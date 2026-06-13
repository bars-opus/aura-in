# Phase 17 — Money Math Hardening · PLAN.md

## Outcome reminder

Close audit findings F-P0-1 + F-P2-4 (checklist v3.1 §2.19 P0-U / [FIN]). Every
money value that crosses a wire boundary uses **integer minor units** (kobo
for GHS). Storage stays `NUMERIC(12,2)` at rest. Dart in-memory math runs on
ints. Edge functions accept versioned `*Minor` keys and dual-format-detect for
backwards compatibility.

## Wave breakdown

| Wave | Scope | Depends on | Parallelism |
|------|-------|------------|-------------|
| 1 | Edge functions: `sanitizeAmountMinor`, provider adapters (Paystack + Stripe), `create-booking` dual-format, webhooks stop normalizing | — | Serial within wave |
| 2 | Server RPC verification (no DDL); wallet RPC contract check | — | Parallel with Wave 1 |
| 3 | Dart core: `lib/core/utils/money.dart`; DTOs flip to int; `payment_config` adds `depositBps` + `platformFeeMinor` | Wave 1 deployed on staging | Serial within wave |
| 4 | Booking flow controllers + payment controller wire format | Wave 3 | Serial within wave |
| 5 | Promo path + display layer + repository boundary conversions | Wave 3 | Parallel within wave (disjoint files) |
| 6 | Tests + SQL smoke | Waves 3–5 | Parallel within wave |
| 7 | Manual UAT (batched per project convention) | — | n/a |

**Cross-wave constraint:** Wave 1 ships to staging and is smoke-verified BEFORE
Waves 3–6 land. The dual-format detection means a mid-deploy mismatch is
harmless, but the verification gates the rollout.

---

## Wave 1 — Edge functions: dual-format support

### Task 1.1 — Add `sanitizeAmountMinor` to `_shared/sanitize.ts`

- **File:** `supabase/functions/_shared/sanitize.ts` (EDIT)
- **Read first:** `_shared/sanitize.ts:83-97` (existing `sanitizeAmount` for shape precedent), SPEC LD-4.
- **Description:** Add a parallel validator that accepts only non-negative integers in the new int-kobo format. Strict: rejects floats, NaN, Infinity, negatives, and oversized values. Coexists with `sanitizeAmount` for the legacy code path.

```ts
/**
 * Validate + sanitize a money amount in minor units (kobo / cents).
 * Strict: must be a non-negative integer.
 */
export function sanitizeAmountMinor(
  raw: unknown,
  opts: { min?: number; max?: number } = {},
): number {
  const min = opts.min ?? 0;
  const max = opts.max ?? 100_000_000_000; // 1B major units
  if (
    typeof raw !== 'number' ||
    !Number.isInteger(raw) ||
    raw < min ||
    raw > max
  ) {
    throw new Error(
      'invalid input: amountMinor must be a non-negative integer in [' +
        min +
        ', ' +
        max +
        ']',
    );
  }
  return raw;
}
```

- **Acceptance:**
  - `sanitizeAmountMinor(5000) === 5000`
  - `sanitizeAmountMinor(50.5)` throws
  - `sanitizeAmountMinor(-1)` throws
  - `sanitizeAmountMinor('5000')` throws
  - `sanitizeAmountMinor(NaN)` throws
- **Rollback:** Revert diff.
- **Estimate:** 20 min

### Task 1.2 — Extend `_shared/providers/port.ts` with `amountMinor`

- **File:** `supabase/functions/_shared/providers/port.ts` (EDIT)
- **Read first:** Current `port.ts`, SPEC LD-5.
- **Description:** Add `amountMinor: number` and `platformFeeAmountMinor?: number` to the provider port input types. Keep `amount` + `platformFeeAmount` as deprecated for one release cycle.

```ts
// Existing:
export interface CreatePaymentIntentInput {
  amount: number;            // legacy float cedis
  platformFeeAmount?: number;
  // ... other fields
}

// After:
export interface CreatePaymentIntentInput {
  amount: number;                  // @deprecated — use amountMinor
  amountMinor: number;             // NEW: int kobo
  platformFeeAmount?: number;      // @deprecated
  platformFeeAmountMinor?: number; // NEW
  // ... other fields
}
```

Same shape for `RefundInput` if it exists.

- **Acceptance:**
  - `port.ts` exports both fields.
  - `deno check` (or `tsc --noEmit` if using node mirror) passes.
- **Rollback:** Revert diff.
- **Estimate:** 15 min

### Task 1.3 — Drop `Math.round(... * 100)` from `paystack_provider.ts`

- **File:** `supabase/functions/_shared/providers/paystack_provider.ts` (EDIT)
- **Read first:** Lines 51, 62, 149, 162 (the four money sites).
- **Description:** Use `input.amountMinor` directly. Drop the ×100 inside the provider. The provider talks kobo natively; we just stop doing the conversion.

Concrete edits:
- **Line 51:** `amount: Math.round(input.amount * 100)` → `amount: input.amountMinor`
- **Line 62:** `body.transaction_charge = Math.round(input.platformFeeAmount * 100)` → `body.transaction_charge = input.platformFeeAmountMinor`
- **Line 149:** `amount: (d.amount ?? 0) / 100` → `amountMinor: (d.amount ?? 0)` (provider response: amount IS already kobo, just stop the /100)
- **Line 162:** `const amountKobo = Math.round(input.amount * 100)` → `const amountKobo = input.amountMinor`

- **Acceptance:**
  - `grep -n "\\* 100\\|/ 100" paystack_provider.ts` returns ZERO money-relevant hits.
  - `paystack_provider.initiate({amountMinor: 5000, ...})` calls Paystack with `amount: 5000` (SC-16).
- **Rollback:** Revert diff.
- **Estimate:** 25 min

### Task 1.4 — Drop `Math.round(... * 100)` from `stripe_provider.ts`

- **File:** `supabase/functions/_shared/providers/stripe_provider.ts` (EDIT)
- **Read first:** Lines 46, 63, 128, 143.
- **Description:** Mirror Task 1.3 for the Stripe adapter.

Concrete edits:
- **Line 46:** `unit_amount: Math.round(input.amount * 100)` → `unit_amount: input.amountMinor`
- **Line 63:** `Math.round(input.platformFeeAmount * 100)` → `input.platformFeeAmountMinor`
- **Line 128:** `amount: (session.amount_total ?? 0) / 100` → `amountMinor: (session.amount_total ?? 0)`
- **Line 143:** `const amountCents = Math.round(input.amount * 100)` → `const amountCents = input.amountMinor`

- **Acceptance:**
  - `grep -n "\\* 100\\|/ 100" stripe_provider.ts` returns ZERO money-relevant hits.
- **Rollback:** Revert diff.
- **Estimate:** 25 min

### Task 1.5 — Dual-format `create-booking/index.ts`

- **File:** `supabase/functions/create-booking/index.ts` (EDIT)
- **Read first:** Lines 40, 48–50, 196–202, 393, 401, 405–407, 470, 619, 684–685. SPEC LD-2 + LD-3 + LD-12.
- **Description:** The most complex task in Wave 1. Accept both legacy and new request body shapes. Detect via field presence. Normalize to int kobo internally. Forward int kobo to provider adapters. Tighten validation epsilon to exact match per LD-12.

Concrete edits:

**1. Request body shape (lines 40, 48–50):**

```ts
// Before:
type ServiceInput = { ..., priceAtBooking: number };
type RequestBody = { ..., totalAmount: number, depositAmount: number, platformFee: number };

// After:
type ServiceInput = { ...,
  priceAtBooking?: number;       // @deprecated legacy
  priceAtBookingMinor?: number;  // NEW
};
type RequestBody = { ...,
  totalAmount?: number;          // @deprecated
  totalAmountMinor?: number;     // NEW
  depositAmount?: number;        // @deprecated
  depositAmountMinor?: number;   // NEW
  platformFee?: number;          // @deprecated
  platformFeeMinor?: number;     // NEW
};
```

**2. Normalization at the top of the handler (replacing lines 196–202):**

```ts
// Normalize to int kobo. New-format keys take precedence; legacy keys are
// the fallback. After this block, every downstream variable is int kobo.
const totalAmountMinor: number =
  typeof rawBody.totalAmountMinor === 'number'
    ? sanitizeAmountMinor(rawBody.totalAmountMinor, { min: 1 })
    : sanitizeAmountMinor(
        Math.round((sanitizeAmount(rawBody.totalAmount, { min: 0.01 })) * 100),
        { min: 1 },
      );

const depositAmountMinor: number =
  typeof rawBody.depositAmountMinor === 'number'
    ? sanitizeAmountMinor(rawBody.depositAmountMinor, { min: 1 })
    : sanitizeAmountMinor(
        Math.round((sanitizeAmount(rawBody.depositAmount, { min: 0.01 })) * 100),
        { min: 1 },
      );

const platformFeeMinor: number =
  typeof rawBody.platformFeeMinor === 'number'
    ? sanitizeAmountMinor(rawBody.platformFeeMinor, { min: 0 })
    : sanitizeAmountMinor(
        Math.round((sanitizeAmount(rawBody.platformFee, { min: 0 })) * 100),
        { min: 0 },
      );

const services = rawBody.services.map((s) => ({
  ...s,
  priceAtBookingMinor:
    typeof s.priceAtBookingMinor === 'number'
      ? sanitizeAmountMinor(s.priceAtBookingMinor, { min: 0 })
      : sanitizeAmountMinor(
          Math.round((sanitizeAmount(s.priceAtBooking, { min: 0 })) * 100),
          { min: 0 },
        ),
}));
```

Then construct a `body` object that exclusively uses the new int fields:

```ts
const body = {
  ...rawBody,
  totalAmountMinor,
  depositAmountMinor,
  platformFeeMinor,
  services,
  // Keep legacy fields for backwards-compat storage in pending_payments
  // booking_data; we tag them as derived from the new keys.
  totalAmount: totalAmountMinor / 100,
  depositAmount: depositAmountMinor / 100,
  platformFee: platformFeeMinor / 100,
};
```

**3. Provider invocation (lines 393, 401, 470):**

```ts
// Paystack call:
amount: body.depositAmount,                  // BEFORE
amount: body.depositAmount,                  // AFTER (deprecated, kept for one cycle)
amountMinor: body.depositAmountMinor,        // AFTER (NEW)

platformFeeAmount: body.platformFee,         // BEFORE
platformFeeAmount: body.platformFee,         // AFTER (deprecated)
platformFeeAmountMinor: body.platformFeeMinor, // AFTER (NEW)
```

Actually cleaner: drop the legacy fields entirely from the provider call. The provider adapter just uses `input.amountMinor`. The deprecation is on the port type for one cycle; the create-booking handler can pass only the new field.

**4. Storage to `pending_payments.booking_data` (lines 405–407):**

```ts
// Before (float string):
total_amount: String(body.totalAmount),
deposit_amount: String(body.depositAmount),
platform_fee: String(body.platformFee),

// After (int kobo + legacy float for back-compat readers):
total_amount: String(body.totalAmount),     // legacy field
deposit_amount: String(body.depositAmount), // legacy field
platform_fee: String(body.platformFee),     // legacy field
total_amount_minor: body.totalAmountMinor,
deposit_amount_minor: body.depositAmountMinor,
platform_fee_minor: body.platformFeeMinor,
```

(The `pending_payments.booking_data` is a JSONB column; we just add fields, no DDL.)

**5. Server-side validation (lines 619 + 684–685) — LD-12 tightening:**

```ts
// Before (lines 618-620):
if (slot && Math.abs(slot.price - service.priceAtBooking) > 0.01) {

// After:
const slotPriceMinor = Math.round((slot.price as number) * 100);
if (slot && slotPriceMinor !== service.priceAtBookingMinor) {

// Before (lines 684-685):
const calculatedAmount = req.services.reduce((sum, s) => sum + s.priceAtBooking, 0);
if (Math.abs(calculatedAmount - req.totalAmount) > 0.01) {

// After:
const calculatedAmountMinor = req.services.reduce((sum, s) => sum + s.priceAtBookingMinor, 0);
if (calculatedAmountMinor !== req.totalAmountMinor) {
```

- **Acceptance:**
  - SC-15: both legacy and new request shapes normalize to the same int kobo value.
  - SC-14: `sanitizeAmountMinor` rejects `50.5`.
  - Validation: a payload with mismatched `priceAtBookingMinor` returns a 400 with `INVALID_PRICE_MISMATCH`.
  - `deno check` (or equivalent) passes.
  - A legacy-format request (with `totalAmount: 50.0`, no `totalAmountMinor`) successfully creates a payment intent with Paystack amount = 5000.
  - A new-format request (with `totalAmountMinor: 5000`) successfully creates the same intent.
- **Rollback:** Revert diff. `pending_payments` rows written under the new format have extra JSONB fields but the legacy readers will see the float fields too.
- **Estimate:** 90 min

### Task 1.6 — Stop `/ 100` normalization in `stripe-webhook/index.ts`

- **File:** `supabase/functions/stripe-webhook/index.ts` (EDIT)
- **Read first:** Line 140.
- **Description:** Replace `const amountPaid = (session.amount_total ?? 0) / 100;` with `const amountPaidMinor = session.amount_total ?? 0;`. Downstream uses of `amountPaid` switch to `amountPaidMinor`. Storage to `bookings.total_amount` (NUMERIC) does `amountPaidMinor / 100` at the boundary, since the column is still major-units.

Search and replace all downstream `amountPaid` references in the same file. Document the boundary.

- **Acceptance:**
  - No `/ 100` on `session.amount_total` anywhere in the file.
  - The `bookings.total_amount` UPDATE persists a value matching the original cents/100 (no behavior change in storage).
  - Stripe webhook integration test (if exists) passes.
- **Rollback:** Revert diff.
- **Estimate:** 30 min

### Task 1.7 — Audit `process-withdrawal` + `paystack-subaccount` for money math

- **File:** `supabase/functions/process-withdrawal/index.ts` (READ), `supabase/functions/paystack-subaccount/index.ts` (READ)
- **Description:** Grep both for `* 100`, `/ 100`, `parseFloat`, `Number(...)` on money columns. If any found, write Task 1.7.X edits in this PLAN. Research §1.5 indicated zero hits but did not deeply walk.
- **Acceptance:** Either zero money math found (document N/A) OR concrete edits authored.
- **Estimate:** 15 min

### Task 1.8 — Wave 1 deploy + staging smoke

- **File:** n/a (operational)
- **Description:** Deploy edge functions to staging: `supabase functions deploy create-booking paystack-webhook stripe-webhook process-withdrawal paystack-subaccount`. Smoke a legacy-format request body (old Flutter shape) and confirm it still completes. Smoke a new-format request body (using a curl or Postman with `totalAmountMinor`) and confirm it completes with the same provider amount.
- **Acceptance:** Both smokes pass. No 500s in the logs.
- **Estimate:** 30 min

---

## Wave 2 — Server RPC verification (no DDL)

### Task 2.1 — Verify `validate_and_apply_promo` round-trip

- **File:** No edit. Verification only.
- **Description:** Confirm the RPC returns `amount_off NUMERIC, new_total NUMERIC` as currently. Document in PLAN that Wave 5 boundary-converts at the Dart repo.
- **Acceptance:** Comment block in `promotions_repository.dart` referencing the contract.
- **Estimate:** 10 min

### Task 2.2 — Verify `redeem_promotion` + `generate_available_slots`

- **File:** No edit.
- **Description:** Both already documented in Phase 13/15. Confirm Wave 5 handles the boundary correctly.
- **Estimate:** 5 min

### Task 2.3 — Audit wallet RPCs

- **File:** Grep `supabase/migrations/` for any RPC with `withdraw`, `payout`, `wallet`, `transaction_amount` in the name.
- **Description:** Inventory. If anything found, document the return shape. Wave 3/4 retypes the Dart side accordingly.
- **Acceptance:** Comment block in `wallet_repository.dart` (if exists) or a brief note in this PLAN naming the RPCs + their return shapes.
- **Estimate:** 20 min

---

## Wave 3 — Dart core: types + helper

### Task 3.1 — Ship `lib/core/utils/money.dart`

- **File:** `lib/core/utils/money.dart` (NEW)
- **Read first:** SPEC LD-7.
- **Description:** Single source of truth. Three pure functions: `formatMoney`, `parseMoneyMinor`, `applyBps`. No I/O, no async, no dependencies beyond `dart:core`.

```dart
// lib/core/utils/money.dart
//
// Phase 17 — single source of truth for money formatting + conversion.
//
// The booking, payment, promo, wallet, and analytics surfaces all use
// int *Minor (kobo for GHS) for in-memory math. The conversion to/from
// NUMERIC(12,2) major-unit storage happens at exactly two boundaries:
//   - parseMoneyMinor(num) — at every PostgREST ↔ DTO unmarshalling site
//   - formatMoney(int, currency) — at every UI display site
//
// Any .toDouble() on a money column, any inline `* 100`, any
// toStringAsFixed(2) outside this file is a regression (see SC-2, SC-3).

/// Format an int minor-unit value as a display string. Thousands-grouped,
/// fixed 2 decimal places. Negative values get a leading minus.
///
/// formatMoney(0, 'GHS')      == 'GHS 0.00'
/// formatMoney(5000, 'GHS')   == 'GHS 50.00'
/// formatMoney(125000, 'GHS') == 'GHS 1,250.00'
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

/// Convert a NUMERIC(12,2) major-unit JSON value to int minor units.
/// Rounds half-away-from-zero, matching Postgres NUMERIC's default rounding.
///
/// parseMoneyMinor(50.00)  == 5000
/// parseMoneyMinor(50.005) == 5001  (rounds away from zero)
/// parseMoneyMinor(0)      == 0
int parseMoneyMinor(num major) => (major * 100).round();

/// Multiply an int minor value by a basis-point fraction (1 bp = 0.01%).
/// Result rounds toward zero (truncates fractional kobo).
///
/// applyBps(5000, 3000) == 1500   // 5000 * 30%
/// applyBps(5000, 2500) == 1250   // 5000 * 25%
/// applyBps(5000, 0)    == 0
int applyBps(int minor, int bps) => (minor * bps) ~/ 10000;
```

- **Acceptance:** SC-4 through SC-10 all pass (asserted in Wave 6 tests).
- **Rollback:** Delete file.
- **Estimate:** 20 min

### Task 3.2 — Flip `TimeSlotModel.price` to `priceMinor`

- **File:** `lib/presentation/features/shops/booking/data/models/time_slot_model.dart` (EDIT)
- **Read first:** Lines 35–36, 70–71.
- **Description:**
  - `final double price` → `final int priceMinor`
  - `final double? basePrice` → `final int? basePriceMinor`
  - `fromJson` uses `parseMoneyMinor((json['price'] as num))` and `(json['base_price'] as num?)?.let((m) => parseMoneyMinor(m))`
  - Update Equatable props accordingly
  - Update doc comments referencing prices

- **Acceptance:** `flutter analyze` clean. All consumers compile (will surface failures in Wave 5).
- **Rollback:** Revert diff.
- **Estimate:** 25 min

### Task 3.3 — Flip `BookingModel` money fields

- **File:** `lib/presentation/features/shops/booking/data/models/booking_model.dart` (EDIT)
- **Read first:** Lines 48–50, 158–160.
- **Description:**
  - `totalAmount`, `depositAmount`, `platformFee` → `totalAmountMinor`, `depositAmountMinor`, `platformFeeMinor` (all `int`; `platformFeeMinor` stays `int?` if currently nullable).
  - `fromJson` boundary-converts via `parseMoneyMinor`.
- **Acceptance:** `flutter analyze` clean (callers will be touched in later waves).
- **Rollback:** Revert diff.
- **Estimate:** 25 min

### Task 3.4 — Flip `BookingServiceModel.priceAtBooking`

- **File:** `lib/presentation/features/shops/booking/data/models/booking_service_model.dart` (EDIT)
- **Read first:** Lines 10, 38.
- **Description:** `final double priceAtBooking` → `final int priceAtBookingMinor`. `fromJson` boundary-converts.
- **Acceptance:** `flutter analyze` clean.
- **Estimate:** 15 min

### Task 3.5 — Flip `PaymentSettings.payoutMinimum`

- **File:** `lib/payment/data/models/payment_settings_model.dart` (EDIT)
- **Read first:** Line 138.
- **Description:** `payoutMinimum: double` → `payoutMinimumMinor: int`. `fromJson` boundary-converts.
- **Acceptance:** `flutter analyze` clean.
- **Estimate:** 10 min

### Task 3.6 — Flip `_PaymentIntent` record + `processPayment` signature

- **File:** `lib/payment/presentation/controllers/payment_controller.dart` (EDIT)
- **Read first:** Lines 52–54, 114–116, 148–161, 457.
- **Description:**
  - `_PaymentIntent.totalAmount/depositAmount/platformFee` → `*Minor` (int).
  - `processPayment` named params: `totalAmount`/`depositAmount`/`platformFee` → `totalAmountMinor`/`depositAmountMinor`/`platformFeeMinor` (int).
  - `requestBody` JSON sends `totalAmountMinor`, `depositAmountMinor`, `platformFeeMinor` keys (per SPEC LD-2). Drop the legacy float keys.
  - Cart fingerprint hash (the F-P0-3 sha256) now hashes int kobo values.
  - Line 457 `_fireSuccess`: `amount: (booking['total_amount'] as num?)?.toDouble() ?? 0` → `amountMinor: parseMoneyMinor((booking['total_amount'] as num?) ?? 0)`.
  - `PaymentSuccessInfo.amount: double` → `PaymentSuccessInfo.amountMinor: int`.
- **Acceptance:** `flutter analyze` clean. Generated JSON for a known input matches SC-13 (`totalAmountMinor: 5000` as JSON int, not `totalAmount: 50.0` float).
- **Rollback:** Revert diff.
- **Estimate:** 45 min

### Task 3.7 — Flip `payment_config.dart` to bps + int

- **File:** `lib/payment/config/payment_config.dart` (EDIT)
- **Read first:** Lines 32, 123, 126.
- **Description:**
  - `depositFraction: double` → `depositBps: int` (3000 = 30%).
  - `platformFeeFraction: double` (if unused, delete) — replace with the hardcoded `_kPlatformFeeMinor = 200` already in `booking_creation_controller.dart` if that's the consumer.
  - Line 32: `PaystackConfig.amount: double` — verify usage. If unused (legacy field), delete. Else convert.
- **Acceptance:** `flutter analyze` clean. `PaymentConfig.depositBps == 3000` by default.
- **Estimate:** 20 min

### Task 3.8 — Flip `BookingFlowState.totalPrice`

- **File:** `lib/presentation/features/shops/booking/presentation/providers/booking_flow_state_provider.dart` (EDIT)
- **Read first:** Line 37.
- **Description:** `totalPrice: double` → `totalPriceMinor: int`. State holder. All callers updated in Wave 4.
- **Acceptance:** `flutter analyze` clean.
- **Estimate:** 10 min

---

## Wave 4 — Booking flow controllers + payment wire format

### Task 4.1 — `booking_creation_controller.dart` int kobo math

- **File:** `lib/presentation/features/shops/booking/presentation/controllers/booking_creation_controller.dart` (EDIT)
- **Read first:** The whole file. Phase 15 already touched the money math; Phase 17 retypes.
- **Description:**
  - Constants: `_kDepositPercent = 0.30` → `_kDepositBps = 3000`. `_kPlatformFee = 2.0` → `_kPlatformFeeMinor = 200`.
  - `_calculateTotalAmount(services, quantities, timeSlots)` returns `int` (sum of `timeSlots[id]?.priceMinor ?? service.priceMinor`).
  - `depositMinor = applyBps(totalAmountMinor, _kDepositBps)`.
  - `_createBookingServices` writes `priceAtBookingMinor: int` (from the effective slot price).
  - `_createFreelancerBookingServices` same change.
  - `BookingModel.totalAmount/depositAmount/platformFee` writes use the `*Minor` int values.
- **Acceptance:** `flutter analyze` clean. SC-11 invariant holds: 100 × `priceMinor: 1234` folded == `123400` exactly.
- **Rollback:** Revert diff.
- **Estimate:** 60 min

### Task 4.2 — `booking_confirmation_screen.dart` int kobo flow

- **File:** `lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart` (EDIT)
- **Read first:** Whole file. Phase 15 + the F-P0-2 / F-P2-8 hardening already touched it.
- **Description:**
  - `_calculateTotalPrice` returns `int`. Reads `priceMinor` from time slots.
  - `totalPrice` state holder is int.
  - `effectiveTotal = _appliedPromo?.newTotalMinor ?? totalPrice` (int).
  - `servicesData` payload uses `priceAtBookingMinor` keys (per SPEC LD-2).
  - `processPayment` call sites pass the new `*Minor` named params.
  - `_calculateTotalDuration` and other non-money math unchanged.
  - Update the display-side calls that show prices to use `formatMoney(...)`.
- **Acceptance:** `flutter analyze` clean. SC-19: a 9000-kobo total with a 10% promo applied sends `totalAmountMinor: 8100` over the wire.
- **Rollback:** Revert diff.
- **Estimate:** 60 min

---

## Wave 5 — Promo + display + repos (parallel)

### Task 5.1 — `PromoValidation` + `AppliedPromo` int kobo

- **File:** `lib/presentation/features/shops/booking/presentation/widgets/client_promo_code_field.dart` (EDIT), `lib/presentation/features/shops/dashboard/data/models/promotion_model.dart` (EDIT — if `PromoValidation` lives there)
- **Read first:** Line 33 in `client_promo_code_field.dart`.
- **Description:**
  - `PromoValidation.amountOff`, `newTotal` → `amountOffMinor`, `newTotalMinor` (int).
  - `AppliedPromo.amountOff`, `newTotal` → `amountOffMinor`, `newTotalMinor` (int).
  - Constructor + factory + JSON parsing all flip.
  - `ClientPromoCodeField` displays use `formatMoney(amountOffMinor, currency)`.
- **Acceptance:** `flutter analyze` clean. Existing `client_promo_code_field_test.dart` migrates and passes (Wave 6).
- **Estimate:** 35 min

### Task 5.2 — `promotions_repository.dart` boundary conversion

- **File:** `lib/presentation/features/shops/dashboard/data/repositories/promotions_repository.dart` (EDIT)
- **Description:** Wherever the repo parses `validate_and_apply_promo`'s response, boundary-convert via `parseMoneyMinor`.

```dart
// Before:
final amountOff = (row['amount_off'] as num).toDouble();
final newTotal  = (row['new_total']  as num).toDouble();

// After:
final amountOffMinor = parseMoneyMinor(row['amount_off'] as num);
final newTotalMinor  = parseMoneyMinor(row['new_total']  as num);
```

- **Acceptance:** `flutter analyze` clean. Phase 13 tests still pass.
- **Estimate:** 25 min

### Task 5.3 — `supabase_booking_repository.dart` boundary conversion

- **File:** `lib/presentation/features/shops/booking/data/repositories/supabase_booking_repository.dart` (EDIT)
- **Read first:** Lines 540, 552, 1095 + grep for any other `.toDouble()` on money columns.
- **Description:**
  - Line 540 `'price_at_booking': (row['price_at_booking'] ?? 0.0).toDouble()` → `'price_at_booking_minor': parseMoneyMinor((row['price_at_booking'] ?? 0) as num)`.
  - Line 552 `'price': ...toDouble()` → `'price_minor': parseMoneyMinor(...)`.
  - Line 1095 `price: (json['price'] as num?)?.toDouble() ?? 0.0` → `priceMinor: json['price'] == null ? 0 : parseMoneyMinor(json['price'] as num)`.
  - Update any internal map keys that downstream `TimeSlotModel.fromJson` reads.
- **Acceptance:** `flutter analyze` clean. `time_slot_chip_test.dart` migrates and passes.
- **Estimate:** 40 min

### Task 5.4 — `supabase_dashboard_repository.dart` analytics boundary

- **File:** `lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart` (EDIT)
- **Description:**
  - Find the 22+ `(... ?? 0).toDouble()` audit sites. The audit specifically called out lines around 114–117 (today revenue fold).
  - Every site reading a money column boundary-converts via `parseMoneyMinor` and the consumer DTO is int.
  - `TodayScheduleItem.price` / `depositPaid` are int now (assuming the model is in scope).
  - `WorkerPerformance.revenue` is int.
  - Cascading model updates as needed.
- **Acceptance:** `flutter analyze` clean. Analytics screen still renders.
- **Estimate:** 60 min

### Task 5.5 — Wallet surfaces (LD-13)

- **File:** Files under `lib/wallet/` (EDIT)
- **Read first:** `WalletTransactionModel`, `WalletRepository`, the wallet display screens. Inventory from Wave 2 Task 2.3.
- **Description:**
  - `WalletTransactionModel` money fields flip to `*Minor: int`.
  - Repository boundary-converts.
  - Wallet display widgets use `formatMoney`.
  - `request_withdrawal` RPC consumer flips (verify the RPC contract from Wave 2 Task 2.3).
- **Acceptance:** `flutter analyze` clean. Wallet history renders.
- **Estimate:** 45 min

### Task 5.6 — Widget display sweep

- **File:** Multiple display widgets:
  - `lib/presentation/features/shops/booking/presentation/widgets/time_slot/time_slot_chip.dart`
  - `lib/presentation/features/shops/booking/presentation/widgets/shared/booking_summary_card.dart`
  - `lib/presentation/features/shops/booking/presentation/widgets/client/booking_price_breakdown.dart`
  - `lib/presentation/features/shops/booking/presentation/screens/shared/booking_detail_screen.dart`
- **Description:** Each widget that receives money flips its parameter type to `int *Minor` and uses `formatMoney(...)` in its render. Phase 16's `formatMoney(revenueMinor, currency)` style is the precedent.
- **Acceptance:**
  - SC-3: `grep -rn 'toStringAsFixed(2)' lib/ | grep -v money.dart | grep -v _test.dart` returns ZERO money hits.
  - `flutter analyze` clean.
- **Estimate:** 50 min

---

## Wave 6 — Tests + SQL smoke

### Task 6.1 — `test/money/money_math_test.dart`

- **File:** `test/money/money_math_test.dart` (NEW)
- **Description:** Invariants for the new helper:
  - `formatMoney(0, 'GHS') == 'GHS 0.00'`
  - `formatMoney(5000, 'GHS') == 'GHS 50.00'`
  - `formatMoney(125000, 'GHS') == 'GHS 1,250.00'`
  - `formatMoney(1234567, 'GHS') == 'GHS 12,345.67'`
  - `formatMoney(-5000, 'GHS') == '-GHS 50.00'`
  - `parseMoneyMinor(50.00) == 5000`
  - `parseMoneyMinor(50.005) == 5001`
  - `parseMoneyMinor(0) == 0`
  - `applyBps(5000, 3000) == 1500`
  - `applyBps(5000, 2500) == 1250`
  - `applyBps(5000, 0) == 0`
  - Fold-many invariant: `List.filled(100, 1234).fold(0, (a, b) => a + b) == 123400`
  - IEEE invariant: explicitly show `0.1 + 0.2 != 0.3` AND `parseMoneyMinor(0.1) + parseMoneyMinor(0.2) == parseMoneyMinor(0.3)` (i.e. 10 + 20 == 30 exactly).
- **Acceptance:** All cases pass. SC-4 through SC-12 covered.
- **Estimate:** 30 min

### Task 6.2 — `test/payment/payment_controller_money_test.dart`

- **File:** `test/payment/payment_controller_money_test.dart` (NEW)
- **Description:** Wire-format assertion. Use mocktail or a fake Supabase client to capture the request body sent to `functions.invoke`. Assert:
  - `body['totalAmountMinor']` is a Dart `int`, not `double` (no `.0`).
  - `body['depositAmountMinor']` is `int`.
  - `body['platformFeeMinor']` is `int`.
  - The legacy `totalAmount` key is absent.
  - Idempotency key fingerprint is stable across runs with identical kobo input.
- **Acceptance:** SC-13, SC-20 covered.
- **Estimate:** 45 min

### Task 6.3 — `test/booking/booking_creation_controller_money_test.dart`

- **File:** `test/booking/booking_creation_controller_money_test.dart` (NEW)
- **Description:** Controller-side invariants:
  - 100 × `priceMinor: 1234` folds to `123400` (SC-11).
  - `applyBps(totalMinor, _kDepositBps)` returns the right deposit.
  - `_calculateTotalAmount` returns the right int.
  - `_createBookingServices` writes `priceAtBookingMinor` exactly matching the effective slot price.
- **Estimate:** 40 min

### Task 6.4 — Migrate existing tests

- **Files:**
  - `test/booking/time_slot_chip_test.dart` (EDIT)
  - `test/booking/client_promo_code_field_test.dart` (EDIT if exists)
- **Description:**
  - `price: 50` fixtures → `priceMinor: 5000`.
  - `basePrice: 40` → `basePriceMinor: 4000`.
  - `amountOff: 10, newTotal: 90` → `amountOffMinor: 1000, newTotalMinor: 9000`.
  - Display assertions for `'GHS 40.00'` etc. stay the same string; just sourced from int.
- **Acceptance:** Pre-Phase-17 test suite (42/42) still passes plus the new tests.
- **Estimate:** 30 min

### Task 6.5 — Edge function dual-format smoke

- **File:** `.planning/phases/17-money-math-hardening/sql/17_dual_format_smoke.sh` (NEW)
- **Description:** A shell smoke that issues two curl requests to the staging `create-booking` endpoint:
  1. Legacy format: `{"totalAmount": 50.0, "depositAmount": 15.0, ...}`
  2. New format: `{"totalAmountMinor": 5000, "depositAmountMinor": 1500, ...}`
  Both must succeed. Both must produce a `pending_payments` row with matching `total_amount` (legacy float field) and `total_amount_minor` (new int field) values.
- **Acceptance:** SC-15 verified.
- **Estimate:** 25 min

### Task 6.6 — Grep-based SC verification

- **File:** No file. Mechanical verification per SC-1, SC-2, SC-3.
- **Description:** Run the three SPEC grep invariants:
  - SC-1: `grep -rn 'double.*[Pp]rice\|double.*[Aa]mount\|double.*[Tt]otal\|double.*[Dd]eposit\|double.*[Pp]latform[Ff]ee' lib/presentation/features/shops/booking/ lib/payment/ lib/wallet/ | grep -v _test.dart` — must return ZERO.
  - SC-2: `grep -rn '\.toDouble()' lib/presentation/features/shops/booking/ lib/payment/ lib/wallet/` — must return ZERO money-column hits (lat/long/rating allowed).
  - SC-3: `grep -rn 'toStringAsFixed(2)' lib/ | grep -v 'lib/core/utils/money.dart' | grep -v _test.dart` — must return ZERO money-formatting hits.
- **Acceptance:** All three pass.
- **Estimate:** 15 min

---

## Wave 7 — Manual UAT

Deferred per project convention. Manual UAT covers the end-to-end booking flow
with both a legacy-build and a new-build client against staging. Specifically:
- A legacy Flutter client (compiled before Phase 17 ships) successfully books +
  pays. Edge function uses the dual-format fallback.
- A new Flutter client successfully books + pays. Edge function uses the new int
  path.
- A promo applied on a multi-service cart with a 30% deposit produces an exact
  kobo total at every layer (form → screen → controller → wire → edge function
  → provider → webhook → bookings table).
- The owner's daily report still computes correctly post-Phase-17 (revenue
  matches the sum of `price_at_booking`).

---

## Verification matrix (SC → wave + task)

| SC | Description | Wave | Task | Test command |
|----|-------------|------|------|--------------|
| SC-1 | Zero `double` money fields in scoped lib paths | 6 | 6.6 | grep |
| SC-2 | Zero `.toDouble()` money sites | 6 | 6.6 | grep |
| SC-3 | Zero `toStringAsFixed(2)` outside money.dart | 6 | 6.6 | grep |
| SC-4 | `formatMoney(0, 'GHS')` | 6 | 6.1 | `flutter test test/money/` |
| SC-5 | `formatMoney(5000, 'GHS')` | 6 | 6.1 | same |
| SC-6 | `formatMoney(125000, 'GHS')` | 6 | 6.1 | same |
| SC-7 | `formatMoney(-5000, 'GHS')` | 6 | 6.1 | same |
| SC-8 | `parseMoneyMinor(50.00) == 5000` | 6 | 6.1 | same |
| SC-9 | `parseMoneyMinor(50.005) == 5001` | 6 | 6.1 | same |
| SC-10 | `applyBps(5000, 3000) == 1500` | 6 | 6.1 | same |
| SC-11 | Fold-many invariant | 6 | 6.1, 6.3 | same + controller test |
| SC-12 | IEEE invariant (0.1+0.2) | 6 | 6.1 | `flutter test test/money/` |
| SC-13 | Encoded JSON has `totalAmountMinor: 5000` int | 6 | 6.2 | `flutter test test/payment/` |
| SC-14 | `sanitizeAmountMinor` rejects 50.5 | 1 | 1.1 | edge-fn unit test (deno) |
| SC-15 | Edge fn accepts both formats | 6 | 6.5 | shell smoke |
| SC-16 | Paystack receives `amount: 5000` | 1 | 1.3 | edge-fn unit test |
| SC-17 | TimeSlotChip renders 'GHS 40.00' from 4000 | 6 | 6.4 | `flutter test test/booking/time_slot_chip_test.dart` |
| SC-18 | BookingPriceBreakdown receives int | 5 | 5.6 | `flutter analyze` + visual UAT |
| SC-19 | Promo round-trip 9000 → 8100 | 4 | 4.2 | controller test |
| SC-20 | `_kPlatformFeeMinor == 200` | 4 | 4.1 | controller test |

---

## Files-touched manifest

**New files (5):**
- `lib/core/utils/money.dart`
- `test/money/money_math_test.dart`
- `test/payment/payment_controller_money_test.dart`
- `test/booking/booking_creation_controller_money_test.dart`
- `.planning/phases/17-money-math-hardening/sql/17_dual_format_smoke.sh`

**Edge function edits (6):**
- `supabase/functions/_shared/sanitize.ts`
- `supabase/functions/_shared/providers/port.ts`
- `supabase/functions/_shared/providers/paystack_provider.ts`
- `supabase/functions/_shared/providers/stripe_provider.ts`
- `supabase/functions/create-booking/index.ts`
- `supabase/functions/stripe-webhook/index.ts`

**Dart edits (~18):**
- Models: `time_slot_model.dart`, `booking_model.dart`, `booking_service_model.dart`, `payment_settings_model.dart`, `promotion_model.dart`
- Controllers: `payment_controller.dart`, `booking_creation_controller.dart`, `payment_config.dart`, `booking_flow_state_provider.dart`
- Screens: `booking_confirmation_screen.dart`, `booking_detail_screen.dart`
- Widgets: `time_slot_chip.dart`, `client_promo_code_field.dart`, `booking_summary_card.dart`, `booking_price_breakdown.dart`
- Repositories: `supabase_booking_repository.dart`, `supabase_dashboard_repository.dart`, `promotions_repository.dart`
- Wallet: TBD per Wave 2 Task 2.3 inventory

**Test edits (2):**
- `test/booking/time_slot_chip_test.dart`
- `test/booking/client_promo_code_field_test.dart` (if exists)

**No SQL migrations.**

---

## Out-of-band items (documented skip)

- **Legacy edge function branch removal.** Stays one release cycle after Flutter
  ships. Wave 8 (backlog) audits `pending_payments` rows for 30 days for any
  legacy-key creation, then removes the fallback.
- **Per-shop deposit / platform-fee config.** P3 nice-to-have from the original
  audit. Hardcoded constants stay; per-shop config remains backlog.
- **Zero-decimal currency support (JPY, KRW).** Universal `minor = major × 100`
  assumption stays for Phase 17. Adding a different-decimal currency requires a
  per-currency lookup in `formatMoney`; deferred.

## PR rollout / verification

Before merging the Phase 17 PR:

1. ✅ All wave tasks complete; this PLAN's checkboxes ticked.
2. ✅ `flutter analyze` clean across all touched files.
3. ✅ Full test suite passes (42/42 pre-Phase-17 + new tests). Final count target: ~55/55.
4. ✅ Wave 6 grep invariants pass (SC-1, SC-2, SC-3).
5. ✅ Wave 6 shell smoke passes against staging (SC-15).
6. ✅ Manual UAT plan written (Wave 7).
7. ✅ Commit message references audit findings F-P0-1 + F-P2-4 as closed.

## PLANNING COMPLETE

Total tasks: 22 (across 6 implementation waves; Wave 7 deferred).
Total estimated time: ~12 hours.
