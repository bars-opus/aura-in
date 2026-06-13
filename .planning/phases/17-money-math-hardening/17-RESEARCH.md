# Phase 17 — Money Math Hardening · RESEARCH.md

**Date:** 2026-06-12
**Scope:** Close deferred audit findings F-P0-1 + F-P2-4 (checklist v3.1 §2.19 P0-U / [FIN]).
**Confidence:** HIGH on inventory (direct grep across all surfaces); MEDIUM on rollout
  ordering (depends on the dev/staging deploy cadence we'll write down in SPEC).

## Executive summary

The storage truth is **already minor-unit-safe** — every money column on the live
DB is `NUMERIC(12,2)`, which is exact-decimal arithmetic. The bug surface is the
**wire format** (Dart ↔ Edge Function, Dart ↔ provider SDK) plus the **client-side
fold math** in the booking flow + payment controller.

This is bigger than the audit suggested. The auditor found 4 hot files; the real
trail is **24+ Dart files** including BookingModel, BookingServiceModel,
BookingFlowStateProvider, BookingPriceBreakdown widget, PaymentIntent record,
PaymentSettings, PromoValidation, and every wallet surface. The edge functions
are bounded — 2 providers (Paystack + Stripe) and the create-booking + 2 webhook
handlers do all the money math.

The audit's most useful (and most wrong) claim: "edge function already speaks
kobo internally." It doesn't. `paystack_provider.ts:51` does
`Math.round(input.amount * 100)`. The edge function takes **major-unit floats**
on the wire and converts to kobo for the provider SDK. Phase 17 has to flip the
wire to int kobo AND flip the provider call to expect int kobo, in lockstep.

The deploy-coupling risk is real. If Flutter ships int-kobo before the edge
function understands it, every payment is 100× wrong. Mitigation: dual-format
detection on the edge function (Section 4) ships first, Flutter ships second,
edge function ships third with the legacy float branch removed.

---

## Section 1 — Edge function money inventory

### 1.1 — `_shared/providers/paystack_provider.ts`

Provider adapter; talks to Paystack API. Paystack expects integer kobo.

| Line | Pattern | Meaning |
|------|---------|---------|
| 51 | `amount: Math.round(input.amount * 100)` | Paystack `transaction/initialize` body. `input.amount` is currently float cedis from the Dart wire. ×100 to provider kobo. |
| 62 | `body.transaction_charge = Math.round(input.platformFeeAmount * 100)` | Same shape for the split-fee field. |
| 149 | `amount: (d.amount ?? 0) / 100` | Provider response. Paystack returns kobo; ÷100 normalizes back to a "logical amount" for downstream code. |
| 162 | `const amountKobo = Math.round(input.amount * 100)` | Refund path. Same float-cedis → int-kobo conversion. |

**Inbound contract:** `input.amount: number` (float cedis).
**Outbound contract to provider:** integer kobo.
**Outbound contract to caller (response shape):** float cedis at line 149.

### 1.2 — `_shared/providers/stripe_provider.ts`

Same pattern as Paystack. Stripe expects integer minor units (cents/pence/etc.).

| Line | Pattern | Meaning |
|------|---------|---------|
| 46 | `unit_amount: Math.round(input.amount * 100)` | Stripe Checkout `line_items[].unit_amount`. |
| 63 | `Math.round(input.platformFeeAmount * 100)` | Stripe Connect application fee. |
| 128 | `amount: (session.amount_total ?? 0) / 100` | Response normalization. |
| 143 | `const amountCents = Math.round(input.amount * 100)` | Refund path. |

Same inbound/outbound contracts as Paystack.

### 1.3 — `create-booking/index.ts`

Inbound RPC handler from Flutter. Contains the `sanitizeAmount` boundary.

| Line | Pattern | Meaning |
|------|---------|---------|
| 48–50 | `totalAmount: number; depositAmount: number; platformFee: number;` | TypeScript request type. Currently float cedis. |
| 196–198 | `sanitizeAmount(rawBody.totalAmount, { min: 0.01 })` | Validation. `sanitizeAmount` accepts float, validates finite + non-negative, returns `Math.round(n * 100) / 100` — i.e. clamps to 2dp. |
| 202 | `priceAtBooking: sanitizeAmount(s.priceAtBooking, ...)` | Per-service price. |
| 393 | `amount: body.depositAmount` | Forwarded to Paystack provider (float cedis). |
| 401 | `platformFeeAmount: body.platformFee` | Forwarded as float cedis. |
| 405–407 | `total_amount: String(body.totalAmount)` | Stored to `pending_payments.booking_data` as JSON string. |
| 470 | `amount: body.totalAmount` | Forwarded to Stripe provider (float cedis). |
| 619 | `Math.abs(slot.price - service.priceAtBooking) > 0.01` | Server-side price validation. Tolerates 1 cent float dust. |
| 684–685 | `Math.abs(calculatedAmount - req.totalAmount) > 0.01` | Server-side total validation. Same dust tolerance. |

**This file is the heart of the wire-format change.** Phase 17 flips:
- Inbound request type to `totalAmountMinor: number` (int)
- `sanitizeAmount` to a new `sanitizeAmountMinor` (or update signature to accept either)
- Both provider calls receive int kobo, dropping the ×100 inside the providers
- The two server-side validation epsilons collapse from `> 0.01` to `!== 0` exact

### 1.4 — `stripe-webhook/index.ts`

Webhook from Stripe. Reads Stripe session amount (kobo/cents int), normalizes
to float cedis to match the rest of the system.

| Line | Pattern | Meaning |
|------|---------|---------|
| 140 | `const amountPaid = (session.amount_total ?? 0) / 100; // cents → dollars` | Normalizes inbound provider int to float for storage. **Post-Phase-17 this normalizes nothing — int kobo from the provider stays as int kobo.** |

### 1.5 — `process-withdrawal/`, `paystack-subaccount/`

Need to spot-check for money-math sites. Audit grep returned zero hits in
`/Users/user/nano_embryo/supabase/functions/process-withdrawal/` for `* 100` or
`/ 100`. Confirm in Wave 1 task.

### 1.6 — `_shared/sanitize.ts`

Contains `sanitizeAmount(raw, { min, max }) → number`. Currently a float
validator. Lines 83–97. **Phase 17 adds a parallel `sanitizeAmountMinor(raw, {
min, max }) → number` returning a non-negative integer, with the dual-format
detection (Section 4) inlined.**

---

## Section 2 — Dart booking-flow money trail

The surface is larger than the audit found. Below is the full trail by file. All
fields proposed as `int` are minor units (kobo for GHS, cents for USD).

### 2.1 — Models that carry money

| File | Line | Field | Current | Proposed |
|------|------|-------|---------|----------|
| `time_slot_model.dart` | 35 | `price` | `double` | `int priceMinor` |
| `time_slot_model.dart` | 36 | `basePrice` | `double?` | `int? basePriceMinor` |
| `time_slot_model.dart` | 70 | `(json['price'] as num).toDouble()` | toDouble | `.toInt()` after `* 100` server-side OR no transformation if server emits kobo column |
| `booking_model.dart` | 48–50 | `totalAmount`, `depositAmount`, `platformFee` | `double` | `int *Minor` |
| `booking_model.dart` | 158–160 | `fromJson` `.toDouble()` | toDouble | Conversion at boundary (see Section 3) |
| `booking_service_model.dart` | 10, 38 | `priceAtBooking` | `double` | `int priceAtBookingMinor` |
| `payment_settings_model.dart` | 138 | `payoutMinimum` | `double` | `int payoutMinimumMinor` |

### 2.2 — Controllers + state holders

| File | Line | Field | Current | Proposed |
|------|------|-------|---------|----------|
| `payment_controller.dart` | 52–54 | `_PaymentIntent.totalAmount/depositAmount/platformFee` | `double` | `int *Minor` |
| `payment_controller.dart` | 114–116 | `processPayment` named params | `double` | `int *Minor` |
| `payment_controller.dart` | 148–161 | `requestBody` JSON encoding | doubles inline | ints inline |
| `payment_controller.dart` | 457 | `(booking['total_amount'] as num?)?.toDouble() ?? 0` | toDouble | Convert at repo boundary; `_fireSuccess` receives kobo |
| `booking_creation_controller.dart` | (varies — `_kDepositPercent`, `_kPlatformFee`, `_calculateTotalAmount`, `priceAtBooking` writes — Phase 15 already touched all these) | money math | `double` | `int` + `~/` (truncating int division) |
| `booking_flow_state_provider.dart` | 37 | `BookingFlowState.totalPrice` | `double` | `int totalPriceMinor` |
| `payment_config.dart` | 32 | `PaystackConfig.amount` | `double` | (deprecated/unused?) verify |
| `payment_config.dart` | 123 | `depositFraction` | `double` | **Stays double** — this is a ratio, multiplied as `totalMinor * (depositFraction * 100).toInt() / 100`. **OR** introduce `depositBps` (basis points, 3000 = 30%) and compute as `totalMinor * depositBps ~/ 10000`. **Bps is cleaner; spec it.** |
| `payment_config.dart` | 126 | `platformFeeFraction` | `double` | Same: convert to `platformFeeBps: int` |

### 2.3 — Repositories

| File | Lines | Sites |
|------|-------|-------|
| `supabase_booking_repository.dart` | 540, 552, 1095 | 3× `(... ?? 0.0).toDouble()` on `price_at_booking`, slot `price` columns. Phase 17 converts these to `(... as num).toInt()` after the server pre-multiplies by 100, OR keeps the NUMERIC return and the Dart repo does `((... as num) * 100).round()` at the boundary. **Recommend boundary conversion** (Section 7 — no schema changes). |
| `supabase_dashboard_repository.dart` | 22+ sites the audit grepped (analytics, daily-report consumption, etc.) | All money-relevant reads need the same boundary conversion. Phase 16 already returns kobo in `daily_reports.payload.revenue_minor` — that path is correct. The other sites that pull from `bookings.total_amount` directly need the conversion. |
| `promotions_repository.dart` | varies | `validate_and_apply_promo` returns NUMERIC `amount_off` + `new_total`. Boundary-convert. |

### 2.4 — UI widgets

Display-only. The change here is purely cosmetic — read `int priceMinor` and
format as `formatMoney(priceMinor, currency)`.

| File | Sites |
|------|-------|
| `time_slot_chip.dart` | `'$currency ${slot.price.toStringAsFixed(2)}'` → `formatMoney(slot.priceMinor, currency)` |
| `booking_price_breakdown.dart` | `totalAmount`, `depositAmount`, `platformFee` — re-type and format |
| `booking_summary_card.dart` | `totalPrice` — re-type and format |
| `booking_detail_screen.dart` | `totalAmount` — re-type and format |
| `client_promo_code_field.dart` | `AppliedPromo.amountOff`, `newTotal` — re-type and format |

### 2.5 — `client_promo_code_field.dart` deep dive

Phase 13 introduced `AppliedPromo` carrying `amountOff: double` + `newTotal:
double`. The screen uses `_appliedPromo?.newTotal ?? totalPrice` as the canonical
payment total. Phase 17 changes:
- `AppliedPromo.amountOff` → `int amountOffMinor`
- `AppliedPromo.newTotal` → `int newTotalMinor`
- `_appliedPromo?.newTotalMinor ?? totalPriceMinor`
- The promo-validation RPC's NUMERIC return is converted at the repository boundary

---

## Section 3 — Server RPCs that emit money

The list, with verdict on whether each needs a schema change:

| RPC | Returns | Verdict |
|-----|---------|---------|
| `generate_available_slots` | `price NUMERIC, base_price NUMERIC` | **Boundary-convert client-side.** No schema change. Phase 15 ships this; Phase 17 client-side reads `(price * 100).round()` when building TimeSlotModel. |
| `redeem_promotion` | UUID | n/a |
| `validate_and_apply_promo` | TABLE `amount_off NUMERIC, new_total NUMERIC, ...` | **Boundary-convert client-side.** No schema change. |
| `generate_daily_report` | UUID; payload kobo | ✅ Already kobo per Phase 16. No change. |
| `list_daily_reports` | `revenue_minor BIGINT` | ✅ Already kobo per Phase 16. No change. |
| `request_withdrawal` (wallet) | varies | Spot-check in Wave 2 task. |
| `create_pricing_override` / `update_pricing_override` | UUID; accepts `value NUMERIC` | Adjustment value semantics. Percent values stay as 0–100. Fixed values are currency-major. **Decision:** keep the param NUMERIC; document that `fixed_*` adjustment kinds receive major-unit values (the planner ensured this for Phase 15). Phase 17 client-side converts the form input's int-kobo cart computations through `(majorOff / 100)` before storing the rule. |

**Net:** no schema changes required. The boundary is Dart-side, at every
PostgrestException ↔ DTO conversion.

---

## Section 4 — Deploy-coupling risk + dual-format predicate

The user locked: dual-format edge functions ship first, Flutter ships second,
legacy float branch removed third.

**The discriminator.** The naive `Number.isInteger(body.totalAmount)` fails on a
legacy client sending `100.0` (a clean integer cedis value parsed as float). We
need a stronger signal.

**Locked predicate** (proposed in SPEC):

```ts
// True iff the field is "in kobo" — i.e. new-format Flutter post-Phase-17.
function isMinorUnits(amount: number, field: string): boolean {
  // Heuristic 1: explicit suffix wins. New-format clients send `totalAmountMinor`,
  // never `totalAmount`. If we see the new key, it's kobo.
  return false; // computed at caller; here just defining the shape
}
```

Better approach — **versioned field names**:

```ts
// New format request body:
//   { totalAmountMinor: 5000, depositAmountMinor: 1500, platformFeeMinor: 200, ... }
// Old format request body:
//   { totalAmount: 50.0, depositAmount: 15.0, platformFee: 2.0, ... }
//
// Edge function detects format and normalizes inbound to int kobo:
const totalAmountMinor: number =
  typeof body.totalAmountMinor === 'number'
    ? body.totalAmountMinor
    : Math.round((body.totalAmount ?? 0) * 100);
```

This is **unambiguous**. No heuristic. The new Flutter client sends the new key;
the old one sends the old key. Edge function understands both.

**Rollout:**

1. **Wave 1 deploys:** edge functions accept both keys, normalize internally to
   int kobo, and forward int kobo to provider SDKs (drop the ×100 inside).
   At this point provider adapters take int kobo on the wire (`input.amountMinor`
   instead of `input.amount`).
2. **Waves 3–6 deploy:** Flutter app flips to send `totalAmountMinor` keys.
3. **Wave 7+ deploys:** edge functions drop the legacy `body.totalAmount` branch.
   Validated by checking `pending_payments` rows in the prior 30 days for any
   legacy-key creation.

---

## Section 5 — Promo discount math

`validate_and_apply_promo` returns `amount_off NUMERIC, new_total NUMERIC`. Dart
parses both as `double`. The screen uses `newTotal` as the canonical
payment total.

**Phase 17 plan:** boundary-convert at the repository:

```dart
// Before:
final amountOff = (row['amount_off'] as num).toDouble();
final newTotal  = (row['new_total']  as num).toDouble();

// After:
final amountOffMinor = ((row['amount_off'] as num) * 100).round();
final newTotalMinor  = ((row['new_total']  as num) * 100).round();
```

`PromoValidation` carries int. `_appliedPromo?.newTotalMinor ?? totalPriceMinor`
becomes the wire-level total sent to the edge function. Display uses
`formatMoney(amountOffMinor, currency)`.

---

## Section 6 — Test impact

Inventory of test files that pass money values:

| Test file | Sites | Change |
|-----------|-------|--------|
| `test/booking/time_slot_chip_test.dart` | Uses `price: 50, basePrice: 50, basePrice: 40, basePrice: 60, basePrice: 50` and asserts `'GHS 40.00'` rendered | Re-type to `priceMinor: 5000` etc. Assertions update to new render format. |
| `test/booking/client_promo_code_field_test.dart` | Uses `amountOff: 10, newTotal: 90, amountOff: 15, newTotal: 85` | Re-type to `amountOffMinor: 1000, newTotalMinor: 9000`. |
| `test/dashboard/data/repositories/daily_report_repository_test.dart` | `revenue_minor: 125000` already kobo (Phase 16) | No change. |
| `test/dashboard/data/repositories/pricing_overrides_repository_test.dart` | `value: 20, value: 150` — percent values, not money | No change. |
| `test/dashboard/data/exceptions/*` | No money values | No change. |

**New tests** Phase 17 adds:
- `test/money/money_math_test.dart` — invariants:
  - `formatMoney(0, 'GHS') == 'GHS 0.00'`
  - `formatMoney(125, 'GHS') == 'GHS 1.25'`
  - `formatMoney(125000, 'GHS') == 'GHS 1,250.00'`
  - Sum of int kobo + int kobo never loses precision
  - Deposit basis-points math: `5000 * 3000 ~/ 10000 == 1500`
  - Fold-many invariant: 100 × `priceMinor: 1234` folded == `123400` exactly
- `test/payment/payment_controller_money_test.dart` — wire format:
  - Encoded JSON request body contains `totalAmountMinor: 5000` (int), not `totalAmount: 50.0` (float)
  - `_PaymentIntent` round-trips through `retryLast` preserving exact kobo

---

## Section 7 — Display format helper

Recommend creating **`lib/core/utils/money.dart`** with:

```dart
/// Formats minor-unit integer as a display string in the given currency.
/// Thousands-grouped, fixed 2-dp.
///
/// formatMoney(5000, 'GHS')   == 'GHS 50.00'
/// formatMoney(125000, 'GHS') == 'GHS 1,250.00'
/// formatMoney(0, 'GHS')      == 'GHS 0.00'
/// formatMoney(-5000, 'GHS')  == '-GHS 50.00'
String formatMoney(int minor, String currency) {
  final neg = minor < 0;
  final abs = neg ? -minor : minor;
  final major = abs ~/ 100;
  final minorPart = (abs % 100).toString().padLeft(2, '0');
  final grouped = _groupThousands(major);
  return '${neg ? '-' : ''}$currency $grouped.$minorPart';
}

String _groupThousands(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// Convert NUMERIC(12,2) major-unit value from JSON to int minor units.
/// Rounds half-away-from-zero, matching Postgres' default NUMERIC rounding.
int parseMoneyMinor(num major) => (major * 100).round();
```

Single source of truth. Every screen uses `formatMoney(...)`. Every repo
boundary that ingests NUMERIC uses `parseMoneyMinor(...)`. Audit grep will then
trivially detect any future regression: any new `.toDouble()` or `* 100` outside
this file is suspect.

---

## Section 8 — Currency dimensions

NanoEmbryo declares support for the following per existing migrations + edge
function provider list:

- **GHS** (Ghanaian cedi, Paystack default) — 1 cedi = 100 pesewa. 2dp.
- **NGN** (Naira, Paystack) — 1 naira = 100 kobo. 2dp.
- **USD** (Stripe Connect) — 1 dollar = 100 cents. 2dp.
- **EUR** (Stripe) — 1 euro = 100 cents. 2dp.

All four are 2dp. Phase 17 assumes the universal `minor = major × 100` model.
Should the platform ever add a zero-decimal currency (JPY, KRW) or a three-decimal
one (KWD, BHD), the `formatMoney` helper would need a per-currency decimal-places
lookup. **Out of scope.** Document the assumption in SPEC.

---

## Section 9 — Open questions / blockers

### Q1 — Wallet surfaces

Audit didn't deeply walk `lib/wallet/`. Phase 17 needs to confirm:
- `WalletTransactionModel` money fields
- `request_withdrawal` RPC return shape
- Wallet history display sites

**Decision needed in SPEC:** does Wave 4 include wallet surfaces, or is the
wallet a separate Phase 17.1 cleanup? My recommendation: **include in scope**.
The wallet talks to provider payouts and is unambiguously [FIN].

### Q2 — Analytics screen

`AnalyticsScreen` (Phase 10) computes revenue / no-show ratios from
`bookings.total_amount` directly. If we keep its repo call returning NUMERIC and
boundary-convert in `getMetrics()`, the analytics surface is fine — but its
display sites use `toStringAsFixed(2)` on doubles. Audit graded Phase 10 as the
worst surface; Phase 17 cleans this up.

### Q3 — `BookingPriceBreakdown` widget recompute risk

The widget receives `totalAmount`, `depositAmount`, `platformFee` from upstream.
Currently the parent does the fold; the widget displays. If we re-type the
upstream, the widget just changes its parameter types and `formatMoney` calls.
**No recompute risk.** Just retyping.

### Q4 — Deploy ordering

Recommend Wave 1 (edge functions) ships and is verified on staging BEFORE
Waves 3–6 ship. The user has been doing manual `supabase db push` + manual
Flutter rebuilds; this is fine. The dual-format predicate (Section 4) means a
mid-deploy mismatch is harmless.

### Q5 — `_kPlatformFee` constant

Currently `2.0` (cedis) in `booking_creation_controller.dart`. **Decision:**
flip to `_kPlatformFeeMinor = 200` (kobo). The audit had this as a P3 nice-to-have
"move to per-shop config." Phase 17 keeps the hardcoded constant but converts
the type. Per-shop config remains backlog.

---

## Section 10 — Recommended wave breakdown

| Wave | Scope | Parallelism |
|------|-------|-------------|
| **0 — SPEC** | Authoritative locked decisions, AMENDs, success criteria. | Sequential. |
| **1 — Edge functions (dual-format)** | `sanitize.ts` adds `sanitizeAmountMinor`. Provider port adds `amountMinor` field. Paystack + Stripe providers drop their `Math.round(input.amount * 100)` and use `input.amountMinor` directly. `create-booking/index.ts` accepts both legacy + new request keys, normalizes to int kobo, forwards int kobo to providers. Webhook handlers stop normalizing `/100`. | Mostly serial (provider port → both adapters → create-booking → webhooks). |
| **2 — Server RPC verification** | No schema changes; just verify each money-emitting RPC's contract is unchanged. Document the boundary-convert pattern. Spot-check wallet RPCs. | Parallel with Wave 1. |
| **3 — Dart models** | TimeSlotModel, BookingModel, BookingServiceModel, PaymentSettings, PromoValidation, AppliedPromo, _PaymentIntent flip to int *Minor fields. `lib/core/utils/money.dart` ships. | Sequential within wave (model → DTO → fromJson). |
| **4 — Dart controllers + booking flow** | payment_controller flips wire format to send `totalAmountMinor`. booking_creation_controller converts deposit to bps math. booking_confirmation_screen folds int kobo. payment_config introduces `depositBps` + `platformFeeMinor`. | Sequential within wave. |
| **5 — Display + promo + repos** | Every widget that displays money uses `formatMoney(minor, currency)`. promotions_repository boundary-converts NUMERIC → int kobo. supabase_booking_repository + supabase_dashboard_repository same treatment. | Parallel within wave (disjoint files). |
| **6 — Tests + SQL smoke** | Migrate existing tests (`time_slot_chip_test`, `client_promo_code_field_test`) to int-kobo fixtures. New `money_math_test.dart` invariants. Wire-format test asserts encoded JSON shape. SQL smoke confirms server-side validation epsilons still pass. | Parallel within wave. |
| **7 — Manual UAT** (deferred per project convention) | n/a |

**Cross-wave dependency:** Wave 1 MUST deploy + verify on staging before Waves
3–6 land in production. Both Waves 1 and 6 may run in parallel for authoring
(the smoke test is independent of the edge-function code), but the deployments
are sequenced.

---

## Sources

### Primary (HIGH confidence)
- `supabase/functions/_shared/providers/paystack_provider.ts:51,62,149,162`
- `supabase/functions/_shared/providers/stripe_provider.ts:46,63,128,143`
- `supabase/functions/_shared/sanitize.ts:83-97`
- `supabase/functions/create-booking/index.ts:48-50,196-198,202,393,401,405-407,470,619,684-685`
- `supabase/functions/stripe-webhook/index.ts:140`
- `lib/presentation/features/shops/booking/data/models/time_slot_model.dart:35-71`
- `lib/presentation/features/shops/booking/data/models/booking_model.dart:48-160`
- `lib/presentation/features/shops/booking/data/models/booking_service_model.dart:10,38`
- `lib/presentation/features/shops/booking/data/repositories/supabase_booking_repository.dart:540,552,1095`
- `lib/payment/presentation/controllers/payment_controller.dart:52-54,114-116,148-161,457`
- `lib/payment/config/payment_config.dart:32,123,126`
- `lib/payment/data/models/payment_settings_model.dart:138`
- `lib/presentation/features/shops/booking/presentation/widgets/client/booking_price_breakdown.dart:4-6`
- `lib/presentation/features/shops/booking/presentation/widgets/shared/booking_summary_card.dart:40`
- `lib/presentation/features/shops/booking/presentation/providers/booking_flow_state_provider.dart:37`
- `lib/presentation/features/shops/booking/presentation/widgets/client_promo_code_field.dart:33`

### Inherited from audit
- `.planning/audits/phases-10-16-quality-audit.md` — F-P0-1, F-P0-2, F-P2-4

## RESEARCH COMPLETE
