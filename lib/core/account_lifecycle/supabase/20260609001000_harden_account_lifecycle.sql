-- Account lifecycle hardening.
--
-- Follow-up to 20260609000000_account_lifecycle.sql, which has already been
-- applied remotely. This migration keeps the public RPC names but tightens the
-- contract around destructive mutations:
--   * bounded reason input
--   * recent auth verification
--   * idempotent pending-delete scheduling
--   * append-only account lifecycle audit trail

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_account_action_reason_len
  CHECK (account_action_reason IS NULL OR length(account_action_reason) <= 1000)
  NOT VALID;

ALTER TABLE public.profiles
  VALIDATE CONSTRAINT profiles_account_action_reason_len;

CREATE TABLE IF NOT EXISTS public.account_lifecycle_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  action TEXT NOT NULL CHECK (length(action) BETWEEN 1 AND 64),
  actor_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  target_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  outcome TEXT NOT NULL CHECK (outcome IN ('success', 'failure', 'denied')),
  before_state JSONB,
  after_state JSONB,
  context JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS account_lifecycle_audit_recent_idx
  ON public.account_lifecycle_audit_log (created_at DESC);

CREATE INDEX IF NOT EXISTS account_lifecycle_audit_actor_idx
  ON public.account_lifecycle_audit_log (actor_user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS account_lifecycle_audit_target_idx
  ON public.account_lifecycle_audit_log (target_user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS account_lifecycle_audit_action_idx
  ON public.account_lifecycle_audit_log (action, created_at DESC);

ALTER TABLE public.account_lifecycle_audit_log ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE VIEW public.account_lifecycle_daily_metrics AS
SELECT
  date_trunc('day', created_at) AS day,
  action,
  outcome,
  count(*) AS event_count
FROM public.account_lifecycle_audit_log
GROUP BY 1, 2, 3;

REVOKE ALL ON TABLE public.account_lifecycle_audit_log FROM PUBLIC;
REVOKE ALL ON TABLE public.account_lifecycle_audit_log FROM anon;
REVOKE ALL ON TABLE public.account_lifecycle_audit_log FROM authenticated;
REVOKE UPDATE, DELETE, TRUNCATE ON TABLE public.account_lifecycle_audit_log FROM service_role;
REVOKE ALL ON public.account_lifecycle_daily_metrics FROM PUBLIC;
REVOKE ALL ON public.account_lifecycle_daily_metrics FROM anon;
REVOKE ALL ON public.account_lifecycle_daily_metrics FROM authenticated;

CREATE OR REPLACE FUNCTION public.prevent_account_lifecycle_audit_modification()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RAISE EXCEPTION 'account_lifecycle_audit_log is append-only (% blocked)', TG_OP;
END;
$$;

DROP TRIGGER IF EXISTS account_lifecycle_audit_no_update
  ON public.account_lifecycle_audit_log;
CREATE TRIGGER account_lifecycle_audit_no_update
  BEFORE UPDATE ON public.account_lifecycle_audit_log
  FOR EACH STATEMENT
  EXECUTE FUNCTION public.prevent_account_lifecycle_audit_modification();

DROP TRIGGER IF EXISTS account_lifecycle_audit_no_delete
  ON public.account_lifecycle_audit_log;
CREATE TRIGGER account_lifecycle_audit_no_delete
  BEFORE DELETE ON public.account_lifecycle_audit_log
  FOR EACH STATEMENT
  EXECUTE FUNCTION public.prevent_account_lifecycle_audit_modification();

DROP TRIGGER IF EXISTS account_lifecycle_audit_no_truncate
  ON public.account_lifecycle_audit_log;
CREATE TRIGGER account_lifecycle_audit_no_truncate
  BEFORE TRUNCATE ON public.account_lifecycle_audit_log
  FOR EACH STATEMENT
  EXECUTE FUNCTION public.prevent_account_lifecycle_audit_modification();

CREATE OR REPLACE FUNCTION public.record_account_lifecycle_audit(
  p_action TEXT,
  p_actor_user_id UUID,
  p_target_user_id UUID,
  p_outcome TEXT,
  p_before_state JSONB DEFAULT NULL,
  p_after_state JSONB DEFAULT NULL,
  p_context JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_id UUID;
BEGIN
  IF length(coalesce(p_action, '')) = 0 OR length(p_action) > 64 THEN
    RAISE EXCEPTION 'invalid_action' USING ERRCODE = '22023';
  END IF;

  IF p_outcome NOT IN ('success', 'failure', 'denied') THEN
    RAISE EXCEPTION 'invalid_outcome' USING ERRCODE = '22023';
  END IF;

  IF octet_length(coalesce(p_context::text, '{}')) > 8192 THEN
    RAISE EXCEPTION 'context_too_large' USING ERRCODE = '22023';
  END IF;

  INSERT INTO public.account_lifecycle_audit_log (
    action,
    actor_user_id,
    target_user_id,
    outcome,
    before_state,
    after_state,
    context
  )
  VALUES (
    p_action,
    p_actor_user_id,
    p_target_user_id,
    p_outcome,
    p_before_state,
    p_after_state,
    coalesce(p_context, '{}'::jsonb)
  )
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.account_lifecycle_clean_reason(p_reason TEXT)
RETURNS TEXT
LANGUAGE plpgsql
IMMUTABLE
SET search_path = public
AS $$
DECLARE
  v_reason TEXT := NULLIF(trim(coalesce(p_reason, '')), '');
BEGIN
  IF v_reason IS NOT NULL AND length(v_reason) > 1000 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'REASON_MAX_1000';
  END IF;

  RETURN v_reason;
END;
$$;

CREATE OR REPLACE FUNCTION public.account_lifecycle_assert_recent_confirmation(
  p_action TEXT,
  p_expected_phrase TEXT DEFAULT NULL,
  p_confirmation_phrase TEXT DEFAULT NULL
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
BEGIN
  IF v_user IS NULL THEN
    PERFORM public.record_account_lifecycle_audit(
      p_action,
      NULL,
      NULL,
      'denied',
      NULL,
      NULL,
      jsonb_build_object('reason', 'unauthorized')
    );
    RAISE EXCEPTION 'unauthorized' USING ERRCODE = '42501';
  END IF;

  SELECT last_sign_in_at, raw_app_meta_data->>'provider'
  INTO v_last_sign_in_at, v_provider
  FROM auth.users
  WHERE id = v_user;

  IF v_last_sign_in_at IS NULL
     OR v_last_sign_in_at < now() - interval '10 minutes' THEN
    PERFORM public.record_account_lifecycle_audit(
      p_action,
      v_user,
      v_user,
      'denied',
      NULL,
      NULL,
      jsonb_build_object('reason', 'recent_auth_required')
    );
    RAISE EXCEPTION 'recent_auth_required'
      USING ERRCODE = '28000', HINT = 'REAUTH_10_MIN';
  END IF;

  IF coalesce(v_provider, 'email') <> 'email'
     AND p_expected_phrase IS NOT NULL
     AND upper(trim(coalesce(p_confirmation_phrase, ''))) <> p_expected_phrase THEN
    PERFORM public.record_account_lifecycle_audit(
      p_action,
      v_user,
      v_user,
      'denied',
      NULL,
      NULL,
      jsonb_build_object('reason', 'confirmation_phrase_mismatch')
    );
    RAISE EXCEPTION 'invalid_confirmation'
      USING ERRCODE = '22023', HINT = 'CONFIRMATION_PHRASE_REQUIRED';
  END IF;
END;
$$;

DROP FUNCTION IF EXISTS public.deactivate_account(TEXT);
DROP FUNCTION IF EXISTS public.request_account_deletion(TEXT);

CREATE OR REPLACE FUNCTION public.deactivate_account(
  p_reason TEXT DEFAULT NULL,
  p_confirmation_phrase TEXT DEFAULT NULL
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
BEGIN
  PERFORM public.account_lifecycle_assert_recent_confirmation(
    'deactivate_account',
    'DEACTIVATE',
    p_confirmation_phrase
  );

  v_reason := public.account_lifecycle_clean_reason(p_reason);

  SELECT *
  INTO v_profile
  FROM public.profiles
  WHERE id = v_user
  FOR UPDATE;

  IF NOT FOUND THEN
    PERFORM public.record_account_lifecycle_audit(
      'deactivate_account',
      v_user,
      v_user,
      'denied',
      NULL,
      NULL,
      jsonb_build_object('reason', 'profile_not_found')
    );
    RETURN jsonb_build_object('success', false, 'reason', 'profile_not_found');
  END IF;

  v_before := to_jsonb(v_profile);

  IF v_profile.account_status IN ('deactivated', 'pending_delete') THEN
    RETURN jsonb_build_object('success', true, 'status', v_profile.account_status);
  END IF;

  IF v_profile.account_status = 'deleted' THEN
    PERFORM public.record_account_lifecycle_audit(
      'deactivate_account',
      v_user,
      v_user,
      'denied',
      v_before,
      v_before,
      jsonb_build_object('reason', 'deleted')
    );
    RETURN jsonb_build_object('success', false, 'reason', 'deleted');
  END IF;

  IF public.account_action_has_blockers() THEN
    PERFORM public.record_account_lifecycle_audit(
      'deactivate_account',
      v_user,
      v_user,
      'denied',
      v_before,
      v_before,
      jsonb_build_object(
        'reason', 'active_obligations',
        'blockers', public.get_account_action_blockers()
      )
    );
    RETURN jsonb_build_object(
      'success', false,
      'reason', 'active_obligations',
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
  RETURNING to_jsonb(profiles.*) INTO v_after;

  PERFORM public.record_account_lifecycle_audit(
    'deactivate_account',
    v_user,
    v_user,
    'success',
    v_before,
    v_after,
    jsonb_build_object('status', 'deactivated')
  );

  RETURN jsonb_build_object('success', true, 'status', 'deactivated');
END;
$$;

CREATE OR REPLACE FUNCTION public.request_account_deletion(
  p_reason TEXT DEFAULT NULL,
  p_confirmation_phrase TEXT DEFAULT NULL
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
BEGIN
  PERFORM public.account_lifecycle_assert_recent_confirmation(
    'request_account_deletion',
    'DELETE',
    p_confirmation_phrase
  );

  v_reason := public.account_lifecycle_clean_reason(p_reason);

  SELECT *
  INTO v_profile
  FROM public.profiles
  WHERE id = v_user
  FOR UPDATE;

  IF NOT FOUND THEN
    PERFORM public.record_account_lifecycle_audit(
      'request_account_deletion',
      v_user,
      v_user,
      'denied',
      NULL,
      NULL,
      jsonb_build_object('reason', 'profile_not_found')
    );
    RETURN jsonb_build_object('success', false, 'reason', 'profile_not_found');
  END IF;

  v_before := to_jsonb(v_profile);

  IF v_profile.account_status = 'pending_delete' THEN
    RETURN jsonb_build_object(
      'success', true,
      'status', 'pending_delete',
      'deletion_scheduled_for', v_profile.deletion_scheduled_for
    );
  END IF;

  IF v_profile.account_status = 'deleted' THEN
    PERFORM public.record_account_lifecycle_audit(
      'request_account_deletion',
      v_user,
      v_user,
      'denied',
      v_before,
      v_before,
      jsonb_build_object('reason', 'deleted')
    );
    RETURN jsonb_build_object('success', false, 'reason', 'deleted');
  END IF;

  IF public.account_action_has_blockers() THEN
    PERFORM public.record_account_lifecycle_audit(
      'request_account_deletion',
      v_user,
      v_user,
      'denied',
      v_before,
      v_before,
      jsonb_build_object(
        'reason', 'active_obligations',
        'blockers', public.get_account_action_blockers()
      )
    );
    RETURN jsonb_build_object(
      'success', false,
      'reason', 'active_obligations',
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
      deletion_scheduled_for = now() + interval '30 days',
      deactivated_at = null,
      deleted_at = null,
      account_action_reason = v_reason,
      account_visibility_snapshot = v_snapshot,
      updated_at = now()
  WHERE id = v_user
  RETURNING to_jsonb(profiles.*) INTO v_after;

  PERFORM public.record_account_lifecycle_audit(
    'request_account_deletion',
    v_user,
    v_user,
    'success',
    v_before,
    v_after,
    jsonb_build_object(
      'status', 'pending_delete',
      'deletion_scheduled_for', v_after->>'deletion_scheduled_for'
    )
  );

  RETURN jsonb_build_object(
    'success', true,
    'status', 'pending_delete',
    'deletion_scheduled_for', v_after->>'deletion_scheduled_for'
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.restore_account()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_profile public.profiles%ROWTYPE;
  v_before JSONB;
  v_after JSONB;
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'unauthorized' USING ERRCODE = '42501';
  END IF;

  SELECT *
  INTO v_profile
  FROM public.profiles
  WHERE id = v_user
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'reason', 'profile_not_found');
  END IF;

  v_before := to_jsonb(v_profile);

  IF v_profile.account_status = 'deleted' THEN
    PERFORM public.record_account_lifecycle_audit(
      'restore_account',
      v_user,
      v_user,
      'denied',
      v_before,
      v_before,
      jsonb_build_object('reason', 'deleted')
    );
    RETURN jsonb_build_object('success', false, 'reason', 'deleted');
  END IF;

  IF v_profile.account_status = 'active' THEN
    RETURN jsonb_build_object('success', true, 'status', 'active');
  END IF;

  PERFORM public.restore_account_visibility(v_user, v_profile.account_visibility_snapshot);

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
  RETURNING to_jsonb(profiles.*) INTO v_after;

  PERFORM public.record_account_lifecycle_audit(
    'restore_account',
    v_user,
    v_user,
    'success',
    v_before,
    v_after,
    jsonb_build_object('status', 'active')
  );

  RETURN jsonb_build_object('success', true, 'status', 'active');
END;
$$;

CREATE OR REPLACE FUNCTION public.finalize_due_account_deletions()
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_profile public.profiles%ROWTYPE;
  v_before JSONB;
  v_after JSONB;
  v_count INT := 0;
BEGIN
  FOR v_profile IN
    SELECT *
    FROM public.profiles
    WHERE account_status = 'pending_delete'
      AND deletion_scheduled_for <= now()
    FOR UPDATE
  LOOP
    v_before := to_jsonb(v_profile);

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
    RETURNING to_jsonb(profiles.*) INTO v_after;

    PERFORM public.record_account_lifecycle_audit(
      'finalize_account_deletion',
      NULL,
      v_profile.id,
      'success',
      v_before,
      v_after,
      jsonb_build_object('status', 'deleted')
    );

    v_count := v_count + 1;
  END LOOP;

  RETURN v_count;
END;
$$;

REVOKE ALL ON FUNCTION public.record_account_lifecycle_audit(TEXT, UUID, UUID, TEXT, JSONB, JSONB, JSONB) FROM public;
REVOKE ALL ON FUNCTION public.account_lifecycle_clean_reason(TEXT) FROM public;
REVOKE ALL ON FUNCTION public.account_lifecycle_assert_recent_confirmation(TEXT, TEXT, TEXT) FROM public;
REVOKE ALL ON FUNCTION public.deactivate_account(TEXT, TEXT) FROM public;
REVOKE ALL ON FUNCTION public.request_account_deletion(TEXT, TEXT) FROM public;

GRANT EXECUTE ON FUNCTION public.deactivate_account(TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.request_account_deletion(TEXT, TEXT) TO authenticated;
