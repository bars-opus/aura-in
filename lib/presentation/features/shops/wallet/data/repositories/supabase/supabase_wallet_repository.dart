// lib/features/wallet/data/repositories/supabase/supabase_wallet_repository.dart

import 'dart:io';

import 'package:nano_embryo/presentation/features/shops/wallet/data/exceptions/wallet_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/data/models/wallet_model.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/data/models/wallet_transaction_model.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/data/models/withdrawal_request_model.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/data/repositories/wallet_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseWalletRepository implements WalletRepository {
  final SupabaseClient _client;

  SupabaseWalletRepository(this._client);

  @override
  Future<WalletModel> getWallet(String shopId) async {
    try {
      final response =
          await _client
              .from('shop_wallets')
              .select()
              .eq('shop_id', shopId)
              .maybeSingle();

      if (response == null) {
        // Try to create wallet
        try {
          final newWallet =
              await _client
                  .from('shop_wallets')
                  .insert({'shop_id': shopId})
                  .select()
                  .single();
          return WalletModel.fromJson(newWallet);
        } catch (insertError) {
          // If insert fails (RLS), try one more select (wallet might have been created by trigger)
          final retryResponse =
              await _client
                  .from('shop_wallets')
                  .select()
                  .eq('shop_id', shopId)
                  .maybeSingle();

          if (retryResponse == null) {
            throw WalletException(
              'Unable to create or fetch wallet for shop: $shopId',
            );
          }
          return WalletModel.fromJson(retryResponse);
        }
      }

      return WalletModel.fromJson(response);
    } catch (e) {
      throw WalletException('Failed to fetch wallet: $e');
    }
  }

  @override
  Future<List<WalletTransactionModel>> getTransactions({
    required String shopId,
    int? limit = 50,
    int? offset,
    DateTime? fromDate,
    DateTime? toDate,
    TransactionType? type,
  }) async {
    try {
      // Use dynamic to handle type changes during method chaining
      dynamic query = _client
          .from('wallet_transactions')
          .select()
          .eq('shop_id', shopId);

      // Apply filters
      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('created_at', toDate.toIso8601String());
      }
      if (type != null) {
        query = query.eq('type', type.value);
      }

      // Apply sorting (this changes the type)
      query = query.order('created_at', ascending: false);

      // Apply pagination
      if (offset != null && limit != null) {
        query = query.range(offset, offset + limit - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return (response as List)
          .map((json) => WalletTransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw WalletException('Failed to fetch transactions: $e');
    }
  }

  @override
  Future<WalletTransactionModel> addTransaction({
    required String shopId,
    required double amount,
    required TransactionType type,
    String? bookingId,
    String? description,
    String? reference,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Use atomic RPC function to prevent race conditions
      final result = await _client.rpc(
        'add_wallet_transaction',
        params: {
          'p_shop_id': shopId,
          'p_amount': amount,
          'p_type': type.value,
          'p_booking_id': bookingId,
          'p_description': description,
          'p_reference': reference,
          'p_metadata': metadata ?? {},
        },
      );

      return WalletTransactionModel.fromJson(result);
    } on PostgrestException catch (e) {
      if (e.message?.contains('Insufficient balance') ?? false) {
        throw InsufficientBalanceException(0, amount);
      }
      throw WalletException('Failed to add transaction: ${e.message}');
    } catch (e) {
      throw WalletException('Failed to add transaction: $e');
    }
  }

  @override
  Future<WithdrawalRequestModel> requestWithdrawal({
    required String shopId,
    required double amount,
  }) async {
    try {
      // 1. Validate amount
      if (amount < 50) {
        throw WalletException('Minimum withdrawal amount is GHS 50');
      }
      if (amount > 5000) {
        throw WalletException(
          'Maximum withdrawal per transaction is GHS 5,000',
        );
      }

      // 2. Get shop's payment provider and recipient
      final paymentInfo = await _getShopPaymentInfo(shopId);

      if (paymentInfo == null) {
        throw WalletException(
          'No connected payment method found. Please connect Paystack or Stripe first.',
        );
      }

      if (!paymentInfo['recipient_verified']) {
        throw WalletException(
          'Your payment recipient is not verified. Please reconnect your payment account.',
        );
      }

      // 3. Get current wallet balance to check if sufficient
      final wallet = await getWallet(shopId);
      final availableBalance = wallet.balance - wallet.pendingWithdrawals;

      if (availableBalance < amount) {
        throw InsufficientBalanceException(availableBalance, amount);
      }

      // 4. Generate idempotency key
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final idempotencyKey = 'wd_${shopId}_${timestamp}_${amount.toInt()}';

      // 5. Get IP address and user agent
      final ipAddress = await _getClientIp();
      final userAgent = Platform.operatingSystem;

      // 6. Call database function to create withdrawal request
      final result = await _client.rpc(
        'create_withdrawal_request',
        params: {
          'p_shop_id': shopId,
          'p_amount': amount,
          'p_payment_provider': paymentInfo['provider'],
          'p_transfer_recipient_id': paymentInfo['recipient_id'],
          'p_idempotency_key': idempotencyKey,
          'p_ip_address': ipAddress,
          'p_user_agent': userAgent,
        },
      );

      // 7. Fetch the created withdrawal request
      final withdrawalResponse =
          await _client
              .from('withdrawal_requests')
              .select()
              .eq('id', result)
              .single();

      return WithdrawalRequestModel.fromJson(withdrawalResponse);
    } on InsufficientBalanceException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.message?.contains('Insufficient balance') ?? false) {
        throw InsufficientBalanceException(0, amount);
      }
      if (e.message?.contains('Daily withdrawal limit') ?? false) {
        throw WalletException(
          'Daily withdrawal limit of GHS 5,000 exceeded. You can only make one withdrawal per day.',
        );
      }
      if (e.message?.contains('duplicate key') ?? false) {
        throw WalletException(
          'Duplicate withdrawal request detected. Please wait a few minutes and try again.',
        );
      }
      throw WalletException('Failed to request withdrawal: ${e.message}');
    } catch (e) {
      throw WalletException('Failed to request withdrawal: $e');
    }
  }

  Future<Map<String, dynamic>?> _getShopPaymentInfo(String shopId) async {
    try {
      // Get payment settings
      final response =
          await _client
              .from('payment_settings')
              .select()
              .eq('shop_id', shopId)
              .maybeSingle();

      if (response == null) return null;

      // Check Paystack first
      if (response['paystack_subaccount_code'] != null &&
          response['paystack_verified'] == true &&
          response['paystack_recipient_id'] != null &&
          response['paystack_recipient_id'].toString().isNotEmpty) {
        return {
          'provider': 'paystack',
          'recipient_id': response['paystack_recipient_id'],
          'recipient_verified':
              response['paystack_recipient_verified'] ?? false,
        };
      }

      // Check Stripe
      if (response['stripe_account_id'] != null &&
          response['stripe_verified'] == true &&
          response['stripe_account_id'].toString().isNotEmpty) {
        return {
          'provider': 'stripe',
          'recipient_id': response['stripe_account_id'],
          'recipient_verified': true,
        };
      }

      return null;
    } catch (e) {
      print('Error fetching payment info: $e');
      return null;
    }
  }

  Future<String> _getClientIp() async {
    try {
      // Try to get IP from Supabase Edge Function
      final response = await _client.functions.invoke('get-ip');
      final data = response.data;
      if (data is Map<String, dynamic> && data['ip'] != null) {
        return data['ip'].toString();
      }
      return 'unknown';
    } catch (e) {
      // Fallback to local IP or unknown
      return 'unknown';
    }
  }

  @override
  Future<List<WithdrawalRequestModel>> getWithdrawalHistory({
    required String shopId,
    int? limit = 20,
    WithdrawalStatus? status,
  }) async {
    try {
      // Use dynamic to handle type changes during method chaining
      dynamic query = _client
          .from('withdrawal_requests')
          .select()
          .eq('shop_id', shopId);

      if (status != null) {
        query = query.eq('status', status.value);
      }

      // Apply sorting (this changes the type)
      query = query.order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return (response as List)
          .map((json) => WithdrawalRequestModel.fromJson(json))
          .toList();
    } catch (e) {
      throw WalletException('Failed to fetch withdrawal history: $e');
    }
  }

  @override
  Future<WithdrawalRequestModel> getWithdrawalRequest(
    String withdrawalId,
  ) async {
    try {
      final response =
          await _client
              .from('withdrawal_requests')
              .select()
              .eq('id', withdrawalId)
              .single();

      return WithdrawalRequestModel.fromJson(response);
    } catch (e) {
      throw WalletException('Failed to fetch withdrawal request: $e');
    }
  }

  @override
  Future<double> getAvailableBalance(String shopId) async {
    try {
      final wallet = await getWallet(shopId);
      return wallet.balance - wallet.pendingWithdrawals;
    } catch (e) {
      throw WalletException('Failed to get available balance: $e');
    }
  }
}
