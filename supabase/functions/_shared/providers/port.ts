// supabase/functions/_shared/providers/port.ts
//
// Provider-agnostic payment port. Adapters in this directory implement this
// interface; edge functions call through `registry.getProvider(name)` instead
// of branching on provider name.

export type PaymentProviderName =
  | "paystack"
  | "stripe"
  | "flutterwave"
  | "razorpay";

export interface InitCheckoutInput {
  /**
   * @deprecated Phase 17 — use `amountMinor`. Major units (e.g. 50.00).
   * Stays on the port for one release cycle while the legacy create-booking
   * float-cedis fallback path is still live.
   */
  amount?: number;
  /**
   * Phase 17 — integer minor units (e.g. 5000 kobo). Adapters pass this
   * value through to the provider SDK verbatim — no `* 100` conversion.
   * This is the new canonical money field.
   */
  amountMinor: number;
  /** ISO 4217, uppercased. */
  currency: string;
  /** Caller-controlled idempotency key. Forwarded to provider-native idempotency. */
  reference: string;
  customerEmail: string;
  /** Deep-link back into the app (e.g. nanoembryo://payment-success). */
  callbackUrl: string;
  metadata?: Record<string, string>;
  /** Paystack subaccount code or Stripe connected account id. */
  destinationAccountId?: string;
  /**
   * @deprecated Phase 17 — use `platformFeeAmountMinor`.
   */
  platformFeeAmount?: number;
  /**
   * Phase 17 — integer minor units. Taken from the gross before destination
   * split. Adapters pass verbatim to provider SDK.
   */
  platformFeeAmountMinor?: number;
}

export interface InitCheckoutResult {
  checkoutUrl: string;
  providerReference: string;
  expiresAt?: string;
}

export interface VerifyTransactionInput {
  reference: string;
}

export interface VerifyTransactionResult {
  status: "success" | "pending" | "failed" | "abandoned";
  /**
   * @deprecated Phase 17 — use `amountMinor`. Major units.
   */
  amount?: number;
  /**
   * Phase 17 — integer minor units. Read directly from provider response
   * (Paystack + Stripe both speak minor natively); no /100 normalization.
   */
  amountMinor: number;
  currency: string;
  paidAt?: string;
  providerTransactionId: string;
}

export interface ProcessPayoutInput {
  /**
   * @deprecated Phase 17 — use `amountMinor`.
   */
  amount?: number;
  /**
   * Phase 17 — integer minor units.
   */
  amountMinor: number;
  currency: string;
  destinationAccountId: string;
  reference: string;
  reason?: string;
}

export interface ProcessPayoutResult {
  status: "pending" | "success" | "failed";
  providerTransferId: string;
  estimatedArrival?: string;
}

export interface VerifyWebhookSignatureInput {
  rawBody: string;
  signatureHeader: string;
}

export interface PaymentProviderPort {
  readonly name: PaymentProviderName;
  initCheckout(input: InitCheckoutInput): Promise<InitCheckoutResult>;
  verifyTransaction(
    input: VerifyTransactionInput,
  ): Promise<VerifyTransactionResult>;
  processPayout(input: ProcessPayoutInput): Promise<ProcessPayoutResult>;
  verifyWebhookSignature(input: VerifyWebhookSignatureInput): Promise<boolean>;
}

export type PaymentErrorCategory =
  | "declined"
  | "insufficient_funds"
  | "invalid_request"
  | "unavailable"
  | "rate_limit"
  | "unknown";

export class PaymentProviderError extends Error {
  constructor(
    message: string,
    readonly category: PaymentErrorCategory,
    readonly retryable: boolean,
    readonly providerCode?: string,
    readonly providerRaw?: unknown,
  ) {
    super(message);
    this.name = "PaymentProviderError";
  }
}
