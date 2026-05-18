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
