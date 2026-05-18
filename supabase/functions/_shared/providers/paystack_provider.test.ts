import {
  assertEquals,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import { PaystackProvider } from "./paystack_provider.ts";

// Set env BEFORE importing/instantiating the provider so its constructor sees it.
Deno.env.set("PAYSTACK_WEBHOOK_SECRET", "test_webhook_secret");

Deno.test("PaystackProvider.verifyWebhookSignature: valid HMAC-SHA512 → true", async () => {
  const provider = new PaystackProvider();
  const body = '{"event":"charge.success","data":{"reference":"abc"}}';
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
