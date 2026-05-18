# PaymentProviderPort — Design Spec

**Date:** 2026-05-18
**Status:** Approved — ready for implementation planning
**Scope:** Phase 3, item 1 of the payment refactor (`PaymentProviderPort` abstraction + Flutter relocation to `lib/payment/`).

---

## Problem

Provider-specific payment logic (Paystack vs Stripe) is currently scattered across four Supabase edge functions with `if (provider === 'paystack') { ... } else { ... }` branching:

- `create-booking/index.ts` — checkout initialization
- `verify-payment/index.ts` — transaction verification
- `process-withdrawal/index.ts` — payout/transfer
- `paystack-webhook/index.ts`, `stripe-webhook/index.ts` — HMAC signature verification

Adding a third provider (Flutterwave for broader African coverage, Razorpay for India) would require touching every branching site. The payment module also lives under `lib/presentation/features/shops/payment/`, which incorrectly couples it to the shop feature even though it's intended to be a drop-in module for any payment-using app.

## Goals

1. A single `PaymentProviderPort` interface in `supabase/functions/_shared/providers/` so adding a new provider is a single adapter file plus a registry entry.
2. Edge functions stop branching on provider name; they call the port.
3. Normalized error model so the Flutter client gets stable error categories regardless of which provider failed.
4. Physical relocation of the payment module from `lib/presentation/features/shops/payment/` to `lib/payment/` (and `lib/wallet/`) to reflect its drop-in nature.

## Non-Goals

- Adding Flutterwave or Razorpay adapters (this work makes that easy; doing it is a separate phase).
- Abstracting onboarding flows (`paystack-subaccount`, `stripe-connect`) — their UX is fundamentally per-provider and forcing a common interface would degrade every adapter.
- Client-side abstraction (Flutter `PaymentProvider` interface) — the Flutter client uses WebView regardless of provider, so no per-provider branching exists client-side.
- Refactoring `payment_settings_repository` to be shop-agnostic — it stays shop-coupled with a documented limit.

---

## Locked Decisions

| # | Decision | Rationale |
|---|---|---|
| 1 | Abstraction lives in edge functions only | Branching pain is server-side; client uses WebView uniformly |
| 2 | Core 4-op port: `initCheckout`, `verifyTransaction`, `processPayout`, `verifyWebhookSignature` | Onboarding stays per-provider; common interface would force least-common-denominator UX |
| 3 | Typed `PaymentProviderError` hierarchy with `category`, `providerCode`, `providerRaw`, `retryable` | Minimal migration from current throw idiom; gives `retry.ts` a real signal instead of string matching |
| 4 | Strangler migration in order: webhook signature → verify → checkout → payout | Monotonically increasing money-at-risk; each cut independently shippable |

---

## Design

### Port interface

`supabase/functions/_shared/providers/port.ts`

```ts
export type PaymentProviderName = 'paystack' | 'stripe' | 'flutterwave' | 'razorpay';

export interface InitCheckoutInput {
  amount: number;            // major units (50.00, not 5000)
  currency: string;          // ISO 4217, uppercased
  reference: string;         // idempotency key
  customerEmail: string;
  callbackUrl: string;
  metadata?: Record<string, string>;
  destinationAccountId?: string;   // paystack subaccount or stripe account
  platformFeeAmount?: number;
}

export interface InitCheckoutResult {
  checkoutUrl: string;
  providerReference: string;
  expiresAt?: string;
}

export interface VerifyTransactionInput {
  reference: string;
}

export interface VerifyTransactionResult {
  status: 'success' | 'pending' | 'failed' | 'abandoned';
  amount: number;            // major units, what the customer actually paid
  currency: string;
  paidAt?: string;
  providerTransactionId: string;
}

export interface ProcessPayoutInput {
  amount: number;
  currency: string;
  destinationAccountId: string;
  reference: string;         // idempotency key
  reason?: string;
}

export interface ProcessPayoutResult {
  status: 'pending' | 'success' | 'failed';
  providerTransferId: string;
  estimatedArrival?: string;
}

export interface VerifyWebhookSignatureInput {
  rawBody: string;
  signatureHeader: string;
}

export interface PaymentProviderPort {
  readonly name: PaymentProviderName;
  initCheckout(input: InitCheckoutInput): Promise<InitCheckoutResult>;
  verifyTransaction(input: VerifyTransactionInput): Promise<VerifyTransactionResult>;
  processPayout(input: ProcessPayoutInput): Promise<ProcessPayoutResult>;
  verifyWebhookSignature(input: VerifyWebhookSignatureInput): boolean;
}

export type PaymentErrorCategory =
  | 'declined'
  | 'insufficient_funds'
  | 'invalid_request'
  | 'unavailable'
  | 'rate_limit'
  | 'unknown';

export class PaymentProviderError extends Error {
  constructor(
    message: string,
    readonly category: PaymentErrorCategory,
    readonly retryable: boolean,
    readonly providerCode?: string,
    readonly providerRaw?: unknown,
  ) {
    super(message);
    this.name = 'PaymentProviderError';
  }
}
```

**Design notes:**

- **Major units everywhere.** Adapters do their own minor-unit conversion (×100 for kobo/cents). Eliminates a class of off-by-100 bugs in the current code.
- **`reference` is the universal idempotency primitive.** Adapters forward it to provider-native idempotency: Paystack `reference` field, Stripe `Idempotency-Key` header.
- **No `createSubaccount` / `createConnectedAccount`** — onboarding stays per-provider.
- **Webhook signature verification is sync** — HMAC compare, no I/O.
- **`destinationAccountId` on both checkout and payout** — Stripe `transfer_data.destination` at checkout, Paystack `subaccount` split. Same semantic, same field.
- **`PaymentProviderError.retryable`** is set by the adapter, removing the need for `retry.ts` to guess from error messages.

### Registry

`supabase/functions/_shared/providers/registry.ts`

```ts
import type { PaymentProviderName, PaymentProviderPort } from "./port.ts";
import { PaystackProvider } from "./paystack_provider.ts";
import { StripeProvider } from "./stripe_provider.ts";

const adapters: Partial<Record<PaymentProviderName, () => PaymentProviderPort>> = {
  paystack: () => new PaystackProvider(),
  stripe:   () => new StripeProvider(),
};

export function getProvider(name: PaymentProviderName): PaymentProviderPort {
  const factory = adapters[name];
  if (!factory) {
    throw new Error(`Payment provider '${name}' is not configured`);
  }
  return factory();
}

export function isProviderEnabled(name: PaymentProviderName): boolean {
  return name in adapters;
}
```

**Design notes:**

- **Factory map, not singleton map.** Adapters construct lazily so importing `registry.ts` never crashes on missing env (e.g. Paystack-only deployment without `STRIPE_SECRET_KEY`).
- **Each adapter reads its own env in its constructor** and throws a clear "secret missing" error only when actually invoked.
- **Country-→-provider decision stays in `create-booking`.** The port is dumb about which provider to use; that's caller business logic.
- **Adding a provider = 3 lines:** new adapter file, registry entry, extend `PaymentProviderName` union.

### File layout

**Edge functions:**

```
supabase/functions/_shared/providers/
├── port.ts
├── registry.ts
├── paystack_provider.ts
├── stripe_provider.ts
├── port.test.ts
├── paystack_provider.test.ts
└── stripe_provider.test.ts
```

Adapters reuse existing `_shared/retry.ts`, `_shared/sanitize.ts`, `_shared/audit.ts` — no changes there.

**Flutter relocation:**

```
lib/payment/                        # was lib/presentation/features/shops/payment/
├── config/payment_config.dart
├── domain/exceptions.dart
├── data/
│   ├── models/                     # payment_settings, bank, subaccount result
│   └── repositories/payment_settings_repository.dart
├── services/country_detection_service.dart
└── presentation/
    ├── controllers/
    ├── screens/                    # connect_paystack, stripe_oauth_popup, payment_settings
    └── widgets/                    # payment_webview, fee_info_card, etc.

lib/wallet/                         # was lib/presentation/features/shops/wallet/
├── data/
├── providers/
└── presentation/
```

**Relocation strategy:**

- Top-level `lib/payment/` and `lib/wallet/` — same depth as `lib/core/`, signaling drop-in module status.
- Mechanical sweep: `grep -rln 'features/shops/payment'` → update imports → `flutter analyze` catches stragglers.
- Single relocation commit per module (one for `payment/`, one for `wallet/`).
- Known limit, documented: `payment_settings_repository` still queries the `shops` table. For non-shop apps you'd swap that one file.

---

## Migration Plan (Strangler)

Cut 0 (port + registry + error class + empty adapter skeletons) lands bundled with Cut 1 — the foundation is meaningless without a caller, so a separate PR would just churn review.

| # | Cut | Risk | Effort | Validation |
|---|---|---|---|---|
| 1 | Port + registry + error class + `verifyWebhookSignature` | low | ~1.5h | webhook replay works for both providers; adapter tests pass |
| 2 | `verifyTransaction` | low | ~1h | `verify-payment` resolves completed/failed/expired correctly |
| 3 | `initCheckout` | medium | ~2h | end-to-end booking → WebView → success for both providers; correct currency |
| 4 | `processPayout` | high | ~1h | withdrawal completes; idempotent on retry; audit log entries recorded |
| 5 | Flutter relocation (`lib/payment/`, `lib/wallet/`) | low | ~1h | `flutter analyze` clean; all features still build |

Each cut is a separate atomic commit. Halting between any two cuts leaves the system functional.

### Cut details

**Cut 1 — `verifyWebhookSignature`**
- New: `port.ts`, `registry.ts`, both adapter files with signature method only.
- Modified: `paystack-webhook/index.ts`, `stripe-webhook/index.ts` — swap inline crypto for `getProvider(name).verifyWebhookSignature(...)`.

**Cut 2 — `verifyTransaction`**
- Adapters: add `verifyTransaction`.
- Modified: `verify-payment/index.ts` — replace direct `retryFetch(PAYSTACK_BASE_URL/transaction/verify/...)` with `provider.verifyTransaction(...)`.

**Cut 3 — `initCheckout`**
- Adapters: add `initCheckout`.
- Modified: `create-booking/index.ts` — replace `if (provider === 'stripe') { ... } else { paystack init }` with `provider.initCheckout(...)`.
- Removed: inline `processPaystackPayment` / `processStripePayment` helpers in `create-booking`.

**Cut 4 — `processPayout`**
- Adapters: add `processPayout`.
- Modified: `process-withdrawal/index.ts` — replace `processPaystackWithdrawal` / `processStripeWithdrawal` with `provider.processPayout(...)`.

**Cut 5 — Flutter relocation** (independent, can land before or after the migration cuts)
- File moves: `lib/presentation/features/shops/payment/` → `lib/payment/`; same for `wallet/`.
- Import sweep across all consumers.
- Update `main.dart` import for `paymentConfigProvider` override.
- Update `PAYMENT_ENGINE.md` integration guide with new paths.

---

## Out of Scope

- Adapter implementations for Flutterwave or Razorpay.
- Refactoring `payment_settings_repository` to be shop-agnostic.
- Onboarding endpoint abstraction (`paystack-subaccount`, `stripe-connect`).
- Client-side `PaymentProvider` interface in Flutter.
- Adding `refund` or `listTransfers` operations to the port.

---

## Open Questions

None — all four design questions resolved during brainstorming.

## Risks

- **Adapter behavioral drift.** If Paystack and Stripe adapters interpret `InitCheckoutResult.checkoutUrl` differently (e.g., one returns a URL with a query string, one without), WebView deep-link handling could regress. *Mitigation:* per-adapter integration tests against recorded provider responses.
- **Error categorization wrong.** If an adapter maps a Stripe `card_declined` to `unknown` instead of `declined`, the Flutter UI shows the wrong message. *Mitigation:* adapter tests assert on `category` for known error codes.
- **`destinationAccountId` semantic mismatch.** Stripe `transfer_data.destination` expects `acct_…`; Paystack `subaccount` expects `ACCT_…`. Caller must pass the right one for the right provider. *Mitigation:* the caller already pulls from `payment_settings.stripe_account_id` or `payment_settings.paystack_subaccount_code` — type-safe at the call site.
