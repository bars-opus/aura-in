// lib/features/payment/presentation/controllers/payment_controller.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/payment/presentation/widgets/payment_webview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentController
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final SupabaseClient _supabase;

  PaymentController(this._supabase) : super(const AsyncValue.data(null));

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
  }) async {
    state = const AsyncValue.loading();

    try {
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
        'idempotencyKey': DateTime.now().millisecondsSinceEpoch.toString(),
        'successUrl': 'nanoembryo://payment-success',
        'cancelUrl': 'nanoembryo://payment-cancelled',
      };

      final response = await _supabase.functions.invoke(
        'create-booking',
        body: requestBody,
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        state = AsyncValue.data(null);
        return null;
      }

      // Show WebView for payment (both Stripe and Paystack)
      final paymentSuccess = await _showPaymentWebView(
        context: context,
        authorizationUrl: data['authorizationUrl'],
        provider: paymentProvider,
      );

      if (!paymentSuccess) {
        state = AsyncValue.data(null);
        return null;
      }

      // Payment successful, get the booking
      final bookingResult = await _confirmPayment(
        data['paymentIntentId'],
        paymentProvider,
      );

      state = AsyncValue.data(bookingResult);
      return bookingResult;
    } catch (e) {
      print(e);
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<bool> _showPaymentWebView({
    required BuildContext context,
    required String authorizationUrl,
    required String provider,
  }) async {
    final completer = Completer<bool>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PaymentWebView(
              url: authorizationUrl,
              provider: provider,
              onComplete: (success) {
                completer.complete(success);
              },
            ),
      ),
    );

    return completer.future;
  }

  Future<Map<String, dynamic>> _confirmPayment(
    String paymentIntentId,
    String provider,
  ) async {
    // Give webhook a moment if it hasn't fired yet
    await Future.delayed(const Duration(seconds: 2));

    // Read the booking that the webhook already created
    final result =
        await _supabase
            .from('bookings')
            .select('*')
            .eq('payment_intent_id', paymentIntentId)
            .maybeSingle();

    if (result != null) {
      return result;
    }

    // Fallback: call edge function if booking not found yet
    final response = await _supabase.functions.invoke(
      'confirm-payment',
      body: {'payment_intent_id': paymentIntentId, 'provider': provider},
    );
    return response.data as Map<String, dynamic>;
  }
}

final paymentControllerProvider =
    StateNotifierProvider<PaymentController, AsyncValue<Map<String, dynamic>?>>(
      (ref) {
        final supabase = Supabase.instance.client;
        return PaymentController(supabase);
      },
    );
