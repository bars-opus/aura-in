-- Phase 16 Wave 1 Task 1.0 — Pre-flight check (AMEND-7).
--
-- Reports the state of pg_cron, pg_net, and shops.archived_at without
-- failing. The findings are captured in the PR description so Task 1.6
-- (cron registration) and Task 2.2 (dispatch_daily_reports archived_at
-- predicate) can branch on the live result.
--
-- This migration is a no-op DO block. It writes no schema. Re-running is safe.

DO $$
DECLARE
  v_cron_present BOOLEAN;
  v_net_present  BOOLEAN;
  v_archived_col BOOLEAN;
BEGIN
  SELECT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron')
    INTO v_cron_present;
  SELECT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_net')
    INTO v_net_present;
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'shops'
      AND column_name = 'archived_at'
  ) INTO v_archived_col;

  RAISE NOTICE 'Phase 16 pre-flight: pg_cron=%, pg_net=%, shops.archived_at=%',
    v_cron_present, v_net_present, v_archived_col;

  IF NOT v_cron_present THEN
    RAISE NOTICE 'pg_cron missing — dispatcher will not fire. Enable via Supabase Dashboard before merging.';
  END IF;
  IF NOT v_net_present THEN
    RAISE NOTICE 'pg_net missing — not strictly required for Phase 16 (cron uses direct SQL invocation per AMEND-4), but flag for future phases.';
  END IF;
END $$;
