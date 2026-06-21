-- Account lifecycle hardening verification script.
--
-- This is a manual SQL smoke/regression script in the same style as the
-- existing Supabase tests. Run against a staging project after applying:
--   20260609000000_account_lifecycle.sql
--   20260609001000_harden_account_lifecycle.sql
--
-- Required psql variables:
--   :user_id         auth.users.id with a profile and no active obligations
--   :old_jwt_sub     auth.users.id whose auth.users.last_sign_in_at is older
--                    than 10 minutes
--
-- Each block rolls back its own mutations.

-- 1. Reason length is bounded.
BEGIN;
  SELECT set_config('request.jwt.claim.sub', :'user_id', true);
  SELECT set_config('request.jwt.claim.role', 'authenticated', true);

  SELECT public.deactivate_account(repeat('x', 1001), NULL);
  -- Expected: ERROR invalid_input, HINT REASON_MAX_1000.
ROLLBACK;

-- 2. Pending deletion is idempotent and does not extend the scheduled date.
BEGIN;
  SELECT set_config('request.jwt.claim.sub', :'user_id', true);
  SELECT set_config('request.jwt.claim.role', 'authenticated', true);

  SELECT public.request_account_deletion('first request', NULL) AS first_result \gset
  SELECT public.request_account_deletion('retry request', NULL) AS retry_result \gset

  -- Expected:
  --   (:first_result->>'deletion_scheduled_for')
  --   equals
  --   (:retry_result->>'deletion_scheduled_for')
ROLLBACK;

-- 3. Recent auth is enforced.
BEGIN;
  SELECT set_config('request.jwt.claim.sub', :'old_jwt_sub', true);
  SELECT set_config('request.jwt.claim.role', 'authenticated', true);

  SELECT public.deactivate_account(NULL, NULL);
  -- Expected: ERROR recent_auth_required, HINT REAUTH_10_MIN.
ROLLBACK;

-- 4. Audit rows are append-only.
BEGIN;
  UPDATE public.account_lifecycle_audit_log
  SET outcome = 'failure'
  WHERE id = (
    SELECT id FROM public.account_lifecycle_audit_log LIMIT 1
  );
  -- Expected: ERROR account_lifecycle_audit_log is append-only.
ROLLBACK;

-- 5. Finalizer records audit and scrubs profile PII.
BEGIN;
  UPDATE public.profiles
  SET account_status = 'pending_delete',
      pending_deletion_at = now() - interval '31 days',
      deletion_scheduled_for = now() - interval '1 minute'
  WHERE id = :'user_id';

  SELECT public.finalize_due_account_deletions();

  SELECT account_status, username, display_name, bio, avatar_url
  FROM public.profiles
  WHERE id = :'user_id';
  -- Expected: deleted, null, null, null, null.
ROLLBACK;
