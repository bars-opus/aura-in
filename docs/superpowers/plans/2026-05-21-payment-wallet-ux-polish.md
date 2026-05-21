# Payment / Wallet UX Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Three Flutter UX wins surfacing Phase 3.1/3.2 backend capabilities — category-aware payment failure screen with retry, cursor-paginated wallet transactions, and a persistent amber banner for `dead_letter` withdrawals.

**Architecture:** All Flutter. PaymentController gains intent caching + navigation to a new `PaymentFailureScreen` via the existing `paymentErrorBuilder` config hook. Wallet screen gains a `ScrollController`-driven paginated list (cursor on `created_at`) and a stream-backed dead-letter banner that polls every 30s.

**Tech Stack:** Flutter, Riverpod 2 + codegen, supabase_flutter, url_launcher (already in pubspec).

---

## File Structure

**New files:**
- `lib/payment/presentation/screens/payment_failure_screen.dart` — widget rendered by `paymentErrorBuilder`
- `lib/wallet/presentation/widgets/dead_letter_banner.dart` — amber persistent banner
- `lib/wallet/providers/wallet_transactions_paginated_provider.dart` — paginated `AsyncNotifier`
- `lib/wallet/providers/dead_letter_withdrawals_provider.dart` — stream provider
- `test/payment/payment_failure_screen_test.dart` — widget tests
- `test/wallet/wallet_transactions_paginated_test.dart` — unit tests
- `test/wallet/dead_letter_banner_test.dart` — widget tests

**Modified files:**
- `lib/main.dart` — register `paymentErrorBuilder`
- `lib/payment/presentation/controllers/payment_controller.dart` — add `_PaymentIntent` cache + `retryLast()` + navigation in `_fireFailure`
- `lib/wallet/data/repositories/wallet_repository.dart` — extend `getTransactions` with `before` cursor + add `watchDeadLetterWithdrawals`
- `lib/wallet/data/repositories/supabase/supabase_wallet_repository.dart` — implement both
- `lib/wallet/data/models/withdrawal_request_model.dart` — add `deadLetterReason` field
- `lib/wallet/presentation/screens/wallet_screen.dart` — swap to paginated provider, add banner, add scroll listener

---

## Caveats baked into this plan

- **Two spec risks now confirmed by code reading**:
  - `PaymentController` does NOT currently invoke `paymentErrorBuilder` — Task 1 wires it.
  - `PaymentController` does NOT cache intent for retry — Task 1 adds an `_PaymentIntent` cache.
- **`getTransactions` already has `offset`/`fromDate` parameters.** Rather than introduce a parallel `fetchTransactions` method (as the spec suggested), Task 3 *extends* the existing method with an optional `before: DateTime?` cursor. This avoids a duplicate API and keeps consumers of the existing `offset` path working.
- **Spec said separate "WalletTransaction entity" — codebase only has `WalletTransactionModel`.** Plan uses `WalletTransactionModel` throughout.
- **Codegen step required after editing `@riverpod` files**: `dart run build_runner build --delete-conflicting-outputs`. Run after Tasks 5.

---

# Task 1: PaymentController — intent caching + failure navigation

**Files:**
- Modify: `lib/payment/presentation/controllers/payment_controller.dart`

This task ships TWO coupled changes in one commit because they're useless apart:
1. Cache the last `processPayment` arguments in a private `_PaymentIntent` field so `retryLast()` has something to re-invoke.
2. After firing `_fireFailure`'s hook, also push the `paymentErrorBuilder` widget (if configured) so the user lands on a real retry screen instead of getting only an analytics callback.

- [ ] **Step 1: Read the controller** (already done during planning — file is `lib/payment/presentation/controllers/payment_controller.dart`, 310 lines).

- [ ] **Step 2: Add the `_PaymentIntent` immutable holder**

Insert this class definition at the top of the file, BEFORE the `PaymentController` class (after the imports):

```dart
/// Immutable snapshot of the args passed to [PaymentController.processPayment]
/// so [PaymentController.retryLast] can re-invoke it without the caller
/// having to remember the values.
class _PaymentIntent {
  const _PaymentIntent({
    required this.shopId,
    required this.userId,
    required this.userEmail,
    required this.services,
    required this.startTime,
    required this.endTime,
    required this.actualEndTime,
    required this.totalAmount,
    required this.depositAmount,
    required this.platformFee,
    required this.paymentProvider,
  });

  final String shopId;
  final String userId;
  final String userEmail;
  final List<Map<String, dynamic>> services;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime actualEndTime;
  final double totalAmount;
  final double depositAmount;
  final double platformFee;
  final String paymentProvider;
}
```

- [ ] **Step 3: Add the `_lastIntent` field and store it on entry to `processPayment`**

In the `PaymentController` class, add the field (with the other private fields, after `_config`):
```dart
  _PaymentIntent? _lastIntent;
```

Then in `processPayment`, BEFORE `state = const AsyncValue.loading();`, capture the intent:
```dart
    _lastIntent = _PaymentIntent(
      shopId: shopId,
      userId: userId,
      userEmail: userEmail,
      services: services,
      startTime: startTime,
      endTime: endTime,
      actualEndTime: actualEndTime,
      totalAmount: totalAmount,
      depositAmount: depositAmount,
      platformFee: platformFee,
      paymentProvider: paymentProvider,
    );
    state = const AsyncValue.loading();
```

- [ ] **Step 4: Add the public `retryLast` method**

Add this method to `PaymentController`, AFTER `processPayment` and BEFORE `_showPaymentWebView`:

```dart
  /// Re-invokes the last [processPayment] call with the same args.
  /// No-op if no intent is cached (e.g., user opened the failure screen
  /// after app restart).
  Future<Map<String, dynamic>?> retryLast(BuildContext context) async {
    final intent = _lastIntent;
    if (intent == null) {
      debugPrint('retryLast called with no cached intent');
      return null;
    }
    return processPayment(
      shopId: intent.shopId,
      userId: intent.userId,
      userEmail: intent.userEmail,
      services: intent.services,
      startTime: intent.startTime,
      endTime: intent.endTime,
      actualEndTime: intent.actualEndTime,
      totalAmount: intent.totalAmount,
      depositAmount: intent.depositAmount,
      platformFee: intent.platformFee,
      paymentProvider: intent.paymentProvider,
      context: context,
    );
  }
```

- [ ] **Step 5: Modify `_fireFailure` to navigate to `paymentErrorBuilder` if configured**

Replace the existing `_fireFailure` (around lines 282–300) with:

```dart
  Future<void> _fireFailure({
    String? reference,
    required String message,
    required PaymentErrorCategory category,
    BuildContext? context,
  }) async {
    final info = PaymentErrorInfo(
      reference: reference,
      message: message,
      category: category,
    );

    final hook = _config.onPaymentFailure;
    if (hook != null) {
      try {
        await hook(info);
      } catch (e) {
        debugPrint('onPaymentFailure hook threw: $e');
      }
    }

    final builder = _config.paymentErrorBuilder;
    if (builder != null && context != null && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (ctx) => builder(ctx, info)),
      );
    }
  }
```

The `context` parameter is OPTIONAL because the catch-all `catch (e, st)` block at the bottom of `processPayment` already has access to the `context` parameter — pass it through. The `context.mounted` guard prevents pushing onto a disposed widget.

- [ ] **Step 6: Update all `_fireFailure` call sites to pass `context`**

In `processPayment`, there are 5 call sites to `_fireFailure` (lines ~67, 78, 94, 133, 146). Update each to pass `context: context` (the `processPayment` parameter):

Examples:
```dart
        await _fireFailure(
          message: 'Could not initialize payment.',
          category: PaymentErrorCategory.serverError,
          context: context,
        );
```

```dart
      await _fireFailure(
        reference: reference,
        message: webViewSuccess
            ? 'Payment received but confirmation timed out. Check your bookings shortly.'
            : 'Payment was cancelled or did not complete.',
        category: webViewSuccess
            ? PaymentErrorCategory.network
            : PaymentErrorCategory.cancelled,
        context: context,
      );
```

```dart
    } catch (e, st) {
      debugPrint('processPayment error: $e\n$st');
      await _fireFailure(
        message: e.toString(),
        category: PaymentErrorCategory.unknown,
        context: context,
      );
      state = AsyncValue.error(e, st);
      return null;
    }
```

Apply to all 5 call sites.

- [ ] **Step 7: Verify no syntax errors**

```bash
flutter analyze lib/payment/presentation/controllers/payment_controller.dart 2>&1 | head -20
```
Expected: 0 errors. (Pre-existing project-wide warnings like `withOpacity` deprecation are fine.)

- [ ] **Step 8: Commit**

```bash
git add lib/payment/presentation/controllers/payment_controller.dart
git commit -m "spec(19): payment controller — cache intent + render paymentErrorBuilder"
```

---

# Task 2: PaymentFailureScreen widget + main.dart wiring

**Files:**
- Create: `lib/payment/presentation/screens/payment_failure_screen.dart`
- Modify: `lib/main.dart`
- Create: `test/payment/payment_failure_screen_test.dart`

- [ ] **Step 1: Write the failing widget test**

Create `test/payment/payment_failure_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/payment/config/payment_config.dart';
import 'package:nano_embryo/payment/presentation/screens/payment_failure_screen.dart';

void main() {
  group('PaymentFailureScreen', () {
    Widget _wrap(PaymentErrorInfo info) => ProviderScope(
          child: MaterialApp(
            home: PaymentFailureScreen(info: info),
          ),
        );

    testWidgets('renders declined-card copy for declined category',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PaymentErrorInfo(
          message: 'Card declined',
          category: PaymentErrorCategory.declined,
        ),
      ));
      expect(find.text('Card declined'), findsOneWidget);
      expect(find.textContaining('Try a different card'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('renders cancelled copy for cancelled category',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PaymentErrorInfo(
          message: 'User cancelled',
          category: PaymentErrorCategory.cancelled,
        ),
      ));
      expect(find.text('Payment cancelled'), findsOneWidget);
    });

    testWidgets('renders network copy for network category', (tester) async {
      await tester.pumpWidget(_wrap(
        const PaymentErrorInfo(
          message: 'Network error',
          category: PaymentErrorCategory.network,
        ),
      ));
      expect(find.text('Connection lost'), findsOneWidget);
    });

    testWidgets('falls back to unknown copy for unknown category',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PaymentErrorInfo(
          message: 'Mystery',
          category: PaymentErrorCategory.unknown,
        ),
      ));
      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/payment/payment_failure_screen_test.dart
```
Expected: FAIL — `PaymentFailureScreen` doesn't exist.

- [ ] **Step 3: Create `payment_failure_screen.dart`**

```dart
// lib/payment/presentation/screens/payment_failure_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/payment/config/payment_config.dart';
import 'package:nano_embryo/payment/presentation/controllers/payment_controller.dart';

class PaymentFailureScreen extends ConsumerWidget {
  const PaymentFailureScreen({required this.info, super.key});

  final PaymentErrorInfo info;

  static const _copy = <PaymentErrorCategory, ({String title, String body})>{
    PaymentErrorCategory.cancelled: (
      title: 'Payment cancelled',
      body:
          "You cancelled this payment before it completed. You can try again whenever you're ready.",
    ),
    PaymentErrorCategory.declined: (
      title: 'Card declined',
      body:
          'Your card was declined. Try a different card, or contact your bank to authorize the payment.',
    ),
    PaymentErrorCategory.network: (
      title: 'Connection lost',
      body:
          "We couldn't reach the payment provider. Check your connection and try again.",
    ),
    PaymentErrorCategory.validation: (
      title: "Payment couldn't be processed",
      body:
          'There was a problem with the payment details. Please review and try again.',
    ),
    PaymentErrorCategory.serverError: (
      title: 'Provider error',
      body:
          'The payment provider returned an error. Please try again in a moment.',
    ),
    PaymentErrorCategory.unknown: (
      title: 'Something went wrong',
      body: "We weren't able to complete this payment. Please try again.",
    ),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = _copy[info.category] ?? _copy[PaymentErrorCategory.unknown]!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isCancelled = info.category == PaymentErrorCategory.cancelled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Icon(Icons.error_outline, size: 64, color: cs.error),
              const SizedBox(height: 24),
              Text(
                copy.title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                copy.body,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                onPressed: isCancelled
                    ? () => Navigator.of(context).pop()
                    : () async {
                        Navigator.of(context).pop();
                        await ref
                            .read(paymentControllerProvider.notifier)
                            .retryLast(context);
                      },
                child: Text(isCancelled ? 'Back to booking' : 'Try again'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/payment/payment_failure_screen_test.dart
```
Expected: PASS, 4 tests.

- [ ] **Step 5: Wire the builder in `lib/main.dart`**

Find the existing `paymentConfigProvider.overrideWithValue(...)` block (search for `paymentConfigProvider.overrideWithValue`). Add the `paymentErrorBuilder` field:

```dart
paymentConfigProvider.overrideWithValue(
  PaymentConfig(
    appScheme: 'nanoembryo',
    brandName: 'NanoEmbryo',
    defaultCurrency: 'GHS',
    paymentErrorBuilder: (context, info) =>
        PaymentFailureScreen(info: info),
  ),
),
```

Add the import at the top of `main.dart`:
```dart
import 'package:nano_embryo/payment/presentation/screens/payment_failure_screen.dart';
```

- [ ] **Step 6: Verify**

```bash
flutter analyze lib/main.dart lib/payment/presentation/screens/payment_failure_screen.dart test/payment/payment_failure_screen_test.dart 2>&1 | head -20
```
Expected: 0 errors for these specific files. (Existing project-wide warnings ignored.)

- [ ] **Step 7: Commit**

```bash
git add lib/main.dart \
        lib/payment/presentation/screens/payment_failure_screen.dart \
        test/payment/payment_failure_screen_test.dart
git commit -m "spec(19): payment failure screen with category-aware retry"
```

---

# Task 3: Wallet repository — cursor pagination + dead-letter stream

**Files:**
- Modify: `lib/wallet/data/repositories/wallet_repository.dart`
- Modify: `lib/wallet/data/repositories/supabase/supabase_wallet_repository.dart`

- [ ] **Step 1: Extend the `WalletRepository` abstract**

Update the existing `getTransactions` signature to add `before: DateTime?`:

```dart
  /// Get transaction history with pagination
  ///
  /// Pass [before] for cursor-based pagination — returns rows with
  /// created_at strictly less than the cursor. [offset] still works for
  /// existing call sites that use it.
  Future<List<WalletTransactionModel>> getTransactions({
    required String shopId,
    int? limit,
    int? offset,
    DateTime? before,
    DateTime? fromDate,
    DateTime? toDate,
    TransactionType? type,
  });
```

Add the new dead-letter stream method to the abstract:

```dart
  /// Stream of withdrawals currently in 'dead_letter' status for [shopId].
  /// Emits the current list, then a fresh list every 30 seconds.
  Stream<List<WithdrawalRequestModel>> watchDeadLetterWithdrawals(
    String shopId,
  );
```

- [ ] **Step 2: Update `SupabaseWalletRepository.getTransactions` to honor `before`**

Find the existing `getTransactions` implementation in `lib/wallet/data/repositories/supabase/supabase_wallet_repository.dart` (around line 73 — the one with `.from('wallet_transactions')`).

The current implementation builds a query and applies `limit`/`offset`/`fromDate`/`toDate`. Add a `before` branch right after `fromDate`/`toDate` handling:

```dart
    if (before != null) {
      query = query.lt('created_at', before.toIso8601String());
    }
```

The method signature needs the new parameter:
```dart
  @override
  Future<List<WalletTransactionModel>> getTransactions({
    required String shopId,
    int? limit,
    int? offset,
    DateTime? before,
    DateTime? fromDate,
    DateTime? toDate,
    TransactionType? type,
  }) async {
    // existing body, plus the `if (before != null) { ... }` block above
    // ...
  }
```

- [ ] **Step 3: Implement `watchDeadLetterWithdrawals` in `SupabaseWalletRepository`**

Add this method to `SupabaseWalletRepository` (alongside the other methods):

```dart
  @override
  Stream<List<WithdrawalRequestModel>> watchDeadLetterWithdrawals(
    String shopId,
  ) async* {
    // Emit immediately, then every 30 seconds. Polling is intentional —
    // dead_letter is rare and Realtime subscriptions add lifecycle complexity
    // for a low-frequency event.
    while (true) {
      try {
        final data = await _supabase
            .from('withdrawal_requests')
            .select()
            .eq('shop_id', shopId)
            .eq('status', 'dead_letter')
            .order('updated_at', ascending: false);
        yield (data as List)
            .map((row) => WithdrawalRequestModel.fromJson(row))
            .toList();
      } catch (e) {
        // Yield empty on transient errors — banner just hides.
        yield const [];
      }
      await Future.delayed(const Duration(seconds: 30));
    }
  }
```

The `_supabase` field name should match the existing convention in this file (it's the SupabaseClient — check the constructor / other methods). If the file uses `_client` or similar, use that.

- [ ] **Step 4: Verify**

```bash
flutter analyze lib/wallet/data/repositories/ 2>&1 | head -20
```
Expected: 0 errors for these files.

- [ ] **Step 5: Commit**

```bash
git add lib/wallet/data/repositories/wallet_repository.dart \
        lib/wallet/data/repositories/supabase/supabase_wallet_repository.dart
git commit -m "spec(19): wallet repo — cursor pagination + dead-letter stream"
```

---

# Task 4: WithdrawalRequestModel — add `deadLetterReason`

**Files:**
- Modify: `lib/wallet/data/models/withdrawal_request_model.dart`

- [ ] **Step 1: Read the current model** to find the fields list, constructor, fromJson, toJson, props.

```bash
cat lib/wallet/data/models/withdrawal_request_model.dart
```

- [ ] **Step 2: Add the field**

Add `deadLetterReason: String?` to the `WithdrawalRequestModel` class. The model has multiple touchpoints — make sure to update ALL of them:

1. **Field declaration**: `final String? deadLetterReason;`
2. **Constructor**: add `this.deadLetterReason,` (optional positional or named — match existing pattern)
3. **`fromJson`**: add `deadLetterReason: json['dead_letter_reason'] as String?,`
4. **`toJson`** (if it exists): add `'dead_letter_reason': deadLetterReason,`
5. **`copyWith`** (if it exists): add `String? deadLetterReason,` param and pass through
6. **`props`** (Equatable): add `deadLetterReason` to the list

If the model has any other fields newly introduced by Phase 3.2 (`attemptCount`, `nextAttemptAt`, `lastError`), don't add them — only `deadLetterReason` is used by the banner.

- [ ] **Step 3: Verify**

```bash
flutter analyze lib/wallet/data/models/withdrawal_request_model.dart 2>&1 | head -10
```
Expected: 0 errors.

- [ ] **Step 4: Commit**

```bash
git add lib/wallet/data/models/withdrawal_request_model.dart
git commit -m "spec(19): WithdrawalRequestModel — add deadLetterReason field"
```

---

# Task 5: Riverpod providers — paginated transactions + dead-letter stream

**Files:**
- Create: `lib/wallet/providers/wallet_transactions_paginated_provider.dart`
- Create: `lib/wallet/providers/dead_letter_withdrawals_provider.dart`
- Create: `test/wallet/wallet_transactions_paginated_test.dart`

- [ ] **Step 1: Write the failing test** for the paginated provider

Create `test/wallet/wallet_transactions_paginated_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/wallet/data/models/wallet_transaction_model.dart';
import 'package:nano_embryo/wallet/data/models/withdrawal_request_model.dart';
import 'package:nano_embryo/wallet/data/repositories/wallet_repository.dart';
import 'package:nano_embryo/wallet/providers/wallet_providers.dart';
import 'package:nano_embryo/wallet/providers/wallet_transactions_paginated_provider.dart';

class _FakeRepo implements WalletRepository {
  _FakeRepo(this.pages);
  final List<List<WalletTransactionModel>> pages;
  int call = 0;

  @override
  Future<List<WalletTransactionModel>> getTransactions({
    required String shopId,
    int? limit,
    int? offset,
    DateTime? before,
    DateTime? fromDate,
    DateTime? toDate,
    TransactionType? type,
  }) async {
    if (call >= pages.length) return [];
    return pages[call++];
  }

  // Unused stubs for this test
  @override
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

WalletTransactionModel _txn(String id, DateTime createdAt) =>
    WalletTransactionModel(
      id: id,
      shopId: 'shop_1',
      amount: 10,
      type: TransactionType.deposit,
      createdAt: createdAt,
    );

void main() {
  group('WalletTransactionsPaginated', () {
    test('build returns first page', () async {
      final repo = _FakeRepo([
        List.generate(20, (i) => _txn('t$i', DateTime(2026, 5, 20 - i))),
      ]);
      final container = ProviderContainer(overrides: [
        walletRepositoryProvider.overrideWith((_) => repo),
      ]);
      addTearDown(container.dispose);

      final list = await container
          .read(walletTransactionsPaginatedProvider('shop_1').future);
      expect(list, hasLength(20));
    });

    test('loadNext appends second page', () async {
      final repo = _FakeRepo([
        List.generate(20, (i) => _txn('t$i', DateTime(2026, 5, 20 - i))),
        List.generate(20, (i) => _txn('u$i', DateTime(2026, 4, 30 - i))),
      ]);
      final container = ProviderContainer(overrides: [
        walletRepositoryProvider.overrideWith((_) => repo),
      ]);
      addTearDown(container.dispose);

      await container
          .read(walletTransactionsPaginatedProvider('shop_1').future);
      await container
          .read(walletTransactionsPaginatedProvider('shop_1').notifier)
          .loadNext();
      final state = container
          .read(walletTransactionsPaginatedProvider('shop_1'))
          .value!;
      expect(state, hasLength(40));
    });

    test('loadNext no-op when hasMore=false', () async {
      final repo = _FakeRepo([
        // First page returns 5 — short page signals end.
        List.generate(5, (i) => _txn('t$i', DateTime(2026, 5, 20 - i))),
      ]);
      final container = ProviderContainer(overrides: [
        walletRepositoryProvider.overrideWith((_) => repo),
      ]);
      addTearDown(container.dispose);

      await container
          .read(walletTransactionsPaginatedProvider('shop_1').future);
      final notifier = container
          .read(walletTransactionsPaginatedProvider('shop_1').notifier);
      expect(notifier.hasMore, isFalse);

      await notifier.loadNext();
      expect(repo.call, 1, reason: 'should not invoke repo again');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/wallet/wallet_transactions_paginated_test.dart
```
Expected: FAIL — provider doesn't exist.

- [ ] **Step 3: Create the paginated provider**

`lib/wallet/providers/wallet_transactions_paginated_provider.dart`:

```dart
import 'package:nano_embryo/wallet/data/models/wallet_transaction_model.dart';
import 'package:nano_embryo/wallet/providers/wallet_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet_transactions_paginated_provider.g.dart';

@riverpod
class WalletTransactionsPaginated extends _$WalletTransactionsPaginated {
  static const _pageSize = 20;
  bool _hasMore = true;
  bool _loading = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _loading;

  @override
  Future<List<WalletTransactionModel>> build(String shopId) async {
    final repo = ref.read(walletRepositoryProvider);
    final first = await repo.getTransactions(
      shopId: shopId,
      limit: _pageSize,
    );
    _hasMore = first.length == _pageSize;
    return first;
  }

  Future<void> loadNext() async {
    if (_loading || !_hasMore) return;
    final current = state.valueOrNull;
    if (current == null || current.isEmpty) return;
    _loading = true;
    try {
      final repo = ref.read(walletRepositoryProvider);
      final next = await repo.getTransactions(
        shopId: shopId,
        before: current.last.createdAt,
        limit: _pageSize,
      );
      _hasMore = next.length == _pageSize;
      state = AsyncData([...current, ...next]);
    } finally {
      _loading = false;
    }
  }

  Future<void> refresh() async {
    _hasMore = true;
    ref.invalidateSelf();
    await future;
  }
}
```

- [ ] **Step 4: Create the dead-letter stream provider**

`lib/wallet/providers/dead_letter_withdrawals_provider.dart`:

```dart
import 'package:nano_embryo/wallet/data/models/withdrawal_request_model.dart';
import 'package:nano_embryo/wallet/providers/wallet_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dead_letter_withdrawals_provider.g.dart';

@riverpod
Stream<List<WithdrawalRequestModel>> deadLetterWithdrawals(
  DeadLetterWithdrawalsRef ref,
  String shopId,
) {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.watchDeadLetterWithdrawals(shopId);
}
```

- [ ] **Step 5: Run codegen**

```bash
dart run build_runner build --delete-conflicting-outputs
```
Expected: completes without errors; generates two new `.g.dart` files next to the providers.

- [ ] **Step 6: Run the test to verify it passes**

```bash
flutter test test/wallet/wallet_transactions_paginated_test.dart
```
Expected: PASS, 3 tests.

- [ ] **Step 7: Commit**

```bash
git add lib/wallet/providers/wallet_transactions_paginated_provider.dart \
        lib/wallet/providers/wallet_transactions_paginated_provider.g.dart \
        lib/wallet/providers/dead_letter_withdrawals_provider.dart \
        lib/wallet/providers/dead_letter_withdrawals_provider.g.dart \
        test/wallet/wallet_transactions_paginated_test.dart
git commit -m "spec(19): wallet providers — paginated transactions + dead-letter stream"
```

---

# Task 6: DeadLetterBanner widget

**Files:**
- Create: `lib/wallet/presentation/widgets/dead_letter_banner.dart`
- Create: `test/wallet/dead_letter_banner_test.dart`

- [ ] **Step 1: Write the failing widget test**

Create `test/wallet/dead_letter_banner_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/wallet/data/models/withdrawal_request_model.dart';
import 'package:nano_embryo/wallet/presentation/widgets/dead_letter_banner.dart';
import 'package:nano_embryo/wallet/providers/dead_letter_withdrawals_provider.dart';

WithdrawalRequestModel _wd(String id, double amount) => WithdrawalRequestModel(
      id: id,
      shopId: 'shop_1',
      amount: amount,
      status: WithdrawalStatus.deadLetter,
      paymentProvider: 'paystack',
      idempotencyKey: 'k_$id',
      createdAt: DateTime(2026, 5, 18),
      updatedAt: DateTime(2026, 5, 18),
      deadLetterReason: 'exhausted 5 retries: connection timeout',
    );

Widget _wrap(Stream<List<WithdrawalRequestModel>> stream) => ProviderScope(
      overrides: [
        deadLetterWithdrawalsProvider('shop_1').overrideWith((_) => stream),
      ],
      child: const MaterialApp(
        home: Scaffold(body: DeadLetterBanner(shopId: 'shop_1')),
      ),
    );

void main() {
  group('DeadLetterBanner', () {
    testWidgets('renders nothing when stream emits empty list',
        (tester) async {
      await tester.pumpWidget(_wrap(Stream.value(const [])));
      await tester.pump();
      expect(find.byType(Icon), findsNothing);
      expect(find.textContaining('needs review'), findsNothing);
    });

    testWidgets('renders banner when stream emits non-empty list',
        (tester) async {
      await tester.pumpWidget(_wrap(Stream.value([_wd('w1', 250.0)])));
      await tester.pump();
      expect(find.text('Withdrawal needs review'), findsOneWidget);
      expect(find.textContaining('250.00'), findsOneWidget);
    });

    testWidgets('expands to show withdrawal details on tap', (tester) async {
      await tester.pumpWidget(_wrap(Stream.value([_wd('w1', 250.0)])));
      await tester.pump();
      expect(find.text('Contact support'), findsNothing);
      await tester.tap(find.text('Withdrawal needs review'));
      await tester.pump();
      expect(find.text('Contact support'), findsOneWidget);
      expect(find.textContaining('exhausted 5 retries'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/wallet/dead_letter_banner_test.dart
```
Expected: FAIL — `DeadLetterBanner` does not exist.

- [ ] **Step 3: Create the banner widget**

```dart
// lib/wallet/presentation/widgets/dead_letter_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/wallet/data/models/withdrawal_request_model.dart';
import 'package:nano_embryo/wallet/providers/dead_letter_withdrawals_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DeadLetterBanner extends ConsumerStatefulWidget {
  const DeadLetterBanner({required this.shopId, super.key});
  final String shopId;

  @override
  ConsumerState<DeadLetterBanner> createState() => _DeadLetterBannerState();
}

class _DeadLetterBannerState extends ConsumerState<DeadLetterBanner> {
  bool _expanded = false;

  Future<void> _contactSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@nanoembryo.app',
      queryParameters: {
        'subject': 'Withdrawal needs review',
        'body':
            'My withdrawal is stuck and needs manual review. Shop ID: ${widget.shopId}',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(deadLetterWithdrawalsProvider(widget.shopId));
    final list = async.valueOrNull ?? const <WithdrawalRequestModel>[];
    if (list.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final total = list.fold<double>(0, (sum, w) => sum + w.amount);
    // Currency field on WithdrawalRequestModel may not exist — fall back to GHS.
    final currency = 'GHS';

    return Material(
      color: cs.tertiaryContainer,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: cs.onTertiaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Withdrawal needs review',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: cs.onTertiaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          list.length == 1
                              ? '$currency ${total.toStringAsFixed(2)} stuck — tap for details'
                              : '$currency ${total.toStringAsFixed(2)} stuck across ${list.length} withdrawals — tap for details',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onTertiaryContainer),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: cs.onTertiaryContainer,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 12),
                Divider(
                    color: cs.onTertiaryContainer.withOpacity(0.2), height: 1),
                const SizedBox(height: 12),
                ...list.map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _DeadLetterRow(withdrawal: w, currency: currency),
                    )),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonal(
                    onPressed: _contactSupport,
                    child: const Text('Contact support'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DeadLetterRow extends StatelessWidget {
  const _DeadLetterRow({required this.withdrawal, required this.currency});
  final WithdrawalRequestModel withdrawal;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final d = withdrawal.updatedAt;
    final fmtDate =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final shortId = withdrawal.id.length >= 8
        ? withdrawal.id.substring(0, 8)
        : withdrawal.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• $currency ${withdrawal.amount.toStringAsFixed(2)} — $fmtDate — #$shortId',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onTertiaryContainer,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (withdrawal.deadLetterReason != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 2),
            child: Text(
              'Reason: ${withdrawal.deadLetterReason}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onTertiaryContainer.withOpacity(0.85),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
```

- [ ] **Step 4: Add `WithdrawalStatus.deadLetter` to the enum** (if not already present)

Check the existing `WithdrawalStatus` enum (likely in `withdrawal_request_model.dart` or a sibling file):

```bash
grep -n "enum WithdrawalStatus" lib/wallet/data/models/withdrawal_request_model.dart
```

If `deadLetter` is missing, add it:
```dart
enum WithdrawalStatus { pending, processing, completed, failed, refunded, retrying, deadLetter }
```

(Names match the DB `status` strings via a `name` getter that snake-cases. If your enum uses string-mapped serialization, update the fromString/toString accordingly: `'dead_letter'` ↔ `WithdrawalStatus.deadLetter`, `'retrying'` ↔ `WithdrawalStatus.retrying`.)

- [ ] **Step 5: Run test to verify it passes**

```bash
flutter test test/wallet/dead_letter_banner_test.dart
```
Expected: PASS, 3 tests.

- [ ] **Step 6: Commit**

```bash
git add lib/wallet/presentation/widgets/dead_letter_banner.dart \
        lib/wallet/data/models/withdrawal_request_model.dart \
        test/wallet/dead_letter_banner_test.dart
git commit -m "spec(19): dead-letter banner — amber persistent + expandable details"
```

---

# Task 7: WalletScreen integration

**Files:**
- Modify: `lib/wallet/presentation/screens/wallet_screen.dart`

Three changes to the existing screen:
1. Insert `DeadLetterBanner` between the balance card and the transaction list.
2. Replace `walletTransactionsProvider(shopId:, limit:)` with `walletTransactionsPaginatedProvider(shopId)`.
3. Add a `ScrollController` that triggers `loadNext()` near the bottom.

- [ ] **Step 1: Read** the full `lib/wallet/presentation/screens/wallet_screen.dart` and locate:
  - The `_WalletScreenState` class
  - The line `final transactionsAsync = ref.watch(walletTransactionsProvider(shopId: widget.shopId, limit: 20));`
  - The `build()` method's tree where `WalletBalanceCard` and the transaction list are composed

- [ ] **Step 2: Add the imports** at the top of the file:

```dart
import 'package:nano_embryo/wallet/presentation/widgets/dead_letter_banner.dart';
import 'package:nano_embryo/wallet/providers/wallet_transactions_paginated_provider.dart';
```

(Keep the existing `wallet_providers.dart` import — it still owns `walletRepositoryProvider`, `shopWalletProvider`, etc.)

- [ ] **Step 3: Add a `ScrollController` to `_WalletScreenState`**

Inside the `_WalletScreenState` class, add at the top:

```dart
class _WalletScreenState extends ConsumerState<WalletScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  void _maybeLoadMore() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 200) {
      ref
          .read(walletTransactionsPaginatedProvider(widget.shopId).notifier)
          .loadNext();
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_maybeLoadMore);
    _scroll.dispose();
    super.dispose();
  }

  // ... build method below ...
}
```

- [ ] **Step 4: Swap the provider in `build()`**

Replace:
```dart
    final transactionsAsync = ref.watch(
      walletTransactionsProvider(shopId: widget.shopId, limit: 20),
    );
```

With:
```dart
    final transactionsAsync = ref.watch(
      walletTransactionsPaginatedProvider(widget.shopId),
    );
```

- [ ] **Step 5: Insert the banner and add the ScrollController to the ListView**

Find the transaction list rendering. It likely looks like a `ListView.builder` or `ListView.separated` inside a `transactionsAsync.when(...)` block. Make these changes:

A. **Insert `DeadLetterBanner` BEFORE the transactions list.** The exact composition depends on the existing tree, but the pattern is:

```dart
Column(
  children: [
    const WalletBalanceCard(/* ... */),
    DeadLetterBanner(shopId: widget.shopId),  // ← new
    Expanded(
      child: transactionsAsync.when(/* ... */),
    ),
  ],
)
```

If the existing screen uses a `CustomScrollView` with `SliverList` instead, wrap the banner in a `SliverToBoxAdapter` and place it before the sliver list.

B. **Attach `_scroll` to the ListView and add a load-more footer:**

```dart
data: (txns) => RefreshIndicator(
  onRefresh: () => ref
      .read(walletTransactionsPaginatedProvider(widget.shopId).notifier)
      .refresh(),
  child: ListView.separated(
    controller: _scroll,
    itemCount: txns.length + 1, // +1 for footer
    separatorBuilder: (_, __) => const SizedBox(height: 8),
    itemBuilder: (context, i) {
      if (i == txns.length) {
        final notifier = ref.read(
          walletTransactionsPaginatedProvider(widget.shopId).notifier,
        );
        if (!notifier.hasMore) return const SizedBox.shrink();
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      }
      return TransactionListItem(transaction: txns[i]);
    },
  ),
),
```

(Keep the existing `loading: () => ...` and `error: (e, st) => ...` branches as-is.)

- [ ] **Step 6: Verify**

```bash
flutter analyze lib/wallet/presentation/screens/wallet_screen.dart 2>&1 | head -30
```
Expected: 0 errors for this file. Pre-existing project-wide warnings (`withOpacity` deprecation, `avoid_print`, etc.) are fine.

- [ ] **Step 7: Smoke verification** (user runs)

The implementer cannot launch the simulator. After commit, the user should:
1. Open the wallet screen for a shop with > 20 transactions → first 20 load → scroll to bottom → next 20 load.
2. `UPDATE withdrawal_requests SET status='dead_letter', dead_letter_reason='manual test' WHERE id='<some>'` → banner appears within 30s.
3. Tap banner → expands → "Contact support" opens mailto.
4. Force a payment failure (bad Paystack key) → `PaymentFailureScreen` appears with "Try again" → tap → retries.

- [ ] **Step 8: Commit**

```bash
git add lib/wallet/presentation/screens/wallet_screen.dart
git commit -m "spec(19): wallet screen — banner + paginated transactions + scroll listener"
```

---

# Verification (after all 7 tasks)

1. **All widget tests pass:** `flutter test test/payment/payment_failure_screen_test.dart test/wallet/`
2. **`flutter analyze`** reports no new errors for the touched files.
3. **Manual smoke test** (per Task 7, Step 7).

After ship, Phase 3 is complete — only **Item 3 (E2E payment tests)** remains as a separate spec/plan cycle.
