-- Phase 16 Wave 2 Task 2.2 — Create dispatch_daily_reports cron-only fan-out.
--
-- Selects shops where local time is within the 22:22:30..22:37:30 window
-- AND ≥ 1 booking exists for the local date AND no daily_reports row
-- exists yet. For each matched shop, invokes generate_daily_report.
-- Zero-shop ticks write a heartbeat row to daily_report_runs (LD-7).
--
-- AMEND-7 finding: shops.archived_at does NOT exist on this project —
-- confirmed via Wave 1 pre-flight grep. No archive predicate needed; the
-- shop_local CTE selects all shops.
--
-- AMEND-6: half-open range form keeps idx_bookings_shop_date_status hot.
-- statement_timeout caps fan-out wall clock (checklist 2.13 + 3.12).
-- Per-shop failures are caught and counted; one bad shop does not poison
-- siblings (checklist 6.2 graceful degradation).

CREATE OR REPLACE FUNCTION public.dispatch_daily_reports()
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE
  v_started_at  TIMESTAMPTZ := clock_timestamp();
  v_shop_count  INT := 0;
  v_error_count INT := 0;
  v_row         RECORD;
BEGIN
  SET LOCAL statement_timeout = '30s';

  FOR v_row IN
    WITH shop_local AS (
      SELECT
        sh.id                                                  AS shop_id,
        sh.timezone                                            AS tz,
        (now() AT TIME ZONE sh.timezone)::time                 AS local_time,
        (now() AT TIME ZONE sh.timezone)::date                 AS local_date
      FROM public.shops sh
      -- AMEND-7: shops.archived_at column not present on this project; no
      -- archive predicate. If a future phase adds soft-delete to shops,
      -- update this CTE to filter archived rows.
    )
    SELECT sl.shop_id, sl.local_date AS report_date
    FROM shop_local sl
    WHERE sl.local_time BETWEEN TIME '22:22:30' AND TIME '22:37:30'
      AND EXISTS (
        SELECT 1 FROM public.bookings b
        WHERE b.shop_id = sl.shop_id
          AND b.booking_date >= ((sl.local_date::timestamp) AT TIME ZONE sl.tz)
          AND b.booking_date <  (((sl.local_date + 1)::timestamp) AT TIME ZONE sl.tz)
      )
      AND NOT EXISTS (
        SELECT 1 FROM public.daily_reports dr
        WHERE dr.shop_id = sl.shop_id AND dr.report_date = sl.local_date
      )
  LOOP
    BEGIN
      PERFORM public.generate_daily_report(v_row.shop_id, v_row.report_date);
      v_shop_count := v_shop_count + 1;
    EXCEPTION
      WHEN OTHERS THEN
        v_error_count := v_error_count + 1;
        -- Inner exception logged by generate_daily_report's own catch-all;
        -- we continue the loop so a single shop's failure does not poison
        -- sibling shops in the same tick.
    END;
  END LOOP;

  -- LD-7: heartbeat row when zero shops matched, so we know the cron ran.
  IF v_shop_count = 0 AND v_error_count = 0 THEN
    INSERT INTO public.daily_report_runs (
      shop_id, report_date, triggered_by, outcome, error_code
    ) VALUES (NULL, NULL, 'cron', 'skipped_zero_bookings', NULL);
  END IF;

  -- Structured RED-metric log (checklist 4.6).
  RAISE NOTICE 'daily_report.dispatch_completed shop_count=% error_count=% duration_ms=%',
    v_shop_count,
    v_error_count,
    EXTRACT(MILLISECONDS FROM clock_timestamp() - v_started_at)::int;
END;
$function$;

REVOKE ALL ON FUNCTION public.dispatch_daily_reports() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.dispatch_daily_reports() FROM authenticated;
-- No GRANT to authenticated — cron runs as superuser; LD-10 explicit deny.

COMMENT ON FUNCTION public.dispatch_daily_reports() IS
  'Phase 16: cron-only fan-out. Scheduled */15 * * * * via dispatch-daily-reports cron job. Selects shops with local time in [22:22:30, 22:37:30] AND >=1 booking today AND no daily_reports row yet, then invokes generate_daily_report per shop. Zero-shop ticks write a heartbeat row to daily_report_runs (LD-7). 30s statement_timeout caps the fan-out wall clock (checklist 2.13). Per-shop failures are caught and counted; one failing shop never poisons sibling shops. SECURITY DEFINER. REVOKED from authenticated.';
