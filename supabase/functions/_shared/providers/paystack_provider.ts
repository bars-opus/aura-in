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
