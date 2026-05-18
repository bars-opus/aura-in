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
