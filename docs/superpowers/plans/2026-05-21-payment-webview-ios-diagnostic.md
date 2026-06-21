# PaymentWebView iOS Diagnostic Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Single atomic commit that rebrands the payment URL scheme from `nanoembryo` to `aurain` (matching iOS Info.plist) and adds temporary `[PW]`-prefixed `debugPrint` instrumentation to `PaymentWebView` so the user can diagnose why the WebView doesn't pop on iOS sim after a successful payment.

**Architecture:** Four touch points — `lib/main.dart` config change, `ios/Runner/Info.plist` verification (no-op expected), `android/app/src/main/AndroidManifest.xml` intent-filter additions, and `lib/payment/presentation/widgets/payment_webview.dart` debug instrumentation. All bundled into one commit because they have to land together to be testable (instrumentation without scheme fix would still mislead; scheme fix alone gives no log evidence).

**Tech Stack:** Flutter, no new dependencies. All instrumentation via `debugPrint` (no-op in release builds).

---

## File Structure

**Modified files (4):**
- `lib/main.dart` — change one literal: `'nanoembryo'` → `'aurain'`
- `ios/Runner/Info.plist` — verify-only; expected no-op
- `android/app/src/main/AndroidManifest.xml` — add 3 intent filters for `aurain://payment-success`, `aurain://payment-cancelled`, `aurain://payment-failed`
- `lib/payment/presentation/widgets/payment_webview.dart` — add `_logTag` getter and 13 `debugPrint` instrumentation lines

**No new files. No test files.** The instrumentation is observation-only `debugPrint` output; not testable behavior. Existing `test/payment/payment_controller_test.dart` does not touch `PaymentWebView` and should keep passing unchanged.

---

## Caveats baked into this plan

- **One commit, many steps.** The spec mandates a single atomic commit. Steps 1–7 stage changes; step 10 commits them. Do not commit between steps.
- **Spec's "Repro Runbook" is not implemented.** It's user-facing documentation that lives in the spec file itself. After the commit lands, the user runs the runbook manually — no code does this.
- **`_appSchemePrefix` value depends on Step 1.** After changing `appScheme: 'aurain'` in `main.dart`, the `PaymentConfig.successDeepLink` becomes `aurain://payment-success` and `PaymentWebView`'s `_appSchemePrefix` (computed in `initState` from `_config.appScheme`) becomes `aurain://`. No code change to `PaymentWebView` is needed for the prefix itself — it's already wired through config.
- **iOS Info.plist already has `aurain` registered** (verified at [ios/Runner/Info.plist:38-48](../../../ios/Runner/Info.plist)). Step 2 is a verification step; if the entry is missing for any reason, follow the spec's fallback.

---

# Task 1: Diagnostic instrumentation + scheme rebrand (single atomic commit)

**Files:**
- Modify: `lib/main.dart` (line 131)
- Verify: `ios/Runner/Info.plist` (lines 38-48)
- Modify: `android/app/src/main/AndroidManifest.xml` (after line 44)
- Modify: `lib/payment/presentation/widgets/payment_webview.dart`

This task ships all four changes in one commit because they're coupled: the scheme rebrand changes what URL the WebView listens for, and the instrumentation logs whether that listening works. Half-changes would mislead the diagnosis.

---

- [ ] **Step 1: Change appScheme in main.dart**

Find the `paymentConfigProvider.overrideWithValue(...)` block in `lib/main.dart` (line 131).

Change:
```dart
              appScheme: 'nanoembryo',
```

To:
```dart
              appScheme: 'aurain',
```

That single field flows through `PaymentConfig.successDeepLink` (→ `aurain://payment-success`), `cancelDeepLink`, `failedDeepLink`, the `successUrl`/`cancelUrl` in the `create-booking` request body, and `PaymentWebView`'s `_appSchemePrefix`. No other code changes needed for this rebrand to propagate.

---

- [ ] **Step 2: Verify iOS Info.plist has aurain registered**

Open `ios/Runner/Info.plist`. Search for `<string>aurain</string>` inside a `CFBundleURLSchemes` array.

Expected: lines 38-48 already contain:
```xml
<dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>aurain</string>
    <key>CFBundleURLSchemes</key>
    <array>
        <string>aurain</string>
    </array>
</dict>
```

If present: no change. Move to Step 3.

If somehow missing (would be a regression): add the block above inside the existing `<array>` under `<key>CFBundleURLTypes</key>`.

---

- [ ] **Step 3: Add Android intent filters for payment callbacks**

Open `android/app/src/main/AndroidManifest.xml`. Locate the existing intent-filter block for `aurain://login-callback` (ending around line 44):

```xml
            <!-- OAuth callback: aurain://login-callback/ (Google & Apple via browser) -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="aurain" android:host="login-callback" />
            </intent-filter>
```

Immediately after this closing `</intent-filter>` (and before the `<!-- Legacy deep links kept for compatibility -->` comment), insert three new intent filters:

```xml

            <!-- Payment callbacks: aurain://payment-success|cancelled|failed -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="aurain" android:host="payment-success" />
            </intent-filter>
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="aurain" android:host="payment-cancelled" />
            </intent-filter>
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="aurain" android:host="payment-failed" />
            </intent-filter>
```

Leave the existing `<!-- Legacy deep links kept for compatibility -->` block and the `aura-in.app` https filter unchanged.

---

- [ ] **Step 4: Add `_logTag` getter + lifecycle logs to PaymentWebView**

Open `lib/payment/presentation/widgets/payment_webview.dart`. Inside the `_PaymentWebViewState` class, immediately after the existing field declarations (after `late final String _appSchemePrefix;` around line 50), add this getter:

```dart
  String get _logTag =>
      '[PW ref=${widget.reference.length >= 8 ? widget.reference.substring(0, 8) : widget.reference}]';
```

Then add an instrumentation line at the end of `initState`, AFTER the `_verifyTimer = Timer.periodic(...)` block (around line 96). Insert immediately before the closing `}` of `initState`:

```dart
    debugPrint(
      '$_logTag init provider=${widget.provider} url=${widget.url} '
      'scheme=$_appSchemePrefix dbPoll=${_config.dbPollInterval.inSeconds}s '
      'verifyEsc=${_config.verifyEscalationInterval.inSeconds}s',
    );
```

Add an instrumentation line at the START of `didChangeAppLifecycleState`, immediately after the `void didChangeAppLifecycleState(AppLifecycleState state) {` opening brace:

```dart
    debugPrint('$_logTag lifecycle state=$state isComplete=$_isComplete');
```

Add an instrumentation line at the START of `dispose`, immediately after the `void dispose() {` opening brace:

```dart
    debugPrint('$_logTag dispose isComplete=$_isComplete');
```

---

- [ ] **Step 5: Add WebView navigation callback logs**

Still in `lib/payment/presentation/widgets/payment_webview.dart`. Locate the `NavigationDelegate(...)` block inside `initState` (around lines 67-89).

Replace the four callbacks with the instrumented versions:

```dart
            NavigationDelegate(
              onPageStarted: (url) {
                debugPrint('$_logTag onPageStarted $url');
                setState(() => _isLoading = true);
              },
              onPageFinished: (url) {
                debugPrint('$_logTag onPageFinished $url → _startDbPolling()');
                setState(() => _isLoading = false);
                _startDbPolling();
              },
              onUrlChange: (change) {
                debugPrint('$_logTag onUrlChange ${change.url}');
                if (change.url == null) return;
                if (_isSuccessUrl(change.url!)) _handleSuccess();
                if (_isCancelUrl(change.url!)) _handleCancelled();
              },
              onNavigationRequest: (request) {
                if (request.url.toLowerCase().startsWith(_appSchemePrefix)) {
                  debugPrint(
                    '$_logTag onNavigationRequest ${request.url} → decision=prevent',
                  );
                  if (_isSuccessUrl(request.url)) {
                    _handleSuccess();
                  } else {
                    _handleCancelled();
                  }
                  return NavigationDecision.prevent;
                }
                debugPrint(
                  '$_logTag onNavigationRequest ${request.url} → decision=navigate',
                );
                return NavigationDecision.navigate;
              },
            ),
```

---

- [ ] **Step 6: Add poll + verify instrumentation**

Still in `lib/payment/presentation/widgets/payment_webview.dart`. Replace the `_startDbPolling` method (around lines 115-124) with:

```dart
  void _startDbPolling() {
    _dbPollTimer?.cancel();
    _dbPollTimer = Timer.periodic(_config.dbPollInterval, (_) {
      debugPrint('$_logTag dbPoll tick isComplete=$_isComplete');
      if (_isComplete) {
        _dbPollTimer?.cancel();
        return;
      }
      _checkBookingInDb();
    });
  }
```

Replace `_checkBookingInDb` (around lines 126-144) with:

```dart
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

      debugPrint(
        '$_logTag checkBookingInDb result=${result == null ? 'null' : 'found id=${result['id']}'}',
      );

      if (result != null) {
        _dbPollTimer?.cancel();
        _handleSuccess();
      }
    } catch (e) {
      debugPrint('$_logTag checkBookingInDb error=$e');
    }
  }
```

Replace `_verifyPaymentDirectly` (around lines 148-175) with:

```dart
  Future<void> _verifyPaymentDirectly() async {
    if (_isComplete || _isVerifying) return;
    _isVerifying = true;

    try {
      debugPrint(
        '🔍 ${_config.verifyPaymentFunctionName}: checking ${widget.reference}',
      );
      final response = await Supabase.instance.client.functions.invoke(
        _config.verifyPaymentFunctionName,
        body: {'reference': widget.reference, 'provider': widget.provider},
      );

      final data = response.data;
      debugPrint(
        '$_logTag verifyPayment result=${data is Map ? (data['success'] == true ? 'success' : 'not confirmed') : 'non-map'}',
      );
      if (data is Map<String, dynamic> && data['success'] == true) {
        debugPrint(
          '✅ ${_config.verifyPaymentFunctionName} confirmed — closing WebView',
        );
        _dbPollTimer?.cancel();
        _verifyTimer?.cancel();
        _handleSuccess();
      }
    } catch (e) {
      debugPrint('$_logTag verifyPayment error=$e');
    } finally {
      _isVerifying = false;
    }
  }
```

---

- [ ] **Step 7: Add outcome handler instrumentation**

Still in `lib/payment/presentation/widgets/payment_webview.dart`. Replace `_handleSuccess` and `_handleCancelled` (around lines 179-195) with:

```dart
  void _handleSuccess() {
    if (_isComplete) return;
    debugPrint('$_logTag _handleSuccess ENTRY');
    _isComplete = true;
    widget.onComplete(true);
    Future.delayed(const Duration(milliseconds: 300), () {
      debugPrint(
        '$_logTag _handleSuccess 300ms elapsed mounted=$mounted → popping',
      );
      if (mounted) {
        Navigator.pop(context);
        debugPrint('$_logTag _handleSuccess post-pop');
      }
    });
  }

  void _handleCancelled() {
    if (_isComplete) return;
    debugPrint('$_logTag _handleCancelled ENTRY');
    _isComplete = true;
    widget.onComplete(false);
    Future.delayed(const Duration(milliseconds: 300), () {
      debugPrint(
        '$_logTag _handleCancelled 300ms elapsed mounted=$mounted → popping',
      );
      if (mounted) {
        Navigator.pop(context);
        debugPrint('$_logTag _handleCancelled post-pop');
      }
    });
  }
```

---

- [ ] **Step 8: Run flutter analyze on touched Dart files**

```bash
flutter analyze lib/main.dart lib/payment/presentation/widgets/payment_webview.dart 2>&1 | head -30
```

Expected: 0 errors. Pre-existing project-wide warnings (e.g., `withOpacity` deprecation) are fine and may appear — those are not introduced by this change. Any NEW error from these files blocks the commit; fix it before proceeding.

---

- [ ] **Step 9: Run existing payment tests to confirm no regression**

```bash
flutter test test/payment/payment_controller_test.dart 2>&1 | tail -10
```

Expected: `All tests passed!` (9 tests). The controller test mocks the WebView via the injected `WebViewLauncher` typedef, so the actual `PaymentWebView` widget is never instantiated — these changes cannot affect it. This step is a sanity check that nothing imported from `payment_webview.dart` got broken.

---

- [ ] **Step 10: Commit**

```bash
git add lib/main.dart \
        ios/Runner/Info.plist \
        android/app/src/main/AndroidManifest.xml \
        lib/payment/presentation/widgets/payment_webview.dart

git commit -m "$(cat <<'EOF'
spec(21): payment webview iOS diagnostic — scheme rebrand + instrumentation

Diagnose-first commit for the iOS sim "WebView doesn't pop after success"
bug. Three real changes plus temporary observation:

- main.dart: appScheme nanoembryo → aurain (matches iOS Info.plist
  CFBundleURLTypes registration; iOS WKWebView can silently drop
  navigations to unregistered custom schemes before the delegate fires)
- AndroidManifest.xml: register aurain://payment-{success,cancelled,failed}
  intent filters alongside the existing aurain://login-callback
- Info.plist: verified aurain entry already present (no change)
- PaymentWebView: temporary [PW]-prefixed debugPrint at 13 lifecycle
  points so user can repro on iOS sim and identify whether the pop
  failure is in onPageFinished, dbPoll tick, _checkBookingInDb,
  _handleSuccess, or Navigator.pop. To be removed in follow-up
  Realtime+overlay PR.

Runbook for repro lives in
docs/superpowers/specs/2026-05-21-payment-webview-ios-diagnostic-design.md

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

Expected: commit succeeds. `git status` after should show a clean working tree (except for the unrelated pre-existing modified files visible at session start).

---

- [ ] **Step 11: Hand back to the user with runbook reminder**

Output to the user:

> Diagnostic instrumentation committed. To diagnose the iOS sim bug, follow the **Repro Runbook** section of `docs/superpowers/specs/2026-05-21-payment-webview-ios-diagnostic-design.md`:
>
> 1. `flutter run --flavor development -d "iPhone 15"` (or your sim)
> 2. Make a Paystack MoMo test payment; do NOT manually close the WebView
> 3. Copy the `[PW]`-prefixed log output from the terminal
> 4. Note whether the WebView popped and when
> 5. Check the Supabase dashboard `paystack-webhook` invocation log
> 6. Share back — we'll use those observations to seed the Realtime+overlay design

---

# Verification (after Task 1)

1. **`flutter analyze` clean** for `lib/main.dart` and `lib/payment/presentation/widgets/payment_webview.dart` (no NEW errors).
2. **Existing `payment_controller_test.dart` passes** unchanged (9 tests).
3. **`git log -1`** shows the single atomic commit with all four files included.
4. **Manual** (user runs): the Repro Runbook in the spec produces a `[PW]`-prefixed log dump that maps to one of the diagnosis branches in the spec's decision tree.

After ship, the diagnostic data seeds the next brainstorming session (Realtime + Confirming overlay). The temporary instrumentation gets removed in that follow-up PR.
