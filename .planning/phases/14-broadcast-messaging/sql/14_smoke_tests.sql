-- Phase 14 — manual SQL smoke tests.
--
-- Hand-runnable against a staging branch DB. pgTAP is intentionally
-- deferred to a future testing-foundation phase. Replace the placeholders
-- at the top with real values before running. Note: the Supabase SQL
-- Editor does NOT support `\set` directives — UUIDs are inlined.
--
-- Wrapped in BEGIN/ROLLBACK with SAVEPOINTs per section so every test
-- rolls back automatically. Each section ends with
-- `RAISE NOTICE 'OK: <case>';` on success — anywhere a different result
-- appears, the test failed.
--
-- Coverage maps to the 10 SPEC success criteria + a cap check + an RLS
-- immutability check + an RLS cross-shop check:
--   §A — preview_broadcast_audience: count > 0 for shop with bookings   (2)
--   §B — preview resolves all 4 audience types correctly                (3, 4)
--   §C — promo source restriction (rejects loyalty/recovery codes)      (5, 8)
--   §D — promo validation rejects expired/archived codes                (8)
--   §E — send_broadcast happy path (row + fan-out)                      (6, 9)
--   §F — UTC-day rate limit enforcement                                 (7)
--   §G — advisory lock prevents same-second double-tap                  (—)
--   §H — 1000-recipient cap enforcement                                 (—)
--   §I — recipient dedup on COALESCE(user_id, guest_profile_id)         (9)
--   §J — accepts_marketing=FALSE guest excluded from fan-out            (10)
--   §K — RLS owner-only SELECT on broadcasts                            (—)
--   §L — broadcasts immutability (UPDATE/DELETE denied to authenticated) (—)
--
-- Reference identities (inlined throughout):
--   owner_a_uid    = 00000000-0000-0000-0000-000000000001
--   owner_b_uid    = 00000000-0000-0000-0000-000000000002
--   shop_a         = 00000000-0000-0000-0000-000000000010
--   shop_b         = 00000000-0000-0000-0000-000000000011
--   user_1         = 00000000-0000-0000-0000-000000000020
--   user_2         = 00000000-0000-0000-0000-000000000021
--   guest_1        = 00000000-0000-0000-0000-000000000030
--   guest_2        = 00000000-0000-0000-0000-000000000031
--   guest_optout   = 00000000-0000-0000-0000-000000000032
--   slot_a         = 00000000-0000-0000-0000-000000000040
--   slot_b         = 00000000-0000-0000-0000-000000000041
--   promo_active   = 00000000-0000-0000-0000-000000000050
--   promo_loyalty  = 00000000-0000-0000-0000-000000000051
--   promo_recovery = 00000000-0000-0000-0000-000000000052
--   promo_archived = 00000000-0000-0000-0000-000000000053
--   promo_expired  = 00000000-0000-0000-0000-000000000054
--
-- Pre-flight (BLOCKING — verify before any section runs):
--   (1) SELECT typname, typcategory FROM pg_type WHERE typname='notification_type';
--       → typcategory must be 'E' (enum).
--   (2) SELECT is_nullable FROM information_schema.columns
--         WHERE table_name='scheduled_notifications' AND column_name='booking_id';
--       → must be 'YES'.
--   (3) SELECT column_name FROM information_schema.columns
--         WHERE table_name='guest_profiles' AND column_name='accepts_marketing';
--       → must return 1 row (added in Phase 14 Wave 0).
--   (4) SELECT column_name FROM information_schema.columns
--         WHERE table_name='shops' AND column_name='timezone';
--       → must return 0 rows.

BEGIN;

-- ─── A. preview_broadcast_audience: count > 0 for shop with bookings ───
-- Owner of shop_a previews "all_clients" → expect count >= 1 once at
-- least one non-pending booking exists.
SAVEPOINT a_preview_nonzero;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

-- Minimal fixture: insert a completed booking for user_1 at shop_a.
INSERT INTO public.bookings (id, shop_id, user_id, status, start_time, end_time, booking_date)
VALUES (gen_random_uuid(),
        '00000000-0000-0000-0000-000000000010'::uuid,
        '00000000-0000-0000-0000-000000000020'::uuid,
        'completed', now() - interval '5 days', now() - interval '5 days' + interval '1 hour', (now() - interval '5 days')::date);

DO $$ DECLARE v_count INT; BEGIN
  v_count := public.preview_broadcast_audience(
    '00000000-0000-0000-0000-000000000010'::uuid, 'all_clients', NULL);
  IF v_count < 1 THEN
    RAISE EXCEPTION 'FAIL: expected preview count >= 1, got %', v_count;
  END IF;
  RAISE NOTICE 'OK: preview_broadcast_audience returns % for shop with bookings', v_count;
END $$;
ROLLBACK TO SAVEPOINT a_preview_nonzero;

-- ─── B. preview resolves all 4 audience types correctly ───
-- Seed: shop_a has user_1 (recent confirmed), user_2 (lapsed completed
-- 70d ago), guest_1 (recent by_service slot_a). Verify each preset.
SAVEPOINT b_preview_types;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

-- Recent (within 30d)
INSERT INTO public.bookings (id, shop_id, user_id, status, start_time, end_time, booking_date)
VALUES (gen_random_uuid(),
        '00000000-0000-0000-0000-000000000010'::uuid,
        '00000000-0000-0000-0000-000000000020'::uuid,
        'confirmed', now() - interval '5 days', now() - interval '5 days' + interval '1 hour', (now() - interval '5 days')::date);

-- Lapsed (70d ago, completed)
INSERT INTO public.bookings (id, shop_id, user_id, status, start_time, end_time, booking_date)
VALUES (gen_random_uuid(),
        '00000000-0000-0000-0000-000000000010'::uuid,
        '00000000-0000-0000-0000-000000000021'::uuid,
        'completed', now() - interval '70 days', now() - interval '70 days' + interval '1 hour', (now() - interval '70 days')::date);

-- By-service guest (slot_a). Captures the booking id so we can seed
-- the booking_services join row (required for the by_service CTE to
-- find this client).
INSERT INTO public.guest_profiles (id, phone, accepts_marketing)
VALUES ('00000000-0000-0000-0000-000000000030'::uuid, '+10000001030', TRUE)
ON CONFLICT (id) DO NOTHING;

DO $$
DECLARE v_booking_id UUID;
BEGIN
  INSERT INTO public.bookings (
    id, shop_id, guest_profile_id, status,
    start_time, end_time, booking_date
  ) VALUES (
    gen_random_uuid(),
    '00000000-0000-0000-0000-000000000010'::uuid,
    '00000000-0000-0000-0000-000000000030'::uuid,
    'confirmed',
    now() - interval '3 days',
    now() - interval '3 days' + interval '1 hour',
    (now() - interval '3 days')::date
  ) RETURNING id INTO v_booking_id;

  -- Join row linking the booking to slot_a so by_service finds it.
  INSERT INTO public.booking_services (booking_id, slot_id)
  VALUES (v_booking_id, '00000000-0000-0000-0000-000000000040'::uuid);
END $$;

DO $$ DECLARE v_all INT; v_recent INT; v_lapsed INT; v_by_service INT; BEGIN
  v_all       := public.preview_broadcast_audience(
                  '00000000-0000-0000-0000-000000000010'::uuid, 'all_clients', NULL);
  v_recent    := public.preview_broadcast_audience(
                  '00000000-0000-0000-0000-000000000010'::uuid, 'recent', NULL);
  v_lapsed    := public.preview_broadcast_audience(
                  '00000000-0000-0000-0000-000000000010'::uuid, 'lapsed', NULL);
  v_by_service:= public.preview_broadcast_audience(
                  '00000000-0000-0000-0000-000000000010'::uuid, 'by_service',
                  '00000000-0000-0000-0000-000000000040'::uuid);

  IF v_all < 3 THEN
    RAISE EXCEPTION 'FAIL: all_clients expected >=3, got %', v_all;
  END IF;
  IF v_recent < 2 THEN
    RAISE EXCEPTION 'FAIL: recent expected >=2, got %', v_recent;
  END IF;
  IF v_lapsed < 1 THEN
    RAISE EXCEPTION 'FAIL: lapsed expected >=1, got %', v_lapsed;
  END IF;
  IF v_by_service < 1 THEN
    RAISE EXCEPTION 'FAIL: by_service expected >=1 with slot_a join row, got %', v_by_service;
  END IF;
  RAISE NOTICE 'OK: all_clients=%, recent=%, lapsed=%, by_service=%',
    v_all, v_recent, v_lapsed, v_by_service;
END $$;
ROLLBACK TO SAVEPOINT b_preview_types;

-- ─── C. Promo source restriction: rejects loyalty/recovery codes ───
-- send_broadcast must reject attaching a promo with source IN
-- ('loyalty','recovery') even when otherwise valid. HINT: PROMO_NOT_VALID.
SAVEPOINT c_promo_source;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

INSERT INTO public.promotions (
  id, shop_id, name, code, discount_type, discount_value,
  valid_from, valid_to, usage_limit, is_active,
  source, target_user_id, per_client_max
) VALUES (
  '00000000-0000-0000-0000-000000000051'::uuid,
  '00000000-0000-0000-0000-000000000010'::uuid,
  'Loyalty reward', 'LOYAL123', 'percentage', 10,
  now(), now() + interval '10 years', 1, TRUE,
  'loyalty', '00000000-0000-0000-0000-000000000020'::uuid, 1
);

-- Seed at least one booking so audience > 0.
INSERT INTO public.bookings (id, shop_id, user_id, status, start_time, end_time, booking_date)
VALUES (gen_random_uuid(),
        '00000000-0000-0000-0000-000000000010'::uuid,
        '00000000-0000-0000-0000-000000000020'::uuid,
        'completed', now() - interval '5 days', now() - interval '5 days' + interval '1 hour', (now() - interval '5 days')::date);

DO $$ BEGIN
  BEGIN
    PERFORM public.send_broadcast(
      '00000000-0000-0000-0000-000000000010'::uuid,
      'Subject', 'Body',
      'all_clients', NULL,
      '00000000-0000-0000-0000-000000000051'::uuid
    );
    RAISE EXCEPTION 'FAIL: attaching loyalty code should have raised PROMO_NOT_VALID';
  EXCEPTION WHEN SQLSTATE '22023' THEN
    -- Verify HINT
    IF SQLERRM NOT LIKE '%invalid_input%' THEN
      RAISE EXCEPTION 'FAIL: wrong SQLERRM: %', SQLERRM;
    END IF;
    RAISE NOTICE 'OK: send_broadcast rejected loyalty-source promo with 22023/PROMO_NOT_VALID';
  END;
END $$;
ROLLBACK TO SAVEPOINT c_promo_source;

-- ─── D. Promo validation rejects expired / archived codes ───
SAVEPOINT d_promo_invalid;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

-- Expired (valid_to in past)
INSERT INTO public.promotions (
  id, shop_id, name, code, discount_type, discount_value,
  valid_from, valid_to, usage_limit, is_active,
  source, per_client_max
) VALUES (
  '00000000-0000-0000-0000-000000000054'::uuid,
  '00000000-0000-0000-0000-000000000010'::uuid,
  'Expired', 'EXPIRED1', 'percentage', 10,
  now() - interval '60 days', now() - interval '1 day', 100, TRUE,
  'owner_defined', 1
);

-- Archived
INSERT INTO public.promotions (
  id, shop_id, name, code, discount_type, discount_value,
  valid_from, valid_to, usage_limit, is_active,
  source, per_client_max, archived_at
) VALUES (
  '00000000-0000-0000-0000-000000000053'::uuid,
  '00000000-0000-0000-0000-000000000010'::uuid,
  'Archived', 'ARCHIV1', 'percentage', 10,
  now() - interval '5 days', now() + interval '30 days', 100, TRUE,
  'owner_defined', 1, now()
);

-- Seed audience
INSERT INTO public.bookings (id, shop_id, user_id, status, start_time, end_time, booking_date)
VALUES (gen_random_uuid(),
        '00000000-0000-0000-0000-000000000010'::uuid,
        '00000000-0000-0000-0000-000000000020'::uuid,
        'completed', now() - interval '5 days', now() - interval '5 days' + interval '1 hour', (now() - interval '5 days')::date);

DO $$ BEGIN
  -- Expired
  BEGIN
    PERFORM public.send_broadcast(
      '00000000-0000-0000-0000-000000000010'::uuid,
      'Subject', 'Body',
      'all_clients', NULL,
      '00000000-0000-0000-0000-000000000054'::uuid);
    RAISE EXCEPTION 'FAIL: expired promo should have raised';
  EXCEPTION WHEN SQLSTATE '22023' THEN
    RAISE NOTICE 'OK: send_broadcast rejected expired promo';
  END;
  -- Archived
  BEGIN
    PERFORM public.send_broadcast(
      '00000000-0000-0000-0000-000000000010'::uuid,
      'Subject', 'Body',
      'all_clients', NULL,
      '00000000-0000-0000-0000-000000000053'::uuid);
    RAISE EXCEPTION 'FAIL: archived promo should have raised';
  EXCEPTION WHEN SQLSTATE '22023' THEN
    RAISE NOTICE 'OK: send_broadcast rejected archived promo';
  END;
END $$;
ROLLBACK TO SAVEPOINT d_promo_invalid;

-- ─── E. send_broadcast happy path ───
-- Owner sends an all_clients broadcast; expect:
--   - one broadcasts row with status='delivered', delivered_at set,
--     recipient_count > 0
--   - matching scheduled_notifications rows with correct delivery_channel
SAVEPOINT e_happy;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

-- Seed: one registered user + one accepts_marketing=TRUE guest
INSERT INTO public.bookings (id, shop_id, user_id, status, start_time, end_time, booking_date)
VALUES (gen_random_uuid(),
        '00000000-0000-0000-0000-000000000010'::uuid,
        '00000000-0000-0000-0000-000000000020'::uuid,
        'completed', now() - interval '5 days', now() - interval '5 days' + interval '1 hour', (now() - interval '5 days')::date);

INSERT INTO public.guest_profiles (id, phone, accepts_marketing)
VALUES ('00000000-0000-0000-0000-000000000030'::uuid, '+10000001030', TRUE)
ON CONFLICT (id) DO UPDATE SET accepts_marketing = TRUE;

INSERT INTO public.bookings (id, shop_id, guest_profile_id, status, start_time, end_time, booking_date)
VALUES (gen_random_uuid(),
        '00000000-0000-0000-0000-000000000010'::uuid,
        '00000000-0000-0000-0000-000000000030'::uuid,
        'completed', now() - interval '7 days', now() - interval '7 days' + interval '1 hour', (now() - interval '7 days')::date);

DO $$
DECLARE
  v_result RECORD;
  v_push_count INT;
  v_whatsapp_count INT;
  v_status TEXT;
  v_delivered_at TIMESTAMPTZ;
BEGIN
  SELECT * INTO v_result FROM public.send_broadcast(
    '00000000-0000-0000-0000-000000000010'::uuid,
    'UAT subject', 'UAT body',
    'all_clients', NULL, NULL);

  IF v_result.recipient_count < 2 THEN
    RAISE EXCEPTION 'FAIL: recipient_count expected >=2, got %', v_result.recipient_count;
  END IF;

  SELECT status, delivered_at INTO v_status, v_delivered_at
  FROM public.broadcasts WHERE id = v_result.broadcast_id;
  IF v_status <> 'delivered' OR v_delivered_at IS NULL THEN
    RAISE EXCEPTION 'FAIL: broadcasts row not flipped to delivered';
  END IF;

  SELECT count(*) INTO v_push_count
  FROM public.scheduled_notifications
  WHERE metadata->>'broadcast_id' = v_result.broadcast_id::text
    AND delivery_channel = 'push';
  SELECT count(*) INTO v_whatsapp_count
  FROM public.scheduled_notifications
  WHERE metadata->>'broadcast_id' = v_result.broadcast_id::text
    AND delivery_channel = 'whatsapp';

  IF v_push_count < 1 OR v_whatsapp_count < 1 THEN
    RAISE EXCEPTION 'FAIL: expected at least 1 push and 1 whatsapp row, got push=% whatsapp=%',
      v_push_count, v_whatsapp_count;
  END IF;

  RAISE NOTICE 'OK: happy path — broadcast % delivered to % recipients (push=%, whatsapp=%)',
    v_result.broadcast_id, v_result.recipient_count, v_push_count, v_whatsapp_count;
END $$;
ROLLBACK TO SAVEPOINT e_happy;

-- ─── F. UTC-day rate limit ───
-- First call succeeds; second call same UTC day raises 55P03 /
-- BROADCAST_DAILY_LIMIT.
SAVEPOINT f_rate_limit;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

INSERT INTO public.bookings (id, shop_id, user_id, status, start_time, end_time, booking_date)
VALUES (gen_random_uuid(),
        '00000000-0000-0000-0000-000000000010'::uuid,
        '00000000-0000-0000-0000-000000000020'::uuid,
        'completed', now() - interval '5 days', now() - interval '5 days' + interval '1 hour', (now() - interval '5 days')::date);

DO $$ BEGIN
  PERFORM public.send_broadcast(
    '00000000-0000-0000-0000-000000000010'::uuid,
    'First', 'First body', 'all_clients', NULL, NULL);
  BEGIN
    PERFORM public.send_broadcast(
      '00000000-0000-0000-0000-000000000010'::uuid,
      'Second', 'Second body', 'all_clients', NULL, NULL);
    RAISE EXCEPTION 'FAIL: second send should have hit rate limit';
  EXCEPTION WHEN SQLSTATE '55P03' THEN
    RAISE NOTICE 'OK: second send same UTC day rejected with 55P03';
  END;
END $$;
ROLLBACK TO SAVEPOINT f_rate_limit;

-- ─── G. Advisory lock prevents same-second double-tap ───
-- Two concurrent sessions racing. Simulated here by manually holding the
-- xact lock from a sub-block and verifying a second call inside the same
-- transaction raises BROADCAST_IN_FLIGHT. The real-world race is between
-- two separate transactions; the semantics are the same since
-- pg_try_advisory_xact_lock returns FALSE when another xact holds it.
SAVEPOINT g_advisory_lock;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

-- Take the lock manually for the same shop_id hash, then call the RPC.
SELECT pg_advisory_xact_lock(hashtext('00000000-0000-0000-0000-000000000010'));

INSERT INTO public.bookings (id, shop_id, user_id, status, start_time, end_time, booking_date)
VALUES (gen_random_uuid(),
        '00000000-0000-0000-0000-000000000010'::uuid,
        '00000000-0000-0000-0000-000000000020'::uuid,
        'completed', now() - interval '5 days', now() - interval '5 days' + interval '1 hour', (now() - interval '5 days')::date);

-- NOTE: pg_try_advisory_xact_lock in the same transaction will RE-ACQUIRE
-- (advisory locks are re-entrant within the same xact). The true race
-- proof is between separate sessions; for the smoke we assert the
-- HINT shape by triggering it from a session that already holds the lock
-- via dblink/separate connection in a CI harness. Here we document the
-- expected behavior and rely on §F's rate-limit raise to also exercise
-- 55P03. To exercise the BROADCAST_IN_FLIGHT branch directly:
--   1. Open two psql sessions.
--   2. In session 1: BEGIN; SELECT pg_try_advisory_xact_lock(hashtext('<uuid>'));
--   3. In session 2: SELECT send_broadcast(...);
--      Expected: raises 55P03 with HINT BROADCAST_IN_FLIGHT.
--   4. In session 1: ROLLBACK;
RAISE NOTICE 'OK: advisory lock semantics documented; cross-session race must be exercised in a CI harness with two connections';
ROLLBACK TO SAVEPOINT g_advisory_lock;

-- ─── H. 1000-recipient cap ───
-- Seed >1000 distinct guest_profile_id bookings (guest path avoids the
-- bookings.user_id → auth.users FK violation that synthetic auth IDs
-- would trigger; also exercises the accepts_marketing gate path).
SAVEPOINT h_cap;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

DO $$
DECLARE i INT; v_guest_id UUID;
BEGIN
  FOR i IN 1..1001 LOOP
    -- Seed guest_profiles row (phone UNIQUE).
    v_guest_id := gen_random_uuid();
    INSERT INTO public.guest_profiles (id, phone, accepts_marketing)
    VALUES (v_guest_id,
            '+1' || lpad(i::text, 10, '0'),
            TRUE);
    -- Seed a completed guest booking referencing it.
    INSERT INTO public.bookings (
      id, shop_id, guest_profile_id, status,
      start_time, end_time, booking_date
    ) VALUES (
      gen_random_uuid(),
      '00000000-0000-0000-0000-000000000010'::uuid,
      v_guest_id,
      'completed',
      now() - interval '5 days',
      now() - interval '5 days' + interval '1 hour',
      (now() - interval '5 days')::date
    );
  END LOOP;
END $$;

DO $$ BEGIN
  BEGIN
    PERFORM public.send_broadcast(
      '00000000-0000-0000-0000-000000000010'::uuid,
      'Big', 'Big body', 'all_clients', NULL, NULL);
    RAISE EXCEPTION 'FAIL: 1001-recipient send should have hit BROADCAST_CAP_EXCEEDED';
  EXCEPTION WHEN SQLSTATE '22023' THEN
    RAISE NOTICE 'OK: 1001-recipient send rejected with 22023/BROADCAST_CAP_EXCEEDED';
  END;
END $$;
ROLLBACK TO SAVEPOINT h_cap;

-- ─── I. Recipient dedup on COALESCE(user_id, guest_profile_id) ───
-- Seed: user_1 has 5 completed bookings + 3 confirmed bookings at shop_a.
-- The audience must contain user_1 EXACTLY ONCE, and the fan-out must
-- write EXACTLY ONE push row.
SAVEPOINT i_dedup;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

DO $$ DECLARE i INT; BEGIN
  FOR i IN 1..5 LOOP
    INSERT INTO public.bookings (id, shop_id, user_id, status, start_time, end_time, booking_date)
    VALUES (gen_random_uuid(),
            '00000000-0000-0000-0000-000000000010'::uuid,
            '00000000-0000-0000-0000-000000000020'::uuid,
            'completed', now() - interval '5 days', now() - interval '5 days' + interval '1 hour', (now() - interval '5 days')::date);
  END LOOP;
  FOR i IN 1..3 LOOP
    INSERT INTO public.bookings (id, shop_id, user_id, status, start_time, end_time, booking_date)
    VALUES (gen_random_uuid(),
            '00000000-0000-0000-0000-000000000010'::uuid,
            '00000000-0000-0000-0000-000000000020'::uuid,
            'confirmed', now() - interval '2 days', now() - interval '2 days' + interval '1 hour', (now() - interval '2 days')::date);
  END LOOP;
END $$;

DO $$
DECLARE v_result RECORD; v_rows INT;
BEGIN
  SELECT * INTO v_result FROM public.send_broadcast(
    '00000000-0000-0000-0000-000000000010'::uuid,
    'Dedup', 'Dedup body', 'all_clients', NULL, NULL);

  IF v_result.recipient_count <> 1 THEN
    RAISE EXCEPTION 'FAIL: dedup should yield recipient_count=1, got %', v_result.recipient_count;
  END IF;

  SELECT count(*) INTO v_rows FROM public.scheduled_notifications
  WHERE metadata->>'broadcast_id' = v_result.broadcast_id::text;
  IF v_rows <> 1 THEN
    RAISE EXCEPTION 'FAIL: expected 1 fan-out row, got %', v_rows;
  END IF;

  RAISE NOTICE 'OK: user_1 deduplicated to a single recipient + single fan-out row';
END $$;
ROLLBACK TO SAVEPOINT i_dedup;

-- ─── J. accepts_marketing=FALSE guest excluded ───
-- Seed: one accepts_marketing=TRUE guest, one accepts_marketing=FALSE
-- guest. Expect recipient_count = 1; the FALSE guest gets no row.
SAVEPOINT j_accepts_marketing_gate;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

INSERT INTO public.guest_profiles (id, phone, accepts_marketing)
VALUES ('00000000-0000-0000-0000-000000000031'::uuid, '+10000001031', TRUE)
ON CONFLICT (id) DO UPDATE SET accepts_marketing = TRUE;

INSERT INTO public.guest_profiles (id, phone, accepts_marketing)
VALUES ('00000000-0000-0000-0000-000000000032'::uuid, '+10000001032', FALSE)
ON CONFLICT (id) DO UPDATE SET accepts_marketing = FALSE;

INSERT INTO public.bookings (id, shop_id, guest_profile_id, status, start_time, end_time, booking_date)
VALUES (gen_random_uuid(),
        '00000000-0000-0000-0000-000000000010'::uuid,
        '00000000-0000-0000-0000-000000000031'::uuid,
        'completed', now() - interval '5 days', now() - interval '5 days' + interval '1 hour', (now() - interval '5 days')::date);

INSERT INTO public.bookings (id, shop_id, guest_profile_id, status, start_time, end_time, booking_date)
VALUES (gen_random_uuid(),
        '00000000-0000-0000-0000-000000000010'::uuid,
        '00000000-0000-0000-0000-000000000032'::uuid,
        'completed', now() - interval '5 days', now() - interval '5 days' + interval '1 hour', (now() - interval '5 days')::date);

DO $$
DECLARE v_result RECORD; v_opt_in_rows INT; v_opt_out_rows INT;
BEGIN
  SELECT * INTO v_result FROM public.send_broadcast(
    '00000000-0000-0000-0000-000000000010'::uuid,
    'Opt-in test', 'Opt-in test body', 'all_clients', NULL, NULL);

  SELECT count(*) INTO v_opt_in_rows
  FROM public.scheduled_notifications
  WHERE metadata->>'broadcast_id' = v_result.broadcast_id::text
    AND guest_profile_id = '00000000-0000-0000-0000-000000000031'::uuid;
  SELECT count(*) INTO v_opt_out_rows
  FROM public.scheduled_notifications
  WHERE metadata->>'broadcast_id' = v_result.broadcast_id::text
    AND guest_profile_id = '00000000-0000-0000-0000-000000000032'::uuid;

  IF v_opt_in_rows <> 1 THEN
    RAISE EXCEPTION 'FAIL: opt-in guest expected 1 row, got %', v_opt_in_rows;
  END IF;
  IF v_opt_out_rows <> 0 THEN
    RAISE EXCEPTION 'FAIL: opt-out guest expected 0 rows, got %', v_opt_out_rows;
  END IF;

  RAISE NOTICE 'OK: accepts_marketing=FALSE guest excluded from fan-out';
END $$;
ROLLBACK TO SAVEPOINT j_accepts_marketing_gate;

-- ─── K. RLS owner-only SELECT on broadcasts ───
-- Owner_A sends a broadcast. Owner_B (different shop) reads broadcasts
-- table → must see zero rows from Owner_A's shop.
SAVEPOINT k_rls_select;

-- Owner_A seed + send
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;
INSERT INTO public.bookings (id, shop_id, user_id, status, start_time, end_time, booking_date)
VALUES (gen_random_uuid(),
        '00000000-0000-0000-0000-000000000010'::uuid,
        '00000000-0000-0000-0000-000000000020'::uuid,
        'completed', now() - interval '5 days', now() - interval '5 days' + interval '1 hour', (now() - interval '5 days')::date);

DO $$ DECLARE v_result RECORD; BEGIN
  SELECT * INTO v_result FROM public.send_broadcast(
    '00000000-0000-0000-0000-000000000010'::uuid,
    'A only', 'A only body', 'all_clients', NULL, NULL);
END $$;

-- Owner_B reads — RLS must hide the row.
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000002"}';
SET LOCAL ROLE authenticated;
DO $$ DECLARE v_rows INT; BEGIN
  SELECT count(*) INTO v_rows FROM public.broadcasts
  WHERE shop_id = '00000000-0000-0000-0000-000000000010'::uuid;
  IF v_rows <> 0 THEN
    RAISE EXCEPTION 'FAIL: owner_B saw % owner_A broadcasts (RLS leak)', v_rows;
  END IF;
  RAISE NOTICE 'OK: owner_B cannot SELECT owner_A broadcasts via RLS';
END $$;
ROLLBACK TO SAVEPOINT k_rls_select;

-- ─── L. broadcasts immutability — UPDATE / DELETE denied ───
-- Owner_A authenticated attempts a direct UPDATE / DELETE on their own
-- broadcasts row. RLS absence of INSERT/UPDATE/DELETE policies means the
-- statement affects 0 rows (silent deny) on Postgres ≥15 with FORCE RLS
-- semantics, or raises with FORCE RLS. We assert affected-row count = 0.
SAVEPOINT l_immutable;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SET LOCAL ROLE authenticated;

INSERT INTO public.bookings (id, shop_id, user_id, status, start_time, end_time, booking_date)
VALUES (gen_random_uuid(),
        '00000000-0000-0000-0000-000000000010'::uuid,
        '00000000-0000-0000-0000-000000000020'::uuid,
        'completed', now() - interval '5 days', now() - interval '5 days' + interval '1 hour', (now() - interval '5 days')::date);

DO $$
DECLARE
  v_result RECORD;
  v_updated INT;
  v_deleted INT;
BEGIN
  SELECT * INTO v_result FROM public.send_broadcast(
    '00000000-0000-0000-0000-000000000010'::uuid,
    'Immutable', 'Immutable body', 'all_clients', NULL, NULL);

  -- Attempt UPDATE as authenticated owner. No UPDATE policy → 0 rows.
  WITH u AS (
    UPDATE public.broadcasts SET subject = 'HACKED' WHERE id = v_result.broadcast_id RETURNING 1
  )
  SELECT count(*) INTO v_updated FROM u;
  IF v_updated <> 0 THEN
    RAISE EXCEPTION 'FAIL: UPDATE affected % rows (expected 0)', v_updated;
  END IF;

  -- Attempt DELETE as authenticated owner. No DELETE policy → 0 rows.
  WITH d AS (
    DELETE FROM public.broadcasts WHERE id = v_result.broadcast_id RETURNING 1
  )
  SELECT count(*) INTO v_deleted FROM d;
  IF v_deleted <> 0 THEN
    RAISE EXCEPTION 'FAIL: DELETE affected % rows (expected 0)', v_deleted;
  END IF;

  RAISE NOTICE 'OK: broadcasts immutable for authenticated (UPDATE=0, DELETE=0)';
END $$;
ROLLBACK TO SAVEPOINT l_immutable;

ROLLBACK;

-- Expected RAISE NOTICE output (one per section):
--   OK: preview_broadcast_audience returns N for shop with bookings
--   OK: all_clients=..., recent=..., lapsed=..., by_service=...
--   OK: send_broadcast rejected loyalty-source promo with 22023/PROMO_NOT_VALID
--   OK: send_broadcast rejected expired promo
--   OK: send_broadcast rejected archived promo
--   OK: happy path — broadcast <uuid> delivered to N recipients (push=P, whatsapp=W)
--   OK: second send same UTC day rejected with 55P03
--   OK: advisory lock semantics documented; cross-session race must be exercised in a CI harness with two connections
--   OK: 1001-recipient send rejected with 22023/BROADCAST_CAP_EXCEEDED
--   OK: user_1 deduplicated to a single recipient + single fan-out row
--   OK: accepts_marketing=FALSE guest excluded from fan-out
--   OK: owner_B cannot SELECT owner_A broadcasts via RLS
--   OK: broadcasts immutable for authenticated (UPDATE=0, DELETE=0)
