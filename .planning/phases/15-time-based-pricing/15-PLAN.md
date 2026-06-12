# Phase 15 PLAN — Time-Based Pricing Overrides

## Goal

Give shop owners a way to define per-(slot, day-of-week, time-window) **pricing
overrides** without touching the base service price, and surface the resulting
**effective price** to the client throughout the booking flow. Phase 15 ADDS one
new table (`pricing_overrides`) with SELECT-only RLS; ADDS three new owner-only
RPCs (`create_pricing_override`, `update_pricing_override`,
`archive_pricing_override`) hardened per Phase 11/13/14 template; REWRITES the
body of `generate_available_slots` to (a) pre-materialize active overrides
once per RPC call, (b) resolve the winning override per generated slot via the
locked 3-tier ladder, (c) bundle the latent `EXTRACT(DOW)` Sunday bug fix
(switch to `EXTRACT(ISODOW)` — Mon=1..Sun=7), and (d) add a new `base_price
NUMERIC` column to the RETURN TABLE so the client can render the
discount/surcharge chip without a second round-trip; PATCHES
`booking_confirmation_screen.dart` and `booking_creation_controller.dart` so
that the total computation and `priceAtBooking` snapshot use the slot's
effective price (without this patch, owners see chips but clients pay base
— RESEARCH §1); EXTENDS the existing `DashboardRepository` (NOT a new file —
SPEC + planner brief lock) with four methods (`createPricingOverride`,
`updatePricingOverride`, `archivePricingOverride`, `listPricingOverrides`) plus
a HINT-driven `_classifyPricingOverrideError` mirroring the PromotionsRepository
classifier; ADDS one new typed exception hierarchy
(`PricingOverrideException`) in its own file; ADDS one new DTO
(`PricingOverrideDTO`) with `AdjustmentKind` enum; ADDS one new
`FutureProvider.family.autoDispose` (`pricingOverridesProvider`); ADDS two new
screens (`PricingOverridesListScreen` + `PricingOverrideFormScreen`); ADDS one
new AppBar `IconButton` to `ServiceEditScreen` (edit-mode only — RESEARCH §15);
EXTENDS the existing `time_slot_chip.dart` widget with an `_AdjustmentBadge`
sub-widget; ADDS one nullable `basePrice` field to `TimeSlotModel`; ADDS ~30
EN keys to `app_en.arb`. The 50-active-overrides-per-slot cap is server-enforced
in `create_pricing_override` (raises `OVERRIDE_CAP_EXCEEDED`). Per-slot scope
only (no shop-wide rules — out of scope). Time windows cannot cross midnight
(CHECK `time_window_end > time_window_start`). Fixed-discount math clamps at
zero (no negative effective price). Phase 13's `validate_and_apply_promo` is
NOT touched — the client passes the override-adjusted total in `p_booking_total`
and the promo engine stacks deterministically (override → promo → final).
`booking_services.price_at_booking` remains the historical-snapshot invariant
— overrides edited after booking do not retroactively re-price.

(SPEC §Outcome lines 3–11; SPEC §Definitions lines 41–75; SPEC §"In scope"
lines 77–89; SPEC §"Research-phase resolutions" lines 168–177; RESEARCH §1
lines 81–161 client patch, §2 lines 163–313 generate_available_slots patch
shape, §3 lines 315–347 day_of_week semantics (OVERRIDDEN by planner brief to
1..7 + ISODOW), §5 lines 376–417 appointment_slots verified columns, §6 lines
419–507 pricing_overrides DDL, §7 lines 509–525 50-cap, §8 lines 527–802 RPC
bodies, §9 lines 810–901 typed exceptions + classifier, §14 lines 1009–1091
repo + provider surface, §15 lines 1093–1145 ServiceEditScreen IconButton,
§16 lines 1147–1256 time_slot_chip patch + base_price column add, §17 lines
1258–1299 i18n keys.)

## Out of scope (locked)

Verbatim from SPEC §"Out of scope (locked)" lines 91–105:

- **Worker-tier pricing** ("senior stylist costs more"). Deferred — schema rippling.
- **Real-time / demand-based surge** ("Saturday is busy, prices auto-rise"). Reactive pricing architecture out of scope.
- **Shop-wide overrides** ("20% off all services Tuesday morning"). Per-slot only in v1.
- **Override-of-overrides** (manual exemption surface). 3-tier ladder is final.
- **Date-range overrides** ("the entire holiday week, run this rule" as a single specific-date rule). `valid_from` / `valid_until` bound the rule's lifespan; the rule still applies to ALL matching days inside.
- **Override stacking** (compose multiple matching overrides). One wins per generated slot.
- **Promo + override interaction beyond "promo applies to adjusted total"**. No double-discount refusal policy in v1.
- **Owner-facing analytics on override impact**. Future dashboard work.
- **Adjustment-kind extensions** like `set_price_to_fixed_amount` or `free`. 100% off via `percent_discount=100` is allowed.
- **Bulk operations** ("copy this rule to all my services").
- **Override notification to clients** (auto-broadcast). Phase 14 broadcast can announce manually.
- **Translation of override labels**. EN keys only.
- **Price audit log** of every effective-price computation. Server is authoritative; owner sees rule definitions.

### Out of scope (locked-in design decisions vs. SPEC drafts vs. RESEARCH recommendations)

- **RESEARCH §3 recommendation of `day_of_week` 0..6 + `EXTRACT(DOW)`** — OVERRIDDEN by the planner brief. day_of_week is LOCKED to **1..7** (Mon=1..Sun=7) matching `shop_opening_hours.day_of_week` (1..7 verified live in prod, RESEARCH §3 + SPEC line 81). The generate_available_slots patch uses `EXTRACT(ISODOW)::INT` (returns 1..7 with Mon=1, Sun=7), which simultaneously fixes the latent Sunday-never-matches bug (`EXTRACT(DOW)` returned 0..6 with Sun=0, joined against `shop_opening_hours.day_of_week=7` and silently missed). Bundling the ISODOW fix into the Phase 15 RPC patch is locked — same surgical edit, same migration.
- **RESEARCH §11 — Fresha attribution on the 3-tier ladder** — DROPPED. SPEC §168–177 already drops it. Ladder stands on its own merits (single-day > narrower window > newest).
- **RESEARCH §6 — `percent_surcharge` upper cap >100%** — DROPPED. Schema CHECK locks percent values at ≤100. Form UI surfaces a soft yellow warning at >50% surcharge (warns, does NOT block) and at >5x base price on `fixed_surcharge`.
- **Partial-update gap on `day_of_week` / `valid_until`** — DEFERRED to v2. NULL = unchanged in the update RPC means owners cannot clear a previously-set `day_of_week` back to "all week" or `valid_until` back to "no expiry" via partial update. v1 workaround: archive + recreate. Documented in the form copy.
- **Per-shop currency conversion** — DROPPED. `fixed_*` adjustment_value is denominated in the parent shop's `currency` column. No cross-currency math. Same convention as Phase 13 `promotions.discount_value` (RESEARCH §6 lines 496–500).
- **Repository file split** — DROPPED. Phase 15 methods extend the existing `DashboardRepository` + `SupabaseDashboardRepository` (Phase 11 precedent — RESEARCH §14 line 1011, planner brief LOCKED). No `pricing_overrides_repository.dart`.

### Carry-over gaps explicitly NOT fixed

- **Cross-timezone slot generation: `shops.timezone` doesn't exist.** Same constraint as Phase 14 (RESEARCH §1 in Phase 14). Times in `pricing_overrides.time_window_*` are local to whatever DB session timezone interprets them. Documented in SPEC risk register line 188.
- **Race: owner archives override mid-checkout.** Client total computed at confirmation time; if the override archives between time-picker render and confirmation, the client charges the at-confirmation effective price (the override that was active when the time-slot list was fetched). Acceptable v1 — same risk profile as Phase 13 promo race. Documented in SPEC risk register line 189.
- **Form preview vs. server effective price drift.** Form preview is client-side math; server is authoritative. UAT verifies they match. Documented.
- **Owner-facing surface for `is_active=false` distinct from `archived_at != null`.** The schema supports both (`is_active` is a soft toggle; `archived_at` is a tombstone). v1 owner UI only exposes Archive. The `is_active` flag is reachable via `update_pricing_override(p_is_active := false)` for future pause-without-archive UX. Not surfaced in v1.

## Files touched

**NEW (SQL — strict timestamp order)**

- `supabase/migrations/20260611000000_pricing_overrides_table.sql`
- `supabase/migrations/20260611000100_create_pricing_override_rpc.sql`
- `supabase/migrations/20260611000200_update_pricing_override_rpc.sql`
- `supabase/migrations/20260611000300_archive_pricing_override_rpc.sql`
- `supabase/migrations/20260611000400_apply_pricing_overrides_to_generate_slots.sql`

**NEW (Dart)**

- `lib/presentation/features/shops/dashboard/data/models/pricing_override_dto.dart`
- `lib/presentation/features/shops/dashboard/data/exceptions/pricing_override_exceptions.dart`
- `lib/presentation/features/shops/dashboard/providers/pricing_overrides_provider.dart`
- `lib/presentation/features/shops/dashboard/presentation/screens/pricing_overrides_list_screen.dart`
- `lib/presentation/features/shops/dashboard/presentation/screens/pricing_override_form_screen.dart`
- `test/presentation/features/shops/dashboard/data/exceptions/pricing_override_exceptions_test.dart`
- `test/presentation/features/shops/dashboard/data/repositories/pricing_overrides_repository_test.dart`
- `test/presentation/features/shops/dashboard/presentation/screens/pricing_override_form_screen_test.dart`
- `test/presentation/features/shops/booking/presentation/widgets/time_slot/time_slot_chip_test.dart`
- `.planning/phases/15-time-based-pricing/sql/15_smoke_tests.sql`

**EDIT (Dart)**

- `lib/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart` — append four abstract methods: `createPricingOverride`, `updatePricingOverride`, `archivePricingOverride`, `listPricingOverrides`. NO new repository file (SPEC + planner brief LOCKED).
- `lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart` — implement the four abstract methods + add `_classifyPricingOverrideError(PostgrestException)` private helper mirroring the existing `_classifyPromotionError` shape.
- `lib/presentation/features/shops/dashboard/presentation/screens/service_edit_screen.dart` — add ONE AppBar `IconButton` (`Icons.price_change_outlined`, tooltip "Pricing rules") visible ONLY when `_isEdit == true && initial != null`. Routes to `PricingOverridesListScreen(shopId, slot: initial!)`. RESEARCH §15 lines 1093–1144.
- `lib/presentation/features/shops/booking/data/models/time_slot_model.dart` — add one nullable `final double? basePrice;` field + JSON round-trip (`json['base_price']`).
- `lib/presentation/features/shops/booking/presentation/widgets/time_slot/time_slot_chip.dart` — restore the commented-out price block at lines 136–145; add `_AdjustmentBadge` sub-widget that renders the Discount / Surcharge chip when `slot.basePrice != null && slot.basePrice != slot.price`. Owner-defined `name` is NOT surfaced (SPEC line 90 + RESEARCH §16 line 1256).
- `lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart` — PATCH lines 302–310 (`_calculateTotalPrice` signature accepts `Map<String, TimeSlotModel> timeSlots`, uses `timeSlots[service.id]?.price ?? service.price`) and 340–359 (`servicesData` payload uses the same `effectivePrice` for `priceAtBooking`). RESEARCH §1 lines 113–149. Net additive — zero-override shops see `effective == base`.
- `lib/presentation/features/shops/booking/presentation/controllers/booking_creation_controller.dart` — PATCH lines 462 and 496 with the same `timeSlots[service.id]?.price ?? service.price` swap. RESEARCH §1 lines 150–155.
- `lib/i10n/app_en.arb` — add ~30 new EN keys (list screen titles, form labels, kind labels, error messages, chip labels). EN only — same pattern as Phase 13.1 / 14.

**NOT TOUCHED**

- `supabase/functions/paystack-webhook/index.ts` and `stripe-webhook/index.ts` — verified RESEARCH §6 lines 53–63. Both already read `s.priceAtBooking` verbatim from the bookingData payload. Phase 15's client patch writes the effective price into that payload entry; the webhook is correct as-is.
- `supabase/migrations/20260606000300_validate_and_apply_promo_rpc.sql` — Phase 13 promo RPC is parameter-only on `p_booking_total`. Phase 15 changes WHAT the client passes (effective total, not base total) but does NOT touch the RPC body.
- Any payment provider SDK or webhook handler. Pricing overrides have no payment lifecycle entanglement.

## Pre-flight checks (BLOCKING — run before Wave 0)

These run once on the production DB. Any unexpected output blocks the PR from merging.

```sql
-- (1) Confirm appointment_slots exists with id UUID PK + the columns Phase 15 reads.
--     The table is NOT in version-controlled migrations (RESEARCH §5); verify live.
SELECT a.attname AS col, t.typname AS type, a.attnotnull AS notnull
FROM   pg_attribute a
JOIN   pg_type t ON t.oid = a.atttypid
WHERE  a.attrelid = 'public.appointment_slots'::regclass
  AND  a.attnum > 0
  AND  a.attname IN ('id','shop_id','price','archived_at','days_of_week')
ORDER BY a.attname;
-- Expected: 5 rows. `id` type = 'uuid' + notnull = TRUE. `price` type = 'numeric'.
-- `archived_at` type = 'timestamptz' + notnull = FALSE. If `id` is not UUID, the FK
-- in 20260611000000_pricing_overrides_table.sql will fail — STOP and surface to user.

-- (2) Confirm appointment_slots PK is the `id` column (FK target).
SELECT a.attname
FROM   pg_index i
JOIN   pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
WHERE  i.indrelid = 'public.appointment_slots'::regclass
  AND  i.indisprimary;
-- Expected: ONE row with attname = 'id'. If the PK is composite or non-`id`, the
-- FK and ON DELETE CASCADE semantics need revisiting.

-- (3) Confirm shop_opening_hours.day_of_week is 1..7 (Mon=1..Sun=7), NOT 0..6.
--     The planner brief LOCKS Phase 15 to 1..7 — verify the join target matches.
SELECT DISTINCT day_of_week FROM public.shop_opening_hours ORDER BY day_of_week;
-- Expected: rows in [1,2,3,4,5,6,7]. If any 0 appears, the existing data uses the
-- 0..6 convention and the ISODOW bundle is unsafe — STOP and surface to user.

-- (4) Confirm the latent EXTRACT(DOW) bug is observable: no Sunday slots exist
--     because EXTRACT(DOW)=0 never joins against shop_opening_hours.day_of_week=7.
--     RESEARCH §16 evidence: appointment_slots rows show range 1..6 (no Sundays).
SELECT array_agg(DISTINCT dow) FROM (
  SELECT unnest(days_of_week) AS dow FROM public.appointment_slots
  WHERE archived_at IS NULL
) t;
-- Expected: array containing 1..6 (no 7, no 0). After Phase 15's ISODOW fix lands,
-- a fresh slot saved with days_of_week containing 7 (Sunday) will start generating
-- bookable rows. Capture this baseline before deploy.

-- (5) Confirm validate_and_apply_promo signature is parameter-only on p_booking_total.
--     Phase 15 does NOT touch this RPC — verify the assumption holds.
SELECT pg_get_function_arguments(p.oid)
FROM   pg_proc p
JOIN   pg_namespace n ON n.oid = p.pronamespace
WHERE  n.nspname = 'public' AND p.proname = 'validate_and_apply_promo';
-- Expected: includes `p_booking_total numeric` (or similar). The RPC operates on
-- the passed-in number; Phase 15 changes what number the client passes.

-- (6) Confirm zero direct Dart callers of `pricing_overrides` table or new RPCs
--     (Phase 15 is greenfield — no prior callers should exist).
-- Run locally:
--   grep -rn "from('pricing_overrides')" lib/
--   grep -rn 'create_pricing_override\|update_pricing_override\|archive_pricing_override' lib/
-- Expected: zero hits before Wave 2.

-- (7) Confirm pricing_overrides table does NOT already exist (Phase 15 creates it).
SELECT count(*) FROM information_schema.tables
WHERE table_schema = 'public' AND table_name = 'pricing_overrides';
-- Expected: 0. If 1, a prior partial deploy left the table behind — audit before re-running.
```

The pre-flight script is also pasted at the top of the smoke SQL file so the
executor sees it before running anything against staging.

## Migration plan

Five new SQL migrations. Strict timestamp order. Every RPC follows the Phase 11
hardening template
([20260603001500_harden_dashboard_rpcs.sql](../../../supabase/migrations/20260603001500_harden_dashboard_rpcs.sql)
lines 29–108) byte-for-byte: `LANGUAGE plpgsql SECURITY DEFINER SET search_path
= public, pg_temp`, authz ownership gate FIRST (via slot→shop chain), null-shape
validation BEFORE side effects, `'not_found'` raises with `ERRCODE = '42501'`,
`'invalid_*'` raises with `ERRCODE = '22023'` + `HINT = '...'`, then `REVOKE ALL
ON FUNCTION ... FROM PUBLIC`, `REVOKE ALL ON FUNCTION ... FROM authenticated`
(defensive per Phase 13 hotfix learning —
[20260606000850_revoke_redeem_promotion_from_authenticated.sql](../../../supabase/migrations/20260606000850_revoke_redeem_promotion_from_authenticated.sql)),
`GRANT EXECUTE ... TO authenticated`, and `COMMENT ON FUNCTION ... IS '... Big-O
... Phase 15.'`.

### 1. `20260611000000_pricing_overrides_table.sql`

Greenfield table + RLS + partial index + CHECK constraints. RLS-enabled with
SELECT-only owner policy via slot→shop chain. NO INSERT / UPDATE / DELETE
policies (per Phase 14 RESEARCH §9 — absence on RLS-enabled table = deny-all
for `authenticated`). All mutations flow through SECURITY DEFINER RPCs.

```sql
-- Phase 15: pricing_overrides — owner-authored per-slot price-adjustment rules.
-- Applied at slot generation time by generate_available_slots. Snapshot-safe:
-- booking_services.price_at_booking captures the actually-charged price at
-- booking instant, so override edits never retroactively re-price history.
--
-- day_of_week LOCKED to 1..7 (Mon=1..Sun=7) matching shop_opening_hours.
-- The Phase 15 generate_available_slots patch switches EXTRACT(DOW) to
-- EXTRACT(ISODOW) so Sunday bookings finally work — see RESEARCH §3.

CREATE TABLE IF NOT EXISTS public.pricing_overrides (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slot_id              UUID NOT NULL
                         REFERENCES public.appointment_slots(id) ON DELETE CASCADE,
  name                 TEXT NOT NULL CHECK (char_length(name) BETWEEN 1 AND 80),
  day_of_week          INT  NULL
                         CHECK (day_of_week IS NULL OR day_of_week BETWEEN 1 AND 7),
  time_window_start    TIME NOT NULL,
  time_window_end      TIME NOT NULL,
  adjustment_kind      TEXT NOT NULL CHECK (adjustment_kind IN
                         ('percent_discount','percent_surcharge',
                          'fixed_discount','fixed_surcharge')),
  adjustment_value     NUMERIC(12,2) NOT NULL CHECK (adjustment_value > 0),
  valid_from           TIMESTAMPTZ NOT NULL DEFAULT now(),
  valid_until          TIMESTAMPTZ NULL,
  is_active            BOOLEAN NOT NULL DEFAULT TRUE,
  archived_at          TIMESTAMPTZ NULL,
  created_by_user_id   UUID NOT NULL REFERENCES auth.users(id),
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Reject midnight-crossing windows. SPEC + planner brief locked.
  CONSTRAINT pricing_overrides_window_ordered
    CHECK (time_window_end > time_window_start),

  -- Percent values cap at 100. 100% discount → free; that's allowed.
  -- Surcharges beyond 100% are NOT allowed at the schema level (SPEC + brief).
  CONSTRAINT pricing_overrides_percent_range CHECK (
    adjustment_kind NOT IN ('percent_discount','percent_surcharge')
    OR adjustment_value BETWEEN 0.01 AND 100
  ),

  -- valid_until must not precede valid_from (NULL is OK = no expiry).
  CONSTRAINT pricing_overrides_validity_ordered CHECK (
    valid_until IS NULL OR valid_until > valid_from
  )
);

-- Hot-path index: generate_available_slots filters on
--   slot_id IN (...) AND is_active AND archived_at IS NULL
-- A partial index on (slot_id) pre-prunes inactive / archived rows.
CREATE INDEX IF NOT EXISTS idx_pricing_overrides_active_slot
  ON public.pricing_overrides (slot_id)
  WHERE is_active = TRUE AND archived_at IS NULL;

-- Note: NO secondary (slot_id, created_at DESC) index. Owner list view is bounded
-- at 50 rows per slot (per the create-RPC cap); Postgres sorts 50 rows in-memory.

ALTER TABLE public.pricing_overrides ENABLE ROW LEVEL SECURITY;

-- SELECT-only RLS for owners via slot → shop chain. INSERT/UPDATE/DELETE flow
-- through SECURITY DEFINER RPCs. Mirrors Phase 14 broadcasts pattern + Phase 11
-- archive_appointment_slot pattern.
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies
                 WHERE policyname = 'pricing_overrides_owner_select') THEN
    CREATE POLICY pricing_overrides_owner_select ON public.pricing_overrides
      FOR SELECT TO authenticated
      USING (EXISTS (
        SELECT 1 FROM public.appointment_slots s
        JOIN public.shops sh ON sh.id = s.shop_id
        WHERE s.id = pricing_overrides.slot_id
          AND sh.user_id = auth.uid()
      ));
  END IF;
END $$;

-- Deliberately NO INSERT / UPDATE / DELETE policies. Absence on an
-- RLS-enabled table = deny-all for `authenticated`. All mutations route
-- through create_pricing_override / update_pricing_override /
-- archive_pricing_override (SECURITY DEFINER, bypasses RLS).
-- Pattern verified against broadcasts (Phase 14) + client_notes (Phase 12).

COMMENT ON TABLE public.pricing_overrides IS
  'Phase 15: per-(slot, day_of_week, time_window) price-adjustment rules. Applied at slot generation time by generate_available_slots. Snapshot-safe — price_at_booking continues to capture the actually-charged price at booking instant. Archived via archived_at (mirrors Phase 11 archive pattern). day_of_week 1..7 (Mon=1..Sun=7) — Phase 15 also fixes the latent EXTRACT(DOW) bug by switching to EXTRACT(ISODOW).';

COMMENT ON COLUMN public.pricing_overrides.day_of_week IS
  '1=Monday .. 7=Sunday matching ISO 8601 and shop_opening_hours.day_of_week. NULL = applies to every day of the week within the valid_from/valid_until window.';

COMMENT ON COLUMN public.pricing_overrides.adjustment_kind IS
  'Four enums: percent_discount (0..100% off), percent_surcharge (0..100% extra), fixed_discount (currency amount off, clamps at 0), fixed_surcharge (currency amount extra). Currency is the parent shop''s `currency` column (same convention as Phase 13 promotions.discount_value).';

COMMENT ON COLUMN public.pricing_overrides.archived_at IS
  'Soft-delete tombstone. When non-NULL, the override is dormant — generate_available_slots filters it out via the partial index. Phase 15 owner UI only Archive (no hard delete).';
```

**Cap doc.** The 50-active-overrides-per-slot cap is enforced in the
`create_pricing_override` RPC body (§2 below) — not at the schema level
(a CHECK cannot count sibling rows). The cap rationale (RESEARCH §7): 50 rules
on one service is the practical owner-comprehensibility limit; at 50 × 5
services the override CTE materializes 250 rows once per RPC call — sub-ms.

### 2. `20260611000100_create_pricing_override_rpc.sql`

Owner-only create. Authz first via slot→shop chain. Field validation
HINT-coded for the Dart-side classifier. Per-slot active-count check raises
`OVERRIDE_CAP_EXCEEDED` at 50. RESEARCH §8 lines 533–641 verbatim, modulo the
day_of_week range (locked 1..7).

```sql
CREATE OR REPLACE FUNCTION public.create_pricing_override(
  p_slot_id            UUID,
  p_name               TEXT,
  p_day_of_week        INT,
  p_time_window_start  TIME,
  p_time_window_end    TIME,
  p_adjustment_kind    TEXT,
  p_adjustment_value   NUMERIC,
  p_valid_from         TIMESTAMPTZ DEFAULT NULL,
  p_valid_until        TIMESTAMPTZ DEFAULT NULL
) RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE
  v_override_id   UUID;
  v_active_count  INT;
BEGIN
  -- 1. NULL shape — required fields only. day_of_week is nullable by design.
  IF p_slot_id IS NULL OR p_name IS NULL
     OR p_time_window_start IS NULL OR p_time_window_end IS NULL
     OR p_adjustment_kind IS NULL OR p_adjustment_value IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'REQUIRED_FIELD_MISSING';
  END IF;

  -- 2. Authz FIRST. slot → shop chain. Sanitized 'not_found' on mismatch.
  IF NOT EXISTS (
    SELECT 1 FROM public.appointment_slots s
    JOIN public.shops sh ON sh.id = s.shop_id
    WHERE s.id = p_slot_id
      AND sh.user_id = auth.uid()
      AND s.archived_at IS NULL
  ) THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  -- 3. Field validation. HINT-coded for typed-exception mapping.
  IF (char_length(p_name) NOT BETWEEN 1 AND 80) THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'NAME_LENGTH_INVALID';
  END IF;
  IF p_day_of_week IS NOT NULL AND (p_day_of_week NOT BETWEEN 1 AND 7) THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'DAY_OF_WEEK_OUT_OF_RANGE';
  END IF;
  IF p_time_window_end <= p_time_window_start THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'WINDOW_NOT_ORDERED';
  END IF;
  IF p_adjustment_kind NOT IN
     ('percent_discount','percent_surcharge','fixed_discount','fixed_surcharge') THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'ADJUSTMENT_KIND_INVALID';
  END IF;
  IF p_adjustment_value <= 0 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'ADJUSTMENT_VALUE_INVALID';
  END IF;
  IF p_adjustment_kind IN ('percent_discount','percent_surcharge')
     AND p_adjustment_value > 100 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'PERCENT_OUT_OF_RANGE';
  END IF;
  IF p_valid_until IS NOT NULL
     AND p_valid_until <= COALESCE(p_valid_from, now()) THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'VALIDITY_NOT_ORDERED';
  END IF;

  -- 4. Per-slot cap. Count only active + non-archived rows on the parent slot.
  SELECT count(*) INTO v_active_count
  FROM public.pricing_overrides
  WHERE slot_id = p_slot_id
    AND is_active = TRUE
    AND archived_at IS NULL;
  IF v_active_count >= 50 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'OVERRIDE_CAP_EXCEEDED';
  END IF;

  -- 5. Insert.
  INSERT INTO public.pricing_overrides (
    slot_id, name, day_of_week,
    time_window_start, time_window_end,
    adjustment_kind, adjustment_value,
    valid_from, valid_until,
    created_by_user_id
  ) VALUES (
    p_slot_id, p_name, p_day_of_week,
    p_time_window_start, p_time_window_end,
    p_adjustment_kind, p_adjustment_value,
    COALESCE(p_valid_from, now()), p_valid_until,
    auth.uid()
  ) RETURNING id INTO v_override_id;

  RETURN v_override_id;
END;
$function$;

REVOKE ALL ON FUNCTION public.create_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.create_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.create_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ) TO authenticated;

COMMENT ON FUNCTION public.create_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ) IS
  'Phase 15: owner-only create. Authz via appointment_slots → shops.user_id = auth.uid(). NULL-shape, field, and per-slot-cap (50) validation HINT-coded. O(1) for create + O(N) cap check where N <= 50. SECURITY DEFINER.';
```

### 3. `20260611000200_update_pricing_override_rpc.sql`

Partial update. NULL params leave fields unchanged. Cross-field checks
(window order, percent range, validity order) run against the MERGED
post-update values so an owner can mutate one half of a constraint pair without
the other being treated as the new baseline.

```sql
CREATE OR REPLACE FUNCTION public.update_pricing_override(
  p_override_id        UUID,
  p_name               TEXT DEFAULT NULL,
  p_day_of_week        INT  DEFAULT NULL,
  p_time_window_start  TIME DEFAULT NULL,
  p_time_window_end    TIME DEFAULT NULL,
  p_adjustment_kind    TEXT DEFAULT NULL,
  p_adjustment_value   NUMERIC DEFAULT NULL,
  p_valid_from         TIMESTAMPTZ DEFAULT NULL,
  p_valid_until        TIMESTAMPTZ DEFAULT NULL,
  p_is_active          BOOLEAN DEFAULT NULL
) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE
  v_existing  RECORD;
  v_new_start TIME;
  v_new_end   TIME;
  v_new_kind  TEXT;
  v_new_value NUMERIC;
  v_new_from  TIMESTAMPTZ;
  v_new_until TIMESTAMPTZ;
BEGIN
  IF p_override_id IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'NULL_NOT_ALLOWED';
  END IF;

  -- Authz via slot → shop. Also pulls existing field values for merge.
  SELECT po.* INTO v_existing
  FROM public.pricing_overrides po
  JOIN public.appointment_slots s ON s.id = po.slot_id
  JOIN public.shops sh ON sh.id = s.shop_id
  WHERE po.id = p_override_id
    AND sh.user_id = auth.uid()
    AND po.archived_at IS NULL;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  -- Compute the post-update merged values for cross-field checks.
  v_new_start := COALESCE(p_time_window_start, v_existing.time_window_start);
  v_new_end   := COALESCE(p_time_window_end,   v_existing.time_window_end);
  v_new_kind  := COALESCE(p_adjustment_kind,   v_existing.adjustment_kind);
  v_new_value := COALESCE(p_adjustment_value,  v_existing.adjustment_value);
  v_new_from  := COALESCE(p_valid_from,        v_existing.valid_from);
  v_new_until := COALESCE(p_valid_until,       v_existing.valid_until);

  -- Same field validation as create — run against merged values.
  IF p_name IS NOT NULL AND (char_length(p_name) NOT BETWEEN 1 AND 80) THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'NAME_LENGTH_INVALID';
  END IF;
  IF p_day_of_week IS NOT NULL AND p_day_of_week NOT BETWEEN 1 AND 7 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'DAY_OF_WEEK_OUT_OF_RANGE';
  END IF;
  IF v_new_end <= v_new_start THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'WINDOW_NOT_ORDERED';
  END IF;
  IF v_new_kind NOT IN
     ('percent_discount','percent_surcharge','fixed_discount','fixed_surcharge') THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'ADJUSTMENT_KIND_INVALID';
  END IF;
  IF v_new_value <= 0 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'ADJUSTMENT_VALUE_INVALID';
  END IF;
  IF v_new_kind IN ('percent_discount','percent_surcharge') AND v_new_value > 100 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'PERCENT_OUT_OF_RANGE';
  END IF;
  IF v_new_until IS NOT NULL AND v_new_until <= v_new_from THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'VALIDITY_NOT_ORDERED';
  END IF;

  -- Apply. COALESCE leaves unchanged fields untouched.
  -- NOTE: day_of_week and valid_until cannot be CLEARED via this RPC — passing
  -- NULL is the "unchanged" sentinel. v1 owner workaround for clearing is
  -- archive + recreate. v2 will add explicit clear sentinels.
  UPDATE public.pricing_overrides SET
    name              = COALESCE(p_name,               name),
    day_of_week       = CASE WHEN p_day_of_week IS NULL THEN day_of_week ELSE p_day_of_week END,
    time_window_start = COALESCE(p_time_window_start,  time_window_start),
    time_window_end   = COALESCE(p_time_window_end,    time_window_end),
    adjustment_kind   = COALESCE(p_adjustment_kind,    adjustment_kind),
    adjustment_value  = COALESCE(p_adjustment_value,   adjustment_value),
    valid_from        = COALESCE(p_valid_from,         valid_from),
    valid_until       = CASE WHEN p_valid_until IS NULL THEN valid_until ELSE p_valid_until END,
    is_active         = COALESCE(p_is_active,          is_active),
    updated_at        = now()
  WHERE id = p_override_id;
END;
$function$;

REVOKE ALL ON FUNCTION public.update_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ, BOOLEAN) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.update_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ, BOOLEAN) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.update_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ, BOOLEAN) TO authenticated;

COMMENT ON FUNCTION public.update_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ, BOOLEAN) IS
  'Phase 15: owner-only partial update. Authz via pricing_overrides → appointment_slots → shops chain. NULL params leave fields unchanged (day_of_week / valid_until cannot be cleared in v1 — workaround is archive + recreate). Cross-field checks run on merged values. SECURITY DEFINER.';
```

### 4. `20260611000300_archive_pricing_override_rpc.sql`

Idempotent soft-delete. Mirrors `archive_appointment_slot`
([20260605000200](../../../supabase/migrations/20260605000200_archive_appointment_slot_rpc.sql)).

```sql
CREATE OR REPLACE FUNCTION public.archive_pricing_override(
  p_override_id UUID
) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
BEGIN
  IF p_override_id IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'NULL_NOT_ALLOWED';
  END IF;

  -- Authz via slot → shop chain. Sanitized 'not_found' on mismatch.
  IF NOT EXISTS (
    SELECT 1 FROM public.pricing_overrides po
    JOIN public.appointment_slots s ON s.id = po.slot_id
    JOIN public.shops sh ON sh.id = s.shop_id
    WHERE po.id = p_override_id
      AND sh.user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  -- Idempotent: re-archiving an already-archived row is a no-op (WHERE clause
  -- filters out rows where archived_at IS NOT NULL).
  UPDATE public.pricing_overrides
     SET archived_at = now()
   WHERE id = p_override_id
     AND archived_at IS NULL;
END;
$function$;

REVOKE ALL ON FUNCTION public.archive_pricing_override(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.archive_pricing_override(UUID) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.archive_pricing_override(UUID) TO authenticated;

COMMENT ON FUNCTION public.archive_pricing_override(UUID) IS
  'Phase 15: owner-only soft-delete. Idempotent (no-op when row is already archived). Authz via pricing_overrides → appointment_slots → shops chain. SECURITY DEFINER.';
```

### 5. `20260611000400_apply_pricing_overrides_to_generate_slots.sql`

The heaviest migration. Rewrites the body of `generate_available_slots`
([20260605000300_archive_filter_cascade.sql:244-393](../../../supabase/migrations/20260605000300_archive_filter_cascade.sql#L244-L393))
in three coordinated changes:

1. **EXTRACT(DOW) → EXTRACT(ISODOW)** (Sunday bug fix). The original code at
   line 291 computes 0..6 with Sun=0 and joins against `shop_opening_hours.day_of_week=7`,
   silently dropping Sunday bookings. The planner brief LOCKS the ISODOW fix as
   part of the same migration. Cite RESEARCH §3 in the migration COMMENT.
2. **Pre-materialize active overrides** via `jsonb_agg` ONCE per RPC call,
   before the FOREACH loop. RESEARCH §2 lines 207–293. Avoids 450x re-execution
   on a typical 9-hour day × 5 services × 30-min slot grid.
3. **Per-slot override resolution** via a `WITH ranked AS (...)` lookup against
   the materialized array, ordered by the 3-tier ladder
   (specificity DESC, window_seconds ASC, created_at DESC) LIMIT 1. The winning
   override produces `v_eff_price`; the unmodified base flows into the NEW
   `base_price NUMERIC` RETURN column. Backward-compatible — clients reading
   the existing fields see no change; new field is additive.

The signature changes: RETURN TABLE adds `base_price NUMERIC` between `price`
and `available_workers`. Existing call sites that read positional fields would
break; the codebase reads named JSON keys via `TimeSlotModel.fromJson` (verified
via grep — Wave 0 pre-flight confirms), so new field is silently absorbed.

```sql
-- Phase 15: rewrite generate_available_slots to apply pricing_overrides and
-- emit a new `base_price` column so the client can render the discount/
-- surcharge chip.
--
-- Three changes from the prior body
-- (20260605000300_archive_filter_cascade.sql:244-393):
--   (1) EXTRACT(DOW) → EXTRACT(ISODOW). The original returned 0..6 with
--       Sunday=0, which never matched shop_opening_hours.day_of_week=7,
--       silently dropping Sunday bookings (RESEARCH §3 — corroborated by
--       prod data showing appointment_slots.days_of_week rows in 1..6 only).
--       ISODOW returns 1..7 with Mon=1, Sun=7 — matches the join target.
--   (2) Pre-materialize active overrides once per RPC call as a JSONB array.
--       The hot-path WHILE loop then looks up the winning override per
--       (v_svc.id, v_dow, v_t) against the materialized array. ~450x cheaper
--       than re-querying pricing_overrides on every iteration on a typical
--       9h × 5-service × 30-min grid.
--   (3) Add `base_price NUMERIC` to the RETURN TABLE. `price` carries the
--       effective (post-override) value; `base_price` carries the unmodified
--       appointment_slots.price. Zero-override shops see price == base_price.

CREATE OR REPLACE FUNCTION public.generate_available_slots(
  p_shop_id                 UUID,
  p_date                    DATE,
  p_service_ids             UUID[],
  p_quantities              INT[],
  p_selected_worker_ids     UUID[] DEFAULT NULL,
  p_default_buffer_minutes  INT    DEFAULT NULL
)
RETURNS TABLE (
  slot_id                    UUID,
  service_name               TEXT,
  start_time                 TIMESTAMPTZ,
  end_time                   TIMESTAMPTZ,
  actual_end_time            TIMESTAMPTZ,
  price                      NUMERIC,
  base_price                 NUMERIC,   -- Phase 15: pre-override base
  available_workers          JSONB,
  remaining_spots            INT,
  requires_worker_selection  BOOLEAN,
  buffer_minutes             INT
)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public
AS $function$
DECLARE
  -- All existing variables PRESERVED from
  -- 20260605000300_archive_filter_cascade.sql:244-393. Phase 15 ADDS:
  v_overrides   JSONB := '[]'::jsonb;
  v_eff_price   NUMERIC;
  v_base_price  NUMERIC;
  v_dow         INT;
  -- ... (remainder of existing DECLARE block: v_use_selected, v_opens,
  --      v_closes, v_closed, v_i, v_svc_id, v_svc, v_dur_min, v_t, v_end,
  --      v_actual_end, etc. — copied verbatim from prior body.)
BEGIN
  v_use_selected := COALESCE(p_selected_worker_ids IS NOT NULL
                             AND cardinality(p_selected_worker_ids) > 0, FALSE);

  -- Phase 15: ISODOW (Mon=1..Sun=7) — fixes the latent Sunday bug.
  v_dow := EXTRACT(ISODOW FROM p_date)::INT;

  SELECT opens_at, closes_at, COALESCE(is_closed, false)
    INTO v_opens, v_closes, v_closed
  FROM shop_opening_hours
  WHERE shop_id = p_shop_id AND day_of_week = v_dow
  LIMIT 1;
  IF NOT FOUND OR v_closed THEN
    RETURN;
  END IF;

  -- Phase 15: pre-materialize active overrides for every service in the call,
  -- restricted to "could match v_dow today". One scan over the partial index
  -- idx_pricing_overrides_active_slot. Filter:
  --   - slot_id IN p_service_ids
  --   - is_active AND NOT archived
  --   - day_of_week NULL (all-week) OR day_of_week = today's ISODOW
  --   - valid_from <= now() < valid_until (or valid_until NULL)
  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'slot_id',         o.slot_id,
    'day_of_week',     o.day_of_week,
    'window_start',    o.time_window_start,
    'window_end',      o.time_window_end,
    'kind',            o.adjustment_kind,
    'value',           o.adjustment_value,
    'specificity',     (o.day_of_week IS NOT NULL)::int,  -- 1 = day-specific
    'window_seconds',  EXTRACT(EPOCH FROM (o.time_window_end - o.time_window_start)),
    'created_at',      o.created_at
  )), '[]'::jsonb) INTO v_overrides
  FROM pricing_overrides o
  WHERE o.slot_id = ANY(p_service_ids)
    AND o.is_active = TRUE
    AND o.archived_at IS NULL
    AND (o.day_of_week IS NULL OR o.day_of_week = v_dow)
    AND o.valid_from <= now()
    AND (o.valid_until IS NULL OR o.valid_until > now());

  v_i := 1;
  FOREACH v_svc_id IN ARRAY p_service_ids LOOP
    -- Existing per-service slot fetch — unchanged from prior body.
    -- (SELECT s.* INTO v_svc FROM appointment_slots s WHERE s.id = v_svc_id
    --   AND s.archived_at IS NULL LIMIT 1;)
    -- ...

    v_t := (p_date + v_opens)::TIMESTAMPTZ;
    WHILE v_t::TIME <= v_closes - (v_dur_min || ' minutes')::INTERVAL LOOP
      v_end := v_t + (v_dur_min || ' minutes')::INTERVAL;
      v_actual_end := v_end + (COALESCE(v_svc.buffer_minutes,
                                        p_default_buffer_minutes, 0)
                              || ' minutes')::INTERVAL;
      -- Existing worker resolution — unchanged.

      -- Phase 15: resolve the winning override for (v_svc.id, v_t::TIME).
      -- 3-tier ladder:
      --   1. day_of_week NOT NULL beats day_of_week NULL (specificity DESC)
      --   2. narrower window beats wider (window_seconds ASC)
      --   3. newer beats older (created_at DESC) — final tiebreak
      v_base_price := COALESCE(v_svc.price, 0);
      v_eff_price  := v_base_price;

      WITH ranked AS (
        SELECT
          (o->>'kind')                          AS kind,
          ((o->>'value')::NUMERIC)              AS value,
          ((o->>'specificity')::INT)            AS specificity,
          ((o->>'window_seconds')::NUMERIC)     AS window_seconds,
          (o->>'created_at')::TIMESTAMPTZ       AS created_at
        FROM jsonb_array_elements(v_overrides) o
        WHERE (o->>'slot_id')::UUID = v_svc.id
          AND v_t::TIME >= (o->>'window_start')::TIME
          AND v_t::TIME <  (o->>'window_end')::TIME
      )
      SELECT
        CASE kind
          WHEN 'percent_discount'  THEN GREATEST(v_base_price * (1 - value/100.0), 0)
          WHEN 'percent_surcharge' THEN v_base_price * (1 + value/100.0)
          WHEN 'fixed_discount'    THEN GREATEST(v_base_price - value, 0)
          WHEN 'fixed_surcharge'   THEN v_base_price + value
        END
      INTO v_eff_price
      FROM ranked
      ORDER BY specificity DESC, window_seconds ASC, created_at DESC
      LIMIT 1;

      -- COALESCE — if no override matched, fall back to base.
      v_eff_price := COALESCE(v_eff_price, v_base_price);

      -- Existing group / individual branches PRESERVED, but with:
      --   price      := v_eff_price;
      --   base_price := v_base_price;
      -- instead of the single
      --   price := COALESCE(v_svc.price, 0);
      -- assignment at lines 365 and 380 of the prior body.
      -- ... RETURN NEXT in each branch ...

      v_t := v_t + (v_dur_min || ' minutes')::INTERVAL;
    END LOOP;
  END LOOP;
END;
$function$;

-- REVOKE / GRANT / COMMENT preserved verbatim from prior migration (the
-- signature additions are purely additive to RETURN TABLE; the parameter
-- list is unchanged, so the existing GRANT EXECUTE remains valid).
COMMENT ON FUNCTION public.generate_available_slots(UUID, DATE, UUID[], INT[], UUID[], INT) IS
  'Phase 15 rewrite of the body: pre-materializes active pricing_overrides once per RPC call, resolves the winning override per generated slot via the 3-tier ladder (specificity → window width → recency), and emits both effective price (`price`) and base price (`base_price`) so the client can render the discount/surcharge chip without a second RPC call. Also fixes the latent EXTRACT(DOW) Sunday bug by switching to EXTRACT(ISODOW). Backward-compatible: zero-override shops see price == base_price and no behavior change. RESEARCH §2 + §3 + §16.';
```

**Executor note.** The full body of the prior `generate_available_slots`
function lives in
[20260605000300_archive_filter_cascade.sql:244-393](../../../supabase/migrations/20260605000300_archive_filter_cascade.sql#L244-L393).
The executor must:
1. Read that file in full.
2. Copy the entire function body verbatim into the new migration.
3. Apply the three changes documented above at the exact insertion points
   (EXTRACT line, top-of-body override materialize, both `RETURN NEXT`
   branches at lines 365 and 380 of the prior body).
4. Preserve all existing worker-resolution, buffer math, and concurrency
   logic byte-for-byte. Phase 15 is additive — no behavior change outside
   the price computation and the Sunday fix.

## Client architecture

### `PricingOverrideDTO` + `AdjustmentKind` enum

Plain model. RESEARCH §14 lines 1061–1091.

```dart
// lib/presentation/features/shops/dashboard/data/models/pricing_override_dto.dart

enum AdjustmentKind {
  percentDiscount('percent_discount'),
  percentSurcharge('percent_surcharge'),
  fixedDiscount('fixed_discount'),
  fixedSurcharge('fixed_surcharge');

  const AdjustmentKind(this.dbValue);
  final String dbValue;

  static AdjustmentKind fromDb(String v) =>
      values.firstWhere((k) => k.dbValue == v);

  bool get isDiscount => this == percentDiscount || this == fixedDiscount;
  bool get isPercent  => this == percentDiscount || this == percentSurcharge;
}

class PricingOverrideDTO {
  final String id;
  final String slotId;
  final String name;
  final int? dayOfWeek;            // 1..7 or null (all-week)
  final String timeWindowStart;    // "HH:mm:ss"
  final String timeWindowEnd;
  final AdjustmentKind kind;
  final double value;
  final DateTime validFrom;
  final DateTime? validUntil;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PricingOverrideDTO({...});

  factory PricingOverrideDTO.fromJson(Map<String, dynamic> json) => ...;
  Map<String, dynamic> toJson() => ...;
}
```

### `PricingOverrideException` hierarchy

Mirrors `PromotionException`. RESEARCH §9 lines 815–876.

```dart
// lib/.../data/exceptions/pricing_override_exceptions.dart

class PricingOverrideException implements Exception {
  final String message;
  final String code;
  final String userMessage;
  PricingOverrideException(this.message,
      {this.code = 'OVERRIDE_GENERIC', String? userMessage})
      : userMessage = userMessage ?? 'Something went wrong. Please try again.';
  @override String toString() => 'PricingOverrideException($code): $message';
}

class OverrideAccessDeniedException extends PricingOverrideException {
  OverrideAccessDeniedException()
      : super('Caller does not own the parent shop',
          code: 'OVERRIDE_NOT_FOUND',
          userMessage: "We couldn't find that pricing rule.");
}

class OverrideWindowInvalidException extends PricingOverrideException { ... }
class OverrideDayOfWeekInvalidException extends PricingOverrideException { ... }
class OverrideAdjustmentInvalidException extends PricingOverrideException { ... }
class OverrideValidityInvalidException extends PricingOverrideException { ... }
class OverrideCapExceededException extends PricingOverrideException { ... }
class OverrideSaveFailedException extends PricingOverrideException { ... }
```

`userMessage` strings are EN fallbacks. The screen swaps to `AppLocalizations`
lookups (`loc.pricingOverrideErrorWindow`, etc.) — the fallback keeps the
exception unit-testable in isolation. PromotionException precedent.

### `_classifyPricingOverrideError` (in `SupabaseDashboardRepository`)

Added next to the existing `_classifyPromotionError` (verify location via
grep — likely co-located with the promotion classifier). HINT-driven, NO string
matching on `e.message`. RESEARCH §9 lines 881–898.

| Postgres `errcode` | HINT | Dart exception |
|--------------------|------|----------------|
| 42501 | (any — sanitized) | `OverrideAccessDeniedException` |
| 22023 | `WINDOW_NOT_ORDERED` | `OverrideWindowInvalidException` |
| 22023 | `DAY_OF_WEEK_OUT_OF_RANGE` | `OverrideDayOfWeekInvalidException` |
| 22023 | `ADJUSTMENT_KIND_INVALID` / `ADJUSTMENT_VALUE_INVALID` / `PERCENT_OUT_OF_RANGE` | `OverrideAdjustmentInvalidException` |
| 22023 | `VALIDITY_NOT_ORDERED` | `OverrideValidityInvalidException` |
| 22023 | `OVERRIDE_CAP_EXCEEDED` | `OverrideCapExceededException` |
| 22023 | `NAME_LENGTH_INVALID` / `REQUIRED_FIELD_MISSING` / `NULL_NOT_ALLOWED` | `OverrideSaveFailedException` |
| (any other) | (any) | `OverrideSaveFailedException` |

### Four new repository methods

Extend `DashboardRepository` (abstract) + `SupabaseDashboardRepository`
(concrete) in place. RESEARCH §14 lines 1015–1044.

```dart
// (additions to lib/.../data/repositories/dashboard_repository.dart)

Future<String> createPricingOverride({
  required String slotId,
  required String name,
  int? dayOfWeek,              // 1..7 or null
  required String timeWindowStart, // "HH:mm" or "HH:mm:ss"
  required String timeWindowEnd,
  required AdjustmentKind kind,
  required double value,
  DateTime? validFrom,
  DateTime? validUntil,
});

Future<void> updatePricingOverride({
  required String overrideId,
  String? name,
  int? dayOfWeek,
  String? timeWindowStart,
  String? timeWindowEnd,
  AdjustmentKind? kind,
  double? value,
  DateTime? validFrom,
  DateTime? validUntil,
  bool? isActive,
});

Future<void> archivePricingOverride(String overrideId);

Future<List<PricingOverrideDTO>> listPricingOverrides({required String slotId});
```

Implementation in `SupabaseDashboardRepository`:

```dart
@override
Future<String> createPricingOverride({...}) async {
  try {
    final id = await _client.rpc('create_pricing_override', params: {
      'p_slot_id': slotId,
      'p_name': name,
      'p_day_of_week': dayOfWeek,
      'p_time_window_start': timeWindowStart,
      'p_time_window_end': timeWindowEnd,
      'p_adjustment_kind': kind.dbValue,
      'p_adjustment_value': value,
      'p_valid_from': validFrom?.toIso8601String(),
      'p_valid_until': validUntil?.toIso8601String(),
    });
    return id as String;
  } on PostgrestException catch (e) {
    AppLogger.error('createPricingOverride failed', e,
      slot_id: slotId, kind: kind.dbValue, error_code: e.code);
    throw _classifyPricingOverrideError(e);
  }
}

@override
Future<List<PricingOverrideDTO>> listPricingOverrides({required String slotId}) async {
  try {
    final rows = await _client
        .from('pricing_overrides')
        .select()
        .eq('slot_id', slotId)
        .filter('archived_at', 'is', null)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => PricingOverrideDTO.fromJson(r as Map<String, dynamic>))
        .toList();
  } on PostgrestException catch (e) {
    AppLogger.error('listPricingOverrides failed', e,
      slot_id: slotId, error_code: e.code);
    throw _classifyPricingOverrideError(e);
  }
}

// updatePricingOverride / archivePricingOverride follow the same shape.
```

Every method logs `slot_id` (or `override_id`) + `error_code` on failure —
matches the AppLogger field convention from PromotionsRepository.

### Provider

```dart
// lib/.../providers/pricing_overrides_provider.dart

final pricingOverridesProvider = FutureProvider.family
    .autoDispose<List<PricingOverrideDTO>, String>((ref, slotId) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.listPricingOverrides(slotId: slotId);
});
```

`autoDispose` because the list screen is short-lived (modal nav from
ServiceEditScreen). Invalidated after each mutation in the form screen via
`ref.invalidate(pricingOverridesProvider(slotId))` before popping.

### `PricingOverridesListScreen`

Lists active overrides for a given slot. RESEARCH §15 + §17.

| State | Body |
|-------|------|
| Loading (`AsyncLoading`) | Centered `CircularProgressIndicator`. |
| Error (`AsyncError`) | `ErrorState` widget with reload button. Message via `PricingOverrideException.userMessage` if applicable, else generic. |
| Data, empty | Empty state: `loc.pricingOverridesEmptyTitle` + `loc.pricingOverridesEmptyBody`. |
| Data, non-empty | `ListView.separated` of `_OverrideRow` widgets. Pull-to-refresh invalidates the provider. |

`_OverrideRow`: leading = adjustment-kind icon (discount = `Icons.percent` or
`Icons.local_offer`; surcharge = `Icons.trending_up`). Center = owner-defined
`name` + formatted summary ("Mon, 09:00–12:00, 20% off"). Trailing =
`PopupMenuButton` with **Edit** + **Archive** (with confirmation dialog —
`loc.pricingOverrideArchiveConfirmTitle` + `loc.pricingOverrideArchiveConfirmBody`).

FAB → push `PricingOverrideFormScreen(slot: slot, override: null)` (create
mode). Tap row → push `PricingOverrideFormScreen(slot: slot, override: row)`
(edit mode).

### `PricingOverrideFormScreen`

LoyaltyRuleScreen / CreateBroadcastScreen precedent — explicit Save, dirty-check,
error toasts. Form fields top to bottom (RESEARCH §17 keys):

1. **Name** — `TextField`, maxLength 80, counter. Helper: `loc.pricingOverrideFieldNameHelper`. Validator: non-empty after trim.
2. **Day of week** — `DropdownButtonFormField<int?>` with 8 entries: "All week" (null) + Mon..Sun (1..7). Default = null.
3. **Start time** — `TextField` with `showTimePicker` on tap. 24-hour. Formatted "HH:mm".
4. **End time** — same. Validator: end > start (matches schema CHECK).
5. **Adjustment kind** — `SegmentedButton<AdjustmentKind>` with 4 segments.
6. **Value** — `TextField` numeric. Helper changes by kind: "%" for percent kinds, "$ amount" (or `shop.currency` prefix) for fixed kinds. Validator: > 0; ≤ 100 for percent kinds.
7. **Valid from** — `DateTime` picker. Default = now.
8. **Valid until** — optional `DateTime` picker. Default = null (no expiry).
9. **Live price preview** — read-only "Example" panel (uses `loc.pricingOverridePreviewLabel` + `pricingOverridePreviewBody`). Computes effective price client-side from current form values + `slot.price`. Shows: "A 10:00 Tuesday slot would price at $40 (saved $10 vs $50 base)."
10. **Soft warnings** — yellow banner when `kind == percent_surcharge && value > 50` ("Surcharge over 50%. Confirm intent.") OR `kind == fixed_surcharge && value > 5 * slot.price` ("Surcharge over 5x base price. Confirm intent."). Warns; does NOT block Save.
11. **Save button** — `FilledButton`. Disabled until all required fields valid.

Tap Save → call `createPricingOverride` (create mode) or `updatePricingOverride`
(edit mode). On success: invalidate `pricingOverridesProvider(slotId)`, pop. On
`PricingOverrideException`: SnackBar with `e.userMessage` (swap to
`AppLocalizations` lookup at SnackBar build time). Back-button intercept when
dirty: "Discard?" dialog.

State management: `StateNotifierProvider.autoDispose` (`PricingOverrideFormController`)
holding form state + dirty hash + sending state. Dirty check via comparing
current state hash to the initial-state hash.

### `ServiceEditScreen` patch

RESEARCH §15 lines 1118–1144. Add ONE AppBar `IconButton`:

```dart
return Scaffold(
  appBar: AppBar(
    title: Text(_isEdit ? loc.editService : loc.newService),
    actions: [
      if (_isEdit && initial != null)
        IconButton(
          icon: const Icon(Icons.price_change_outlined),
          tooltip: loc.pricingOverridesTitle,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PricingOverridesListScreen(
                shopId: shopId,
                slot: initial!,
              ),
            ),
          ),
        ),
    ],
  ),
  body: ...
);
```

Visible only in edit mode (when the parent slot already has a UUID).

### `TimeSlotModel.basePrice` field add

```dart
// lib/.../booking/data/models/time_slot_model.dart

class TimeSlotModel {
  // ... existing fields ...
  final double price;       // effective (post-override)
  final double? basePrice;  // Phase 15: pre-override base; null when RPC omits

  // ... existing constructor ...

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      // ... existing fields ...
      price: (json['price'] as num).toDouble(),
      basePrice: (json['base_price'] as num?)?.toDouble(),  // NEW
      // ... existing fields ...
    );
  }
}
```

Backward-compatible: when `generate_available_slots` returns the new column,
`basePrice` is non-null. Pre-deploy / old-RPC fallback: `basePrice == null`,
chip does not render.

### `time_slot_chip.dart` patch

Restore the commented-out price block at lines 136–145 AND add the
`_AdjustmentBadge` sub-widget. RESEARCH §16 lines 1157–1255.

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    if (slot.bufferMinutes > 0)
      Text('${slot.bufferMinutes}m buffer', style: ...),
    Row(children: [
      Text(
        '${currency} ${slot.price.toStringAsFixed(2)}',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
        ),
      ),
      if (slot.basePrice != null && slot.basePrice != slot.price) ...[
        const SizedBox(width: 6),
        _AdjustmentBadge(isDiscount: slot.price < slot.basePrice!),
      ],
    ]),
  ],
)

class _AdjustmentBadge extends StatelessWidget {
  final bool isDiscount;
  const _AdjustmentBadge({required this.isDiscount});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isDiscount ? scheme.tertiary : scheme.error;
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isDiscount ? loc.pricingChipDiscount : loc.pricingChipSurcharge,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

The owner-defined `name` is NEVER surfaced to the client (SPEC line 90).

### `booking_confirmation_screen.dart` PATCH (CRITICAL)

RESEARCH §1 lines 81–149. Without this patch, owners see chips but clients pay
the base. Phase 15's #1 risk.

**Line 302–310 (`_calculateTotalPrice`):**

```dart
// BEFORE (base price — WRONG):
double _calculateTotalPrice(
  List<AppointmentSlotDTO> services,
  Map<String, int> quantities,
) {
  return services.fold<double>(
    0,
    (sum, service) => sum + service.price * (quantities[service.id] ?? 1),
  );
}

// AFTER (effective price — Phase 15):
double _calculateTotalPrice(
  List<AppointmentSlotDTO> services,
  Map<String, int> quantities,
  Map<String, TimeSlotModel> timeSlots,
) {
  return services.fold<double>(
    0,
    (sum, service) {
      final effectivePrice = timeSlots[service.id]?.price ?? service.price;
      return sum + effectivePrice * (quantities[service.id] ?? 1);
    },
  );
}
```

The `?? service.price` fallback covers the "TimeSlotModel map missing this
entry" defensive case. The effective vs. base equivalence is: when no override
matches, `generate_available_slots` returns `price == base_price == slot.price`
— so the math is identical for zero-override shops.

**Line 340–359 (`servicesData` payload):**

```dart
// BEFORE — priceAtBooking from service.price (base):
return List.generate(qty, (i) {
  final worker = i < workerEntries.length ? workerEntries[i] : null;
  return {
    'slotId': service.id,
    'workerId': worker?['id'],
    'priceAtBooking': service.price,  // ← base, WRONG
    'durationMinutes': DurationUtils.parse(service.duration).inMinutes,
    'serviceName': service.serviceName,
    'workerName': worker?['name'] ?? '',
  };
});

// AFTER — priceAtBooking from effective:
return List.generate(qty, (i) {
  final worker = i < workerEntries.length ? workerEntries[i] : null;
  final effectivePrice = timeSlots[service.id]?.price ?? service.price;
  return {
    'slotId': service.id,
    'workerId': worker?['id'],
    'priceAtBooking': effectivePrice,
    'durationMinutes': DurationUtils.parse(service.duration).inMinutes,
    'serviceName': service.serviceName,
    'workerName': worker?['name'] ?? '',
  };
});
```

All `_calculateTotalPrice(...)` call sites pass the `timeSlots` map. The
screen already holds it (state.timeSlots, or equivalent) — the executor
verifies the field name via grep and threads it through.

**Promo composition.** With this patch, `validate_and_apply_promo` is called
with `bookingTotal: <effective total>`. The promo RPC operates on the passed-in
number ([20260606000300:76-78](../../../supabase/migrations/20260606000300_validate_and_apply_promo_rpc.sql#L76-L78))
— no slot.price lookup, no per-service base re-derivation. Stacking is
deterministic: override → promo → final. SPEC §non-functional / "Promo
composition" line 151 holds.

### `booking_creation_controller.dart` PATCH

RESEARCH §1 lines 150–155. Same `timeSlots[service.id]?.price ?? service.price`
swap at:

- Line 462: `priceAtBooking: service.price` → `priceAtBooking: effectivePrice`
  inside the local `BookingServiceModel` construction.
- Line 496: same swap inside the second `BookingServiceModel` construction
  (the non-payment-provider / dev-path branch).

The controller already has the slot id and the `timeSlots` map in scope (verify
via grep on the function signature). If `timeSlots` is not in scope, thread it
through the public method signature.

## i18n keys (Wave 5)

Add to `lib/i10n/app_en.arb` only. EN only. RESEARCH §17 lines 1264–1298:

| Key | Value (EN) |
|-----|------------|
| `pricingOverridesTitle` | "Pricing rules" |
| `pricingOverridesEmptyTitle` | "No pricing rules yet" |
| `pricingOverridesEmptyBody` | "Tap + to add a discount or surcharge for specific days and times." |
| `pricingOverrideAddCta` | "Add rule" |
| `pricingOverrideFormTitleAdd` | "New pricing rule" |
| `pricingOverrideFormTitleEdit` | "Edit pricing rule" |
| `pricingOverrideFieldName` | "Name (private)" |
| `pricingOverrideFieldNameHelper` | "Only you see this. Clients see the discount or surcharge badge, not the name." |
| `pricingOverrideFieldDayOfWeek` | "Day" |
| `pricingOverrideDayAllWeek` | "All week" |
| `pricingOverrideFieldStart` | "Starts at" |
| `pricingOverrideFieldEnd` | "Ends at" |
| `pricingOverrideFieldKind` | "Adjustment" |
| `pricingOverrideKindPercentDiscount` | "Percent off" |
| `pricingOverrideKindPercentSurcharge` | "Percent extra" |
| `pricingOverrideKindFixedDiscount` | "Amount off" |
| `pricingOverrideKindFixedSurcharge` | "Amount extra" |
| `pricingOverrideFieldValue` | "Amount" |
| `pricingOverrideFieldValidFrom` | "Valid from" |
| `pricingOverrideFieldValidUntil` | "Valid until (optional)" |
| `pricingOverridePreviewLabel` | "Example" |
| `pricingOverridePreviewBody` | "A 10am Tuesday slot would price at {effective} (saved {delta} vs {base})." |
| `pricingOverrideWarnHighSurcharge` | "Surcharge over 50%. Confirm intent." |
| `pricingOverrideWarnExtremeFixed` | "Surcharge over 5× base price. Confirm intent." |
| `pricingOverrideSaveCta` | "Save rule" |
| `pricingOverrideArchiveCta` | "Archive" |
| `pricingOverrideArchiveConfirmTitle` | "Archive this rule?" |
| `pricingOverrideArchiveConfirmBody` | "Future bookings will use the base price. Existing bookings keep their prices." |
| `pricingOverrideErrorWindow` | "End time must be later than start time." |
| `pricingOverrideErrorDow` | "Please pick a valid day of the week." |
| `pricingOverrideErrorAdjustment` | "Please pick a discount or surcharge with a valid amount." |
| `pricingOverrideErrorPercent` | "Percent must be between 1 and 100." |
| `pricingOverrideErrorValidity` | "The 'Valid until' date must be after the 'Valid from' date." |
| `pricingOverrideErrorCap` | "You can have up to 50 rules per service. Archive an old one first." |
| `pricingOverrideErrorAccess` | "We couldn't find that pricing rule." |
| `pricingOverrideErrorGeneric` | "We couldn't save the rule. Please try again." |
| `pricingChipDiscount` | "Discount" |
| `pricingChipSurcharge` | "Surcharge" |

(Tally ~38 — overshoots planner brief's "~20" but in the right ballpark, same
overshoot as Phase 14's "~25" → 32.)

## Tasks

Atomic. Each touches ≤ 3 files unless explicitly justified inline. Each maps to
≥ 1 acceptance test in the Verification matrix. Estimates in minutes.

### Wave 0 — Schema (pre-flight gated)

**Task 0.0 — Run pre-flight checks**
- File(s): n/a (operational; staging then prod).
- Description: Execute the seven pre-flight SELECTs against staging, then prod. Capture output in PR description. **BLOCK migration deployment if check (1) reports `appointment_slots.id` not UUID, or check (3) reports any 0 in `shop_opening_hours.day_of_week`, or check (7) reports a pre-existing `pricing_overrides` table.**
- Acceptance: All seven checks return expected shape. Outputs pasted into PR description.
- Estimate: 15

**Task 0.1 — Create `pricing_overrides` table + RLS + partial index**
- File(s): `supabase/migrations/20260611000000_pricing_overrides_table.sql` (NEW)
- Description: Per Migration Plan §1. Table + 3 CHECK constraints (window order, percent range, validity order) + partial index `idx_pricing_overrides_active_slot` + RLS-enabled + SELECT-only owner policy. NO INSERT / UPDATE / DELETE policies. day_of_week LOCKED to 1..7.
- Acceptance: `\d public.pricing_overrides` shows all 14 columns + the 3 CHECK constraints. `SELECT polname FROM pg_policies WHERE tablename='pricing_overrides'` returns exactly 1 row (`pricing_overrides_owner_select`). Smoke §A (table + RLS owner-only verify) passes.
- Rollback: `DROP TABLE public.pricing_overrides CASCADE`. Safe — no prior callers.
- Estimate: 30

### Wave 1 — Server logic (depends on Wave 0)

**Task 1.1 — Create `create_pricing_override` RPC**
- File(s): `supabase/migrations/20260611000100_create_pricing_override_rpc.sql` (NEW)
- Description: Per Migration Plan §2. Authz-first via slot→shop chain. NULL-shape, field validation, per-slot 50-cap check — all HINT-coded. HINT codes: `REQUIRED_FIELD_MISSING`, `NAME_LENGTH_INVALID`, `DAY_OF_WEEK_OUT_OF_RANGE`, `WINDOW_NOT_ORDERED`, `ADJUSTMENT_KIND_INVALID`, `ADJUSTMENT_VALUE_INVALID`, `PERCENT_OUT_OF_RANGE`, `VALIDITY_NOT_ORDERED`, `OVERRIDE_CAP_EXCEEDED`. Double REVOKE (FROM PUBLIC + FROM authenticated) + GRANT EXECUTE TO authenticated + COMMENT.
- Acceptance: Smoke §B (happy path returns UUID; non-owner caller raises `42501 not_found`) + §K (50-cap raises `OVERRIDE_CAP_EXCEEDED`) pass. `flutter test test/.../pricing_overrides_repository_test.dart` HINT classifier cases pass.
- Rollback: `DROP FUNCTION public.create_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ)`.
- Estimate: 45

**Task 1.2 — Create `update_pricing_override` RPC**
- File(s): `supabase/migrations/20260611000200_update_pricing_override_rpc.sql` (NEW)
- Description: Per Migration Plan §3. Partial update — NULL params = unchanged. Cross-field checks run on merged values. Authz via pricing_overrides → appointment_slots → shops chain. day_of_week locked 1..7. Same HINT codes as create (excluding `OVERRIDE_CAP_EXCEEDED` — update does not change the count).
- Acceptance: Smoke §C (owner-only authz; partial update changes only the named fields) passes. Cross-owner update raises `42501`.
- Rollback: `DROP FUNCTION public.update_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ, BOOLEAN)`.
- Estimate: 45

**Task 1.3 — Create `archive_pricing_override` RPC**
- File(s): `supabase/migrations/20260611000300_archive_pricing_override_rpc.sql` (NEW)
- Description: Per Migration Plan §4. Idempotent soft-delete. Authz via pricing_overrides → appointment_slots → shops chain. `archive_appointment_slot` precedent.
- Acceptance: Smoke §D (archive sets `archived_at`; re-archive is no-op; cross-owner archive raises `42501`) passes.
- Rollback: `DROP FUNCTION public.archive_pricing_override(UUID)`.
- Estimate: 20

**Task 1.4 — Modify `generate_available_slots` (ISODOW fix + override CTE + base_price column)**
- File(s): `supabase/migrations/20260611000400_apply_pricing_overrides_to_generate_slots.sql` (NEW)
- Description: Per Migration Plan §5. The heaviest task — copy the prior body verbatim from [20260605000300:244-393](../../../supabase/migrations/20260605000300_archive_filter_cascade.sql#L244-L393), then apply three changes: (1) `EXTRACT(DOW)` → `EXTRACT(ISODOW)` (Sunday bug fix), (2) JSONB override materialize at top of body, (3) per-(v_svc.id, v_t::TIME) override resolution + `base_price NUMERIC` RETURN column. Worker resolution + buffer math + concurrency logic byte-for-byte preserved. Signature ADDs `base_price NUMERIC` to RETURN TABLE; parameter list unchanged so existing GRANT EXECUTE remains valid.
- Acceptance: Smoke §E (base_price column populated equals slot.price for zero-override service) + §F (single percent_discount applies; effective price matches expected math) + §G (single-day beats all-week) + §H (narrower window beats wider) + §I (newest beats older when both same specificity) + §J (fixed_discount clamps at 0) + §L (ISODOW fix — Sunday slots now generate when shop_opening_hours.day_of_week=7 exists) all pass. `EXPLAIN ANALYZE` on a shop with 50 active overrides shows < 50ms total execution.
- Rollback: Re-run the prior migration body to restore. Documented as paste-the-prior-body, not a forward-fix.
- Estimate: 90

### Wave 2 — Client data layer (depends on Wave 1)

**Task 2.1 — Create `PricingOverrideDTO` + `AdjustmentKind` enum + `PricingOverrideException` hierarchy**
- File(s): `lib/.../data/models/pricing_override_dto.dart` (NEW), `lib/.../data/exceptions/pricing_override_exceptions.dart` (NEW)
- Description: DTO with `AdjustmentKind` enum (4 values + `isDiscount` / `isPercent` getters + `fromDb` factory) and JSON round-trip. Exception hierarchy with 7 subtypes per RESEARCH §9. Each exception carries an EN fallback `userMessage` for test independence; screen swaps to `AppLocalizations` lookup at runtime.
- Acceptance: `flutter analyze` clean. `flutter test test/.../pricing_override_exceptions_test.dart` cases for each subtype (`code` + `userMessage` assertions) pass. DTO `fromJson` / `toJson` round-trip preserves fields including null `dayOfWeek` and null `validUntil`.
- Rollback: Delete both files.
- Estimate: 30

**Task 2.2 — Extend `DashboardRepository` + `SupabaseDashboardRepository` with four pricing-override methods + classifier**
- File(s): `lib/.../data/repositories/dashboard_repository.dart` (EDIT — abstract methods), `lib/.../data/repositories/supabase_dashboard_repository.dart` (EDIT — concrete impl + classifier)
- Description: Append `createPricingOverride`, `updatePricingOverride`, `archivePricingOverride`, `listPricingOverrides` abstract methods + concrete impls. Add `_classifyPricingOverrideError(PostgrestException)` private helper per the table in §"Client architecture > `_classifyPricingOverrideError`". HINT-driven; no string matching. AppLogger fields on every method call (`slot_id` or `override_id`, `error_code`).
- Acceptance: `flutter analyze` clean. `flutter test test/.../pricing_overrides_repository_test.dart` table tests for all 7 HINT → exception mappings (including default-to-`OverrideSaveFailedException`) pass. Existing `DashboardRepository` callers still compile (no signature changes on existing methods).
- Rollback: Revert the two file diffs.
- Estimate: 60

**Task 2.3 — Create `pricingOverridesProvider`**
- File(s): `lib/.../providers/pricing_overrides_provider.dart` (NEW)
- Description: `FutureProvider.family.autoDispose<List<PricingOverrideDTO>, String>` keyed by `slotId`. Watches `dashboardRepositoryProvider`. RESEARCH §14.
- Acceptance: `flutter analyze` clean. Provider compiles; smoke widget test in Task 2.4 / 2.5 uses it via `ProviderScope` override.
- Rollback: Delete the file.
- Estimate: 10

### Wave 3 — Client UI (depends on Wave 2)

**Task 3.1 — Add `basePrice` field to `TimeSlotModel` + patch `time_slot_chip.dart`**
- File(s): `lib/.../booking/data/models/time_slot_model.dart` (EDIT), `lib/.../booking/presentation/widgets/time_slot/time_slot_chip.dart` (EDIT)
- Description: Add `final double? basePrice;` field to `TimeSlotModel` + JSON round-trip reading `json['base_price']`. Restore commented-out price block at lines 136–145 of `time_slot_chip.dart` to display the price. Add `_AdjustmentBadge` sub-widget rendering Discount/Surcharge chip when `slot.basePrice != null && slot.basePrice != slot.price`. Owner-defined `name` NOT surfaced.
- Acceptance: `flutter analyze` clean. `flutter test test/.../time_slot_chip_test.dart` cases: (a) chip absent when basePrice null; (b) chip absent when basePrice == price; (c) "Discount" chip when price < basePrice; (d) "Surcharge" chip when price > basePrice.
- Rollback: Revert both file diffs.
- Estimate: 30

**Task 3.2 — Create `PricingOverridesListScreen`**
- File(s): `lib/.../presentation/screens/pricing_overrides_list_screen.dart` (NEW)
- Description: List view per §"Client architecture > PricingOverridesListScreen". Watches `pricingOverridesProvider(slotId)`. Four states (loading / error / empty / data). `_OverrideRow` with leading kind-icon, center name + summary, trailing PopupMenuButton (Edit / Archive). FAB → push form screen (create mode). Tap row → push form screen (edit mode). Pull-to-refresh invalidates provider. Archive confirmation dialog uses `loc.pricingOverrideArchiveConfirmTitle` + `Body`.
- Acceptance: `flutter analyze` clean. Widget test (in form screen test file under Wave 6) renders empty / loading / data / error states. Tap FAB pushes form screen. Tap row → form screen with override pre-filled.
- Rollback: Delete the file.
- Estimate: 50

**Task 3.3 — Create `PricingOverrideFormScreen` + state controller**
- File(s): `lib/.../presentation/screens/pricing_override_form_screen.dart` (NEW)
- Description: Form per §"Client architecture > PricingOverrideFormScreen". `StateNotifier` for form state + dirty hash + sending state. Time pickers via `showTimePicker`. Day-of-week dropdown with "All week" (null) + Mon..Sun (1..7). Segmented adjustment kind. Live price preview computed client-side. Soft warning banners at >50% surcharge or >5× base on fixed_surcharge — warn, never block. Save → repo create or update (depending on `override` param) → invalidate provider → pop. Error toasts via `AppLocalizations` lookup keyed by exception subtype. Back-button intercept when dirty.
- Acceptance: `flutter analyze` clean. Widget tests under Wave 6 cover: validation gates Save; preview math correct; warnings render; create vs. edit paths; toast on each exception subtype.
- Rollback: Delete the file.
- Estimate: 90

**Task 3.4 — Patch `ServiceEditScreen` AppBar IconButton**
- File(s): `lib/.../presentation/screens/service_edit_screen.dart` (EDIT)
- Description: Add `Icons.price_change_outlined` IconButton to AppBar `actions` per §"Client architecture > ServiceEditScreen patch". Visible only when `_isEdit && initial != null`. onPressed pushes `PricingOverridesListScreen(shopId, slot: initial!)`. Tooltip = `loc.pricingOverridesTitle`.
- Acceptance: `flutter analyze` clean. Widget test (existing service_edit_screen tests, if any — else inline check): icon present in edit mode, absent in create mode. Tap navigates to list screen.
- Rollback: Revert the file diff.
- Estimate: 15

### Wave 4 — Client booking-flow patch (CRITICAL — depends on Wave 3)

**Task 4.1 — Patch `booking_confirmation_screen.dart` (`_calculateTotalPrice` + `servicesData` payload)**
- File(s): `lib/.../booking/presentation/screens/client/booking_confirmation_screen.dart` (EDIT)
- Description: Lines 302–310: change `_calculateTotalPrice` signature to accept `Map<String, TimeSlotModel> timeSlots` and use `timeSlots[service.id]?.price ?? service.price` for the fold. Lines 340–359: read same `effectivePrice` for the `priceAtBooking` field of the `servicesData` payload. All call sites of `_calculateTotalPrice` updated to pass the timeSlots map (the screen already holds it in state). Net additive — zero-override shops see `effective == base`.
- Acceptance: `flutter analyze` clean. Smoke §F (a confirmation with a 20% override returns total = 0.80 × base sum, not base sum). Existing widget tests for the confirmation screen still pass (no regression in zero-override path).
- Rollback: Revert the file diff. **Without this patch, owners see chips but clients pay the base. Critical.**
- Estimate: 35

**Task 4.2 — Patch `booking_creation_controller.dart` (priceAtBooking writes)**
- File(s): `lib/.../booking/presentation/controllers/booking_creation_controller.dart` (EDIT)
- Description: Lines 462 and 496: same `timeSlots[service.id]?.price ?? service.price` swap for `priceAtBooking`. Thread `timeSlots` through the public method signature if not already in scope (verify via grep).
- Acceptance: `flutter analyze` clean. Smoke §F same as Task 4.1.
- Rollback: Revert the file diff.
- Estimate: 25

### Wave 5 — i18n (depends on Wave 3)

**Task 5.1 — Add EN keys to `app_en.arb`**
- File(s): `lib/i10n/app_en.arb` (EDIT)
- Description: Add the ~38 keys listed in §"i18n keys (Wave 5)". Plural-aware on count keys (none in v1 — preview uses placeholder substitution only). Run `flutter gen-l10n` to regenerate `AppLocalizations` getters.
- Acceptance: `flutter gen-l10n` exits 0. `flutter analyze` clean (no missing-key warnings from PricingOverridesListScreen, PricingOverrideFormScreen, or time_slot_chip). All UI strings in the new screens route through `AppLocalizations.of(context)!` getters (verified via grep — no string literals remain in the screen files).
- Rollback: Revert the diff; `flutter gen-l10n` again.
- Estimate: 25

### Wave 6 — Tests (depends on all prior waves)

**Task 6.1 — Write `pricing_override_exceptions_test.dart`**
- File(s): `test/.../data/exceptions/pricing_override_exceptions_test.dart` (NEW)
- Description: One test per subtype (7) asserting `code` and `userMessage` are the locked strings. Round-trip `toString()`.
- Acceptance: `flutter test test/.../pricing_override_exceptions_test.dart` exits 0; 7 cases.
- Estimate: 15

**Task 6.2 — Write `pricing_overrides_repository_test.dart`**
- File(s): `test/.../data/repositories/pricing_overrides_repository_test.dart` (NEW)
- Description: Mock `SupabaseClient` via mocktail. Table tests for `_classifyPricingOverrideError`: feed it a synthetic `PostgrestException` for each (errcode, HINT) pair and assert the resulting Dart subtype. Also test the four repository methods' happy paths: `createPricingOverride` returns parsed UUID; `updatePricingOverride` calls RPC with correct param map; `archivePricingOverride` same; `listPricingOverrides` returns parsed list. Error propagation: PostgrestException → typed exception.
- Acceptance: `flutter test test/.../pricing_overrides_repository_test.dart` exits 0; at least 15 cases (7 classifier + 4 happy paths + 4 error-propagation).
- Estimate: 45

**Task 6.3 — Write `pricing_override_form_screen_test.dart`**
- File(s): `test/.../presentation/screens/pricing_override_form_screen_test.dart` (NEW)
- Description: Widget tests with overridden Riverpod providers. Cases: (a) Save disabled until name + window + kind + value valid; (b) Day dropdown defaults to "All week"; (c) Time picker validation — end ≤ start blocks Save; (d) Percent kind value > 100 blocks Save with the right error; (e) Live preview math: 20% percent_discount on $50 slot shows "$40 (saved $10 vs $50 base)"; (f) Soft warning banner appears at percent_surcharge > 50%; Save is NOT blocked; (g) Soft warning banner appears at fixed_surcharge > 5× base; Save is NOT blocked; (h) Create flow: tap Save → repo.createPricingOverride called with correct params → provider invalidated → screen pops; (i) Edit flow: form pre-filled from override param → tap Save → repo.updatePricingOverride called; (j) Toast on `OverrideCapExceededException` shows `loc.pricingOverrideErrorCap`; (k) Toast on `OverrideWindowInvalidException` shows `loc.pricingOverrideErrorWindow`; (l) Back button when dirty shows Discard dialog.
- Acceptance: `flutter test test/.../pricing_override_form_screen_test.dart` exits 0; at least 12 cases.
- Estimate: 90

**Task 6.4 — Write `time_slot_chip_test.dart`**
- File(s): `test/.../booking/presentation/widgets/time_slot/time_slot_chip_test.dart` (NEW)
- Description: Widget tests for the new `_AdjustmentBadge` rendering. Cases: (a) `basePrice == null` → no chip; (b) `basePrice == price` → no chip; (c) `price < basePrice` → Discount chip with `loc.pricingChipDiscount`; (d) `price > basePrice` → Surcharge chip with `loc.pricingChipSurcharge`; (e) price text displays effective `price` (not basePrice) — semantic check that the visible price is what the client will be charged.
- Acceptance: `flutter test test/.../time_slot_chip_test.dart` exits 0; 5 cases.
- Estimate: 30

**Task 6.5 — Author `15_smoke_tests.sql`**
- File(s): `.planning/phases/15-time-based-pricing/sql/15_smoke_tests.sql` (NEW)
- Description: Hand-runnable SQL smoke per Phase 13 / 14 precedent. BEGIN/ROLLBACK wrapper with SAVEPOINTs per section. `SET LOCAL ROLE authenticated` + `SET LOCAL "request.jwt.claims"` for owner-context tests. `RAISE NOTICE 'OK: ...'` on success. Twelve sections (§A–§L) covering the 10 SPEC success criteria + the 50-cap check + the ISODOW Sunday fix. Reference UUIDs inlined at the top of the file.
- Acceptance: `psql -f .planning/phases/15-time-based-pricing/sql/15_smoke_tests.sql` against a staging branch prints exactly twelve `OK:` lines and `ROLLBACK` at the end. No `FAIL:` lines.
- Estimate: 75

### Wave 7 — Manual UAT (user-side after merge)

**Task 7.1 — Manual UAT on staging**
- File(s): n/a (UAT script).
- Description: Run the 10 SPEC success criteria end-to-end on staging. Detailed script:
  1. Sign in as a shop owner with ≥1 active appointment_slot at $50.
  2. Open Tools → Service Management → tap a service → edit → AppBar shows the price-change IconButton.
  3. Tap → land on `PricingOverridesListScreen` (empty for fresh slot — verify empty state copy).
  4. Tap FAB → `PricingOverrideFormScreen` opens in create mode. Default day = "All week".
  5. Fill: name = "Off-peak Tuesday morning", day = Tue (2), start = 09:00, end = 12:00, kind = percent_discount, value = 20. Preview row shows "A 10am Tuesday slot would price at $40 (saved $10 vs $50 base)".
  6. Save → return to list. Row appears with kind icon + summary.
  7. Sign in as a client. Open the shop. Pick Tuesday. Time slots from 09:00 to 11:45 show "$40" with "Discount" chip. Slots outside the window show "$50" with no chip.
  8. Pick 10am. Confirmation screen shows $40 total. Apply SUMMER10 (10% off). Total = $36.
  9. Confirm booking. Webhook persists `price_at_booking = 40` (verify in DB).
  10. Owner edits the rule: value = 30 (30% off). Save.
  11. NEW client booking on Tuesday 10am: confirmation shows $35. Existing booking (from step 9) still shows $40 in the client's booking history.
  12. Owner archives the rule. Subsequent generated slots show $50 with no chip. The rule no longer appears in the active list.
  13. Owner creates two overlapping rules: A = "weekdays 09:00–17:00, 10% off", B = "Tue only 10:00–12:00, 20% off". Client books Tuesday 10am → effective = $40 (20% off — the Tue-only rule wins by specificity).
  14. Owner tries fixed_discount = 100 on a $50 slot. RPC succeeds. Client time-picker shows "$0" with "Discount" chip.
  15. Owner tries to add a 51st rule on the same slot → form shows `loc.pricingOverrideErrorCap`.
  16. NEW: Configure a service with Sunday (day_of_week = 7) in its days_of_week. Pre-Phase 15: no Sunday slots. Post-Phase 15: Sunday slots generate correctly.
- Acceptance: All 10 SPEC criteria + the 50-cap + the ISODOW Sunday fix observed. Screenshot evidence pasted in PR.
- Estimate: 75

## Verification matrix

Maps SPEC success criteria → test type → command → status.

| SC | SPEC text | Test type | Command / location | Status |
|----|-----------|-----------|--------------------|--------|
| 1 | Owner navigates to Service Management → service → "Pricing rules" icon → empty state. | Widget test | `flutter test test/.../pricing_override_form_screen_test.dart` (list-screen state cases) + manual UAT step 3 | Wave 6 Task 6.3 / Wave 7 |
| 2 | Owner creates rule: name + day_of_week=2 + window 09:00–12:00 + percent_discount + value=20. New row shown. | Widget test + SQL smoke | `pricing_override_form_screen_test.dart` (case h "create flow") + `15_smoke_tests.sql §B` | Wave 6 Tasks 6.3, 6.5 |
| 3 | Live preview shows "$40 (saved $10 vs $50 base)". | Widget test | `pricing_override_form_screen_test.dart` (case e "preview math") | Wave 6 Task 6.3 |
| 4 | Client books Tuesday: slots 09:00–12:00 show "$40" with Discount chip; slots outside show "$50" no chip. | SQL smoke + Widget test | `15_smoke_tests.sql §F` + `time_slot_chip_test.dart` | Wave 6 Tasks 6.4, 6.5 |
| 5 | Client picks 10am → confirmation $40 → SUMMER10 → $36. | SQL smoke | `15_smoke_tests.sql §F` (effective total feeds promo math) | Wave 6 Task 6.5 |
| 6 | Owner edits rule to value=30. New bookings $35; existing $36 (snapshot). | SQL smoke | `15_smoke_tests.sql §C` (update authz + partial update) | Wave 6 Tasks 6.5, 7.1 |
| 7 | Owner archives → future slots $50 no chip; rule gone from list. | SQL smoke | `15_smoke_tests.sql §D` (archive idempotency) | Wave 6 Task 6.5 |
| 8 | Two overlapping rules: Tue-only beats weekdays for Tue 10am. | SQL smoke | `15_smoke_tests.sql §G` (single-day beats all-week) | Wave 6 Task 6.5 |
| 9 | `fixed_discount=100` on $50 → effective $0; RPC succeeds. | SQL smoke | `15_smoke_tests.sql §J` (clamp at zero) | Wave 6 Task 6.5 |
| 10 | `validate_and_apply_promo` uses effective total → promo math against discounted base. | SQL smoke + manual UAT | `15_smoke_tests.sql §F` + UAT step 8 | Wave 6 Task 6.5 / Wave 7 |
| (cap) | 51st active override raises `OVERRIDE_CAP_EXCEEDED`. | SQL smoke | `15_smoke_tests.sql §K` | Wave 6 Task 6.5 |
| (resolution narrower) | Narrower window beats wider. | SQL smoke | `15_smoke_tests.sql §H` | Wave 6 Task 6.5 |
| (resolution newest) | Newest beats older at equal specificity. | SQL smoke | `15_smoke_tests.sql §I` | Wave 6 Task 6.5 |
| (base_price col) | `generate_available_slots` returns `base_price` populated. | SQL smoke | `15_smoke_tests.sql §E` | Wave 6 Task 6.5 |
| (ISODOW) | Sunday (day_of_week=7) bookings generate after the fix. | SQL smoke + UAT | `15_smoke_tests.sql §L` + UAT step 16 | Wave 6 Task 6.5 / Wave 7 |
| (RLS) | Cross-shop owner cannot SELECT another owner's overrides. | SQL smoke | `15_smoke_tests.sql §A` (RLS owner-only verify) | Wave 6 Task 6.5 |
| (typed exceptions) | All 7 HINT codes map to typed Dart exceptions. | Widget / repo test | `pricing_overrides_repository_test.dart` (classifier table) | Wave 6 Task 6.2 |
| (client patch) | Confirmation total uses effective price, not base. | Code review + UAT | `booking_confirmation_screen.dart` diff + UAT step 8 | Wave 4 Task 4.1 / Wave 7 |

## Risk register (delta from SPEC)

| Risk | Likelihood | Mitigation in this plan |
|------|-----------|-------------------------|
| Sunday-bookings-suddenly-work surprises owners with existing slot configs that include 7 in days_of_week | M | Pre-flight check (4) captures the baseline. Owners with existing day_of_week=7 entries in shop_opening_hours benefit immediately — no migration needed. UAT step 16 confirms. |
| The override CTE materialization breaks generate_available_slots performance on a large shop | M | Pre-materialize-once + JSONB-array iteration is ~450x cheaper than per-iteration JOIN. EXPLAIN ANALYZE gate at <50ms on a 50-override shop (Wave 1 Task 1.4 acceptance). |
| Client patch breaks zero-override-shop bookings | M | `?? service.price` fallback is the byte-for-byte equivalent of the prior behavior when `timeSlots` is missing. Widget tests for the confirmation screen pass unchanged. |
| Owner toggles `is_active` to FALSE via SQL but expects the UI Archive to do the same | L | `update_pricing_override(p_is_active := false)` is reachable via the repo; v1 UI does not surface it (only Archive). Documented; no UX regression because both effectively remove the rule from `generate_available_slots`. |
| Negative effective price on excessive `fixed_discount` | L | `GREATEST(price - value, 0)` clamp in §2 patch. Smoke §J verifies. |
| Owner archives an active rule mid-checkout, client charges old price | L | Acceptable v1 — same risk profile as Phase 13 promo race. Documented. |
| 38 i18n keys vs. planner brief "~20" estimate | L | Same overshoot as Phase 14's "~25" → 32. Both within the right ballpark. Not a blocker. |
| Cross-timezone slot generation (shops.timezone doesn't exist) | L | Same constraint as Phase 14. Times in `pricing_overrides.time_window_*` interpreted in DB session timezone. Documented. |
| Partial-update gap on `day_of_week` / `valid_until` (can't clear to null) | L | v1 workaround: archive + recreate. v2 will add `clear_*` sentinels. Documented in form helper text. |

## Phase boundary

Phase 15 ships:
- Server: 5 migrations (1 table + RLS + index, 3 RPCs, 1 modified RPC bundling the ISODOW fix + override CTE + base_price column).
- Client: 2 new screens (`PricingOverridesListScreen`, `PricingOverrideFormScreen`), 1 DTO + enum, 1 exception hierarchy (7 subtypes), 4 new repo methods + 1 classifier, 1 provider, 1 AppBar IconButton on `ServiceEditScreen`, 1 new `_AdjustmentBadge` widget, 1 nullable field on `TimeSlotModel`, ~38 EN i18n keys.
- Client booking-flow PATCH (critical): `_calculateTotalPrice` + `servicesData.priceAtBooking` in `booking_confirmation_screen.dart`; `priceAtBooking` writes in `booking_creation_controller.dart`.
- Tests: 4 new test files (exceptions, repo, form-screen, time-slot-chip) + 1 SQL smoke file (12 sections).

Phase 15 does NOT ship:
- Worker-tier pricing (Flavor B from earlier discussion).
- Real-time / demand-based surge (Flavor C).
- Shop-wide overrides.
- Override stacking / override-of-overrides.
- Date-specific overrides (use `valid_from` / `valid_until` to bound rule lifespan).
- Bulk copy operations.
- Owner-facing override-impact analytics.
- Translations beyond EN.
- Real-time push of price changes.
- `BROADCAST`-style audit log of every effective-price computation.
- v1 surface for `is_active=false` distinct from `archived_at != null` (reachable via RPC; not in UI).
- v2 partial-update `clear_*` sentinels for `day_of_week` / `valid_until`.
- Webhook code path changes (paystack / stripe already trust the client's `priceAtBooking`).
