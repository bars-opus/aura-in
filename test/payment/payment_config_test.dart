// test/payment/payment_config_test.dart
//
// Unit tests for PaymentConfig — the standalone module's public API contract.
// These tests pin the defaults, the provider-resolution rules, the deep-link
// generation, and the invariants enforced by the constructor's asserts.
//
// PaymentConfig is pure Dart (no Flutter binding required) so these run fast.

import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/payment/config/payment_config.dart';

void main() {
  group('PaymentConfig defaults', () {
    const config = PaymentConfig(appScheme: 'myapp');

    test('uses sensible Paystack-friendly defaults', () {
      expect(config.defaultCurrency, 'GHS');
      // Phase 17: basis points instead of fractions; int kobo bounds.
      expect(config.depositBps, 3000);
      expect(config.platformFeeBps, 290);
      expect(config.minWithdrawalAmountMinor, 5000);
      expect(config.maxWithdrawalAmountMinor, 500000);
    });

    test('default function names match shipped edge functions', () {
      expect(config.createIntentFunctionName, 'create-booking');
      expect(config.verifyPaymentFunctionName, 'verify-payment');
      expect(config.processWithdrawalFunctionName, 'process-withdrawal');
      expect(config.paystackSubaccountFunctionName, 'paystack-subaccount');
      expect(config.stripeConnectFunctionName, 'stripe-connect');
    });

    test('default retry/poll cadence keeps WebView responsive', () {
      expect(config.dbPollInterval, const Duration(seconds: 4));
      expect(config.verifyEscalationInterval, const Duration(seconds: 15));
      expect(config.providerApiRetries, 3);
    });

    test('both providers enabled by default', () {
      expect(
        config.enabledProviders,
        {PaymentProvider.paystack, PaymentProvider.stripe},
      );
    });
  });

  group('Deep links derive from appScheme', () {
    test('generates the three lifecycle deep links', () {
      const config = PaymentConfig(appScheme: 'acme');
      expect(config.successDeepLink, 'acme://payment-success');
      expect(config.cancelDeepLink, 'acme://payment-cancelled');
      expect(config.failedDeepLink, 'acme://payment-failed');
    });

    test('different host apps get isolated schemes', () {
      const a = PaymentConfig(appScheme: 'appone');
      const b = PaymentConfig(appScheme: 'apptwo');
      expect(a.successDeepLink, isNot(b.successDeepLink));
    });
  });

  group('resolveProvider', () {
    const config = PaymentConfig(appScheme: 'x');

    test('African currencies route to Paystack', () {
      for (final code in ['GHS', 'NGN', 'KES', 'ZAR', 'UGX']) {
        expect(
          config.resolveProvider(PaymentResolveContext(currency: code)),
          PaymentProvider.paystack,
          reason: '$code should resolve to paystack',
        );
      }
    });

    test('non-African currencies route to Stripe', () {
      for (final code in ['USD', 'EUR', 'GBP', 'CAD', 'JPY']) {
        expect(
          config.resolveProvider(PaymentResolveContext(currency: code)),
          PaymentProvider.stripe,
          reason: '$code should resolve to stripe',
        );
      }
    });

    test('falls back to defaultCurrency when context has no currency', () {
      const ghsConfig = PaymentConfig(
        appScheme: 'x',
        defaultCurrency: 'GHS',
      );
      const usdConfig = PaymentConfig(
        appScheme: 'x',
        defaultCurrency: 'USD',
      );
      expect(
        ghsConfig.resolveProvider(const PaymentResolveContext()),
        PaymentProvider.paystack,
      );
      expect(
        usdConfig.resolveProvider(const PaymentResolveContext()),
        PaymentProvider.stripe,
      );
    });

    test('custom resolver overrides built-in rule', () {
      final config = PaymentConfig(
        appScheme: 'x',
        providerResolver: (_) => PaymentProvider.stripe,
      );
      expect(
        config.resolveProvider(const PaymentResolveContext(currency: 'GHS')),
        PaymentProvider.stripe,
      );
    });

    test('currency comparison is case-insensitive', () {
      expect(
        config.resolveProvider(const PaymentResolveContext(currency: 'ghs')),
        PaymentProvider.paystack,
      );
      expect(
        config.resolveProvider(const PaymentResolveContext(currency: 'Usd')),
        PaymentProvider.stripe,
      );
    });
  });

  group('Constructor asserts', () {
    // Phase 17: bps + int kobo bounds.
    test('rejects deposit bps outside [0, 10000]', () {
      expect(
        () => PaymentConfig(appScheme: 'x', depositBps: -1),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => PaymentConfig(appScheme: 'x', depositBps: 15000),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects platform fee bps outside [0, 10000]', () {
      expect(
        () => PaymentConfig(appScheme: 'x', platformFeeBps: -1),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => PaymentConfig(appScheme: 'x', platformFeeBps: 10001),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects max below min withdrawal', () {
      expect(
        () => PaymentConfig(
          appScheme: 'x',
          minWithdrawalAmountMinor: 10000,
          maxWithdrawalAmountMinor: 5000,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects non-positive minimum withdrawal', () {
      expect(
        () => PaymentConfig(appScheme: 'x', minWithdrawalAmountMinor: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects negative retry count', () {
      expect(
        () => PaymentConfig(appScheme: 'x', providerApiRetries: -1),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('PaymentErrorInfo / PaymentSuccessInfo', () {
    test('PaymentSuccessInfo holds the contract callers depend on', () {
      const info = PaymentSuccessInfo(
        reference: 'booking_abc_123',
        // Phase 17: int kobo. 50 GHS = 5000 kobo.
        amountMinor: 5000,
        currency: 'GHS',
        raw: {'id': 'b1'},
      );
      expect(info.reference, 'booking_abc_123');
      expect(info.amountMinor, 5000);
      expect(info.currency, 'GHS');
      expect(info.raw['id'], 'b1');
    });

    test('PaymentErrorInfo carries category for host-side branching', () {
      const info = PaymentErrorInfo(
        message: 'card declined',
        category: PaymentErrorCategory.declined,
        reference: 'booking_abc_123',
      );
      expect(info.category, PaymentErrorCategory.declined);
      expect(info.reference, 'booking_abc_123');
    });
  });
}
