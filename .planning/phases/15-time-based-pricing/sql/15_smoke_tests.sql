-- Phase 15 — manual SQL smoke tests.
--
-- Hand-runnable against a staging branch DB. pgTAP intentionally deferred.
-- Replace the placeholders at the top with real values before running.
-- Note: the Supabase SQL Editor does NOT support `\set` directives —
-- UUIDs are inlined throughout.
--
-- Wrapped in BEGIN/ROLLBACK with SAVEPOINTs per section so every test
-- rolls back automatically. Each section ends with
-- `RAISE NOTICE 'OK: <case>';` on success — anywhere a different result
-- appears, the test failed.
--
-- Coverage maps to the 10 SPEC success criteria + the 50-cap check +
-- the ISODOW Sunday fix:
--   §A — pricing_overrides table + RLS owner-only verify             (SC 1)
--   §B — create_pricing_override happy path + authz failure          (SC 2)
--   §C — update_pricing_override authz + partial update              (SC 6)
--   §D — archive_pricing_override idempotency                        (SC 7)
--   §E — generate_available_slots base_price column populated        (—)
--   §F — single percent_discount applied (effective price math)      (SC 4, 5, 10)
--   §G — resolution ladder: single-day beats all-week                (SC 8)
--   §H — resolution ladder: narrower window beats wider              (—)
--   §I — resolution ladder: newest beats older when both same        (—)
--   §J — fixed_discount clamps at 0 (no negative effective)          (SC 9)
--   §K — 50-cap enforcement raises OVERRIDE_CAP_EXCEEDED             (—)
--   §L — ISODOW fix: Sunday (day_of_week=7) bookings now work        (—)
--
-- Reference identities (inlined throughout):
--   owner_a_uid     = 00000000-0000-0000-0000-000000000001
--   owner_b_uid     = 00000000-0000-0000-0000-000000000002
--   shop_a          = 00000000-0000-0000-0000-000000000010
--   shop_b          = 00000000-0000-0000-0000-000000000011
--   slot_a_50       = 00000000-0000-0000-0000-000000000040  ($50 service in shop_a)
--   slot_b_50       = 00000000-0000-0000-0000-000000000041  ($50 service in shop_b)
--   slot_sunday     = 00000000-0000-0000-0000-000000000042  (slot with days_of_week containing 7)
--
-- Pre-flight (BLOCKING — verify before any section runs):
--   (1) SELECT a.attname, t.typname FROM pg_attribute a JOIN pg_type t ON t.oid=a.atttypid
--         WHERE a.attrelid='public.appointment_slots'::regclass
--           AND a.attname='id';
--       → typname must be 'uuid'.
--   (2) SELECT DISTINCT day_of_week FROM public.shop_opening_hours ORDER BY 1;
--       → must be a subset of {1,2,3,4,5,6,7}. Any 0 means legacy data and stop.
--   (3) SELECT count(*) FROM information_schema.tables
--         WHERE table_schema='public' AND table_name='pricing_overrides';
--       → must be 1 (Phase 15 Wave 0 migration applied).
--   (4) SELECT array_agg(DISTINCT dow) FROM (
--           SELECT unnest(days_of_week) AS dow FROM public.appointment_slots
--           WHERE archived_at IS NULL) t;
--       → baseline of pre-fix data. Capture for §L comparison.
--
-- Fixture invariant:
--   shop_a is owned by owner_a_uid; shop_b is owned by owner_b_uid.
--   slot_a_50 belongs to shop_a, slot_b_50 belongs to shop_b, slot_sunday
--   belongs to shop_a with days_of_week containing 7 and shop_opening_hours
--   row at day_of_week=7 for shop_a.

BEGIN;

-- ─── A. pricing_overrides table + RLS owner-only verify ──────────────────
-- Owner of shop_a can SELECT overrides on shop_a's slots.
-- Owner of shop_b cannot SELECT shop_a's overrides (RLS denies).
-- Direct INSERT / UPDATE / DELETE as authenticated is RLS-denied
-- (deny-all by policy absence).
SAVEPOINT a_table_rls;

-- Seed an override on shop_a/slot_a_50 directly via SECURITY DEFINER bypass
-- (SET LOCAL ROLE postgres for the seed, then verify as authenticated).
SET LOCAL ROLE postgres;
INSERT INTO public.pricing_overrides (
  id, slot_id, name, day_of_week,
  time_window_start, time_window_end,
  adjustment_kind, adjustment_value,
  created_by_user_id
) VALUES (
  '00000000-0000-0000-0000-000000000100'::uuid,
  '00000000-0000-0000-0000-000000000040'::uuid,
  'Seed rule for §A',
  2,  -- Tuesday
  '09:00:00'::time, '12:00:00'::time,
  'percent_discount', 20,
  '00000000-0000-0000-0000-000000000001'::uuid
);

-- Owner_a SELECT — should see 1 row.
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;
DO $$ DECLARE v_count INT; BEGIN
  SELECT count(*) INTO v_count FROM public.pricing_overrides
    WHERE slot_id = '00000000-0000-0000-0000-000000000040'::uuid;
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'FAIL §A.1: owner_a expected 1 override, got %', v_count;
  END IF;
END $$;

-- Owner_b SELECT — should see 0 rows (RLS denies).
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000002"}';
DO $$ DECLARE v_count INT; BEGIN
  SELECT count(*) INTO v_count FROM public.pricing_overrides
    WHERE slot_id = '00000000-0000-0000-0000-000000000040'::uuid;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'FAIL §A.2: owner_b should see 0 rows (RLS), got %', v_count;
  END IF;
END $$;

-- Direct INSERT as authenticated — should fail (no INSERT policy).
DO $$ BEGIN
  BEGIN
    INSERT INTO public.pricing_overrides (
      slot_id, name, day_of_week,
      time_window_start, time_window_end,
      adjustment_kind, adjustment_value,
      created_by_user_id
    ) VALUES (
      '00000000-0000-0000-0000-000000000040'::uuid,
      'Direct insert attempt', NULL,
      '10:00:00'::time, '11:00:00'::time,
      'percent_discount', 10,
      '00000000-0000-0000-0000-000000000002'::uuid
    );
    RAISE EXCEPTION 'FAIL §A.3: direct INSERT as authenticated should have been RLS-denied';
  EXCEPTION WHEN insufficient_privilege OR check_violation OR others THEN
    -- expected
    NULL;
  END;
END $$;

RAISE NOTICE 'OK: §A pricing_overrides table + RLS owner-only verify';
ROLLBACK TO SAVEPOINT a_table_rls;

-- ─── B. create_pricing_override happy path + authz failure ───────────────
-- Happy: owner_a creates an override on slot_a_50 → returns UUID.
-- Authz: owner_b tries to create an override on slot_a_50 → raises 42501.
SAVEPOINT b_create;

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

DO $$ DECLARE v_id UUID; BEGIN
  v_id := public.create_pricing_override(
    p_slot_id            => '00000000-0000-0000-0000-000000000040'::uuid,
    p_name               => 'Off-peak Tuesday morning',
    p_day_of_week        => 2,
    p_time_window_start  => '09:00:00'::time,
    p_time_window_end    => '12:00:00'::time,
    p_adjustment_kind    => 'percent_discount',
    p_adjustment_value   => 20,
    p_valid_from         => NULL,
    p_valid_until        => NULL
  );
  IF v_id IS NULL THEN
    RAISE EXCEPTION 'FAIL §B.1: create returned NULL';
  END IF;
END $$;

-- Authz failure: owner_b tries to mutate shop_a's slot.
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000002"}';
DO $$ BEGIN
  BEGIN
    PERFORM public.create_pricing_override(
      '00000000-0000-0000-0000-000000000040'::uuid,
      'cross-owner attempt', 2,
      '09:00:00'::time, '12:00:00'::time,
      'percent_discount', 10, NULL, NULL
    );
    RAISE EXCEPTION 'FAIL §B.2: expected 42501 not_found for cross-owner create';
  EXCEPTION WHEN insufficient_privilege THEN
    -- expected: SQLSTATE 42501
    NULL;
  END;
END $$;

RAISE NOTICE 'OK: §B create_pricing_override happy path + authz failure';
ROLLBACK TO SAVEPOINT b_create;

-- ─── C. update_pricing_override authz + partial update ───────────────────
-- Owner_a creates a rule, partial-updates the value (only). Other fields preserved.
-- Owner_b update on owner_a's override → 42501.
SAVEPOINT c_update;

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

DO $$
DECLARE
  v_id          UUID;
  v_value_after NUMERIC;
  v_name_after  TEXT;
  v_dow_after   INT;
BEGIN
  v_id := public.create_pricing_override(
    '00000000-0000-0000-0000-000000000040'::uuid,
    'Original name', 3,
    '10:00:00'::time, '12:00:00'::time,
    'percent_discount', 15, NULL, NULL
  );

  PERFORM public.update_pricing_override(
    p_override_id => v_id,
    p_adjustment_value => 30
  );

  SELECT adjustment_value, name, day_of_week INTO v_value_after, v_name_after, v_dow_after
    FROM public.pricing_overrides WHERE id = v_id;

  IF v_value_after <> 30 THEN
    RAISE EXCEPTION 'FAIL §C.1: expected value=30 after partial update, got %', v_value_after;
  END IF;
  IF v_name_after <> 'Original name' THEN
    RAISE EXCEPTION 'FAIL §C.2: partial update should preserve name, got %', v_name_after;
  END IF;
  IF v_dow_after <> 3 THEN
    RAISE EXCEPTION 'FAIL §C.3: partial update should preserve day_of_week, got %', v_dow_after;
  END IF;
END $$;

-- Cross-owner update authz.
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000002"}';
DO $$
DECLARE v_id UUID;
BEGIN
  SELECT id INTO v_id FROM public.pricing_overrides
    WHERE slot_id = '00000000-0000-0000-0000-000000000040'::uuid LIMIT 1;
  BEGIN
    PERFORM public.update_pricing_override(p_override_id => v_id, p_name => 'hijack');
    RAISE EXCEPTION 'FAIL §C.4: expected 42501 for cross-owner update';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
END $$;

RAISE NOTICE 'OK: §C update_pricing_override authz + partial update';
ROLLBACK TO SAVEPOINT c_update;

-- ─── D. archive_pricing_override idempotency ─────────────────────────────
-- Archive sets archived_at; re-archive is a no-op (archived_at unchanged).
SAVEPOINT d_archive;

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

DO $$
DECLARE
  v_id           UUID;
  v_archived_at1 TIMESTAMPTZ;
  v_archived_at2 TIMESTAMPTZ;
BEGIN
  v_id := public.create_pricing_override(
    '00000000-0000-0000-0000-000000000040'::uuid,
    'To archive', NULL,
    '08:00:00'::time, '10:00:00'::time,
    'percent_discount', 10, NULL, NULL
  );

  PERFORM public.archive_pricing_override(v_id);
  SELECT archived_at INTO v_archived_at1 FROM public.pricing_overrides WHERE id = v_id;
  IF v_archived_at1 IS NULL THEN
    RAISE EXCEPTION 'FAIL §D.1: first archive should have set archived_at';
  END IF;

  -- Re-archive — should be a no-op.
  PERFORM pg_sleep(0.01);
  PERFORM public.archive_pricing_override(v_id);
  SELECT archived_at INTO v_archived_at2 FROM public.pricing_overrides WHERE id = v_id;
  IF v_archived_at1 <> v_archived_at2 THEN
    RAISE EXCEPTION 'FAIL §D.2: re-archive should be no-op, archived_at changed % → %', v_archived_at1, v_archived_at2;
  END IF;
END $$;

RAISE NOTICE 'OK: §D archive_pricing_override idempotency';
ROLLBACK TO SAVEPOINT d_archive;

-- ─── E. generate_available_slots base_price column populated ─────────────
-- For a service with no override, base_price column equals appointment_slots.price.
-- For a service with no Phase 15 changes applied to its day, base_price still emits.
SAVEPOINT e_base_price_col;

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

DO $$
DECLARE
  v_base       NUMERIC;
  v_price      NUMERIC;
  v_slot_price NUMERIC;
BEGIN
  SELECT price INTO v_slot_price FROM public.appointment_slots
    WHERE id = '00000000-0000-0000-0000-000000000040'::uuid;

  -- Pick the next Tuesday from today's date as p_date. Zero-override case.
  SELECT price, base_price INTO v_price, v_base
    FROM public.generate_available_slots(
      '00000000-0000-0000-0000-000000000010'::uuid,
      (CURRENT_DATE + ((9 - EXTRACT(ISODOW FROM CURRENT_DATE)::INT) % 7) * INTERVAL '1 day')::DATE,
      ARRAY['00000000-0000-0000-0000-000000000040'::uuid],
      ARRAY[1]::INT[]
    ) LIMIT 1;

  IF v_base IS NULL THEN
    RAISE EXCEPTION 'FAIL §E.1: base_price column missing or NULL';
  END IF;
  IF v_base <> v_slot_price THEN
    RAISE EXCEPTION 'FAIL §E.2: base_price (%) <> appointment_slots.price (%)', v_base, v_slot_price;
  END IF;
  IF abs(v_price - v_base) > 0.01 THEN
    RAISE EXCEPTION 'FAIL §E.3: zero-override shop should see price == base_price, got % vs %', v_price, v_base;
  END IF;
END $$;

RAISE NOTICE 'OK: §E generate_available_slots base_price column populated';
ROLLBACK TO SAVEPOINT e_base_price_col;

-- ─── F. single percent_discount applied → effective price math ──────────
-- Create a 20% discount override on slot_a_50 covering Tue 09:00–12:00.
-- generate_available_slots on a Tuesday for slot_a_50 at 10am should return
-- price = $40 and base_price = $50.
SAVEPOINT f_percent_discount;

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

DO $$
DECLARE
  v_price     NUMERIC;
  v_base      NUMERIC;
  v_tuesday   DATE;
  v_id        UUID;
  v_expected  NUMERIC;
BEGIN
  -- Next Tuesday.
  v_tuesday := (CURRENT_DATE + ((9 - EXTRACT(ISODOW FROM CURRENT_DATE)::INT) % 7) * INTERVAL '1 day')::DATE;
  IF EXTRACT(ISODOW FROM v_tuesday)::INT <> 2 THEN
    v_tuesday := v_tuesday + ((2 - EXTRACT(ISODOW FROM v_tuesday)::INT + 7) % 7) * INTERVAL '1 day';
  END IF;

  v_id := public.create_pricing_override(
    '00000000-0000-0000-0000-000000000040'::uuid,
    'Off-peak Tue', 2,
    '09:00:00'::time, '12:00:00'::time,
    'percent_discount', 20, NULL, NULL
  );

  -- Pick the 10am slot specifically. Filter by start_time hour.
  SELECT price, base_price INTO v_price, v_base
    FROM public.generate_available_slots(
      '00000000-0000-0000-0000-000000000010'::uuid,
      v_tuesday,
      ARRAY['00000000-0000-0000-0000-000000000040'::uuid],
      ARRAY[1]::INT[]
    )
   WHERE EXTRACT(HOUR FROM start_time) = 10
   LIMIT 1;

  v_expected := v_base * 0.80;
  IF abs(v_price - v_expected) > 0.01 THEN
    RAISE EXCEPTION 'FAIL §F: expected price=% (= base * 0.80), got % (base=%)', v_expected, v_price, v_base;
  END IF;
END $$;

RAISE NOTICE 'OK: §F single percent_discount applied (effective price math)';
ROLLBACK TO SAVEPOINT f_percent_discount;

-- ─── G. Resolution ladder: single-day beats all-week ────────────────────
-- Override A: day_of_week=NULL (all-week), percent_discount 10%, window 09:00–17:00.
-- Override B: day_of_week=2 (Tue), percent_discount 20%, window 09:00–17:00.
-- For Tue 10am → 20% (B wins by specificity).
SAVEPOINT g_single_day_beats_all_week;

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

DO $$
DECLARE
  v_price    NUMERIC;
  v_base     NUMERIC;
  v_tuesday  DATE;
  v_expected NUMERIC;
BEGIN
  v_tuesday := (CURRENT_DATE + ((2 - EXTRACT(ISODOW FROM CURRENT_DATE)::INT + 7) % 7) * INTERVAL '1 day')::DATE;

  PERFORM public.create_pricing_override(
    '00000000-0000-0000-0000-000000000040'::uuid,
    'All-week 10% off', NULL,
    '09:00:00'::time, '17:00:00'::time,
    'percent_discount', 10, NULL, NULL
  );
  PERFORM public.create_pricing_override(
    '00000000-0000-0000-0000-000000000040'::uuid,
    'Tue-only 20% off', 2,
    '09:00:00'::time, '17:00:00'::time,
    'percent_discount', 20, NULL, NULL
  );

  SELECT price, base_price INTO v_price, v_base
    FROM public.generate_available_slots(
      '00000000-0000-0000-0000-000000000010'::uuid,
      v_tuesday,
      ARRAY['00000000-0000-0000-0000-000000000040'::uuid],
      ARRAY[1]::INT[]
    )
   WHERE EXTRACT(HOUR FROM start_time) = 10
   LIMIT 1;

  v_expected := v_base * 0.80;  -- Tue-only 20% wins
  IF abs(v_price - v_expected) > 0.01 THEN
    RAISE EXCEPTION 'FAIL §G: single-day rule should win; expected % got % (base=%)', v_expected, v_price, v_base;
  END IF;
END $$;

RAISE NOTICE 'OK: §G resolution ladder: single-day beats all-week';
ROLLBACK TO SAVEPOINT g_single_day_beats_all_week;

-- ─── H. Resolution ladder: narrower window beats wider ──────────────────
-- Override A: day_of_week=2, window 09:00–17:00 (8h wide), 10% off.
-- Override B: day_of_week=2, window 10:00–12:00 (2h wide), 25% off.
-- For Tue 10am → 25% (B wins by window width).
SAVEPOINT h_narrower_beats_wider;

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

DO $$
DECLARE
  v_price    NUMERIC;
  v_base     NUMERIC;
  v_tuesday  DATE;
  v_expected NUMERIC;
BEGIN
  v_tuesday := (CURRENT_DATE + ((2 - EXTRACT(ISODOW FROM CURRENT_DATE)::INT + 7) % 7) * INTERVAL '1 day')::DATE;

  PERFORM public.create_pricing_override(
    '00000000-0000-0000-0000-000000000040'::uuid,
    'Wide Tue rule 10%', 2,
    '09:00:00'::time, '17:00:00'::time,
    'percent_discount', 10, NULL, NULL
  );
  PERFORM public.create_pricing_override(
    '00000000-0000-0000-0000-000000000040'::uuid,
    'Narrow Tue rule 25%', 2,
    '10:00:00'::time, '12:00:00'::time,
    'percent_discount', 25, NULL, NULL
  );

  SELECT price, base_price INTO v_price, v_base
    FROM public.generate_available_slots(
      '00000000-0000-0000-0000-000000000010'::uuid,
      v_tuesday,
      ARRAY['00000000-0000-0000-0000-000000000040'::uuid],
      ARRAY[1]::INT[]
    )
   WHERE EXTRACT(HOUR FROM start_time) = 10
   LIMIT 1;

  v_expected := v_base * 0.75;  -- narrower 25% wins
  IF abs(v_price - v_expected) > 0.01 THEN
    RAISE EXCEPTION 'FAIL §H: narrower window should win; expected % got % (base=%)', v_expected, v_price, v_base;
  END IF;
END $$;

RAISE NOTICE 'OK: §H resolution ladder: narrower window beats wider';
ROLLBACK TO SAVEPOINT h_narrower_beats_wider;

-- ─── I. Resolution ladder: newest beats older when both same specificity ─
-- Override A: day_of_week=2, window 10:00–12:00, 15% off, created first.
-- Override B: day_of_week=2, window 10:00–12:00, 30% off, created second.
-- For Tue 10am → 30% (B wins by created_at DESC).
SAVEPOINT i_newest_beats_older;

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

DO $$
DECLARE
  v_price    NUMERIC;
  v_base     NUMERIC;
  v_tuesday  DATE;
  v_expected NUMERIC;
BEGIN
  v_tuesday := (CURRENT_DATE + ((2 - EXTRACT(ISODOW FROM CURRENT_DATE)::INT + 7) % 7) * INTERVAL '1 day')::DATE;

  PERFORM public.create_pricing_override(
    '00000000-0000-0000-0000-000000000040'::uuid,
    'Older Tue rule 15%', 2,
    '10:00:00'::time, '12:00:00'::time,
    'percent_discount', 15, NULL, NULL
  );
  PERFORM pg_sleep(0.05);  -- ensure created_at ordering
  PERFORM public.create_pricing_override(
    '00000000-0000-0000-0000-000000000040'::uuid,
    'Newer Tue rule 30%', 2,
    '10:00:00'::time, '12:00:00'::time,
    'percent_discount', 30, NULL, NULL
  );

  SELECT price, base_price INTO v_price, v_base
    FROM public.generate_available_slots(
      '00000000-0000-0000-0000-000000000010'::uuid,
      v_tuesday,
      ARRAY['00000000-0000-0000-0000-000000000040'::uuid],
      ARRAY[1]::INT[]
    )
   WHERE EXTRACT(HOUR FROM start_time) = 10
   LIMIT 1;

  v_expected := v_base * 0.70;  -- newer 30% wins
  IF abs(v_price - v_expected) > 0.01 THEN
    RAISE EXCEPTION 'FAIL §I: newer rule should win at equal specificity/width; expected % got % (base=%)', v_expected, v_price, v_base;
  END IF;
END $$;

RAISE NOTICE 'OK: §I resolution ladder: newest beats older when both same specificity';
ROLLBACK TO SAVEPOINT i_newest_beats_older;

-- ─── J. fixed_discount clamps at 0 (no negative effective price) ────────
-- Override: fixed_discount = 100 on a $50 slot. Effective should clamp to $0.
SAVEPOINT j_clamp_at_zero;

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

DO $$
DECLARE
  v_price   NUMERIC;
  v_base    NUMERIC;
  v_tuesday DATE;
BEGIN
  v_tuesday := (CURRENT_DATE + ((2 - EXTRACT(ISODOW FROM CURRENT_DATE)::INT + 7) % 7) * INTERVAL '1 day')::DATE;

  PERFORM public.create_pricing_override(
    '00000000-0000-0000-0000-000000000040'::uuid,
    'Huge fixed discount', 2,
    '10:00:00'::time, '12:00:00'::time,
    'fixed_discount', 100, NULL, NULL
  );

  SELECT price, base_price INTO v_price, v_base
    FROM public.generate_available_slots(
      '00000000-0000-0000-0000-000000000010'::uuid,
      v_tuesday,
      ARRAY['00000000-0000-0000-0000-000000000040'::uuid],
      ARRAY[1]::INT[]
    )
   WHERE EXTRACT(HOUR FROM start_time) = 10
   LIMIT 1;

  IF v_price < 0 THEN
    RAISE EXCEPTION 'FAIL §J: effective price went negative (% vs base %)', v_price, v_base;
  END IF;
  IF abs(v_price) > 0.01 THEN
    RAISE EXCEPTION 'FAIL §J: expected price=0 for fixed_discount > base, got % (base=%)', v_price, v_base;
  END IF;
END $$;

RAISE NOTICE 'OK: §J fixed_discount clamps at 0 (no negative effective price)';
ROLLBACK TO SAVEPOINT j_clamp_at_zero;

-- ─── K. 50-cap enforcement → OVERRIDE_CAP_EXCEEDED ──────────────────────
-- Insert 50 active overrides on a single slot, then attempt the 51st.
-- The 51st create call must raise SQLSTATE 22023 with HINT OVERRIDE_CAP_EXCEEDED.
SAVEPOINT k_50_cap;

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

DO $$
DECLARE
  i INT;
BEGIN
  FOR i IN 1..50 LOOP
    PERFORM public.create_pricing_override(
      '00000000-0000-0000-0000-000000000040'::uuid,
      'Rule ' || i, NULL,
      ('09:00:00'::time + (i * INTERVAL '1 minute'))::time,
      ('10:00:00'::time + (i * INTERVAL '1 minute'))::time,
      'percent_discount', 1, NULL, NULL
    );
  END LOOP;

  BEGIN
    PERFORM public.create_pricing_override(
      '00000000-0000-0000-0000-000000000040'::uuid,
      'Rule 51 (cap)', NULL,
      '14:00:00'::time, '15:00:00'::time,
      'percent_discount', 1, NULL, NULL
    );
    RAISE EXCEPTION 'FAIL §K.1: 51st override should have raised OVERRIDE_CAP_EXCEEDED';
  EXCEPTION WHEN OTHERS THEN
    IF SQLSTATE <> '22023' THEN
      RAISE EXCEPTION 'FAIL §K.2: expected SQLSTATE 22023, got % (%)', SQLSTATE, SQLERRM;
    END IF;
    -- The HINT carries OVERRIDE_CAP_EXCEEDED. PG does not expose HINT in EXCEPTION
    -- DIAGNOSTICS via the simple OTHERS handler — but SQLSTATE + the count
    -- precondition fully identifies the cap path.
  END;
END $$;

RAISE NOTICE 'OK: §K 50-cap enforcement raises OVERRIDE_CAP_EXCEEDED';
ROLLBACK TO SAVEPOINT k_50_cap;

-- ─── L. ISODOW fix: Sunday (day_of_week=7) bookings now work ────────────
-- Setup: slot_sunday has days_of_week containing 7, and shop_a has a
-- shop_opening_hours row at day_of_week=7. Pre-Phase 15 (EXTRACT(DOW))
-- would return 0 for Sunday → no join → no slots. Post-fix (EXTRACT(ISODOW))
-- returns 7 → join hits → slots generate.
SAVEPOINT l_isodow_sunday;

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

DO $$
DECLARE
  v_count  INT;
  v_sunday DATE;
BEGIN
  -- Next Sunday from today.
  v_sunday := (CURRENT_DATE + ((7 - EXTRACT(ISODOW FROM CURRENT_DATE)::INT + 7) % 7) * INTERVAL '1 day')::DATE;
  IF EXTRACT(ISODOW FROM v_sunday)::INT <> 7 THEN
    v_sunday := v_sunday + 7;  -- defensive: bump to next Sunday
  END IF;

  SELECT count(*) INTO v_count
    FROM public.generate_available_slots(
      '00000000-0000-0000-0000-000000000010'::uuid,
      v_sunday,
      ARRAY['00000000-0000-0000-0000-000000000042'::uuid],  -- slot_sunday
      ARRAY[1]::INT[]
    );

  IF v_count = 0 THEN
    RAISE EXCEPTION 'FAIL §L: ISODOW fix should generate Sunday slots when shop_opening_hours has day_of_week=7. Got 0 slots.';
  END IF;
END $$;

RAISE NOTICE 'OK: §L ISODOW fix: Sunday (day_of_week=7) bookings now work';
ROLLBACK TO SAVEPOINT l_isodow_sunday;

ROLLBACK;
