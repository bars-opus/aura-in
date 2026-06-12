// lib/features/payment/presentation/controllers/payment_controller.dart

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/logging/app_logger.dart';
import 'package:nano_embryo/payment/config/payment_config.dart';
import 'package:nano_embryo/payment/presentation/widgets/payment_webview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Typedef for the function that launches the payment WebView and returns
/// whether the user reached the success deep-link. Injected into
/// [PaymentController] so tests can substitute a fake without going through
/// Navigator.push.
typedef WebViewLauncher = Future<bool> Function({
  required BuildContext context,
  required String authorizationUrl,
  required String reference,
  required String provider,
});

/// Immutable snapshot of the args passed to [PaymentController.processPayment]
/// so [PaymentController.retryLast] can re-invoke it without the caller
/// having to remember the values.
class _PaymentIntent {
  const _PaymentIntent({
    required this.shopId,
    required this.userId,
    required this.userEmail,
    required this.services,
    required this.startTime,
    required this.endTime,
    required this.actualEndTime,
    required this.totalAmount,
    required this.depositAmount,
    required this.platformFee,
    required this.paymentProvider,
    this.promotionId,
    this.promoAmountOff,
  });

  final String shopId;
  final String userId;
  final String userEmail;
  final List<Map<String, dynamic>> services;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime actualEndTime;
  final double totalAmount;
  final double depositAmount;
  final double platformFee;
  final String paymentProvider;

  /// Phase 13 — the promo code id resolved by validate_and_apply_promo.
  /// Null when no code was applied. Webhook reads this from
  /// pending_payments.booking_data and calls redeem_promotion after the
  /// booking row is created.
  final String? promotionId;

  /// Phase 13 — the discount amount in currency-major units. Server
  /// already authoritative; this is the value we round-trip back to the
  /// webhook so it can pass the same amount into redeem_promotion.
  final double? promoAmountOff;
}

class PaymentController
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final SupabaseClient _supabase;
  final PaymentConfig _config;
  final WebViewLauncher _webViewLauncher;
  _PaymentIntent? _lastIntent;

  PaymentController(
    this._supabase,
    this._config, {
    WebViewLauncher? webViewLauncher,
  })  : _webViewLauncher = webViewLauncher ?? _defaultWebViewLauncher,
        super(const AsyncValue.data(null));

  static Future<bool> _defaultWebViewLauncher({
    required BuildContext context,
    required String authorizationUrl,
    required String reference,
    required String provider,
  }) async {
    final completer = Completer<bool>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentWebView(
          url: authorizationUrl,
          reference: reference,
          provider: provider,
          onComplete: (success) {
            if (!completer.isCompleted) completer.complete(success);
          },
        ),
      ),
    );
    return completer.future;
  }

  Future<Map<String, dynamic>?> processPayment({
    required String shopId,
    required String userId,
    required String userEmail,
    required List<Map<String, dynamic>> services,
    required DateTime startTime,
    required DateTime endTime,
    required DateTime actualEndTime,
    required double totalAmount,
    required double depositAmount,
    required double platformFee,
    required String paymentProvider,
    required BuildContext context,
    String? promotionId,
    double? promoAmountOff,
  }) async {
    _lastIntent = _PaymentIntent(
      shopId: shopId,
      userId: userId,
      userEmail: userEmail,
      services: services,
      startTime: startTime,
      endTime: endTime,
      actualEndTime: actualEndTime,
      totalAmount: totalAmount,
      depositAmount: depositAmount,
      platformFee: platformFee,
      paymentProvider: paymentProvider,
      promotionId: promotionId,
      promoAmountOff: promoAmountOff,
    );
    state = const AsyncValue.loading();

    try {
      // F-P0-3: idempotency key incorporates cart fingerprint so that a
      // retry against a changed cart (different services, different promo,
      // different total) reaches the edge function as a NEW intent rather
      // than replaying the stale one. Without this, a user who fails
      // payment, edits the cart, and retries at the same start_time
      // silently gets back the original (now-stale) intent.
      final cartFingerprint = sha256
          .convert(utf8.encode(jsonEncode([
            for (final s in services)
              [s['slotId'], s['workerId'], s['priceAtBooking']],
            totalAmount,
            depositAmount,
            promotionId,
            promoAmountOff,
          ])))
          .toString()
          .substring(0, 16);
      final idempotencyKey =
          '${shopId}_${userId}_${startTime.millisecondsSinceEpoch}_$cartFingerprint';

      final requestBody = {
        'shopId': shopId,
        'userId': userId,
        'userEmail': userEmail,
        'services': services,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'actualEndTime': actualEndTime.toIso8601String(),
        'totalAmount': totalAmount,
        'depositAmount': depositAmount,
        'platformFee': platformFee,
        'paymentMethod': paymentProvider,
        'paymentProvider': paymentProvider,
        'idempotencyKey': idempotencyKey,
        'successUrl': _config.successDeepLink,
        'cancelUrl': _config.cancelDeepLink,
        // Phase 13: promo identity carried through pending_payments.booking_data
        // so the success webhook can call redeem_promotion. Null when no code
        // applied — webhook reads `if (bookingData.promotionId)` before redeeming.
        if (promotionId != null) 'promotionId': promotionId,
        if (promoAmountOff != null) 'promoAmountOff': promoAmountOff,
      };

      final response = await _supabase.functions.invoke(
        _config.createIntentFunctionName,
        body: requestBody,
      );

      final data = response.data;
      if (data == null || data is! Map<String, dynamic>) {
        AppLogger.warn(
          'payment.create_intent.unexpected_response',
          fields: {
            'function': _config.createIntentFunctionName,
            'shape': data.runtimeType.toString(),
          },
        );
        await _fireFailure(
          message: 'Could not initialize payment.',
          category: PaymentErrorCategory.serverError,
          context: context,
        );
        state = AsyncValue.data(null);
        return null;
      }

      if (data['success'] != true) {
        final err = (data['error'] ?? 'Unknown error').toString();
        AppLogger.warn(
          'payment.create_intent.failed',
          fields: {
            'function': _config.createIntentFunctionName,
            'category': _classifyServerError(err).name,
          },
        );
        await _fireFailure(
          message: err,
          category: _classifyServerError(err),
          context: context,
        );
        state = AsyncValue.data(null);
        return null;
      }

      final reference =
          (data['reference'] ?? data['paymentIntentId']) as String?;
      final authorizationUrl = data['authorizationUrl'] as String?;

      if (reference == null || authorizationUrl == null) {
        AppLogger.warn(
          'payment.create_intent.missing_fields',
          fields: {
            'function': _config.createIntentFunctionName,
            'has_reference': (reference != null).toString(),
            'has_url': (authorizationUrl != null).toString(),
          },
        );
        await _fireFailure(
          message: 'Could not initialize payment.',
          category: PaymentErrorCategory.serverError,
          context: context,
        );
        state = AsyncValue.data(null);
        return null;
      }

      final webViewSuccess = await _showPaymentWebView(
        context: context,
        authorizationUrl: authorizationUrl,
        reference: reference,
        provider: paymentProvider,
      );

      // Poll regardless of WebView outcome — user may have paid via MoMo USSD
      // and dismissed manually.
      final bookingResult = await _confirmPayment(
        reference,
        longPoll: webViewSuccess,
      );

      if (bookingResult != null) {
        state = AsyncValue.data(bookingResult);
        await _fireSuccess(reference, bookingResult);
        return bookingResult;
      }

      // Final escalation: ask the provider directly.
      final verifiedBooking = await _verifyWithProvider(
        reference,
        paymentProvider,
      );
      if (verifiedBooking != null) {
        state = AsyncValue.data(verifiedBooking);
        await _fireSuccess(reference, verifiedBooking);
        return verifiedBooking;
      }

      await _fireFailure(
        reference: reference,
        message: webViewSuccess
            ? 'Payment received but confirmation timed out. Check your bookings shortly.'
            : 'Payment was cancelled or did not complete.',
        category: webViewSuccess
            ? PaymentErrorCategory.network
            : PaymentErrorCategory.cancelled,
        context: context,
      );
      state = AsyncValue.data(null);
      return null;
    } catch (e, st) {
      AppLogger.warn(
        'payment.process.error',
        fields: {
          'function': _config.createIntentFunctionName,
          'error': e.toString(),
        },
      );
      await _fireFailure(
        message: 'Could not initialize payment.',
        category: PaymentErrorCategory.unknown,
        context: context,
      );
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Re-invokes the last [processPayment] call with the same args.
  /// No-op if no intent is cached (e.g., user opened the failure screen
  /// after app restart).
  Future<Map<String, dynamic>?> retryLast(BuildContext context) async {
    final intent = _lastIntent;
    if (intent == null) {
      AppLogger.warn(
        'payment.retry_last.no_intent',
        fields: const {'reason': 'cache_empty'},
      );
      return null;
    }
    return processPayment(
      shopId: intent.shopId,
      userId: intent.userId,
      userEmail: intent.userEmail,
      services: intent.services,
      startTime: intent.startTime,
      endTime: intent.endTime,
      actualEndTime: intent.actualEndTime,
      totalAmount: intent.totalAmount,
      depositAmount: intent.depositAmount,
      platformFee: intent.platformFee,
      paymentProvider: intent.paymentProvider,
      context: context,
      promotionId: intent.promotionId,
      promoAmountOff: intent.promoAmountOff,
    );
  }

  Future<bool> _showPaymentWebView({
    required BuildContext context,
    required String authorizationUrl,
    required String reference,
    required String provider,
  }) {
    return _webViewLauncher(
      context: context,
      authorizationUrl: authorizationUrl,
      reference: reference,
      provider: provider,
    );
  }

  /// Polls the `bookings` table for a row matching the reference.
  ///
  /// Attempt 0 is immediate — if the webhook already fired the booking exists
  /// with no wait. Subsequent attempts back off by [PaymentConfig.dbConfirmInterval].
  Future<Map<String, dynamic>?> _confirmPayment(
    String paymentIntentId, {
    bool longPoll = true,
  }) async {
    final maxAttempts = longPoll
        ? _config.dbConfirmAttemptsAfterWebViewSuccess
        : _config.dbConfirmAttemptsAfterWebViewCancel;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (attempt > 0) await Future.delayed(_config.dbConfirmInterval);

      try {
        final result = await _supabase
            .from('bookings')
            .select('*')
            .eq('payment_intent_id', paymentIntentId)
            .maybeSingle();

        if (result != null) return result;
      } catch (e) {
        // Transient — try again next loop.
        AppLogger.warn(
          'payment.confirm.poll_error',
          fields: {
            'payment_intent_id': paymentIntentId,
            'attempt': attempt,
            'error': e.toString(),
          },
        );
      }
    }

    return null;
  }

  /// Calls the verify-payment edge function as the authoritative fallback.
  Future<Map<String, dynamic>?> _verifyWithProvider(
    String reference,
    String provider,
  ) async {
    try {
      final response = await _supabase.functions.invoke(
        _config.verifyPaymentFunctionName,
        body: {'reference': reference, 'provider': provider},
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) return null;
      if (data['success'] != true) {
        AppLogger.warn(
          'payment.verify.not_confirmed',
          fields: {
            'function': _config.verifyPaymentFunctionName,
            'provider': provider,
          },
        );
        return null;
      }

      final booking = data['booking'];
      return booking is Map<String, dynamic> ? booking : null;
    } catch (e) {
      AppLogger.warn(
        'payment.verify.error',
        fields: {
          'function': _config.verifyPaymentFunctionName,
          'error': e.toString(),
        },
      );
      return null;
    }
  }

  PaymentErrorCategory _classifyServerError(String message) {
    final m = message.toLowerCase();
    if (m.contains('rate limit') || m.contains('too many')) {
      return PaymentErrorCategory.validation;
    }
    if (m.contains('validation') ||
        m.contains('mismatch') ||
        m.contains('invalid')) {
      return PaymentErrorCategory.validation;
    }
    if (m.contains('unauthorized') || m.contains('forbidden')) {
      return PaymentErrorCategory.validation;
    }
    if (m.contains('network') || m.contains('timeout')) {
      return PaymentErrorCategory.network;
    }
    return PaymentErrorCategory.serverError;
  }

  Future<void> _fireSuccess(
    String reference,
    Map<String, dynamic> booking,
  ) async {
    final hook = _config.onPaymentSuccess;
    if (hook == null) return;
    try {
      await hook(
        PaymentSuccessInfo(
          reference: reference,
          amount: (booking['total_amount'] as num?)?.toDouble() ?? 0,
          currency: _config.defaultCurrency,
          raw: booking,
        ),
      );
    } catch (e) {
      AppLogger.warn(
        'payment.success_hook.threw',
        fields: {'error': e.toString()},
      );
    }
  }

  Future<void> _fireFailure({
    String? reference,
    required String message,
    required PaymentErrorCategory category,
    BuildContext? context,
  }) async {
    final info = PaymentErrorInfo(
      reference: reference,
      message: message,
      category: category,
    );

    final hook = _config.onPaymentFailure;
    if (hook != null) {
      try {
        await hook(info);
      } catch (e) {
        AppLogger.warn(
          'payment.failure_hook.threw',
          fields: {'error': e.toString()},
        );
      }
    }

    final builder = _config.paymentErrorBuilder;
    if (builder != null && context != null && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (ctx) => builder(ctx, info)),
      );
    }
  }
}

final paymentControllerProvider = StateNotifierProvider<PaymentController,
    AsyncValue<Map<String, dynamic>?>>(
  (ref) => PaymentController(
    Supabase.instance.client,
    ref.watch(paymentConfigProvider),
  ),
);
