-- Phase 11 — manual SQL smoke tests.
--
-- Hand-runnable against a staging branch DB. pgTAP is intentionally
-- deferred to a future testing-foundation phase. Replace the
-- placeholders at the top with real values before running.
--
-- Wrapped in BEGIN/ROLLBACK with SAVEPOINTs per section so every test
-- rolls back automatically. Each section ends with
-- `RAISE NOTICE 'OK: <case>';` on success — anywhere a different
-- result appears, the test failed.

BEGIN;

-- ─── placeholders ──────────────────────────────────────────────────
\set owner_uid '''00000000-0000-0000-0000-000000000001'''
\set other_uid '''00000000-0000-0000-0000-000000000002'''
\set shop_a    '''00000000-0000-0000-0000-000000000010'''
\set slot_a    '''00000000-0000-0000-0000-000000000030'''
\set test_user '''00000000-0000-0000-0000-000000000020'''

-- ─── A. rebuild_shop_opening_hours authz ──────────────────────────
SAVEPOINT a_authz;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000002"}';
DO $$ BEGIN
  BEGIN
    PERFORM public.rebuild_shop_opening_hours(
      '00000000-0000-0000-0000-000000000010'::uuid,
      '[]'::jsonb
    );
    RAISE EXCEPTION 'FAIL: non-owner should have raised 42501';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'OK: rebuild_shop_opening_hours authz';
  END;
END $$;
ROLLBACK TO SAVEPOINT a_authz;

-- ─── B. rebuild_shop_opening_hours shape (null) ──────────────────
SAVEPOINT b_shape;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
DO $$ BEGIN
  BEGIN
    PERFORM public.rebuild_shop_opening_hours(
      '00000000-0000-0000-0000-000000000010'::uuid,
      NULL
    );
    RAISE EXCEPTION 'FAIL: null payload should have raised';
  EXCEPTION WHEN data_exception THEN
    RAISE NOTICE 'OK: rebuild_shop_opening_hours shape (null)';
  END;
END $$;
ROLLBACK TO SAVEPOINT b_shape;

-- ─── C. rebuild_shop_opening_hours count (5 elements) ────────────
SAVEPOINT c_count;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
DO $$ BEGIN
  BEGIN
    PERFORM public.rebuild_shop_opening_hours(
      '00000000-0000-0000-0000-000000000010'::uuid,
      jsonb_build_array(
        jsonb_build_object('day_of_week',1,'opens_at','09:00 AM','closes_at','05:00 PM','is_closed',false),
        jsonb_build_object('day_of_week',2,'opens_at','09:00 AM','closes_at','05:00 PM','is_closed',false),
        jsonb_build_object('day_of_week',3,'opens_at','09:00 AM','closes_at','05:00 PM','is_closed',false),
        jsonb_build_object('day_of_week',4,'opens_at','09:00 AM','closes_at','05:00 PM','is_closed',false),
        jsonb_build_object('day_of_week',5,'opens_at','09:00 AM','closes_at','05:00 PM','is_closed',false)
      )
    );
    RAISE EXCEPTION 'FAIL: 5-element array should have raised';
  EXCEPTION WHEN data_exception THEN
    RAISE NOTICE 'OK: rebuild_shop_opening_hours count';
  END;
END $$;
ROLLBACK TO SAVEPOINT c_count;

-- ─── D. rebuild_shop_opening_hours dow range ─────────────────────
SAVEPOINT d_dow;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
DO $$ BEGIN
  BEGIN
    PERFORM public.rebuild_shop_opening_hours(
      '00000000-0000-0000-0000-000000000010'::uuid,
      jsonb_build_array(
        jsonb_build_object('day_of_week',9,'opens_at','09:00 AM','closes_at','05:00 PM','is_closed',false),
        jsonb_build_object('day_of_week',2,'opens_at','09:00 AM','closes_at','05:00 PM','is_closed',false),
        jsonb_build_object('day_of_week',3,'opens_at','09:00 AM','closes_at','05:00 PM','is_closed',false),
        jsonb_build_object('day_of_week',4,'opens_at','09:00 AM','closes_at','05:00 PM','is_closed',false),
        jsonb_build_object('day_of_week',5,'opens_at','09:00 AM','closes_at','05:00 PM','is_closed',false),
        jsonb_build_object('day_of_week',6,'opens_at','09:00 AM','closes_at','05:00 PM','is_closed',false),
        jsonb_build_object('day_of_week',7,'opens_at','09:00 AM','closes_at','05:00 PM','is_closed',true)
      )
    );
    RAISE EXCEPTION 'FAIL: day_of_week=9 should have raised';
  EXCEPTION WHEN data_exception THEN
    RAISE NOTICE 'OK: rebuild_shop_opening_hours dow range';
  END;
END $$;
ROLLBACK TO SAVEPOINT d_dow;

-- ─── E. rebuild_shop_opening_hours happy path ────────────────────
SAVEPOINT e_happy;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SELECT public.rebuild_shop_opening_hours(
  '00000000-0000-0000-0000-000000000010'::uuid,
  jsonb_build_array(
    jsonb_build_object('day_of_week',1,'opens_at','09:00 AM','closes_at','05:00 PM','is_closed',false),
    jsonb_build_object('day_of_week',2,'opens_at','09:00 AM','closes_at','05:00 PM','is_closed',false),
    jsonb_build_object('day_of_week',3,'opens_at','09:00 AM','closes_at','05:00 PM','is_closed',false),
    jsonb_build_object('day_of_week',4,'opens_at','09:00 AM','closes_at','05:00 PM','is_closed',false),
    jsonb_build_object('day_of_week',5,'opens_at','09:00 AM','closes_at','05:00 PM','is_closed',false),
    jsonb_build_object('day_of_week',6,'opens_at','09:00 AM','closes_at','05:00 PM','is_closed',false),
    jsonb_build_object('day_of_week',7,'opens_at','09:00 AM','closes_at','05:00 PM','is_closed',true)
  )
);
-- Expect 7 rows for this shop now, opens_at value is still text "09:00 AM".
SELECT
  CASE WHEN COUNT(*) = 7 AND BOOL_AND(opens_at = '09:00 AM' OR is_closed)
       THEN 'OK: rebuild_shop_opening_hours happy path'
       ELSE 'FAIL: row count or TEXT round-trip'
  END
FROM public.shop_opening_hours
WHERE shop_id = '00000000-0000-0000-0000-000000000010';
ROLLBACK TO SAVEPOINT e_happy;

-- ─── F. archive_appointment_slot authz ────────────────────────────
SAVEPOINT f_archive_authz;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000002"}';
DO $$ BEGIN
  BEGIN
    PERFORM public.archive_appointment_slot(
      '00000000-0000-0000-0000-000000000030'::uuid
    );
    RAISE EXCEPTION 'FAIL: non-owner should have raised 42501';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'OK: archive_appointment_slot authz';
  END;
END $$;
ROLLBACK TO SAVEPOINT f_archive_authz;

-- ─── G. archive_appointment_slot happy path ──────────────────────
SAVEPOINT g_archive;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SELECT public.archive_appointment_slot(
  '00000000-0000-0000-0000-000000000030'::uuid
);
SELECT
  CASE WHEN archived_at IS NOT NULL
       THEN 'OK: archive_appointment_slot happy path'
       ELSE 'FAIL: archived_at still NULL'
  END
FROM public.appointment_slots
WHERE id = '00000000-0000-0000-0000-000000000030';
ROLLBACK TO SAVEPOINT g_archive;

-- ─── H. archive_appointment_slot idempotent ───────────────────────
SAVEPOINT h_idem;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SELECT public.archive_appointment_slot(
  '00000000-0000-0000-0000-000000000030'::uuid
);
-- Capture the timestamp.
SELECT archived_at AS ts1
INTO TEMP TABLE _archived_ts
FROM public.appointment_slots
WHERE id = '00000000-0000-0000-0000-000000000030';

-- Second call: no-op.
SELECT public.archive_appointment_slot(
  '00000000-0000-0000-0000-000000000030'::uuid
);

SELECT
  CASE WHEN (SELECT ts1 FROM _archived_ts) =
            (SELECT archived_at FROM public.appointment_slots
             WHERE id = '00000000-0000-0000-0000-000000000030')
       THEN 'OK: archive_appointment_slot idempotent'
       ELSE 'FAIL: archived_at changed on second call'
  END;
DROP TABLE _archived_ts;
ROLLBACK TO SAVEPOINT h_idem;

-- ─── I. check_slot_availability filter ────────────────────────────
SAVEPOINT i_check_avail;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SELECT public.archive_appointment_slot(
  '00000000-0000-0000-0000-000000000030'::uuid
);
SELECT
  CASE WHEN result->>'available' = 'false'
        AND result->>'reason' = 'archived'
       THEN 'OK: check_slot_availability archived'
       ELSE 'FAIL: unexpected: ' || result::text
  END
FROM (
  SELECT public.check_slot_availability(
    '00000000-0000-0000-0000-000000000010'::uuid,
    '00000000-0000-0000-0000-000000000030'::uuid,
    NULL,
    now() + interval '2 hours',
    now() + interval '3 hours'
  ) AS result
) x;
ROLLBACK TO SAVEPOINT i_check_avail;

-- ─── J. create_booking_with_conflict_check filter ─────────────────
SAVEPOINT j_create;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SELECT public.archive_appointment_slot(
  '00000000-0000-0000-0000-000000000030'::uuid
);
DO $$ BEGIN
  BEGIN
    PERFORM public.create_booking_with_conflict_check(
      '00000000-0000-0000-0000-000000000001'::uuid,
      '00000000-0000-0000-0000-000000000010'::uuid,
      '00000000-0000-0000-0000-000000000030'::uuid,
      NULL,
      current_date,
      now() + interval '2 hours',
      now() + interval '3 hours',
      100, 0, NULL, NULL, NULL
    );
    RAISE EXCEPTION 'FAIL: archived slot should have raised';
  EXCEPTION WHEN raise_exception THEN
    RAISE NOTICE 'OK: create_booking_with_conflict_check filter';
  END;
END $$;
ROLLBACK TO SAVEPOINT j_create;

-- ─── K. generate_available_slots LIVE filter ─────────────────────
-- Picker UX assertion: archived slots are silently skipped from the
-- SETOF result.
SAVEPOINT k_gen;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SELECT public.archive_appointment_slot(
  '00000000-0000-0000-0000-000000000030'::uuid
);
SELECT
  CASE WHEN COUNT(*) = 0
       THEN 'OK: generate_available_slots filter (archived absent)'
       ELSE 'FAIL: archived slot still in SETOF (' || COUNT(*) || ' rows)'
  END
FROM public.generate_available_slots(
  '00000000-0000-0000-0000-000000000010'::uuid,
  (current_date + interval '7 days')::date,
  ARRAY['00000000-0000-0000-0000-000000000030'::uuid],
  ARRAY[1]
);
ROLLBACK TO SAVEPOINT k_gen;

ROLLBACK;

-- ─── L. resolve-link archive filter ──────────────────────────────
-- Run as a curl command (NOT psql) after staging deploy:
--
--   curl -s "https://<project>.supabase.co/functions/v1/resolve-link?slug=<test-shop-slug>" \
--     | jq '.services | map(.id)'
--
-- Expected: an archived slot's id is absent from the returned array.
-- Re-run after a manual UNDO of the archive to confirm it reappears.
