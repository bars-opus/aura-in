# Phases 10–16 Quality Audit — v3.1

**Date:** 2026-06-12
**Scope:** Owner-facing surfaces from Tools tab + financial booking-flow paths (Phases 10–16)
**Checklist:** v3.1 (84 checks, applied per scope tag)
**Auditor verdict (overall):** **BLOCK** — 4 P0 findings on the booking-flow [FIN] surface plus one prod log-leak that affects the daily-report observability promise.

## Executive summary

The Phase 13–16 server work is mature: HINT-driven typed exceptions, SECURITY DEFINER discipline, owner-only RLS, append-only audit on `daily_report_runs`, idempotent ON CONFLICT mutations, and well-scoped REVOKEs. Phase 16 in particular is the cleanest of the batch.

The client side is where the audit fails. The booking-flow [FIN] path stores and computes money as `double` from `TimeSlotModel.price` all the way through `processPayment`, in direct violation of checklist 2.19 (P0-U). The owner-facing dashboard repository (`supabase_dashboard_repository.dart`) has the same problem layered on top of 15 `print(...)` statements that ship to release logs. Phase 13's promo redemption is correctly atomic but the booking-side controller's idempotency key composition omits cart content, so a retry after the user changes the cart will replay against the wrong booking shape. The Phase 16 cron's "failed" audit rows never commit because the EXCEPTION block's INSERT is rolled back when it re-RAISES — defeating the LD-7 observability promise.

P0 BLOCK count: **4**.

## Scoring summary (per phase × dimension)

| Phase | Secure | Robust | Scalable | Maintainable | Observable | User-aware | Overall |
|-------|--------|--------|----------|--------------|------------|------------|---------|
| 10    | 6/10   | 5/10   | 6/10     | 5/10         | 4/10       | 5/10       | 5/10 |
| 10.5  | 8/10   | 7/10   | 8/10     | 7/10         | 6/10       | 7/10       | 7/10 |
| 11    | 7/10   | 7/10   | 8/10     | 8/10         | 6/10       | 7/10       | 7/10 |
| 12    | 8/10   | 7/10   | 8/10     | 8/10         | 7/10       | 7/10       | 8/10 |
| 13    | 7/10   | 7/10   | 8/10     | 8/10         | 7/10       | 7/10       | 7/10 |
| 14    | 9/10   | 8/10   | 7/10     | 9/10         | 8/10       | 8/10       | 8/10 |
| 15    | 5/10   | 6/10   | 8/10     | 8/10         | 8/10       | 8/10       | 7/10 |
| 16    | 8/10   | 7/10   | 9/10     | 9/10         | 7/10       | 9/10       | 8/10 |

- **Phase 10** — Cancellation/no-show metric path lives in `supabase_dashboard_repository.getMetrics` which uses `print()` and `toDouble()` for money. Drags the whole score down.
- **Phase 10.5** — Backfill captures dashboard drift cleanly; deprecation of `increment_promotion_usage` is well documented.
- **Phase 11** — Atomic rebuild + archive RPCs are correct. HINT leak (`SHOP_NOT_FOUND` vs `NOT_SHOP_OWNER`) in `rebuild_shop_opening_hours` enumerates existence.
- **Phase 12** — Strong server posture; idempotent recovery_checkin enqueue; sanitized `not_found` for cross-shop.
- **Phase 13** — Atomic redeem_promotion is solid; `generate_loyalty_code` lacks a unique_violation handler so a concurrent fire on the same client can rollback the booking status flip.
- **Phase 14** — Best-engineered surface in the audit. Advisory lock + UTC daily cap + atomic fan-out. Audience CTE is recomputed twice (pre-check + insert) which is a minor scalability nit.
- **Phase 15** — Server is good; client is the worst money-math offender. `TimeSlotModel.price` and `_calculateTotalPrice` are `double` end-to-end.
- **Phase 16** — Best overall hygiene (typed exceptions, structured logs, owner-only RLS), but the EXCEPTION-block audit-insert rollback in `generate_daily_report` silently loses every cron-driven failure row.

## P0 findings (BLOCK — must fix before UAT)

### F-P0-1 — Booking-flow money is computed and transmitted as `double` end-to-end
- **Checklist:** 2.19 (P0-U) — [FIN]
- **Phase:** 15 (inherited from earlier phases, formalized in 15)
- **Where:**
  - [lib/presentation/features/shops/booking/data/models/time_slot_model.dart:35](lib/presentation/features/shops/booking/data/models/time_slot_model.dart#L35)
  - [lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart:307](lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart#L307)
  - [lib/presentation/features/shops/booking/presentation/controllers/booking_creation_controller.dart:127](lib/presentation/features/shops/booking/presentation/controllers/booking_creation_controller.dart#L127)
  - [lib/payment/presentation/controllers/payment_controller.dart:111](lib/payment/presentation/controllers/payment_controller.dart#L111)
- **Issue:** `TimeSlotModel.price` is `double`. `_calculateTotalPrice` folds doubles. `processPayment` accepts `double totalAmount, double depositAmount, double platformFee, double? promoAmountOff` and JSON-encodes them into the edge-function request body. This is the canonical money path; `$0.1 + $0.2 != $0.3` exactly. The server stores NUMERIC(12,2) at rest but the wire transit is binary float.
- **Evidence:**
```dart
// time_slot_model.dart:35
final double price;

// booking_confirmation_screen.dart:307-319
double _calculateTotalPrice(...) {
  return services.fold<double>(0, (sum, service) {
    final effective = timeSlots[service.id]?.price ?? service.price;
    return sum + effective * (quantities[service.id] ?? 1);
  });
}

// booking_creation_controller.dart:128
final depositAmount = totalAmount * _kDepositPercent;
```
- **Recommended fix:** Adopt minor-units (kobo) across the booking flow. Change `TimeSlotModel.price` to `int priceMinor`. Convert `_kDepositPercent` math to `(totalMinor * 30) ~/ 100`. Format `(major / 100).toStringAsFixed(2)` only at display sites (already done in `time_slot_chip.dart:146` — leave the display side alone). At the payment-controller boundary, send integers in JSON. Edge function already speaks kobo internally.
- **Effort:** L

### F-P0-2 — Dashboard repository fold all revenue/booking math as `double` and contains 15 `print()` calls
- **Checklist:** 2.19 (P0-U) and 4.4 (P0-U) — [FIN][ALL]
- **Phase:** 10 (metrics surface)
- **Where:** [lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart:116](lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart#L116) (and 22 other call sites identified via `grep toDouble`), plus `print(` at lines 186, 207, 298, 316, 338, 341, 551, 572, 620, 626, 660, 678, 698, 739, 742.
- **Issue:** Every revenue, deposit, and price column is parsed via `(x ?? 0).toDouble()`. The `print(...)` calls leak shop IDs, booking IDs, error messages, and counts to the platform console in release builds — `print()` is NOT release-stripped, only `debugPrint` is rate-limited.
- **Evidence:**
```dart
// supabase_dashboard_repository.dart:114-117
final todayRevenue = bookings.fold<double>(
  0,
  (sum, b) => sum + ((b['total_amount'] ?? 0).toDouble()),
);

// supabase_dashboard_repository.dart:186
print('🔍 getTodaySchedule - shopId: $shopId, date: $dateStr');
// :207
print('📋 Found ${bookings.length} bookings');
// :341
print('❌ Error in getTodaySchedule: $e');  // ← leaks PostgrestException internals
```
- **Recommended fix:**
  1. Replace every `(... ?? 0).toDouble()` on a money column with `(x ?? 0 as num).toInt()` after agreeing on a minor-unit convention. For server-side aggregation use a NUMERIC SUM and consume as int.
  2. Delete every `print()` call and route through `AppLogger.warn(...)` (already release-stripped + redacted). Example:
```dart
// Replace:
print('❌ Error in getTodaySchedule: $e');
// With:
AppLogger.warn('dashboard.today_schedule.error',
    fields: {'shop_id': shopId, 'error': e.toString()});
```
- **Effort:** M

### F-P0-3 — Booking-flow idempotency key omits cart content; retries with a changed cart replay against the old booking shape
- **Checklist:** 2.20 (P0-U) — [FIN][MUTATION]
- **Phase:** 13 (booking flow)
- **Where:** [lib/payment/presentation/controllers/payment_controller.dart:138](lib/payment/presentation/controllers/payment_controller.dart#L138)
- **Issue:** The idempotency key is `'${shopId}_${userId}_${startTime.millisecondsSinceEpoch}'`. If a user picks a time slot, taps Pay, the payment fails, they swap a service in the cart, and re-tap Pay at the same start_time — the edge function sees the same idempotency key and returns the original (now-stale) intent. Worse: a promo code changes after first attempt and the second attempt's `promotionId` / `promoAmountOff` are silently ignored.
- **Evidence:**
```dart
// payment_controller.dart:137-138
final idempotencyKey =
    '${shopId}_${userId}_${startTime.millisecondsSinceEpoch}';
```
- **Recommended fix:** Hash the cart payload into the key. The `BookingCreationController.build()` already generates a UUID per controller instance; reuse THAT key in the payment_controller too, and regenerate it via `controller.reset()` when the user explicitly edits the cart. Concrete:
```dart
// payment_controller.dart — replace line 137-138 with:
final cartFingerprint = sha256.convert(utf8.encode(
  jsonEncode([for (final s in services) [s['slotId'], s['workerId'], s['priceAtBooking']]])
)).toString().substring(0, 16);
final idempotencyKey =
    '${shopId}_${userId}_${startTime.millisecondsSinceEpoch}_$cartFingerprint';
```
- **Effort:** S

### F-P0-4 — `daily_report_runs` rows with `outcome='failed'` never commit when cron triggers them; LD-7 observability promise silently broken
- **Checklist:** 4.4 / 2.22 / 4.9 — [SERVICE][ASYNC]
- **Phase:** 16
- **Where:** [supabase/migrations/20260611100600_generate_daily_report_rpc.sql:367](supabase/migrations/20260611100600_generate_daily_report_rpc.sql#L367)
- **Issue:** `generate_daily_report` traps `WHEN OTHERS` and INSERTs an audit row with `outcome='failed'`, then re-RAISEs to surface the HINT to the caller. In PL/pgSQL, an EXCEPTION block runs in a subtransaction; when the handler re-RAISEs, the entire subtransaction (including the audit INSERT) is rolled back. Caller `dispatch_daily_reports` catches the propagated exception and increments `v_error_count` in memory, but writes nothing to `daily_report_runs`. Result: cron failures leave zero forensic trace. LD-7 explicitly promised a "ran the tick, observed failure" audit row.
- **Evidence:**
```sql
-- generate_daily_report:367-394
EXCEPTION
  WHEN OTHERS THEN
    DECLARE ... BEGIN
      GET STACKED DIAGNOSTICS ...;
      INSERT INTO public.daily_report_runs (...) VALUES (..., 'failed', v_code);
      RAISE EXCEPTION 'report_failed'
        USING ERRCODE = v_sqlstate, HINT = v_code;  -- rolls back the INSERT
    END;
END;
```
- **Recommended fix:** Use Postgres autonomous-transaction-style trick via `dblink_exec` or split the audit insert into a separate function called from a `BEGIN ... EXCEPTION` that does NOT re-raise but instead records the error and returns a sentinel. Simplest patch: replace the EXCEPTION block with a non-trapping flow — wrap the body in a savepoint that the caller manages. Concrete option: have `dispatch_daily_reports` write the failed audit row in ITS WHEN OTHERS handler (which is NOT re-raising, so its INSERT survives):
```sql
-- dispatch_daily_reports:54-65 — replace BEGIN..EXCEPTION with:
BEGIN
  PERFORM public.generate_daily_report(v_row.shop_id, v_row.report_date);
  v_shop_count := v_shop_count + 1;
EXCEPTION
  WHEN OTHERS THEN
    v_error_count := v_error_count + 1;
    DECLARE v_hint TEXT; v_state TEXT;
    BEGIN
      GET STACKED DIAGNOSTICS v_hint = PG_EXCEPTION_HINT, v_state = RETURNED_SQLSTATE;
      INSERT INTO public.daily_report_runs (
        shop_id, report_date, triggered_by, outcome, error_code
      ) VALUES (
        v_row.shop_id, v_row.report_date, 'cron', 'failed',
        COALESCE(NULLIF(v_hint, ''), 'REPORT_RPC_FAILED')
      );
    END;
END;
```
  Then remove the audit INSERT from `generate_daily_report`'s exception block (just RAISE).
- **Effort:** S

## P1 findings (FLAG — fix before UAT)

### F-P1-1 — `rebuild_shop_opening_hours` leaks shop existence to non-owners via separate HINT codes
- **Checklist:** 2.4 (P0-U) — [SERVICE]
- **Phase:** 11
- **Where:** [supabase/migrations/20260605120000_rebuild_hours_time_cast_fix.sql:42-49](supabase/migrations/20260605120000_rebuild_hours_time_cast_fix.sql#L42)
- **Issue:** Two separate raises: `SHOP_NOT_FOUND` when the row is absent vs `NOT_SHOP_OWNER` when it exists but the caller doesn't own it. A probing caller can enumerate which shop UUIDs exist. Other Phase 11 RPCs use a single sanitized `not_found` for both cases.
- **Evidence:**
```sql
IF v_owner IS NULL THEN
  RAISE EXCEPTION 'shop_not_found' USING ERRCODE = '42501', HINT = 'SHOP_NOT_FOUND';
END IF;
IF v_owner <> auth.uid() THEN
  RAISE EXCEPTION 'not_shop_owner' USING ERRCODE = '42501', HINT = 'NOT_SHOP_OWNER';
END IF;
```
- **Recommended fix:** Collapse to one raise with a single sanitized HINT, mirroring `upsert_loyalty_rule`:
```sql
IF v_owner IS NULL OR v_owner <> auth.uid() THEN
  RAISE EXCEPTION 'not_found' USING ERRCODE = '42501', HINT = 'NOT_SHOP_OWNER';
END IF;
```
- **Effort:** S

### F-P1-2 — `generate_loyalty_code` has no `unique_violation` handler; concurrent triggers can roll back the booking status flip
- **Checklist:** 1.6 / 2.16 — [ASYNC][MUTATION]
- **Phase:** 13
- **Where:** [supabase/migrations/20260606000500_generate_loyalty_code_helper.sql:67-76](supabase/migrations/20260606000500_generate_loyalty_code_helper.sql#L67)
- **Issue:** The `NOT EXISTS` check for existing unredeemed loyalty codes is non-atomic with the INSERT. The partial UNIQUE index `promotions_silent_target_uniq (shop_id, COALESCE(target_user_id, target_guest_profile_id), source) WHERE source IN ('loyalty','recovery')` will fire `unique_violation` on a race. There is no `EXCEPTION WHEN unique_violation` block, so the violation propagates up through the trigger and rolls back the `mark_booking_complete` UPDATE that fired the trigger.
- **Evidence:**
```sql
-- generate_loyalty_code:46-76 — no exception handler around the INSERT
SELECT code INTO v_existing FROM public.promotions WHERE ...;  -- non-atomic check
IF FOUND THEN RETURN v_existing; END IF;
v_new_code := upper('LOYAL' || ...);
INSERT INTO public.promotions (...) VALUES (...);  -- can raise unique_violation
```
- **Recommended fix:** Wrap the INSERT in `BEGIN ... EXCEPTION WHEN unique_violation THEN ... END;` and on violation re-read the existing code:
```sql
BEGIN
  INSERT INTO public.promotions (...) VALUES (...);
EXCEPTION WHEN unique_violation THEN
  SELECT code INTO v_new_code FROM public.promotions
  WHERE shop_id = p_shop_id AND source = 'loyalty'
    AND COALESCE(target_user_id, target_guest_profile_id)
        = COALESCE(p_user_id, p_guest_profile_id)
    AND archived_at IS NULL
  ORDER BY created_at DESC LIMIT 1;
END;
```
- **Effort:** S

### F-P1-3 — `cancel_booking` / `mark_booking_complete` / `mark_booking_no_show` leak booking existence via P0002 error text before authz
- **Checklist:** 2.4 (P0-U) — [SERVICE]
- **Phase:** 12 (pattern existed prior, re-touched in Phase 12 wiring)
- **Where:** [supabase/migrations/20260605130700_wire_terminal_rpcs.sql:41](supabase/migrations/20260605130700_wire_terminal_rpcs.sql#L41)
- **Issue:** All three terminal RPCs do `SELECT ... FROM bookings WHERE id = p_booking_id` then check ownership. The NOT FOUND branch raises `'booking % not found', p_booking_id` BEFORE the ownership check, leaking the UUID and the existence of the booking. A non-owner probing UUIDs gets `P0002 'booking <UUID> not found'` for missing rows and `42501 'unauthorized'` for existing-but-not-owned rows — enumeration.
- **Evidence:**
```sql
SELECT * INTO v_booking FROM bookings WHERE id = p_booking_id FOR UPDATE;
IF NOT FOUND THEN
  RAISE EXCEPTION 'booking % not found', p_booking_id USING ERRCODE = 'P0002';
END IF;
-- ownership check happens AFTER, with a different error code
```
- **Recommended fix:** Either gate the SELECT with an ownership join (preferred), or sanitize both raises to the same generic `'not_found'` with no embedded UUID:
```sql
SELECT b.* INTO v_booking
FROM bookings b
LEFT JOIN shops s ON s.id = b.shop_id
WHERE b.id = p_booking_id
  AND (b.user_id = auth.uid() OR s.user_id = auth.uid())
FOR UPDATE;
IF NOT FOUND THEN
  RAISE EXCEPTION 'not_found' USING ERRCODE = '42501', HINT = 'BOOKING_NOT_FOUND';
END IF;
```
- **Effort:** M (3 RPCs)

### F-P1-4 — `payment_controller.processPayment` uses `debugPrint` to dump raw edge-function responses including error text
- **Checklist:** 4.4 (P0-U) / 5.5 — [UI][MOBILE]
- **Phase:** 13 (payment surface touched for promo)
- **Where:** [lib/payment/presentation/controllers/payment_controller.dart:170](lib/payment/presentation/controllers/payment_controller.dart#L170), :184, :199
- **Issue:** `debugPrint(...)` is NOT release-stripped — it's rate-limited but still emits. It prints `data` (the full edge-function response) and raw `err` text. Provider error messages can contain card identifiers, account fragments, or internal reference IDs.
- **Evidence:**
```dart
debugPrint('${_config.createIntentFunctionName} returned unexpected data: $data');
// :184
debugPrint('${_config.createIntentFunctionName} failed: $err');
// :199
debugPrint('${_config.createIntentFunctionName} missing reference or URL: $data');
```
- **Recommended fix:** Route through `AppLogger.warn` (release no-op, redacts):
```dart
AppLogger.warn('payment.create_intent.unexpected_response',
    fields: {'function': _config.createIntentFunctionName, 'shape': data.runtimeType.toString()});
```
- **Effort:** S

### F-P1-5 — `accepts_marketing` defaults to TRUE so all existing guests are opted in retroactively
- **Checklist:** 1.11 (P1) — [ALL]
- **Phase:** 14
- **Where:** [supabase/migrations/20260607000100_add_accepts_marketing_to_guest_profiles.sql:11](supabase/migrations/20260607000100_add_accepts_marketing_to_guest_profiles.sql#L11)
- **Issue:** `accepts_marketing BOOLEAN NOT NULL DEFAULT TRUE`. Every guest who ever booked is now eligible to receive WhatsApp marketing without explicit opt-in. Migration comment acknowledges "STOP-reply worker behavior is OUT of Phase 14 scope" but there is no in-app opt-in capture path either. Depending on jurisdiction (GDPR / WhatsApp marketing policy), this is a soft-compliance liability.
- **Evidence:**
```sql
ALTER TABLE public.guest_profiles
  ADD COLUMN IF NOT EXISTS accepts_marketing BOOLEAN NOT NULL DEFAULT TRUE;
```
- **Recommended fix:** Either (a) flip the default to FALSE and capture explicit opt-in at guest checkout, or (b) ship the STOP-reply opt-out worker before Phase 14 hits production marketing volume. Tag the decision in MEMORY.md.
- **Effort:** M

### F-P1-6 — `shops.timezone` validated only by length + no-spaces; cron-side `AT TIME ZONE` raises and aborts the whole tick on a bad value
- **Checklist:** 2.1 (P0-U) / 6.2 — [SERVICE][ASYNC]
- **Phase:** 16
- **Where:** [supabase/migrations/20260611100100_shops_timezone_column.sql:24](supabase/migrations/20260611100100_shops_timezone_column.sql#L24)
- **Issue:** The CHECK constraint only enforces `length(timezone) BETWEEN 3 AND 64 AND timezone !~ ' '`. A future owner-facing editor (deferred per spec) that writes `'NOT_A_ZONE'` will store fine. When `dispatch_daily_reports` evaluates `now() AT TIME ZONE sh.timezone` for THAT shop, Postgres raises `invalid_parameter_value`. There is NO inner BEGIN..EXCEPTION around the dispatcher's CTE, so the whole cron tick aborts — every other shop in the same tick is skipped.
- **Evidence:**
```sql
-- shops_timezone_column.sql:24
CHECK (length(timezone) BETWEEN 3 AND 64 AND timezone !~ ' ');
-- dispatch_daily_reports.sql:33-39 — no exception handling around CTE
SELECT ... (now() AT TIME ZONE sh.timezone)::time AS local_time ...
FROM shop_local sl WHERE sl.local_time BETWEEN ...
```
- **Recommended fix:** Tighten the CHECK to validate against `pg_timezone_names`:
```sql
ALTER TABLE public.shops DROP CONSTRAINT shops_timezone_iana_shape;
ALTER TABLE public.shops ADD CONSTRAINT shops_timezone_iana_valid
  CHECK (timezone IN (SELECT name FROM pg_timezone_names));
```
(`pg_timezone_names` is a view, can't be referenced in a CHECK directly — use a trigger or a domain. Practical alternative: wrap the dispatcher CTE in a per-row TRY/CATCH via a helper function.)
- **Effort:** M

## P2 findings (FLAG — fix this week, may slip to next)

### F-P2-1 — `send_broadcast` recomputes the audience CTE twice (pre-check + insert); read-after-write race possible
- **Checklist:** 1.6 / 3.2 — [SERVICE]
- **Phase:** 14
- **Where:** [supabase/migrations/20260607000400_send_broadcast_rpc.sql:138-176](supabase/migrations/20260607000400_send_broadcast_rpc.sql#L138)
- **Issue:** Audience size pre-check at step 10a is a separate CTE from the fan-out INSERT at 10b. Between them, a new booking can land that pushes the actual fan-out count past 1000 (the cap raise won't fire). Advisory lock + UTC-day cap cover most race surface, but the gap exists.
- **Fix:** Compute the audience CTE once into a temp table, count from it, then INSERT...SELECT from the same temp table. Or wrap the whole audience query in a CTE and reference it twice in a single statement.

### F-P2-2 — `AppLogger.warn(... fields: {'error': e.toString()})` does not redact PostgrestException message
- **Checklist:** 4.4 (P0-U) — [ALL]
- **Phase:** all Dart phases
- **Where:** [lib/core/utils/logging/app_logger.dart:69-84](lib/core/utils/logging/app_logger.dart#L69), called from dozens of sites including the dashboard repo daily-report / pricing-override / business-hours classifiers.
- **Issue:** `_redactValue` only inspects the KEY (looks for `email`, `phone`, `token`, etc). A key named `error` carries `e.toString()` verbatim. The PostgrestException's `message` field often embeds column names, partial UUIDs, and provider error text. Since `AppLogger` is release-no-op the prod exposure is zero, but staging logs leak.
- **Fix:** Add a pass-through: any value containing `@`, `Bearer `, `sk_`, etc. routes through `_redactFreeform`. Or whitelist allowed keys.

### F-P2-3 — `redeem_promotion` (widened 5-arg version) lost the `usage_limit` check that the original 4-arg version enforced
- **Checklist:** 1.10 / 2.18 — [FIN][MUTATION]
- **Phase:** 13
- **Where:** [supabase/migrations/20260606000200_widen_redeem_promotion_for_guests.sql:42-67](supabase/migrations/20260606000200_widen_redeem_promotion_for_guests.sql#L42)
- **Issue:** The 4-arg version did `FOR UPDATE` + `usage_count >= usage_limit` raise before inserting. The 5-arg version just inserts and bumps the counter. If `validate_and_apply_promo` is bypassed (webhook calls `redeem_promotion` directly), there's no usage-cap enforcement at the redemption step.
- **Fix:** Restore the FOR UPDATE + usage_limit check inside the 5-arg version, or document that the caller is responsible (and verify all callers).

### F-P2-4 — `print()` + `toDouble()` in `client_promo_code_field` and related booking widgets
- **Checklist:** 2.19 / 4.4 — [FIN][UI]
- **Phase:** 13
- **Where:** Many call sites in `lib/presentation/features/shops/booking/presentation/widgets/`. Sampled at top of `booking_confirmation_screen` confirmed. Audit did not exhaustively sweep widget tree — high probability of additional double-money sites.
- **Fix:** Same as F-P0-1: minor-units across the booking flow client side.

### F-P2-5 — `validate_and_apply_promo` uses ERRCODE `42501` for "code not found" (semantic mismatch with insufficient_privilege)
- **Checklist:** 5.1 — [SERVICE]
- **Phase:** 13
- **Where:** [supabase/migrations/20260606000300_validate_and_apply_promo_rpc.sql:103](supabase/migrations/20260606000300_validate_and_apply_promo_rpc.sql#L103)
- **Issue:** `RAISE EXCEPTION 'not_found' USING ERRCODE = '42501', HINT = 'CODE_NOT_FOUND'`. `42501` is `insufficient_privilege`. Used here deliberately to look authz-like (don't leak existence) — but it conflates business-not-found with authz failures and confuses downstream alert routing. Other RPCs use the same pattern; pick one and document.
- **Fix:** Document the convention in CLAUDE.md or move not-found business cases to `P0002 no_data_found` and reserve `42501` for actual authz.

### F-P2-6 — `ToolsScreen` renders 8 cards in a fixed-height `ListView(physics: NeverScrollable)` sized for 6
- **Checklist:** 5.2 / 5.6 — [UI][MOBILE]
- **Phase:** 10.5 / 13 / 14 added new cards
- **Where:** [lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart:96-99](lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart#L96)
- **Issue:** `SizedBox(height: 6 * 70, child: ListView.builder(physics: NeverScrollable, itemCount: 8, ...))`. On small phones the loyalty (case 6) and broadcasts (case 7) cards clip below the visible area and are unreachable.
- **Fix:** Either bump the SizedBox height to `8 * 70.h` or remove the SizedBox and let the outer ListView scroll naturally.

### F-P2-7 — `CreatePromotionScreen._save` surfaces raw `e.toString()` in a SnackBar
- **Checklist:** 5.5 (P0-U) — [UI]
- **Phase:** 13
- **Where:** [lib/presentation/features/shops/dashboard/presentation/screens/create_promotion_screen.dart:151](lib/presentation/features/shops/dashboard/presentation/screens/create_promotion_screen.dart#L151)
- **Issue:** `SnackBar(content: Text('Error: $e'))` shows whatever `e.toString()` returns. PostgrestException toString includes message + code + hint + details — visible to the owner.
- **Fix:** Switch to typed `PromotionException.userMessage` like `pricing_override_form_screen.dart` does. Replace with a generic copy + log the original via `AppLogger.warn`.

### F-P2-8 — `booking_confirmation_screen._showError` displays `e.toString()` directly to the client
- **Checklist:** 5.5 (P0-U) — [UI]
- **Phase:** 13 / 15 (untouched but on scope)
- **Where:** [lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart:401](lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart#L401)
- **Issue:** `_showError(e.toString())` in the catch-all. Client-side users see raw exception strings.
- **Fix:** Generic copy + structured log.

### F-P2-9 — `broadcasts` table has no schema-level REVOKE on UPDATE/DELETE — relies on RLS-policy absence
- **Checklist:** 2.22 (P1 [FIN]) — [MUTATION]
- **Phase:** 14
- **Where:** [supabase/migrations/20260607000200_broadcasts_table.sql:37-52](supabase/migrations/20260607000200_broadcasts_table.sql#L37)
- **Issue:** Mirrors `daily_report_runs` but skips the `REVOKE UPDATE, DELETE FROM service_role` belt-and-braces. service_role still has full mutability — a misconfigured edge function can corrupt history.
- **Fix:** Mirror `daily_report_runs:48-51`:
```sql
REVOKE UPDATE, DELETE ON public.broadcasts FROM PUBLIC;
REVOKE UPDATE, DELETE ON public.broadcasts FROM authenticated;
REVOKE UPDATE, DELETE ON public.broadcasts FROM service_role;
REVOKE UPDATE, DELETE ON public.broadcasts FROM anon;
```

### F-P2-10 — `pricingOverridesProvider` is not autoDispose; cache lingers across screen disposal
- **Checklist:** 2.14 — [MOBILE]
- **Phase:** 15
- **Where:** [lib/presentation/features/shops/dashboard/providers/pricing_overrides_provider.dart:11](lib/presentation/features/shops/dashboard/providers/pricing_overrides_provider.dart#L11)
- **Issue:** Stale override data after archive + back navigation.
- **Fix:** Add `.autoDispose`.

### F-P2-11 — `list_daily_reports` reuses `REPORT_DATE_INVALID` HINT for a NULL `p_shop_id` error
- **Checklist:** 5.1 — [SERVICE]
- **Phase:** 16
- **Where:** [supabase/migrations/20260611100800_list_daily_reports_rpc.sql:26-29](supabase/migrations/20260611100800_list_daily_reports_rpc.sql#L26)
- **Issue:** HINT semantics break — Dart classifier sees REPORT_DATE_INVALID and shows "That date is out of range" for a NULL shopId payload.
- **Fix:** Use a distinct HINT `SHOP_ID_NULL` or `REQUIRED_FIELD_MISSING`.

## P3 findings (nice-to-have wins)

- `tools_screen.dart` has no entry point for `DailyReportScreen` / `DailyReportHistoryScreen`. Phase 16 only reachable via deep-link.
- `_kDepositPercent = 0.30` and `_kPlatformFee = 2.0` are hardcoded magic numbers in `booking_creation_controller.dart`. Move to per-shop config or named config keys.
- Comment block at top of `tools_screen.dart` says "Six cards" but renders eight — drift.
- `daily_report_screen.dart` does not show `generated_at` to the owner; trust signal missing.
- `generate_loyalty_code` uses 6 hex chars (`~30 bits`) for the code suffix; format collisions theoretically possible across multiple shops. Per-shop UNIQUE saves you, but increase to 8 chars for ergonomic cleanliness.
- `broadcasts_provider.dart` not autoDispose; same concern as F-P2-10.
- `send_broadcast` audience CTE never filters out the owner themselves — if the owner has a guest_profile under their own shop, they get their own broadcast.
- `cancel_and_followup` only handles `unique_violation`; other transient errors (deadlock, etc.) propagate and roll back the terminal status.

## Phase-by-phase commentary

**Phase 10 — cancellation/no-show metric.** Backed by `supabase_dashboard_repository.getMetrics`, which is the floating-point + print-leak hotspot. The metric itself is correct; the surface is the worst owner-facing code in the audit. Posture: fix-before-UAT.

**Phase 10.5 — tools cleanup.** Backfill migration is the right approach for the dashboard-drift problem. `increment_promotion_usage` deprecation-as-noop is graceful. Strength.

**Phase 11 — business hours + services.** Atomic DELETE+INSERT rebuild is well-thought through; the time-cast fix (20260605120000) cleanly recovered from a column-type mismatch. The `SHOP_NOT_FOUND` HINT leak is the only real flaw. Otherwise solid.

**Phase 12 — retention engine.** Strong server discipline. `cancel_and_followup`'s narrow `unique_violation` swallow is the right pattern. Triggers don't overlap. `client_notes` uses the partial unique on COALESCE correctly. Strengths outweigh.

**Phase 13 — promo + loyalty.** `redeem_promotion` original 4-arg version is the gold standard (atomic counter + ledger + FOR UPDATE). The widened 5-arg version regressed on the usage_limit check. `generate_loyalty_code` lacks a unique_violation handler for the race. `validate_and_apply_promo` is read-only and clean. Posture: server fixable; client booking-flow money math is the real concern.

**Phase 14 — broadcasts.** The reference implementation for the audit. Eleven discrete steps, advisory lock + UTC cap defense in depth, atomic fan-out via INSERT...SELECT. Only nits: audience CTE evaluated twice, accepts_marketing default-on, broadcasts table lacks schema-level REVOKE. Best phase.

**Phase 15 — pricing overrides.** Server is well-built (3-tier specificity ladder, ISODOW fix, base+effective dual emission). The client side regresses everything: `TimeSlotModel.price` as double propagates the bug throughout the booking flow. The form screen itself is well-coded (typed exceptions, structured logging). The pricing system is correct; the wire format violates 2.19.

**Phase 16 — daily close-out.** Cleanest engineering of the seven phases. Minor-unit math, NUMERIC × 100 → bigint kobo, typed exceptions, append-only audit. The cron-failure observability gap (F-P0-4) is a genuine PL/pgSQL subtlety that the spec didn't catch. Once that's fixed, this is 9/10 across the board.

## Skip justifications (N/A scope)

- **6.10 (24h soak), 6.11 (2x peak load test)** — Per Phase 15 SPEC LD-15, skipped at <100-shop scale.
- **6.12 (chaos test in staging), 4.3 (distributed trace context), 4.14 (dead letter queue), 3.11 (circuit breaker), 3.13 (bulkhead)** — Out of v1 scope for a single-region Supabase deployment; no service mesh.
- **7.6 (CSRF/CORS)** — N/A; native-mobile-only consumer.
- **6.5 (property-based tests), 6.8 (mutation testing)** — Out of v1 testing budget.
- **5.6 (WCAG 2.1 AA)** — Out of audit scope (visual audit needed); flagged owner-facing screens for follow-up.
- **8.1 Tier 1 canary** — Supabase Edge Functions deploy semantics; Tier 2 manual rollback runbook is the realistic posture.

## AUDIT COMPLETE
