# Payment Engine

A drop-in payment, wallet, and withdrawal engine for any Flutter + Supabase
app. Supports **Paystack** (Africa) and **Stripe Connect** (global) behind a
single `PaymentConfig`. Mirrors the structure of the chat engine.

---

## What you get

- WebView checkout with deep-link callbacks, DB polling, and a verify-payment
  fallback for when the provider webhook is delayed or misconfigured.
- Per-shop wallet ledger (`wallets`, `wallet_transactions`).
- Withdrawal flow with idempotency, provider-side transfers, and audit logging.
- Subaccount / Stripe Connect onboarding.
- Defense-in-depth: input sanitization, rate limiting, JWT verification,
  redacted logs, atomic RPCs, retry-with-backoff on provider APIs.
- A single tuneable config — `PaymentConfig` — for currency, deposit %, fees,
  withdrawal bounds, polling cadence, function names, lifecycle hooks.

---

## Architecture (one screen)

```
┌──────────────────────────────────────────────────────────────────────┐
│                            FLUTTER APP                               │
│                                                                      │
│   ┌─────────────────────┐         ┌────────────────────────┐         │
│   │ paymentConfigProv.  │◄────────┤ Your ProviderScope     │         │
│   └──────────┬──────────┘         │  override              │         │
│              │                    └────────────────────────┘         │
│              ▼                                                       │
│   ┌─────────────────────┐         ┌────────────────────────┐         │
│   │ PaymentController   │────────►│ PaymentWebView         │         │
│   │ (StateNotifier)     │         │  - DB poll  (4 s)      │         │
│   └──────────┬──────────┘         │  - verify-payment(15s) │         │
│              │ supabase.functions │  - deep-link intercept │         │
│              │                    └────────────────────────┘         │
└──────────────┼───────────────────────────────────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                         SUPABASE EDGE FUNCTIONS                      │
│                                                                      │
│   create-booking       verify-payment       process-withdrawal       │
│   paystack-webhook     stripe-webhook                                │
│   paystack-subaccount  stripe-connect                                │
│         │                    │                       │               │
│         └────────────┬───────┴───────────┬───────────┘               │
│                      ▼                   ▼                           │
└──────────────────────┼───────────────────┼───────────────────────────┘
                       ▼                   ▼
              ┌────────────────┐  ┌──────────────────┐
              │   POSTGRES     │  │  Paystack / Stripe│
              │                │  │   provider APIs  │
              │  pending_pay…  │  └──────────────────┘
              │  bookings      │
              │  wallets       │
              │  wallet_txns   │
              │  withdrawals   │
              │  payment_set…  │
              │  payment_audit │
              └────────────────┘
```

---

## Payment provider port

All provider-specific HTTP calls live behind a single interface in
`supabase/functions/_shared/providers/port.ts`. Edge functions call:

```ts
const provider = getProvider(providerName);   // 'paystack' | 'stripe'
await provider.initCheckout({ ... });
```

Adding a new provider (Flutterwave, Razorpay, etc.) is a 3-step change:
1. Create `supabase/functions/_shared/providers/<name>_provider.ts` implementing `PaymentProviderPort`.
2. Add `<name>: () => new <Name>Provider()` to the `adapters` map in `registry.ts`.
3. Add `'<name>'` to the `PaymentProviderName` union in `port.ts`.

The port covers 4 ops: `initCheckout`, `verifyTransaction`, `processPayout`, `verifyWebhookSignature`.
Onboarding (subaccount / OAuth Connect) stays per-provider because the UX is fundamentally different.

---

## Drop into another app

### 1. Copy the module

```
lib/payment/                                     # whole folder
lib/wallet/                                      # whole folder
supabase/functions/_shared/                      # retry + sanitize + audit
supabase/functions/create-booking/
supabase/functions/verify-payment/
supabase/functions/paystack-webhook/
supabase/functions/stripe-webhook/
supabase/functions/process-withdrawal/
supabase/functions/paystack-subaccount/
supabase/functions/stripe-connect/
supabase/migrations/20260515000000_pending_payments.sql
supabase/migrations/20260516120000_payment_schema.sql
supabase/migrations/20260516130000_pending_payments_cleanup.sql
supabase/migrations/20260516140000_payment_audit_log.sql
```

### 2. Override `paymentConfigProvider` in your root `ProviderScope`

```dart
ProviderScope(
  overrides: [
    paymentConfigProvider.overrideWithValue(
      const PaymentConfig(
        appScheme: 'myapp',          // → myapp://payment-success
        brandName: 'MyApp',
        defaultCurrency: 'USD',
        depositFraction: 0.50,       // 50% upfront
        platformFeeFraction: 0.029,
        minWithdrawalAmount: 10,
        maxWithdrawalAmount: 10000,
        enabledProviders: {PaymentProvider.stripe},
      ),
    ),
  ],
  child: MyApp(),
)
```

The default override throws `UnimplementedError` to surface missing config
immediately — same pattern as `chat_config.dart`.

### 3. Apply migrations + deploy functions

```bash
supabase db push
supabase functions deploy create-booking verify-payment paystack-webhook \
  stripe-webhook process-withdrawal paystack-subaccount stripe-connect
```

### 4. Configure Supabase secrets

| Secret | Required for | Notes |
|---|---|---|
| `PAYSTACK_SECRET_KEY` | Paystack flows | From Paystack Dashboard → API Keys |
| `PAYSTACK_WEBHOOK_SECRET` | paystack-webhook | Must be set or function returns 500 |
| `STRIPE_SECRET_KEY` | Stripe flows | Optional if Stripe not enabled |
| `STRIPE_WEBHOOK_SECRET` | stripe-webhook | Must be set or function returns 500 |
| `INTERNAL_WEBHOOK_SECRET` | process-withdrawal | Used as Bearer token by DB webhook trigger |
| `PAYMENT_DEBUG_LOGS` | (optional) | Set to `true` to surface redacted request payloads in logs. Off in prod. |

### 5. Register provider webhook URLs

- **Paystack** → Dashboard → Settings → API Keys & Webhooks
  - URL: `https://<project-ref>.supabase.co/functions/v1/paystack-webhook`
- **Stripe** → Dashboard → Developers → Webhooks
  - URL: `https://<project-ref>.supabase.co/functions/v1/stripe-webhook`
  - Events: `checkout.session.completed`, `checkout.session.expired`,
    `account.updated`, `account.application.deauthorized`

### 6. (Optional) Schedule the cleanup cron

In Supabase → Database → Extensions, enable `pg_cron`. Then:

```sql
SELECT cron.schedule(
  'expire-stale-pending-payments',
  '* * * * *',
  $$SELECT public.expire_stale_pending_payments();$$
);
```

Without this, expired payment intents linger forever. The cleanup is also safe
to call from inside your webhook handlers as defense-in-depth.

---

## `PaymentConfig` reference

Every knob with its default. All optional except `appScheme`.

| Field | Default | Purpose |
|---|---|---|
| `appScheme` | (required) | Deep-link scheme — drives `appScheme://payment-success` etc. |
| `brandName` | `'App'` | Used in dialog copy / notifications |
| `createIntentFunctionName` | `'create-booking'` | Override if you renamed the function |
| `verifyPaymentFunctionName` | `'verify-payment'` | ↑ |
| `processWithdrawalFunctionName` | `'process-withdrawal'` | ↑ |
| `paystackSubaccountFunctionName` | `'paystack-subaccount'` | ↑ |
| `stripeConnectFunctionName` | `'stripe-connect'` | ↑ |
| `enabledProviders` | `{paystack, stripe}` | Restrict to e.g. `{stripe}` for non-African apps |
| `providerResolver` | African currency → paystack, else stripe | Provide your own to override |
| `defaultCurrency` | `'GHS'` | Fallback when shop currency is missing |
| `depositFraction` | `0.30` | Upfront deposit, 0–1 |
| `platformFeeFraction` | `0.029` | Platform fee, 0–1 |
| `minWithdrawalAmount` | `50` | In the shop's currency |
| `maxWithdrawalAmount` | `5000` | ↑ |
| `dbPollInterval` | `4 s` | How often the WebView polls the bookings table |
| `verifyEscalationInterval` | `15 s` | How often the WebView calls verify-payment as fallback |
| `dbConfirmAttemptsAfterWebViewSuccess` | `15` | DB poll attempts after WebView closes successfully |
| `dbConfirmAttemptsAfterWebViewCancel` | `8` | DB poll attempts after user cancellation |
| `dbConfirmInterval` | `3 s` | Delay between post-WebView polls |
| `pendingPaymentExpiry` | `30 min` | Server-side expiry for `pending_payments` |
| `providerApiRetries` | `3` | Retry attempts on Paystack/Stripe API |
| `providerApiRetryBaseDelay` | `500 ms` | Initial backoff (doubles per attempt) |
| `paymentSuccessBuilder` | `null` | Custom widget builder for success state |
| `paymentErrorBuilder` | `null` | Custom widget builder for error state |
| `onPaymentSuccess` | `null` | Hook fired after successful payment |
| `onPaymentFailure` | `null` | Hook fired with `PaymentErrorCategory` |

---

## Lifecycle hooks

`onPaymentSuccess` and `onPaymentFailure` receive structured info you can
branch on. Use them to navigate, log analytics, or surface custom UI without
forking the engine.

```dart
PaymentConfig(
  appScheme: 'myapp',
  onPaymentSuccess: (info) async {
    Analytics.track('payment.succeeded', {
      'reference': info.reference,
      'amount': info.amount,
      'currency': info.currency,
    });
  },
  onPaymentFailure: (info) async {
    if (info.category == PaymentErrorCategory.declined) {
      showRetryDialog();
    } else if (info.category == PaymentErrorCategory.network) {
      showOfflineHint();
    }
  },
)
```

`PaymentErrorCategory` is one of: `cancelled`, `declined`, `network`,
`validation`, `serverError`, `unknown`.

---

## Robustness story

| Failure mode | Mitigation |
|---|---|
| Provider webhook delayed / dropped | WebView escalates to `verify-payment` every 15 s; calls Paystack/Stripe verify API and creates the booking server-side if confirmed |
| Webhook URL misconfigured | Same fallback; user still sees success within 15 s |
| Provider API blip during checkout | `retryFetch` with 3 attempts, exponential backoff + jitter |
| Provider 500 during withdrawal | Same retry; Paystack idempotent on `reference`, Stripe idempotent via `Idempotency-Key` header |
| User pays then closes app | Lifecycle observer + DB poll restart on resume; verify-payment fires immediately on resume |
| Race: webhook + verify-payment both insert | Both code paths detect the unique-constraint race and return the existing booking |
| Slow networks | DB poll keeps trying for ~45 s; WebView won't pop until confirmed |
| Stale pending intents | `expire_stale_pending_payments()` RPC + pg_cron (optional) |
| Notification failure | Non-fatal — booking creation never rolls back due to notification errors |

---

## Security story

| Risk | Mitigation |
|---|---|
| Forged `userId` in `create-booking` | JWT extracted; mismatched `body.userId` → 403 |
| Forged webhook payload | HMAC verification required on both Paystack and Stripe |
| Client-tampered totals | Server recomputes; client-supplied provider ignored |
| SQL injection | Postgres parameterised queries throughout; `sanitizeIdentifier` for inputs that hit table names |
| XSS via free-text fields | `sanitizeText` strips HTML + control chars at edge |
| PII in logs | `redactForLog` + `PAYMENT_DEBUG_LOGS` gate; verbose logs off in prod |
| Rate-limit abuse | `pending_payments` count throttles create-booking; `payment_settings` count throttles subaccount creation |
| Withdrawal duplication | Date-scoped idempotency key + Paystack reference idempotency + Stripe `Idempotency-Key` |
| Unauthorized withdrawal trigger | `INTERNAL_WEBHOOK_SECRET` required on `process-withdrawal` |
| Audit gap | `payment_audit_log` table; `audit()` helper records subaccount + withdrawal events |
| RLS bypass | All payment tables RLS-enabled; reads gated to shop owner |

---

## Tests

```bash
# Flutter
flutter test test/payment/

# Deno (once installed)
deno test supabase/functions/_shared/
```

Coverage:
- `payment_config_test.dart` — config defaults, deep links, provider
  resolution, constructor asserts (18 tests).
- `retry.test.ts` — backoff cadence, retryable-classification, custom predicate.
- `sanitize.test.ts` — text/identifier/amount/currency rules, log redaction.

---

## Operational notes

- **Hot-reload won't pick up WebView changes.** The verify timer starts in
  `initState`. Full restart required.
- **Set `PAYMENT_DEBUG_LOGS=true` only when actively debugging.** Logs are
  redacted but verbose; off in prod keeps the edge-function log volume low.
- **Track `payment_audit_log` size.** Append-only; for high-volume apps add a
  periodic archival job (move > N days to cold storage).
- **`process-withdrawal` is internal-only.** The DB webhook trigger that calls
  it must include `Authorization: Bearer ${INTERNAL_WEBHOOK_SECRET}`. Browsers
  and user clients cannot trigger it.
