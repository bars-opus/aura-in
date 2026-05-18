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
