# PaymentController Integration Tests — Design Spec

**Date:** 2026-05-21
**Status:** Approved — ready for implementation planning
**Scope:** Phase 3, item 4 of 4 (final). Adds Flutter integration tests for `PaymentController` to cover orchestration logic that currently has 0% test coverage.

---

## Problem

The `PaymentController.processPayment` orchestration — call `create-booking`, push WebView, poll the bookings table, fall back to `verify-payment`, fire success/failure hooks with the right `PaymentErrorCategory` — has no tests. The adapter unit tests (Phase 3.1) cover provider shape mapping, but the Flutter-side flow is untested. A regression here would mean a real payment flow breaks in user hands.

## Goals

1. Cover every branch in `processPayment` with at least one test (9 tests total).
2. Verify `onPaymentFailure` hook is called with the correct `PaymentErrorCategory` for each failure path.
3. Verify `onPaymentSuccess` hook is called for happy paths (DB poll + verify-payment fallback).
4. Verify `retryLast()` no-ops when no prior intent is cached.
5. Tests run locally with `flutter test test/payment/payment_controller_test.dart` — no CI required, no Deno required, no Supabase instance.

## Non-Goals

- True end-to-end testing against real Paystack/Stripe sandboxes or a live Supabase project.
- `integration_test/` device/emulator runs.
- CI / GitHub Actions configuration.
- Deno tests for `process-withdrawal`'s retry-queue catch-block branching (deferred to Phase 4 test-infra milestone).
- Golden-fixture contract tests for provider response shapes (already covered by Phase 3.1 adapter unit tests).
- Widget tests for `booking_confirmation_screen` or other UI surfaces.
- Tests for the polling retry behavior in `_confirmPayment` (covered implicitly by configuring `dbConfirmAttemptsAfterWebViewSuccess: 1`).

---

## Locked Decisions

| # | Decision | Rationale |
|---|---|---|
| 1 | Scope = Flutter `PaymentController` integration tests only | Best ROI given constraints (no CI, no Deno locally). Highest-value uncovered surface. |
| 2 | 8 scenario tests + 1 `retryLast` no-op test = 9 tests total | Covers every branch in `processPayment` exactly once; one bonus trivial test for the retry no-prior-intent path. |
| 3 | Inject `WebViewLauncher` typedef into `PaymentController` constructor with a default | Lets tests bypass `Navigator.push` cleanly. Tiny refactor (~15 LOC). Default behavior unchanged. |
| 4 | Mock at the `SupabaseClient` boundary using `mocktail` | mocktail is already in dev deps. Mocking the full `functions.invoke` and `from().select().eq().maybeSingle()` chains is verbose but isolates the controller cleanly. |

---

## Design

### `PaymentController` refactor

`lib/payment/presentation/controllers/payment_controller.dart` — add a typedef and an optional constructor parameter:

```dart
typedef WebViewLauncher = Future<bool> Function({
  required BuildContext context,
  required String authorizationUrl,
  required String reference,
  required String provider,
});

class PaymentController extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final SupabaseClient _supabase;
  final PaymentConfig _config;
  final WebViewLauncher _webViewLauncher;
  _PaymentIntent? _lastIntent;

  PaymentController(
    this._supabase,
    this._config, {
    WebViewLauncher? webViewLauncher,
  })  : _webViewLauncher = webViewLauncher ?? _defaultWebViewLauncher,
        super(const AsyncValue.data(null));

  static Future<bool> _defaultWebViewLauncher({
    required BuildContext context,
    required String authorizationUrl,
    required String reference,
    required String provider,
  }) async {
    final completer = Completer<bool>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentWebView(
          url: authorizationUrl,
          reference: reference,
          provider: provider,
          onComplete: (success) {
            if (!completer.isCompleted) completer.complete(success);
          },
        ),
      ),
    );
    return completer.future;
  }
  // ... rest unchanged ...
}
```

The existing `_showPaymentWebView` method becomes a thin delegating wrapper:

```dart
Future<bool> _showPaymentWebView({
  required BuildContext context,
  required String authorizationUrl,
  required String reference,
  required String provider,
}) {
  return _webViewLauncher(
    context: context,
    authorizationUrl: authorizationUrl,
    reference: reference,
    provider: provider,
  );
}
```

The `paymentControllerProvider` factory at the bottom of the file stays unchanged — production code never passes `webViewLauncher`, so the default applies.

### Test file structure

Single file: `test/payment/payment_controller_test.dart`.

**Mocks (mocktail):**
- `_MockSupabaseClient` for `SupabaseClient`
- `_MockFunctionsClient` for `client.functions`
- `_MockFunctionResponse` for return values of `functions.invoke(...)`
- `_MockSupabaseQueryBuilder` for `client.from('bookings')`
- `_MockPostgrestFilterBuilder<dynamic>` for the chained `.select().eq().maybeSingle()` calls

**Helpers (private to the test file):**
- `_testConfig(...)` — builds a `PaymentConfig` with short polling cadence (`dbConfirmAttemptsAfterWebViewSuccess: 1`, `dbConfirmInterval: 1ms`) and optional `onSuccess` / `onFailure` hooks
- `_stubCreateBooking(client, functions, {body, throws})` — wires `client.functions.invoke('create-booking', body: any)` to return either a stubbed response or throw
- `_stubBookingsPoll(client, {returns})` — wires the `from('bookings').select().eq().maybeSingle()` chain to return either a row or null
- `_materializeContext(tester)` — pumps a minimal `MaterialApp` to capture a real `BuildContext`

**Fallback registration (one-time, in `setUpAll`):**
```dart
registerFallbackValue(<String, dynamic>{});
```

### The 9 tests

| # | Test | Stubs | Assertions |
|---|---|---|---|
| 1 | happy path — DB poll returns booking | create-booking ok; WebView returns true; bookings poll returns row | result non-null; `onSuccess` fired with correct reference + amount |
| 2 | happy path via verify-payment fallback | create-booking ok; WebView returns true; bookings poll returns null; verify-payment returns `{success: true, booking: {...}}` | result non-null; `onSuccess` fired |
| 3 | create-booking returns `success=false` with 'invalid' in error | body `{success: false, error: 'invalid input'}` | result null; `onFailure` fired with `validation` |
| 4 | create-booking returns null body | body `null` | result null; `onFailure` fired with `serverError` |
| 5 | create-booking missing `reference` | body `{success: true, authorizationUrl: 'x'}` (no reference) | result null; `onFailure` fired with `serverError` |
| 6 | WebView dismissed + verify-payment fails | `webViewLauncher: () => false`; bookings poll null; verify-payment returns `{success: false}` | result null; `onFailure` fired with `cancelled` |
| 7 | WebView success but DB + verify both timeout | `webViewLauncher: () => true`; bookings poll null; verify-payment returns `{success: false}` | result null; `onFailure` fired with `network` |
| 8 | exception thrown in catch block | `_stubCreateBooking(..., throws: Exception('boom'))` | result null; `onFailure` fired with `unknown`; state is `AsyncValue.error` |
| 9 | retryLast no-op when no prior intent | construct controller, call `retryLast(ctx)` without prior `processPayment` | result null |

### Polling cadence in tests

`PaymentConfig.dbConfirmAttemptsAfterWebViewSuccess: 1` and `dbConfirmAttemptsAfterWebViewCancel: 1` make the polling loop execute exactly once. `dbConfirmInterval: const Duration(milliseconds: 1)` removes any meaningful wait. Each test completes in well under a second.

---

## Out of scope

- True end-to-end tests against Paystack/Stripe sandbox.
- `integration_test/` device runs.
- CI configuration.
- Deno tests for process-withdrawal catch-block branching (deferred to a Phase 4 test infra milestone alongside CI setup).
- Widget tests for booking_confirmation_screen.
- Tests for `_classifyServerError` heuristics in isolation (implicitly covered by tests 3 and 7).

## Risks

- **mocktail chains are verbose.** Each test's mock setup is ~10 lines. The helper functions amortize this but a future change to the controller's Supabase access pattern (e.g., adding a `.order()` to the bookings query) would require updating every stub. *Mitigation:* the helper functions centralize the chain stubbing so a change updates one place.
- **`PaymentConfig` constructor signature drift.** The tests construct `PaymentConfig` directly with several fields. If new required fields are added to `PaymentConfig`, the tests break. *Mitigation:* keep `PaymentConfig` constructor params optional with sensible defaults (already the pattern per Phase 3.1's design).
- **The `WebViewLauncher` typedef is a public API surface change.** Any consumer of `PaymentController` constructor that uses positional args will not break (it's a named optional parameter), but a consumer that imports the typedef name would. *Mitigation:* the typedef is opt-in for tests; nothing in production code imports it.
