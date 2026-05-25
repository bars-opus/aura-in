# PaymentWebView iOS Diagnostic — Design Spec

**Date:** 2026-05-21
**Status:** Approved — ready for implementation planning
**Scope:** Diagnose why `PaymentWebView` does not auto-pop after a successful payment on the iOS simulator. Single throwaway commit: URL-scheme rebrand fix + temporary instrumentation + a runbook for repro.

---

## Problem

Users report that after entering their mobile-money PIN on the Paystack flow, returning to the app leaves them stuck on the Paystack "Approve on your phone" page even though the payment succeeded server-side. The user has reproduced this on the iOS simulator with hosted Supabase + real Paystack test webhook — meaning the `bookings` row *is* getting created, but the WebView never pops.

`PaymentWebView` ([lib/payment/presentation/widgets/payment_webview.dart](../../../lib/payment/presentation/widgets/payment_webview.dart)) already has three independent success-detection paths:
1. **URL-scheme detection** — `onNavigationRequest` watching for `nanoembryo://payment-success`
2. **DB polling** — `Timer.periodic(dbPollInterval)` querying `bookings` for the reference
3. **verify-payment escalation** — `Timer.periodic(verifyEscalationInterval)` calling the edge function

We don't currently know which of these is failing on iOS. Without that diagnosis, any "fix" (e.g., adding Supabase Realtime) is speculative.

## Goal

Produce enough observation data to identify the root cause of the iOS pop failure, with a high-confidence config fix bundled in.

## Non-Goals

- Supabase Realtime subscription (separate spec)
- "Confirming your payment…" overlay screen (separate spec)
- Edge function changes
- PaymentController changes
- Test additions
- Broader rebrand cleanup of `nanoembryo` references outside `PaymentConfig`
- Production logging (all instrumentation is `debugPrint`, no-op in release; all temporary)

---

## Diagnosis — what we already know

### URL-scheme mismatch (confirmed config bug)

| Surface | Current value | Should be |
|---|---|---|
| `lib/main.dart` `appScheme:` | `'nanoembryo'` | `'aurain'` |
| iOS `Info.plist` `CFBundleURLTypes` | `aurain` (already correct) | `aurain` |
| Android `AndroidManifest.xml` | `aurain://login-callback` + `nanoembryo://verify-email` | add `aurain://payment-success`, `aurain://payment-cancelled`, `aurain://payment-failed` |

The app was renamed from a legacy "nanoembryo" identity to `aura_in` (bundle `com.barsOpus.florence`). iOS Info.plist was updated to use `aurain://` (no underscore — URL schemes disallow it), but the Flutter code config was never updated, so the WebView is listening for a scheme that the OS doesn't know about. On iOS WKWebView, custom URL schemes that aren't OS-registered can be silently dropped before the navigation delegate fires — this is a strong candidate root cause for the pop failure but is **not yet confirmed**, hence the instrumentation.

### Backend confirmed live

Paystack webhook is configured at `https://kbmjwicdffpuowymkobo.supabase.co/functions/v1/paystack-webhook` — so on a successful test payment, `bookings.insert(...)` *does* execute server-side. The diagnostic test can verify the webhook fired via Supabase dashboard logs.

---

## Locked Decisions

| # | Decision | Rationale |
|---|---|---|
| 1 | Single commit, scoped to diagnosis + scheme rebrand | Smallest possible change that lets us observe. Doesn't pre-commit to a fix design. |
| 2 | URL scheme = `aurain` | Matches existing iOS Info.plist registration and Android `aurain://login-callback`. Minimum config churn. |
| 3 | Instrumentation is `debugPrint` only, all `[PW]`-prefixed, throwaway | No production-logger dependency. Easy to grep, easy to remove in the follow-up PR. |
| 4 | Runbook lives inside this spec | One place to point at; no separate doc to maintain. |
| 5 | Realtime + overlay design happens in a separate brainstorming session after diagnostic data is in | Avoids designing a fix on assumptions. |

---

## Design

### Change 1: Rebrand the app scheme in code

**`lib/main.dart`** — find the `paymentConfigProvider.overrideWithValue(...)` block, change:

```dart
appScheme: 'nanoembryo',
```

to:

```dart
appScheme: 'aurain',
```

That single field drives `PaymentConfig.successDeepLink` / `cancelDeepLink` / `failedDeepLink`, which in turn drive both the `successUrl` / `cancelUrl` sent to `create-booking` (and onward to Paystack as the `callback_url`) and the `_appSchemePrefix` the WebView uses to detect callbacks.

### Change 2: Verify iOS Info.plist (no-op expected)

**`ios/Runner/Info.plist`** — verify the existing `CFBundleURLTypes` array contains an entry with `CFBundleURLSchemes` = `["aurain"]`. If present, no change. If somehow missing, add:

```xml
<dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>aurain-payment</string>
    <key>CFBundleURLSchemes</key>
    <array>
        <string>aurain</string>
    </array>
</dict>
```

### Change 3: Add Android payment-callback intent filters

**`android/app/src/main/AndroidManifest.xml`** — alongside the existing `aurain://login-callback` intent filter, add three more:

```xml
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

These are required for Android's PendingIntent resolution if any flow ever hands the URL off to the OS; they're also defensive for the same in-WebView detection path on Android.

### Change 4: Temporary instrumentation in PaymentWebView

**`lib/payment/presentation/widgets/payment_webview.dart`** — add a helper at the top of `_PaymentWebViewState`:

```dart
String get _logTag => '[PW ref=${widget.reference.length >= 8 ? widget.reference.substring(0, 8) : widget.reference}]';
```

Then add `debugPrint` calls at the following points:

| Hook | Log message |
|---|---|
| `initState` (end) | `$_logTag init provider=${widget.provider} url=${widget.url} scheme=$_appSchemePrefix dbPoll=${_config.dbPollInterval.inSeconds}s verifyEsc=${_config.verifyEscalationInterval.inSeconds}s` |
| `dispose` | `$_logTag dispose isComplete=$_isComplete` |
| `didChangeAppLifecycleState` | `$_logTag lifecycle state=$state isComplete=$_isComplete` |
| `onPageStarted` | `$_logTag onPageStarted $url` |
| `onPageFinished` | `$_logTag onPageFinished $url → _startDbPolling()` |
| `onUrlChange` | `$_logTag onUrlChange ${change.url}` |
| `onNavigationRequest` (before return) | `$_logTag onNavigationRequest ${request.url} → decision=$decision` (where `$decision` is `'prevent'` or `'navigate'`) |
| `_dbPollTimer` callback (inside `Timer.periodic`) | `$_logTag dbPoll tick isComplete=$_isComplete` |
| `_checkBookingInDb` (after query) | `$_logTag checkBookingInDb result=${result == null ? 'null' : 'found id=${result['id']}'}` (and `error: $e` in catch) |
| `_verifyPaymentDirectly` (after invoke) | `$_logTag verifyPayment result=${data is Map ? data['success'] : 'non-map'}` (and `error: $e` in catch) |
| `_handleSuccess` entry | `$_logTag _handleSuccess ENTRY` |
| `_handleSuccess` post-delay | `$_logTag _handleSuccess 300ms elapsed mounted=$mounted → popping` and after pop `$_logTag _handleSuccess post-pop` |
| `_handleCancelled` (same shape as success) | `$_logTag _handleCancelled ENTRY` / `... post-pop` |

All `debugPrint` — no-op in release builds. All temporary; the follow-up PR removes them.

### Change 5: Repro runbook (this spec is also the runbook)

See the **Repro Runbook** section below.

---

## Repro Runbook

### Prerequisites
- iOS simulator booted (`iPhone 15` or similar)
- `flutter run --flavor development -d <sim>` in a terminal you can scroll
- Logged in as a test user on a shop with Paystack + MoMo configured
- A second window open to the Supabase dashboard, viewing **Logs → Edge Functions → `paystack-webhook`**

### Test steps
1. Navigate to a booking confirmation, tap pay.
2. The Paystack WebView opens. Pick **Mobile Money**, enter a Ghana test phone number.
3. Paystack will prompt: "Approve on your phone." Background the app (cmd-shift-H in the sim) to simulate going to the SMS / USSD app for PIN entry. In the simulator you can just leave the app backgrounded for ~15s — the Paystack sandbox auto-approves.
4. Return to the app. **Do NOT manually close the WebView.** Wait up to 60 seconds.
5. Note: did the WebView pop on its own? At roughly what time after returning?

### What to capture
1. **`[PW]` log dump** — copy the entire `flutter run` terminal output, or filter with `grep '\[PW'`.
2. **Wall-clock observation** — one sentence: "WebView popped after ~3s" / "WebView never popped, I closed it after 60s" / etc.
3. **Webhook log row** — from the Supabase dashboard, the `paystack-webhook` invocation around the test time: status code, timestamp.
4. **(Optional but high-value)** Run this in the SQL editor against your test booking:
   ```sql
   SELECT id, payment_intent_id, status, created_at
   FROM bookings
   WHERE created_at > now() - interval '5 minutes'
   ORDER BY created_at DESC LIMIT 5;
   ```
   Confirms the row exists and shows its `payment_intent_id` so we can cross-check against the WebView's `ref=` prefix in the logs.

### Decision tree the logs will answer

| Observation | Diagnosis |
|---|---|
| `onPageFinished` never fires after the Paystack page loads | Polling never starts. Likely WKWebView lifecycle / Paystack page never reports "finished". |
| `onPageFinished` fires but `dbPoll tick` never appears | `Timer.periodic` suspended (likely backgrounded — cross-check with `lifecycle state=paused`). |
| `dbPoll tick` fires but `checkBookingInDb result=null` repeatedly *while* webhook log shows success | Either RLS denies the read or `payment_intent_id` doesn't match. Compare the `ref=` prefix to the SQL row's `payment_intent_id`. |
| `_handleSuccess ENTRY` fires but `post-pop` never shows `mounted=true` | Navigator stack issue — the WebView's `BuildContext` was unmounted before the 300ms delay elapsed. |
| `onNavigationRequest` fires with `aurain://payment-success` and `decision=prevent` | URL detection works. Follow `_handleSuccess` from there. |
| `onNavigationRequest` never fires for the callback URL | Paystack redirected to an HTTP success page instead of the deep link, OR WKWebView swallowed the scheme before the delegate. |
| Webhook log shows no invocation around test time | Webhook never fired — backend issue, not WebView. (Unlikely given confirmed setup but rules it out.) |

---

## Out of scope (deferred to follow-up specs)

- **Supabase Realtime on `bookings` filtered by `payment_intent_id`** — independent detection channel with sub-second latency. Constraint already verified: `pending_payments` has RLS lockdown ([supabase/migrations/20260515000000_pending_payments.sql:32](../../../supabase/migrations/20260515000000_pending_payments.sql)), so the subscription must target `bookings` (user-readable).
- **"Confirming your payment…" overlay** — shown on lifecycle resume, manual close, or stalled verification. Gives visible feedback so users don't panic-close.
- **Push notifications on booking creation** — backstop for users who fully kill the app. Deferred until FCM setup (per project memory).
- **Production logging plumbing** (e.g., Sentry breadcrumbs for payment lifecycle).
- **Test coverage** — the existing `test/payment/payment_controller_test.dart` already exercises the controller's branches with mocks; iOS-specific WebView behavior isn't unit-testable.

## Risks

- **The URL-scheme rebrand changes the deep link Paystack sees** (`callback_url` is built from `successDeepLink`). Old in-flight `pending_payments` rows created before this deploy reference the `nanoembryo://` callback; if a user is mid-payment during deploy and Paystack redirects them to a callback that no longer matches the WebView's listener, detection falls through to polling/verify-payment. *Mitigation:* polling + verify still run, so the user is at most a few seconds slower, not stuck.
- **The instrumentation is verbose.** ~13 log lines per WebView lifecycle. Acceptable for diagnosis; this is the whole point. *Mitigation:* `debugPrint` is no-op in release builds; the follow-up PR removes the logs entirely.
- **The runbook depends on a working test environment.** If the user's Paystack test mode is misconfigured or the sandbox MoMo flow has changed, the repro won't yield useful data. *Mitigation:* the runbook tells the user to verify the webhook log row exists before drawing conclusions.

---

## Done criteria

1. Code changes (1, 2, 3, 4 above) committed in a single atomic commit.
2. `flutter analyze` clean for the touched files.
3. App boots on iOS simulator with no scheme-related warnings.
4. User runs the runbook on iOS sim and shares logs + observations back, which seed the next (Realtime + overlay) brainstorming session.
