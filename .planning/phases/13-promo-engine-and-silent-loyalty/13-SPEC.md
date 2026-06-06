# Phase 13 — Promo Engine + Silent Loyalty

## Outcome

Convert the platform's "every booking pays the sticker price" model
into a **rule-driven discount engine** with two creation paths:

1. **Owner-defined promo codes** — shop owners author named codes
   ("SUMMER10", "WELCOME") with scope (per-shop), discount mechanic
   (percent or fixed amount), validity window, redemption cap, and
   service restriction. Clients enter the code at checkout; the
   server validates and applies it before payment.

2. **System-generated codes** — the same code engine, triggered
   autonomously by:
   - **Silent loyalty** — every Nth completed booking by the same
     client at the same shop generates a one-shot discount code that
     auto-applies to the client's next booking. **Client never sees
     their progress** (no badges, no "X more visits"). Owner defines
     N + the reward once in shop settings; the system runs itself.
   - **Recovery promo** — Phase 12's `recovery_checkin` notification
     (currently text-only) gets a generated one-shot code embedded in
     the message body. The discount is real now, not aspirational.

Both code paths share one `promo_codes` table, one validation RPC,
one redemption record. The checkout surface ([`booking_confirmation_screen.dart`](../../../lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart))
gains a "Promo code?" field. Auto-applied codes attach silently
without UI input.

## Why this matters

- **Owner-facing competitive parity.** Fresha, Booksy, Vagaro, and
  Square all ship owner-authored promo codes out of the box. Owners
  expect it. Without it, NanoEmbryo can't be sold as a complete
  marketplace tool for shops moving from those platforms.
- **Closes the Phase 12 recovery-promo gap.** Phase 12 deferred
  discount codes from `recovery_checkin` because the engine didn't
  exist yet. Phase 13 makes Phase 12's recovery messages actually
  recover bookings instead of just nudging.
- **Silent loyalty turns NanoEmbryo's data into retention.** The
  platform already tracks completed bookings per client per shop
  (Phase 10 + Phase 12). Wiring a rule on top costs almost nothing
  and gives shops a Square-parity feature without owner setup work.
- **Autonomy principle.** The loyalty rule runs on a trigger; the
  owner sets it once and forgets it. No daily list of "who gets a
  reward today" to review — matches the locked design principle that
  drove Phase 12.

## Definitions

- **Promo code** — a row in `promo_codes` with: `code TEXT` (uppercase
  ascii), `shop_id`, `discount_kind` (`percent` | `fixed`),
  `discount_value` (0..100 for percent, currency-minor-units for
  fixed), `valid_from`, `valid_until`, `max_redemptions` (NULL =
  unlimited), `per_client_max` (default 1), `min_booking_amount`
  (NULL = no floor), `service_restriction` (NULL = any service, else
  array of `appointment_slot.id`), `source` (`owner_defined` |
  `loyalty` | `recovery`), `target_client_user_id` /
  `target_guest_profile_id` (NULL except for system-generated
  one-shot codes), `archived_at`.
- **Redemption** — a row in `promo_redemptions` recording
  `(promo_code_id, booking_id, client_id, amount_off, redeemed_at)`.
  One row per booking; the `(promo_code_id, booking_id)` unique key
  prevents double-counting.
- **Loyalty rule** — a row in `loyalty_rules`: `shop_id`,
  `trigger_visit_count` (e.g. 6), `discount_kind`,
  `discount_value`, `is_active`. Exactly one active rule per shop in
  v1 (UNIQUE on `shop_id` WHERE `is_active`).
- **Silent code** — a `promo_codes` row with `source IN ('loyalty',
  'recovery')` and a non-null `target_*` field. Visible to the owner
  in their analytics but never surfaced to the client in any list.
  Auto-applied at checkout by client identity match.
- **Discount calculation** — `percent` codes apply `total_amount *
  value / 100`, capped at total. `fixed` codes apply `min(value,
  total_amount)`. Discount is computed server-side at validation
  time. Platform fee + deposit are recomputed against the discounted
  total before payment.

## Research-resolved decisions (locked 2026-06-06)

- **Tables: EXTEND existing.** `promotions` and `promotion_redemptions` already exist in prod with a full owner UI (PromotionsScreen, CreatePromotionScreen, PromotionsRepository, `Promotion` model, `PromotionException` hierarchy, `redeem_promotion` RPC). Phase 13 ADDS columns rather than building parallel schema. Existing owner UI keeps working unchanged.
- **Discount target column:** `bookings.total_amount` (verified — no `subtotal`).
- **Platform fee:** RECOMPUTES against the discounted `new_total`. Platform earns less when a discount applies. Industry-standard accounting.
- **Recovery code discount:** Reuses the shop's active loyalty rule's `discount_kind` + `discount_value`. One config per shop.
- **`redeem_promotion` GRANT:** REVOKED from authenticated in Phase 13. Webhooks use service_role; revoking closes a fabrication surface.
- **Legacy `discount_type='free_addon'`:** Kept in the CHECK constraint. Phase 13 doesn't use it, doesn't remove it.
- **WhatsApp template:** `recovery_checkin_v2` submitted to Meta as a separate template; helper switches `_v1` → `_v2` after approval. User submits manually.
- **Live-DB shape verified 2026-06-06:**
  - `promotions.valid_from / valid_to` are `DATE` (must widen to TIMESTAMPTZ)
  - `promotion_redemptions.user_id` is NOT NULL with no `guest_profile_id` (must make nullable + add `guest_profile_id`)
  - **🚨 CRITICAL: `promotions_code_key` is `UNIQUE (code)` GLOBALLY, not per-shop.** Phase 13 must drop this and replace with `UNIQUE (shop_id, UPPER(code)) WHERE archived_at IS NULL`. Pre-flight: confirm no existing duplicate codes across shops (zero in dev DB; check before prod).
  - Existing indexes on `promotion_redemptions`: PK, booking, promotion, `(promotion_id, booking_id)` UNIQUE — sufficient.

## In scope

| Surface | Scope |
|---------|-------|
| **EXTEND** `promotions` table | Add columns: `archived_at TIMESTAMPTZ NULL`, `source TEXT NOT NULL DEFAULT 'owner_defined' CHECK (source IN ('owner_defined','loyalty','recovery'))`, `target_user_id UUID REFERENCES auth.users(id)`, `target_guest_profile_id UUID REFERENCES guest_profiles(id)`, `per_client_max INT NOT NULL DEFAULT 1`, `min_booking_amount NUMERIC NULL`, `service_restriction UUID[] NULL`. Widen `valid_from / valid_to` from DATE → TIMESTAMPTZ. Drop `promotions_code_key` UNIQUE; add `promotions_shop_code_unique` UNIQUE `(shop_id, UPPER(code)) WHERE archived_at IS NULL`. CHECK: at most one of `target_user_id` / `target_guest_profile_id` non-null (both null = open code; both set = invalid). |
| **EXTEND** `promotion_redemptions` table | Make `user_id` NULLABLE. Add `guest_profile_id UUID REFERENCES guest_profiles(id)`. CHECK: at most one of user_id / guest_profile_id non-null (a booking can be paid by a guest OR a registered user, never both, possibly neither if record_promo_redemption is called pre-identity-resolution). |
| **New table** `loyalty_rules` | One config row per shop. UNIQUE `(shop_id) WHERE is_active`. RLS: owner-only. Columns: `shop_id`, `trigger_visit_count INT NOT NULL CHECK (BETWEEN 2 AND 50)`, `discount_kind`, `discount_value`, `is_active BOOLEAN DEFAULT TRUE`, `created_at`, `updated_at`. |
| **REUSE** existing `redeem_promotion` RPC | Already atomic counter+ledger writer. Wave 2 extends it to accept guest_profile_id. Wave 0 REVOKES the `GRANT EXECUTE TO authenticated` (closes the fabrication surface — webhooks use service_role). |
| **EXTEND** existing `promotions` UI | The existing `CreatePromotionScreen` form gains 4 new owner-facing fields: per-client max, min booking amount, service restriction multi-select, archived toggle. The list view shows `source` badge (Owner / Loyalty / Recovery). System-generated codes (`source != 'owner_defined'`) are visible but NOT editable in the form. |
| **New RPC** `validate_and_apply_promo(p_shop_id, p_code, p_user_id, p_guest_profile_id, p_booking_total, p_service_ids)` | Called from the checkout flow. Returns `{ promotion_id, amount_off, new_total }` or raises typed exceptions. Does NOT insert a redemption row (that happens on payment success via `redeem_promotion`). Checks: code exists for this shop AND not archived; in validity window (`now()` between valid_from and valid_to); under usage_limit (existing column); under `per_client_max` for this client; passes `min_booking_amount`; passes `service_restriction` if set; not a `target_*` code for a different client. |
| **Auto-apply path on validate** | Calling `validate_and_apply_promo` with `p_code = NULL` returns the highest-discount unredeemed silent code (`source IN ('loyalty', 'recovery')` AND `target_*` matches the caller) for this shop. Tiebreak: sooner-expiring `valid_until` wins. NULL if no match. |
| **New RPC** `upsert_loyalty_rule(p_shop_id, p_trigger_visit_count, p_discount_kind, p_discount_value, p_is_active)` | Owner-only. One active rule per shop. |
| **New helper** `generate_loyalty_code(p_shop_id, p_user_id, p_guest_profile_id)` | SECURITY DEFINER. Called from the loyalty trigger. Generates a unique code (format `LOYALTY-{8-char-base32}`), inserts into `promotions` with `source='loyalty'`, target set, `valid_until = NULL` (no expiry), `usage_limit=1`, `per_client_max=1`. Idempotent via NOT EXISTS guard on unredeemed loyalty code for this (shop, client). |
| **New helper** `generate_recovery_code(p_booking_id)` | SECURITY DEFINER. Called from `enqueue_booking_reminder` when `p_type = 'recovery_checkin'`. Reads the shop's active loyalty rule for the discount kind/value; generates a unique code (`RECOVER-{8-char-base32}`); inserts into `promotions` with `source='recovery'`, target = booking's client, `valid_until = now() + 30 days`, `usage_limit=1`, `per_client_max=1`. Idempotent on existing unredeemed recovery code for this (shop, client). |
| **New trigger** on `bookings` UPDATE-to-completed | When status flips to `completed`, count the client's completed bookings at this shop; if the count matches the shop's active loyalty rule's `trigger_visit_count` AND no unredeemed loyalty code already exists for this client at this shop, generate one. Idempotent. |
| **Edit `enqueue_booking_reminder` (Phase 12)** | When the type is `recovery_checkin`, generate a recovery promo code for the booking's client before composing the message body. Embed the code text into `metadata.body` and `whatsapp_params`. |
| **Checkout flow surface** | [`booking_confirmation_screen.dart`](../../../lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart) gains a "Promo code?" TextField above the totals row. On blur or "Apply" tap, calls `validate_and_apply_promo`; on success, updates the displayed total, recomputes platform fee against the discounted new_total, and stores `promotion_id` in screen state for the subsequent `processPayment` call. On mount, calls validate with `p_code = NULL` to pick up any auto-apply silent code; shows a single line item ("Loyalty reward" or "Recovery discount" or the code text). |
| **Payment webhooks** | `paystack-webhook`, `stripe-webhook`, `verify-payment` receive `promotion_id` via `pending_payments.booking_data` (NOT provider metadata — verified via Research §3). On booking-insert success, call `redeem_promotion(p_promotion_id, p_booking_id, p_user_id, p_guest_profile_id, p_discount_amount)`. |
| **Auto-apply on checkout** | The validate RPC, when called without a `p_code` argument, also returns any `target_*` code matching the calling client at the shop (loyalty or recovery). The checkout screen calls validate once on mount with no code to pick up the silent code, then again if the client types one manually. |
| **Owner-facing UI** | A new "Promotions" tab/screen on the Tools surface (`tools_screen.dart`). List of active codes + create/archive. Loyalty rule editor. NO per-redemption analytics in v1 — just code count + total $ discounted. |

## Out of scope (locked)

- **Tiered loyalty (gold/silver/platinum)** — visit-count rewards only in v1. Future phase.
- **Referral codes** — different growth motion, different attribution semantics. Phase 14+ if at all.
- **Promo code stacking** — exactly one code per booking. Validation rejects a second.
- **Per-day-of-week promos / happy hour** — owner-defined codes have a single validity window. Cron-driven activation is out.
- **Birthday discounts** — we don't collect DOB. Locked out (same constraint as Phase 12).
- **Group booking discounts** — currently a single-line discount per booking. Group dynamics are their own scope.
- **Marketing broadcast of codes to clients** — Phase 14 broadcast scope. v1 owners share codes out-of-band (Instagram, posters, etc.) and clients enter them at checkout.
- **Loyalty progress visible to clients** — locked SILENT. Server-side count, surprise reward.
- **Multi-shop loyalty (visit any of my shops counts)** — single-shop only. Per `loyalty_rules.shop_id`.
- **Promo expiry warnings to clients** — silent codes don't expire by default; manual codes that expire just stop validating.
- **Code activation on retroactive bookings** — only applies to bookings created AFTER the code is active. No backdating.
- **Owner-facing redemption analytics** — code count + total discounted only in v1. Per-day, per-client, per-service breakdowns are dashboard scope, not Phase 13.

## Data sources / infrastructure already in place

- `bookings.status` with `completed` semantics — Phase 10.
- `enqueue_booking_reminder` channel-branching helper for the
  `recovery_checkin` message — Phase 12 ([20260605130400_enqueue_booking_reminder_helper.sql](../../../supabase/migrations/20260605130400_enqueue_booking_reminder_helper.sql)).
- `mark_booking_complete` RPC with `cancel_and_followup` already
  wired — Phase 12 ([20260605130700_wire_terminal_rpcs.sql](../../../supabase/migrations/20260605130700_wire_terminal_rpcs.sql)).
- Existing `payment_controller.dart` processPayment signature with
  metadata passthrough — no breaking changes needed; we add
  `promoCodeId` as an optional field.
- `booking_confirmation_screen.dart` already collects shop currency,
  total, services list — the promo code field slots in cleanly.
- `notification_type` enum (still TEXT-ALTER-VALUE compatible) — no
  new enum value needed; `recovery_checkin` already exists.
- Phase 11 hardening template (authz first, HINT codes, REVOKE/GRANT,
  COMMENT ON FUNCTION) — every new RPC follows it byte-for-byte.
- Typed-exception pattern — every Dart-side error maps via HINT, not
  string matching.
- The pre-existing `_calculateTotalBookings` / `_calculateTotalRevenue`
  unused helpers in `supabase_dashboard_repository.dart` can stay
  unused — they're not in Phase 13 scope to clean up.

## Server changes (high-level)

| Migration | Purpose |
|-----------|---------|
| `promo_codes` table + RLS + UNIQUE | Owner-defined + system codes. |
| `promo_redemptions` table + RLS + UNIQUE | Redemption log. |
| `loyalty_rules` table + RLS + UNIQUE active-per-shop | Shop's loyalty config. |
| `create_promo_code` RPC | Owner-defined creation, hardened. |
| `archive_promo_code` RPC | Soft-delete owner-defined code. |
| `upsert_loyalty_rule` RPC | Owner-defined rule. |
| `validate_and_apply_promo` RPC | The hot path for checkout. Read-only; idempotent. |
| `record_promo_redemption` RPC | Payment-success path, idempotent. |
| `generate_loyalty_code(p_shop_id, p_client_user_id, p_client_guest_profile_id)` helper | Called from the loyalty trigger. SECURITY DEFINER, internal-only. |
| `loyalty_visit_count_trigger` on `bookings` UPDATE | Fires `generate_loyalty_code` when threshold hit. Idempotent. |
| `enqueue_booking_reminder` patch | When `p_type = 'recovery_checkin'`, generate a recovery code before composing the message. |
| 3 payment-webhook edge fns | Pass `promo_code_id` from metadata through; call `record_promo_redemption` on success. |

## Client changes

| File | Change |
|------|--------|
| `lib/presentation/features/shops/dashboard/data/models/promo_code_dto.dart` (NEW) | DTO for owner-facing list. |
| `lib/presentation/features/shops/dashboard/data/models/loyalty_rule_dto.dart` (NEW) | DTO for owner-facing rule editor. |
| `lib/presentation/features/shops/dashboard/data/exceptions/promo_exceptions.dart` (NEW) | Typed exception hierarchy (PromoNotFound, PromoExpired, PromoMaxRedemptions, PromoMinAmountNotMet, PromoServiceNotEligible, PromoAlreadyApplied, PromoSaveFailed). |
| `lib/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart` + `supabase_dashboard_repository.dart` | Add CRUD methods + validate method, HINT-based exception mapping. |
| `lib/presentation/features/shops/dashboard/providers/promo_provider.dart` (NEW) | Provider family for owner's code list + loyalty rule. |
| `lib/presentation/features/shops/dashboard/presentation/screens/promotions_screen.dart` (NEW) | List + create + archive UI. |
| `lib/presentation/features/shops/dashboard/presentation/screens/loyalty_rule_screen.dart` (NEW) | Single-form rule editor. |
| `lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart` | Add two new tools-tab cards routing to the screens above. |
| `lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart` | Add "Promo code?" TextField + apply button; show line-item discount in the totals; auto-apply silent codes on mount. |
| `lib/payment/presentation/controllers/payment_controller.dart` | `processPayment` gains an optional `promoCodeId` field passed through to the create-intent edge fn metadata. |

## Non-functional requirements

- **Atomicity:** `validate_and_apply_promo` is read-only — no redemption row written until payment success. Prevents abandoned-checkout codes from inflating redemption counts.
- **Idempotency:** `record_promo_redemption` is `ON CONFLICT DO NOTHING`. The loyalty trigger checks for an unredeemed loyalty code before generating. Recovery code generation checks for an existing unredeemed recovery code for that booking.
- **Authz:** every owner RPC checks `shops.user_id = auth.uid()`. `validate_and_apply_promo` is open to authenticated callers but only returns codes scoped to the requesting shop. `record_promo_redemption` is SECURITY DEFINER, not GRANTed to authenticated.
- **Observability:** AppLogger fields on every Dart-side RPC call (`shop_id`, `code`, `rpc`, `error_code`). Never logs the raw discount-eligible client's identity in plaintext to the logs the owner can read.
- **Performance:** validate RPC must complete in <100ms with a single shop having 1000 active codes. Verified via EXPLAIN ANALYZE in the plan.
- **No PII leakage:** code text in WhatsApp template params is fine; client phone numbers stay out of metadata.
- **Code text rules:** `[A-Z0-9]{3,20}` server-enforced. Reject whitespace, hyphens, underscores. Case-insensitive at input, normalized to uppercase at storage. Prevents look-alike codes (`PROMO1` vs `PROMO 1` zero-width nbsp).

## Success criteria

1. Owner creates a `SUMMER10` 10%-off code on their shop. Code appears in their promotions list. A different shop's owner cannot see or edit it.
2. A client enters `SUMMER10` on the booking confirmation screen. The total updates to show 10% off. Payment proceeds with the discounted amount, platform fee recomputed.
3. The same client tries `SUMMER10` on a second booking the same day. If `per_client_max=1`, the second attempt raises `PromoMaxRedemptionsException` and the field shows an error.
4. The shop owner sets a loyalty rule: every 6th completed booking grants 15% off. A test client completes 6 bookings at the shop. After the 6th, a `promo_codes` row appears with `source='loyalty'`, `target_user_id` set, `discount_value=15`.
5. The same client books a 7th time. The checkout screen auto-applies the loyalty code on mount — no manual entry. The line-item shows "Loyalty reward: 15% off" but no progress badge anywhere.
6. A booking is cancelled. Phase 12's `recovery_checkin` notification fires at T+7d. The notification body now contains a recovery code that, when entered at the next checkout, applies the configured recovery discount.
7. `validate_and_apply_promo` rejects an expired code with `PromoExpiredException`. Rejects a non-existent code with `PromoNotFoundException`. Rejects a service-restricted code on a non-matching service with `PromoServiceNotEligibleException`.
8. Re-running `validate_and_apply_promo` for the same code+client+booking returns the same result (idempotent; no side effects).
9. Calling `record_promo_redemption` twice for the same `(promo_code_id, booking_id)` results in exactly one row in `promo_redemptions`.

## Research-phase resolutions (all answered 2026-06-06)

- **Existing tables identified.** `promotions` + `promotion_redemptions` + `redeem_promotion` already exist with a full owner UI. Phase 13 EXTENDS them. (Research §1.)
- **`bookings.total_amount`** is the discount target column. No `subtotal`. (Research §2.)
- **Platform fee** recomputes against the discounted total. Industry-standard. (Research §2.)
- **Webhook integration** is via `pending_payments.booking_data` JSONB, NOT Stripe/Paystack metadata. Provider size limits are irrelevant. (Research §3.)
- **`cancel_and_followup` is INLINE PERFORM** from RPC bodies, not a trigger. Phase 13's new AFTER UPDATE OF status trigger has zero ordering conflict. (Research §4.)
- **`recovery_checkin_v1` WhatsApp template** must be replaced with `recovery_checkin_v2` (3 variables: client_name, shop_name, code). User submits to Meta; existing 6h retry covers approval window. (Research §6.)
- **Meta template var cap** is 15 — well above the 3 we need. (Research §6.)
- **`promotions_code_key` is globally UNIQUE on `code`**, NOT per-shop. Phase 13 drops it and creates per-shop UNIQUE `(shop_id, UPPER(code)) WHERE archived_at IS NULL`. Pre-flight check for duplicate codes across shops is part of Wave 0. (Verification, 2026-06-06.)
- **`promotion_redemptions.user_id`** is NOT NULL. Phase 13 makes it nullable and adds `guest_profile_id`.

## Risk register

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Loyalty trigger inflates counts on retry/double-mark | M | NOT EXISTS guard on unredeemed loyalty code; idempotency proven in smoke. |
| Owner creates a code that breaks the booking flow (e.g., 100% off with no min_booking_amount) | M | Server validates 0 < percent <= 100 and discount_value > 0 in the create RPC. Discount capped at total_amount in validate. |
| Recovery code arrives but the client books at a different shop | L | Codes are scoped per `shop_id`. Cross-shop redemption impossible. |
| Code collision (two owners pick `SUMMER10`) | L | Codes are per-shop unique, not globally unique. Two shops with `SUMMER10` is fine. |
| Race: client submits code while owner archives it | L | Validate is read-only at the moment of checkout. If the code archives between validate and payment, the next attempted apply re-validates. Worst case: client gets a charge attempt without the discount; rolled back. |
| Auto-apply picks the WRONG silent code (loyalty + recovery both exist for one client) | M | LOCKED: validate returns the highest-discount silent code; the other stays unredeemed for a future booking. Tie-broken on `valid_until` (sooner-expiring wins) — protects the recovery code from being stranded. Documented and tested. |
| `validate_and_apply_promo` slow under high traffic | L | Single-row lookups on (shop_id, code) + EXISTS counts. EXPLAIN ANALYZE gate in plan. |
| Phase 12 reminder pipeline regressions when adding recovery code | M | Adding to `enqueue_booking_reminder` only touches the `recovery_checkin` branch. Other 4 categories untouched. Smoke covers all 5 categories. |
| Owner sees client loyalty progress in analytics and shares with client (breaks silent constraint) | M | Owner dashboard shows "Total loyalty rewards issued: N" and "Total $ discounted: X" — does NOT show per-client visit counts in v1. |

## Phase boundary

Phase 13 ships:
- Server: ~10 migrations (3 tables + 7 RPCs/triggers/helpers + recovery_checkin patch)
- Edge functions: 3 webhook diffs (record_promo_redemption on success)
- Client: 2 screens (promotions list + loyalty rule editor) + 1 checkout integration + DTOs + exceptions + repo methods + provider family.

Phase 13 does NOT ship:
- Owner-facing redemption analytics dashboards (beyond simple totals)
- Per-day-of-week / happy-hour promo activation
- Marketing broadcast of codes
- Group discounts, gift cards (Phase 14+)
- Tiered loyalty
- Multi-shop loyalty
