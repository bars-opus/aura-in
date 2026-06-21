# PaymentWebView Realtime Detection + Confirming Overlay Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Supabase Realtime subscription to `PaymentWebView` for <1s booking detection when the Paystack webhook fires, show a bottom-sheet overlay during async MoMo wait, and remove all temporary diagnostic `debugPrint` instrumentation from commit `f3b517e`.

**Architecture:** Single file change — `lib/payment/presentation/widgets/payment_webview.dart`. The Realtime stream is a `StreamSubscription` started in `initState` alongside the existing timers and cancelled in `dispose`. The bottom sheet is an `AnimatedSlide`-driven widget inside the existing `Stack`, gated on `widget.provider == 'paystack' && !_isComplete`. All four detection paths (Realtime, URL scheme, DB poll, verify-payment) converge on the existing `_handleSuccess()` with its idempotency guard.

**Tech Stack:** Flutter, `webview_flutter`, `supabase_flutter` (`.stream()` API), `flutter_riverpod`. No new dependencies.

---

## File Structure

**Modified (1):**
- `lib/payment/presentation/widgets/payment_webview.dart` — add fields, Realtime subscription, overlay widget, remove diagnostic prints

**No new files.**

---

## Task 1: Realtime detection + confirming overlay (single atomic commit)

**Files:**
- Modify: `lib/payment/presentation/widgets/payment_webview.dart`
- Test: `test/payment/payment_controller_test.dart` (existing — must pass unchanged)

---

- [ ] **Step 1: Verify baseline tests pass before touching anything**

```bash
flutter test test/payment/payment_controller_test.dart
```

Expected output:
```
00:XX +9: All tests passed!
```

If any test fails at this point, stop and fix before proceeding — the baseline must be green.

---

- [ ] **Step 2: Rewrite `payment_webview.dart` with the full cleaned + new version**

Replace the entire file with the following. This removes all 21 diagnostic `debugPrint` calls and the `_logTag` getter, adds `_showConfirmingSheet` and `_realtimeSubscription` fields, wires the Realtime subscription in `initState`, updates `onPageFinished` to trigger the overlay for Paystack, cancels the subscription in `dispose`, and adds the `AnimatedSlide` overlay to `build`.

```dart
// lib/features/payment/presentation/widgets/payment_webview.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/payment/config/payment_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends ConsumerStatefulWidget {
  final String url;
  final String provider;
  final String reference;
  final Function(bool success) onComplete;

  const PaymentWebView({
    Key? key,
    required this.url,
    required this.provider,
    required this.reference,
    required this.onComplete,
  }) : super(key: key);

  @override
  ConsumerState<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends ConsumerState<PaymentWebView>
    with WidgetsBindingObserver {
  late final WebViewController _controller;
  late final PaymentConfig _config;

  bool _isLoading = true;
  bool _isComplete = false;
  bool _isVerifying = false;
  bool _showConfirmingSheet = false;

  // Fast DB poll — checks bookings table at [PaymentConfig.dbPollInterval].
  Timer? _dbPollTimer;

  // Slow verify escalation — calls verify-payment edge fn at
  // [PaymentConfig.verifyEscalationInterval]. Started once in initState and
  // never reset, so it fires regardless of Paystack page navigations.
  Timer? _verifyTimer;

  // Realtime: detects booking row the moment the Paystack webhook fires,
  // giving <1s detection vs 4–60s for the polling paths.
  StreamSubscription<List<Map<String, dynamic>>>? _realtimeSubscription;

  late final String _successScheme;
  late final String _cancelScheme;
  late final String _failedScheme;
  late final String _appSchemePrefix;

  @override
  void initState() {
    super.initState();
    _config = ref.read(paymentConfigProvider);
    _successScheme = _config.successDeepLink.toLowerCase();
    _cancelScheme = _config.cancelDeepLink.toLowerCase();
    _failedScheme = _config.failedDeepLink.toLowerCase();
    _appSchemePrefix = '${_config.appScheme}://';

    WidgetsBinding.instance.addObserver(this);

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                setState(() => _isLoading = true);
              },
              onPageFinished: (url) {
                setState(() {
                  _isLoading = false;
                  if (widget.provider == 'paystack') _showConfirmingSheet = true;
                });
                _startDbPolling();
              },
              onUrlChange: (change) {
                if (change.url == null) return;
                if (_isSuccessUrl(change.url!)) _handleSuccess();
                if (_isCancelUrl(change.url!)) _handleCancelled();
              },
              onNavigationRequest: (request) {
                if (request.url.toLowerCase().startsWith(_appSchemePrefix)) {
                  if (_isSuccessUrl(request.url)) {
                    _handleSuccess();
                  } else {
                    _handleCancelled();
                  }
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));

    // Verify timer fires independently of page navigation.
    _verifyTimer = Timer.periodic(_config.verifyEscalationInterval, (_) {
      if (!_isComplete && !_isVerifying) _verifyPaymentDirectly();
    });

    // Realtime subscription — primary fast-path for async MoMo payments.
    _realtimeSubscription = Supabase.instance.client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('payment_intent_id', widget.reference)
        .listen(
      (rows) {
        if (!_isComplete && rows.any((r) => r['status'] == 'confirmed')) {
          _handleSuccess();
        }
      },
      onError: (_) {
        // DB poll and verify-payment timers serve as fallbacks on stream error.
      },
    );
  }

  // ── App lifecycle ───────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isComplete) return;
    if (state == AppLifecycleState.resumed) {
      _checkBookingInDb();
      _startDbPolling();
      if (!_isVerifying) _verifyPaymentDirectly();
    } else if (state == AppLifecycleState.paused) {
      _dbPollTimer?.cancel();
    }
  }

  // ── DB polling (fast path — webhook already fired) ──────────────────────────

  void _startDbPolling() {
    _dbPollTimer?.cancel();
    _dbPollTimer = Timer.periodic(_config.dbPollInterval, (_) {
      if (_isComplete) {
        _dbPollTimer?.cancel();
        return;
      }
      _checkBookingInDb();
    });
  }

  Future<void> _checkBookingInDb() async {
    if (_isComplete) return;
    try {
      final result =
          await Supabase.instance.client
              .from('bookings')
              .select('id')
              .eq('payment_intent_id', widget.reference)
              .eq('status', 'confirmed')
              .maybeSingle();

      if (result != null) {
        _dbPollTimer?.cancel();
        _handleSuccess();
      }
    } catch (_) {
      // Poll will retry on next tick.
    }
  }

  // ── Verify escalation (slow path — webhook missed) ──────────────────────────

  Future<void> _verifyPaymentDirectly() async {
    if (_isComplete || _isVerifying) return;
    _isVerifying = true;

    try {
      final response = await Supabase.instance.client.functions.invoke(
        _config.verifyPaymentFunctionName,
        body: {'reference': widget.reference, 'provider': widget.provider},
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        _dbPollTimer?.cancel();
        _verifyTimer?.cancel();
        _handleSuccess();
      }
    } catch (_) {
      // Will retry on next timer tick.
    } finally {
      _isVerifying = false;
    }
  }

  // ── Outcome handlers ────────────────────────────────────────────────────────

  void _handleSuccess() {
    if (_isComplete) return;
    _isComplete = true;
    widget.onComplete(true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _handleCancelled() {
    if (_isComplete) return;
    _isComplete = true;
    widget.onComplete(false);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) Navigator.pop(context);
    });
  }

  bool _isSuccessUrl(String url) {
    final lower = url.toLowerCase();
    return lower.startsWith(_successScheme);
  }

  bool _isCancelUrl(String url) {
    final lower = url.toLowerCase();
    return lower.startsWith(_cancelScheme) || lower.startsWith(_failedScheme);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dbPollTimer?.cancel();
    _verifyTimer?.cancel();
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  // ── UI ───────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.provider == 'stripe' ? 'Stripe Checkout' : 'Paystack Payment',
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel payment',
          onPressed: () {
            if (!_isComplete) widget.onComplete(false);
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularLoadingIndicator()),
          AnimatedSlide(
            offset: _showConfirmingSheet && !_isComplete
                ? Offset.zero
                : const Offset(0, 1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: const Align(
              alignment: Alignment.bottomCenter,
              child: _ConfirmingSheet(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmingSheet extends StatelessWidget {
  const _ConfirmingSheet();

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

---

- [ ] **Step 3: Run `flutter analyze` on the modified file**

```bash
flutter analyze lib/payment/presentation/widgets/payment_webview.dart 2>&1 | head -30
```

Expected: `No issues found!` or pre-existing project-wide warnings unrelated to this file. Any NEW error in this file blocks the commit — fix before proceeding.

Common false positives to ignore:
- `withOpacity is deprecated` — not introduced here (we use `withValues`)
- Warnings from other files in the project

---

- [ ] **Step 4: Run existing payment controller tests to confirm no regression**

```bash
flutter test test/payment/payment_controller_test.dart
```

Expected:
```
00:XX +9: All tests passed!
```

These tests mock the WebView via the injected `WebViewLauncher` typedef, so they never instantiate `PaymentWebView` — they should be unaffected by this change. If any fail, a pre-existing issue exists; investigate before committing.

---

- [ ] **Step 5: Commit**

```bash
git add lib/payment/presentation/widgets/payment_webview.dart

git commit -m "$(cat <<'EOF'
feat(payment): Realtime booking detection + confirming overlay

Adds Supabase Realtime subscription on bookings filtered by
payment_intent_id as the primary detection path (<1s) for async MoMo
payments. The webhook fires → booking row inserted → stream emits →
_handleSuccess() called immediately, replacing the 3–4 minute wait via
verify-payment escalation alone.

Also adds a bottom-sheet overlay ("Confirming your payment…") that
slides up after onPageFinished for Paystack payments, giving visual
feedback during the async MoMo confirmation window.

Removes all temporary diagnostic debugPrint instrumentation added in
f3b517e as planned.

Detection path priority (fastest to slowest):
  1. Realtime stream        <1s   (new)
  2. URL scheme callback    <1s   (Stripe/card)
  3. DB poll (4s)           4–8s  (safety net)
  4. verify-payment (15s)   15s+  (last resort)

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

Expected: commit succeeds. Run `git show --stat HEAD` to confirm only `payment_webview.dart` is in the diff.

---

## Verification (after Task 1)

1. **`flutter analyze`** — 0 new errors in `payment_webview.dart`
2. **`flutter test test/payment/payment_controller_test.dart`** — 9/9 pass
3. **`git show --stat HEAD`** — only `lib/payment/presentation/widgets/payment_webview.dart` changed
4. **Manual (iOS simulator)**: Make a Paystack MoMo test payment → bottom sheet appears after page loads → WebView pops in <3s after PIN entry (vs 3–4 minutes before)
