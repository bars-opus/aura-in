-- Phase 10.5 — manual SQL smoke tests.
--
-- Hand-runnable against a staging branch DB. pgTAP is intentionally
-- deferred to a future testing-foundation phase. Replace the four
-- placeholder UUIDs at the top with real values before running.
--
-- Expected behavior: each section ends with `RAISE NOTICE 'OK: <name>';`
-- on success. Anywhere a different result appears, the test failed.
--
-- The `request.jwt.claims` SET LOCAL pattern simulates Supabase's
-- per-request JWT for the authz checks. Run inside a transaction so
-- changes roll back automatically.

BEGIN;

-- ─── placeholders ──────────────────────────────────────────────────
-- Replace these four with real ids from your staging environment.
\set owner_uid    '''00000000-0000-0000-0000-000000000001'''
\set other_uid    '''00000000-0000-0000-0000-000000000002'''
\set shop_a       '''00000000-0000-0000-0000-000000000010'''
\set test_user    '''00000000-0000-0000-0000-000000000020'''

-- ─── A. schedule_manual_booking_reminder authz (P0-U 1.4) ─────────
SAVEPOINT a_auth;

-- Insert a future booking the owner owns.
INSERT INTO bookings (id, user_id, shop_id, slot_id, booking_date,
                      start_time, end_time, total_amount, status)
SELECT 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', :test_user,
       :shop_a, ap.id, current_date,
       now() + interval '2 hours', now() + interval '3 hours', 100, 'confirmed'
FROM appointment_slots ap WHERE ap.shop_id = :shop_a LIMIT 1;

-- (A.1) Non-owner -> 42501 / not_found.
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000002"}';
DO $$ BEGIN
  BEGIN
    PERFORM public.schedule_manual_booking_reminder(
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid);
    RAISE EXCEPTION 'FAIL: non-owner should have raised 42501';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'OK: schedule_manual_booking_reminder authz';
  END;
END $$;

-- (A.2) Owner -> a new scheduled_notifications row appears.
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SELECT public.schedule_manual_booking_reminder(
         'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid) AS new_id;

SELECT
  CASE
    WHEN COUNT(*) = 1 THEN 'OK: notification row inserted'
    ELSE 'FAIL: expected exactly 1 row'
  END
FROM scheduled_notifications
WHERE booking_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
  AND notification_type = 'booking_reminder_manual'
  AND delivery_channel  = 'push'
  AND metadata ->> 'booking_id' = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

ROLLBACK TO SAVEPOINT a_auth;

-- ─── B. Past-time guard (RESEARCH R2) ─────────────────────────────
SAVEPOINT b_past;

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
INSERT INTO bookings (id, user_id, shop_id, slot_id, booking_date,
                      start_time, end_time, total_amount, status)
SELECT 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', :test_user,
       :shop_a, ap.id, current_date,
       now() - interval '1 hour', now(), 100, 'confirmed'
FROM appointment_slots ap WHERE ap.shop_id = :shop_a LIMIT 1;

DO $$ BEGIN
  BEGIN
    PERFORM public.schedule_manual_booking_reminder(
      'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::uuid);
    RAISE EXCEPTION 'FAIL: past-time should have raised';
  EXCEPTION WHEN raise_exception THEN
    RAISE NOTICE 'OK: past-time guard';
  END;
END $$;

ROLLBACK TO SAVEPOINT b_past;

-- ─── C. Guest booking (no push) ───────────────────────────────────
SAVEPOINT c_guest;

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
INSERT INTO bookings (id, user_id, shop_id, slot_id, booking_date,
                      start_time, end_time, total_amount, status)
SELECT 'cccccccc-cccc-cccc-cccc-cccccccccccc', NULL,
       :shop_a, ap.id, current_date,
       now() + interval '4 hours', now() + interval '5 hours', 100, 'confirmed'
FROM appointment_slots ap WHERE ap.shop_id = :shop_a LIMIT 1;

DO $$ BEGIN
  BEGIN
    PERFORM public.schedule_manual_booking_reminder(
      'cccccccc-cccc-cccc-cccc-cccccccccccc'::uuid);
    RAISE EXCEPTION 'FAIL: guest booking should have raised';
  EXCEPTION WHEN raise_exception THEN
    RAISE NOTICE 'OK: guest-booking guard';
  END;
END $$;

ROLLBACK TO SAVEPOINT c_guest;

-- ─── D. Bulk reminders (authz + count + null date) ────────────────
SAVEPOINT d_bulk;

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';

-- 3 confirmed future bookings; 1 is a guest (must be excluded).
INSERT INTO bookings (id, user_id, shop_id, slot_id, booking_date,
                      start_time, end_time, total_amount, status)
SELECT v.id::uuid, v.user_id::uuid, :shop_a, ap.id, current_date,
       now() + (v.h || ' hours')::interval,
       now() + ((v.h::int + 1) || ' hours')::interval, 100, 'confirmed'
FROM (VALUES
  ('dddddddd-dddd-dddd-dddd-ddddddddddd1', '00000000-0000-0000-0000-000000000020', '1'),
  ('dddddddd-dddd-dddd-dddd-ddddddddddd2', '00000000-0000-0000-0000-000000000020', '2'),
  ('dddddddd-dddd-dddd-dddd-ddddddddddd3',  NULL,                                  '3')
) AS v(id, user_id, h)
JOIN LATERAL (SELECT id FROM appointment_slots WHERE shop_id = :shop_a LIMIT 1) ap ON true;

SELECT
  CASE
    WHEN public.schedule_bulk_manual_booking_reminders(:shop_a, current_date) = 2
    THEN 'OK: bulk count excludes guest'
    ELSE 'FAIL: expected 2'
  END;

-- Non-owner
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000002"}';
DO $$ BEGIN
  BEGIN
    PERFORM public.schedule_bulk_manual_booking_reminders(
      '00000000-0000-0000-0000-000000000010'::uuid, current_date);
    RAISE EXCEPTION 'FAIL: bulk non-owner should have raised';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'OK: bulk authz';
  END;
END $$;

-- Null date
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
DO $$ BEGIN
  BEGIN
    PERFORM public.schedule_bulk_manual_booking_reminders(
      '00000000-0000-0000-0000-000000000010'::uuid, NULL);
    RAISE EXCEPTION 'FAIL: null date should have raised';
  EXCEPTION WHEN data_exception THEN
    RAISE NOTICE 'OK: bulk null-date validation';
  END;
END $$;

ROLLBACK TO SAVEPOINT d_bulk;

-- ─── E. redeem_promotion idempotency ──────────────────────────────
SAVEPOINT e_idemp;

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';

INSERT INTO promotions (id, shop_id, name, code, discount_type,
                        discount_value, valid_from, valid_to, usage_limit)
VALUES ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', :shop_a,
        'Test', 'TEST10', 'percentage', 10,
        current_date, current_date + 30, NULL);

INSERT INTO bookings (id, user_id, shop_id, slot_id, booking_date,
                      start_time, end_time, total_amount, status)
SELECT 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeee01', :test_user,
       :shop_a, ap.id, current_date,
       now() + interval '6 hours', now() + interval '7 hours', 100, 'confirmed'
FROM appointment_slots ap WHERE ap.shop_id = :shop_a LIMIT 1;

WITH first  AS (SELECT public.redeem_promotion(
                  'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'::uuid,
                  'eeeeeeee-eeee-eeee-eeee-eeeeeeeeee01'::uuid,
                  :test_user, 10::numeric) AS id),
     second AS (SELECT public.redeem_promotion(
                  'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'::uuid,
                  'eeeeeeee-eeee-eeee-eeee-eeeeeeeeee01'::uuid,
                  :test_user, 10::numeric) AS id)
SELECT
  CASE WHEN first.id = second.id THEN 'OK: redeem idempotent' ELSE 'FAIL: ids differ' END
FROM first, second;

SELECT
  CASE WHEN usage_count = 1 THEN 'OK: counter bumped exactly once'
       ELSE 'FAIL: usage_count != 1' END
FROM promotions WHERE id = 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';

ROLLBACK TO SAVEPOINT e_idemp;

-- ─── F. redeem_promotion limit_reached ────────────────────────────
SAVEPOINT f_limit;

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
INSERT INTO promotions (id, shop_id, name, code, discount_type,
                        discount_value, valid_from, valid_to, usage_limit, usage_count)
VALUES ('ffffffff-ffff-ffff-ffff-ffffffffffff', :shop_a,
        'Capped', 'CAP1', 'fixed', 5,
        current_date, current_date + 30, 1, 1);

INSERT INTO bookings (id, user_id, shop_id, slot_id, booking_date,
                      start_time, end_time, total_amount, status)
SELECT 'ffffffff-ffff-ffff-ffff-ffffffffff01', :test_user,
       :shop_a, ap.id, current_date,
       now() + interval '8 hours', now() + interval '9 hours', 100, 'confirmed'
FROM appointment_slots ap WHERE ap.shop_id = :shop_a LIMIT 1;

DO $$ BEGIN
  BEGIN
    PERFORM public.redeem_promotion(
      'ffffffff-ffff-ffff-ffff-ffffffffffff'::uuid,
      'ffffffff-ffff-ffff-ffff-ffffffffff01'::uuid,
      '00000000-0000-0000-0000-000000000020'::uuid, 5::numeric);
    RAISE EXCEPTION 'FAIL: limit-reached should have raised';
  EXCEPTION WHEN raise_exception THEN
    RAISE NOTICE 'OK: limit_reached raised';
  END;
END $$;

ROLLBACK TO SAVEPOINT f_limit;

-- ─── G. redeem_promotion invalid_amount ───────────────────────────
SAVEPOINT g_amount;

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
INSERT INTO promotions (id, shop_id, name, code, discount_type,
                        discount_value, valid_from, valid_to)
VALUES ('99999999-9999-9999-9999-999999999999', :shop_a,
        'AmountTest', 'AMT', 'fixed', 1,
        current_date, current_date + 30);

INSERT INTO bookings (id, user_id, shop_id, slot_id, booking_date,
                      start_time, end_time, total_amount, status)
SELECT '99999999-9999-9999-9999-9999999999a1', :test_user,
       :shop_a, ap.id, current_date,
       now() + interval '10 hours', now() + interval '11 hours', 100, 'confirmed'
FROM appointment_slots ap WHERE ap.shop_id = :shop_a LIMIT 1;

DO $$ BEGIN
  BEGIN
    PERFORM public.redeem_promotion(
      '99999999-9999-9999-9999-999999999999'::uuid,
      '99999999-9999-9999-9999-9999999999a1'::uuid,
      '00000000-0000-0000-0000-000000000020'::uuid, 0::numeric);
    RAISE EXCEPTION 'FAIL: zero amount should have raised';
  EXCEPTION WHEN data_exception THEN
    RAISE NOTICE 'OK: invalid_amount raised';
  END;
END $$;

ROLLBACK TO SAVEPOINT g_amount;

-- ─── H. redeem_promotion authz ────────────────────────────────────
SAVEPOINT h_authz;

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
INSERT INTO promotions (id, shop_id, name, code, discount_type,
                        discount_value, valid_from, valid_to)
VALUES ('88888888-8888-8888-8888-888888888888', :shop_a,
        'AuthzTest', 'AZ', 'fixed', 1,
        current_date, current_date + 30);

INSERT INTO bookings (id, user_id, shop_id, slot_id, booking_date,
                      start_time, end_time, total_amount, status)
SELECT '88888888-8888-8888-8888-8888888888a1', :test_user,
       :shop_a, ap.id, current_date,
       now() + interval '12 hours', now() + interval '13 hours', 100, 'confirmed'
FROM appointment_slots ap WHERE ap.shop_id = :shop_a LIMIT 1;

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000002"}';
DO $$ BEGIN
  BEGIN
    PERFORM public.redeem_promotion(
      '88888888-8888-8888-8888-888888888888'::uuid,
      '88888888-8888-8888-8888-8888888888a1'::uuid,
      '00000000-0000-0000-0000-000000000020'::uuid, 1::numeric);
    RAISE EXCEPTION 'FAIL: non-owner should have raised 42501';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'OK: redeem authz';
  END;
END $$;

ROLLBACK TO SAVEPOINT h_authz;

ROLLBACK;
