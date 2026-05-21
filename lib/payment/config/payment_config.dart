import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supported payment providers.
enum PaymentProvider { paystack, stripe }

/// Inputs available when picking a provider for a transaction.
class PaymentResolveContext {
  final String? country;
  final String? currency;
  const PaymentResolveContext({this.country, this.currency});
}

/// Optional client-side provider resolver.
typedef PaymentProviderResolver = PaymentProvider Function(
  PaymentResolveContext context,
);

/// Classified payment outcomes — surfaced via [PaymentConfig.onPaymentFailure]
/// so the host app can branch on category instead of parsing strings.
enum PaymentErrorCategory {
  cancelled,
  declined,
  network,
  validation,
  serverError,
  unknown,
}

class PaymentSuccessInfo {
  final String reference;
  final double amount;
  final String currency;
  final Map<String, dynamic> raw;
  const PaymentSuccessInfo({
    required this.reference,
    required this.amount,
    required this.currency,
    required this.raw,
  });
}

class PaymentErrorInfo {
  final String? reference;
  final String message;
  final PaymentErrorCategory category;
  const PaymentErrorInfo({
    required this.message,
    required this.category,
    this.reference,
  });
}

/// The single configuration object for the payment engine.
///
/// Drop this into any Flutter + Supabase project that uses Paystack and/or
/// Stripe. Override [paymentConfigProvider] in your root [ProviderScope]:
///
/// ```dart
/// ProviderScope(
///   overrides: [
///     paymentConfigProvider.overrideWithValue(
///       const PaymentConfig(
///         appScheme: 'myapp',
///         brandName: 'MyApp',
///         defaultCurrency: 'USD',
///         enabledProviders: {PaymentProvider.stripe},
///       ),
///     ),
///   ],
///   child: MyApp(),
/// )
/// ```
///
/// See PAYMENT_ENGINE.md for the integration guide.
class PaymentConfig {
  // ── Identity ──────────────────────────────────────────────────────────────

  /// Custom URL scheme used for payment callbacks.
  ///
  /// Drives the deep links the WebView listens for. Example: `'myapp'` →
  /// `myapp://payment-success` / `myapp://payment-cancelled`.
  final String appScheme;

  /// Brand name shown in payment dialogs and confirmation copy.
  final String brandName;

  // ── Edge function names ───────────────────────────────────────────────────

  /// Name of the Edge Function that creates a payment intent.
  final String createIntentFunctionName;

  /// Name of the Edge Function that verifies a payment via the provider API.
  final String verifyPaymentFunctionName;

  /// Name of the Edge Function that processes wallet withdrawals.
  final String processWithdrawalFunctionName;

  /// Name of the Edge Function that manages Paystack subaccounts.
  final String paystackSubaccountFunctionName;

  /// Name of the Edge Function that manages Stripe Connect onboarding.
  final String stripeConnectFunctionName;

  // ── Providers ─────────────────────────────────────────────────────────────

  /// Which providers are enabled in this app.
  final Set<PaymentProvider> enabledProviders;

  /// Optional client-side provider resolver. Used purely for UI hints — the
  /// server is the source of truth and re-resolves on its own.
  ///
  /// If null, the default rule applies: African currency → paystack, else
  /// stripe.
  final PaymentProviderResolver? providerResolver;

  // ── Money ─────────────────────────────────────────────────────────────────

  /// Fallback currency when the shop currency is missing. ISO 4217.
  final String defaultCurrency;

  /// Upfront deposit as a fraction of the total (0.0–1.0). Default 0.30.
  final double depositFraction;

  /// Platform fee as a fraction of the total (0.0–1.0). Default 0.029.
  final double platformFeeFraction;

  /// Minimum withdrawal amount, in the shop's currency.
  final double minWithdrawalAmount;

  /// Maximum withdrawal amount, in the shop's currency.
  final double maxWithdrawalAmount;

  // ── Retry / polling ───────────────────────────────────────────────────────

  /// How often the WebView polls the DB for a confirmed payment.
  final Duration dbPollInterval;

  /// How often the WebView falls back to verify-payment.
  final Duration verifyEscalationInterval;

  /// Long-poll attempts (DB) after the WebView pops successfully.
  final int dbConfirmAttemptsAfterWebViewSuccess;

  /// Short-poll attempts (DB) after the WebView is cancelled.
  final int dbConfirmAttemptsAfterWebViewCancel;

  /// Delay between DB polls in the post-WebView confirm loop.
  final Duration dbConfirmInterval;

  /// Lifetime of a pending_payment row before it is treated as expired.
  final Duration pendingPaymentExpiry;

  /// Retries for transient provider API failures (Paystack / Stripe).
  final int providerApiRetries;

  /// Initial backoff between provider API retries (doubled each attempt).
  final Duration providerApiRetryBaseDelay;

  // ── UI customization ──────────────────────────────────────────────────────

  /// Custom builder for the payment success widget.
  /// Return null to fall back to the host's existing dialog.
  final Widget Function(BuildContext, PaymentSuccessInfo)? paymentSuccessBuilder;

  /// Custom builder for the payment error UI.
  final Widget Function(BuildContext, PaymentErrorInfo)? paymentErrorBuilder;

  // ── Lifecycle hooks ───────────────────────────────────────────────────────

  /// Called after a payment succeeds. Use to navigate, log analytics, etc.
  final Future<void> Function(PaymentSuccessInfo)? onPaymentSuccess;

  /// Called after a payment fails or is cancelled.
  final Future<void> Function(PaymentErrorInfo)? onPaymentFailure;

  const PaymentConfig({
    required this.appScheme,
    this.brandName = 'App',
    this.createIntentFunctionName = 'create-booking',
    this.verifyPaymentFunctionName = 'verify-payment',
    this.processWithdrawalFunctionName = 'process-withdrawal',
    this.paystackSubaccountFunctionName = 'paystack-subaccount',
    this.stripeConnectFunctionName = 'stripe-connect',
    this.enabledProviders = const {
      PaymentProvider.paystack,
      PaymentProvider.stripe,
    },
    this.providerResolver,
    this.defaultCurrency = 'GHS',
    this.depositFraction = 0.30,
    this.platformFeeFraction = 0.029,
    this.minWithdrawalAmount = 50,
    this.maxWithdrawalAmount = 5000,
    this.dbPollInterval = const Duration(seconds: 4),
    this.verifyEscalationInterval = const Duration(seconds: 15),
    this.dbConfirmAttemptsAfterWebViewSuccess = 15,
    this.dbConfirmAttemptsAfterWebViewCancel = 8,
    this.dbConfirmInterval = const Duration(seconds: 3),
    this.pendingPaymentExpiry = const Duration(minutes: 30),
    this.providerApiRetries = 3,
    this.providerApiRetryBaseDelay = const Duration(milliseconds: 500),
    this.paymentSuccessBuilder,
    this.paymentErrorBuilder,
    this.onPaymentSuccess,
    this.onPaymentFailure,
  })  : assert(depositFraction >= 0 && depositFraction <= 1),
        assert(platformFeeFraction >= 0 && platformFeeFraction <= 1),
        assert(minWithdrawalAmount > 0),
        assert(maxWithdrawalAmount >= minWithdrawalAmount),
        assert(dbConfirmAttemptsAfterWebViewSuccess > 0),
        assert(dbConfirmAttemptsAfterWebViewCancel > 0),
        assert(providerApiRetries >= 0);

  /// Default resolver: African currency → paystack, else stripe.
  PaymentProvider resolveProvider(PaymentResolveContext ctx) {
    if (providerResolver != null) return providerResolver!(ctx);
    final currency = (ctx.currency ?? defaultCurrency).toUpperCase();
    return _africanCurrencies.contains(currency)
        ? PaymentProvider.paystack
        : PaymentProvider.stripe;
  }

  /// Returns the deep-link URL the WebView treats as a payment success.
  String get successDeepLink => '$appScheme://payment-success';

  /// Returns the deep-link URL the WebView treats as a user cancellation.
  String get cancelDeepLink => '$appScheme://payment-cancelled';

  /// Returns the deep-link URL the WebView treats as a payment failure.
  String get failedDeepLink => '$appScheme://payment-failed';

  static const _africanCurrencies = {
    'GHS', 'GHC', 'NGN', 'KES', 'ZAR', 'UGX', 'TZS', 'RWF', 'ZMW', 'BWP',
    'XOF', 'XAF', 'EGP', 'MAD', 'TND', 'DZD', 'ETB', 'MZN', 'AOA',
  };
}

/// Override this provider in your root [ProviderScope].
///
/// The default throws immediately to surface missing configuration early.
final paymentConfigProvider = Provider<PaymentConfig>((ref) {
  throw UnimplementedError(
    'paymentConfigProvider has no value. '
    'Add paymentConfigProvider.overrideWithValue(const PaymentConfig(appScheme: "...")) '
    'to your root ProviderScope. See PAYMENT_ENGINE.md.',
  );
});
