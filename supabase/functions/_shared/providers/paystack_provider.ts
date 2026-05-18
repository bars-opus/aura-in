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
