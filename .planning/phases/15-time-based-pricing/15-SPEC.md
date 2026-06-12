# Phase 15 — Time-Based Pricing Overrides

## Outcome

Let shop owners define **time-window pricing overrides** on their
existing services — without changing the base service price. The
booking flow's slot-generation RPC applies matching overrides at slot
generation time; the client sees the adjusted price before they pick a
time. `booking_services.price_at_booking` continues to snapshot the
actual charged amount, so historical bookings are immune to subsequent
override edits.

Use cases this unlocks:
- **Off-peak discount**: "Weekdays 10am–2pm = 20% off"
- **Peak surcharge**: "Saturday 4pm–7pm = 15% premium"
- **Promotional window**: "First Tuesday of every month = 30% off facials"
- **Service-specific schedules**: "Senior cuts free 9am Mondays"

The waitlist / surge / worker-tier pricing concepts from earlier
roadmap sketches are explicitly DROPPED — see Out of scope. This phase
ships **owner-defined static schedules**, not real-time demand-based
pricing.

## Why this matters

- **Competitive parity**: Fresha, Booksy, and Square all ship some form
  of time-based discount scheduling. Without it, NanoEmbryo can't be
  pitched as a complete shop-management tool for owners moving from
  those platforms.
- **Activates off-peak demand**: empty Tuesday morning slots are
  100% lost revenue. A 20% discount that fills 50% of them is
  net-positive for the shop.
- **Owner autonomy**: this is the third "owner sets a rule once, it
  runs forever" surface (after loyalty rules in Phase 13 and
  broadcasts in Phase 14). Establishes a consistent pattern.
- **Composes with Phase 13 promos cleanly**: time-based override is
  applied at slot generation; Phase 13's `validate_and_apply_promo`
  then runs against the adjusted total. Stacking order is
  deterministic (override → promo → final total).

## Definitions

- **Pricing override** — a per-(slot, day_of_week, time_window) rule
  that adjusts the service's base price. Owner-authored; stored in a
  new `pricing_overrides` table.
- **Adjustment kind** — one of:
  - `percent_discount` (e.g. 20% off; `adjustment_value` in 0..100)
  - `percent_surcharge` (e.g. 15% extra; `adjustment_value` in 0..100)
  - `fixed_discount` (e.g. $10 off; `adjustment_value` in currency
    minor units; clamped at base price so adjusted ≥ 0)
  - `fixed_surcharge` (e.g. $5 extra)
- **Effective price** = `slot.price` after the highest-priority
  matching override is applied. When multiple overrides match (e.g. a
  weekday-morning rule AND a special-Tuesday rule both cover the same
  generated slot), the **most specific** override wins by a
  deterministic ordering described under "Override resolution."
- **Override resolution** — when a generated slot at `(day_of_week, start_time)`
  has multiple matching overrides:
  1. Single-day override (specific `day_of_week`) beats all-week
     override (`day_of_week IS NULL`).
  2. Narrower time window beats wider time window (measured by
     `time_window_end - time_window_start`).
  3. Most recently created (`created_at DESC`) breaks any remaining
     tie.
- **Override scope** — each override targets a single
  `appointment_slot_id`. v1 does NOT support shop-wide rules ("20% off
  EVERYTHING on Tuesdays"). Adding a shop-wide rule means the
  resolution ladder needs a 4th tier; defer.
- **Validity window** — every override has `valid_from` and
  `valid_until` (TIMESTAMPTZ). Overrides outside this window don't
  apply to generated slots. `valid_until = NULL` = no expiry.
- **Archive (soft delete)** — `archived_at TIMESTAMPTZ NULL`. Mirrors
  the Phase 11 / Phase 13 archival pattern. Archived overrides don't
  apply; the partial-unique constraint lets owners re-author a
  same-shape override after archiving.

## In scope

| Surface | Scope |
|---------|-------|
| **New table** `pricing_overrides` | Owner-authored time-window rules. Columns: `id`, `slot_id` (FK appointment_slots, ON DELETE CASCADE), `name TEXT NOT NULL` (owner label), `day_of_week INT NULL CHECK (day_of_week BETWEEN 1 AND 7)` (1=Mon..7=Sun matches shop_opening_hours; NULL = all-week), `time_window_start TIME NOT NULL`, `time_window_end TIME NOT NULL CHECK (time_window_end > time_window_start)`, `adjustment_kind TEXT CHECK IN (percent_discount, percent_surcharge, fixed_discount, fixed_surcharge)`, `adjustment_value NUMERIC(12,2) NOT NULL CHECK (>0)`, additional CHECK: when kind is `percent_*`, value ≤ 100, `valid_from TIMESTAMPTZ NOT NULL DEFAULT now()`, `valid_until TIMESTAMPTZ NULL`, `is_active BOOLEAN NOT NULL DEFAULT TRUE`, `archived_at TIMESTAMPTZ NULL`, `created_by_user_id UUID NOT NULL REFERENCES auth.users(id)`, `created_at`, `updated_at`. Indexed on `(slot_id) WHERE archived_at IS NULL AND is_active`. RLS: owner-only on the parent slot's shop. 50-active-overrides-per-slot cap enforced in `create_pricing_override` RPC. |
| **Modified RPC** `generate_available_slots` | Three coordinated changes: (1) pre-materialize matching overrides via `jsonb_agg` outside the FOREACH (one-time lookup; Research §2); (2) inside the WHILE loop, rank by specificity/window/created_at and compute effective price; (3) **fix the latent `EXTRACT(DOW)` bug** — change to `EXTRACT(ISODOW)` so Sunday (=7) finally matches `shop_opening_hours.day_of_week=7`. **Adds new `base_price NUMERIC` return column** so client can compute the chip. `price` column carries the effective price; `base_price` carries the unmodified slot.price. Backward-compatible: zero-override shops see `price = base_price`. |
| **New RPC** `create_pricing_override(p_slot_id, p_name, p_day_of_week, p_time_window_start, p_time_window_end, p_adjustment_kind, p_adjustment_value, p_valid_from, p_valid_until)` | Owner-only. Authz first (via slot→shop chain). Hardened per Phase 11 template. Returns `id`. |
| **New RPC** `update_pricing_override(p_override_id, ...)` | Owner-only. Partial update; pass NULL for fields to leave unchanged. |
| **New RPC** `archive_pricing_override(p_override_id)` | Owner-only. Soft delete. Idempotent. |
| **Owner UI surface** | Add a "Pricing rules" affordance INSIDE `ServiceManagementScreen`'s edit-service detail (not a new Tools tab card). Owner sees a list of overrides on the service, can add/edit/archive. List view in the service editor; modal form for add/edit. Reaches `PricingOverrideFormScreen` for the form. Reasoning: pricing rules are scoped to a service, so they live on the service edit surface rather than a separate Tools card. |
| **Per-override read-only price preview** | The form shows a live "Example: a slot at 10am Tuesday would price at $X (saved $Y vs base)" preview as the owner edits the rule. Computed client-side from the form's current values + the slot's base price; no server round-trip needed. |
| **Client-side price chip** | When `generate_available_slots` returns a slot whose effective price differs from the base, the time-picker row shows a small "Discount" or "Surcharge" chip. Client-side compares the returned `price` to a `slot.price` lookup the screen already has. Owner-defined `name` doesn't surface to clients (privacy + simplicity); only the kind (discount vs surcharge) shows. |
| **Phase 13 promo composition** | `validate_and_apply_promo` already runs against `p_booking_total` passed in by the client. Phase 15 changes what number gets passed in (effective total, not base total). NO change to the promo RPC. The booking confirmation screen recomputes total = sum(slot.effective_price * quantity) before calling validate. |

## Out of scope (locked)

- **Worker-tier pricing** ("senior stylist costs more"). Schema-rippling; deferred to a future phase. Phase 15 = time-based only.
- **Real-time / demand-based surge** ("Saturday is busy, prices auto-rise"). Architecture doesn't support reactive pricing in the booking flow; UX paradigm shift; not building it.
- **Shop-wide overrides** ("20% off all services Tuesday morning"). Per-slot only in v1. Owner can stamp the same rule on N services; UX nicety.
- **Override-of-overrides** (e.g. "this Tuesday only, ignore the standing weekly rule"). The 3-tier resolution ladder above is final; we don't ship a manual exemption surface.
- **Date-range overrides** ("the entire holiday week, run this rule"). Use `valid_from` / `valid_until` to bound the rule's lifespan, but the rule still applies to ALL matching days inside that range — no "this date specifically" override.
- **Override stacking** (compose multiple matching overrides). One override wins per generated slot; the priority ladder is the only resolution.
- **Promo + override interaction beyond "promo applies to adjusted total"**. The promo engine doesn't know about overrides explicitly; it sees the effective total. Whether an owner-defined promo should refuse to stack on top of a discount override is a future call (e.g. "no double discounts policy"). Not in v1.
- **Owner-facing analytics on override impact** ("you discounted $400 last month via off-peak rules"). Future dashboard work.
- **Adjustment-kind extensions** like `set_price_to_fixed_amount` or `free` (100% off). Owners can do 100% via `percent_discount` with value 100 — that path is allowed and clamps gracefully.
- **Bulk operations** ("copy this rule to all my services"). One-at-a-time only in v1.
- **Override notification to clients** ("your favorite shop has a new off-peak deal"). Phase 14's broadcast surface can announce it; we don't auto-broadcast.
- **Translation of override labels**. Phase 15 ships EN i18n keys only — same pattern as Phase 13.1 / 14.
- **Price audit log** showing every effective-price computation. The owner sees the rule definitions; the server is authoritative.

## Data sources / infrastructure already in place

- `appointment_slots.price` — the canonical default price.
- `appointment_slots.days_of_week INT[]` — owner-defined days the service is offered.
- `generate_available_slots` RPC — already returns `price NUMERIC` per row; already iterates over (day_of_week, time_window) combinations to project slot rows.
- `booking_services.price_at_booking` — already snapshots actual paid price at booking time. Phase 15 doesn't disrupt this; the snapshot continues to be the source of truth for revenue analytics.
- Archive pattern with `archived_at` + partial-unique-index — Phase 11 (appointment_slots), Phase 13 (promotions). Phase 15 reuses verbatim.
- HINT-based typed exception mapping pattern — Phase 12, 13, 14.
- Owner-form UX precedent — LoyaltyRuleScreen (Phase 13) → CreatePromotionScreen (Phase 13.1) → CreateBroadcastScreen (Phase 14). Explicit Save, dirty-check, error toasts.
- `ServiceManagementScreen` + `ServiceEditScreen` — Phase 11. Both already exist; Phase 15 extends their detail view.

## Server changes (high-level)

| Migration | Purpose |
|-----------|---------|
| `pricing_overrides_table.sql` | Table + RLS + indexes + check constraints |
| `create_pricing_override_rpc.sql` | Owner-only create, hardened |
| `update_pricing_override_rpc.sql` | Owner-only update, hardened |
| `archive_pricing_override_rpc.sql` | Owner-only archive, idempotent |
| `apply_pricing_override_to_generate_slots.sql` | Rewrite `generate_available_slots` to inject the override resolution CTE |

## Client changes

| File | Change |
|------|--------|
| `lib/.../dashboard/data/models/pricing_override_dto.dart` (NEW) | DTO + AdjustmentKind enum |
| `lib/.../dashboard/data/exceptions/pricing_override_exceptions.dart` (NEW) | Typed hierarchy |
| `lib/.../dashboard/data/repositories/dashboard_repository.dart` + `supabase_dashboard_repository.dart` | Add CRUD methods + classifier |
| `lib/.../dashboard/providers/pricing_overrides_provider.dart` (NEW) | `FutureProvider.family<List<PricingOverrideDTO>, String slotId>` |
| `lib/.../dashboard/presentation/screens/pricing_overrides_list_screen.dart` (NEW) | Embedded in service edit; lists overrides for a slot |
| `lib/.../dashboard/presentation/screens/pricing_override_form_screen.dart` (NEW) | Create/edit form with live price preview |
| `lib/.../dashboard/presentation/screens/service_edit_screen.dart` | Add an "Pricing rules" affordance routing to the list screen |
| `lib/.../shops/booking/presentation/widgets/...time_slot_card.dart` (or equivalent) | Adjusted-price chip when slot's effective price ≠ base. Compare `slot.price` (effective) to new `slot.basePrice` (added by Research §16 to the RPC return). |
| `lib/.../shops/booking/presentation/screens/client/booking_confirmation_screen.dart` (PATCH) | Lines 302-359: replace `service.price` with the slot's effective price for `priceAtBooking` and the total computation. Net additive — zero-override shops see effective == base. (Research §1 + P0 decision.) |
| `lib/.../shops/booking/presentation/controllers/booking_creation_controller.dart` (PATCH) | Lines 462, 496: same effective-price read. (Research §1.) |
| `lib/i10n/app_en.arb` | ~20 new EN keys |

## Non-functional requirements

- **Atomicity**: each owner mutation is single-RPC. No multi-statement transaction churn.
- **Authz**: every RPC enforces `appointment_slots → shops.user_id = auth.uid()` chain. Cross-shop access raises `42501 NOT_FOUND` (sanitized).
- **Performance**: `generate_available_slots` already iterates per (day, time). Adding the override CTE adds one indexed lookup per generated slot. Verified <50ms on a shop with 50 active overrides via EXPLAIN.
- **Determinism**: override resolution is server-side, deterministic. Two clients viewing the same shop's slot at the same instant see identical prices.
- **Backwards compatibility**: shops with zero overrides see ZERO behavior change. The override CTE is a `LEFT JOIN` that returns NULL when no match, in which case the base `price` flows through.
- **Promo composition**: validate_and_apply_promo runs against the override-adjusted total. Phase 13 promo rules don't change. Phase 13 + Phase 15 stack cleanly: override → promo → final.
- **Snapshot invariance**: `booking_services.price_at_booking` continues to be the source of truth for what the client paid. An override edited after booking does NOT retroactively change historical revenue.
- **i18n**: EN keys only. Other locales fall back. Same pattern as Phase 13.1 / 14.

## Success criteria

1. Owner navigates to Tools → Service Management → tap a service → "Pricing rules" tab/section appears. Empty state shown.
2. Owner taps "Add rule", fills form: name="Off-peak Tuesday morning", day_of_week=2, time_window 09:00–12:00, kind=percent_discount, value=20. Saves. Returns to list. New row shown.
3. Owner sees a "Example: a 10am slot would price at $40 (saved $10 vs $50 base)" preview while editing the form.
4. Client opens the shop, books for that Tuesday. The time slots between 9am and noon show "$40" with a "Discount" chip. Slots outside the window show "$50" with no chip.
5. Client picks 10am, sees confirmation screen showing $40. Phase 13 promo SUMMER10 (10% off) applied → total = $36.
6. Owner edits the rule to value=30 (30% off). Saves. NEW bookings price at $35; existing bookings (from criterion 5) still show $36 in client's booking history.
7. Owner archives the rule. Subsequent generated slots show $50 with no chip. The rule no longer appears in the active list.
8. Two overrides both cover the same generated slot — one for "weekdays" (all weekdays 09:00–17:00), one for "Tuesday only" (Tue 10:00–12:00). The Tuesday-only rule wins (more specific day match) for a Tuesday 10am slot.
9. Owner tries `adjustment_kind=fixed_discount`, `adjustment_value=100` on a $50 slot. Effective price clamps to $0 (never negative). RPC succeeds; doesn't raise.
10. Calling `validate_and_apply_promo` server-side at checkout uses the effective total (post-override), so the promo discount is computed off the discounted base. No double-counting bugs.

## Research-phase resolutions (all answered 2026-06-11)

- **Client booking-flow patch is REQUIRED** (Research §1). SPEC's "purely additive" claim was wrong. `booking_confirmation_screen.dart:302-359` and `booking_creation_controller.dart:462,496` hardcode `service.price` (base), not the slot's effective price. Without this patch, owners would see discount chips but clients would be charged the base price. Phase 15 PATCHES both files. Net additive for zero-override shops (effective price == base price → identical behavior).
- **`generate_available_slots` gains a new `base_price NUMERIC` return column** (Research §16). Backward-compatible; lets the client render the discount/surcharge chip without a second RPC call.
- **`day_of_week` convention LOCKED to 1..7** (Mon=1..Sun=7), matching `shop_opening_hours.day_of_week` (1..7 verified in prod). The latent `EXTRACT(DOW)` bug in `generate_available_slots` (computes 0..6, joins against 1..7) is ALSO fixed in the Phase 15 RPC patch — change to `EXTRACT(ISODOW)` so Sunday bookings start working. Same surgical edit; same migration.
- **Resolution ladder attribution dropped** (Research §11). SPEC line 65 originally credited Fresha for the 3-tier ladder; Research couldn't verify. The ladder stands on its own merits.
- **Partial-update gap on `day_of_week` / `valid_until`**: deferred to v2. v1 workaround = archive + recreate. Form is single-screen anyway; minimal UX cost.
- **Form warnings on extreme values**: soft warning at >50% surcharge AND >5x base price on `fixed_surcharge`. Form shows yellow warning but doesn't block. Schema's hard caps (percent ≤ 100) remain the absolute limit.
- **`appointment_slots` shape verified live 2026-06-11**: `id UUID NOT NULL`, `price NUMERIC NOT NULL`, `archived_at TIMESTAMPTZ NULL`, `days_of_week ARRAY NULL`. Existing rows show range 1..6 (no Sundays — explained by the latent ISODOW bug).

## Risk register

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Override resolution ladder produces wrong winner under multi-rule overlap | M | Server-side deterministic ordering + smoke test with 3 overlapping rules. |
| `generate_available_slots` performance degrades on shops with many overrides | M | EXPLAIN gate at < 50ms on a 50-override shop. Add partial index on `pricing_overrides(slot_id) WHERE is_active AND archived_at IS NULL` (already in scope). |
| Negative effective price on excessive `fixed_discount` | M | CHECK constraint impossible (`adjustment_value > 0`); server math clamps `max(adjusted, 0)`. |
| Owner edits an active rule and historical bookings re-price | L | `booking_services.price_at_booking` is a snapshot; never re-read on existing bookings. Document. |
| Phase 13 promo applied twice (once via override "looks like a discount", once via promo code) | L | Override produces a single effective price, not a "discount line item". Client doesn't see two discount lines — sees the new effective price + promo applied. Cleaner UX. |
| Cross-timezone slot generation: `shops.timezone` doesn't exist | L | Same constraint as Phase 14. Times are local to whatever DB session timezone interprets them. Document. |
| Client sees stale prices when owner edits a rule mid-session | L | Time-slot list re-fetches `generate_available_slots` on date change. Manual refresh available. Real-time push is out of scope. |
| Race: owner archives an override mid-checkout | L | Validate_and_apply_promo doesn't see overrides directly. The client's `total` is computed at booking confirmation time; if the override archives between time-picker and confirmation, the next regen would surface it. Worst case: client pays the old (discounted) price the override is no longer active for. Acceptable v1; document. |
| Form preview drift from server effective price | L | The form preview is client-side math; the RPC is authoritative. UAT verifies they match. |

## Phase boundary

Phase 15 ships:
- Server: 5 migrations (1 table, 4 RPCs — including 1 modified)
- Client: 2 new screens + form + DTO + exceptions + repo methods + provider + 1 widget chip + service edit screen extension
- ~20 EN i18n keys
- Tests: exception contracts + repo HINT mapping + widget contracts + SQL smoke covering the 10 success criteria

Phase 15 does NOT ship:
- Worker-tier pricing (Flavor B from earlier discussion)
- Real-time / demand-based surge (Flavor C)
- Shop-wide overrides
- Override stacking / override-of-overrides
- Bulk copy operations
- Owner-facing override-impact analytics
- Translations beyond EN
- Real-time push of price changes
