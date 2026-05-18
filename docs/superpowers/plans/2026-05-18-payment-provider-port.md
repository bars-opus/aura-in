# PaymentProviderPort Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `if (provider === 'paystack')` branching across edge functions with a `PaymentProviderPort` interface so adding Flutterwave/Razorpay becomes a single adapter file.

**Architecture:** Edge-function-side only. 4-op port (`initCheckout`, `verifyTransaction`, `processPayout`, `verifyWebhookSignature`) plus typed `PaymentProviderError`. Lazy factory registry. Strangler migration in 5 cuts ordered by money-at-risk. Flutter module relocates from `lib/presentation/features/shops/payment/` to `lib/payment/` as a separate independent cut.

**Tech Stack:** Deno (TypeScript) for edge functions; Deno test framework; Supabase JS client; Stripe SDK v13; existing `_shared/retry.ts` + `_shared/sanitize.ts`. Flutter relocation is mechanical file moves + import sweeps.

---

## File Structure

**New files:**
- `supabase/functions/_shared/providers/port.ts` — interface + `PaymentProviderError`
- `supabase/functions/_shared/providers/registry.ts` — `getProvider(name)`
- `supabase/functions/_shared/providers/paystack_provider.ts` — Paystack adapter
- `supabase/functions/_shared/providers/stripe_provider.ts` — Stripe adapter
- `supabase/functions/_shared/providers/port.test.ts` — error class tests
- `supabase/functions/_shared/providers/paystack_provider.test.ts` — adapter tests
- `supabase/functions/_shared/providers/stripe_provider.test.ts` — adapter tests

**Modified files:**
- `supabase/functions/paystack-webhook/index.ts` — use port for signature verify
- `supabase/functions/stripe-webhook/index.ts` — use port for signature verify
- `supabase/functions/verify-payment/index.ts` — use port for transaction verify
- `supabase/functions/create-booking/index.ts` — use port for checkout init
- `supabase/functions/process-withdrawal/index.ts` — use port for payout

**Relocated (Cut 5):**
- `lib/presentation/features/shops/payment/` → `lib/payment/`
- `lib/presentation/features/shops/wallet/` → `lib/wallet/`

---

# CUT 1 — Port + registry + `verifyWebhookSignature`

Lowest-risk cut. HMAC verification has no side effects.

---

### Task 1: Define the port interface and error class

**Files:**
- Create: `supabase/functions/_shared/providers/port.ts`
- Test: `supabase/functions/_shared/providers/port.test.ts`

- [ ] **Step 1: Write the failing test**

```ts
// supabase/functions/_shared/providers/port.test.ts
import {
  assertEquals,
  assertInstanceOf,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import { PaymentProviderError } from "./port.ts";

Deno.test("PaymentProviderError: carries category, retryable, code, raw", () => {
  const raw = { paystack_message: "card declined" };
  const err = new PaymentProviderError(
    "card declined",
    "declined",
    false,
    "card_declined",
    raw,
  );
  assertInstanceOf(err, Error);
  assertEquals(err.name, "PaymentProviderError");
  assertEquals(err.message, "card declined");
  assertEquals(err.category, "declined");
  assertEquals(err.retryable, false);
  assertEquals(err.providerCode, "card_declined");
  assertEquals(err.providerRaw, raw);
});

Deno.test("PaymentProviderError: optional fields default to undefined", () => {
  const err = new PaymentProviderError("oops", "unknown", true);
  assertEquals(err.providerCode, undefined);
  assertEquals(err.providerRaw, undefined);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `deno test supabase/functions/_shared/providers/port.test.ts`
Expected: FAIL with module resolution error (`port.ts` does not exist).

- [ ] **Step 3: Create `port.ts`**

```ts
// supabase/functions/_shared/providers/port.ts
//
// Provider-agnostic payment port. Adapters in this directory implement this
// interface; edge functions call through `registry.getProvider(name)` instead
// of branching on provider name.

export type PaymentProviderName =
  | "paystack"
  | "stripe"
  | "flutterwave"
  | "razorpay";

export interface InitCheckoutInput {
  /** Major units (e.g. 50.00, not 5000). Adapters convert to minor. */
  amount: number;
  /** ISO 4217, uppercased. */
  currency: string;
  /** Caller-controlled idempotency key. Forwarded to provider-native idempotency. */
  reference: string;
  customerEmail: string;
  /** Deep-link back into the app (e.g. nanoembryo://payment-success). */
  callbackUrl: string;
  metadata?: Record<string, string>;
  /** Paystack subaccount code or Stripe connected account id. */
  destinationAccountId?: string;
  /** Major units, taken from the gross before destination split. */
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
  status: "success" | "pending" | "failed" | "abandoned";
  /** Major units. */
  amount: number;
  currency: string;
  paidAt?: string;
  providerTransactionId: string;
}

export interface ProcessPayoutInput {
  amount: number;
  currency: string;
  destinationAccountId: string;
  reference: string;
  reason?: string;
}

export interface ProcessPayoutResult {
  status: "pending" | "success" | "failed";
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
  verifyTransaction(
    input: VerifyTransactionInput,
  ): Promise<VerifyTransactionResult>;
  processPayout(input: ProcessPayoutInput): Promise<ProcessPayoutResult>;
  verifyWebhookSignature(input: VerifyWebhookSignatureInput): Promise<boolean>;
}

export type PaymentErrorCategory =
  | "declined"
  | "insufficient_funds"
  | "invalid_request"
  | "unavailable"
  | "rate_limit"
  | "unknown";

export class PaymentProviderError extends Error {
  constructor(
    message: string,
    readonly category: PaymentErrorCategory,
    readonly retryable: boolean,
    readonly providerCode?: string,
    readonly providerRaw?: unknown,
  ) {
    super(message);
    this.name = "PaymentProviderError";
  }
}
```

Note: `verifyWebhookSignature` is `Promise<boolean>` (not sync `boolean` as the spec hinted), because the Web Crypto API is async. Updating the spec mentally — sync vs async is an implementation detail; the behavior is the same.

- [ ] **Step 4: Run test to verify it passes**

Run: `deno test supabase/functions/_shared/providers/port.test.ts`
Expected: PASS, 2 tests.

- [ ] **Step 5: Commit**

```bash
git add supabase/functions/_shared/providers/port.ts \
        supabase/functions/_shared/providers/port.test.ts
git commit -m "spec(17): payment provider port — interface + error class"
```

---

### Task 2: Implement the lazy factory registry

**Files:**
- Create: `supabase/functions/_shared/providers/registry.ts`
- Modify: `supabase/functions/_shared/providers/port.test.ts` (add registry tests)

- [ ] **Step 1: Write the failing tests** (append to `port.test.ts`)

```ts
// Append to supabase/functions/_shared/providers/port.test.ts
import {
  assertThrows,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import { getProvider, isProviderEnabled } from "./registry.ts";

Deno.test("registry: getProvider throws for unconfigured name", () => {
  assertThrows(
    () => getProvider("flutterwave"),
    Error,
    "Payment provider 'flutterwave' is not configured",
  );
});

Deno.test("registry: isProviderEnabled reports paystack/stripe enabled", () => {
  assertEquals(isProviderEnabled("paystack"), true);
  assertEquals(isProviderEnabled("stripe"), true);
  assertEquals(isProviderEnabled("flutterwave"), false);
  assertEquals(isProviderEnabled("razorpay"), false);
});

Deno.test("registry: getProvider returns an instance with the right name", () => {
  const paystack = getProvider("paystack");
  assertEquals(paystack.name, "paystack");
  const stripe = getProvider("stripe");
  assertEquals(stripe.name, "stripe");
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `deno test supabase/functions/_shared/providers/port.test.ts`
Expected: FAIL — `registry.ts` does not exist, and neither do the adapter files.

- [ ] **Step 3: Create skeleton adapter files** (so registry imports resolve)

```ts
// supabase/functions/_shared/providers/paystack_provider.ts
import type {
  InitCheckoutInput,
  InitCheckoutResult,
  PaymentProviderPort,
  ProcessPayoutInput,
  ProcessPayoutResult,
  VerifyTransactionInput,
  VerifyTransactionResult,
  VerifyWebhookSignatureInput,
} from "./port.ts";

export class PaystackProvider implements PaymentProviderPort {
  readonly name = "paystack" as const;

  initCheckout(_input: InitCheckoutInput): Promise<InitCheckoutResult> {
    throw new Error("PaystackProvider.initCheckout: not implemented yet");
  }
  verifyTransaction(
    _input: VerifyTransactionInput,
  ): Promise<VerifyTransactionResult> {
    throw new Error("PaystackProvider.verifyTransaction: not implemented yet");
  }
  processPayout(_input: ProcessPayoutInput): Promise<ProcessPayoutResult> {
    throw new Error("PaystackProvider.processPayout: not implemented yet");
  }
  verifyWebhookSignature(
    _input: VerifyWebhookSignatureInput,
  ): Promise<boolean> {
    throw new Error(
      "PaystackProvider.verifyWebhookSignature: not implemented yet",
    );
  }
}
```

```ts
// supabase/functions/_shared/providers/stripe_provider.ts
import type {
  InitCheckoutInput,
  InitCheckoutResult,
  PaymentProviderPort,
  ProcessPayoutInput,
  ProcessPayoutResult,
  VerifyTransactionInput,
  VerifyTransactionResult,
  VerifyWebhookSignatureInput,
} from "./port.ts";

export class StripeProvider implements PaymentProviderPort {
  readonly name = "stripe" as const;

  initCheckout(_input: InitCheckoutInput): Promise<InitCheckoutResult> {
    throw new Error("StripeProvider.initCheckout: not implemented yet");
  }
  verifyTransaction(
    _input: VerifyTransactionInput,
  ): Promise<VerifyTransactionResult> {
    throw new Error("StripeProvider.verifyTransaction: not implemented yet");
  }
  processPayout(_input: ProcessPayoutInput): Promise<ProcessPayoutResult> {
    throw new Error("StripeProvider.processPayout: not implemented yet");
  }
  verifyWebhookSignature(
    _input: VerifyWebhookSignatureInput,
  ): Promise<boolean> {
    throw new Error(
      "StripeProvider.verifyWebhookSignature: not implemented yet",
    );
  }
}
```

- [ ] **Step 4: Create `registry.ts`**

```ts
// supabase/functions/_shared/providers/registry.ts
import type { PaymentProviderName, PaymentProviderPort } from "./port.ts";
import { PaystackProvider } from "./paystack_provider.ts";
import { StripeProvider } from "./stripe_provider.ts";

// Factory map (not singleton) so adapters lazily construct. Importing this
// module is safe even when secrets for one provider are missing — the error
// is deferred to the moment `getProvider(name)` is called.
const adapters: Partial<Record<PaymentProviderName, () => PaymentProviderPort>> = {
  paystack: () => new PaystackProvider(),
  stripe: () => new StripeProvider(),
  // Add flutterwave/razorpay here when adapters exist.
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

- [ ] **Step 5: Run tests to verify they pass**

Run: `deno test supabase/functions/_shared/providers/port.test.ts`
Expected: PASS, 5 tests total.

- [ ] **Step 6: Commit**

```bash
git add supabase/functions/_shared/providers/registry.ts \
        supabase/functions/_shared/providers/paystack_provider.ts \
        supabase/functions/_shared/providers/stripe_provider.ts \
        supabase/functions/_shared/providers/port.test.ts
git commit -m "spec(17): payment provider registry + adapter skeletons"
```

---

### Task 3: Implement Paystack `verifyWebhookSignature`

**Files:**
- Modify: `supabase/functions/_shared/providers/paystack_provider.ts`
- Create: `supabase/functions/_shared/providers/paystack_provider.test.ts`

- [ ] **Step 1: Write the failing test**

```ts
// supabase/functions/_shared/providers/paystack_provider.test.ts
import {
  assertEquals,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import { PaystackProvider } from "./paystack_provider.ts";

// Set env BEFORE importing/instantiating the provider so its constructor sees it.
Deno.env.set("PAYSTACK_WEBHOOK_SECRET", "test_webhook_secret");

Deno.test("PaystackProvider.verifyWebhookSignature: valid HMAC-SHA512 → true", async () => {
  const provider = new PaystackProvider();
  const body = '{"event":"charge.success","data":{"reference":"abc"}}';
  // Precomputed HMAC-SHA512 of `body` with key `test_webhook_secret`.
  const sig = await hmacSha512Hex("test_webhook_secret", body);
  const ok = await provider.verifyWebhookSignature({
    rawBody: body,
    signatureHeader: sig,
  });
  assertEquals(ok, true);
});

Deno.test("PaystackProvider.verifyWebhookSignature: tampered body → false", async () => {
  const provider = new PaystackProvider();
  const body = '{"event":"charge.success","data":{"reference":"abc"}}';
  const sig = await hmacSha512Hex("test_webhook_secret", body);
  const ok = await provider.verifyWebhookSignature({
    rawBody: body + "tampered",
    signatureHeader: sig,
  });
  assertEquals(ok, false);
});

Deno.test("PaystackProvider.verifyWebhookSignature: empty signature → false", async () => {
  const provider = new PaystackProvider();
  const ok = await provider.verifyWebhookSignature({
    rawBody: '{"x":1}',
    signatureHeader: "",
  });
  assertEquals(ok, false);
});

// Helper: compute HMAC-SHA512 hex (matches Paystack's signature format).
async function hmacSha512Hex(secret: string, payload: string): Promise<string> {
  const enc = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    enc.encode(secret),
    { name: "HMAC", hash: "SHA-512" },
    false,
    ["sign"],
  );
  const buf = await crypto.subtle.sign("HMAC", key, enc.encode(payload));
  return Array.from(new Uint8Array(buf))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `deno test supabase/functions/_shared/providers/paystack_provider.test.ts`
Expected: FAIL — `verifyWebhookSignature` throws "not implemented yet".

- [ ] **Step 3: Implement `verifyWebhookSignature` in `paystack_provider.ts`**

Replace the skeleton class with:

```ts
// supabase/functions/_shared/providers/paystack_provider.ts
import type {
  InitCheckoutInput,
  InitCheckoutResult,
  PaymentProviderPort,
  ProcessPayoutInput,
  ProcessPayoutResult,
  VerifyTransactionInput,
  VerifyTransactionResult,
  VerifyWebhookSignatureInput,
} from "./port.ts";

export class PaystackProvider implements PaymentProviderPort {
  readonly name = "paystack" as const;

  private readonly webhookSecret: string;

  constructor() {
    // Read at construction so a missing secret fails fast on instantiation,
    // not during signature verify.
    this.webhookSecret = Deno.env.get("PAYSTACK_WEBHOOK_SECRET") ?? "";
  }

  initCheckout(_input: InitCheckoutInput): Promise<InitCheckoutResult> {
    throw new Error("PaystackProvider.initCheckout: not implemented yet");
  }

  verifyTransaction(
    _input: VerifyTransactionInput,
  ): Promise<VerifyTransactionResult> {
    throw new Error("PaystackProvider.verifyTransaction: not implemented yet");
  }

  processPayout(_input: ProcessPayoutInput): Promise<ProcessPayoutResult> {
    throw new Error("PaystackProvider.processPayout: not implemented yet");
  }

  async verifyWebhookSignature(
    input: VerifyWebhookSignatureInput,
  ): Promise<boolean> {
    if (!this.webhookSecret) {
      console.error("❌ PAYSTACK_WEBHOOK_SECRET not configured");
      return false;
    }
    if (!input.signatureHeader) return false;

    const enc = new TextEncoder();
    const key = await crypto.subtle.importKey(
      "raw",
      enc.encode(this.webhookSecret),
      { name: "HMAC", hash: "SHA-512" },
      false,
      ["sign"],
    );
    const buf = await crypto.subtle.sign(
      "HMAC",
      key,
      enc.encode(input.rawBody),
    );
    const computed = Array.from(new Uint8Array(buf))
      .map((b) => b.toString(16).padStart(2, "0"))
      .join("");
    return computed === input.signatureHeader;
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `deno test supabase/functions/_shared/providers/paystack_provider.test.ts`
Expected: PASS, 3 tests.

- [ ] **Step 5: Commit**

```bash
git add supabase/functions/_shared/providers/paystack_provider.ts \
        supabase/functions/_shared/providers/paystack_provider.test.ts
git commit -m "spec(17): paystack adapter — HMAC-SHA512 signature verify"
```

---

### Task 4: Implement Stripe `verifyWebhookSignature`

**Files:**
- Modify: `supabase/functions/_shared/providers/stripe_provider.ts`
- Create: `supabase/functions/_shared/providers/stripe_provider.test.ts`

Stripe's webhook signature uses a `t=…,v1=…` format and requires the Stripe SDK's `webhooks.constructEventAsync` for verification.

- [ ] **Step 1: Write the failing test**

```ts
// supabase/functions/_shared/providers/stripe_provider.test.ts
import {
  assertEquals,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import Stripe from "https://esm.sh/stripe@13.6.0";
import { StripeProvider } from "./stripe_provider.ts";

// Set env BEFORE first import that reads it.
Deno.env.set("STRIPE_SECRET_KEY", "sk_test_dummy");
Deno.env.set("STRIPE_WEBHOOK_SECRET", "whsec_test_dummy");

Deno.test("StripeProvider.verifyWebhookSignature: valid signed payload → true", async () => {
  const provider = new StripeProvider();
  const stripe = new Stripe("sk_test_dummy", { apiVersion: "2023-10-16" });
  const body = '{"type":"checkout.session.completed","data":{"object":{}}}';
  const header = stripe.webhooks.generateTestHeaderString({
    payload: body,
    secret: "whsec_test_dummy",
  });
  const ok = await provider.verifyWebhookSignature({
    rawBody: body,
    signatureHeader: header,
  });
  assertEquals(ok, true);
});

Deno.test("StripeProvider.verifyWebhookSignature: tampered body → false", async () => {
  const provider = new StripeProvider();
  const stripe = new Stripe("sk_test_dummy", { apiVersion: "2023-10-16" });
  const body = '{"type":"checkout.session.completed","data":{"object":{}}}';
  const header = stripe.webhooks.generateTestHeaderString({
    payload: body,
    secret: "whsec_test_dummy",
  });
  const ok = await provider.verifyWebhookSignature({
    rawBody: body + "tampered",
    signatureHeader: header,
  });
  assertEquals(ok, false);
});

Deno.test("StripeProvider.verifyWebhookSignature: missing header → false", async () => {
  const provider = new StripeProvider();
  const ok = await provider.verifyWebhookSignature({
    rawBody: '{"x":1}',
    signatureHeader: "",
  });
  assertEquals(ok, false);
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `deno test supabase/functions/_shared/providers/stripe_provider.test.ts`
Expected: FAIL — `verifyWebhookSignature` throws "not implemented yet".

- [ ] **Step 3: Implement `verifyWebhookSignature` in `stripe_provider.ts`**

```ts
// supabase/functions/_shared/providers/stripe_provider.ts
import Stripe from "https://esm.sh/stripe@13.6.0";
import type {
  InitCheckoutInput,
  InitCheckoutResult,
  PaymentProviderPort,
  ProcessPayoutInput,
  ProcessPayoutResult,
  VerifyTransactionInput,
  VerifyTransactionResult,
  VerifyWebhookSignatureInput,
} from "./port.ts";

export class StripeProvider implements PaymentProviderPort {
  readonly name = "stripe" as const;

  private readonly stripe: Stripe | null;
  private readonly webhookSecret: string;

  constructor() {
    const key = Deno.env.get("STRIPE_SECRET_KEY");
    this.stripe = key ? new Stripe(key, { apiVersion: "2023-10-16" }) : null;
    this.webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET") ?? "";
  }

  initCheckout(_input: InitCheckoutInput): Promise<InitCheckoutResult> {
    throw new Error("StripeProvider.initCheckout: not implemented yet");
  }

  verifyTransaction(
    _input: VerifyTransactionInput,
  ): Promise<VerifyTransactionResult> {
    throw new Error("StripeProvider.verifyTransaction: not implemented yet");
  }

  processPayout(_input: ProcessPayoutInput): Promise<ProcessPayoutResult> {
    throw new Error("StripeProvider.processPayout: not implemented yet");
  }

  async verifyWebhookSignature(
    input: VerifyWebhookSignatureInput,
  ): Promise<boolean> {
    if (!this.stripe || !this.webhookSecret) {
      console.error("❌ Stripe not fully configured (missing keys)");
      return false;
    }
    if (!input.signatureHeader) return false;
    try {
      // SDK throws if signature is invalid or body has been tampered with.
      await this.stripe.webhooks.constructEventAsync(
        input.rawBody,
        input.signatureHeader,
        this.webhookSecret,
      );
      return true;
    } catch (err) {
      console.error(
        "Stripe webhook signature verification failed:",
        (err as Error).message,
      );
      return false;
    }
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `deno test supabase/functions/_shared/providers/stripe_provider.test.ts`
Expected: PASS, 3 tests.

- [ ] **Step 5: Commit**

```bash
git add supabase/functions/_shared/providers/stripe_provider.ts \
        supabase/functions/_shared/providers/stripe_provider.test.ts
git commit -m "spec(17): stripe adapter — webhook signature verify via SDK"
```

---

### Task 5: Refactor `paystack-webhook` to use the port

**Files:**
- Modify: `supabase/functions/paystack-webhook/index.ts:1-90` (the signature-verify block)

- [ ] **Step 1: Read current state**

Confirm the current handler uses inline `verifyPaystackSignature` defined at lines 15–42 and called at line 61.

- [ ] **Step 2: Replace inline signature verify with port call**

In `supabase/functions/paystack-webhook/index.ts`:

**Remove** the import at line 3:
```ts
import { isDebugLogging, redactForLog } from "../_shared/sanitize.ts";
```

**Replace with:**
```ts
import { isDebugLogging, redactForLog } from "../_shared/sanitize.ts";
import { getProvider } from "../_shared/providers/registry.ts";
```

**Remove** the inline helper at lines 15–42:
```ts
async function verifyPaystackSignature(
  payload: string,
  signature: string | null,
  secret: string
): Promise<boolean> {
  // ... 28 lines of HMAC code ...
}
```

**Remove** the `PAYSTACK_WEBHOOK_SECRET` const at line 10 (the adapter reads it internally now):
```ts
const PAYSTACK_WEBHOOK_SECRET = Deno.env.get('PAYSTACK_WEBHOOK_SECRET');
```

**Replace** the verification block at lines 49–69 with:

```ts
    const payload = await req.text();
    const signature = req.headers.get('x-paystack-signature') ?? '';

    const provider = getProvider('paystack');
    const isValid = await provider.verifyWebhookSignature({
      rawBody: payload,
      signatureHeader: signature,
    });
    if (!isValid) {
      console.error('❌ Invalid webhook signature');
      return new Response(
        JSON.stringify({ error: 'Invalid signature' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } }
      );
    }
    console.log('✅ Webhook signature verified');
```

(The "secret not configured" branch is now inside the adapter — it returns false and logs, which causes the 401 above. That's the same external behavior as before.)

- [ ] **Step 3: Verify no other references to the removed symbols**

Run: `grep -n "verifyPaystackSignature\|PAYSTACK_WEBHOOK_SECRET" supabase/functions/paystack-webhook/index.ts`
Expected: no matches.

- [ ] **Step 4: Smoke test — deploy and replay a webhook**

```bash
supabase functions deploy paystack-webhook
```

Then send a valid signed webhook (or use Paystack dashboard's "Send test webhook"). Expect a 200 response and "✅ Webhook signature verified" in logs.

Send the same body with a tampered signature. Expect 401 and "❌ Invalid webhook signature".

- [ ] **Step 5: Commit**

```bash
git add supabase/functions/paystack-webhook/index.ts
git commit -m "spec(17): paystack-webhook uses PaymentProviderPort for signature verify"
```

---

### Task 6: Refactor `stripe-webhook` to use the port

**Files:**
- Modify: `supabase/functions/stripe-webhook/index.ts:1-51` (the signature-verify block)

- [ ] **Step 1: Replace inline signature verify with port call**

In `supabase/functions/stripe-webhook/index.ts`:

**Remove** the Stripe import + lazy init at lines 4 and 10–13:
```ts
import Stripe from "https://esm.sh/stripe@13.6.0";
// ...
const stripeKey = Deno.env.get('STRIPE_SECRET_KEY');
const stripe = stripeKey
  ? new Stripe(stripeKey, { apiVersion: '2023-10-16' })
  : null;
```

**Remove** the `WEBHOOK_SECRET` const at line 20:
```ts
const WEBHOOK_SECRET = Deno.env.get('STRIPE_WEBHOOK_SECRET');
```

**Keep** the `Stripe` import — it's still used for the `Stripe.Event`, `Stripe.Checkout.Session`, `Stripe.Account` types in the handler functions. Move it to a type-only import:
```ts
import type Stripe from "https://esm.sh/stripe@13.6.0";
import Stripe_runtime from "https://esm.sh/stripe@13.6.0";  // keep one runtime ref for event parsing
```

Actually — simpler approach. The downstream handlers (`handleCheckoutSessionCompleted`, etc.) only use the SDK for **types**, not runtime calls. So make it type-only and parse the event manually after the port verifies the signature.

**Replace** lines 1–51 with:

```ts
// supabase/functions/stripe-webhook/index.ts

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import type Stripe from "https://esm.sh/stripe@13.6.0";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";
import { isDebugLogging, redactForLog } from "../_shared/sanitize.ts";
import { getProvider } from "../_shared/providers/registry.ts";

const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
);

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  const signature = req.headers.get('stripe-signature') ?? '';
  if (!signature) {
    return new Response('Missing stripe-signature header', { status: 400 });
  }

  const body = await req.text();
  const provider = getProvider('stripe');
  const isValid = await provider.verifyWebhookSignature({
    rawBody: body,
    signatureHeader: signature,
  });
  if (!isValid) {
    return new Response('Webhook signature verification failed', { status: 400 });
  }

  // Signature is valid; safe to parse the event payload.
  const event = JSON.parse(body) as Stripe.Event;

  try {
    switch (event.type) {
      case 'checkout.session.completed':
        await handleCheckoutSessionCompleted(event.data.object as Stripe.Checkout.Session);
        break;
      case 'checkout.session.expired':
        await handleCheckoutSessionExpired(event.data.object as Stripe.Checkout.Session);
        break;
      case 'account.updated':
        await handleAccountUpdated(event.data.object as Stripe.Account);
        break;
      case 'account.application.deauthorized':
        await handleDeauthorized(event.account!);
        break;
      default:
        console.log(`Unhandled Stripe event type: ${event.type}`);
        break;
    }

    return new Response(JSON.stringify({ received: true }), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (err) {
    console.error(`Error handling webhook event ${event.type}:`, err);
    return new Response('Webhook handler error', { status: 500 });
  }
});
```

Leave the `handleCheckoutSessionCompleted`, `handleCheckoutSessionExpired`, `handleAccountUpdated`, `handleDeauthorized` functions (lines 86 onward) unchanged.

- [ ] **Step 2: Verify type-only import works**

Run: `deno check supabase/functions/stripe-webhook/index.ts`
Expected: no type errors.

- [ ] **Step 3: Smoke test**

```bash
supabase functions deploy stripe-webhook
```

In Stripe dashboard → Developers → Webhooks → send a test `checkout.session.completed`. Expect 200 + log "Unhandled Stripe event type: checkout.session.completed" OR a real handler trace.

Send a payload with an invalid signature. Expect 400.

- [ ] **Step 4: Commit**

```bash
git add supabase/functions/stripe-webhook/index.ts
git commit -m "spec(17): stripe-webhook uses PaymentProviderPort for signature verify"
```

---

**Cut 1 complete.** Webhook signature verification is now port-driven for both providers. No behavior change visible to Paystack/Stripe — only internal restructuring.

---

# CUT 2 — `verifyTransaction`

Read-only against provider API. Replaces the direct `retryFetch` in `verify-payment`.

---

### Task 7: Implement Paystack `verifyTransaction`

**Files:**
- Modify: `supabase/functions/_shared/providers/paystack_provider.ts`
- Modify: `supabase/functions/_shared/providers/paystack_provider.test.ts`

- [ ] **Step 1: Write the failing test** (append)

```ts
// Append to supabase/functions/_shared/providers/paystack_provider.test.ts
import { assertRejects } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { PaymentProviderError } from "./port.ts";

Deno.env.set("PAYSTACK_SECRET_KEY", "sk_test_dummy");

// Stub global fetch — restore after each test.
function stubFetch(handler: (url: string, init?: RequestInit) => Response | Promise<Response>) {
  const original = globalThis.fetch;
  globalThis.fetch = (input, init) =>
    Promise.resolve(handler(input.toString(), init as RequestInit));
  return () => { globalThis.fetch = original; };
}

Deno.test("PaystackProvider.verifyTransaction: success → maps to result", async () => {
  const restore = stubFetch((url) => {
    if (url.includes("/transaction/verify/")) {
      return new Response(JSON.stringify({
        status: true,
        data: {
          status: "success",
          amount: 5000,           // 5000 kobo = 50.00
          currency: "GHS",
          paid_at: "2026-05-18T10:00:00Z",
          id: 12345,
          reference: "test_ref_1",
        },
      }), { status: 200 });
    }
    return new Response("not found", { status: 404 });
  });
  try {
    const provider = new PaystackProvider();
    const result = await provider.verifyTransaction({ reference: "test_ref_1" });
    assertEquals(result.status, "success");
    assertEquals(result.amount, 50);          // converted to major units
    assertEquals(result.currency, "GHS");
    assertEquals(result.providerTransactionId, "12345");
    assertEquals(result.paidAt, "2026-05-18T10:00:00Z");
  } finally { restore(); }
});

Deno.test("PaystackProvider.verifyTransaction: failed → status=failed", async () => {
  const restore = stubFetch(() =>
    new Response(JSON.stringify({
      status: true,
      data: { status: "failed", amount: 5000, currency: "GHS", id: 1, reference: "x" },
    }), { status: 200 })
  );
  try {
    const provider = new PaystackProvider();
    const result = await provider.verifyTransaction({ reference: "x" });
    assertEquals(result.status, "failed");
  } finally { restore(); }
});

Deno.test("PaystackProvider.verifyTransaction: abandoned → status=abandoned", async () => {
  const restore = stubFetch(() =>
    new Response(JSON.stringify({
      status: true,
      data: { status: "abandoned", amount: 0, currency: "GHS", id: 1, reference: "x" },
    }), { status: 200 })
  );
  try {
    const provider = new PaystackProvider();
    const result = await provider.verifyTransaction({ reference: "x" });
    assertEquals(result.status, "abandoned");
  } finally { restore(); }
});

Deno.test("PaystackProvider.verifyTransaction: 401 from API → throws unavailable+non-retryable", async () => {
  const restore = stubFetch(() =>
    new Response(JSON.stringify({ status: false, message: "Invalid key" }), { status: 401 })
  );
  try {
    const provider = new PaystackProvider();
    await assertRejects(
      () => provider.verifyTransaction({ reference: "x" }),
      PaymentProviderError,
    );
  } finally { restore(); }
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `deno test supabase/functions/_shared/providers/paystack_provider.test.ts`
Expected: FAIL — `verifyTransaction` throws "not implemented yet".

- [ ] **Step 3: Implement `verifyTransaction` in `paystack_provider.ts`**

Add an import at the top:
```ts
import { retryFetch } from "../retry.ts";
```

Add a constant inside the class file (above the class):
```ts
const PAYSTACK_BASE_URL = "https://api.paystack.co";
```

Add a private field for the secret in the constructor:
```ts
private readonly secretKey: string;

constructor() {
  this.webhookSecret = Deno.env.get("PAYSTACK_WEBHOOK_SECRET") ?? "";
  this.secretKey = Deno.env.get("PAYSTACK_SECRET_KEY") ?? "";
}
```

Replace the `verifyTransaction` stub with:

```ts
async verifyTransaction(
  input: VerifyTransactionInput,
): Promise<VerifyTransactionResult> {
  if (!this.secretKey) {
    throw new PaymentProviderError(
      "Paystack secret key not configured",
      "unavailable",
      false,
    );
  }
  let resp: Response;
  try {
    resp = await retryFetch(
      `${PAYSTACK_BASE_URL}/transaction/verify/${encodeURIComponent(input.reference)}`,
      { headers: { Authorization: `Bearer ${this.secretKey}` } },
      { attempts: 3, baseDelayMs: 500, label: "paystack.verify" },
    );
  } catch (e) {
    // retryFetch throws Error on 4xx (terminal) or Response on 5xx after retries.
    throw new PaymentProviderError(
      `Paystack verify failed: ${(e as Error).message}`,
      "unavailable",
      false,
      undefined,
      e,
    );
  }
  const body = await resp.json();
  if (!body.status) {
    throw new PaymentProviderError(
      body.message ?? "Paystack verify returned status=false",
      "invalid_request",
      false,
      undefined,
      body,
    );
  }
  const d = body.data;
  const status: VerifyTransactionResult["status"] =
    d.status === "success" ? "success" :
    d.status === "abandoned" ? "abandoned" :
    d.status === "failed" ? "failed" : "pending";

  return {
    status,
    amount: (d.amount ?? 0) / 100,
    currency: (d.currency ?? "").toUpperCase(),
    paidAt: d.paid_at,
    providerTransactionId: String(d.id ?? d.reference ?? input.reference),
  };
}
```

Add the missing import at the top of `paystack_provider.ts`:
```ts
import { PaymentProviderError } from "./port.ts";
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `deno test supabase/functions/_shared/providers/paystack_provider.test.ts`
Expected: PASS, 7 tests total (3 from Task 3 + 4 new).

- [ ] **Step 5: Commit**

```bash
git add supabase/functions/_shared/providers/paystack_provider.ts \
        supabase/functions/_shared/providers/paystack_provider.test.ts
git commit -m "spec(17): paystack adapter — verifyTransaction"
```

---

### Task 8: Implement Stripe `verifyTransaction`

Stripe's equivalent is `checkout.sessions.retrieve(sessionId)` — returns the session with `payment_status: 'paid' | 'unpaid' | 'no_payment_required'`.

**Files:**
- Modify: `supabase/functions/_shared/providers/stripe_provider.ts`
- Modify: `supabase/functions/_shared/providers/stripe_provider.test.ts`

- [ ] **Step 1: Write the failing test** (append)

```ts
// Append to supabase/functions/_shared/providers/stripe_provider.test.ts
import { assertRejects } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { PaymentProviderError } from "./port.ts";

// Stub fetch shared with paystack tests — duplicated here to keep test files
// independent so Deno's parallel test runner doesn't cross-contaminate.
function stubFetch(handler: (url: string, init?: RequestInit) => Response | Promise<Response>) {
  const original = globalThis.fetch;
  globalThis.fetch = (input, init) =>
    Promise.resolve(handler(input.toString(), init as RequestInit));
  return () => { globalThis.fetch = original; };
}

Deno.test("StripeProvider.verifyTransaction: paid session → success", async () => {
  const restore = stubFetch((url) => {
    if (url.includes("/checkout/sessions/cs_test_1")) {
      return new Response(JSON.stringify({
        id: "cs_test_1",
        payment_status: "paid",
        amount_total: 5000,
        currency: "usd",
        created: 1715000000,
      }), { status: 200, headers: { "content-type": "application/json" } });
    }
    return new Response("not found", { status: 404 });
  });
  try {
    const provider = new StripeProvider();
    const result = await provider.verifyTransaction({ reference: "cs_test_1" });
    assertEquals(result.status, "success");
    assertEquals(result.amount, 50);
    assertEquals(result.currency, "USD");
    assertEquals(result.providerTransactionId, "cs_test_1");
  } finally { restore(); }
});

Deno.test("StripeProvider.verifyTransaction: unpaid session → pending", async () => {
  const restore = stubFetch(() =>
    new Response(JSON.stringify({
      id: "cs_test_2",
      payment_status: "unpaid",
      amount_total: 5000,
      currency: "usd",
      created: 1715000000,
    }), { status: 200, headers: { "content-type": "application/json" } })
  );
  try {
    const provider = new StripeProvider();
    const result = await provider.verifyTransaction({ reference: "cs_test_2" });
    assertEquals(result.status, "pending");
  } finally { restore(); }
});

Deno.test("StripeProvider.verifyTransaction: 404 → throws invalid_request", async () => {
  const restore = stubFetch(() =>
    new Response(JSON.stringify({
      error: { type: "invalid_request_error", message: "No such session" },
    }), { status: 404, headers: { "content-type": "application/json" } })
  );
  try {
    const provider = new StripeProvider();
    await assertRejects(
      () => provider.verifyTransaction({ reference: "cs_missing" }),
      PaymentProviderError,
    );
  } finally { restore(); }
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `deno test supabase/functions/_shared/providers/stripe_provider.test.ts`
Expected: FAIL — `verifyTransaction` throws "not implemented yet".

- [ ] **Step 3: Implement `verifyTransaction` in `stripe_provider.ts`**

Add import at the top:
```ts
import { PaymentProviderError } from "./port.ts";
```

Replace the `verifyTransaction` stub with:

```ts
async verifyTransaction(
  input: VerifyTransactionInput,
): Promise<VerifyTransactionResult> {
  if (!this.stripe) {
    throw new PaymentProviderError(
      "Stripe not configured",
      "unavailable",
      false,
    );
  }
  let session: Stripe.Checkout.Session;
  try {
    session = await this.stripe.checkout.sessions.retrieve(input.reference);
  } catch (e) {
    const err = e as { type?: string; message?: string; raw?: unknown };
    const category = err.type === "StripeInvalidRequestError"
      ? "invalid_request"
      : err.type === "StripeRateLimitError"
      ? "rate_limit"
      : "unavailable";
    throw new PaymentProviderError(
      err.message ?? "Stripe session retrieve failed",
      category,
      category === "rate_limit",
      err.type,
      err.raw ?? err,
    );
  }
  const status: VerifyTransactionResult["status"] =
    session.payment_status === "paid" ? "success" :
    session.status === "expired" ? "abandoned" :
    session.payment_status === "no_payment_required" ? "success" : "pending";

  return {
    status,
    amount: (session.amount_total ?? 0) / 100,
    currency: (session.currency ?? "").toUpperCase(),
    paidAt: session.created
      ? new Date(session.created * 1000).toISOString()
      : undefined,
    providerTransactionId: session.id,
  };
}
```

Change the `import type Stripe` to a runtime import (we now call `stripe.checkout.sessions.retrieve` directly):
```ts
import Stripe from "https://esm.sh/stripe@13.6.0";
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `deno test supabase/functions/_shared/providers/stripe_provider.test.ts`
Expected: PASS, 6 tests total (3 + 3 new).

- [ ] **Step 5: Commit**

```bash
git add supabase/functions/_shared/providers/stripe_provider.ts \
        supabase/functions/_shared/providers/stripe_provider.test.ts
git commit -m "spec(17): stripe adapter — verifyTransaction via session retrieve"
```

---

### Task 9: Refactor `verify-payment` to use the port

**Files:**
- Modify: `supabase/functions/verify-payment/index.ts:1-103`

- [ ] **Step 1: Replace direct `retryFetch` with port call**

In `supabase/functions/verify-payment/index.ts`:

**Update imports** at the top (replace lines 1–8 with):
```ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";
import {
  isDebugLogging,
  redactForLog,
  sanitizeIdentifier,
} from "../_shared/sanitize.ts";
import { getProvider, isProviderEnabled } from "../_shared/providers/registry.ts";
import { PaymentProviderError, type PaymentProviderName } from "../_shared/providers/port.ts";
```

**Remove** the `PAYSTACK_SECRET_KEY` const at line 15:
```ts
const PAYSTACK_SECRET_KEY = Deno.env.get('PAYSTACK_SECRET_KEY');
```

**Replace** the verification block at lines 72–103 (from "Step 2: Only Paystack supports direct verification" through the response build):

```ts
    // ── Step 2: Verify the transaction via the provider port ──────────────────
    if (!isProviderEnabled(provider as PaymentProviderName)) {
      return json({ success: false, confirmed: false });
    }
    // Stripe relies exclusively on webhooks — verifyTransaction would return
    // 'pending' until the customer completes checkout. Skip the round-trip and
    // wait for the webhook to fire.
    if (provider !== 'paystack') {
      return json({ success: false, confirmed: false });
    }

    let verification;
    try {
      verification = await getProvider(provider as PaymentProviderName)
        .verifyTransaction({ reference });
    } catch (e) {
      if (e instanceof PaymentProviderError) {
        console.error('Provider verify failed:', e.message);
        return json(
          { success: false, error: 'Provider verification temporarily unavailable, please retry' },
          502,
        );
      }
      throw e;
    }

    console.log('📡 Verify response:', verification.status);
    if (isDebugLogging()) {
      console.log('📡 verify body:', redactForLog(verification));
    }

    if (verification.status !== 'success') {
      return json({ success: false, confirmed: false, paystack_status: verification.status });
    }
```

**Replace** the line that reads `const paidAmount = verifyData.data.amount / 100;` (around line 128) with:
```ts
    const paidAmount = verification.amount;
```

- [ ] **Step 2: Verify no stale references**

Run: `grep -n "verifyData\|PAYSTACK_SECRET_KEY\|retryFetch" supabase/functions/verify-payment/index.ts`
Expected: no matches.

- [ ] **Step 3: Type-check**

Run: `deno check supabase/functions/verify-payment/index.ts`
Expected: no errors.

- [ ] **Step 4: Smoke test**

```bash
supabase functions deploy verify-payment
```

Complete a real Paystack test payment in the app. After payment, verify-payment should return `{ success: true, booking: {...} }` within 1–2 polls.

- [ ] **Step 5: Commit**

```bash
git add supabase/functions/verify-payment/index.ts
git commit -m "spec(17): verify-payment uses PaymentProviderPort"
```

---

**Cut 2 complete.** Transaction verification is now port-driven.

---

# CUT 3 — `initCheckout`

Highest-behavioral-surface migration. Touches `create-booking`.

---

### Task 10: Implement Paystack `initCheckout`

**Files:**
- Modify: `supabase/functions/_shared/providers/paystack_provider.ts`
- Modify: `supabase/functions/_shared/providers/paystack_provider.test.ts`

- [ ] **Step 1: Write the failing test** (append)

```ts
// Append to supabase/functions/_shared/providers/paystack_provider.test.ts

Deno.test("PaystackProvider.initCheckout: returns authorization URL + reference", async () => {
  const restore = stubFetch((url, init) => {
    if (url.endsWith("/transaction/initialize")) {
      const body = JSON.parse(init?.body as string);
      // Adapter must convert major→minor units.
      assertEquals(body.amount, 5000);
      assertEquals(body.email, "buyer@example.com");
      assertEquals(body.currency, "GHS");
      assertEquals(body.reference, "ref_abc");
      return new Response(JSON.stringify({
        status: true,
        data: {
          authorization_url: "https://checkout.paystack.com/x",
          reference: "ref_abc",
          access_code: "ac_xyz",
        },
      }), { status: 200 });
    }
    return new Response("not found", { status: 404 });
  });
  try {
    const provider = new PaystackProvider();
    const result = await provider.initCheckout({
      amount: 50,
      currency: "GHS",
      reference: "ref_abc",
      customerEmail: "buyer@example.com",
      callbackUrl: "nanoembryo://payment-success",
    });
    assertEquals(result.checkoutUrl, "https://checkout.paystack.com/x");
    assertEquals(result.providerReference, "ref_abc");
  } finally { restore(); }
});

Deno.test("PaystackProvider.initCheckout: forwards subaccount + platform fee", async () => {
  let received: any;
  const restore = stubFetch((url, init) => {
    if (url.endsWith("/transaction/initialize")) {
      received = JSON.parse(init?.body as string);
      return new Response(JSON.stringify({
        status: true,
        data: { authorization_url: "u", reference: "r" },
      }), { status: 200 });
    }
    return new Response("nf", { status: 404 });
  });
  try {
    const provider = new PaystackProvider();
    await provider.initCheckout({
      amount: 100,
      currency: "GHS",
      reference: "r",
      customerEmail: "x@y.z",
      callbackUrl: "x://y",
      destinationAccountId: "ACCT_sub1",
      platformFeeAmount: 2.9,
    });
    assertEquals(received.subaccount, "ACCT_sub1");
    assertEquals(received.transaction_charge, 290); // 2.9 → 290 minor
  } finally { restore(); }
});

Deno.test("PaystackProvider.initCheckout: provider 400 → throws PaymentProviderError", async () => {
  const restore = stubFetch(() =>
    new Response(JSON.stringify({ status: false, message: "Invalid email" }), { status: 400 })
  );
  try {
    const provider = new PaystackProvider();
    await assertRejects(
      () => provider.initCheckout({
        amount: 50, currency: "GHS", reference: "r",
        customerEmail: "bad", callbackUrl: "x://y",
      }),
      PaymentProviderError,
    );
  } finally { restore(); }
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `deno test supabase/functions/_shared/providers/paystack_provider.test.ts`
Expected: FAIL — `initCheckout` throws "not implemented yet".

- [ ] **Step 3: Implement `initCheckout` in `paystack_provider.ts`**

Add the import (if not present):
```ts
import { sanitizeCurrency } from "../sanitize.ts";
```

Replace the `initCheckout` stub with:

```ts
async initCheckout(
  input: InitCheckoutInput,
): Promise<InitCheckoutResult> {
  if (!this.secretKey) {
    throw new PaymentProviderError(
      "Paystack secret key not configured",
      "unavailable",
      false,
    );
  }
  const currency = sanitizeCurrency(input.currency);
  // Append reference to callback so the WebView can pick it up from the URL.
  const sep = input.callbackUrl.includes("?") ? "&" : "?";
  const callbackUrl = `${input.callbackUrl}${sep}reference=${encodeURIComponent(input.reference)}`;

  const body: Record<string, unknown> = {
    amount: Math.round(input.amount * 100),
    email: input.customerEmail,
    currency,
    reference: input.reference,
    callback_url: callbackUrl,
    metadata: input.metadata ?? {},
  };
  if (input.destinationAccountId) {
    body.subaccount = input.destinationAccountId;
  }
  if (input.platformFeeAmount !== undefined) {
    body.transaction_charge = Math.round(input.platformFeeAmount * 100);
  }

  let resp: Response;
  try {
    resp = await retryFetch(
      `${PAYSTACK_BASE_URL}/transaction/initialize`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.secretKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(body),
      },
      { attempts: 3, baseDelayMs: 500, label: "paystack.initialize" },
    );
  } catch (e) {
    throw new PaymentProviderError(
      `Paystack initialize failed: ${(e as Error).message}`,
      "unavailable",
      false,
      undefined,
      e,
    );
  }
  const data = await resp.json();
  if (!data.status) {
    throw new PaymentProviderError(
      data.message ?? "Paystack initialize returned status=false",
      "invalid_request",
      false,
      undefined,
      data,
    );
  }
  return {
    checkoutUrl: data.data.authorization_url,
    providerReference: data.data.reference,
  };
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `deno test supabase/functions/_shared/providers/paystack_provider.test.ts`
Expected: PASS, 10 tests total.

- [ ] **Step 5: Commit**

```bash
git add supabase/functions/_shared/providers/paystack_provider.ts \
        supabase/functions/_shared/providers/paystack_provider.test.ts
git commit -m "spec(17): paystack adapter — initCheckout with subaccount split"
```

---

### Task 11: Implement Stripe `initCheckout`

**Files:**
- Modify: `supabase/functions/_shared/providers/stripe_provider.ts`
- Modify: `supabase/functions/_shared/providers/stripe_provider.test.ts`

- [ ] **Step 1: Write the failing test** (append)

```ts
// Append to supabase/functions/_shared/providers/stripe_provider.test.ts

Deno.test("StripeProvider.initCheckout: creates session with major→minor conversion", async () => {
  const restore = stubFetch((url, init) => {
    if (url.endsWith("/checkout/sessions")) {
      const body = new URLSearchParams(init?.body as string);
      // Stripe SDK serializes as form-urlencoded
      assertEquals(body.get("line_items[0][price_data][unit_amount]"), "5000");
      assertEquals(body.get("line_items[0][price_data][currency]"), "usd");
      return new Response(JSON.stringify({
        id: "cs_test_3",
        url: "https://checkout.stripe.com/x",
        payment_status: "unpaid",
      }), { status: 200, headers: { "content-type": "application/json" } });
    }
    return new Response("nf", { status: 404 });
  });
  try {
    const provider = new StripeProvider();
    const result = await provider.initCheckout({
      amount: 50,
      currency: "USD",
      reference: "ref_x",
      customerEmail: "buyer@example.com",
      callbackUrl: "nanoembryo://payment-success",
    });
    assertEquals(result.checkoutUrl, "https://checkout.stripe.com/x");
    assertEquals(result.providerReference, "cs_test_3");
  } finally { restore(); }
});

Deno.test("StripeProvider.initCheckout: adds transfer_data when destinationAccountId set", async () => {
  let received: URLSearchParams | undefined;
  const restore = stubFetch((url, init) => {
    if (url.endsWith("/checkout/sessions")) {
      received = new URLSearchParams(init?.body as string);
      return new Response(JSON.stringify({
        id: "cs_x", url: "u", payment_status: "unpaid",
      }), { status: 200, headers: { "content-type": "application/json" } });
    }
    return new Response("nf", { status: 404 });
  });
  try {
    const provider = new StripeProvider();
    await provider.initCheckout({
      amount: 100, currency: "USD", reference: "r",
      customerEmail: "x@y.z", callbackUrl: "x://y",
      destinationAccountId: "acct_1Xxx",
      platformFeeAmount: 2.9,
    });
    assertEquals(received?.get("payment_intent_data[transfer_data][destination]"), "acct_1Xxx");
    assertEquals(received?.get("payment_intent_data[application_fee_amount]"), "290");
  } finally { restore(); }
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `deno test supabase/functions/_shared/providers/stripe_provider.test.ts`
Expected: FAIL — `initCheckout` throws "not implemented yet".

- [ ] **Step 3: Implement `initCheckout` in `stripe_provider.ts`**

Replace the `initCheckout` stub with:

```ts
async initCheckout(
  input: InitCheckoutInput,
): Promise<InitCheckoutResult> {
  if (!this.stripe) {
    throw new PaymentProviderError("Stripe not configured", "unavailable", false);
  }
  const sessionParams: Stripe.Checkout.SessionCreateParams = {
    payment_method_types: ["card"],
    mode: "payment",
    customer_email: input.customerEmail,
    line_items: [{
      price_data: {
        currency: input.currency.toLowerCase(),
        product_data: {
          name: "Booking Deposit",
        },
        unit_amount: Math.round(input.amount * 100),
      },
      quantity: 1,
    }],
    success_url: input.callbackUrl,
    cancel_url: input.callbackUrl.replace("payment-success", "payment-cancelled"),
    metadata: {
      ...input.metadata,
      reference: input.reference,
    },
  };
  if (input.destinationAccountId) {
    sessionParams.payment_intent_data = {
      transfer_data: { destination: input.destinationAccountId },
    };
    if (input.platformFeeAmount !== undefined) {
      sessionParams.payment_intent_data.application_fee_amount =
        Math.round(input.platformFeeAmount * 100);
    }
  }

  let session: Stripe.Checkout.Session;
  try {
    session = await this.stripe.checkout.sessions.create(sessionParams, {
      idempotencyKey: input.reference,
    });
  } catch (e) {
    const err = e as { type?: string; message?: string; raw?: unknown };
    const category = err.type === "StripeInvalidRequestError"
      ? "invalid_request"
      : err.type === "StripeRateLimitError"
      ? "rate_limit"
      : "unavailable";
    throw new PaymentProviderError(
      err.message ?? "Stripe session create failed",
      category,
      category === "rate_limit",
      err.type,
      err.raw ?? err,
    );
  }
  return {
    checkoutUrl: session.url ?? "",
    providerReference: session.id,
  };
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `deno test supabase/functions/_shared/providers/stripe_provider.test.ts`
Expected: PASS, 8 tests total.

- [ ] **Step 5: Commit**

```bash
git add supabase/functions/_shared/providers/stripe_provider.ts \
        supabase/functions/_shared/providers/stripe_provider.test.ts
git commit -m "spec(17): stripe adapter — initCheckout with connected-account transfer"
```

---

### Task 12: Refactor `create-booking` to use the port

**Files:**
- Modify: `supabase/functions/create-booking/index.ts:295-310, 487-619`

- [ ] **Step 1: Update imports** at the top of `create-booking/index.ts`

Add:
```ts
import { getProvider } from "../_shared/providers/registry.ts";
import { PaymentProviderError, type PaymentProviderName } from "../_shared/providers/port.ts";
```

- [ ] **Step 2: Replace the provider-branching block (lines 295–310)** with:

```ts
    // ========================================================================
    // STEP 4: INITIALIZE CHECKOUT VIA THE PROVIDER PORT
    // ========================================================================
    const callbackBase = body.successUrl ?? "nanoembryo://payment-success";

    let checkoutResult;
    try {
      checkoutResult = await getProvider(provider as PaymentProviderName).initCheckout({
        amount: body.depositAmount,
        currency: shopCurrency,
        reference: provider === "paystack"
          ? `booking_${body.shopId}_${Date.now()}_${body.idempotencyKey.slice(0, 8)}`
          : body.idempotencyKey,
        customerEmail: body.userEmail,
        callbackUrl: callbackBase,
        destinationAccountId: await resolveDestinationAccountId(body.shopId, provider),
        platformFeeAmount: body.platformFee,
        metadata: {
          shop_id: body.shopId,
          user_id: body.userId,
          total_amount: String(body.totalAmount),
          deposit_amount: String(body.depositAmount),
          platform_fee: String(body.platformFee),
          idempotency_key: body.idempotencyKey,
          services: body.services.map((s) => s.serviceName).join(", "),
        },
      });
    } catch (e) {
      if (e instanceof PaymentProviderError) {
        return new Response(
          JSON.stringify({ success: false, error: e.message }),
          { status: e.category === "invalid_request" ? 400 : 502, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }
      throw e;
    }

    const paymentResult = {
      success: true,
      paymentIntentId: checkoutResult.providerReference,
      authorizationUrl: checkoutResult.checkoutUrl,
      reference: checkoutResult.providerReference,
    };
```

- [ ] **Step 3: Add the `resolveDestinationAccountId` helper** near the bottom of the file (before the dead `processPaystackPayment` / `processStripePayment` functions):

```ts
async function resolveDestinationAccountId(
  shopId: string,
  provider: "paystack" | "stripe",
): Promise<string | undefined> {
  const { data: settings } = await supabase
    .from("payment_settings")
    .select("paystack_subaccount_code, stripe_account_id, stripe_verified")
    .eq("shop_id", shopId)
    .maybeSingle();
  if (!settings) return undefined;
  if (provider === "paystack") return settings.paystack_subaccount_code ?? undefined;
  if (provider === "stripe") {
    return settings.stripe_verified ? (settings.stripe_account_id ?? undefined) : undefined;
  }
  return undefined;
}
```

- [ ] **Step 4: Delete the dead `processStripePayment` and `processPaystackPayment` functions** (lines 487–619 — everything after `validateRequest` and the `STRIPE PAYMENT PROCESSING` / `PAYSTACK PAYMENT PROCESSING` section headers, all the way to end of file).

Verify the file ends cleanly. Run: `tail -20 supabase/functions/create-booking/index.ts`
Expected: ends with the `validateRequest` function's closing brace or the `resolveDestinationAccountId` helper.

- [ ] **Step 5: Verify no stale references**

Run:
```bash
grep -n "processPaystackPayment\|processStripePayment\|PAYSTACK_BASE_URL\b\|^import Stripe" supabase/functions/create-booking/index.ts
```
Expected: no matches (the `PAYSTACK_BASE_URL` const + `import Stripe` are now in the adapters, no longer needed here).

If `stripe` and `Stripe` imports are still present at the top, remove them:
```ts
import Stripe from "https://esm.sh/stripe@13.6.0";
// ...
const stripeKey = Deno.env.get('STRIPE_SECRET_KEY');
const stripe = stripeKey ? new Stripe(stripeKey, { apiVersion: '2023-10-16' }) : null;
```

If `PAYSTACK_BASE_URL` and `PAYSTACK_SECRET_KEY` consts are still present, remove them.

- [ ] **Step 6: Type-check**

Run: `deno check supabase/functions/create-booking/index.ts`
Expected: no errors.

- [ ] **Step 7: Smoke test — end-to-end booking**

```bash
supabase functions deploy create-booking
```

In the app, complete a real booking → Paystack checkout opens → pay with test card → success screen appears. Repeat for Stripe (set shop country to e.g. USA).

- [ ] **Step 8: Commit**

```bash
git add supabase/functions/create-booking/index.ts
git commit -m "spec(17): create-booking uses PaymentProviderPort; remove dead per-provider helpers"
```

---

**Cut 3 complete.** Checkout initialization is port-driven.

---

# CUT 4 — `processPayout`

Highest money-at-risk migration. Touches `process-withdrawal`.

---

### Task 13: Implement Paystack `processPayout`

**Files:**
- Modify: `supabase/functions/_shared/providers/paystack_provider.ts`
- Modify: `supabase/functions/_shared/providers/paystack_provider.test.ts`

- [ ] **Step 1: Write the failing test** (append)

```ts
// Append to paystack_provider.test.ts

Deno.test("PaystackProvider.processPayout: kobo conversion + reference idempotency", async () => {
  let received: any;
  const restore = stubFetch((url, init) => {
    if (url.endsWith("/transfer")) {
      received = JSON.parse(init?.body as string);
      return new Response(JSON.stringify({
        status: true,
        data: { transfer_code: "trf_xyz", status: "pending", reference: received.reference },
      }), { status: 200 });
    }
    return new Response("nf", { status: 404 });
  });
  try {
    const provider = new PaystackProvider();
    const result = await provider.processPayout({
      amount: 100,
      currency: "GHS",
      destinationAccountId: "RCP_abc",
      reference: "wd_idempotency_1",
      reason: "Withdrawal",
    });
    assertEquals(received.amount, 10000);
    assertEquals(received.recipient, "RCP_abc");
    assertEquals(received.reference, "wd_idempotency_1");
    assertEquals(received.reason, "Withdrawal");
    assertEquals(result.providerTransferId, "trf_xyz");
    assertEquals(result.status, "pending");
  } finally { restore(); }
});

Deno.test("PaystackProvider.processPayout: status=false → invalid_request", async () => {
  const restore = stubFetch(() =>
    new Response(JSON.stringify({ status: false, message: "Insufficient balance" }), { status: 200 })
  );
  try {
    const provider = new PaystackProvider();
    await assertRejects(
      () => provider.processPayout({
        amount: 50, currency: "GHS", destinationAccountId: "RCP_x",
        reference: "wd_x",
      }),
      PaymentProviderError,
    );
  } finally { restore(); }
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `deno test supabase/functions/_shared/providers/paystack_provider.test.ts`
Expected: FAIL — `processPayout` throws "not implemented yet".

- [ ] **Step 3: Implement `processPayout` in `paystack_provider.ts`**

Replace the `processPayout` stub with:

```ts
async processPayout(
  input: ProcessPayoutInput,
): Promise<ProcessPayoutResult> {
  if (!this.secretKey) {
    throw new PaymentProviderError("Paystack not configured", "unavailable", false);
  }
  const amountKobo = Math.round(input.amount * 100);
  let resp: Response;
  try {
    resp = await retryFetch(
      `${PAYSTACK_BASE_URL}/transfer`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.secretKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          source: "balance",
          amount: amountKobo,
          recipient: input.destinationAccountId,
          reference: input.reference,    // Paystack's native idempotency primitive
          reason: input.reason ?? "Withdrawal",
        }),
      },
      { attempts: 3, baseDelayMs: 1000, label: "paystack.transfer" },
    );
  } catch (e) {
    throw new PaymentProviderError(
      `Paystack transfer failed: ${(e as Error).message}`,
      "unavailable",
      false,
      undefined,
      e,
    );
  }
  const body = await resp.json();
  if (!body.status) {
    throw new PaymentProviderError(
      body.message ?? "Paystack transfer returned status=false",
      "invalid_request",
      false,
      undefined,
      body,
    );
  }
  const d = body.data;
  return {
    status: d.status === "success" ? "success" : d.status === "failed" ? "failed" : "pending",
    providerTransferId: d.transfer_code,
  };
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `deno test supabase/functions/_shared/providers/paystack_provider.test.ts`
Expected: PASS, 12 tests total.

- [ ] **Step 5: Commit**

```bash
git add supabase/functions/_shared/providers/paystack_provider.ts \
        supabase/functions/_shared/providers/paystack_provider.test.ts
git commit -m "spec(17): paystack adapter — processPayout via transfer API"
```

---

### Task 14: Implement Stripe `processPayout`

**Files:**
- Modify: `supabase/functions/_shared/providers/stripe_provider.ts`
- Modify: `supabase/functions/_shared/providers/stripe_provider.test.ts`

- [ ] **Step 1: Write the failing test** (append)

```ts
// Append to stripe_provider.test.ts

Deno.test("StripeProvider.processPayout: sends Idempotency-Key header + form body", async () => {
  let receivedInit: RequestInit | undefined;
  const restore = stubFetch((url, init) => {
    if (url.endsWith("/payouts")) {
      receivedInit = init;
      return new Response(JSON.stringify({
        id: "po_test_1", status: "pending", amount: 5000, currency: "usd",
      }), { status: 200, headers: { "content-type": "application/json" } });
    }
    return new Response("nf", { status: 404 });
  });
  try {
    const provider = new StripeProvider();
    const result = await provider.processPayout({
      amount: 50, currency: "USD", destinationAccountId: "acct_1abc",
      reference: "wd_stripe_1",
    });
    const headers = new Headers(receivedInit?.headers);
    assertEquals(headers.get("idempotency-key"), "wd_stripe_1");
    const body = new URLSearchParams(receivedInit?.body as string);
    assertEquals(body.get("amount"), "5000");
    assertEquals(body.get("currency"), "usd");
    assertEquals(body.get("destination"), "acct_1abc");
    assertEquals(result.providerTransferId, "po_test_1");
    assertEquals(result.status, "pending");
  } finally { restore(); }
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `deno test supabase/functions/_shared/providers/stripe_provider.test.ts`
Expected: FAIL — `processPayout` throws "not implemented yet".

- [ ] **Step 3: Implement `processPayout` in `stripe_provider.ts`**

Note: the existing code uses raw `retryFetch` to `/v1/payouts` because Stripe's `payouts.create` SDK call doesn't accept a `destination` for cross-account payouts in the same way. We'll mirror that approach in the adapter for fidelity.

Add the import:
```ts
import { retryFetch } from "../retry.ts";
```

Add a private secret field in the constructor:
```ts
private readonly secretKey: string;

constructor() {
  const key = Deno.env.get("STRIPE_SECRET_KEY");
  this.secretKey = key ?? "";
  this.stripe = key ? new Stripe(key, { apiVersion: "2023-10-16" }) : null;
  this.webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET") ?? "";
}
```

Replace the `processPayout` stub:

```ts
async processPayout(
  input: ProcessPayoutInput,
): Promise<ProcessPayoutResult> {
  if (!this.secretKey) {
    throw new PaymentProviderError("Stripe not configured", "unavailable", false);
  }
  const amountCents = Math.round(input.amount * 100);
  let resp: Response;
  try {
    resp = await retryFetch(
      "https://api.stripe.com/v1/payouts",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.secretKey}`,
          "Content-Type": "application/x-www-form-urlencoded",
          "Idempotency-Key": input.reference,
        },
        body: new URLSearchParams({
          amount: amountCents.toString(),
          currency: input.currency.toLowerCase(),
          destination: input.destinationAccountId,
          description: input.reason ?? "Withdrawal",
        }).toString(),
      },
      { attempts: 3, baseDelayMs: 1000, label: "stripe.payout" },
    );
  } catch (e) {
    throw new PaymentProviderError(
      `Stripe payout failed: ${(e as Error).message}`,
      "unavailable",
      false,
      undefined,
      e,
    );
  }
  const data = await resp.json();
  if (data.error) {
    throw new PaymentProviderError(
      data.error.message ?? "Stripe payout returned error",
      "invalid_request",
      false,
      data.error.code,
      data.error,
    );
  }
  return {
    status: data.status === "paid" ? "success" : data.status === "failed" ? "failed" : "pending",
    providerTransferId: data.id,
  };
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `deno test supabase/functions/_shared/providers/stripe_provider.test.ts`
Expected: PASS, 9 tests total.

- [ ] **Step 5: Commit**

```bash
git add supabase/functions/_shared/providers/stripe_provider.ts \
        supabase/functions/_shared/providers/stripe_provider.test.ts
git commit -m "spec(17): stripe adapter — processPayout with Idempotency-Key"
```

---

### Task 15: Refactor `process-withdrawal` to use the port

**Files:**
- Modify: `supabase/functions/process-withdrawal/index.ts:128-316`

- [ ] **Step 1: Update imports**

In `supabase/functions/process-withdrawal/index.ts`, add:
```ts
import { getProvider } from "../_shared/providers/registry.ts";
import { PaymentProviderError, type PaymentProviderName } from "../_shared/providers/port.ts";
```

- [ ] **Step 2: Replace the provider-branching block (lines 128–148)** with:

```ts
    let transferResult;
    try {
      const provider = getProvider(withdrawal.payment_provider as PaymentProviderName);
      transferResult = await provider.processPayout({
        amount: withdrawal.net_amount ?? withdrawal.amount,
        currency: await getWalletCurrency(withdrawal.shops.id),
        destinationAccountId: withdrawal.transfer_recipient_id,
        reference: withdrawal.idempotency_key,
        reason: "Withdrawal",
      });
    } catch (e) {
      if (e instanceof PaymentProviderError) {
        throw new Error(e.message);
      }
      throw e;
    }

    // The port returns providerTransferId in the same field shape as before.
    const transferIdForCompletion = transferResult.providerTransferId;
```

- [ ] **Step 3: Update the `completeWithdrawal(withdrawalId, transferResult.id)` call** (line 150) to:

```ts
    await completeWithdrawal(withdrawalId, transferIdForCompletion);
```

And update the `context.transfer_id` in the audit payload (line 162):
```ts
        transfer_id: transferIdForCompletion,
```

- [ ] **Step 4: Delete the dead `processPaystackWithdrawal` and `processStripeWithdrawal` functions** (lines 218–316).

Verify the file ends cleanly. Run: `tail -20 supabase/functions/process-withdrawal/index.ts`
Expected: ends with `getWalletCurrency` helper.

- [ ] **Step 5: Remove unused constants** at the top of the file:

```ts
const PAYSTACK_SECRET_KEY = Deno.env.get('PAYSTACK_SECRET_KEY')!;
const PAYSTACK_BASE_URL = 'https://api.paystack.co';
const STRIPE_SECRET_KEY = Deno.env.get('STRIPE_SECRET_KEY');
const STRIPE_BASE_URL = 'https://api.stripe.com/v1';
```

Also remove unused imports:
```ts
import { retryFetch } from "../_shared/retry.ts";
import { sanitizeAmount } from "../_shared/sanitize.ts";
```

(Keep `sanitizeIdentifier` — still used for `withdrawalId` validation.)

- [ ] **Step 6: Type-check**

Run: `deno check supabase/functions/process-withdrawal/index.ts`
Expected: no errors.

- [ ] **Step 7: Smoke test — process a real withdrawal**

```bash
supabase functions deploy process-withdrawal
```

Request a small withdrawal in the app (e.g. GHS 50 if using Paystack). Verify:
- Withdrawal completes (`status=completed`).
- Wallet balance debited correctly.
- Audit log entry recorded.
- Retrying the same `withdrawal_id` does not double-payout (idempotency holds via `reference`).

- [ ] **Step 8: Commit**

```bash
git add supabase/functions/process-withdrawal/index.ts
git commit -m "spec(17): process-withdrawal uses PaymentProviderPort"
```

---

**Cut 4 complete.** All 4 port operations are wired up. No edge function branches on provider name anymore.

---

# CUT 5 — Flutter relocation

Mechanical file moves + import sweep. Independent of the port migration.

---

### Task 16: Relocate `lib/presentation/features/shops/payment/` → `lib/payment/`

**Files:**
- Move: entire directory.
- Modify: every file importing from the old path.

- [ ] **Step 1: Find all importers**

Run:
```bash
grep -rln "features/shops/payment" lib/ test/ | sort -u
```
Save the output — these are the files that need updating.

- [ ] **Step 2: Move the directory**

```bash
git mv lib/presentation/features/shops/payment lib/payment
```

- [ ] **Step 3: Sweep imports across the codebase**

Use a find+sed combo (BSD sed syntax for macOS):
```bash
grep -rln "features/shops/payment" lib/ test/ \
  | xargs sed -i '' "s|features/shops/payment|payment|g"
```

- [ ] **Step 4: Special-case the `lib/payment/` internal imports**

Files inside the moved directory may now have wrong relative depths. For each file in `lib/payment/`, imports like `package:nano_embryo/presentation/features/shops/payment/...` should already be fixed by the sweep above. Imports of OTHER modules (e.g. `package:nano_embryo/core/...`) are unaffected.

Run: `flutter analyze` and fix any remaining "URI doesn't exist" errors one by one.

- [ ] **Step 5: Update `main.dart`**

Find the `paymentConfigProvider` override import in `lib/main.dart`. After Step 3 it should read:
```dart
import 'package:nano_embryo/payment/config/payment_config.dart';
```
(The sweep updates this automatically.)

- [ ] **Step 6: Verify build**

Run: `flutter analyze`
Expected: no errors.

Run: `flutter test test/payment/`
Expected: PASS (all 18 config tests).

- [ ] **Step 7: Smoke test — open the app**

```bash
flutter run --flavor development
```

Navigate to: a service detail → book → confirm payment → WebView opens. Confirms no broken paths.

- [ ] **Step 8: Commit**

```bash
git add -A lib/payment/ lib/presentation/features/shops/ lib/main.dart test/
git commit -m "spec(17): relocate payment module to lib/payment/ (drop-in layout)"
```

---

### Task 17: Relocate `lib/presentation/features/shops/wallet/` → `lib/wallet/`

**Files:**
- Move: entire directory.
- Modify: every file importing from the old path.

- [ ] **Step 1: Find all importers**

```bash
grep -rln "features/shops/wallet" lib/ test/ | sort -u
```

- [ ] **Step 2: Move the directory**

```bash
git mv lib/presentation/features/shops/wallet lib/wallet
```

- [ ] **Step 3: Sweep imports**

```bash
grep -rln "features/shops/wallet" lib/ test/ \
  | xargs sed -i '' "s|features/shops/wallet|wallet|g"
```

- [ ] **Step 4: Verify build**

Run: `flutter analyze`
Expected: no errors.

- [ ] **Step 5: Smoke test — open the Wallet screen**

```bash
flutter run --flavor development
```

Navigate to: Shop dashboard → Wallet. Verify the screen loads, balance shows, transaction list renders.

- [ ] **Step 6: Commit**

```bash
git add -A lib/wallet/ lib/presentation/features/shops/
git commit -m "spec(17): relocate wallet module to lib/wallet/ (drop-in layout)"
```

---

### Task 18: Update `PAYMENT_ENGINE.md` integration paths

**Files:**
- Modify: `PAYMENT_ENGINE.md`

- [ ] **Step 1: Read current state**

Open `PAYMENT_ENGINE.md`. Find the "Drop into another app" section (around line 71).

- [ ] **Step 2: Replace the old paths**

Find:
```
lib/presentation/features/shops/payment/         # whole folder
lib/presentation/features/shops/wallet/          # whole folder
```

Replace with:
```
lib/payment/                                     # whole folder
lib/wallet/                                      # whole folder
```

- [ ] **Step 3: Add a "Payment provider port" subsection** after the "Architecture" diagram

Insert this after the architecture ASCII diagram (around line 65):

```markdown
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
```

- [ ] **Step 4: Commit**

```bash
git add PAYMENT_ENGINE.md
git commit -m "spec(17): docs — update PAYMENT_ENGINE paths + document provider port"
```

---

**Cut 5 complete.** Flutter modules relocated, docs updated.

---

# Verification

After all cuts are merged:

1. **Adapter tests pass:** `deno test supabase/functions/_shared/providers/` → all green.
2. **Edge-function type-check:** `deno check supabase/functions/{create-booking,verify-payment,process-withdrawal,paystack-webhook,stripe-webhook}/index.ts` → no errors.
3. **Flutter analyze:** `flutter analyze` → no errors.
4. **End-to-end Paystack:** book a service → pay with test card → success screen.
5. **End-to-end Stripe:** book at a USD shop → pay with test card → success screen.
6. **Withdrawal flow:** request a withdrawal → verify wallet debit + audit log entry → confirm idempotency by triggering the same withdrawal_id twice.
7. **Webhook replay:** send a valid Paystack webhook → 200. Send invalid signature → 401. Same for Stripe.
8. **No grep matches:** `grep -rn "processPaystackPayment\|processStripePayment\|processPaystackWithdrawal\|processStripeWithdrawal" supabase/` → 0 results.

Once verified, the codebase has a clean port abstraction. Adding Flutterwave/Razorpay would now require:
1. ~150-line new adapter file.
2. 2-line registry change.
3. 1-line `PaymentProviderName` union extension.
4. Country-→-provider mapping update in `create-booking` (`providerResolver` logic).
