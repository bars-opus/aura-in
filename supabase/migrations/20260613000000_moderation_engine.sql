-- Moderation engine: mutual user blocking, structured reports, append-only audit.
-- Drop-in for Flutter + Supabase apps. See architecture/MODERATION_ENGINE.md.

BEGIN;

CREATE TABLE IF NOT EXISTS public.user_blocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  blocker_user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  blocked_user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
  released_at TIMESTAMPTZ,
  pair_user_low UUID GENERATED ALWAYS AS (
    LEAST(blocker_user_id, blocked_user_id)
  ) STORED,
  pair_user_high UUID GENERATED ALWAYS AS (
    GREATEST(blocker_user_id, blocked_user_id)
  ) STORED,
  CONSTRAINT user_blocks_reason_len CHECK (
    reason IS NULL OR char_length(reason) <= 300
  ),
  CONSTRAINT user_blocks_not_self CHECK (blocker_user_id <> blocked_user_id)
);

CREATE UNIQUE INDEX IF NOT EXISTS user_blocks_active_pair_idx
  ON public.user_blocks (pair_user_low, pair_user_high)
  WHERE released_at IS NULL;

CREATE INDEX IF NOT EXISTS user_blocks_blocker_idx
  ON public.user_blocks (blocker_user_id, created_at DESC)
  WHERE released_at IS NULL;

CREATE INDEX IF NOT EXISTS user_blocks_blocked_idx
  ON public.user_blocks (blocked_user_id)
  WHERE released_at IS NULL;

CREATE TABLE IF NOT EXISTS public.moderation_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  target_type TEXT NOT NULL,
  target_id UUID NOT NULL,
  target_owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  details TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  client_idempotency_key UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
  reviewed_at TIMESTAMPTZ,
  CONSTRAINT moderation_reports_target_type_check CHECK (
    target_type IN ('profile', 'shop', 'freelancer')
  ),
  CONSTRAINT moderation_reports_reason_check CHECK (
    reason IN (
      'spam',
      'harassment',
      'impersonation',
      'inappropriate_content',
      'scam_fraud',
      'safety_concern',
      'other'
    )
  ),
  CONSTRAINT moderation_reports_status_check CHECK (
    status IN ('pending', 'reviewing', 'resolved', 'dismissed')
  ),
  CONSTRAINT moderation_reports_details_len CHECK (
    details IS NULL OR char_length(details) <= 1000
  ),
  CONSTRAINT moderation_reports_not_self CHECK (
    reporter_user_id <> target_owner_id
  ),
  CONSTRAINT moderation_reports_idempotency_unique UNIQUE (
    reporter_user_id,
    client_idempotency_key
  )
);

CREATE INDEX IF NOT EXISTS moderation_reports_queue_idx
  ON public.moderation_reports (status, created_at DESC);

CREATE INDEX IF NOT EXISTS moderation_reports_target_owner_idx
  ON public.moderation_reports (target_owner_id, created_at DESC);

-- Rate-limit window for report submissions (per reporter, per target_owner).
CREATE INDEX IF NOT EXISTS moderation_reports_recent_by_reporter_idx
  ON public.moderation_reports (reporter_user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS public.moderation_audit_log (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  action TEXT NOT NULL,
  actor_user_id UUID,
  target_user_id UUID,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS moderation_audit_recent_idx
  ON public.moderation_audit_log (created_at DESC);

ALTER TABLE public.user_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moderation_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moderation_audit_log ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.user_blocks FROM PUBLIC, anon, authenticated;
REVOKE ALL ON TABLE public.moderation_reports FROM PUBLIC, anon, authenticated;
REVOKE ALL ON TABLE public.moderation_audit_log FROM PUBLIC, anon, authenticated;
REVOKE UPDATE, DELETE, TRUNCATE ON TABLE public.moderation_audit_log FROM service_role;

CREATE OR REPLACE FUNCTION public.prevent_moderation_audit_modification()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE EXCEPTION 'moderation_audit_log is append-only (% blocked)', TG_OP;
END;
$$;

DROP TRIGGER IF EXISTS moderation_audit_no_update ON public.moderation_audit_log;
CREATE TRIGGER moderation_audit_no_update
  BEFORE UPDATE ON public.moderation_audit_log
  FOR EACH ROW
  EXECUTE FUNCTION public.prevent_moderation_audit_modification();

DROP TRIGGER IF EXISTS moderation_audit_no_delete ON public.moderation_audit_log;
CREATE TRIGGER moderation_audit_no_delete
  BEFORE DELETE ON public.moderation_audit_log
  FOR EACH ROW
  EXECUTE FUNCTION public.prevent_moderation_audit_modification();

DROP TRIGGER IF EXISTS moderation_audit_no_truncate ON public.moderation_audit_log;
CREATE TRIGGER moderation_audit_no_truncate
  BEFORE TRUNCATE ON public.moderation_audit_log
  FOR EACH STATEMENT
  EXECUTE FUNCTION public.prevent_moderation_audit_modification();

CREATE OR REPLACE FUNCTION public.record_moderation_audit(
  p_action TEXT,
  p_actor_user_id UUID,
  p_target_user_id UUID,
  p_payload JSONB DEFAULT '{}'::jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.moderation_audit_log (
    action,
    actor_user_id,
    target_user_id,
    payload
  ) VALUES (
    p_action,
    p_actor_user_id,
    p_target_user_id,
    COALESCE(p_payload, '{}'::jsonb)
  );
END;
$$;

-- Verifies the target row exists AND that target_owner_id matches the owning user.
-- This stops a caller from reporting an existing target_id with a forged owner.
CREATE OR REPLACE FUNCTION public.moderation_target_exists(
  p_target_type TEXT,
  p_target_id UUID,
  p_target_owner_id UUID
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_exists boolean := false;
BEGIN
  CASE p_target_type
    WHEN 'profile' THEN
      SELECT EXISTS(
        SELECT 1 FROM public.profiles
        WHERE id = p_target_id
          AND id = p_target_owner_id
      ) INTO v_exists;
    WHEN 'shop' THEN
      SELECT EXISTS(
        SELECT 1 FROM public.shops
        WHERE id = p_target_id
          AND user_id = p_target_owner_id
      ) INTO v_exists;
    WHEN 'freelancer' THEN
      SELECT EXISTS(
        SELECT 1 FROM public.workers
        WHERE id = p_target_id
          AND user_id = p_target_owner_id
          AND is_freelancer = true
      ) INTO v_exists;
    ELSE
      v_exists := false;
  END CASE;

  RETURN v_exists;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_moderation_hidden_user_ids()
RETURNS SETOF UUID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT DISTINCT
    CASE
      WHEN blocker_user_id = auth.uid() THEN blocked_user_id
      ELSE blocker_user_id
    END AS hidden_user_id
  FROM public.user_blocks
  WHERE released_at IS NULL
    AND auth.uid() IS NOT NULL
    AND (blocker_user_id = auth.uid() OR blocked_user_id = auth.uid());
$$;

-- Paginated list of accounts the current user has blocked.
-- Cursor is the created_at of the last row; first page passes NULL.
CREATE OR REPLACE FUNCTION public.get_blocked_accounts(
  p_limit INTEGER DEFAULT 50,
  p_cursor_created_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS TABLE(
  id UUID,
  blocked_user_id UUID,
  username TEXT,
  display_name TEXT,
  avatar_url TEXT,
  reason TEXT,
  created_at TIMESTAMPTZ
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    ub.id,
    ub.blocked_user_id,
    p.username,
    p.display_name,
    p.avatar_url,
    ub.reason,
    ub.created_at
  FROM public.user_blocks ub
  JOIN public.profiles p ON p.id = ub.blocked_user_id
  WHERE ub.blocker_user_id = auth.uid()
    AND ub.released_at IS NULL
    AND (p_cursor_created_at IS NULL OR ub.created_at < p_cursor_created_at)
  ORDER BY ub.created_at DESC
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 50), 1), 200);
$$;

CREATE OR REPLACE FUNCTION public.is_moderation_blocked(
  p_other_user_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_current_user_id UUID := auth.uid();
  v_blocked_by_current_user BOOLEAN := false;
  v_blocking_current_user BOOLEAN := false;
BEGIN
  IF v_current_user_id IS NULL OR p_other_user_id IS NULL THEN
    RETURN jsonb_build_object(
      'is_blocked', false,
      'is_blocked_by_current_user', false,
      'is_blocking_current_user', false
    );
  END IF;

  SELECT EXISTS(
    SELECT 1
    FROM public.user_blocks
    WHERE blocker_user_id = v_current_user_id
      AND blocked_user_id = p_other_user_id
      AND released_at IS NULL
  ) INTO v_blocked_by_current_user;

  SELECT EXISTS(
    SELECT 1
    FROM public.user_blocks
    WHERE blocker_user_id = p_other_user_id
      AND blocked_user_id = v_current_user_id
      AND released_at IS NULL
  ) INTO v_blocking_current_user;

  RETURN jsonb_build_object(
    'is_blocked', v_blocked_by_current_user OR v_blocking_current_user,
    'is_blocked_by_current_user', v_blocked_by_current_user,
    'is_blocking_current_user', v_blocking_current_user
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.block_user(
  p_blocked_user_id UUID,
  p_reason TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_current_user_id UUID := auth.uid();
  v_existing_id UUID;
BEGIN
  IF v_current_user_id IS NULL THEN
    RAISE EXCEPTION 'unauthorized' USING HINT = 'auth_required';
  END IF;

  IF p_blocked_user_id IS NULL THEN
    RAISE EXCEPTION 'invalid_input' USING HINT = 'blocked_user_required';
  END IF;

  IF v_current_user_id = p_blocked_user_id THEN
    RAISE EXCEPTION 'self_block_not_allowed' USING HINT = 'self_block_not_allowed';
  END IF;

  IF p_reason IS NOT NULL AND char_length(p_reason) > 300 THEN
    RAISE EXCEPTION 'invalid_input' USING HINT = 'reason_max_300';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.profiles WHERE id = p_blocked_user_id
  ) THEN
    RAISE EXCEPTION 'invalid_input' USING HINT = 'target_not_found';
  END IF;

  -- Atomic insert; if a race produces a duplicate active pair, the partial
  -- unique index rejects the second insert and we report already_blocked.
  BEGIN
    INSERT INTO public.user_blocks (
      blocker_user_id,
      blocked_user_id,
      reason
    ) VALUES (
      v_current_user_id,
      p_blocked_user_id,
      NULLIF(trim(p_reason), '')
    );
  EXCEPTION
    WHEN unique_violation THEN
      RETURN jsonb_build_object('success', true, 'reason', 'already_blocked');
  END;

  PERFORM public.record_moderation_audit(
    'block_user',
    v_current_user_id,
    p_blocked_user_id,
    jsonb_build_object('reason', NULLIF(trim(p_reason), ''))
  );

  RETURN jsonb_build_object('success', true);
END;
$$;

CREATE OR REPLACE FUNCTION public.unblock_user(
  p_blocked_user_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_current_user_id UUID := auth.uid();
  v_rows_affected INTEGER;
BEGIN
  IF v_current_user_id IS NULL THEN
    RAISE EXCEPTION 'unauthorized' USING HINT = 'auth_required';
  END IF;

  UPDATE public.user_blocks
  SET released_at = timezone('utc', now())
  WHERE blocker_user_id = v_current_user_id
    AND blocked_user_id = p_blocked_user_id
    AND released_at IS NULL;

  GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

  IF v_rows_affected = 0 THEN
    RETURN jsonb_build_object('success', true, 'reason', 'not_blocked');
  END IF;

  PERFORM public.record_moderation_audit(
    'unblock_user',
    v_current_user_id,
    p_blocked_user_id,
    '{}'::jsonb
  );

  RETURN jsonb_build_object('success', true);
END;
$$;

-- Rate limit: per reporter, max 20 reports per hour and max 3 reports per
-- target_owner per 24h. Keeps abuse / brigading down without blocking
-- legitimate first-time reports.
CREATE OR REPLACE FUNCTION public.submit_moderation_report(
  p_target_type TEXT,
  p_target_id UUID,
  p_target_owner_id UUID,
  p_reason TEXT,
  p_details TEXT DEFAULT NULL,
  p_client_idempotency_key UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_current_user_id UUID := auth.uid();
  v_existing_id UUID;
  v_recent_count INTEGER;
  v_per_target_count INTEGER;
BEGIN
  IF v_current_user_id IS NULL THEN
    RAISE EXCEPTION 'unauthorized' USING HINT = 'auth_required';
  END IF;

  IF p_target_type NOT IN ('profile', 'shop', 'freelancer') THEN
    RAISE EXCEPTION 'invalid_input' USING HINT = 'target_type_invalid';
  END IF;

  IF p_reason NOT IN (
    'spam',
    'harassment',
    'impersonation',
    'inappropriate_content',
    'scam_fraud',
    'safety_concern',
    'other'
  ) THEN
    RAISE EXCEPTION 'invalid_input' USING HINT = 'reason_invalid';
  END IF;

  IF p_target_id IS NULL OR p_target_owner_id IS NULL THEN
    RAISE EXCEPTION 'invalid_input' USING HINT = 'target_missing';
  END IF;

  IF p_client_idempotency_key IS NULL THEN
    RAISE EXCEPTION 'invalid_input' USING HINT = 'idempotency_required';
  END IF;

  IF p_details IS NOT NULL AND char_length(p_details) > 1000 THEN
    RAISE EXCEPTION 'invalid_input' USING HINT = 'details_max_1000';
  END IF;

  IF v_current_user_id = p_target_owner_id THEN
    RAISE EXCEPTION 'invalid_input' USING HINT = 'self_report_not_allowed';
  END IF;

  IF NOT public.moderation_target_exists(p_target_type, p_target_id, p_target_owner_id) THEN
    RAISE EXCEPTION 'invalid_input' USING HINT = 'target_not_found';
  END IF;

  -- Idempotency replay short-circuit (must run before rate-limit so retries
  -- don't burn the rate-limit budget).
  SELECT id
  INTO v_existing_id
  FROM public.moderation_reports
  WHERE reporter_user_id = v_current_user_id
    AND client_idempotency_key = p_client_idempotency_key
  LIMIT 1;

  IF v_existing_id IS NOT NULL THEN
    RETURN jsonb_build_object('success', true, 'reason', 'already_reported');
  END IF;

  -- Per-reporter throughput rate limit: 20 / hour.
  SELECT count(*)
  INTO v_recent_count
  FROM public.moderation_reports
  WHERE reporter_user_id = v_current_user_id
    AND created_at > timezone('utc', now()) - interval '1 hour';

  IF v_recent_count >= 20 THEN
    RAISE EXCEPTION 'rate_limited' USING HINT = 'rate_limited_hour';
  END IF;

  -- Per-target brigading guard: 3 distinct reports against the same owner / 24h.
  SELECT count(*)
  INTO v_per_target_count
  FROM public.moderation_reports
  WHERE reporter_user_id = v_current_user_id
    AND target_owner_id = p_target_owner_id
    AND created_at > timezone('utc', now()) - interval '24 hours';

  IF v_per_target_count >= 3 THEN
    RAISE EXCEPTION 'rate_limited' USING HINT = 'rate_limited_target';
  END IF;

  INSERT INTO public.moderation_reports (
    reporter_user_id,
    target_type,
    target_id,
    target_owner_id,
    reason,
    details,
    client_idempotency_key
  ) VALUES (
    v_current_user_id,
    p_target_type,
    p_target_id,
    p_target_owner_id,
    p_reason,
    NULLIF(trim(p_details), ''),
    p_client_idempotency_key
  );

  PERFORM public.record_moderation_audit(
    'submit_report',
    v_current_user_id,
    p_target_owner_id,
    jsonb_build_object(
      'target_type', p_target_type,
      'target_id', p_target_id,
      'reason', p_reason
    )
  );

  RETURN jsonb_build_object('success', true);
END;
$$;

REVOKE ALL ON FUNCTION public.record_moderation_audit(TEXT, UUID, UUID, JSONB) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.moderation_target_exists(TEXT, UUID, UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.get_moderation_hidden_user_ids() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.get_blocked_accounts(INTEGER, TIMESTAMPTZ) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.is_moderation_blocked(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.block_user(UUID, TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.unblock_user(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.submit_moderation_report(TEXT, UUID, UUID, TEXT, TEXT, UUID) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.get_moderation_hidden_user_ids() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_blocked_accounts(INTEGER, TIMESTAMPTZ) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_moderation_blocked(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.block_user(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.unblock_user(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.submit_moderation_report(TEXT, UUID, UUID, TEXT, TEXT, UUID) TO authenticated;

COMMIT;
