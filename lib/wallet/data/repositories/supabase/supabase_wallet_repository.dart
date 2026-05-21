// lib/features/wallet/data/repositories/supabase/supabase_wallet_repository.dart

import 'package:nano_embryo/payment/config/payment_config.dart';
import 'package:nano_embryo/wallet/data/exceptions/wallet_exceptions.dart';
import 'package:nano_embryo/wallet/data/models/wallet_model.dart';
import 'package:nano_embryo/wallet/data/models/wallet_transaction_model.dart';
import 'package:nano_embryo/wallet/data/models/withdrawal_request_model.dart';
import 'package:nano_embryo/wallet/data/repositories/wallet_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseWalletRepository implements WalletRepository {
  final SupabaseClient _client;
  final PaymentConfig _config;

  SupabaseWalletRepository(this._client, this._config);

  @override
  Future<WalletModel> getWallet(String shopId) async {
    try {
      final response =
          await _client
              .from('wallets')
              .select()
              .eq('shop_id', shopId)
              .maybeSingle();

      if (response == null) {
        // Try to create wallet
        try {
          final newWallet =
              await _client
                  .from('wallets')
                  .insert({'shop_id': shopId})
                  .select()
                  .single();
          return WalletModel.fromJson(newWallet);
        } catch (insertError) {
          // If insert fails (RLS), try one more select (wallet might have been created by trigger)
          final retryResponse =
              await _client
                  .from('wallets')
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
    DateTime? before,
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
      if (before != null) {
        query = query.lt('created_at', before.toIso8601String());
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
      // 1. Validate amount against configured bounds
      final min = _config.minWithdrawalAmount;
      final max = _config.maxWithdrawalAmount;
      final currency = _config.defaultCurrency;
      if (amount < min) {
        throw WalletException(
          'Minimum withdrawal amount is $currency ${min.toStringAsFixed(0)}',
        );
      }
      if (amount > max) {
        throw WalletException(
          'Maximum withdrawal per transaction is $currency ${max.toStringAsFixed(0)}',
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

      // 4. Date-scoped idempotency key — one withdrawal per shop per day at this
      //    amount, naturally enforcing the daily limit and preventing retries from
      //    creating duplicate requests.
      final today = DateTime.now().toUtc();
      final dateStamp =
          '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
      final idempotencyKey = 'wd_${shopId}_${dateStamp}_${amount.toInt()}';

      // 5. Call database function to create withdrawal request
      final result = await _client.rpc(
        'create_withdrawal_request',
        params: {
          'p_shop_id': shopId,
          'p_amount': amount,
          'p_payment_provider': paymentInfo['provider'],
          'p_transfer_recipient_id': paymentInfo['recipient_id'],
          'p_idempotency_key': idempotencyKey,
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
          'Daily withdrawal limit of ${_config.defaultCurrency} ${_config.maxWithdrawalAmount.toStringAsFixed(0)} exceeded. You can only make one withdrawal per day.',
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

      // Check Paystack — recipient_id alone is sufficient (subaccount_code is
      // intentionally null for mobile money shops).
      if (response['paystack_verified'] == true &&
          response['paystack_recipient_id'] != null &&
          (response['paystack_recipient_id'] as String).isNotEmpty) {
        return {
          'provider': 'paystack',
          'recipient_id': response['paystack_recipient_id'],
          'recipient_verified': true,
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

  @override
  Stream<List<WithdrawalRequestModel>> watchDeadLetterWithdrawals(
    String shopId,
  ) async* {
    // Emit immediately, then every 30 seconds. Polling is intentional —
    // dead_letter is rare and Realtime subscriptions add lifecycle complexity
    // for a low-frequency event.
    while (true) {
      try {
        final data = await _client
            .from('withdrawal_requests')
            .select()
            .eq('shop_id', shopId)
            .eq('status', 'dead_letter')
            .order('updated_at', ascending: false);
        yield (data as List)
            .map((row) => WithdrawalRequestModel.fromJson(row))
            .toList();
      } catch (e) {
        // Yield empty on transient errors — banner just hides.
        yield const [];
      }
      await Future.delayed(const Duration(seconds: 30));
    }
  }
}
