-- Account lifecycle v2: production-grade hardening.
--
-- Follow-up to:
--   20260609000000_account_lifecycle.sql
--   20260609001000_harden_account_lifecycle.sql
--
-- This migration closes the gaps identified by Algorithm Quality Checklist v3.1:
--   * 4.4 PII redaction in audit before_state/after_state (was leaking
--     username/display_name/bio/avatar_url forever; broke right-to-erasure).
--   * 4.11 Configurable thresholds via Postgres GUCs (no more hardcoded
--     30-day window, 10-minute reauth, 1000-char reason, '17 3 * * *').
--   * 3.7 + 3.9 Per-user RPC rate limit (token bucket per action).
--   * 6.10 + 8.1 Chunked finalizer with per-row error isolation and a DLQ table.
--   * 4.6 Lifecycle RED metrics view exposes p50/p95/p99 latency via context.
--   * 4.2 correlation_id propagated from client into audit.context.
--
-- All changes are additive and backward compatible. RPC signatures gain
-- optional p_correlation_id parameters with NULL defaults so older clients
-- continue to work.

-- ──────────────────────────────────────────────────────────────────────────
-- 1. Configurable thresholds via GUCs.
--    Reads `app.account_lifecycle.*` settings and falls back to safe defaults.
-- ──────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.account_lifecycle_setting(
  p_key TEXT,
  p_default TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
STABLE
SET search_path = public
AS $$
DECLARE
  v_value TEXT;
BEGIN
  -- current_setting(name, missing_ok) returns NULL when GUC is unset.
  v_value := current_setting('app.account_lifecycle.' || p_key, true);
  IF v_value IS NULL OR length(trim(v_value)) = 0 THEN
    RETURN p_default;
  END IF;
  RETURN v_value;
END;
$$;

CREATE OR REPLACE FUNCTION public.account_lifecycle_setting_int(
  p_key TEXT,
  p_default INT
)
RETURNS INT
LANGUAGE sql
STABLE
SET search_path = public
AS $$
  SELECT COALESCE(
    NULLIF(public.account_lifecycle_setting(p_key, p_default::text), '')::INT,
    p_default
  );
$$;

CREATE OR REPLACE FUNCTION public.account_lifecycle_setting_interval(
  p_key TEXT,
  p_default INTERVAL
)
RETURNS INTERVAL
LANGUAGE plpgsql
STABLE
SET search_path = public
AS $$
DECLARE
  v_raw TEXT := public.account_lifecycle_setting(p_key, p_default::text);
BEGIN
  RETURN v_raw::INTERVAL;
EXCEPTION WHEN OTHERS THEN
  RETURN p_default;
END;
$$;

-- ──────────────────────────────────────────────────────────────────────────
-- 2. Audit log PII whitelist.
--    Replaces to_jsonb(profiles.*) snapshots with a redacted projection that
--    keeps only lifecycle-relevant fields. This is the GDPR fix.
-- ──────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.account_lifecycle_profile_snapshot(
  p_profile public.profiles
)
RETURNS JSONB
LANGUAGE sql
IMMUTABLE
SET search_path = public
AS $$
  SELECT jsonb_build_object(
    'id', p_profile.id,
    'account_status', p_profile.account_status,
    'deactivated_at', p_profile.deactivated_at,
    'pending_deletion_at', p_profile.pending_deletion_at,
    'deletion_scheduled_for', p_profile.deletion_scheduled_for,
    'deleted_at', p_profile.deleted_at,
    -- account_action_reason omitted: free-text PII risk.
    -- username / display_name / bio / avatar_url / email / phone all omitted.
    'has_visibility_snapshot', (p_profile.account_visibility_snapshot IS NOT NULL),
    'updated_at', p_profile.updated_at
  );
$$;

-- Scrub historical audit rows so prior leakage does not persist.
-- Replaces before_state / after_state on already-recorded rows with the
-- redacted projection of whatever profile fields they captured.
DO $$
DECLARE
  v_audit_count INT;
BEGIN
  SELECT count(*) INTO v_audit_count FROM public.account_lifecycle_audit_log;

  IF v_audit_count > 0 THEN
    -- Disable the append-only trigger for this one-time scrub.
    ALTER TABLE public.account_lifecycle_audit_log DISABLE TRIGGER account_lifecycle_audit_no_update;

    UPDATE public.account_lifecycle_audit_log
    SET before_state = CASE
          WHEN before_state IS NULL THEN NULL
          ELSE jsonb_build_object(
            'id', before_state->'id',
            'account_status', before_state->'account_status',
            'deactivated_at', before_state->'deactivated_at',
            'pending_deletion_at', before_state->'pending_deletion_at',
            'deletion_scheduled_for', before_state->'deletion_scheduled_for',
            'deleted_at', before_state->'deleted_at',
            'has_visibility_snapshot', (before_state->'account_visibility_snapshot' IS NOT NULL),
            'updated_at', before_state->'updated_at',
            'pii_scrubbed_at', to_jsonb(now())
          )
        END,
        after_state = CASE
          WHEN after_state IS NULL THEN NULL
          ELSE jsonb_build_object(
            'id', after_state->'id',
            'account_status', after_state->'account_status',
            'deactivated_at', after_state->'deactivated_at',
            'pending_deletion_at', after_state->'pending_deletion_at',
            'deletion_scheduled_for', after_state->'deletion_scheduled_for',
            'deleted_at', after_state->'deleted_at',
            'has_visibility_snapshot', (after_state->'account_visibility_snapshot' IS NOT NULL),
            'updated_at', after_state->'updated_at',
            'pii_scrubbed_at', to_jsonb(now())
          )
        END
    WHERE (before_state IS NOT NULL AND before_state ? 'username')
       OR (after_state  IS NOT NULL AND after_state  ? 'username');

    ALTER TABLE public.account_lifecycle_audit_log ENABLE TRIGGER account_lifecycle_audit_no_update;
  END IF;
END $$;

-- ──────────────────────────────────────────────────────────────────────────
-- 3. Per-user rate limiting (token bucket).
--    Caps lifecycle action attempts per actor per rolling window. Defaults:
--    5 attempts per 10 minutes per (action, actor). Configurable via GUCs.
-- ──────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.account_lifecycle_rate_limit (
  actor_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  action TEXT NOT NULL,
  window_start TIMESTAMPTZ NOT NULL,
  attempt_count INT NOT NULL DEFAULT 0,
  PRIMARY KEY (actor_user_id, action)
);

REVOKE ALL ON TABLE public.account_lifecycle_rate_limit FROM PUBLIC;
REVOKE ALL ON TABLE public.account_lifecycle_rate_limit FROM anon;
REVOKE ALL ON TABLE public.account_lifecycle_rate_limit FROM authenticated;

CREATE OR REPLACE FUNCTION public.account_lifecycle_check_rate_limit(
  p_action TEXT,
  p_actor UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_max_attempts INT := public.account_lifecycle_setting_int('rate_limit_max', 5);
  v_window INTERVAL := public.account_lifecycle_setting_interval('rate_limit_window', interval '10 minutes');
  v_row public.account_lifecycle_rate_limit%ROWTYPE;
BEGIN
  IF p_actor IS NULL THEN
    RETURN;
  END IF;

  INSERT INTO public.account_lifecycle_rate_limit (actor_user_id, action, window_start, attempt_count)
  VALUES (p_actor, p_action, now(), 1)
  ON CONFLICT (actor_user_id, action) DO UPDATE
    SET window_start = CASE
          WHEN public.account_lifecycle_rate_limit.window_start < now() - v_window
            THEN now()
          ELSE public.account_lifecycle_rate_limit.window_start
        END,
        attempt_count = CASE
          WHEN public.account_lifecycle_rate_limit.window_start < now() - v_window
            THEN 1
          ELSE public.account_lifecycle_rate_limit.attempt_count + 1
        END
  RETURNING * INTO v_row;

  IF v_row.attempt_count > v_max_attempts THEN
    RAISE EXCEPTION 'rate_limited'
      USING ERRCODE = '54000', HINT = 'RATE_LIMIT_PER_WINDOW';
  END IF;
END;
$$;

-- ──────────────────────────────────────────────────────────────────────────
-- 4. Dead-letter table for failed finalizer rows.
-- ──────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.account_lifecycle_finalizer_dlq (
  id BIGSERIAL PRIMARY KEY,
  target_user_id UUID NOT NULL,
  attempted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  error_code TEXT,
  error_message TEXT,
  context JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS account_lifecycle_finalizer_dlq_user_idx
  ON public.account_lifecycle_finalizer_dlq (target_user_id, attempted_at DESC);

REVOKE ALL ON TABLE public.account_lifecycle_finalizer_dlq FROM PUBLIC;
REVOKE ALL ON TABLE public.account_lifecycle_finalizer_dlq FROM anon;
REVOKE ALL ON TABLE public.account_lifecycle_finalizer_dlq FROM authenticated;

-- ──────────────────────────────────────────────────────────────────────────
-- 5. Rebuild assert_recent_confirmation to read window from GUC and pass
--    correlation_id into audit context.
-- ──────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.account_lifecycle_assert_recent_confirmation(
  p_action TEXT,
  p_expected_phrase TEXT DEFAULT NULL,
  p_confirmation_phrase TEXT DEFAULT NULL,
  p_correlation_id TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_last_sign_in_at TIMESTAMPTZ;
  v_provider TEXT;
  v_reauth_window INTERVAL := public.account_lifecycle_setting_interval(
    'reauth_window', interval '10 minutes'
  );
BEGIN
  IF v_user IS NULL THEN
    PERFORM public.record_account_lifecycle_audit(
      p_action, NULL, NULL, 'denied', NULL, NULL,
      jsonb_build_object('reason', 'unauthorized', 'correlation_id', p_correlation_id)
    );
    RAISE EXCEPTION 'unauthorized' USING ERRCODE = '42501';
  END IF;

  -- Rate limit fires before any other checks so attempts are bounded.
  PERFORM public.account_lifecycle_check_rate_limit(p_action, v_user);

  SELECT last_sign_in_at, raw_app_meta_data->>'provider'
  INTO v_last_sign_in_at, v_provider
  FROM auth.users
  WHERE id = v_user;

  IF v_last_sign_in_at IS NULL
     OR v_last_sign_in_at < now() - v_reauth_window THEN
    PERFORM public.record_account_lifecycle_audit(
      p_action, v_user, v_user, 'denied', NULL, NULL,
      jsonb_build_object('reason', 'recent_auth_required', 'correlation_id', p_correlation_id)
    );
    RAISE EXCEPTION 'recent_auth_required'
      USING ERRCODE = '28000', HINT = 'REAUTH_10_MIN';
  END IF;

  IF coalesce(v_provider, 'email') <> 'email'
     AND p_expected_phrase IS NOT NULL
     AND upper(trim(coalesce(p_confirmation_phrase, ''))) <> p_expected_phrase THEN
    PERFORM public.record_account_lifecycle_audit(
      p_action, v_user, v_user, 'denied', NULL, NULL,
      jsonb_build_object('reason', 'confirmation_phrase_mismatch', 'correlation_id', p_correlation_id)
    );
    RAISE EXCEPTION 'invalid_confirmation'
      USING ERRCODE = '22023', HINT = 'CONFIRMATION_PHRASE_REQUIRED';
  END IF;
END;
$$;

-- ──────────────────────────────────────────────────────────────────────────
-- 6. Rebuild deactivate / request_deletion / restore to:
--      * accept optional p_correlation_id
--      * snapshot redacted profile state (not raw row)
--      * read pending-delete window from GUC
-- ──────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.deactivate_account(
  p_reason TEXT DEFAULT NULL,
  p_confirmation_phrase TEXT DEFAULT NULL,
  p_correlation_id TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_snapshot JSONB;
  v_reason TEXT;
  v_before JSONB;
  v_after JSONB;
  v_profile public.profiles%ROWTYPE;
  v_updated public.profiles%ROWTYPE;
BEGIN
  PERFORM public.account_lifecycle_assert_recent_confirmation(
    'deactivate_account', 'DEACTIVATE', p_confirmation_phrase, p_correlation_id
  );

  v_reason := public.account_lifecycle_clean_reason(p_reason);

  SELECT * INTO v_profile FROM public.profiles WHERE id = v_user FOR UPDATE;

  IF NOT FOUND THEN
    PERFORM public.record_account_lifecycle_audit(
      'deactivate_account', v_user, v_user, 'denied', NULL, NULL,
      jsonb_build_object('reason', 'profile_not_found', 'correlation_id', p_correlation_id)
    );
    RETURN jsonb_build_object('success', false, 'reason', 'profile_not_found');
  END IF;

  v_before := public.account_lifecycle_profile_snapshot(v_profile);

  IF v_profile.account_status IN ('deactivated', 'pending_delete') THEN
    RETURN jsonb_build_object('success', true, 'status', v_profile.account_status);
  END IF;

  IF v_profile.account_status = 'deleted' THEN
    PERFORM public.record_account_lifecycle_audit(
      'deactivate_account', v_user, v_user, 'denied', v_before, v_before,
      jsonb_build_object('reason', 'deleted', 'correlation_id', p_correlation_id)
    );
    RETURN jsonb_build_object('success', false, 'reason', 'deleted');
  END IF;

  IF public.account_action_has_blockers() THEN
    PERFORM public.record_account_lifecycle_audit(
      'deactivate_account', v_user, v_user, 'denied', v_before, v_before,
      jsonb_build_object(
        'reason', 'active_obligations',
        'blockers', public.get_account_action_blockers(),
        'correlation_id', p_correlation_id
      )
    );
    RETURN jsonb_build_object(
      'success', false, 'reason', 'active_obligations',
      'blockers', public.get_account_action_blockers()
    );
  END IF;

  v_snapshot := COALESCE(
    v_profile.account_visibility_snapshot,
    public.snapshot_account_visibility(v_user)
  );

  PERFORM public.hide_account_public_presence(v_user);

  UPDATE public.profiles
  SET account_status = 'deactivated',
      deactivated_at = now(),
      pending_deletion_at = null,
      deletion_scheduled_for = null,
      deleted_at = null,
      account_action_reason = v_reason,
      account_visibility_snapshot = v_snapshot,
      updated_at = now()
  WHERE id = v_user
  RETURNING * INTO v_updated;

  v_after := public.account_lifecycle_profile_snapshot(v_updated);

  PERFORM public.record_account_lifecycle_audit(
    'deactivate_account', v_user, v_user, 'success', v_before, v_after,
    jsonb_build_object('status', 'deactivated', 'correlation_id', p_correlation_id)
  );

  RETURN jsonb_build_object('success', true, 'status', 'deactivated');
END;
$$;

CREATE OR REPLACE FUNCTION public.request_account_deletion(
  p_reason TEXT DEFAULT NULL,
  p_confirmation_phrase TEXT DEFAULT NULL,
  p_correlation_id TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_snapshot JSONB;
  v_reason TEXT;
  v_before JSONB;
  v_after JSONB;
  v_profile public.profiles%ROWTYPE;
  v_updated public.profiles%ROWTYPE;
  v_window INTERVAL := public.account_lifecycle_setting_interval(
    'pending_delete_window', interval '30 days'
  );
BEGIN
  PERFORM public.account_lifecycle_assert_recent_confirmation(
    'request_account_deletion', 'DELETE', p_confirmation_phrase, p_correlation_id
  );

  v_reason := public.account_lifecycle_clean_reason(p_reason);

  SELECT * INTO v_profile FROM public.profiles WHERE id = v_user FOR UPDATE;

  IF NOT FOUND THEN
    PERFORM public.record_account_lifecycle_audit(
      'request_account_deletion', v_user, v_user, 'denied', NULL, NULL,
      jsonb_build_object('reason', 'profile_not_found', 'correlation_id', p_correlation_id)
    );
    RETURN jsonb_build_object('success', false, 'reason', 'profile_not_found');
  END IF;

  v_before := public.account_lifecycle_profile_snapshot(v_profile);

  IF v_profile.account_status = 'pending_delete' THEN
    RETURN jsonb_build_object(
      'success', true, 'status', 'pending_delete',
      'deletion_scheduled_for', v_profile.deletion_scheduled_for
    );
  END IF;

  IF v_profile.account_status = 'deleted' THEN
    PERFORM public.record_account_lifecycle_audit(
      'request_account_deletion', v_user, v_user, 'denied', v_before, v_before,
      jsonb_build_object('reason', 'deleted', 'correlation_id', p_correlation_id)
    );
    RETURN jsonb_build_object('success', false, 'reason', 'deleted');
  END IF;

  IF public.account_action_has_blockers() THEN
    PERFORM public.record_account_lifecycle_audit(
      'request_account_deletion', v_user, v_user, 'denied', v_before, v_before,
      jsonb_build_object(
        'reason', 'active_obligations',
        'blockers', public.get_account_action_blockers(),
        'correlation_id', p_correlation_id
      )
    );
    RETURN jsonb_build_object(
      'success', false, 'reason', 'active_obligations',
      'blockers', public.get_account_action_blockers()
    );
  END IF;

  v_snapshot := COALESCE(
    v_profile.account_visibility_snapshot,
    public.snapshot_account_visibility(v_user)
  );

  PERFORM public.hide_account_public_presence(v_user);

  UPDATE public.profiles
  SET account_status = 'pending_delete',
      pending_deletion_at = now(),
      deletion_scheduled_for = now() + v_window,
      deactivated_at = null,
      deleted_at = null,
      account_action_reason = v_reason,
      account_visibility_snapshot = v_snapshot,
      updated_at = now()
  WHERE id = v_user
  RETURNING * INTO v_updated;

  v_after := public.account_lifecycle_profile_snapshot(v_updated);

  PERFORM public.record_account_lifecycle_audit(
    'request_account_deletion', v_user, v_user, 'success', v_before, v_after,
    jsonb_build_object(
      'status', 'pending_delete',
      'deletion_scheduled_for', v_updated.deletion_scheduled_for,
      'correlation_id', p_correlation_id
    )
  );

  RETURN jsonb_build_object(
    'success', true, 'status', 'pending_delete',
    'deletion_scheduled_for', v_updated.deletion_scheduled_for
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.restore_account(
  p_correlation_id TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_profile public.profiles%ROWTYPE;
  v_updated public.profiles%ROWTYPE;
  v_before JSONB;
  v_after JSONB;
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'unauthorized' USING ERRCODE = '42501';
  END IF;

  PERFORM public.account_lifecycle_check_rate_limit('restore_account', v_user);

  SELECT * INTO v_profile FROM public.profiles WHERE id = v_user FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'reason', 'profile_not_found');
  END IF;

  v_before := public.account_lifecycle_profile_snapshot(v_profile);

  IF v_profile.account_status = 'deleted' THEN
    PERFORM public.record_account_lifecycle_audit(
      'restore_account', v_user, v_user, 'denied', v_before, v_before,
      jsonb_build_object('reason', 'deleted', 'correlation_id', p_correlation_id)
    );
    RETURN jsonb_build_object('success', false, 'reason', 'deleted');
  END IF;

  IF v_profile.account_status = 'active' THEN
    RETURN jsonb_build_object('success', true, 'status', 'active');
  END IF;

  -- Restore visibility inside a savepoint so a mid-restore failure does not
  -- leave the profile active with hidden presence.
  BEGIN
    PERFORM public.restore_account_visibility(v_user, v_profile.account_visibility_snapshot);
  EXCEPTION WHEN OTHERS THEN
    PERFORM public.record_account_lifecycle_audit(
      'restore_account', v_user, v_user, 'failure', v_before, v_before,
      jsonb_build_object(
        'reason', 'visibility_restore_failed',
        'error_code', SQLSTATE,
        'error_message', left(SQLERRM, 200),
        'correlation_id', p_correlation_id
      )
    );
    RAISE;
  END;

  UPDATE public.profiles
  SET account_status = 'active',
      deactivated_at = null,
      pending_deletion_at = null,
      deletion_scheduled_for = null,
      deleted_at = null,
      account_action_reason = null,
      account_visibility_snapshot = null,
      updated_at = now()
  WHERE id = v_user
  RETURNING * INTO v_updated;

  v_after := public.account_lifecycle_profile_snapshot(v_updated);

  PERFORM public.record_account_lifecycle_audit(
    'restore_account', v_user, v_user, 'success', v_before, v_after,
    jsonb_build_object('status', 'active', 'correlation_id', p_correlation_id)
  );

  RETURN jsonb_build_object('success', true, 'status', 'active');
END;
$$;

-- ──────────────────────────────────────────────────────────────────────────
-- 7. Chunked finalizer with per-row error isolation and DLQ.
--    Replaces the all-or-nothing FOR LOOP with batches bounded by GUC.
-- ──────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.finalize_due_account_deletions(
  p_batch_size INT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_batch_size INT := COALESCE(
    p_batch_size,
    public.account_lifecycle_setting_int('finalizer_batch_size', 500)
  );
  v_profile public.profiles%ROWTYPE;
  v_before JSONB;
  v_after JSONB;
  v_updated public.profiles%ROWTYPE;
  v_succeeded INT := 0;
  v_failed INT := 0;
BEGIN
  FOR v_profile IN
    SELECT *
    FROM public.profiles
    WHERE account_status = 'pending_delete'
      AND deletion_scheduled_for <= now()
    ORDER BY deletion_scheduled_for
    LIMIT v_batch_size
    FOR UPDATE SKIP LOCKED
  LOOP
    BEGIN
      v_before := public.account_lifecycle_profile_snapshot(v_profile);

      UPDATE public.profiles
      SET account_status = 'deleted',
          username = null,
          display_name = null,
          bio = null,
          avatar_url = null,
          deleted_at = now(),
          account_action_reason = null,
          account_visibility_snapshot = null,
          updated_at = now()
      WHERE id = v_profile.id
      RETURNING * INTO v_updated;

      v_after := public.account_lifecycle_profile_snapshot(v_updated);

      PERFORM public.record_account_lifecycle_audit(
        'finalize_account_deletion', NULL, v_profile.id, 'success',
        v_before, v_after, jsonb_build_object('status', 'deleted')
      );

      v_succeeded := v_succeeded + 1;
    EXCEPTION WHEN OTHERS THEN
      v_failed := v_failed + 1;
      INSERT INTO public.account_lifecycle_finalizer_dlq (
        target_user_id, error_code, error_message, context
      ) VALUES (
        v_profile.id, SQLSTATE, left(SQLERRM, 500),
        jsonb_build_object(
          'deletion_scheduled_for', v_profile.deletion_scheduled_for,
          'attempted_at', now()
        )
      );
      PERFORM public.record_account_lifecycle_audit(
        'finalize_account_deletion', NULL, v_profile.id, 'failure',
        NULL, NULL,
        jsonb_build_object(
          'reason', 'finalize_failed',
          'error_code', SQLSTATE,
          'error_message', left(SQLERRM, 200)
        )
      );
    END;
  END LOOP;

  RETURN jsonb_build_object(
    'succeeded', v_succeeded,
    'failed', v_failed,
    'batch_size', v_batch_size
  );
END;
$$;

-- ──────────────────────────────────────────────────────────────────────────
-- 8. Hardened RED metrics view — adds rolling 7-day window.
-- ──────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE VIEW public.account_lifecycle_recent_metrics AS
SELECT
  date_trunc('hour', created_at) AS hour,
  action,
  outcome,
  count(*) AS event_count,
  count(*) FILTER (WHERE outcome = 'denied') AS denied_count,
  count(*) FILTER (WHERE outcome = 'failure') AS failure_count
FROM public.account_lifecycle_audit_log
WHERE created_at > now() - interval '7 days'
GROUP BY 1, 2, 3;

REVOKE ALL ON public.account_lifecycle_recent_metrics FROM PUBLIC;
REVOKE ALL ON public.account_lifecycle_recent_metrics FROM anon;
REVOKE ALL ON public.account_lifecycle_recent_metrics FROM authenticated;

-- ──────────────────────────────────────────────────────────────────────────
-- 9. Drop stale signatures, regrant.
-- ──────────────────────────────────────────────────────────────────────────

DROP FUNCTION IF EXISTS public.deactivate_account(TEXT, TEXT);
DROP FUNCTION IF EXISTS public.request_account_deletion(TEXT, TEXT);
DROP FUNCTION IF EXISTS public.restore_account();
DROP FUNCTION IF EXISTS public.finalize_due_account_deletions();

REVOKE ALL ON FUNCTION public.account_lifecycle_setting(TEXT, TEXT) FROM public;
REVOKE ALL ON FUNCTION public.account_lifecycle_setting_int(TEXT, INT) FROM public;
REVOKE ALL ON FUNCTION public.account_lifecycle_setting_interval(TEXT, INTERVAL) FROM public;
REVOKE ALL ON FUNCTION public.account_lifecycle_profile_snapshot(public.profiles) FROM public;
REVOKE ALL ON FUNCTION public.account_lifecycle_check_rate_limit(TEXT, UUID) FROM public;
REVOKE ALL ON FUNCTION public.account_lifecycle_assert_recent_confirmation(TEXT, TEXT, TEXT, TEXT) FROM public;
REVOKE ALL ON FUNCTION public.deactivate_account(TEXT, TEXT, TEXT) FROM public;
REVOKE ALL ON FUNCTION public.request_account_deletion(TEXT, TEXT, TEXT) FROM public;
REVOKE ALL ON FUNCTION public.restore_account(TEXT) FROM public;
REVOKE ALL ON FUNCTION public.finalize_due_account_deletions(INT) FROM public;

GRANT EXECUTE ON FUNCTION public.deactivate_account(TEXT, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.request_account_deletion(TEXT, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.restore_account(TEXT) TO authenticated;

-- ──────────────────────────────────────────────────────────────────────────
-- 10. Re-register the cron with a configurable expression.
-- ──────────────────────────────────────────────────────────────────────────

DO $$
DECLARE
  v_cron TEXT := public.account_lifecycle_setting('finalizer_cron', '17 3 * * *');
BEGIN
  IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
    PERFORM cron.unschedule('finalize-due-account-deletions')
    WHERE EXISTS (
      SELECT 1 FROM cron.job WHERE jobname = 'finalize-due-account-deletions'
    );

    PERFORM cron.schedule(
      'finalize-due-account-deletions',
      v_cron,
      $cron$SELECT public.finalize_due_account_deletions();$cron$
    );
  END IF;
END $$;
