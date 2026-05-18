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

import { assertRejects } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { PaymentProviderError } from "./port.ts";

// Stub fetch — duplicated from paystack_provider.test.ts to keep test files independent.
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
