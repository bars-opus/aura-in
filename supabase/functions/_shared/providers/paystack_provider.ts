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
import { PaymentProviderError } from "./port.ts";
import { retryFetch } from "../retry.ts";
import { sanitizeCurrency } from "../sanitize.ts";

const PAYSTACK_BASE_URL = "https://api.paystack.co";

export class PaystackProvider implements PaymentProviderPort {
  readonly name = "paystack" as const;

  private readonly webhookSecret: string;
  private readonly secretKey: string;

  constructor() {
    // Read at construction so a missing secret fails fast on instantiation,
    // not during signature verify.
    this.webhookSecret = Deno.env.get("PAYSTACK_WEBHOOK_SECRET") ?? "";
    this.secretKey = Deno.env.get("PAYSTACK_SECRET_KEY") ?? "";
  }

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
