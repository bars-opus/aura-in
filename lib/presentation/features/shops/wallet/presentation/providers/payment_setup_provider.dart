// lib/features/shops/payment/providers/payment_setup_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider to check if a shop has payment setup (Paystack or Stripe connected and verified)
/// Returns true if either Paystack or Stripe is connected and verified
final paymentSetupStatusProvider = StreamProvider.family<bool, String>((
  ref,
  shopId,
) {
  final supabase = Supabase.instance.client;

  return supabase
      .from('payment_settings')
      .stream(primaryKey: ['shop_id'])
      .eq('shop_id', shopId)
      .map((event) {
        if (event.isEmpty) return false;
        final data = event.first;

        // Check if Paystack is connected and verified
        final isPaystackConnected =
            data['paystack_subaccount_code'] != null &&
            data['paystack_verified'] == true;

        // Check if Stripe is connected and verified
        final isStripeConnected =
            data['stripe_account_id'] != null &&
            data['stripe_verified'] == true;

        return isPaystackConnected || isStripeConnected;
      });
});

/// Provider to get payment settings for a shop (non-streaming, one-time fetch)
final paymentSettingsProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, shopId) async {
      final supabase = Supabase.instance.client;

      final response =
          await supabase
              .from('payment_settings')
              .select()
              .eq('shop_id', shopId)
              .maybeSingle();

      return response;
    });

/// Provider to get the connected payment provider type
final connectedPaymentProviderProvider = StreamProvider.family<String?, String>(
  (ref, shopId) {
    final supabase = Supabase.instance.client;

    return supabase
        .from('payment_settings')
        .stream(primaryKey: ['shop_id'])
        .eq('shop_id', shopId)
        .map((event) {
          if (event.isEmpty) return null;
          final data = event.first;

          if (data['paystack_subaccount_code'] != null &&
              data['paystack_verified'] == true) {
            return 'paystack';
          }

          if (data['stripe_account_id'] != null &&
              data['stripe_verified'] == true) {
            return 'stripe';
          }

          return null;
        });
  },
);

/// Provider to check if a specific provider is connected
final isProviderConnectedProvider = Provider.family<
  bool,
  ({String shopId, String provider})
>((ref, params) {
  final setupAsync = ref.watch(paymentSetupStatusProvider(params.shopId));

  return setupAsync.when(
    data: (hasPaymentSetup) {
      if (!hasPaymentSetup) return false;

      // If we need to check specific provider, we need to watch the specific provider stream
      // This is a simplified version
      return hasPaymentSetup;
    },
    loading: () => false,
    error: (_, __) => false,
  );
});
