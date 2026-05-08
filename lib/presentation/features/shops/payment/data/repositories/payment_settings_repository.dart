// lib/features/dashboard/data/repositories/payment_settings_repository.dart
import 'package:nano_embryo/presentation/features/shops/payment/data/models/payment_settings_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentSettingsRepository {
  final SupabaseClient _supabase;
  static const String _table = 'payment_settings';
  static const String _edgeFunction = 'paystack-subaccount';

  PaymentSettingsRepository({required SupabaseClient supabaseClient})
    : _supabase = supabaseClient;

  // ============================================================================
  // Database Operations
  // ============================================================================

  Future<PaymentSettings?> getSettings(String shopId) async {
    try {
      print('📡 Fetching payment settings for shop: $shopId');

      final response =
          await _supabase
              .from(_table)
              .select()
              .eq('shop_id', shopId)
              .maybeSingle();

      if (response == null) {
        print('⚠️ No payment settings found for shop: $shopId');
        return null;
      }

      return PaymentSettings.fromJson(response);
    } catch (e) {
      print('❌ Failed to fetch payment settings: $e');
      throw Exception('Failed to fetch payment settings: $e');
    }
  }

  Future<PaymentSettings> createSettings(PaymentSettings settings) async {
    try {
      final response =
          await _supabase
              .from(_table)
              .insert(settings.toJson())
              .select()
              .single();

      return PaymentSettings.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create payment settings: $e');
    }
  }

  Future<PaymentSettings> updateSettings(PaymentSettings settings) async {
    try {
      final response =
          await _supabase
              .from(_table)
              .update(settings.toJson())
              .eq('shop_id', settings.shopId)
              .select()
              .single();

      return PaymentSettings.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update payment settings: $e');
    }
  }

  Future<PaymentSettings> saveSettings(PaymentSettings settings) async {
    final existing = await getSettings(settings.shopId);
    if (existing == null) {
      return await createSettings(settings);
    } else {
      return await updateSettings(settings);
    }
  }

  // ============================================================================
  // Paystack Edge Function Calls
  // ============================================================================

  /// Fetch available banks for a given currency code (e.g., 'GHS', 'NGN')
  Future<List<Map<String, String>>> fetchBanks(String currencyCode) async {
    try {
      print('🔍 Fetching banks for currency: $currencyCode');

      final response = await _supabase.functions.invoke(
        _edgeFunction,
        body: {'action': 'fetch-banks', 'currencyCode': currencyCode},
      );

      final raw = response.data;
      if (raw is! List) throw Exception('Invalid bank list response');

      final banks =
          raw
              .map((item) {
                return {
                  'code': item['code']?.toString() ?? '',
                  'name': item['name']?.toString() ?? '',
                };
              })
              .where((b) => b['code']!.isNotEmpty && b['name']!.isNotEmpty)
              .toList();

      print('✅ Found ${banks.length} banks');
      return banks;
    } catch (e) {
      print('❌ Failed to fetch banks: $e');
      throw Exception('Failed to fetch banks: $e');
    }
  }

  /// Create a Paystack subaccount for a shop

  /// Create a Paystack subaccount (simplified - matches legacy code)
  Future<Map<String, dynamic>> createSubaccount({
    required String shopId,
    required String businessName,
    required String
    bankCode, // This can be bank code OR mobile money code (058, 057, etc.)
    required String accountNumber,
    required String currencyCode,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        _edgeFunction,
        body: {
          'action': 'create-subaccount',
          'shopId': shopId,
          'businessName': businessName,
          'bankCode': bankCode,
          'accountNumber': accountNumber,
          'currencyCode': currencyCode,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Failed to create subaccount');
      }

      return {
        'success': true,
        'subaccount_code': data['subaccount_code'],
        'recipient_code': data['recipient_code'],
      };
    } catch (e) {
      throw Exception('Failed to create Paystack subaccount: $e');
    }
  }

  /// Get the status of a shop's Paystack subaccount
  Future<Map<String, dynamic>> getSubaccountStatus(String shopId) async {
    try {
      print('🔍 Getting subaccount status for shop: $shopId');

      final response = await _supabase.functions.invoke(
        _edgeFunction,
        body: {'action': 'get-status', 'shopId': shopId},
      );

      final data = response.data as Map<String, dynamic>;
      return {
        'connected': data['connected'] ?? false,
        'verified': data['verified'] ?? false,
        'has_recipient': data['has_recipient'] ?? false,
      };
    } catch (e) {
      print('❌ Failed to get subaccount status: $e');
      throw Exception('Failed to get subaccount status: $e');
    }
  }

  /// Disconnect a shop's Paystack subaccount
  Future<void> disconnectSubaccount(String shopId) async {
    try {
      print('🔍 Disconnecting subaccount for shop: $shopId');

      await _supabase.functions.invoke(
        _edgeFunction,
        body: {'action': 'disconnect', 'shopId': shopId},
      );

      print('✅ Subaccount disconnected');
    } catch (e) {
      print('❌ Failed to disconnect subaccount: $e');
      throw Exception('Failed to disconnect Paystack subaccount: $e');
    }
  }
}
