# Payment / Wallet UX Polish — Design Spec

**Date:** 2026-05-21
**Status:** Approved — ready for implementation planning
**Scope:** Phase 3, item 3 of 4. Bundles three small Flutter UX improvements that surface the backend capabilities shipped in Phase 3.1 (PaymentProviderPort) and Phase 3.2 (withdrawal retry queue).

---

## Problem

Three independent UX gaps in the payment/wallet flows:

1. **No retry path on payment failure.** When `PaymentWebView.onPaymentFailure` fires, the user lands on a dead-end error state with no UI to retry. The `PaymentConfig.paymentErrorBuilder` hook exists but isn't registered.
2. **Wallet transaction list loads everything at once.** `wallet_screen.dart` queries `wallet_transactions` without pagination. For shops with 1000+ transactions this lags the screen.
3. **`dead_letter` withdrawals invisible to shop owners.** Phase 3.2 introduced the `dead_letter` state with a notification row insert, but there's no persistent UI signal once the notification is dismissed. Money stuck in limbo with no in-app indicator.

## Goals

1. Category-aware payment failure screen with a "Try again" button bound to the same booking intent.
2. Cursor-paginated wallet transaction list (page size 20) with infinite-scroll.
3. Persistent amber banner on the wallet screen when any withdrawal is in `dead_letter` status — expandable to show details + a "Contact support" link.

## Non-Goals

- Admin/operator dashboard for the dead-letter queue.
- In-app dead-letter resolution flow (operator continues to use SQL per Phase 3.2 runbook).
- Push notification on dead-letter event (deferred until SMTP/push infra).
- Pagination of `withdrawal_requests` list (low volume).
- Supabase Realtime subscriptions (30s poll is enough for dead-letter; transactions don't need live updates).
- Localization of UI copy.

---

## Locked Decisions

| # | Decision | Rationale |
|---|---|---|
| 1 | Bundle all 3 features into one spec/plan/execute cycle | Single screen surface, shared patterns, ~300 LOC total — separate ceremony would dwarf the work |
| 2 | Cursor pagination on `created_at` with page size 20 | Stable under inserts (a new txn doesn't shift page boundaries). `wallet_transactions.created_at` is indexed. 20 ≈ one mobile screen. |
| 3 | Retry button via `paymentErrorBuilder` config hook | The hook was designed for this; lives inside the payment module, reusable for any embedding app |
| 4 | Dead-letter banner: amber, persistent, expandable in place | Money is real and unresolved — persistence matches stakes. Amber (not red) signals "needs attention" without alarm. Expansion beats route navigation for a 1–3 row affair. |

---

## Design

### File layout

**New files:**
- `lib/payment/presentation/screens/payment_failure_screen.dart` — widget rendered by `paymentErrorBuilder`.
- `lib/wallet/presentation/widgets/dead_letter_banner.dart` — amber banner with expansion.
- `lib/wallet/providers/wallet_transactions_provider.dart` — paginated `AsyncNotifier` (codegen).
- `lib/wallet/providers/dead_letter_withdrawals_provider.dart` — stream provider.

**Modified files:**
- `lib/main.dart` — register `paymentErrorBuilder` in `paymentConfigProvider` override.
- `lib/payment/presentation/controllers/payment_controller.dart` — add `retryLast()` method.
- `lib/wallet/data/repositories/wallet_repository.dart` — add `fetchTransactions(shopId, before, limit)` + `watchDeadLetterWithdrawals(shopId)`.
- `lib/wallet/data/repositories/supabase/supabase_wallet_repository.dart` — implement both new repo methods.
- `lib/wallet/data/models/withdrawal_request_model.dart` — add `deadLetterReason` field (mirrors DB column from Phase 3.2).
- `lib/wallet/presentation/screens/wallet_screen.dart` — convert to ConsumerStatefulWidget, integrate banner + paginated list + ScrollController.

### Retry button — `payment_failure_screen.dart`

`Scaffold` with error icon, category-aware title/body, primary "Try again" button, secondary "Back to booking" link.

Category copy table (from `PaymentErrorCategory`):

| Category | Title | Body |
|---|---|---|
| `cancelled` | "Payment cancelled" | "You cancelled this payment before it completed. You can try again whenever you're ready." |
| `declined` | "Card declined" | "Your card was declined. Try a different card, or contact your bank to authorize the payment." |
| `network` | "Connection lost" | "We couldn't reach the payment provider. Check your connection and try again." |
| `validation` | "Payment couldn't be processed" | "There was a problem with the payment details. Please review and try again." |
| `serverError` | "Provider error" | "The payment provider returned an error. Please try again in a moment." |
| `unknown` | "Something went wrong" | "We weren't able to complete this payment. Please try again." |

For `cancelled`, the "Try again" button just pops back to the booking screen — the user explicitly cancelled, so we don't auto-restart. For all others, it pops the failure screen and calls `paymentController.retryLast()` which reissues the original `processPayment(...)` with the booking intent still held in controller state.

**Wiring in `main.dart`:**
```dart
paymentConfigProvider.overrideWithValue(
  PaymentConfig(
    appScheme: 'nanoembryo',
    brandName: 'NanoEmbryo',
    defaultCurrency: 'GHS',
    paymentErrorBuilder: (context, info) => PaymentFailureScreen(info: info),
  ),
),
```

**`PaymentController.retryLast()`:** the controller already holds the intent state during a payment cycle. Expose a public method that re-invokes `processPayment(...)` with the cached intent. If no intent is cached (edge case), the method no-ops and logs a warning.

### Pagination

**Repository signatures:**
```dart
Future<List<WalletTransaction>> fetchTransactions(
  String shopId, {
  DateTime? before,
  int limit = 20,
});

Stream<List<WithdrawalRequest>> watchDeadLetterWithdrawals(String shopId);
```

**Supabase implementation** (cursor `WHERE created_at < before ORDER BY created_at DESC LIMIT 20`).

**`WalletTransactionsPaginated` notifier:**
- `_pageSize = 20`
- `_hasMore: bool` (true until a page returns fewer than `_pageSize`)
- `_loading: bool` guard against concurrent `loadNext()` calls
- `build(shopId)` returns first page
- `loadNext()` appends next page, no-op when `!_hasMore` or `_loading`
- `refresh()` calls `ref.invalidateSelf()` and awaits the rebuild

**Screen integration:**
- Convert `WalletScreen` to `ConsumerStatefulWidget`
- Add `ScrollController` listener firing `loadNext()` at `maxScrollExtent - 200px`
- `ListView.separated(itemCount: txns.length + 1)` — last item is a `CircularProgressIndicator` while loading more, or `SizedBox.shrink()` when `!hasMore`
- Wrap in `RefreshIndicator` for pull-to-refresh

### Dead-letter banner

**Provider:** `deadLetterWithdrawalsProvider(shopId)` returns `Stream<List<WithdrawalRequest>>`. Repository implementation polls every 30s (sufficient for a low-frequency event; avoids Realtime subscription lifecycle).

**Widget contract:**
- Collapses to `SizedBox.shrink()` when the list is empty (no banner rendered).
- Compact state: `colorScheme.tertiaryContainer` background, `Icons.warning_amber_rounded`, title "Withdrawal needs review", subtitle with total amount + count, `expand_more` chevron.
- Expanded state: divider + one row per withdrawal showing amount, date (`YYYY-MM-DD`), short ID, and `dead_letter_reason` italic-styled, plus a "Contact support" `FilledButton.tonal` that opens `mailto:support@nanoembryo.app?subject=...&body=...`.

**No dismiss control.** Persistence is the feature.

**Placement in `wallet_screen.dart`:**
```dart
Column(
  children: [
    const WalletBalanceCard(),
    DeadLetterBanner(shopId: widget.shopId),
    Expanded(child: /* paginated ListView */),
  ],
)
```

### Model field addition

`WithdrawalRequest` entity gains:
- `deadLetterReason: String?` — surfaces in the banner expansion.

Other Phase 3.2 columns (`attemptCount`, `nextAttemptAt`, `lastError`) are not used by this UI and don't need to be lifted into the Flutter model.

### Dependency: `url_launcher`

The mailto link uses `url_launcher`. Verify it's already in `pubspec.yaml` during planning; if not, the plan adds it.

---

## Test plan

Flutter widget tests (no Deno surface this time):

- `payment_failure_screen_test.dart` — renders correct copy per `PaymentErrorCategory`; "Try again" button is hidden/visible per category logic; tap invokes `retryLast()` (mock controller).
- `wallet_transactions_paginated_test.dart` — first build returns page 1; `loadNext` appends page 2 once; `loadNext` no-ops when `hasMore=false`; `refresh` resets the cursor.
- `dead_letter_banner_test.dart` — empty stream → renders `SizedBox.shrink()`; non-empty stream → renders title + total; tap toggles expanded state; "Contact support" launches the mailto URL.

Integration smoke (manual, after deploy):
- Force a payment failure (e.g., bad Paystack key) → failure screen appears → "Try again" relaunches the WebView.
- Insert a synthetic `dead_letter` withdrawal via SQL → banner appears on wallet screen within 30s.
- Open a shop with >20 transactions → list loads first 20 → scroll to bottom → next 20 load.

---

## Out of scope

- Admin/operator dashboard for dead-letter queue (manual SQL via Phase 3.2 runbook).
- In-app dead-letter resolution flow.
- Push notification on dead-letter event.
- Pagination of `withdrawal_requests` list.
- Supabase Realtime subscriptions.
- Localization of UI copy.

## Risks

- **`paymentErrorBuilder` not currently invoked by `PaymentController`.** The hook exists in the config but the controller may not call it on failure. If true, the implementation also wires the call site. Verify during planning.
- **`PaymentController.retryLast()` requires cached intent.** If the controller cleared intent on first failure, retry would have nothing to use. Implementation must verify and, if cleared, restructure to retain the intent until the user explicitly cancels.
- **`url_launcher` not in pubspec.** Adds one dep if missing; trivial.
