# Phase 13 PLAN — Promo Engine + Silent Loyalty

## Goal

Convert NanoEmbryo from "every booking pays sticker price" into a rule-driven discount engine without breaking the existing owner-facing promotions UI. EXTEND the live `promotions` / `promotion_redemptions` tables (do NOT build parallel `promo_codes` schema); REUSE the existing `redeem_promotion` RPC (Wave 2 widens its signature to accept `guest_profile_id`; Wave 0 REVOKEs its `GRANT EXECUTE TO authenticated`); ADD one new RPC `validate_and_apply_promo` for the checkout hot path; ADD one new RPC `upsert_loyalty_rule` for the new `loyalty_rules` table; ADD two SECURITY DEFINER helpers (`generate_loyalty_code`, `generate_recovery_code`); ADD one AFTER UPDATE OF status trigger on `bookings` that fires on the completed transition and idempotently issues loyalty codes; PATCH the Phase 12 `enqueue_booking_reminder` helper so `recovery_checkin` rows embed a generated code via a new `recovery_checkin_v2` WhatsApp template; PATCH `payment_controller.dart` to carry `promotionId` through `pending_payments.booking_data` (NOT Stripe/Paystack metadata — verified RESEARCH §3); PATCH the three webhooks to call `redeem_promotion` after booking insert; EXTEND `CreatePromotionScreen` with four new owner-facing fields and `PromotionsScreen` with source badges; ADD one new `LoyaltyRuleScreen` routed from the Tools tab; EXTEND `booking_confirmation_screen.dart` with a Promo code TextField that auto-applies silent codes on mount and recomputes platform fee against the discounted total. (SPEC §Outcome lines 3–47; SPEC §"Research-resolved decisions (locked 2026-06-06)" lines 79–92; RESEARCH §1 lines 95–204, §2 lines 206–246, §3 lines 248–309, §4 lines 310–430, §5 lines 432–550, §6 lines 568–596, §7 lines 598–674, §11 lines 774–799, §15 lines 873–897, §17 lines 925–962.)

## Out of scope (locked)

Verbatim from SPEC §"Out of scope (locked)" lines 115–128:

- **Tiered loyalty (gold/silver/platinum)** — visit-count rewards only in v1.
- **Referral codes** — Phase 14+ if at all.
- **Promo code stacking** — exactly one code per booking. Validation rejects a second.
- **Per-day-of-week / happy-hour activation** — single validity window per code; no cron flipping.
- **Birthday discounts** — DOB not collected.
- **Group booking discounts** — per-booking discount only.
- **Marketing broadcast of codes to clients** — Phase 14.
- **Loyalty progress visible to clients** — LOCKED silent. No badges, no "X more visits".
- **Multi-shop loyalty** — `loyalty_rules.shop_id` is the boundary.
- **Promo expiry warnings to clients** — codes silently stop validating.
- **Retroactive code activation** — codes apply only to bookings created AFTER the code is active.
- **Per-day / per-client / per-service redemption analytics** — v1 ships code count + total $ discounted only.

### Out of scope (locked-in design decisions vs. SPEC drafts)

- **NEW `promo_codes` / `promo_redemptions` tables** — DROPPED. RESEARCH §1 confirmed the existing `promotions` + `promotion_redemptions` tables with a full owner UI; Phase 13 EXTENDS, doesn't rebuild. The existing owner-facing files (`PromotionsScreen`, `CreatePromotionScreen`, `PromotionsRepository`, `Promotion` model, `PromotionException` hierarchy) keep working unchanged.
- **NEW `record_promo_redemption` RPC** — DROPPED. RESEARCH §3 lines 301–308 confirmed `redeem_promotion` already does the atomic counter+ledger write with the right `ON CONFLICT` semantics. Wave 1 widens its signature with `p_guest_profile_id`; nothing else changes.
- **Dropping the legacy `discount_type = 'free_addon'` CHECK value** — DROPPED. Zero forward cost; Phase 13 simply doesn't use it. The validate RPC explicitly rejects it via a CASE in the discount-math expression (RESEARCH §8 line 710).
- **Separate `recovery_rules` table for recovery code config** — DROPPED. Recovery reuses the shop's active `loyalty_rules` row (`discount_kind` + `discount_value`). If the shop has no active loyalty rule, `generate_recovery_code` returns NULL and the recovery_checkin message stays text-only. (SPEC line 84; RESEARCH §5 lines 552–565.)
- **Manual `recovery_checkin` skip-when-no-code logic** — DROPPED. The helper builds the message body conditionally on `v_recovery_code IS NOT NULL` (RESEARCH §5 lines 477–484). No flag, no skip-list.

### Carry-over gaps explicitly NOT fixed

- **`notification_settings.{recovery_checkin}_enabled`** is not consulted by the worker today (Phase 12 RESEARCH §3 line 109). Phase 13 does not change that; the `recovery_checkin` row with embedded code rides the existing `delivery_channel`-only branching.
- **`payment_controller.dart`'s `platformFeeFraction` recomputation against the discounted total is client-side**, mirroring the existing behavior. The webhook stores what the client sends (RESEARCH §2 lines 222–246). Locked.

## Files touched

**NEW (SQL — strict timestamp order)**

- `supabase/migrations/20260606000000_extend_promotions_for_phase13.sql`
- `supabase/migrations/20260606000100_loyalty_rules_table.sql`
- `supabase/migrations/20260606000200_widen_redeem_promotion_for_guests.sql`
- `supabase/migrations/20260606000300_validate_and_apply_promo_rpc.sql`
- `supabase/migrations/20260606000400_upsert_loyalty_rule_rpc.sql`
- `supabase/migrations/20260606000500_generate_loyalty_code_helper.sql`
- `supabase/migrations/20260606000600_generate_recovery_code_helper.sql`
- `supabase/migrations/20260606000700_booking_loyalty_trigger.sql`
- `supabase/migrations/20260606000800_patch_enqueue_booking_reminder_for_recovery_code.sql`

**NEW (Dart)**

- `lib/presentation/features/shops/dashboard/data/models/loyalty_rule_dto.dart`
- `lib/presentation/features/shops/dashboard/data/repositories/loyalty_rule_repository.dart`
- `lib/presentation/features/shops/dashboard/providers/loyalty_rule_provider.dart`
- `lib/presentation/features/shops/dashboard/presentation/screens/loyalty_rule_screen.dart`
- `lib/presentation/features/shops/booking/presentation/widgets/client_promo_code_field.dart`
- `test/presentation/features/shops/dashboard/data/exceptions/promotion_exceptions_test.dart`
- `test/presentation/features/shops/dashboard/data/repositories/validate_and_apply_promo_test.dart`
- `test/presentation/features/shops/booking/presentation/widgets/client_promo_code_field_test.dart`
- `.planning/phases/13-promo-engine-and-silent-loyalty/sql/13_smoke_tests.sql`

**EDIT (edge functions — same release as SQL)**

- `supabase/functions/paystack-webhook/index.ts` — after the `console.log('✅ Booking created:', booking.id)` line (around line 170 per RESEARCH §3 lines 280–283), read `bookingData.promotionId` and call `redeem_promotion` if non-null. Repeat in the registered-user path.
- `supabase/functions/stripe-webhook/index.ts` — same diff after line 242.
- `supabase/functions/verify-payment/index.ts` — same diff after line 189.

**EDIT (Dart)**

- `lib/presentation/features/shops/dashboard/data/exceptions/promotion_exceptions.dart` — EXTEND the existing hierarchy in place with six new subtypes (`PromoExpiredException`, `PromoMinAmountNotMetException`, `PromoServiceNotEligibleException`, `PromoPerClientMaxException`, `PromoWrongClientException`, `LoyaltyRuleSaveFailedException`). NO new `promo_exceptions.dart` file (RESEARCH §17 lines 938–940).
- `lib/presentation/features/shops/dashboard/data/repositories/promotions_repository.dart` — add `validateAndApplyPromo`, `getLoyaltyRule`, `upsertLoyaltyRule` methods with HINT-based exception mapping mirroring the existing `incrementUsage` pattern at lines 130–148.
- `lib/presentation/features/shops/dashboard/data/models/promotion_model.dart` — add nullable fields for the new columns (`source`, `targetUserId`, `targetGuestProfileId`, `perClientMax`, `minBookingAmount`, `serviceRestriction`, `archivedAt`). Defaults preserve the existing JSON shape.
- `lib/presentation/features/shops/dashboard/presentation/screens/create_promotion_screen.dart` — add four new form fields (per-client max numeric input, min booking amount currency input, service multi-select dropdown, archived toggle). Form layout follows the existing field-stack pattern.
- `lib/presentation/features/shops/dashboard/presentation/screens/promotions_screen.dart` — add `source` badge to list rows; filter out `source IN ('loyalty', 'recovery')` rows by default with an optional debug-mode toggle.
- `lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart` — add one new Tools card routing to `LoyaltyRuleScreen` next to the existing Promotions card.
- `lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart` — embed `ClientPromoCodeField` above the totals row; on mount call validate with `pCode = null` (auto-apply); on Apply tap call validate with the typed code; store `promotionId` in state; pass through to `processPayment`; recompute platform fee from `newTotal * platformFeeFraction`.
- `lib/payment/presentation/controllers/payment_controller.dart` — add optional `promotionId: String?` parameter to `processPayment` signature (line 90 region); add `'promotionId': promotionId` to `requestBody` (line 123 region). Zero behavioral change when null.

**EDIT (Meta — out-of-band, BEFORE merge per RESEARCH §6)**

- Submit `recovery_checkin_v2` WhatsApp template to Meta for approval. Three variables: `{{1}}` = client_name, `{{2}}` = shop_name, `{{3}}` = recovery code. Body draft per RESEARCH §5 lines 477–484. Worker's 6-hour `WhatsAppTemplateNotFoundError` defer (process-scheduled-notifications/index.ts:124-128) covers the approval window automatically; existing `recovery_checkin_v1` rows keep flowing until the helper switches in Wave 2.

## Pre-flight checks (BLOCKING — run before Wave 0)

These run once on the production DB. Any non-zero return blocks the PR from merging.

```sql
-- (1) Confirm valid_from / valid_to are DATE (we widen to TIMESTAMPTZ in Wave 0).
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'promotions' AND column_name IN ('valid_from', 'valid_to');
-- Expected: both rows show data_type = 'date'. If 'timestamp with time zone', skip
-- the ALTER COLUMN TYPE in Wave 0 (idempotent IF EXISTS, but verify by reading
-- the migration output).

-- (2) Confirm promotion_redemptions has user_id NOT NULL, no guest_profile_id.
SELECT column_name, is_nullable, data_type FROM information_schema.columns
WHERE table_name = 'promotion_redemptions' ORDER BY ordinal_position;
-- Expected: user_id is_nullable='NO'; no row for guest_profile_id. Phase 13
-- makes user_id nullable and adds guest_profile_id in Wave 0.

-- (3) Confirm the global UNIQUE on promotions.code (RESEARCH §1 line 91 calls
-- this CRITICAL). The Wave 0 drop hits this constraint.
SELECT conname, pg_get_constraintdef(oid) FROM pg_constraint
WHERE conrelid = 'public.promotions'::regclass AND contype = 'u';
-- Expected: ONE row with conname = 'promotions_code_key' and constraint def
-- 'UNIQUE (code)'. If conname differs, update the DROP CONSTRAINT in
-- 20260606000000_extend_promotions_for_phase13.sql to match.

-- (4) **CRITICAL — duplicate codes across shops.** If ANY rows return,
-- BLOCK the migration. The per-shop UNIQUE we replace with cannot be created
-- while two shops own the same code text.
SELECT UPPER(code) AS code_text, COUNT(*) AS shop_count, array_agg(shop_id) AS shops
FROM public.promotions
WHERE archived_at IS NULL OR archived_at IS NULL  -- archived_at not yet present; this is the dev-DB pre-flight
GROUP BY UPPER(code)
HAVING COUNT(*) > 1;
-- Expected: zero rows. Dev DB confirmed empty 2026-06-06. Re-run against
-- prod immediately before deploy. If non-empty: contact each owner pair,
-- ask one to rename their code, document the rename in the PR before merge.

-- (5) Confirm zero direct Dart callers of redeem_promotion (we REVOKE the
-- authenticated GRANT in Wave 0).
-- Run locally: grep -rn 'redeem_promotion' lib/
-- Expected: ONLY promotions_repository.dart:122 (the dead-code incrementUsage
-- method per RESEARCH §18 lines 1003-1009). If any other caller appears,
-- audit it before revoking.
```

The pre-flight script is also pasted at the top of the smoke SQL file so the executor sees it before running anything destructive.

## Migration plan

Nine new SQL migrations. Strict timestamp order. Edge-function diffs ship in the same release. Every RPC follows the Phase 11 hardening template ([20260603001500_harden_dashboard_rpcs.sql](../../../supabase/migrations/20260603001500_harden_dashboard_rpcs.sql) lines 29–108) byte-for-byte: `LANGUAGE plpgsql`, `SECURITY DEFINER`, `SET search_path = public`, authz ownership gate FIRST, validation second, `'not_found'` raises with `ERRCODE = '42501'`, `'invalid_*'` raises with `ERRCODE = '22023'` + `HINT = '...'`, then `REVOKE ALL ... FROM PUBLIC`, GRANT only when callable from clients, and `COMMENT ON FUNCTION ... IS '... Big-O ...'`.

### 1. `20260606000000_extend_promotions_for_phase13.sql`

Schema extension for the existing `promotions` and `promotion_redemptions` tables. Every column add is `IF NOT EXISTS` and idempotent. The constraint swap (drop global `promotions_code_key`, add per-shop `promotions_shop_code_unique`) is the riskiest single operation in Phase 13 — pre-flight check 4 BLOCKS the migration if duplicates exist across shops.

```sql
-- Phase 13: extend promotions for silent codes + per-shop scoping.
-- All adds idempotent. Constraint swap requires pre-flight check 4 to pass.

-- 1. Widen valid_from / valid_to from DATE to TIMESTAMPTZ. Existing data
-- coerces cleanly (date → midnight UTC). Owner UI continues to write dates.
DO $$ BEGIN
  IF (SELECT data_type FROM information_schema.columns
      WHERE table_name = 'promotions' AND column_name = 'valid_from') = 'date' THEN
    ALTER TABLE public.promotions
      ALTER COLUMN valid_from TYPE TIMESTAMPTZ USING valid_from::TIMESTAMPTZ,
      ALTER COLUMN valid_to   TYPE TIMESTAMPTZ USING valid_to::TIMESTAMPTZ;
  END IF;
END $$;

-- 2. Add new columns.
ALTER TABLE public.promotions
  ADD COLUMN IF NOT EXISTS per_client_max          INT NOT NULL DEFAULT 1
    CHECK (per_client_max >= 1),
  ADD COLUMN IF NOT EXISTS min_booking_amount      NUMERIC(12,2),
  ADD COLUMN IF NOT EXISTS service_restriction     UUID[],
  ADD COLUMN IF NOT EXISTS source                  TEXT NOT NULL DEFAULT 'owner_defined'
    CHECK (source IN ('owner_defined','loyalty','recovery')),
  ADD COLUMN IF NOT EXISTS target_user_id          UUID
    REFERENCES auth.users(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS target_guest_profile_id UUID
    REFERENCES public.guest_profiles(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS archived_at             TIMESTAMPTZ;

-- 3. XOR constraint on target_*: owner_defined → both NULL; loyalty/recovery →
-- exactly one set. Locks the silent-code identity contract.
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'promotions_target_xor_check'
      AND conrelid = 'public.promotions'::regclass
  ) THEN
    ALTER TABLE public.promotions ADD CONSTRAINT promotions_target_xor_check
      CHECK (
        source = 'owner_defined'
        OR (
          source IN ('loyalty', 'recovery')
          AND ((target_user_id IS NOT NULL) <> (target_guest_profile_id IS NOT NULL))
        )
      );
  END IF;
END $$;

-- 4. Constraint swap: drop the global UNIQUE on code, replace with per-shop
-- UNIQUE on (shop_id, UPPER(code)) WHERE archived_at IS NULL. The partial
-- predicate lets owners re-issue a code text after archiving the old one.
-- Pre-flight check 4 must pass first (zero duplicate codes across shops).
ALTER TABLE public.promotions DROP CONSTRAINT IF EXISTS promotions_code_key;

CREATE UNIQUE INDEX IF NOT EXISTS promotions_shop_code_unique
  ON public.promotions (shop_id, UPPER(code))
  WHERE archived_at IS NULL;

-- 5. Auto-apply silent code lookup index (RESEARCH §1 lines 164-168).
CREATE UNIQUE INDEX IF NOT EXISTS promotions_silent_target_uniq
  ON public.promotions (shop_id, COALESCE(target_user_id, target_guest_profile_id), source)
  WHERE source IN ('loyalty','recovery') AND archived_at IS NULL;

-- 6. promotion_redemptions: make user_id nullable, add guest_profile_id,
-- enforce exactly-one-of identity.
ALTER TABLE public.promotion_redemptions
  ALTER COLUMN user_id DROP NOT NULL,
  ADD COLUMN IF NOT EXISTS guest_profile_id UUID
    REFERENCES public.guest_profiles(id) ON DELETE SET NULL;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'promotion_redemptions_identity_check'
      AND conrelid = 'public.promotion_redemptions'::regclass
  ) THEN
    ALTER TABLE public.promotion_redemptions ADD CONSTRAINT promotion_redemptions_identity_check
      CHECK (
        -- Pre-identity-resolution rows allowed (both NULL). At-most-one set.
        (user_id IS NULL) OR (guest_profile_id IS NULL)
      );
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS promotion_redemptions_promo_user
  ON public.promotion_redemptions (promotion_id, user_id)
  WHERE user_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS promotion_redemptions_promo_guest
  ON public.promotion_redemptions (promotion_id, guest_profile_id)
  WHERE guest_profile_id IS NOT NULL;

-- 7. RLS tightening: replace the broad owner_all policy with four scoped
-- policies. Direct INSERT/UPDATE/DELETE restricted to owner_defined rows;
-- system codes (loyalty / recovery) can only be written by SECURITY DEFINER
-- helpers (which bypass RLS). Closes the fabrication surface where an owner
-- could otherwise set source='loyalty' + target_user_id=<arbitrary>.
DROP POLICY IF EXISTS promotions_owner_all ON public.promotions;

CREATE POLICY promotions_owner_select ON public.promotions
  FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.shops s
                 WHERE s.id = promotions.shop_id AND s.user_id = auth.uid()));

CREATE POLICY promotions_owner_write_owner_defined ON public.promotions
  FOR INSERT TO authenticated
  WITH CHECK (
    source = 'owner_defined'
    AND EXISTS (SELECT 1 FROM public.shops s
                WHERE s.id = promotions.shop_id AND s.user_id = auth.uid())
  );

CREATE POLICY promotions_owner_update_owner_defined ON public.promotions
  FOR UPDATE TO authenticated
  USING (source = 'owner_defined'
         AND EXISTS (SELECT 1 FROM public.shops s
                     WHERE s.id = promotions.shop_id AND s.user_id = auth.uid()))
  WITH CHECK (source = 'owner_defined');

CREATE POLICY promotions_owner_delete_owner_defined ON public.promotions
  FOR DELETE TO authenticated
  USING (source = 'owner_defined'
         AND EXISTS (SELECT 1 FROM public.shops s
                     WHERE s.id = promotions.shop_id AND s.user_id = auth.uid()));

COMMENT ON COLUMN public.promotions.source IS
  'owner_defined: owner-authored code via PromotionsScreen. loyalty: trigger-generated on Nth completed booking. recovery: helper-generated by enqueue_booking_reminder. Phase 13.';
COMMENT ON COLUMN public.promotions.target_user_id IS
  'Set only for source in (loyalty, recovery). Silent codes restricted to this client.';
COMMENT ON COLUMN public.promotions.archived_at IS
  'Soft-delete timestamp. NULL = active. Set by archive_promo flow; lets the partial-unique index free up code text for re-issue.';
```

### 2. `20260606000100_loyalty_rules_table.sql`

New `loyalty_rules` table per RESEARCH §9 lines 719–739. One active rule per shop enforced by partial unique index. RLS owner-only.

```sql
CREATE TABLE IF NOT EXISTS public.loyalty_rules (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id             UUID NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
  trigger_visit_count INT NOT NULL CHECK (trigger_visit_count BETWEEN 2 AND 50),
  discount_type       TEXT NOT NULL CHECK (discount_type IN ('percentage','fixed')),
  discount_value      NUMERIC(12,2) NOT NULL CHECK (discount_value > 0),
  is_active           BOOLEAN NOT NULL DEFAULT TRUE,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS loyalty_rules_one_active_per_shop
  ON public.loyalty_rules (shop_id) WHERE is_active = TRUE;

CREATE INDEX IF NOT EXISTS idx_loyalty_rules_shop
  ON public.loyalty_rules (shop_id);

ALTER TABLE public.loyalty_rules ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'loyalty_rules_owner_select') THEN
    CREATE POLICY loyalty_rules_owner_select ON public.loyalty_rules
      FOR SELECT TO authenticated
      USING (EXISTS (SELECT 1 FROM public.shops s
                     WHERE s.id = loyalty_rules.shop_id AND s.user_id = auth.uid()));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'loyalty_rules_owner_write') THEN
    CREATE POLICY loyalty_rules_owner_write ON public.loyalty_rules
      FOR ALL TO authenticated
      USING (EXISTS (SELECT 1 FROM public.shops s
                     WHERE s.id = loyalty_rules.shop_id AND s.user_id = auth.uid()))
      WITH CHECK (EXISTS (SELECT 1 FROM public.shops s
                          WHERE s.id = loyalty_rules.shop_id AND s.user_id = auth.uid()));
  END IF;
END $$;

COMMENT ON TABLE public.loyalty_rules IS
  'Per-shop loyalty config. One active row per shop (partial unique index). Every Nth completed booking issues a one-shot loyalty code via the bookings trigger. Phase 13.';
```

### 3. `20260606000200_widen_redeem_promotion_for_guests.sql`

Reuse the existing `redeem_promotion` RPC; widen its signature to accept `p_guest_profile_id`. REVOKE the `GRANT EXECUTE TO authenticated` (RESEARCH §18 lines 993–1009 — dead code from client side; webhooks use service_role). The function body is COPIED verbatim from the existing 20260604000400 file with one INSERT shape change (add `guest_profile_id` to the column list and parameter list).

```sql
-- Phase 13: widen redeem_promotion to accept guest_profile_id. Body is
-- byte-for-byte the existing 20260604000400_redeem_promotion.sql shape
-- with one VALUES tuple addition. CREATE OR REPLACE preserves the OID.

CREATE OR REPLACE FUNCTION public.redeem_promotion(
  p_promotion_id     UUID,
  p_booking_id       UUID,
  p_user_id          UUID,
  p_discount_amount  NUMERIC,
  p_guest_profile_id UUID DEFAULT NULL
) RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $function$
DECLARE
  v_redemption_id UUID;
  v_promotion     RECORD;
BEGIN
  -- NULL shape validation (no side effects; precedes authz).
  IF p_promotion_id IS NULL OR p_booking_id IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'PROMOTION_OR_BOOKING_NULL';
  END IF;

  -- At-most-one identity (the table's CHECK also enforces this).
  IF p_user_id IS NOT NULL AND p_guest_profile_id IS NOT NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'AT_MOST_ONE_OF_USER_OR_GUEST';
  END IF;

  -- Atomic insert; rely on UNIQUE(promotion_id, booking_id) for idempotency.
  INSERT INTO public.promotion_redemptions (
    promotion_id, booking_id, user_id, guest_profile_id, discount_amount, redeemed_at
  ) VALUES (
    p_promotion_id, p_booking_id, p_user_id, p_guest_profile_id, p_discount_amount, now()
  )
  ON CONFLICT (promotion_id, booking_id) DO NOTHING
  RETURNING id INTO v_redemption_id;

  -- If the conflict path fired, fetch the existing redemption id.
  IF v_redemption_id IS NULL THEN
    SELECT id INTO v_redemption_id FROM public.promotion_redemptions
    WHERE promotion_id = p_promotion_id AND booking_id = p_booking_id;
    RETURN v_redemption_id;  -- idempotent no-op.
  END IF;

  -- Counter bump.
  UPDATE public.promotions
  SET usage_count = COALESCE(usage_count, 0) + 1
  WHERE id = p_promotion_id;

  RETURN v_redemption_id;
END;
$function$;

-- REVOKE the broad authenticated grant (RESEARCH §18 lines 993-1009).
REVOKE ALL ON FUNCTION public.redeem_promotion(UUID, UUID, UUID, NUMERIC, UUID) FROM PUBLIC;
-- NOT GRANTed to authenticated. Webhooks call with service_role only.

COMMENT ON FUNCTION public.redeem_promotion(UUID, UUID, UUID, NUMERIC, UUID) IS
  'Phase 13: widened to accept guest_profile_id. Idempotent insert + counter bump. SECURITY DEFINER; service_role-only (revoked from authenticated to close the fabrication surface). O(1).';
```

### 4. `20260606000300_validate_and_apply_promo_rpc.sql`

The hot path for checkout. Read-only — no redemption row written until payment success. Called from `booking_confirmation_screen.dart` (a) on mount with `p_code = NULL` (auto-apply silent codes) and (b) on Apply tap with `p_code = <text>`. Returns `(promotion_id UUID, code TEXT, amount_off NUMERIC, new_total NUMERIC, source TEXT)`.

```sql
CREATE OR REPLACE FUNCTION public.validate_and_apply_promo(
  p_shop_id          UUID,
  p_code             TEXT,                 -- NULL → auto-apply silent code lookup
  p_user_id          UUID,                 -- caller's user_id; one of user/guest set
  p_guest_profile_id UUID,
  p_booking_total    NUMERIC,
  p_service_ids      UUID[] DEFAULT NULL   -- NULL = no service restriction check
) RETURNS TABLE (
  promotion_id  UUID,
  code          TEXT,
  amount_off    NUMERIC,
  new_total     NUMERIC,
  source        TEXT
)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $function$
DECLARE
  v_promo       RECORD;
  v_redeem_count INT;
  v_amount_off  NUMERIC;
BEGIN
  -- NULL shape (no side effects).
  IF p_shop_id IS NULL OR p_booking_total IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'SHOP_OR_TOTAL_NULL';
  END IF;
  IF p_user_id IS NULL AND p_guest_profile_id IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'CALLER_IDENTITY_REQUIRED';
  END IF;
  IF p_user_id IS NOT NULL AND p_guest_profile_id IS NOT NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'AT_MOST_ONE_OF_USER_OR_GUEST';
  END IF;

  -- Branch: silent auto-apply vs manual code entry.
  IF p_code IS NULL OR length(trim(p_code)) = 0 THEN
    -- Auto-apply: pick highest-discount silent code; tiebreak sooner-expiring.
    SELECT p.id, p.code, p.discount_type, p.discount_value, p.valid_to, p.source,
           p.service_restriction, p.min_booking_amount
    INTO v_promo
    FROM public.promotions p
    WHERE p.shop_id = p_shop_id
      AND p.source IN ('loyalty','recovery')
      AND p.archived_at IS NULL
      AND p.valid_to > now()
      AND COALESCE(p.target_user_id, p.target_guest_profile_id)
          = COALESCE(p_user_id, p_guest_profile_id)
      AND NOT EXISTS (
        SELECT 1 FROM public.promotion_redemptions r
        WHERE r.promotion_id = p.id
      )
    ORDER BY
      CASE WHEN p.discount_type = 'percentage'
           THEN LEAST(p_booking_total * p.discount_value / 100.0, p_booking_total)
           WHEN p.discount_type = 'fixed'
           THEN LEAST(p.discount_value, p_booking_total)
           ELSE 0
      END DESC,
      p.valid_to ASC
    LIMIT 1;
    IF NOT FOUND THEN RETURN; END IF;  -- empty result; no auto-apply.
  ELSE
    -- Manual entry: case-insensitive exact lookup on (shop_id, UPPER(code)).
    SELECT p.id, p.code, p.discount_type, p.discount_value, p.valid_from, p.valid_to,
           p.usage_limit, p.usage_count, p.per_client_max, p.min_booking_amount,
           p.service_restriction, p.source,
           p.target_user_id, p.target_guest_profile_id, p.is_active, p.archived_at
    INTO v_promo
    FROM public.promotions p
    WHERE p.shop_id = p_shop_id
      AND UPPER(p.code) = UPPER(trim(p_code))
      AND p.archived_at IS NULL;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'not_found'
        USING ERRCODE = '42501', HINT = 'CODE_NOT_FOUND';
    END IF;

    IF v_promo.is_active IS FALSE THEN
      RAISE EXCEPTION 'not_found'
        USING ERRCODE = '42501', HINT = 'CODE_NOT_FOUND';
    END IF;

    -- Validity window.
    IF v_promo.valid_from > now() OR v_promo.valid_to <= now() THEN
      RAISE EXCEPTION 'invalid_input'
        USING ERRCODE = '22023', HINT = 'CODE_EXPIRED';
    END IF;

    -- Global usage cap.
    IF v_promo.usage_limit IS NOT NULL
       AND COALESCE(v_promo.usage_count, 0) >= v_promo.usage_limit THEN
      RAISE EXCEPTION 'invalid_input'
        USING ERRCODE = '22023', HINT = 'CODE_LIMIT_REACHED';
    END IF;

    -- Per-client cap.
    SELECT COUNT(*) INTO v_redeem_count
    FROM public.promotion_redemptions r
    WHERE r.promotion_id = v_promo.id
      AND (
        (p_user_id IS NOT NULL AND r.user_id = p_user_id) OR
        (p_guest_profile_id IS NOT NULL AND r.guest_profile_id = p_guest_profile_id)
      );
    IF v_redeem_count >= v_promo.per_client_max THEN
      RAISE EXCEPTION 'invalid_input'
        USING ERRCODE = '22023', HINT = 'CODE_PER_CLIENT_MAX';
    END IF;

    -- Min booking amount.
    IF v_promo.min_booking_amount IS NOT NULL
       AND p_booking_total < v_promo.min_booking_amount THEN
      RAISE EXCEPTION 'invalid_input'
        USING ERRCODE = '22023', HINT = 'CODE_MIN_AMOUNT_NOT_MET';
    END IF;

    -- Service restriction.
    IF v_promo.service_restriction IS NOT NULL
       AND array_length(v_promo.service_restriction, 1) > 0 THEN
      IF p_service_ids IS NULL OR NOT (p_service_ids && v_promo.service_restriction) THEN
        RAISE EXCEPTION 'invalid_input'
          USING ERRCODE = '22023', HINT = 'CODE_SERVICE_NOT_ELIGIBLE';
      END IF;
    END IF;

    -- Wrong-client guard for silent codes that someone tries to type manually.
    IF v_promo.source IN ('loyalty','recovery') THEN
      IF COALESCE(v_promo.target_user_id, v_promo.target_guest_profile_id)
         <> COALESCE(p_user_id, p_guest_profile_id) THEN
        RAISE EXCEPTION 'invalid_input'
          USING ERRCODE = '22023', HINT = 'CODE_WRONG_CLIENT';
      END IF;
    END IF;
  END IF;

  -- Discount math. Server-authoritative; client treats as opaque.
  v_amount_off := CASE v_promo.discount_type
    WHEN 'percentage' THEN LEAST(p_booking_total * v_promo.discount_value / 100.0, p_booking_total)
    WHEN 'fixed'      THEN LEAST(v_promo.discount_value, p_booking_total)
    ELSE 0
  END;

  RETURN QUERY SELECT
    v_promo.id,
    v_promo.code,
    v_amount_off,
    GREATEST(p_booking_total - v_amount_off, 0),
    v_promo.source;
END;
$function$;

REVOKE ALL ON FUNCTION public.validate_and_apply_promo(UUID, TEXT, UUID, UUID, NUMERIC, UUID[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.validate_and_apply_promo(UUID, TEXT, UUID, UUID, NUMERIC, UUID[]) TO authenticated;

COMMENT ON FUNCTION public.validate_and_apply_promo(UUID, TEXT, UUID, UUID, NUMERIC, UUID[]) IS
  'Phase 13 checkout hot path. Read-only; no redemption row inserted. Branches on p_code: NULL → highest-discount silent code lookup (loyalty/recovery); TEXT → manual entry validation. Returns (promotion_id, code, amount_off, new_total, source) or raises 22023/HINT for typed-exception mapping. O(1) by partial unique indexes.';
```

### 5. `20260606000400_upsert_loyalty_rule_rpc.sql`

Owner-only RPC. Authz FIRST. Idempotent UPSERT on shop_id; flips the existing rule to `is_active=false` and inserts the new one. Wrapped in a single SAVEPOINT so the swap is atomic against the partial unique index.

```sql
CREATE OR REPLACE FUNCTION public.upsert_loyalty_rule(
  p_shop_id             UUID,
  p_trigger_visit_count INT,
  p_discount_type       TEXT,
  p_discount_value      NUMERIC,
  p_is_active           BOOLEAN DEFAULT TRUE
) RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $function$
DECLARE
  v_owns_shop BOOLEAN;
  v_rule_id   UUID;
BEGIN
  IF p_shop_id IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'SHOP_ID_NULL';
  END IF;

  -- Authz FIRST.
  SELECT EXISTS (
    SELECT 1 FROM public.shops
    WHERE id = p_shop_id AND user_id = auth.uid()
  ) INTO v_owns_shop;
  IF NOT v_owns_shop THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  -- Payload validation.
  IF p_trigger_visit_count IS NULL
     OR p_trigger_visit_count < 2 OR p_trigger_visit_count > 50 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'TRIGGER_VISIT_COUNT_OUT_OF_RANGE';
  END IF;
  IF p_discount_type NOT IN ('percentage','fixed') THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'INVALID_DISCOUNT_TYPE';
  END IF;
  IF p_discount_value IS NULL OR p_discount_value <= 0 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'DISCOUNT_VALUE_NOT_POSITIVE';
  END IF;
  IF p_discount_type = 'percentage' AND p_discount_value > 100 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'PERCENTAGE_OUT_OF_RANGE';
  END IF;

  -- Atomic swap: deactivate existing active rule for this shop, then insert.
  -- The partial unique index permits multiple is_active=false rows.
  UPDATE public.loyalty_rules
  SET is_active = FALSE, updated_at = now()
  WHERE shop_id = p_shop_id AND is_active = TRUE;

  IF p_is_active THEN
    INSERT INTO public.loyalty_rules (
      shop_id, trigger_visit_count, discount_type, discount_value, is_active
    ) VALUES (
      p_shop_id, p_trigger_visit_count, p_discount_type, p_discount_value, TRUE
    )
    RETURNING id INTO v_rule_id;
  END IF;

  RETURN v_rule_id;
END;
$function$;

REVOKE ALL ON FUNCTION public.upsert_loyalty_rule(UUID, INT, TEXT, NUMERIC, BOOLEAN) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.upsert_loyalty_rule(UUID, INT, TEXT, NUMERIC, BOOLEAN) TO authenticated;

COMMENT ON FUNCTION public.upsert_loyalty_rule(UUID, INT, TEXT, NUMERIC, BOOLEAN) IS
  'Phase 13 owner-facing loyalty rule upsert. Authz first. Deactivates existing active rule and inserts the new one atomically. SECURITY DEFINER with shops.user_id=auth.uid() gate. O(1).';
```

### 6. `20260606000500_generate_loyalty_code_helper.sql`

SECURITY DEFINER helper called from the bookings trigger (migration 8). Body per RESEARCH §4 lines 340–410. Idempotent via NOT EXISTS guard on unredeemed loyalty code for the (shop, client) pair. Loyalty code TTL is the no-expiry sentinel (`now() + INTERVAL '10 years'`) per RESEARCH §4 lines 427–430.

```sql
CREATE OR REPLACE FUNCTION public.generate_loyalty_code(
  p_shop_id          UUID,
  p_user_id          UUID,
  p_guest_profile_id UUID
) RETURNS TEXT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE
  v_rule       RECORD;
  v_existing   TEXT;
  v_new_code   TEXT;
BEGIN
  IF p_user_id IS NULL AND p_guest_profile_id IS NULL THEN
    RETURN NULL;
  END IF;

  -- Look up the shop's active loyalty rule.
  SELECT discount_type, discount_value, trigger_visit_count INTO v_rule
  FROM public.loyalty_rules
  WHERE shop_id = p_shop_id AND is_active = TRUE;
  IF NOT FOUND THEN RETURN NULL; END IF;

  -- Idempotency: return existing unredeemed loyalty code if any.
  SELECT code INTO v_existing FROM public.promotions
  WHERE shop_id = p_shop_id
    AND source = 'loyalty'
    AND archived_at IS NULL
    AND COALESCE(target_user_id, target_guest_profile_id)
        = COALESCE(p_user_id, p_guest_profile_id)
    AND NOT EXISTS (
      SELECT 1 FROM public.promotion_redemptions r
      WHERE r.promotion_id = promotions.id
    )
  ORDER BY created_at DESC LIMIT 1;
  IF FOUND THEN RETURN v_existing; END IF;

  -- Generate. Format: LOYAL + 6 base32-ish chars (UUID-derived, uppercase
  -- alphanumeric). Total 11 chars; fits the [A-Z0-9]{3,20} server regex.
  v_new_code := upper('LOYAL' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 6));

  INSERT INTO public.promotions (
    shop_id, name, code, discount_type, discount_value,
    valid_from, valid_to, usage_limit, is_active,
    source, target_user_id, target_guest_profile_id, per_client_max
  ) VALUES (
    p_shop_id, 'Loyalty reward', v_new_code,
    v_rule.discount_type, v_rule.discount_value,
    now(), now() + INTERVAL '10 years', 1, TRUE,
    'loyalty', p_user_id, p_guest_profile_id, 1
  );

  RETURN v_new_code;
END;
$function$;

REVOKE ALL ON FUNCTION public.generate_loyalty_code(UUID, UUID, UUID) FROM PUBLIC;
-- NOT GRANTed to authenticated. Trigger-only.

COMMENT ON FUNCTION public.generate_loyalty_code(UUID, UUID, UUID) IS
  'Phase 13 internal helper. Issues a one-shot loyalty promo code for a (shop, client) pair using the shop active loyalty_rule. Idempotent (reuses existing unredeemed code). TTL is the no-expiry sentinel (now()+10y). SECURITY DEFINER; trigger-only. O(1).';
```

### 7. `20260606000600_generate_recovery_code_helper.sql`

SECURITY DEFINER helper called from `enqueue_booking_reminder` (migration 9). Body per RESEARCH §5 lines 490–550. Discount kind/value reused from shop's active loyalty rule; if no rule, return NULL and the recovery_checkin message stays text-only (LOCKED per planner brief, contradicting RESEARCH §5 line 528's hardcoded-10% fallback).

```sql
CREATE OR REPLACE FUNCTION public.generate_recovery_code(
  p_shop_id          UUID,
  p_user_id          UUID,
  p_guest_profile_id UUID
) RETURNS TEXT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE
  v_rule_type  TEXT;
  v_rule_value NUMERIC;
  v_existing   TEXT;
  v_new_code   TEXT;
BEGIN
  IF p_user_id IS NULL AND p_guest_profile_id IS NULL THEN
    RETURN NULL;
  END IF;

  -- Idempotency: reuse a still-valid unredeemed recovery code if one exists.
  SELECT code INTO v_existing FROM public.promotions
  WHERE shop_id = p_shop_id
    AND source = 'recovery'
    AND archived_at IS NULL
    AND valid_to > now()
    AND COALESCE(target_user_id, target_guest_profile_id)
        = COALESCE(p_user_id, p_guest_profile_id)
    AND NOT EXISTS (
      SELECT 1 FROM public.promotion_redemptions r
      WHERE r.promotion_id = promotions.id
    )
  ORDER BY created_at DESC LIMIT 1;
  IF FOUND THEN RETURN v_existing; END IF;

  -- Look up the shop's active loyalty rule. If absent, return NULL and let
  -- the caller (enqueue_booking_reminder) compose a text-only message.
  -- LOCKED decision per planner brief — no hardcoded fallback discount.
  SELECT discount_type, discount_value INTO v_rule_type, v_rule_value
  FROM public.loyalty_rules WHERE shop_id = p_shop_id AND is_active = TRUE;
  IF NOT FOUND THEN
    RETURN NULL;
  END IF;

  v_new_code := upper('RECOVER' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 5));

  INSERT INTO public.promotions (
    shop_id, name, code, discount_type, discount_value,
    valid_from, valid_to, usage_limit, is_active,
    source, target_user_id, target_guest_profile_id, per_client_max
  ) VALUES (
    p_shop_id, 'Recovery offer', v_new_code,
    v_rule_type, v_rule_value,
    now(), now() + INTERVAL '30 days', 1, TRUE,
    'recovery', p_user_id, p_guest_profile_id, 1
  );

  RETURN v_new_code;
END;
$function$;

REVOKE ALL ON FUNCTION public.generate_recovery_code(UUID, UUID, UUID) FROM PUBLIC;

COMMENT ON FUNCTION public.generate_recovery_code(UUID, UUID, UUID) IS
  'Phase 13 internal helper. Issues a 30-day recovery promo code for a (shop, client) pair. Discount kind/value reuse the shop active loyalty_rule; returns NULL when no rule (recovery_checkin message stays text-only). Idempotent. SECURITY DEFINER; called only from enqueue_booking_reminder. O(1).';
```

### 8. `20260606000700_booking_loyalty_trigger.sql`

AFTER UPDATE OF status ON bookings, WHEN (NEW.status = 'completed'). Counts the client's completed bookings at this shop; fires `generate_loyalty_code` on `count % trigger_visit_count = 0`. Idempotent via the helper's NOT EXISTS guard. Per RESEARCH §4 line 426 (loyalty trigger fires AFTER the status UPDATE; cancel_and_followup PERFORM runs later — zero ordering conflict with Phase 12's `trg_bookings_schedule_reminders` because that trigger's WHEN clause restricts it to the confirmed transition).

```sql
CREATE OR REPLACE FUNCTION public.handle_booking_completion_for_loyalty()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp
AS $function$
DECLARE
  v_rule         RECORD;
  v_visit_count  INTEGER;
BEGIN
  -- Re-mark-as-completed: no-op.
  IF TG_OP = 'UPDATE' AND OLD.status = 'completed' THEN
    RETURN NEW;
  END IF;

  -- Look up the shop's active loyalty rule.
  SELECT trigger_visit_count INTO v_rule
  FROM public.loyalty_rules
  WHERE shop_id = NEW.shop_id AND is_active = TRUE;
  IF NOT FOUND THEN RETURN NEW; END IF;

  -- Count the client's completed bookings at this shop (including this one).
  SELECT COUNT(*) INTO v_visit_count
  FROM public.bookings b
  WHERE b.shop_id = NEW.shop_id
    AND b.status = 'completed'
    AND (
      (NEW.user_id IS NOT NULL AND b.user_id = NEW.user_id) OR
      (NEW.guest_profile_id IS NOT NULL AND b.guest_profile_id = NEW.guest_profile_id)
    );

  -- Threshold check. visit_count is 1-indexed (this completion counted).
  -- Fires when count is an exact multiple of trigger_visit_count — i.e. on
  -- every Nth completion, reward the next booking.
  IF v_visit_count % v_rule.trigger_visit_count <> 0 THEN
    RETURN NEW;
  END IF;

  -- Helper is idempotent (NOT EXISTS guard on unredeemed loyalty code).
  PERFORM public.generate_loyalty_code(NEW.shop_id, NEW.user_id, NEW.guest_profile_id);

  RETURN NEW;
END;
$function$;

DROP TRIGGER IF EXISTS trg_bookings_loyalty_visit ON public.bookings;
CREATE TRIGGER trg_bookings_loyalty_visit
  AFTER UPDATE OF status ON public.bookings
  FOR EACH ROW
  WHEN (NEW.status = 'completed')
  EXECUTE FUNCTION public.handle_booking_completion_for_loyalty();

COMMENT ON FUNCTION public.handle_booking_completion_for_loyalty() IS
  'Phase 13: AFTER UPDATE OF status trigger body. Fires only on the completed transition. Idempotent via generate_loyalty_code NOT EXISTS guard. Non-overlapping WHEN clause with trg_bookings_schedule_reminders (confirmed-only). O(client_completed_bookings_at_shop).';
```

### 9. `20260606000800_patch_enqueue_booking_reminder_for_recovery_code.sql`

CREATE OR REPLACE the Phase 12 `enqueue_booking_reminder` helper. The function body is COPIED verbatim from `20260605130400_enqueue_booking_reminder_helper.sql` with three insertions per RESEARCH §5 lines 444–484:

1. New local `v_recovery_code TEXT;` declared.
2. Before the `v_template` / `v_body` CASE construction, conditional call: `IF p_type = 'recovery_checkin' THEN v_recovery_code := public.generate_recovery_code(v_booking.shop_id, v_booking.user_id, v_booking.guest_profile_id); END IF;`.
3. The WhatsApp template variable selection switches `_v1` → `_v2` for `recovery_checkin` only:

```sql
v_template := CASE p_type
  WHEN 'recovery_checkin' THEN 'recovery_checkin_v2'
  ELSE p_type::text || '_v1'
END;
```

4. The `whatsapp_params` jsonb_build_object adds `{{3}}` when the code is non-null:

```sql
CASE WHEN v_channel = 'whatsapp'
     THEN CASE WHEN p_type = 'recovery_checkin' AND v_recovery_code IS NOT NULL
               THEN jsonb_build_object('1', v_client_name, '2', v_shop_name, '3', v_recovery_code)
               ELSE jsonb_build_object('1', v_client_name, '2', v_shop_name)
          END
     ELSE NULL END,
```

5. The push body for recovery_checkin gets a code suffix when present:

```sql
WHEN 'recovery_checkin' THEN
  'We noticed your last appointment at ' || v_shop_name || ' didn''t happen. ' ||
  CASE WHEN v_recovery_code IS NOT NULL
       THEN 'Use code ' || v_recovery_code || ' for a discount on your next booking.'
       ELSE 'Book a new time whenever works for you.'
  END
```

Everything else in the function body — channel branching, the other four notification types, the `INSERT INTO scheduled_notifications` shape, the REVOKE/COMMENT trio — is byte-for-byte unchanged. The executor copies the original body, makes the five surgical edits, and writes the result. No other Phase 12 callers are affected because all five categories still receive their original message shape; only `recovery_checkin` changes.

(Full body omitted for length — the executor reads `20260605130400_enqueue_booking_reminder_helper.sql` and applies the five documented edits.)

## Tasks

Atomic. Each touches ≤ 3 files unless explicitly justified inline. Each maps to ≥ 1 acceptance test in the Verification matrix. Estimates in minutes.

### Wave 0 — Schema groundwork (pre-flight gated)

**Task 0.0 — Run pre-flight checks**
- File(s): n/a (operational, staging then prod).
- Description: Execute the five SELECT queries in §Pre-flight checks against staging then prod. Capture output in PR description. **BLOCK migration deployment if check 4 returns any rows.**
- Acceptance: All five queries return the expected shape per §Pre-flight checks. Check 4 returns zero rows on dev DB (verified 2026-06-06) and on prod (re-run within 1h of deploy). Outputs pasted into PR description.
- Rollback: n/a.
- Estimate: 15

**Task 0.1 — Extend `promotions` + `promotion_redemptions` schema**
- File(s): `supabase/migrations/20260606000000_extend_promotions_for_phase13.sql` (NEW)
- Description: Per Migration Plan §1. Seven discrete operations: (a) widen `valid_from / valid_to` to TIMESTAMPTZ when DATE; (b) seven `ADD COLUMN IF NOT EXISTS`; (c) XOR CHECK constraint on `(source, target_user_id, target_guest_profile_id)`; (d) drop global `promotions_code_key`, replace with per-shop partial-unique on `(shop_id, UPPER(code)) WHERE archived_at IS NULL`; (e) silent-target unique index; (f) `promotion_redemptions.user_id` made nullable, `guest_profile_id` added, identity CHECK + two indexes; (g) RLS policies replaced (drop `promotions_owner_all`, add four scoped policies — select-all-owner, write-owner-defined, update-owner-defined, delete-owner-defined).
- Acceptance: `\d public.promotions` shows seven new columns + the XOR CHECK. `SELECT indexname FROM pg_indexes WHERE tablename='promotions'` includes both `promotions_shop_code_unique` and `promotions_silent_target_uniq`. `SELECT polname FROM pg_policies WHERE tablename='promotions'` returns exactly 4 rows. `\d public.promotion_redemptions` shows `guest_profile_id` and `user_id` nullable. Smoke §A (per-shop UNIQUE swap) passes.
- Rollback: Reverse migration is non-trivial (RLS policies, constraint swap). Document: revert by `DROP INDEX promotions_silent_target_uniq, promotions_shop_code_unique; ALTER TABLE promotions ADD CONSTRAINT promotions_code_key UNIQUE (code);` ONLY if zero new system-generated codes exist. If they do, archive them first.
- Estimate: 45

**Task 0.2 — Create `loyalty_rules` table + RLS + partial unique**
- File(s): `supabase/migrations/20260606000100_loyalty_rules_table.sql` (NEW)
- Description: Per Migration Plan §2. Table + two indexes (partial-unique on active rule + flat index on shop_id) + RLS owner-only.
- Acceptance: `\d public.loyalty_rules` shows the seven columns + CHECKs. `SELECT polname FROM pg_policies WHERE tablename='loyalty_rules'` returns 2 rows. Inserting a second `is_active=TRUE` row for the same shop fails with unique violation. Smoke §G (loyalty_rules RLS) passes.
- Rollback: `DROP TABLE public.loyalty_rules CASCADE`. Safe — no production data depended on it before Phase 13.
- Estimate: 25

**Task 0.3 — REVOKE direct `redeem_promotion` GRANT (defensive isolation before Wave 1 widens signature)**
- File(s): None (operational, part of `20260606000200_widen_redeem_promotion_for_guests.sql` in Task 1.1).
- Description: The REVOKE lives inside the Wave 1 migration that widens the RPC signature (see Task 1.1). Splitting them risks an orphaned grant on the old signature. Acceptance asserts post-Wave 1 state.
- Acceptance: After Wave 1: `SELECT has_function_privilege('authenticated', 'public.redeem_promotion(UUID,UUID,UUID,NUMERIC,UUID)', 'EXECUTE')` returns `false`. `grep -rn 'redeem_promotion' lib/` returns the existing single dead caller at `promotions_repository.dart:122` only.
- Estimate: (covered in Task 1.1)

### Wave 1 — Server logic (depends on Wave 0)

**Task 1.1 — Widen `redeem_promotion` to accept `guest_profile_id`, REVOKE authenticated GRANT**
- File(s): `supabase/migrations/20260606000200_widen_redeem_promotion_for_guests.sql` (NEW)
- Description: Per Migration Plan §3. CREATE OR REPLACE keeps the OID. Body byte-for-byte the existing `20260604000400_redeem_promotion.sql` shape with one INSERT-shape addition (`guest_profile_id` in column list + parameter). REVOKE the authenticated grant.
- Acceptance: `\df+ public.redeem_promotion` shows 5 parameters (was 4). `has_function_privilege('authenticated', ...)` returns false. Smoke §H (record_promo_redemption idempotency under guest path) passes.
- Rollback: Re-grant + revert to the 4-arg signature in a follow-up migration. The dead `promotions_repository.dart:122` caller is unaffected.
- Estimate: 30

**Task 1.2 — Create `validate_and_apply_promo` RPC**
- File(s): `supabase/migrations/20260606000300_validate_and_apply_promo_rpc.sql` (NEW)
- Description: Per Migration Plan §4. Authz: null-shape FIRST (no side effects), then identity validation. Branches on `p_code IS NULL` → silent auto-apply lookup; else manual entry with seven checks (existence, validity window, usage cap, per-client cap, min amount, service restriction, wrong-client). HINT codes: `CODE_NOT_FOUND`, `CODE_EXPIRED`, `CODE_LIMIT_REACHED`, `CODE_PER_CLIENT_MAX`, `CODE_MIN_AMOUNT_NOT_MET`, `CODE_SERVICE_NOT_ELIGIBLE`, `CODE_WRONG_CLIENT`. Discount math at the end; returns `(promotion_id, code, amount_off, new_total, source)`. GRANTed to authenticated.
- Acceptance: Smoke §B (manual happy path), §C (expired rejection), §D (per-client cap), §E (service restriction), §F (auto-apply silent code) all print `OK:`. `EXPLAIN ANALYZE SELECT * FROM validate_and_apply_promo(...)` against a shop with 1000 active codes completes in <100ms. `flutter test test/.../validate_and_apply_promo_test.dart` HINT-mapping cases pass.
- Rollback: `DROP FUNCTION public.validate_and_apply_promo(UUID, TEXT, UUID, UUID, NUMERIC, UUID[])`.
- Estimate: 70

**Task 1.3 — Create `upsert_loyalty_rule` RPC**
- File(s): `supabase/migrations/20260606000400_upsert_loyalty_rule_rpc.sql` (NEW)
- Description: Per Migration Plan §5. Authz FIRST. Atomic deactivate-then-insert against the partial unique index. HINT codes: `TRIGGER_VISIT_COUNT_OUT_OF_RANGE`, `INVALID_DISCOUNT_TYPE`, `DISCOUNT_VALUE_NOT_POSITIVE`, `PERCENTAGE_OUT_OF_RANGE`.
- Acceptance: Smoke §G (owner can upsert, non-owner gets 42501, percentage > 100 rejected). `flutter test test/.../loyalty_rule_test.dart` cases pass.
- Rollback: `DROP FUNCTION public.upsert_loyalty_rule(UUID, INT, TEXT, NUMERIC, BOOLEAN)`.
- Estimate: 35

**Task 1.4 — Create `generate_loyalty_code` SECURITY DEFINER helper**
- File(s): `supabase/migrations/20260606000500_generate_loyalty_code_helper.sql` (NEW)
- Description: Per Migration Plan §6. NOT EXISTS guard for idempotency. Code format `LOYAL + 6 base32 chars`. TTL = `now() + INTERVAL '10 years'` (no-expiry sentinel). Returns the code text, or NULL when shop has no active rule. Trigger-only — not GRANTed to authenticated.
- Acceptance: Smoke §I (loyalty trigger idempotency) passes — calling the trigger twice for the same client at the same shop generates exactly one code. `has_function_privilege('authenticated', 'public.generate_loyalty_code(UUID,UUID,UUID)', 'EXECUTE')` returns false.
- Rollback: `DROP FUNCTION public.generate_loyalty_code(UUID, UUID, UUID) CASCADE` (CASCADE removes the trigger function dependency too).
- Estimate: 30

**Task 1.5 — Create `generate_recovery_code` SECURITY DEFINER helper**
- File(s): `supabase/migrations/20260606000600_generate_recovery_code_helper.sql` (NEW)
- Description: Per Migration Plan §7. NOT EXISTS guard for idempotency. Discount kind/value pulled from shop's active loyalty_rule; returns NULL if no rule (recovery_checkin stays text-only per planner brief). Code format `RECOVER + 5 base32 chars`. TTL = `now() + INTERVAL '30 days'`. Trigger/helper-only — not GRANTed.
- Acceptance: Smoke §J (recovery code generation on enqueue_booking_reminder) passes. Calling twice within the 30d window returns the same code. With no active loyalty rule, returns NULL.
- Rollback: `DROP FUNCTION public.generate_recovery_code(UUID, UUID, UUID)`.
- Estimate: 30

**Task 1.6 — AFTER UPDATE OF status trigger on `bookings`**
- File(s): `supabase/migrations/20260606000700_booking_loyalty_trigger.sql` (NEW)
- Description: Per Migration Plan §8. WHEN clause restricts to `NEW.status = 'completed'`; skips re-completions. Counts client's completed bookings at shop; fires `generate_loyalty_code` on multiples of `trigger_visit_count`. Trigger naming `trg_bookings_loyalty_visit` matches Phase 12's `trg_bookings_*` convention.
- Acceptance: Smoke §I prints `OK:` (insert N=6 completed bookings, after the 6th a `source='loyalty'` row appears with target set; calling `mark_booking_complete` again — already-completed transition — generates no new row). Trigger has WHEN clause that excludes the confirmed transition (verified via `SELECT pg_get_triggerdef(oid) FROM pg_trigger WHERE tgname='trg_bookings_loyalty_visit'`).
- Rollback: `DROP TRIGGER trg_bookings_loyalty_visit ON public.bookings; DROP FUNCTION public.handle_booking_completion_for_loyalty()`.
- Estimate: 40

**Task 1.7 — Patch `enqueue_booking_reminder` for recovery code**
- File(s): `supabase/migrations/20260606000800_patch_enqueue_booking_reminder_for_recovery_code.sql` (NEW)
- Description: Per Migration Plan §9. CREATE OR REPLACE the Phase 12 helper. Copy the original body verbatim from `20260605130400_enqueue_booking_reminder_helper.sql`; apply the five surgical edits documented in Migration Plan §9 (new `v_recovery_code` local, conditional call, `_v1`→`_v2` template switch, `{{3}}` whatsapp param, push body concat). All other four notification categories unchanged.
- Acceptance: Smoke §J prints `OK:` — calling the helper with `p_type='recovery_checkin'` (a) generates a recovery code via the helper from Task 1.5, (b) inserts a row with `whatsapp_template = 'recovery_checkin_v2'`, (c) `whatsapp_params` includes key `'3'` with the code text, (d) push body for registered users includes "Use code <CODE> for a discount". Calling with any other type (`booking_reminder_24h`, `rebook_nudge`, etc.) leaves the row shape byte-for-byte unchanged from Phase 12. `diff` test: extract the function body, scrub the five documented diff regions, `diff` against the Phase 12 body → only documented diff regions appear.
- Rollback: Re-apply the original Phase 12 helper migration (CREATE OR REPLACE overwrites). The new `recovery_checkin_v2` template in Meta keeps working as long as Phase 13 helpers remain; the Phase 12 `_v1` switch is single-line.
- Estimate: 50

### Wave 2 — Phase 12 integration (depends on Wave 1)

**Task 2.1 — Payment controller passes `promotionId`**
- File(s): `lib/payment/presentation/controllers/payment_controller.dart`
- Description: Add `String? promotionId` as an optional parameter to `processPayment` (line 90 region). Add `'promotionId': promotionId` to the `requestBody` JSONB (line 123 region). Both edits are additive — when null, the request body shape is byte-for-byte equivalent to today's call.
- Acceptance: `flutter analyze` clean. Existing callers (no `promotionId` arg) compile unchanged. New checkout call in Task 4.1 passes `promotionId`.
- Rollback: Revert the two-line diff.
- Estimate: 15

**Task 2.2 — Webhook patches: read `promotionId` from booking_data, call `redeem_promotion`**
- File(s): `supabase/functions/paystack-webhook/index.ts`, `supabase/functions/stripe-webhook/index.ts`, `supabase/functions/verify-payment/index.ts`
- Description: After each `console.log('✅ Booking created...', booking.id)` line (per RESEARCH §3 lines 280–283), insert the redemption call:
  ```ts
  if (bookingData.promotionId) {
    const { error: redeemError } = await supabase.rpc('redeem_promotion', {
      p_promotion_id: bookingData.promotionId,
      p_booking_id: booking.id,
      p_user_id: booking.user_id,
      p_guest_profile_id: booking.guest_profile_id,
      p_discount_amount: bookingData.promoAmountOff ?? 0,
    });
    if (redeemError) console.error('⚠️ promo redemption failed (non-fatal):', redeemError);
  }
  ```
  Paystack webhook has TWO booking-insert paths (guest at line ~170, registered at line ~470 region) — apply both. Stripe webhook has one (line 242 region). Verify-payment has one (line 189 region). FOUR insertion points total.
  
  **Why this Task touches 3 files:** All three webhooks are the same pattern; splitting them adds zero clarity and triples the PR-review burden. The diff is mechanically identical at four insertion points.
- Acceptance: `grep -rn "rpc('redeem_promotion'" supabase/functions/` returns at least 4 (one paystack guest, one paystack registered, one stripe, one verify-payment). Manual UAT step 2 (Task 6.2) confirms a real promo redemption inserts a row in `promotion_redemptions` after webhook fires. `deno check` clean on all three files.
- Rollback: `git revert` the three-file commit. Loyalty redemption stops being recorded; existing redemptions stay forensically.
- Estimate: 45

### Wave 3 — Owner UI (depends on Wave 0 schema + Wave 1 RPCs)

**Task 3.1 — Extend `PromotionException` hierarchy with six new subtypes**
- File(s): `lib/presentation/features/shops/dashboard/data/exceptions/promotion_exceptions.dart`
- Description: ADD six subtypes to the EXISTING file (no new `promo_exceptions.dart` per RESEARCH §17). Each subtype carries a stable `code` and sanitized `userMessage`:
  - `PromoExpiredException` → `PROMO_EXPIRED`, "This code has expired or isn't yet active."
  - `PromoMinAmountNotMetException` → `PROMO_MIN_AMOUNT`, "Your booking total is below the minimum for this code."
  - `PromoServiceNotEligibleException` → `PROMO_SERVICE_RESTRICTION`, "This code doesn't apply to the selected service."
  - `PromoPerClientMaxException` → `PROMO_PER_CLIENT_MAX`, "You've already used this code the maximum number of times."
  - `PromoWrongClientException` → `PROMO_WRONG_CLIENT`, "This code isn't valid for your account."
  - `LoyaltyRuleSaveFailedException` → `LOYALTY_SAVE_FAILED`, "We couldn't save the loyalty rule. Please try again."
  Constructor pattern mirrors the existing four subtypes in the file. `message` may include identifiers; `userMessage` is render-safe.
- Acceptance: `flutter test test/.../promotion_exceptions_test.dart` passes the new cases (Task 5.1). `flutter analyze` clean. Existing four subtypes remain unmodified (`git diff` shows additive-only edits below line 65).
- Estimate: 20

**Task 3.2 — Extend `Promotion` model + `PromotionsRepository`**
- File(s): `lib/presentation/features/shops/dashboard/data/models/promotion_model.dart`, `lib/presentation/features/shops/dashboard/data/repositories/promotions_repository.dart`
- Description: Add nullable fields to `Promotion` model: `source`, `targetUserId`, `targetGuestProfileId`, `perClientMax`, `minBookingAmount`, `serviceRestriction` (List<String>?), `archivedAt`. Update `fromJson` to read them safely (default `source = 'owner_defined'`, `perClientMax = 1`). Update `toJson` for completeness. **Existing fields untouched** — every existing serialization path keeps working. In `PromotionsRepository`, ADD three methods with HINT-based exception mapping mirroring the existing `incrementUsage` pattern at lines 130–148:
  - `validateAndApplyPromo({shopId, code (nullable), userId (nullable), guestProfileId (nullable), bookingTotal, serviceIds (nullable)}) → Future<({String promotionId, String code, double amountOff, double newTotal, String source})?>`. Returns null when called with `code = null` and no silent code exists. Maps HINT → exception per the RPC's HINT codes. Empty result with non-null code → throw `PromotionNotFoundException`.
  - `getLoyaltyRule({shopId}) → Future<LoyaltyRuleDTO?>` — `.from('loyalty_rules').select('*').eq('shop_id', shopId).eq('is_active', true).maybeSingle()`.
  - `upsertLoyaltyRule({shopId, triggerVisitCount, discountType, discountValue, isActive}) → Future<String>` — RPC call; HINT mapping → `LoyaltyRuleSaveFailedException` for the unknown error path; `PromoWrongClientException` is N/A for this RPC; `42501 → PromotionNotFoundException`; other 22023 hints map to the existing `InvalidDiscountAmountException` family or `LoyaltyRuleSaveFailedException` as the fallback.
- Acceptance: `grep -n "e\\.toString()\\.contains" lib/.../promotions_repository.dart` returns 0. `flutter analyze` clean. Task 5.2 repository unit tests pass — at least one HINT → exception case per added method. Existing JSON round-trip on the unmodified fields still passes (no regression).
- Estimate: 65

**Task 3.3 — `LoyaltyRuleDTO` + provider + screen**
- File(s): `lib/presentation/features/shops/dashboard/data/models/loyalty_rule_dto.dart` (NEW), `lib/presentation/features/shops/dashboard/providers/loyalty_rule_provider.dart` (NEW), `lib/presentation/features/shops/dashboard/presentation/screens/loyalty_rule_screen.dart` (NEW)
- Description: DTO mirrors the existing `promotion_model.dart` shape (`fromJson` / `toJson`, immutable, no Equatable). Provider is a `FutureProvider.family<LoyaltyRuleDTO?, String>` keyed by `shopId`. Screen pattern follows the Phase 12 `ClientStickyNoteCard` precedent — explicit Save button, NO debounce/autosave. Form fields: trigger visit count (numeric stepper 2-50), discount type (segmented control: percentage/fixed), discount value (numeric input), is_active (Switch). On Save: catches `LoyaltyRuleSaveFailedException` + the `InvalidDiscountAmountException` family and surfaces `userMessage` via `Snackbar.error`. On success: `Snackbar.success` + `ref.invalidate(loyaltyRuleProvider(shopId))`.
  
  **Why this Task touches 3 files:** Single feature unit; splitting into separate DTO/provider/screen tasks triples the round-trip without changing the diff surface.
- Acceptance: `flutter analyze` clean. `grep -n 'debounce\\|Timer.periodic\\|onChanged.*upsert' lib/.../loyalty_rule_screen.dart` returns 0 (no autosave). Manual UAT step 4 (Task 6.2) confirms the form persists and round-trips.
- Estimate: 75

**Task 3.4 — Extend `CreatePromotionScreen` + `PromotionsScreen` + `tools_screen.dart` routing**
- File(s): `lib/presentation/features/shops/dashboard/presentation/screens/create_promotion_screen.dart`, `lib/presentation/features/shops/dashboard/presentation/screens/promotions_screen.dart`, `lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart`
- Description: 
  - `create_promotion_screen.dart`: add four form fields below the existing block — `per_client_max` (numeric stepper, default 1), `min_booking_amount` (currency input, nullable), `service_restriction` (multi-select dropdown of the shop's appointment_slots, nullable), `archived_at` (only visible in edit mode for existing codes — Switch that submits a null↔now() toggle). Submit body includes the new fields; null-pass when unset to preserve the existing endpoint shape.
  - `promotions_screen.dart`: add a `source` badge to each list row (Owner / Loyalty / Recovery). Filter `source IN ('loyalty', 'recovery')` rows by default — show a "Show system codes" toggle in the app bar for debugging.
  - `tools_screen.dart`: add one new Tools card next to the existing Promotions card, routing to `LoyaltyRuleScreen(shopId: shopId)`. Title "Loyalty rule"; subtitle "Reward every Nth completed booking".
  
  **Why this Task touches 3 files:** Three UI surfaces, one shipping feature ("system codes integration with owner UI"). Splitting fractures the screen-level user story across PRs.
- Acceptance: Manual UAT step 5 (Task 6.2) confirms (a) owner can set per-client-max=1 on a new code, (b) silent codes are hidden by default in the list and visible when toggled, (c) Tools tab shows the new Loyalty card. `flutter analyze` clean.
- Estimate: 70

### Wave 4 — Checkout integration (depends on Wave 1 RPCs + Wave 2 controller)

**Task 4.1 — `ClientPromoCodeField` widget + checkout integration**
- File(s): `lib/presentation/features/shops/booking/presentation/widgets/client_promo_code_field.dart` (NEW), `lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart`
- Description: 
  - `client_promo_code_field.dart`: `ConsumerStatefulWidget`. Internal state: `TextEditingController _controller`, `bool _busy`, `bool _autoApplied`. On mount: call `repo.validateAndApplyPromo(p_code: null, ...)` — if it returns a silent code, surface a single line-item "Loyalty reward" / "Welcome back" (source-keyed copy) and store the result in screen state. On Apply tap: call with `p_code = _controller.text` — replace any auto-applied code with the explicit one (RESEARCH §12 lines 833–836 "manual code wins"). On exception, surface `e.userMessage` via Snackbar and clear the field.
  - `booking_confirmation_screen.dart`: above the totals row, embed `ClientPromoCodeField` with a callback that updates the screen's `_promotionId`, `_amountOff`, `_discountedTotal`, `_appliedSource` state (RESEARCH §12 lines 805–818). Recompute platform fee from `_discountedTotal * paymentConfigProvider.platformFeeFraction` (single-line edit). Pass `_promotionId` through to `processPayment` per Task 2.1.
- Acceptance: `flutter analyze` clean. Task 5.3 widget tests pass (auto-apply on mount, manual entry overrides auto-apply, expired code shows Snackbar with `userMessage`). Manual UAT steps 2 + 3 + 6 + 7 (Task 6.2) confirm end-to-end.
- Estimate: 90

### Wave 5 — Tests (depends on Waves 0–4)

**Task 5.1 — `PromotionException` unit tests (NEW subtypes)**
- File(s): `test/presentation/features/shops/dashboard/data/exceptions/promotion_exceptions_test.dart` (NEW)
- Description: Mirror `client_notes_exceptions_test.dart` shape (Phase 12). Cases: (a) each NEW subtype exposes its declared `code` and `userMessage`; (b) `userMessage` contains zero internal identifiers (no UUIDs, no shop_id text, no `$e` interpolation); (c) `toString()` returns `'PromotionException(<code>): <message>'`; (d) baseline assertion: the four EXISTING subtypes still match their declared codes (regression guard).
- Acceptance: `flutter test test/.../promotion_exceptions_test.dart` passes.
- Estimate: 25

**Task 5.2 — Repository unit tests for new methods (mocktail)**
- File(s): `test/presentation/features/shops/dashboard/data/repositories/validate_and_apply_promo_test.dart` (NEW)
- Description: Mirror `services_repository_test.dart` mocktail pattern from Phase 11. Cases:
  (a) `validateAndApplyPromo(code: 'SUMMER10', ...)` issues `.rpc('validate_and_apply_promo', ...)` with the expected param map; returns a non-null record from the mocked success row.
  (b) `validateAndApplyPromo(code: null, ...)` issues the same RPC with null `p_code`; returns null when the mocked response is empty (no silent code).
  (c) Mocked `PostgrestException(code: '42501', hint: 'CODE_NOT_FOUND')` → `PromotionNotFoundException`.
  (d) `code: '22023', hint: 'CODE_EXPIRED'` → `PromoExpiredException`.
  (e) `code: '22023', hint: 'CODE_LIMIT_REACHED'` → `PromotionLimitReachedException`.
  (f) `code: '22023', hint: 'CODE_PER_CLIENT_MAX'` → `PromoPerClientMaxException`.
  (g) `code: '22023', hint: 'CODE_MIN_AMOUNT_NOT_MET'` → `PromoMinAmountNotMetException`.
  (h) `code: '22023', hint: 'CODE_SERVICE_NOT_ELIGIBLE'` → `PromoServiceNotEligibleException`.
  (i) `code: '22023', hint: 'CODE_WRONG_CLIENT'` → `PromoWrongClientException`.
  (j) Unmapped `PostgrestException` → generic `PromotionException` (the fallback path).
  (k) Same file: `upsertLoyaltyRule` happy path + `42501 → PromotionNotFoundException` + unmapped → `LoyaltyRuleSaveFailedException`.
- Acceptance: `flutter test test/.../validate_and_apply_promo_test.dart` passes all 11 cases. `grep -n 'e\\.toString()\\.contains' lib/.../promotions_repository.dart` returns 0.
- Estimate: 70

**Task 5.3 — `ClientPromoCodeField` widget test**
- File(s): `test/presentation/features/shops/booking/presentation/widgets/client_promo_code_field_test.dart` (NEW)
- Description: `ProviderScope` override of `dashboardRepositoryProvider` with a fake. Cases:
  (a) On mount with no silent code: field is empty, no line-item shown.
  (b) On mount with a loyalty silent code: field stays empty; line-item "Loyalty reward" appears with the source-keyed copy.
  (c) On mount with a recovery silent code: line-item "Welcome back" appears.
  (d) Type SUMMER10 + tap Apply → fake repo called with `p_code='SUMMER10'`; line-item swaps to "Code: SUMMER10".
  (e) `PromoExpiredException` thrown → Snackbar shows `userMessage`; field clears.
  (f) Manual code entry while silent code is auto-applied: manual code wins per RESEARCH §12 lines 833–836.
- Acceptance: `flutter test test/.../client_promo_code_field_test.dart` passes all 6 cases.
- Estimate: 60

**Task 5.4 — SQL smoke-test script**
- File(s): `.planning/phases/13-promo-engine-and-silent-loyalty/sql/13_smoke_tests.sql` (NEW — written by this plan in parallel with PLAN.md)
- Description: Hand-runnable script against a staging branch DB. Sections cover the SPEC's 9 success criteria plus the pre-flight schema sanity checks. Wrapped in `BEGIN ... ROLLBACK` with SAVEPOINTs per section. Each section ends with `RAISE NOTICE 'OK: <case>'`. Coverage:
  - §A — per-shop UNIQUE code creation; cross-shop code reuse permitted.
  - §B — `validate_and_apply_promo` manual happy path (SUMMER10 → returns amount_off and new_total).
  - §C — expired code rejection (`CODE_EXPIRED`).
  - §D — per-client cap enforcement (`CODE_PER_CLIENT_MAX` on 2nd attempt).
  - §E — service restriction enforcement (`CODE_SERVICE_NOT_ELIGIBLE`).
  - §F — auto-apply silent code: insert a loyalty code with target_user_id; call validate with p_code=NULL → returns the silent code.
  - §G — `loyalty_rules` RLS denies non-owner; `upsert_loyalty_rule` authz.
  - §H — `redeem_promotion` idempotency for both registered and guest paths.
  - §I — loyalty trigger fires on Nth completion + idempotency (re-mark-completed produces no new code).
  - §J — `enqueue_booking_reminder('recovery_checkin', ...)` writes a row with `whatsapp_template='recovery_checkin_v2'` and `whatsapp_params.3 = <code text>`.
- Acceptance: `psql $STAGING_DB_URL -f .planning/phases/13-promo-engine-and-silent-loyalty/sql/13_smoke_tests.sql` prints `OK:` for every case (§A–§J). The outer ROLLBACK leaves no residue.
- Estimate: 90

### Wave 6 — Meta + UAT (parallel with Wave 5)

**Task 6.1 — Submit `recovery_checkin_v2` WhatsApp template to Meta**
- File(s): n/a — Meta Business Manager dashboard.
- Description: Submit `recovery_checkin_v2` with three variables: `{{1}}` = client_name, `{{2}}` = shop_name, `{{3}}` = code. Body draft (lifted from RESEARCH §5 lines 477–484):
  > Hi {{1}}, we missed seeing you at {{2}}. Use code **{{3}}** for a discount on your next booking. Reply STOP to opt out.
  
  Category: MARKETING. Submission BEFORE merging the Wave 1 migration that creates `generate_recovery_code`. The worker's existing 6-hour `WhatsAppTemplateNotFoundError` retry behavior at `supabase/functions/process-scheduled-notifications/index.ts:124-128` defers pending `_v2` rows until Meta approves — no flag, no skip logic required. The Phase 12 `recovery_checkin_v1` template keeps working until the patched helper (Task 1.7) flips the template name.
- Acceptance: Template appears in Meta dashboard as `SUBMITTED` or `APPROVED`. Approval ID captured in PR description.
- Rollback: Template can sit in `SUBMITTED` indefinitely. If Phase 13 deploys before approval, recovery_checkin rows defer for up to 24h cumulatively (typical Meta SLA < 6h).
- Estimate: 25

**Task 6.2 — Manual UAT: end-to-end promo + loyalty + recovery loop on staging**
- File(s): n/a (manual).
- Description: On a real staging shop with a real test phone:
  1. **Owner creates `SUMMER10` 10%-off code in PromotionsScreen.** Verify it appears in the list with source badge "Owner". Sign in as a different shop owner; navigate to their PromotionsScreen — `SUMMER10` is NOT visible (RLS holds).
  2. **Client books a service through booking_confirmation_screen with a Paystack test card.** Enter `SUMMER10` → total updates to show 10% off; platform fee recomputes against the discounted new_total. Pay through. Verify in DB: `promotion_redemptions` has one row for the booking with the correct `discount_amount`.
  3. **Same client attempts to use `SUMMER10` on a second booking the same day.** Apply button → Snackbar with `userMessage` "You've already used this code the maximum number of times." (`PromoPerClientMaxException`).
  4. **Owner sets a loyalty rule: every 6th completed booking grants 15% off.** Use the `LoyaltyRuleScreen`. Verify the row appears in `loyalty_rules` with `is_active=true`. Toggle is_active off, then on, then a different discount value — verify only ONE active row at a time.
  5. **Test client completes 6 bookings at the shop** (use `mark_booking_complete` from worker dashboard, or staging UI). After the 6th, verify a `promotions` row appears with `source='loyalty'`, `target_user_id` set, `discount_value=15`. Re-mark one of the bookings as completed (a no-op transition) → verify NO new loyalty code is generated.
  6. **Client books a 7th time.** On checkout mount, the line-item shows "Loyalty reward: 15% off" with NO code text visible in the field. Payment proceeds with the 15% discount applied.
  7. **Cancel a confirmed booking; wait for `recovery_checkin` (or invoke `enqueue_booking_reminder` directly).** Verify `scheduled_notifications` has the row with `whatsapp_template='recovery_checkin_v2'` AND `whatsapp_params->>'3'` non-null. The `promotions` table has a new `source='recovery'` row with `valid_to = now() + 30 days`. Capture screenshots.
  8. **Different shop owner navigates to the first shop's PromotionsScreen URL.** Verify zero rows surface (RLS denies cross-shop reads).
  9. **Owner archives `SUMMER10`** (Switch in CreatePromotionScreen edit). Verify the next attempted apply by a client returns `CODE_NOT_FOUND`. Owner can now re-create `SUMMER10` because the partial-unique index lets it free up.
- Acceptance: All 9 steps observed. Steps 1–3 confirm owner-defined path. Steps 4–6 confirm loyalty trigger + auto-apply. Step 7 confirms recovery_checkin patch. Step 8 confirms RLS. Step 9 confirms archive flow with partial-unique constraint. Screenshots attached to PR.
- Estimate: 60

## Verification per task

| Task | Observable acceptance |
|------|-----------------------|
| 0.0 | Pre-flight queries returned expected shape; check 4 = zero rows. Outputs pasted in PR. |
| 0.1 | `\d public.promotions` shows seven new columns + XOR CHECK. Per-shop partial-unique + silent-target unique indexes exist. Smoke §A passes. |
| 0.2 | `\d public.loyalty_rules` shows seven columns + CHECKs + 2 indexes + 2 RLS policies. Smoke §G passes. |
| 1.1 | `\df+ public.redeem_promotion` shows 5 params. `has_function_privilege('authenticated', ...)` returns false. Smoke §H passes. |
| 1.2 | Smoke §B–§F print `OK:`. EXPLAIN ANALYZE < 100ms. Task 5.2 HINT-mapping cases pass. |
| 1.3 | Smoke §G prints `OK:`. Authz rejects non-owner with 42501. Task 5.2 loyalty case passes. |
| 1.4 | Smoke §I prints `OK:` — trigger idempotency holds. `has_function_privilege('authenticated', ...)` returns false. |
| 1.5 | Smoke §J prints `OK:` — code generated, idempotent on re-call. With no active rule, returns NULL. |
| 1.6 | Smoke §I prints `OK:`. Trigger WHEN clause restricts to NEW.status='completed'. Non-overlapping with Phase 12's confirmed-only trigger. |
| 1.7 | Smoke §J prints `OK:`. `diff`-based body audit shows ONLY the five documented edits vs. Phase 12 helper. Other 4 notification categories byte-for-byte unchanged. |
| 2.1 | `flutter analyze` clean. Existing callers compile unchanged (the param is optional). |
| 2.2 | `grep -rn "rpc('redeem_promotion'" supabase/functions/` returns at least 4. Manual UAT step 2 confirms redemption row inserted. |
| 3.1 | `flutter analyze` clean. Task 5.1 passes. Existing four subtypes unchanged. |
| 3.2 | `grep -n 'e\\.toString()\\.contains' lib/.../promotions_repository.dart` returns 0. Task 5.2 passes. Existing JSON round-trip unaffected. |
| 3.3 | `grep -n 'debounce\\|Timer.periodic\\|onChanged.*upsert' lib/.../loyalty_rule_screen.dart` returns 0. Manual UAT step 4 confirms persist + round-trip. |
| 3.4 | Manual UAT step 1 (owner creates SUMMER10) + step 5 (silent codes hidden in list by default) + Tools tab card. `flutter analyze` clean. |
| 4.1 | Task 5.3 widget tests pass all 6 cases. Manual UAT steps 2 + 3 + 6 + 7 confirm. |
| 5.1 | `flutter test` green; six new subtypes asserted. |
| 5.2 | `flutter test` green; 11 cases pass. NO string matching anywhere in production code. |
| 5.3 | `flutter test` green; 6 cases pass. |
| 5.4 | `psql -f` prints `OK:` for §A–§J. |
| 6.1 | Template submitted; Meta IDs in PR. |
| 6.2 | Nine UAT steps observed; screenshots in PR. |

## Risk register

| ID | Risk | Severity | Mitigation in this plan |
|----|------|----------|--------------------------|
| R1 | **Constraint swap breaks during production deploy** — duplicate `code` text across shops would prevent the per-shop partial-unique creation. | P0 | Pre-flight check 4 (Task 0.0) BLOCKS the deploy if duplicates exist. Output pasted to PR. If the dev DB → prod gap surfaces duplicates, contact owner pairs and rename before merge. |
| R2 | **REVOKE on `redeem_promotion` breaks a live caller**. | P0 (mitigated) | RESEARCH §18 grepped the codebase: only `promotions_repository.dart:122` calls it, in the dead `incrementUsage` method that no UI invokes. Pre-flight check 5 (Task 0.0) re-grepped immediately before deploy. If a hidden caller surfaces during canary, re-grant in a hotfix migration. |
| R3 | **Trigger ordering with Phase 12's `trg_bookings_schedule_reminders`** would mean the loyalty trigger fires on transitions it shouldn't. | P0 (mitigated) | Per RESEARCH §4 lines 326–332: Phase 12's trigger has `WHEN (NEW.status = 'confirmed')`. Phase 13's loyalty trigger has `WHEN (NEW.status = 'completed')`. Non-overlapping. Verified by `pg_get_triggerdef` in Task 1.6 acceptance. |
| R4 | **Auto-apply picks the WRONG silent code when both loyalty AND recovery exist for one client.** | P1 | Highest-discount wins; tiebreak on sooner-expiring `valid_until` (RESEARCH §8 lines 685–707). Locked decision. Smoke §F asserts. |
| R5 | **Owner fabricates a `source='loyalty'` row for an arbitrary client** to bypass RLS and grant themselves a silent code targeting a customer who hasn't earned one. | P0 (mitigated) | Task 0.1 replaces the broad `promotions_owner_all` policy with four scoped policies. Direct INSERT requires `source = 'owner_defined'`. Silent codes can only be written via the SECURITY DEFINER helpers (`generate_loyalty_code`, `generate_recovery_code`) which derive `target_*` from the actual booking row. |
| R6 | **`recovery_checkin_v2` template not approved at deploy** — guest deliveries defer. | P1 | Worker's existing 6-hour `WhatsAppTemplateNotFoundError` retry covers up to 24h. Phase 12's `recovery_checkin_v1` keeps working until Task 1.7's helper update flips the template name. Submit early (Task 6.1). |
| R7 | **Phase 12 helper rewrite (Task 1.7) breaks the other 4 notification categories** if the executor misapplies the diff. | P0 (mitigated) | The migration documents five surgical edits with line-level precision. Task 1.7 acceptance includes a `diff` audit — extract the function body, scrub the documented diff regions, `diff` against Phase 12 original → only the five regions should appear. Smoke §J (recovery_checkin v2) plus Phase 12's existing smoke for the other four categories (still present, untouched) catch regressions. |
| R8 | **`validate_and_apply_promo` slow under high traffic** at scale. | L | Three partial unique indexes cover all three lookup patterns (RESEARCH §7 lines 668–674). EXPLAIN ANALYZE gate < 100ms in Task 1.2 acceptance. |
| R9 | **Platform fee recomputation drift between client and webhook** — the client computes `new_total * fraction` and sends; the webhook trusts the value. Owner could craft a malicious client and pass a too-low platform_fee. | M (existing) | This is the EXISTING Phase 11 behavior, unchanged by Phase 13. The platform fee is also recomputed against the discounted total in `validate_and_apply_promo`'s implicit contract (`new_total` is server-authoritative), so a malicious client passing a lower `new_total` than the validate RPC returned would be detected by the webhook's existing `pending_payments.booking_data` cross-check. Documented as Phase 13 carry-over, not a regression. |
| R10 | **Constraint swap leaves the existing global `promotions_code_key` unconstrained for a transactional window** between DROP and partial-unique creation. | L | Both operations are inside the same migration → one transaction. No window. |
| R11 | **Client recomputes platform fee against pre-discount total by accident** if the executor misses the `_discountedTotal` substitution in Task 4.1. | M | Task 4.1 acceptance includes manual UAT step 2 explicitly checking platform fee against the discounted new_total. Task 5.3 widget test (e) asserts the line-item math. |

## Rollout

**Strict order. Webhook diffs (Task 2.2) MUST land AFTER the schema + RPC migrations (Wave 0 + Wave 1).**

1. **Submit `recovery_checkin_v2` to Meta** (Task 6.1) at least 12 hours before SQL migrations land. The template can sit in SUBMITTED indefinitely without affecting production; `recovery_checkin_v1` keeps shipping until Task 1.7's helper rewrite swaps the name.
2. **Run pre-flight checks** (Task 0.0) against staging then prod. Paste outputs into PR. **BLOCK on check 4 (duplicate codes across shops).** If any non-zero return, do not proceed — fix data and re-run.
3. **Push SQL migrations in strict timestamp order** to staging:
   - `20260606000000_extend_promotions_for_phase13.sql` (Task 0.1)
   - `20260606000100_loyalty_rules_table.sql` (Task 0.2)
   - `20260606000200_widen_redeem_promotion_for_guests.sql` (Task 1.1)
   - `20260606000300_validate_and_apply_promo_rpc.sql` (Task 1.2)
   - `20260606000400_upsert_loyalty_rule_rpc.sql` (Task 1.3)
   - `20260606000500_generate_loyalty_code_helper.sql` (Task 1.4)
   - `20260606000600_generate_recovery_code_helper.sql` (Task 1.5)
   - `20260606000700_booking_loyalty_trigger.sql` (Task 1.6)
   - `20260606000800_patch_enqueue_booking_reminder_for_recovery_code.sql` (Task 1.7)
   Verify with smoke §A–§J against staging. Only after every `OK:` fires do we push to prod.
4. **Ship the three webhook diffs** (Task 2.2): `supabase functions deploy paystack-webhook stripe-webhook verify-payment`. After deploy, smoke-check by paying for a new test booking with a promo code attached and watching `promotion_redemptions` — the new row should appear after webhook fires.
5. **Ship the Dart code** as one commit. The widget changes are additive: the new promo field only renders inside `booking_confirmation_screen`, and `LoyaltyRuleScreen` is gated behind a new Tools card. Pre-Phase-13 builds simply don't show the new surfaces.
6. **24-hour log watch**: any `AppLogger.warn` event whose `event` starts with `promo.validate_failed` or `promo.redeem_failed`. A spike indicates an unmapped `PostgrestException` HINT that escaped Task 3.2. Cross-check against the worker's `WhatsAppTemplateNotFoundError` defer count for `recovery_checkin_v2` rows — if > 100 deferrals/hour, Meta still has the template in review; not a Phase 13 bug.
7. **PR description** must explicitly call out: (a) `redeem_promotion` GRANT revoked from authenticated; (b) `promotions_code_key` global UNIQUE replaced with per-shop partial-unique — pre-flight check 4 outputs attached; (c) `recovery_checkin_v2` template submission Meta IDs attached; (d) silent codes (`source IN ('loyalty', 'recovery')`) never write through the authenticated RLS path — fabrication closed; (e) Phase 12's other four notification categories byte-for-byte unchanged by Task 1.7 — diff audit attached.

### Rollback (Tier 2)

1. **Revert the Dart commit** — promo field disappears from checkout; LoyaltyRuleScreen disappears from Tools. No data loss; existing promos and loyalty rules stay in the DB and reappear when the commit is re-landed.
2. **Revert the three webhook diffs**: `supabase functions deploy paystack-webhook stripe-webhook verify-payment --version <prev-sha>`. New redemptions stop being recorded; existing rows stay forensically. Acceptable for an emergency rollback.
3. **Roll back the SQL**: ship a follow-up migration that drops the trigger first (`DROP TRIGGER trg_bookings_loyalty_visit ON public.bookings`), then re-applies the original Phase 12 `enqueue_booking_reminder` helper from `20260605130400_enqueue_booking_reminder_helper.sql`, then re-grants `redeem_promotion` to authenticated. **Do NOT drop the new helpers** (`generate_loyalty_code`, `generate_recovery_code`, `validate_and_apply_promo`, `upsert_loyalty_rule`) — any rows already enqueued via the trigger still depend on the helpers for forensic reads. **Do NOT drop `loyalty_rules` table or the seven new columns on `promotions`** — written rules and silent codes would be lost. The Dart commit revert hides them from the UI.

## Plan-check criteria

This plan is internally consistent when every item below holds. Reviewer asserts each manually before approval.

- [ ] Every `<task>` ≤ 3 file paths; bigger fans (Tasks 2.2, 3.3, 3.4, 4.1) are explicitly justified inline.
- [ ] Every `<task>` has an `Acceptance` line that is observable without reading the diff (grep / psql / flutter test / manual screenshot).
- [ ] Every `<task>` has a `Rollback` line OR §Rollout §Rollback covers it.
- [ ] Every new RPC follows the Phase 11 hardening template (authz FIRST, HINT codes, REVOKE/GRANT, COMMENT). Verified for `validate_and_apply_promo`, `upsert_loyalty_rule`, `generate_loyalty_code`, `generate_recovery_code`, plus the widened `redeem_promotion`.
- [ ] Every client-side error path uses typed exceptions with HINT-based dispatch. NO `e.toString().contains(...)`. Grep gate in §Definition of done asserts.
- [ ] **EXTEND not REBUILD.** No new `promo_codes` / `promo_redemptions` tables. The existing `promotions` + `promotion_redemptions` tables are extended.
- [ ] **REUSE `redeem_promotion`.** No new `record_promo_redemption` RPC.
- [ ] Pre-flight check 4 (duplicate codes across shops) BLOCKS the deploy when non-zero.
- [ ] Per-shop UNIQUE replaces the global UNIQUE. Documented in Task 0.1.
- [ ] `promotion_redemptions.user_id` is made nullable; `guest_profile_id` added; at-most-one identity CHECK.
- [ ] RLS tightened: direct INSERT/UPDATE/DELETE restricted to `source='owner_defined'`. Silent codes write via SECURITY DEFINER helpers only.
- [ ] Loyalty trigger uses AFTER UPDATE OF status with `WHEN (NEW.status = 'completed')`. Non-overlapping with Phase 12's confirmed-only trigger.
- [ ] Recovery code reuses the shop's active loyalty rule's discount; returns NULL when no rule (NOT hardcoded 10%).
- [ ] Loyalty code TTL = `now() + 10 years` (no-expiry sentinel). Recovery TTL = `now() + 30 days`.
- [ ] Silent code tiebreak: highest-discount wins; sooner-expiring `valid_until` on tie.
- [ ] `recovery_checkin_v2` Meta submission is in the plan (Task 6.1) but does NOT block PR merge; the worker's 6h retry covers the approval window.
- [ ] Phase 12 helper rewrite (Task 1.7) is documented as five surgical edits with a `diff` audit gate in acceptance.
- [ ] Platform fee recomputes against `new_total` in both `validate_and_apply_promo` (implicit via server-authoritative discount math) AND in `payment_controller.dart` (explicit client-side `new_total * platformFeeFraction`).
- [ ] Webhook integration uses `pending_payments.booking_data.promotionId`, NOT Stripe/Paystack metadata.
- [ ] Smoke SQL covers the 9 SPEC success criteria: §A (per-shop UNIQUE → SC 1), §B (validate happy path → SC 2), §C (expiry → SC 7), §D (per-client cap → SC 3), §E (service restriction → SC 7), §F (auto-apply silent → SC 5), §G (loyalty rule + RLS → SC 4), §H (redeem idempotency → SC 8 + 9), §I (loyalty trigger → SC 4), §J (recovery code generation → SC 6).
- [ ] Legacy `discount_type='free_addon'` kept in CHECK constraint; validate RPC rejects it via discount-math CASE.

## Definition of done

- [ ] `flutter analyze` clean on every touched Dart file (NEW + EDIT).
- [ ] All new Dart tests (Tasks 5.1–5.3) pass locally and in CI.
- [ ] `supabase db reset && supabase db push` applies the nine new migrations cleanly to a fresh DB.
- [ ] Smoke-test SQL script (Task 5.4) prints `OK:` for all of §A–§J against staging.
- [ ] UAT (Task 6.2) all 9 steps observed; screenshots in PR.
- [ ] Meta `recovery_checkin_v2` template submitted (Task 6.1); template ID documented in PR.
- [ ] Grep gates (CI step or `make verify` target — exact commands):
  - [ ] `grep -rn 'promo_codes\\|promo_redemptions' supabase/migrations/2026060[6-9]*.sql lib/` returns `0` (no parallel-schema regressions).
  - [ ] `grep -rn 'record_promo_redemption' supabase/migrations/2026060[6-9]*.sql lib/ supabase/functions/` returns `0` (renamed RPC not introduced).
  - [ ] `grep -rn "rpc('redeem_promotion'" supabase/functions/` returns at least `4` (paystack guest + paystack registered + stripe + verify-payment).
  - [ ] `grep -rn 'e\\.toString()\\.contains' lib/presentation/features/shops/dashboard/data/repositories/promotions_repository.dart` returns `0`.
  - [ ] `grep -rn 'debounce\\|Timer.periodic\\|onChanged.*upsert' lib/presentation/features/shops/dashboard/presentation/screens/loyalty_rule_screen.dart` returns `0`.
  - [ ] `grep -rn 'recovery_checkin_v2' supabase/migrations/20260606000800_patch_enqueue_booking_reminder_for_recovery_code.sql` returns at least `1`.
  - [ ] **Body-drift gate**: `enqueue_booking_reminder` in `20260606000800_*` is byte-for-byte identical to the Phase 12 body except for the five documented edits. Mechanical check: extract both function bodies via awk, mask the five documented diff regions in the new body, then `diff` — output must be empty.
  - [ ] **redeem_promotion grant audit**: `psql -tc "SELECT has_function_privilege('authenticated', 'public.redeem_promotion(UUID,UUID,UUID,NUMERIC,UUID)', 'EXECUTE')"` returns `f`.
  - [ ] `grep -rn 'ClientPromoCodeField' lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart` returns at least `1`.
  - [ ] `grep -rn 'LoyaltyRuleScreen' lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart` returns at least `1`.
- [ ] PR description flags the constraint swap (per-shop UNIQUE) as the highest-risk delta and documents the pre-flight + rollback plan (per §Rollout step 7).
- [ ] PR description lists the carry-over gaps in §Out of scope (`notification_settings.recovery_checkin_enabled` dormant; legacy `free_addon` kept in CHECK; platform-fee passthrough trust model unchanged).

**Estimated total effort:** 1095 minutes ≈ 18.3 hours. Lands above a typical phase target. The bump is documented and load-bearing: nine SQL migrations (including a constraint swap touching production-critical `promotions` table), the Phase 12 helper rewrite via surgical-diff audit, four webhook insertion points across three files, two new owner-facing screens, the checkout integration, and full typed-exception + widget-test coverage across both manual-entry and auto-apply paths.

## PLAN COMPLETE
