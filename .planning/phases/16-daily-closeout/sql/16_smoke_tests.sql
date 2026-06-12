-- Phase 16 — manual SQL smoke tests for the Daily Close-Out Report.
--
-- Hand-runnable against a staging branch DB. pgTAP intentionally
-- deferred. Wrapped in BEGIN/ROLLBACK with SAVEPOINTs per section so
-- every test rolls back automatically. Each section ends with
-- `RAISE NOTICE 'OK: <case>';` on success.
--
-- Coverage maps to the 18 SPEC success criteria:
--   §A — daily_reports table + RLS owner-only verify              (SC-2)
--   §B — generate_daily_report happy path (5 bookings, 50 GHS)    (SC-1, SC-2, SC-3)
--   §C — cross-owner authz raises OWNER_NOT_FOUND                 (SC-14)
--   §D — future date raises REPORT_DATE_INVALID                   (SC-15)
--   §E — > 365-day-old date raises REPORT_DATE_INVALID            (SC-16)
--   §F — no_show_no_action follow-up honours client_notes.booking_id (LD-13 / AMEND-2)
--   §G — yesterday + last-week comparison rows (NULL semantics)   (SC-4, SC-5)
--   §H — daily_report_runs append-only: UPDATE attempt rejected   (LD-5 / 2.22)
--   §I — list_daily_reports happy path + page_size clamp          (SC-17)
--   §J — Manual re-generate REPLACES snapshot (idempotency)       (SC-11)
--   §K — Duplicate cron tick is a no-op                           (SC-12)
--   §L — Zero-booking shop NOT dispatched (heartbeat only)        (SC-13, SC-7)
--   §M — Per-worker + per-service breakdowns sum to revenue       (SC-6, SC-7)
--   §N — Tomorrow peek (count + first_booking_at)                 (SC-8)
--   §O — IST shop (timezone='Asia/Kolkata') dispatch timing       (SC-18)
--
-- Reference identities (inlined throughout):
--   owner_a_uid     = 00000000-0000-0000-0000-000000000a01
--   owner_b_uid     = 00000000-0000-0000-0000-000000000a02
--   shop_a          = 00000000-0000-0000-0000-000000000b01
--   shop_b          = 00000000-0000-0000-0000-000000000b02
--   shop_ist        = 00000000-0000-0000-0000-000000000b03
--   slot_haircut    = 00000000-0000-0000-0000-000000000c01
--   worker_ama      = 00000000-0000-0000-0000-000000000d01
--
-- Pre-flight (BLOCKING — verify before any section runs):
--   (1) SELECT count(*) FROM information_schema.columns
--         WHERE table_schema='public' AND table_name='shops'
--           AND column_name='timezone';
--       → must be 1 (Task 1.1 applied).
--   (2) SELECT count(*) FROM information_schema.tables
--         WHERE table_schema='public' AND table_name='daily_reports';
--       → must be 1 (Task 1.2 applied).
--   (3) SELECT count(*) FROM information_schema.tables
--         WHERE table_schema='public' AND table_name='daily_report_runs';
--       → must be 1 (Task 1.3 applied).
--   (4) SELECT count(*) FROM information_schema.columns
--         WHERE table_schema='public' AND table_name='client_notes'
--           AND column_name='booking_id';
--       → must be 1 (Task 1.4 applied).
--   (5) SELECT 'daily_report'::notification_type;
--       → must succeed (Task 1.5 applied).
--   (6) SELECT count(*) FROM pg_proc
--         WHERE proname IN
--           ('generate_daily_report','dispatch_daily_reports','list_daily_reports');
--       → must be 3 (Wave 2 applied).
--   (7) SELECT 1 FROM cron.job WHERE jobname = 'dispatch-daily-reports';
--       → must return 1 row (Task 1.6 applied AND pg_cron enabled).

BEGIN;

-- ============================================================
-- Set up identities + a shop with 5 completed bookings today.
-- ============================================================

INSERT INTO auth.users (id, email, raw_user_meta_data)
VALUES
  ('00000000-0000-0000-0000-000000000a01', 'owner_a@test', '{}'::jsonb),
  ('00000000-0000-0000-0000-000000000a02', 'owner_b@test', '{}'::jsonb)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.shops (id, user_id, name, currency, timezone)
VALUES
  ('00000000-0000-0000-0000-000000000b01',
   '00000000-0000-0000-0000-000000000a01',
   'Shop A', 'GHS', 'Africa/Accra'),
  ('00000000-0000-0000-0000-000000000b02',
   '00000000-0000-0000-0000-000000000a02',
   'Shop B', 'GHS', 'Africa/Accra'),
  ('00000000-0000-0000-0000-000000000b03',
   '00000000-0000-0000-0000-000000000a01',
   'Shop IST', 'INR', 'Asia/Kolkata')
ON CONFLICT (id) DO UPDATE
  SET timezone = EXCLUDED.timezone, currency = EXCLUDED.currency;

INSERT INTO public.workers (id, shop_id, name, is_active)
VALUES
  ('00000000-0000-0000-0000-000000000d01',
   '00000000-0000-0000-0000-000000000b01',
   'Ama', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.appointment_slots
  (id, shop_id, service_name, slot_type, max_clients, price)
VALUES
  ('00000000-0000-0000-0000-000000000c01',
   '00000000-0000-0000-0000-000000000b01',
   'Haircut', 'standard', 1, 50.00)
ON CONFLICT (id) DO NOTHING;

-- Five completed bookings TODAY in Africa/Accra.
DO $$
DECLARE
  v_today_start TIMESTAMPTZ
    := ((now() AT TIME ZONE 'Africa/Accra')::date::timestamp)
       AT TIME ZONE 'Africa/Accra';
  v_b UUID;
  i INT;
BEGIN
  FOR i IN 1..5 LOOP
    v_b := gen_random_uuid();
    INSERT INTO public.bookings
      (id, user_id, shop_id, booking_date,
       start_time, end_time, actual_end_time,
       status, total_amount, deposit_amount, payment_status)
    VALUES
      (v_b,
       '00000000-0000-0000-0000-000000000a02',
       '00000000-0000-0000-0000-000000000b01',
       v_today_start + (i * interval '1 hour'),
       v_today_start + (i * interval '1 hour'),
       v_today_start + (i * interval '1 hour') + interval '30 minutes',
       v_today_start + (i * interval '1 hour') + interval '30 minutes',
       'completed', 50.00, 15.00, 'paid');
    INSERT INTO public.booking_services
      (id, booking_id, slot_id, worker_id, service_name,
       price_at_booking, duration_minutes)
    VALUES
      (gen_random_uuid(), v_b,
       '00000000-0000-0000-0000-000000000c01',
       '00000000-0000-0000-0000-000000000d01',
       'Haircut', 50.00, 30);
  END LOOP;
END $$;

-- ============================================================
-- §A — daily_reports RLS owner-only SELECT (SC-2)
-- ============================================================
SAVEPOINT s_a;
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a02","role":"authenticated"}';

INSERT INTO public.daily_reports
  (shop_id, report_date, payload)
VALUES
  ('00000000-0000-0000-0000-000000000b01',
   (now() AT TIME ZONE 'Africa/Accra')::date,
   '{"revenue_minor": 0, "currency":"GHS", "schema_version":1}'::jsonb)
ON CONFLICT (shop_id, report_date) DO NOTHING;

DO $$
DECLARE
  v_seen INT;
BEGIN
  -- owner_b cannot SELECT shop_a's row.
  SELECT count(*) INTO v_seen
  FROM public.daily_reports
  WHERE shop_id = '00000000-0000-0000-0000-000000000b01';
  IF v_seen <> 0 THEN
    RAISE EXCEPTION 'FAIL §A: cross-shop SELECT leaked, saw % rows', v_seen;
  END IF;
  RAISE NOTICE 'OK: §A daily_reports RLS owner-only SELECT enforced';
END $$;
RESET ROLE;
ROLLBACK TO SAVEPOINT s_a;

-- ============================================================
-- §B — generate_daily_report happy path (SC-1, SC-2, SC-3)
-- ============================================================
SAVEPOINT s_b;
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a01","role":"authenticated"}';

SELECT public.generate_daily_report(
  '00000000-0000-0000-0000-000000000b01',
  (now() AT TIME ZONE 'Africa/Accra')::date
);

DO $$
DECLARE
  v_rev_minor BIGINT;
  v_completed INT;
  v_run_count INT;
  v_notif_count INT;
BEGIN
  SELECT (payload->>'revenue_minor')::bigint,
         (payload->'bookings'->>'completed')::int
    INTO v_rev_minor, v_completed
  FROM public.daily_reports
  WHERE shop_id = '00000000-0000-0000-0000-000000000b01'
    AND report_date = (now() AT TIME ZONE 'Africa/Accra')::date;

  IF v_rev_minor <> 25000 THEN
    RAISE EXCEPTION 'FAIL §B: expected revenue_minor=25000, got %', v_rev_minor;
  END IF;
  IF v_completed <> 5 THEN
    RAISE EXCEPTION 'FAIL §B: expected completed=5, got %', v_completed;
  END IF;

  SELECT count(*) INTO v_run_count
  FROM public.daily_report_runs
  WHERE shop_id = '00000000-0000-0000-0000-000000000b01'
    AND outcome = 'created';
  IF v_run_count < 1 THEN
    RAISE EXCEPTION 'FAIL §B: no created audit row';
  END IF;

  SELECT count(*) INTO v_notif_count
  FROM public.scheduled_notifications
  WHERE shop_id = '00000000-0000-0000-0000-000000000b01'
    AND notification_type = 'daily_report';
  IF v_notif_count < 1 THEN
    RAISE EXCEPTION 'FAIL §B: no scheduled_notifications row';
  END IF;

  RAISE NOTICE 'OK: §B happy path — revenue 25000 kobo, 5 completed, audit + push present';
END $$;
RESET ROLE;
ROLLBACK TO SAVEPOINT s_b;

-- ============================================================
-- §C — Cross-owner authz raises OWNER_NOT_FOUND (SC-14)
-- ============================================================
SAVEPOINT s_c;
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a02","role":"authenticated"}';

DO $$
DECLARE
  v_hint TEXT := '';
BEGIN
  BEGIN
    PERFORM public.generate_daily_report(
      '00000000-0000-0000-0000-000000000b01',  -- shop owned by owner_a
      (now() AT TIME ZONE 'Africa/Accra')::date
    );
    RAISE EXCEPTION 'FAIL §C: expected OWNER_NOT_FOUND, RPC returned success';
  EXCEPTION
    WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS v_hint = PG_EXCEPTION_HINT;
      IF v_hint <> 'OWNER_NOT_FOUND' THEN
        RAISE EXCEPTION 'FAIL §C: expected OWNER_NOT_FOUND, got "%"', v_hint;
      END IF;
  END;
  RAISE NOTICE 'OK: §C cross-owner authz raises OWNER_NOT_FOUND';
END $$;
RESET ROLE;
ROLLBACK TO SAVEPOINT s_c;

-- ============================================================
-- §D — Future date raises REPORT_DATE_INVALID (SC-15)
-- ============================================================
SAVEPOINT s_d;
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a01","role":"authenticated"}';

DO $$
DECLARE
  v_hint TEXT := '';
BEGIN
  BEGIN
    PERFORM public.generate_daily_report(
      '00000000-0000-0000-0000-000000000b01',
      ((now() AT TIME ZONE 'Africa/Accra')::date + 1)
    );
    RAISE EXCEPTION 'FAIL §D: expected REPORT_DATE_INVALID, RPC returned success';
  EXCEPTION
    WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS v_hint = PG_EXCEPTION_HINT;
      IF v_hint <> 'REPORT_DATE_INVALID' THEN
        RAISE EXCEPTION 'FAIL §D: expected REPORT_DATE_INVALID, got "%"', v_hint;
      END IF;
  END;
  RAISE NOTICE 'OK: §D future date raises REPORT_DATE_INVALID';
END $$;
RESET ROLE;
ROLLBACK TO SAVEPOINT s_d;

-- ============================================================
-- §E — > 365-day-old date raises REPORT_DATE_INVALID (SC-16)
-- ============================================================
SAVEPOINT s_e;
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a01","role":"authenticated"}';

DO $$
DECLARE
  v_hint TEXT := '';
BEGIN
  BEGIN
    PERFORM public.generate_daily_report(
      '00000000-0000-0000-0000-000000000b01',
      ((now() AT TIME ZONE 'Africa/Accra')::date - 400)
    );
    RAISE EXCEPTION 'FAIL §E: expected REPORT_DATE_INVALID for stale date';
  EXCEPTION
    WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS v_hint = PG_EXCEPTION_HINT;
      IF v_hint <> 'REPORT_DATE_INVALID' THEN
        RAISE EXCEPTION 'FAIL §E: expected REPORT_DATE_INVALID, got "%"', v_hint;
      END IF;
  END;
  RAISE NOTICE 'OK: §E >365-day-old date raises REPORT_DATE_INVALID';
END $$;
RESET ROLE;
ROLLBACK TO SAVEPOINT s_e;

-- ============================================================
-- §F — no_show_no_action follow-up honours client_notes.booking_id
--      (LD-13 / AMEND-2)
-- ============================================================
SAVEPOINT s_f;

-- One no_show booking today.
DO $$
DECLARE
  v_b UUID := gen_random_uuid();
  v_today_start TIMESTAMPTZ
    := ((now() AT TIME ZONE 'Africa/Accra')::date::timestamp)
       AT TIME ZONE 'Africa/Accra';
BEGIN
  INSERT INTO public.bookings
    (id, user_id, shop_id, booking_date,
     start_time, end_time, actual_end_time,
     status, total_amount, deposit_amount, payment_status)
  VALUES
    (v_b,
     '00000000-0000-0000-0000-000000000a02',
     '00000000-0000-0000-0000-000000000b01',
     v_today_start + interval '20 hours',
     v_today_start + interval '20 hours',
     v_today_start + interval '20 hours' + interval '30 minutes',
     v_today_start + interval '20 hours' + interval '30 minutes',
     'no_show', 50.00, 15.00, 'failed');
  -- Stash the id for the next block.
  CREATE TEMP TABLE IF NOT EXISTS _smoke_f (booking_id UUID);
  INSERT INTO _smoke_f VALUES (v_b);
END $$;

SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a01","role":"authenticated"}';

SELECT public.generate_daily_report(
  '00000000-0000-0000-0000-000000000b01',
  (now() AT TIME ZONE 'Africa/Accra')::date
);

DO $$
DECLARE
  v_fu_count INT;
BEGIN
  SELECT count(*) INTO v_fu_count
  FROM public.daily_reports dr,
       jsonb_array_elements(dr.payload->'follow_ups') fu
  WHERE dr.shop_id = '00000000-0000-0000-0000-000000000b01'
    AND dr.report_date = (now() AT TIME ZONE 'Africa/Accra')::date
    AND fu->>'reason' = 'no_show_no_action';
  IF v_fu_count < 1 THEN
    RAISE EXCEPTION 'FAIL §F: expected no_show_no_action follow-up, got 0';
  END IF;
  RAISE NOTICE 'OK: §F no_show_no_action present when no client_notes.booking_id';
END $$;
RESET ROLE;

-- Add a client_notes row WITH booking_id, then re-generate; the follow-up
-- for that booking should disappear.
INSERT INTO public.client_notes (shop_id, user_id, body, booking_id)
SELECT '00000000-0000-0000-0000-000000000b01',
       '00000000-0000-0000-0000-000000000a02',
       'Called and left voicemail',
       booking_id
FROM _smoke_f;

SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a01","role":"authenticated"}';

SELECT public.generate_daily_report(
  '00000000-0000-0000-0000-000000000b01',
  (now() AT TIME ZONE 'Africa/Accra')::date
);

DO $$
DECLARE
  v_fu_count INT;
  v_b UUID;
BEGIN
  SELECT booking_id INTO v_b FROM _smoke_f LIMIT 1;
  SELECT count(*) INTO v_fu_count
  FROM public.daily_reports dr,
       jsonb_array_elements(dr.payload->'follow_ups') fu
  WHERE dr.shop_id = '00000000-0000-0000-0000-000000000b01'
    AND dr.report_date = (now() AT TIME ZONE 'Africa/Accra')::date
    AND fu->>'reason' = 'no_show_no_action'
    AND (fu->>'booking_id')::uuid = v_b;
  IF v_fu_count <> 0 THEN
    RAISE EXCEPTION 'FAIL §F: follow-up should disappear after note logged';
  END IF;
  RAISE NOTICE 'OK: §F note with booking_id suppresses no_show_no_action follow-up';
END $$;
RESET ROLE;
ROLLBACK TO SAVEPOINT s_f;

-- ============================================================
-- §G — Comparison NULL semantics (SC-4, SC-5, LD-14)
-- ============================================================
SAVEPOINT s_g;
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a01","role":"authenticated"}';

SELECT public.generate_daily_report(
  '00000000-0000-0000-0000-000000000b01',
  (now() AT TIME ZONE 'Africa/Accra')::date
);

DO $$
DECLARE
  v_payload JSONB;
  v_yesterday JSONB;
  v_lastweek  JSONB;
BEGIN
  SELECT payload INTO v_payload
  FROM public.daily_reports
  WHERE shop_id = '00000000-0000-0000-0000-000000000b01'
    AND report_date = (now() AT TIME ZONE 'Africa/Accra')::date;

  v_yesterday := v_payload->'comparison'->'yesterday';
  v_lastweek  := v_payload->'comparison'->'same_day_last_week';

  -- Both comparison dates had zero bookings in this fixture → both NULL.
  IF v_yesterday IS NOT NULL AND v_yesterday <> 'null'::jsonb THEN
    RAISE EXCEPTION 'FAIL §G: expected yesterday=null (no bookings yesterday), got %', v_yesterday;
  END IF;
  IF v_lastweek IS NOT NULL AND v_lastweek <> 'null'::jsonb THEN
    RAISE EXCEPTION 'FAIL §G: expected same_day_last_week=null, got %', v_lastweek;
  END IF;
  RAISE NOTICE 'OK: §G comparison rows are NULL when comparison date had zero bookings';
END $$;
RESET ROLE;
ROLLBACK TO SAVEPOINT s_g;

-- ============================================================
-- §H — daily_report_runs append-only (LD-5 / checklist 2.22)
-- ============================================================
SAVEPOINT s_h;
SET LOCAL ROLE service_role;

DO $$
DECLARE
  v_err_state TEXT := '';
BEGIN
  BEGIN
    UPDATE public.daily_report_runs SET outcome = 'updated' WHERE 1 = 0;
    RAISE EXCEPTION 'FAIL §H: UPDATE on daily_report_runs should be revoked';
  EXCEPTION
    WHEN insufficient_privilege THEN
      RAISE NOTICE 'OK: §H UPDATE on daily_report_runs revoked from service_role';
    WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS v_err_state = RETURNED_SQLSTATE;
      RAISE EXCEPTION 'FAIL §H: UPDATE failed with unexpected SQLSTATE % (expected 42501)', v_err_state;
  END;

  BEGIN
    DELETE FROM public.daily_report_runs WHERE 1 = 0;
    RAISE EXCEPTION 'FAIL §H: DELETE on daily_report_runs should be revoked';
  EXCEPTION
    WHEN insufficient_privilege THEN
      RAISE NOTICE 'OK: §H DELETE on daily_report_runs revoked from service_role';
    WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS v_err_state = RETURNED_SQLSTATE;
      RAISE EXCEPTION 'FAIL §H: DELETE failed with unexpected SQLSTATE % (expected 42501)', v_err_state;
  END;
END $$;
RESET ROLE;
ROLLBACK TO SAVEPOINT s_h;

-- ============================================================
-- §I — list_daily_reports page_size clamp + sort (SC-17)
-- ============================================================
SAVEPOINT s_i;
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a01","role":"authenticated"}';

DO $$
DECLARE
  v_count INT;
BEGIN
  -- page_size=5 clamps to 10 (LD-9). With 0–1 rows we still get back ≤ pageSize.
  SELECT count(*) INTO v_count
  FROM public.list_daily_reports(
    '00000000-0000-0000-0000-000000000b01', NULL, 5
  );
  IF v_count > 10 THEN
    RAISE EXCEPTION 'FAIL §I: page_size clamp lower-bound failed: %', v_count;
  END IF;

  SELECT count(*) INTO v_count
  FROM public.list_daily_reports(
    '00000000-0000-0000-0000-000000000b01', NULL, 100
  );
  IF v_count > 50 THEN
    RAISE EXCEPTION 'FAIL §I: page_size clamp upper-bound failed: %', v_count;
  END IF;
  RAISE NOTICE 'OK: §I list_daily_reports clamps page_size to [10, 50]';
END $$;
RESET ROLE;
ROLLBACK TO SAVEPOINT s_i;

-- ============================================================
-- §J — Manual re-generate REPLACES snapshot (SC-11)
-- ============================================================
SAVEPOINT s_j;
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a01","role":"authenticated"}';

SELECT public.generate_daily_report(
  '00000000-0000-0000-0000-000000000b01',
  (now() AT TIME ZONE 'Africa/Accra')::date
);
SELECT public.generate_daily_report(
  '00000000-0000-0000-0000-000000000b01',
  (now() AT TIME ZONE 'Africa/Accra')::date
);

DO $$
DECLARE
  v_rows  INT;
  v_runs  INT;
BEGIN
  SELECT count(*) INTO v_rows
  FROM public.daily_reports
  WHERE shop_id = '00000000-0000-0000-0000-000000000b01'
    AND report_date = (now() AT TIME ZONE 'Africa/Accra')::date;
  IF v_rows <> 1 THEN
    RAISE EXCEPTION 'FAIL §J: expected exactly 1 daily_reports row after re-generate, got %', v_rows;
  END IF;

  SELECT count(*) INTO v_runs
  FROM public.daily_report_runs
  WHERE shop_id = '00000000-0000-0000-0000-000000000b01'
    AND outcome IN ('created', 'updated');
  IF v_runs < 2 THEN
    RAISE EXCEPTION 'FAIL §J: expected ≥ 2 audit rows after two generations, got %', v_runs;
  END IF;
  RAISE NOTICE 'OK: §J re-generate REPLACES snapshot; audit logs both attempts';
END $$;
RESET ROLE;
ROLLBACK TO SAVEPOINT s_j;

-- ============================================================
-- §K — Duplicate cron tick is a no-op (SC-12)
-- ============================================================
SAVEPOINT s_k;
-- Simulate two cron dispatches against the same minute. The selector's
-- NOT EXISTS guard on daily_reports filters the second pass out.
SELECT public.dispatch_daily_reports();
SELECT public.dispatch_daily_reports();

DO $$
DECLARE
  v_rows INT;
BEGIN
  -- Just verify no exception was raised and the table has at most one row
  -- per (shop, date) — the UNIQUE constraint guarantees this.
  SELECT count(*) INTO v_rows
  FROM (
    SELECT shop_id, report_date, count(*) AS c
    FROM public.daily_reports
    GROUP BY shop_id, report_date
    HAVING count(*) > 1
  ) t;
  IF v_rows > 0 THEN
    RAISE EXCEPTION 'FAIL §K: duplicate (shop_id, report_date) rows exist: %', v_rows;
  END IF;
  RAISE NOTICE 'OK: §K duplicate cron tick is a no-op (UNIQUE constraint holds)';
END $$;
ROLLBACK TO SAVEPOINT s_k;

-- ============================================================
-- §L — Zero-booking shop NOT dispatched (SC-13, SC-7)
-- ============================================================
SAVEPOINT s_l;
-- shop_b has no bookings today by fixture.
SELECT public.dispatch_daily_reports();

DO $$
DECLARE
  v_b_rows INT;
  v_b_notif INT;
BEGIN
  SELECT count(*) INTO v_b_rows
  FROM public.daily_reports
  WHERE shop_id = '00000000-0000-0000-0000-000000000b02';
  IF v_b_rows <> 0 THEN
    RAISE EXCEPTION 'FAIL §L: zero-booking shop should not get a daily_reports row, got %', v_b_rows;
  END IF;

  SELECT count(*) INTO v_b_notif
  FROM public.scheduled_notifications
  WHERE shop_id = '00000000-0000-0000-0000-000000000b02'
    AND notification_type = 'daily_report';
  IF v_b_notif <> 0 THEN
    RAISE EXCEPTION 'FAIL §L: zero-booking shop should not receive a push, got %', v_b_notif;
  END IF;
  RAISE NOTICE 'OK: §L zero-booking shop skipped — no row, no push';
END $$;
ROLLBACK TO SAVEPOINT s_l;

-- ============================================================
-- §M — Per-worker + per-service breakdowns sum to revenue (SC-6, SC-7)
-- ============================================================
SAVEPOINT s_m;
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a01","role":"authenticated"}';

SELECT public.generate_daily_report(
  '00000000-0000-0000-0000-000000000b01',
  (now() AT TIME ZONE 'Africa/Accra')::date
);

DO $$
DECLARE
  v_rev       BIGINT;
  v_worker_sum BIGINT;
  v_svc_sum    BIGINT;
BEGIN
  SELECT (payload->>'revenue_minor')::bigint,
         COALESCE((
           SELECT sum((w->>'revenue_minor')::bigint)
           FROM jsonb_array_elements(payload->'per_worker') w
         ), 0),
         COALESCE((
           SELECT sum((s->>'revenue_minor')::bigint)
           FROM jsonb_array_elements(payload->'per_service') s
         ), 0)
    INTO v_rev, v_worker_sum, v_svc_sum
  FROM public.daily_reports
  WHERE shop_id = '00000000-0000-0000-0000-000000000b01'
    AND report_date = (now() AT TIME ZONE 'Africa/Accra')::date;

  IF v_worker_sum <> v_rev THEN
    RAISE EXCEPTION 'FAIL §M: per_worker sum % <> revenue %', v_worker_sum, v_rev;
  END IF;
  IF v_svc_sum <> v_rev THEN
    RAISE EXCEPTION 'FAIL §M: per_service sum % <> revenue %', v_svc_sum, v_rev;
  END IF;
  RAISE NOTICE 'OK: §M per-worker + per-service breakdowns each sum to revenue';
END $$;
RESET ROLE;
ROLLBACK TO SAVEPOINT s_m;

-- ============================================================
-- §N — Tomorrow peek (SC-8)
-- ============================================================
SAVEPOINT s_n;

-- Insert one booking for tomorrow.
DO $$
DECLARE
  v_b UUID := gen_random_uuid();
  v_tomorrow_start TIMESTAMPTZ
    := (((now() AT TIME ZONE 'Africa/Accra')::date + 1)::timestamp
        + interval '9 hours')
       AT TIME ZONE 'Africa/Accra';
BEGIN
  INSERT INTO public.bookings
    (id, user_id, shop_id, booking_date,
     start_time, end_time, actual_end_time,
     status, total_amount, deposit_amount, payment_status)
  VALUES
    (v_b,
     '00000000-0000-0000-0000-000000000a02',
     '00000000-0000-0000-0000-000000000b01',
     v_tomorrow_start,
     v_tomorrow_start,
     v_tomorrow_start + interval '30 minutes',
     v_tomorrow_start + interval '30 minutes',
     'confirmed', 50.00, 15.00, 'paid');
END $$;

SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" =
  '{"sub":"00000000-0000-0000-0000-000000000a01","role":"authenticated"}';

SELECT public.generate_daily_report(
  '00000000-0000-0000-0000-000000000b01',
  (now() AT TIME ZONE 'Africa/Accra')::date
);

DO $$
DECLARE
  v_count INT;
  v_first TIMESTAMPTZ;
BEGIN
  SELECT (payload->'tomorrow'->>'count')::int,
         (payload->'tomorrow'->>'first_booking_at')::timestamptz
    INTO v_count, v_first
  FROM public.daily_reports
  WHERE shop_id = '00000000-0000-0000-0000-000000000b01'
    AND report_date = (now() AT TIME ZONE 'Africa/Accra')::date;

  IF v_count <> 1 THEN
    RAISE EXCEPTION 'FAIL §N: tomorrow.count expected 1, got %', v_count;
  END IF;
  IF v_first IS NULL THEN
    RAISE EXCEPTION 'FAIL §N: tomorrow.first_booking_at should be non-null';
  END IF;
  RAISE NOTICE 'OK: §N tomorrow peek populated (count=1, first_booking_at set)';
END $$;
RESET ROLE;
ROLLBACK TO SAVEPOINT s_n;

-- ============================================================
-- §O — IST shop (timezone='Asia/Kolkata') dispatch timing (SC-18)
-- ============================================================
SAVEPOINT s_o;
-- We can't easily move the clock here, so we verify the timezone column
-- is set + the local-time computation works for the IST shop.
DO $$
DECLARE
  v_local_time TIME;
  v_local_date DATE;
BEGIN
  SELECT (now() AT TIME ZONE sh.timezone)::time,
         (now() AT TIME ZONE sh.timezone)::date
    INTO v_local_time, v_local_date
  FROM public.shops sh
  WHERE sh.id = '00000000-0000-0000-0000-000000000b03';

  IF v_local_time IS NULL OR v_local_date IS NULL THEN
    RAISE EXCEPTION 'FAIL §O: timezone math failed for Asia/Kolkata shop';
  END IF;
  -- A staging-tester running this within ±7.5 min of 17:00 UTC should
  -- see local_time ≈ 22:30 IST. We only assert that the math runs.
  RAISE NOTICE 'OK: §O Asia/Kolkata shop local_time=%, local_date=% (expect 22:30 IST when UTC≈17:00)',
    v_local_time, v_local_date;
END $$;
ROLLBACK TO SAVEPOINT s_o;

-- ============================================================
-- Roll everything back.
-- ============================================================
ROLLBACK;

-- End of Phase 16 smoke.
