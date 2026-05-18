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
