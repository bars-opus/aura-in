-- Phase 16 Wave 1 Task 1.6 — Register dispatch-daily-reports pg_cron job (AMEND-4).
--
-- Timestamp ordered AFTER Wave 2 RPC migrations because the cron body
-- invokes dispatch_daily_reports(). Direct SQL invocation, no Edge
-- Function (AMEND-4 — RESEARCH §2.3 justifies vs. precedent's HTTP hop).
-- Graceful skip when pg_cron is absent (RESEARCH §2.1 precedent).
-- Defensive unschedule-first idempotency (RESEARCH §2.2 precedent).

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
    RAISE NOTICE 'pg_cron extension not installed — skipping dispatch-daily-reports cron registration. Enable pg_cron via Supabase Dashboard and re-run this migration.';
    RETURN;
  END IF;

  PERFORM cron.unschedule('dispatch-daily-reports')
  WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'dispatch-daily-reports');

  PERFORM cron.schedule(
    'dispatch-daily-reports',
    '*/15 * * * *',
    $cron$ SELECT public.dispatch_daily_reports(); $cron$
  );

  RAISE NOTICE 'Scheduled dispatch-daily-reports at */15 * * * *';
END $$;
