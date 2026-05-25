# PaymentWebView — Realtime Detection + Confirming Overlay

## Problem

MoMo (Mobile Money) payments on Paystack are asynchronous. After the user enters their PIN on their phone, the Paystack checkout page does not navigate to the `aurain://payment-success` callback URL immediately. The mobile network confirms the debit seconds-to-minutes later, at which point Paystack fires the `charge.success` webhook.

Diagnostic data from the iOS simulator runbook confirmed:
- `onNavigationRequest aurain://...` never fires during MoMo payments
- `checkBookingInDb result=null` for the full duration (webhook hadn't fired yet)
- `verify-payment` escalation fired 3–4 times before confirming — ~3–4 minutes of wait time
- WebView eventually popped via the verify-payment path

The user waited 3–4 minutes in a static WebView after paying. The booking was eventually created correctly, but the UX is unacceptable.

## Goal

Reduce time-to-pop from 3–4 minutes to <3 seconds for MoMo payments, by adding a Supabase Realtime subscription that detects the `bookings` row insertion the moment the webhook fires. Simultaneously add a visual bottom sheet that reassures the user their payment is being processed while they wait.

This commit also removes the temporary diagnostic `debugPrint` instrumentation added in `f3b517e`.

## Detection Path Architecture (after this change)

```
Priority   Path                     Speed      Trigger
──────────────────────────────────────────────────────────────────
  1 (new)  Realtime stream          < 1 s      Webhook fires → bookings row inserted
  2        URL scheme callback      < 1 s      Paystack redirect to aurain://payment-success
  3        DB poll (4 s tick)       4–8 s      Safety net when Realtime misses
  4        verify-payment (15 s)    15–60 s    Last resort; also creates booking if webhook missed
```

All four paths converge on `_handleSuccess()`, which has `if (_isComplete) return` as an idempotency guard. No double-pop risk regardless of which path fires first.

## Locked Decisions

1. **Realtime stream inside `_PaymentWebViewState`** — not a Riverpod provider. The subscription is a widget-lifetime concern, same as `_dbPollTimer` and `_verifyTimer`. It starts in `initState` and cancels in `dispose()`.

2. **`.stream(primaryKey: ['id']).eq('payment_intent_id', widget.reference)`** — uses the existing Supabase Flutter `.stream()` API (already used in two other places in the codebase: `notification_provider.dart` and `payment_setup_provider.dart`). No raw Realtime channel API needed.

3. **Bottom sheet shown for Paystack only, immediately on `onPageFinished`** — Stripe card payments complete synchronously via the callback URL and never need the sheet. Paystack MoMo is async and always needs it. The condition: `widget.provider == 'paystack' && !_isComplete`.

4. **Copy: "Confirming your payment… / This usually takes a few seconds"** — generic, provider-agnostic. Works for MoMo, card, bank transfer, and any future Paystack channel.

5. **No new config knobs** — `verifyEscalationInterval` and `dbPollInterval` remain. No new `PaymentConfig` fields. Realtime is always-on for Paystack; no toggle.

## Design

### `_PaymentWebViewState` changes

**New field:**
```dart
StreamSubscription<List<Map<String, dynamic>>>? _realtimeSubscription;
```

**In `initState` (after existing timer setup):**
```dart
_realtimeSubscription = Supabase.instance.client
    .from('bookings')
    .stream(primaryKey: ['id'])
    .eq('payment_intent_id', widget.reference)
    .listen(
  (rows) {
    if (!_isComplete && rows.any((r) => r['status'] == 'confirmed')) {
      debugPrint('[PaymentWebView] Realtime: booking confirmed');
      _handleSuccess();
    }
  },
  onError: (_) {
    // DB poll and verify-payment timers serve as fallbacks.
  },
);
```

**In `dispose()`:**
```dart
_realtimeSubscription?.cancel();
```

**New state field for bottom sheet animation:**
```dart
bool _showConfirmingSheet = false;
```

**In `onPageFinished` callback (inside `NavigationDelegate`):**
```dart
onPageFinished: (url) {
  setState(() {
    _isLoading = false;
    if (widget.provider == 'paystack') _showConfirmingSheet = true;
  });
  _startDbPolling();
},
```

**Bottom sheet widget (inside existing `Stack` in `build()`):**
```dart
AnimatedSlide(
  offset: _showConfirmingSheet && !_isComplete
      ? Offset.zero
      : const Offset(0, 1),
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeOutCubic,
  child: Align(
    alignment: Alignment.bottomCenter,
    child: _ConfirmingSheet(),
  ),
),
```

**`_ConfirmingSheet` private widget (same file):**
```dart
class _ConfirmingSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirming your payment…',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'This usually takes a few seconds',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Diagnostic cleanup

Remove from `_PaymentWebViewState`:
- `_logTag` getter
- All 13 `debugPrint` calls added in commit `f3b517e` (covering `initState`, `didChangeAppLifecycleState`, `dispose`, `onPageStarted`, `onPageFinished`, `onUrlChange`, `onNavigationRequest`, `_startDbPolling` tick, `_checkBookingInDb` result, `_verifyPaymentDirectly` result, `_handleSuccess` ×3, `_handleCancelled` ×3)

Keep: all functional logic unchanged (timers, `_checkBookingInDb`, `_verifyPaymentDirectly`, `_handleSuccess`, `_handleCancelled`, lifecycle observer).

### Error handling

| Scenario | Behaviour |
|---|---|
| Realtime connection drops | `onError` is a no-op; DB poll + verify-payment provide coverage |
| App backgrounded mid-wait | Supabase client reconnects Realtime on resume; `didChangeAppLifecycleState` restarts DB poll |
| Realtime and verify-payment both fire | `_handleSuccess` idempotency guard (`if (_isComplete) return`) prevents double-pop |
| User taps ✕ while sheet is showing | `Navigator.pop` disposes the widget; `dispose()` cancels stream |

## Files Changed

**Modified (1):**
- `lib/payment/presentation/widgets/payment_webview.dart` — add `_realtimeSubscription`, `_showConfirmingSheet`, update `onPageFinished`, add `_ConfirmingSheet` private widget, remove all diagnostic debugPrints

**No new files. No backend changes. No `PaymentConfig` changes.**

## Verification

1. **`flutter analyze lib/payment/presentation/widgets/payment_webview.dart`** — 0 new errors
2. **`flutter test test/payment/payment_controller_test.dart`** — 9/9 pass (unchanged)
3. **Manual**: MoMo test payment on iOS simulator → WebView pops in <3s after PIN entry, bottom sheet visible during wait, booking created in Supabase dashboard

## Out of Scope

- Stripe overlay — not needed; Stripe confirms synchronously via callback URL
- Realtime for other tables (`pending_payments` is service_role only; `bookings` is the correct target)
- `PaymentConfig` overlay toggle — YAGNI; if needed, add in a future PR
- Notification on pop — existing `widget.onComplete(true)` callback handles downstream side effects
