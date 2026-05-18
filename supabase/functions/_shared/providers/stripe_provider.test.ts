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
