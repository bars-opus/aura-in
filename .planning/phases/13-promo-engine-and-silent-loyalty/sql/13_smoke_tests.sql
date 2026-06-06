-- Phase 13 — manual SQL smoke tests.
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
-- Coverage maps to the 9 SPEC success criteria + a §A precondition:
--   §A — per-shop UNIQUE code; cross-shop reuse permitted
--          (criteria 1, pre-condition for everything else)
--   §B — validate_and_apply_promo manual happy path                (2)
--   §C — expired code rejection (CODE_EXPIRED)                     (7)
--   §D — per-client cap enforcement (CODE_PER_CLIENT_MAX)          (3)
--   §E — service restriction rejection (CODE_SERVICE_NOT_ELIGIBLE) (7)
--   §F — auto-apply silent code (loyalty target)                   (5)
--   §G — loyalty_rules + upsert_loyalty_rule authz                 (—)
--   §H — redeem_promotion idempotency (registered + guest)         (9)
--   §I — loyalty trigger fires on Nth completion + idempotent      (4, 8)
--   §J — enqueue_booking_reminder('recovery_checkin') uses
--          recovery_checkin_v2 + embeds the code                   (6)
--
-- Reference identities (inlined throughout):
--   owner_uid     = 00000000-0000-0000-0000-000000000001
--   other_uid     = 00000000-0000-0000-0000-000000000002
--   shop_a        = 00000000-0000-0000-0000-000000000010
--   shop_b        = 00000000-0000-0000-0000-000000000011
--   test_user     = 00000000-0000-0000-0000-000000000020
--   test_guest    = 00000000-0000-0000-0000-000000000030
--   slot_a        = 00000000-0000-0000-0000-000000000040
--   slot_b        = 00000000-0000-0000-0000-000000000041
--   booking_a     = 00000000-0000-0000-0000-000000000050
--   booking_recover = 00000000-0000-0000-0000-000000000060

BEGIN;

-- ─── A. Per-shop UNIQUE code; cross-shop reuse permitted ──────────
-- Pre-condition for every other test: prove the constraint swap from
-- globally-unique `code` to per-shop UNIQUE (shop_id, UPPER(code)).
-- Two shops can both author 'SUMMER10'; same shop authoring it twice
-- fails.
SAVEPOINT a_unique;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';

-- shop_a owner creates SUMMER10
SELECT public.create_promotion(
  '00000000-0000-0000-0000-000000000010'::uuid, 'SUMMER10', 'percentage', 10,
  current_date, current_date + interval '30 days', 100, 1, NULL, NULL
);

-- shop_b (different owner) can also create SUMMER10 — per-shop scope
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000002"}';
SELECT public.create_promotion(
  '00000000-0000-0000-0000-000000000011'::uuid, 'SUMMER10', 'percentage', 5,
  current_date, current_date + interval '30 days', 100, 1, NULL, NULL
);

-- shop_a owner re-attempting SUMMER10 must fail (same shop, same code)
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
DO $$ BEGIN
  BEGIN
    PERFORM public.create_promotion(
      '00000000-0000-0000-0000-000000000010'::uuid, 'SUMMER10', 'percentage', 15,
      current_date, current_date + interval '30 days', 100, 1, NULL, NULL
    );
    RAISE EXCEPTION 'FAIL: duplicate per-shop code should have raised';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'OK: per-shop UNIQUE rejects duplicate; cross-shop allowed';
  END;
END $$;
ROLLBACK TO SAVEPOINT a_unique;

-- ─── B. validate_and_apply_promo manual happy path ─────────────────
-- Insert a code with discount=10%; validate against a 100-currency
-- booking; expect amount_off=10, new_total=90.
SAVEPOINT b_happy;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SELECT public.create_promotion(
  '00000000-0000-0000-0000-000000000010'::uuid, 'HAPPY10', 'percentage', 10,
  current_date, current_date + interval '30 days', 100, 1, NULL, NULL
);

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000020"}';
-- validate_and_apply_promo RETURNS TABLE — read columns directly,
-- not via JSON cast (which is undefined for record-typed results).
SELECT
  CASE WHEN amount_off = 10
        AND new_total = 90
        AND promotion_id IS NOT NULL
       THEN 'OK: validate_and_apply_promo happy path'
       ELSE 'FAIL: amount_off=' || amount_off::text
            || ' new_total=' || new_total::text
  END
FROM public.validate_and_apply_promo(
  '00000000-0000-0000-0000-000000000010'::uuid,
  'HAPPY10',
  '00000000-0000-0000-0000-000000000020'::uuid,
  NULL,
  100::numeric,
  NULL
);
ROLLBACK TO SAVEPOINT b_happy;

-- ─── C. Expired code rejection (CODE_EXPIRED) ──────────────────────
SAVEPOINT c_expired;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
INSERT INTO public.promotions (
  shop_id, name, code, discount_type, discount_value,
  valid_from, valid_to, usage_limit, per_client_max,
  source, is_active
) VALUES (
  '00000000-0000-0000-0000-000000000010', 'Expired', 'EXPIRED10',
  'percentage', 10,
  (now() - interval '60 days')::timestamptz,
  (now() - interval '1 day')::timestamptz,
  100, 1, 'owner_defined', true
);

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000020"}';
DO $$ BEGIN
  BEGIN
    PERFORM public.validate_and_apply_promo(
      '00000000-0000-0000-0000-000000000010'::uuid,
      'EXPIRED10',
      '00000000-0000-0000-0000-000000000020'::uuid,
      NULL,
      100::numeric,
      NULL
    );
    RAISE EXCEPTION 'FAIL: expired code should have raised';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM LIKE '%CODE_EXPIRED%' OR SQLSTATE = '22023' THEN
      RAISE NOTICE 'OK: expired code rejected with CODE_EXPIRED';
    ELSE
      RAISE EXCEPTION 'FAIL: wrong error: % (state %)', SQLERRM, SQLSTATE;
    END IF;
  END;
END $$;
ROLLBACK TO SAVEPOINT c_expired;

-- ─── D. Per-client cap enforcement (CODE_PER_CLIENT_MAX) ───────────
-- Code with per_client_max=1. First redemption succeeds; second
-- validate by same client must reject.
SAVEPOINT d_per_client;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SELECT public.create_promotion(
  '00000000-0000-0000-0000-000000000010'::uuid, 'CAP1', 'percentage', 10,
  current_date, current_date + interval '30 days', 100, 1, NULL, NULL
);

-- Simulate a prior redemption by test_user.
INSERT INTO public.promotion_redemptions (
  promotion_id, booking_id, user_id, guest_profile_id, discount_amount, redeemed_at
) SELECT
    id,
    '00000000-0000-0000-0000-000000000050'::uuid,
    '00000000-0000-0000-0000-000000000020'::uuid,
    NULL,
    10,
    now()
  FROM public.promotions
  WHERE shop_id = '00000000-0000-0000-0000-000000000010'
    AND code = 'CAP1';

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000020"}';
DO $$ BEGIN
  BEGIN
    PERFORM public.validate_and_apply_promo(
      '00000000-0000-0000-0000-000000000010'::uuid,
      'CAP1',
      '00000000-0000-0000-0000-000000000020'::uuid,
      NULL,
      100::numeric,
      NULL
    );
    RAISE EXCEPTION 'FAIL: second redemption should have raised';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM LIKE '%CODE_PER_CLIENT_MAX%' OR SQLSTATE = '22023' THEN
      RAISE NOTICE 'OK: per_client_max enforced after first redemption';
    ELSE
      RAISE EXCEPTION 'FAIL: wrong error: % (state %)', SQLERRM, SQLSTATE;
    END IF;
  END;
END $$;
ROLLBACK TO SAVEPOINT d_per_client;

-- ─── E. Service restriction rejection ──────────────────────────────
-- Code restricted to slot_a; validate for a booking containing only
-- slot_b — must reject.
SAVEPOINT e_service;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SELECT public.create_promotion(
  '00000000-0000-0000-0000-000000000010'::uuid, 'HAIRCUT10', 'percentage', 10,
  current_date, current_date + interval '30 days', 100, 1, NULL,
  ARRAY['00000000-0000-0000-0000-000000000040'::uuid]
);

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000020"}';
DO $$ BEGIN
  BEGIN
    PERFORM public.validate_and_apply_promo(
      '00000000-0000-0000-0000-000000000010'::uuid,
      'HAIRCUT10',
      '00000000-0000-0000-0000-000000000020'::uuid,
      NULL,
      100::numeric,
      ARRAY['00000000-0000-0000-0000-000000000041'::uuid]  -- slot_b only
    );
    RAISE EXCEPTION 'FAIL: service-restricted code should have raised';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM LIKE '%CODE_SERVICE_NOT_ELIGIBLE%' OR SQLSTATE = '22023' THEN
      RAISE NOTICE 'OK: service restriction enforced';
    ELSE
      RAISE EXCEPTION 'FAIL: wrong error: % (state %)', SQLERRM, SQLSTATE;
    END IF;
  END;
END $$;
ROLLBACK TO SAVEPOINT e_service;

-- ─── F. Auto-apply silent code (loyalty target) ────────────────────
-- Insert a loyalty code with target_user_id; call validate with
-- p_code = NULL; expect the silent code to come back.
SAVEPOINT f_autoapply;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
INSERT INTO public.promotions (
  shop_id, name, code, discount_type, discount_value,
  valid_from, valid_to, usage_limit, per_client_max,
  source, target_user_id, is_active
) VALUES (
  '00000000-0000-0000-0000-000000000010', 'Loyalty', 'LOYALTY-AUTOAPLY',
  'percentage', 15,
  current_date, NULL,
  1, 1, 'loyalty',
  '00000000-0000-0000-0000-000000000020'::uuid,
  true
);

SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000020"}';
-- RETURNS TABLE — read columns directly.
SELECT
  CASE WHEN code = 'LOYALTY-AUTOAPLY'
        AND amount_off = 15
       THEN 'OK: auto-apply returns the silent loyalty code'
       ELSE 'FAIL: code=' || COALESCE(code, 'NULL')
            || ' amount_off=' || COALESCE(amount_off::text, 'NULL')
  END
FROM public.validate_and_apply_promo(
  '00000000-0000-0000-0000-000000000010'::uuid,
  NULL,
  '00000000-0000-0000-0000-000000000020'::uuid,
  NULL,
  100::numeric,
  NULL
);
ROLLBACK TO SAVEPOINT f_autoapply;

-- ─── G. loyalty_rules + upsert_loyalty_rule authz ──────────────────
-- Non-owner attempting to upsert a loyalty rule for shop_a must fail.
SAVEPOINT g_authz;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000002"}';
DO $$ BEGIN
  BEGIN
    PERFORM public.upsert_loyalty_rule(
      '00000000-0000-0000-0000-000000000010'::uuid,
      6, 'percentage', 15, true
    );
    RAISE EXCEPTION 'FAIL: non-owner should have raised 42501';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'OK: upsert_loyalty_rule authz';
  END;
END $$;
ROLLBACK TO SAVEPOINT g_authz;

-- ─── H. redeem_promotion idempotency (registered + guest) ──────────
-- Same (promotion_id, booking_id) pair: second call must NOT insert a
-- second row. Verified for both registered (user_id) and guest paths.
SAVEPOINT h_idem;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SELECT public.create_promotion(
  '00000000-0000-0000-0000-000000000010'::uuid, 'IDEM10', 'percentage', 10,
  current_date, current_date + interval '30 days', 100, 1, NULL, NULL
);

-- Run as service_role-equivalent (SECURITY DEFINER bypasses RLS).
RESET ROLE;

-- First call: registered path
SELECT public.redeem_promotion(
  (SELECT id FROM public.promotions
    WHERE shop_id = '00000000-0000-0000-0000-000000000010'
      AND code = 'IDEM10'),
  '00000000-0000-0000-0000-000000000050'::uuid,
  '00000000-0000-0000-0000-000000000020'::uuid,
  NULL,
  10::numeric
);

-- Second call: same pair → ON CONFLICT DO NOTHING
SELECT public.redeem_promotion(
  (SELECT id FROM public.promotions
    WHERE shop_id = '00000000-0000-0000-0000-000000000010'
      AND code = 'IDEM10'),
  '00000000-0000-0000-0000-000000000050'::uuid,
  '00000000-0000-0000-0000-000000000020'::uuid,
  NULL,
  10::numeric
);

SELECT
  CASE WHEN COUNT(*) = 1
       THEN 'OK: redeem_promotion idempotent (registered path)'
       ELSE 'FAIL: expected 1 row, got ' || COUNT(*)::text
  END
FROM public.promotion_redemptions
WHERE booking_id = '00000000-0000-0000-0000-000000000050';

-- Guest path: different booking, guest_profile_id set, two calls
SELECT public.redeem_promotion(
  (SELECT id FROM public.promotions
    WHERE shop_id = '00000000-0000-0000-0000-000000000010'
      AND code = 'IDEM10'),
  '00000000-0000-0000-0000-000000000051'::uuid,
  NULL,
  '00000000-0000-0000-0000-000000000030'::uuid,
  10::numeric
);
SELECT public.redeem_promotion(
  (SELECT id FROM public.promotions
    WHERE shop_id = '00000000-0000-0000-0000-000000000010'
      AND code = 'IDEM10'),
  '00000000-0000-0000-0000-000000000051'::uuid,
  NULL,
  '00000000-0000-0000-0000-000000000030'::uuid,
  10::numeric
);

SELECT
  CASE WHEN COUNT(*) = 1
        AND BOOL_AND(user_id IS NULL AND guest_profile_id IS NOT NULL)
       THEN 'OK: redeem_promotion idempotent (guest path)'
       ELSE 'FAIL: guest idempotency or NULL constraints failed'
  END
FROM public.promotion_redemptions
WHERE booking_id = '00000000-0000-0000-0000-000000000051';
ROLLBACK TO SAVEPOINT h_idem;

-- ─── I. Loyalty trigger fires on Nth completion + idempotent ──────
-- Set loyalty rule: trigger_visit_count = 3 for shop_a.
-- Insert 2 completed bookings for the same client. No loyalty code yet.
-- Mark a 3rd booking completed via UPDATE — trigger fires; loyalty
-- code appears. Re-mark the same booking completed → no new code.
SAVEPOINT i_loyalty;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SELECT public.upsert_loyalty_rule(
  '00000000-0000-0000-0000-000000000010'::uuid,
  3, 'percentage', 20, true
);

RESET ROLE;

-- 2 prior completed bookings.
-- NOTE: bookings has many NOT NULL columns (verified against live DDL):
-- bookings(id, shop_id, user_id, booking_date, start_time, end_time,
-- actual_end_time, status, total_amount, deposit_amount,
-- payment_method, payment_status, created_at, updated_at).
-- Defaults are insufficient for some columns; provide all explicitly.
INSERT INTO public.bookings (
  id, shop_id, user_id, booking_date, start_time, end_time, actual_end_time,
  status, total_amount, deposit_amount, payment_method, payment_status
) VALUES
  ('00000000-0000-0000-0000-0000000000a1'::uuid,
   '00000000-0000-0000-0000-000000000010'::uuid,
   '00000000-0000-0000-0000-000000000020'::uuid,
   (now() - interval '30 days')::date,
   now() - interval '30 days', now() - interval '30 days' + interval '1 hour',
   now() - interval '30 days' + interval '1 hour',
   'completed', 100, 0, 'card', 'paid'),
  ('00000000-0000-0000-0000-0000000000a2'::uuid,
   '00000000-0000-0000-0000-000000000010'::uuid,
   '00000000-0000-0000-0000-000000000020'::uuid,
   (now() - interval '15 days')::date,
   now() - interval '15 days', now() - interval '15 days' + interval '1 hour',
   now() - interval '15 days' + interval '1 hour',
   'completed', 100, 0, 'card', 'paid');

-- Plan-check WARNING 3: assert the trigger does NOT fire on INSERT.
-- The two completed rows above should not have generated any loyalty
-- codes yet — the trigger is AFTER UPDATE OF status, not AFTER INSERT.
SELECT
  CASE WHEN COUNT(*) = 0
       THEN 'OK: loyalty trigger inert on INSERT'
       ELSE 'FAIL: trigger fired on INSERT; got ' || COUNT(*)::text
  END
FROM public.promotions
WHERE shop_id = '00000000-0000-0000-0000-000000000010'
  AND source = 'loyalty'
  AND target_user_id = '00000000-0000-0000-0000-000000000020'::uuid;

-- 3rd booking starts as confirmed (does NOT trigger — WHEN clause requires completed).
INSERT INTO public.bookings (
  id, shop_id, user_id, booking_date, start_time, end_time, actual_end_time,
  status, total_amount, deposit_amount, payment_method, payment_status
) VALUES
  ('00000000-0000-0000-0000-0000000000a3'::uuid,
   '00000000-0000-0000-0000-000000000010'::uuid,
   '00000000-0000-0000-0000-000000000020'::uuid,
   (now() + interval '1 day')::date,
   now() + interval '26 hours', now() + interval '27 hours',
   now() + interval '27 hours',
   'confirmed', 100, 0, 'card', 'paid');

-- Flip to completed — NOW the trigger fires (3rd completion = N).
UPDATE public.bookings SET status = 'completed'
WHERE id = '00000000-0000-0000-0000-0000000000a3'::uuid;

SELECT
  CASE WHEN COUNT(*) = 1
        AND BOOL_AND(source = 'loyalty')
        AND BOOL_AND(target_user_id = '00000000-0000-0000-0000-000000000020'::uuid)
        AND BOOL_AND(discount_value = 20)
       THEN 'OK: loyalty trigger generated code on Nth completion'
       ELSE 'FAIL: expected 1 loyalty code, got ' || COUNT(*)::text
  END
FROM public.promotions
WHERE shop_id = '00000000-0000-0000-0000-000000000010'
  AND source = 'loyalty'
  AND target_user_id = '00000000-0000-0000-0000-000000000020'::uuid;

-- Re-mark the same booking — must NOT produce a 2nd code
UPDATE public.bookings SET status = 'completed', updated_at = now()
WHERE id = '00000000-0000-0000-0000-0000000000a3'::uuid;

SELECT
  CASE WHEN COUNT(*) = 1
       THEN 'OK: loyalty trigger idempotent on re-mark'
       ELSE 'FAIL: idempotency broken; got ' || COUNT(*)::text
  END
FROM public.promotions
WHERE shop_id = '00000000-0000-0000-0000-000000000010'
  AND source = 'loyalty'
  AND target_user_id = '00000000-0000-0000-0000-000000000020'::uuid;
ROLLBACK TO SAVEPOINT i_loyalty;

-- ─── J. enqueue_booking_reminder(recovery_checkin) uses v2 + code ──
-- With the active loyalty rule in place, calling enqueue_booking_reminder
-- with type=recovery_checkin must:
--   * generate a recovery code (source='recovery', valid_until ≈ now+30d)
--   * write a scheduled_notifications row with
--     whatsapp_template = 'recovery_checkin_v2'
--     whatsapp_params->>'3' = the code text
SAVEPOINT j_recovery;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SELECT public.upsert_loyalty_rule(
  '00000000-0000-0000-0000-000000000010'::uuid,
  3, 'percentage', 25, true
);

RESET ROLE;

-- Insert a guest booking so the channel branches to WhatsApp.
-- Same NOT NULL constraints as §I.
INSERT INTO public.bookings (
  id, shop_id, user_id, guest_profile_id, booking_date,
  start_time, end_time, actual_end_time,
  status, total_amount, deposit_amount, payment_method, payment_status,
  guest_phone, guest_name
) VALUES (
  '00000000-0000-0000-0000-000000000060'::uuid,
  '00000000-0000-0000-0000-000000000010'::uuid,
  NULL,
  '00000000-0000-0000-0000-000000000030'::uuid,
  (now() + interval '2 days')::date,
  now() + interval '2 days', now() + interval '2 days' + interval '1 hour',
  now() + interval '2 days' + interval '1 hour',
  'cancelled', 100, 0, 'card', 'paid',
  '+233200000000',
  'TestGuest'
);

-- Trigger the recovery_checkin schedule.
-- PERFORM is PL/pgSQL-only; use SELECT at top level (the function
-- returns UUID — we discard it).
SELECT public.enqueue_booking_reminder(
  '00000000-0000-0000-0000-000000000060'::uuid,
  'recovery_checkin'::notification_type,
  now() + interval '7 days'
);

-- Assert: a recovery promo was generated
SELECT
  CASE WHEN COUNT(*) = 1
        AND BOOL_AND(source = 'recovery')
        AND BOOL_AND(target_guest_profile_id =
                     '00000000-0000-0000-0000-000000000030'::uuid)
        AND BOOL_AND(valid_to::date = (now() + interval '30 days')::date)
       THEN 'OK: recovery code generated by enqueue_booking_reminder'
       ELSE 'FAIL: recovery code missing or malformed'
  END
FROM public.promotions
WHERE shop_id = '00000000-0000-0000-0000-000000000010'
  AND source = 'recovery'
  AND target_guest_profile_id = '00000000-0000-0000-0000-000000000030'::uuid;

-- Assert: scheduled_notifications row uses v2 template + code variable
SELECT
  CASE WHEN COUNT(*) = 1
        AND BOOL_AND(whatsapp_template = 'recovery_checkin_v2')
        AND BOOL_AND(whatsapp_params ? '3')
        AND BOOL_AND(whatsapp_params->>'3' ~ '^RECOVER-[A-Z0-9]+$')
       THEN 'OK: scheduled notification uses recovery_checkin_v2 + code'
       ELSE 'FAIL: template or code var missing'
  END
FROM public.scheduled_notifications
WHERE booking_id = '00000000-0000-0000-0000-000000000060'
  AND notification_type = 'recovery_checkin';
ROLLBACK TO SAVEPOINT j_recovery;

ROLLBACK;

-- End of Phase 13 smoke tests.
