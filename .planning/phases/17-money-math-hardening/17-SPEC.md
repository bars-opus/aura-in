# Phase 17 — Money Math Hardening

## Outcome

Close audit findings F-P0-1 + F-P2-4 (checklist v3.1 §2.19 P0-U / [FIN]). Every
money value that crosses a wire boundary — Dart ↔ Edge Function, Dart ↔ provider
SDK, Dart in-memory math — uses **integer minor units** (kobo for GHS, cents for
USD). Storage stays `NUMERIC(12,2)` at rest; the conversion happens at every
PostgrestException ↔ DTO boundary.

No payment ever recomputes from `double * double`. No checkout total ever
shows `$50.00000001` rounding dust. No promo discount ever drifts by a cent
between client estimate and server validation.

This phase is the cleanup the audit promised "in a future hardening phase."
With it landed, the booking-flow, payment, promo, wallet, and analytics
surfaces all score 9–10/10 on checklist §2.19.

## Why this matters

- **Correctness:** `$0.1 + $0.2 != $0.3` in IEEE-754 binary floating-point. The
  checkout flow folds 1–N service prices, applies a deposit fraction, computes
  a platform fee, applies an optional promo discount, and transmits the result
  across a JSON wire. Every fold is one float operation; floats accumulate
  rounding error. At GHS or NGN scale the error is sub-pesewa and effectively
  invisible. At larger amounts or higher transaction counts, it becomes a real
  revenue leak (or a real refund overcharge).
- **Provider contract:** Paystack and Stripe both expect integer minor units.
  The edge function currently multiplies `Math.round(input.amount * 100)` to
  satisfy this. By the time we hit `Math.round`, we've already lost precision
  to floats. Doing the math in int kobo end-to-end means the value that hits
  the provider is exactly what the client owed.
- **Audit gate:** the v3.1 checklist marks 2.19 as P0-U for [FIN] surfaces. The
  audit deferred this finding explicitly. Phase 17 closes it.

## Definitions

- **Major unit** — currency-display unit. GHS 50.00. USD 1.99.
- **Minor unit** — integer subdivision. 5000 kobo. 199 cents. Universally
  `major × 100` for every currency NanoEmbryo supports (GHS, NGN, USD, EUR;
  see § Out of scope for zero-decimal currencies).
- **Wire format** — JSON sent between Dart and an Edge Function. Phase 17
  locks the new format to send int minor units under explicit `*Minor` keys
  (e.g. `totalAmountMinor`, `depositAmountMinor`, `platformFeeMinor`).
- **Boundary conversion** — the single point where a NUMERIC-typed JSON value
  from PostgREST becomes an int kobo Dart value. Always
  `((row['x'] as num) * 100).round()`.
- **Basis points (bps)** — integer fraction. 3000 bps = 30%. Phase 17 replaces
  `depositFraction: 0.30` with `depositBps: 3000` and computes deposit as
  `totalMinor * depositBps ~/ 10000`.

## Locked decisions

The following decisions are LOCKED. Implementation must match. Any deviation
requires re-opening this SPEC.

### LD-1 — Storage unchanged

`NUMERIC(12,2)` stays. No schema migrations are required for Phase 17. Storage
is already minor-unit-safe (exact decimal). The bug is wire format + client
arithmetic, not storage.

### LD-2 — Wire format: new keys with `*Minor` suffix

Edge function request bodies use **distinct field names** for the int-kobo
format vs. the legacy float-cedis format. This is the discriminator that lets
the edge function dual-format-detect without heuristics.

**Old format (legacy Flutter pre-Phase-17):**
```json
{ "totalAmount": 50.00, "depositAmount": 15.00, "platformFee": 2.00,
  "services": [{ "priceAtBooking": 50.00, ... }] }
```

**New format (post-Phase-17 Flutter):**
```json
{ "totalAmountMinor": 5000, "depositAmountMinor": 1500, "platformFeeMinor": 200,
  "services": [{ "priceAtBookingMinor": 5000, ... }] }
```

A request body MUST contain either all-new keys or all-old keys; mixing keys is
a 400. The edge function detects the new keys first; on absence, falls back to
the legacy keys.

### LD-3 — Dual-format edge function detection

Inside the edge function, normalization happens at one entry point per money
field:

```ts
const totalAmountMinor: number =
  typeof body.totalAmountMinor === 'number'
    ? body.totalAmountMinor
    : Math.round((body.totalAmount ?? 0) * 100);
```

After normalization, the rest of the edge function operates exclusively on int
kobo. The provider adapters (Paystack, Stripe) take int kobo directly — their
internal `Math.round(input.amount * 100)` is removed.

The legacy branch survives until 100% of Flutter clients are on the new build.
Wave 8 (out of v1 scope; backlog) audits `pending_payments` rows for any legacy-
key creation in the prior 30 days and removes the fallback once zero hits.

### LD-4 — `sanitizeAmountMinor` validator

`_shared/sanitize.ts` adds a parallel validator for the new int format:

```ts
export function sanitizeAmountMinor(
  raw: unknown,
  opts: { min?: number; max?: number } = {},
): number {
  const min = opts.min ?? 0;          // already kobo
  const max = opts.max ?? 100_000_000_000;  // 1 billion major units = 100B kobo
  if (typeof raw !== 'number' || !Number.isInteger(raw) || raw < min || raw > max) {
    throw new Error('invalid input: amountMinor must be a non-negative integer');
  }
  return raw;
}
```

Strict. Non-integer numeric inputs are rejected. The legacy `sanitizeAmount`
stays — it's called only on the legacy code path.

### LD-5 — Provider adapters take int kobo

`paystack_provider.ts` and `stripe_provider.ts` accept a new field
`input.amountMinor: number` instead of `input.amount: number`. Their internal
`Math.round(input.amount * 100)` is removed; the int kobo passes straight through
to the provider SDK.

The legacy `input.amount` field stays on the port type as deprecated for one
release cycle. The create-booking handler stops setting it after Wave 1 ships.

### LD-6 — Dart canonical type: `int` for every money value

Every money field on every model, DTO, controller-state record, provider
intent, widget parameter, and config constant is `int *Minor`. No `double` for
money anywhere in the booking, payment, promo, wallet, or analytics paths.

Exceptions:
- **Ratios** (deposit, platform-fee) are basis points (`depositBps: int`,
  `platformFeeBps: int`).
- **Display strings** in widget text are formatted via `formatMoney(minor,
  currency)` from a single helper (LD-7).
- **NUMERIC-typed JSON from PostgREST** is converted at the repository boundary
  via `parseMoneyMinor(num major) => (major * 100).round()`. The Dart variable
  carrying that value is `int`.

### LD-7 — `lib/core/utils/money.dart` is the single source of truth

Ship `lib/core/utils/money.dart` with three functions:

```dart
/// Format an int minor-unit value as a display string.
/// formatMoney(5000, 'GHS')   == 'GHS 50.00'
/// formatMoney(125000, 'GHS') == 'GHS 1,250.00'
/// formatMoney(0, 'GHS')      == 'GHS 0.00'
/// formatMoney(-5000, 'GHS')  == '-GHS 50.00'
String formatMoney(int minor, String currency);

/// Convert a NUMERIC(12,2) major-unit JSON value to int minor units.
/// Rounds half-away-from-zero, matching Postgres NUMERIC rounding behaviour.
int parseMoneyMinor(num major);

/// Multiply an int minor value by a basis-point fraction.
/// applyBps(5000, 3000) == 1500  (5000 * 30% = 1500)
/// applyBps(5000, 2500) == 1250
int applyBps(int minor, int bps);
```

Phase 17 audit grep: any `.toDouble()` on a money column or any inline `* 100`
outside `lib/core/utils/money.dart` is a regression.

### LD-8 — Basis-point ratios for deposit + platform fee

`payment_config.dart`:

```dart
// Before:
final double depositFraction;       // 0.30
final double platformFeeFraction;   // unused; we use _kPlatformFee = 2.0 in cedis

// After:
final int depositBps;               // 3000
final int platformFeeMinor;         // 200 (a hardcoded constant, kobo)
```

Math in `booking_creation_controller.dart`:

```dart
final depositMinor = applyBps(totalMinor, _config.depositBps);
final platformFeeMinor = _config.platformFeeMinor;
```

Result: deposit and platform-fee math are **exact integers**. No `* 0.30`
rounding drift across multi-service bookings.

### LD-9 — Boundary conversion at every NUMERIC ↔ Dart hop

Every repository method that returns money from PostgREST applies
`parseMoneyMinor(row['column'] as num)` at the point of unmarshalling. Direct
`(... as num).toDouble()` on a money column is forbidden.

Scope: every method on `SupabaseBookingRepository`, `SupabaseDashboardRepository`,
`PromotionsRepository`, `WalletRepository`, and any future repo that reads
money from PostgREST.

### LD-10 — Promo path round-trip

`PromoValidation` carries int kobo. `AppliedPromo.amountOff` and
`AppliedPromo.newTotal` are int kobo. The `validate_and_apply_promo` RPC return
is boundary-converted in `promotions_repository.dart`.

The screen uses `_appliedPromo?.newTotalMinor ?? totalPriceMinor` and sends
that as `totalAmountMinor` on the wire.

### LD-11 — Display layer uses `formatMoney` exclusively

Every widget that renders money uses `formatMoney(minor, currency)`. The Phase 16
display sites that built strings like `'$currency ${(major / 100).toStringAsFixed(2)}'`
collapse to `formatMoney(...)`. Phase 17 audit grep: any `toStringAsFixed(2)`
on a money value outside `lib/core/utils/money.dart` is a regression.

### LD-12 — Server-side epsilon validation tightens to exact

`create-booking/index.ts` lines 619 + 684 currently validate price match with
a `> 0.01` tolerance to absorb float dust. With int kobo end-to-end the
tolerance is zero — mismatch is exact.

```ts
// Before:
if (Math.abs(slot.price - service.priceAtBooking) > 0.01) {

// After:
if (slotPriceMinor !== service.priceAtBookingMinor) {
```

This is a security/correctness upgrade: a tampered client can no longer slip a
1-pesewa discrepancy through the validator.

### LD-13 — Wallet surfaces included in scope

`WalletTransactionModel` money fields, `request_withdrawal` RPC return, wallet
history display all flip to int kobo. Wallet is unambiguously [FIN]. Phase 17
does not extend the wallet surface (no new features); it just retypes.

### LD-14 — Analytics + dashboard repository included in scope

`AnalyticsScreen` (Phase 10) reads `bookings.total_amount` for the revenue
metric. Every `(... ?? 0).toDouble()` on a money column in
`supabase_dashboard_repository.dart` is boundary-converted to
`parseMoneyMinor(...)`. The display layer uses `formatMoney(...)`.

### LD-15 — Tests migrated, new invariants added

Existing tests using `price: 50, basePrice: 40` etc. migrate to
`priceMinor: 5000, basePriceMinor: 4000`. Assertions for rendered text update
to the new `formatMoney` format (same `'GHS 50.00'` string; just sourced from
int now).

New test files:
- `test/money/money_math_test.dart` — invariants for `formatMoney`,
  `parseMoneyMinor`, `applyBps` (including the 0.1 + 0.2 == 0.3 semantic test).
- `test/payment/payment_controller_money_test.dart` — wire-format assertion
  that the encoded JSON request body contains `totalAmountMinor: 5000` (int),
  never `totalAmount: 50.0` (float).
- `test/booking/booking_creation_controller_money_test.dart` — `applyBps`
  invariant: 100 × `priceMinor: 1234` folded == `123400` exactly.

### LD-16 — No new SQL migrations

Storage is unchanged. Server-side RPCs are unchanged. The smoke test file in
Wave 6 verifies that the existing RPCs still return values that round-trip
correctly through the new boundary conversion — no DDL.

## Out of scope

- **Schema changes.** `NUMERIC(12,2)` storage stays.
- **Per-shop config for deposit + platform fee.** Stays hardcoded constants
  (`depositBps = 3000`, `platformFeeMinor = 200`). Per-shop config remains
  backlog.
- **Zero-decimal currencies** (JPY, KRW). Universal `minor = major × 100`
  assumption holds for GHS, NGN, USD, EUR. Adding JPY would require a per-
  currency decimal-places lookup in `formatMoney`; deferred.
- **Three-decimal currencies** (KWD, BHD). Same justification as above.
- **Provider SDK rewrites.** Paystack + Stripe SDKs accept int kobo today; we
  just remove the redundant `* 100` inside the adapter.
- **Removing the legacy float branch on the edge function.** Stays one
  release cycle for safety. Wave 8 (backlog) removes after verification.
- **Recomputing existing `pending_payments` records.** Pre-Phase-17 records
  stay as float JSON forever; the edge function legacy branch handles them
  through the verify-payment flow.

## Success criteria

1. **SC-1** — `grep -rn 'double.*[Pp]rice\|double.*[Aa]mount\|double.*[Tt]otal\|double.*[Dd]eposit\|double.*[Pp]latform[Ff]ee' lib/presentation/features/shops/booking/ lib/payment/ lib/wallet/` returns ZERO results post-Phase-17 (excluding `_test.dart` files which migrate too).
2. **SC-2** — `grep -rn '\.toDouble()' lib/presentation/features/shops/booking/ lib/payment/ lib/wallet/` returns ZERO money-column hits (lat/long/rating allowed).
3. **SC-3** — `grep -rn 'toStringAsFixed(2)' lib/ | grep -v 'lib/core/utils/money.dart' | grep -v _test.dart` returns ZERO money-formatting hits.
4. **SC-4** — `formatMoney(0, 'GHS') == 'GHS 0.00'`.
5. **SC-5** — `formatMoney(5000, 'GHS') == 'GHS 50.00'`.
6. **SC-6** — `formatMoney(125000, 'GHS') == 'GHS 1,250.00'`.
7. **SC-7** — `formatMoney(-5000, 'GHS') == '-GHS 50.00'`.
8. **SC-8** — `parseMoneyMinor(50.00) == 5000`.
9. **SC-9** — `parseMoneyMinor(50.005) == 5001` (rounds half-away-from-zero per Postgres NUMERIC).
10. **SC-10** — `applyBps(5000, 3000) == 1500`.
11. **SC-11** — Fold-many invariant: a list of 100 `priceMinor: 1234` items folds to `123400` exactly.
12. **SC-12** — IEEE invariant test: a known-bad float sequence (`0.1 + 0.2`) demonstrably fails the float path AND demonstrably passes the int-kobo path.
13. **SC-13** — Encoded `payment_controller.processPayment` JSON request body contains `totalAmountMinor: 5000` as a JSON integer (no `.0`, no string).
14. **SC-14** — Edge function `sanitizeAmountMinor` rejects `50.5` with the documented error message.
15. **SC-15** — Edge function `create-booking` accepts both legacy + new request body shapes; both normalize to the same int kobo value internally.
16. **SC-16** — `paystack_provider.initiate` called with `amountMinor: 5000` sends `amount: 5000` to Paystack (NOT `amount: 500000`).
17. **SC-17** — `time_slot_chip` renders `'GHS 40.00'` from `priceMinor: 4000`.
18. **SC-18** — `BookingPriceBreakdown` widget receives + renders int kobo throughout.
19. **SC-19** — Promo flow round-trip: `ClientPromoCodeField` receives `bookingTotal: 9000`, applies a 10% promo, gets back `newTotalMinor: 8100`, sends `totalAmountMinor: 8100` to the edge function.
20. **SC-20** — `_kPlatformFeeMinor == 200` (kobo) and is sent verbatim through the wire as `platformFeeMinor: 200`.

## Algorithm Quality Checklist coverage

Phase 17 is a [FIN] hardening sweep. Coverage of the checklist's [FIN]-tagged
items:

- **2.19 (P0-U / [FIN]) — Money never stored or computed as floating point.**
  ✅ Storage was already NUMERIC; this phase removes float compute end-to-end.
- **2.20 (P0-U / [FIN][MUTATION]) — Provider idempotency keys reused across retries.**
  Already shipped in the F-P0-3 hardening sweep (5735c1d). Re-verified.
- **2.21 (P0-U / [FIN][ASYNC]) — Webhook handlers idempotent on event ID.**
  Phase 12/13 already enforce this. Re-verified.
- **2.22 (P1 / [FIN][MUTATION]) — Append-only audit log.**
  Phase 14 broadcasts + Phase 16 daily_report_runs cover this. Re-verified.
- **2.23 (P2 / [FIN][ASYNC]) — Periodic reconciliation.**
  Backlog — not Phase 17 scope.

Phase 17 brings the per-phase Secure dimension scores to:
- Phase 10: 7 → **9**
- Phase 13: 9 → **10**
- Phase 15: 7 → **10**

---

*Phase: 17-money-math-hardening*
*SPEC locked: 2026-06-12*
