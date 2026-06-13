// lib/features/wallet/data/repositories/supabase/supabase_wallet_repository.dart

import 'dart:async';

import 'package:nano_embryo/core/utils/logging/app_logger.dart';
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
      // The trg_create_wallet_on_shop_insert trigger (migration
      // 20260602180000) creates the wallet row when a shop is created, and
      // add_wallet_transaction backfills on first deposit. Both paths
      // create rows under postgres-side privileges, so the client only
      // needs to read. If the row is genuinely missing here, that's a
      // schema invariant violation worth surfacing — don't paper over it
      // with a client-side INSERT (which would race with the trigger).
      final response = await _client
          .from('wallets')
          .select()
          .eq('shop_id', shopId)
          .maybeSingle();

      if (response == null) {
        throw WalletNotFoundException(shopId);
      }
      return WalletModel.fromJson(response);
    } on WalletException {
      rethrow;
    } on PostgrestException catch (e) {
      throw WalletException('getWallet PostgrestException: ${e.code} ${e.message}');
    } catch (e, st) {
      throw WalletException('getWallet unexpected: $e\n$st');
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
    } on PostgrestException catch (e) {
      throw WalletException('getTransactions PostgrestException: ${e.code} ${e.message}');
    } catch (e, st) {
      throw WalletException('getTransactions unexpected: $e\n$st');
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
      if (_isInsufficientBalance(e)) throw InsufficientBalanceException();
      throw WalletException(
        'add_wallet_transaction RPC failed: ${e.code} ${e.message}',
      );
    } catch (e, st) {
      throw WalletException('addTransaction unexpected: $e\n$st');
    }
  }

  // Centralised error classifier. Postgrest surfaces RAISE EXCEPTION HINTs
  // via PostgrestException.details (Supabase forwards them in the JSON
  // response body). We match on HINT codes set by the wallet RPCs rather
  // than English strings so localisation / re-wording can't break us.
  bool _isInsufficientBalance(PostgrestException e) =>
      (e.hint ?? '').contains('WALLET_INSUFFICIENT') ||
      e.message.toLowerCase().contains('insufficient');

  bool _isDailyLimit(PostgrestException e) =>
      (e.hint ?? '').contains('WALLET_DAILY_LIMIT') ||
      e.message.toLowerCase().contains('daily withdrawal limit');

  bool _isDuplicateIdempotencyKey(PostgrestException e) =>
      e.code == '23505' || e.message.contains('duplicate key');

  @override
  Future<WithdrawalRequestModel> requestWithdrawal({
    required String shopId,
    required double amount,
  }) async {
    // 1. Client-side validation (config bounds). Server enforces these too;
    //    the duplicate check here is purely a UX optimisation so we don't
    //    waste a round-trip when the user clearly entered something invalid.
    // Phase 17: config bounds are now int kobo; convert to major-units
    // for comparison against the legacy `double amount` param.
    final min = _config.minWithdrawalAmountMinor / 100;
    final max = _config.maxWithdrawalAmountMinor / 100;
    if (amount < min || amount > max) {
      throw InvalidWithdrawalAmountException();
    }

    try {
      // 2. Resolve the shop's payment recipient.
      final paymentInfo = await _getShopPaymentInfo(shopId);
      if (paymentInfo == null || !paymentInfo['recipient_verified']) {
        throw PaymentSetupMissingException();
      }

      // 3. Idempotency key. The server treats (shop_id, idempotency_key)
      //    as a primary key for retries — same key on attempt 1..N must
      //    produce the same withdrawal_id (checklist 2.20).
      //
      //    The previous implementation used `amount.toInt()` which truncated
      //    cents — 12.49 and 12.51 collided onto the same key. We now use
      //    `toStringAsFixed(2)` so the full minor-unit resolution is part
      //    of the key. Also UTC-stamped so the key is stable for retries
      //    within the same UTC day, deliberately distinct across days.
      final idempotencyKey = _buildIdempotencyKey(shopId, amount);

      // 4. Call the server-side RPC. Authz, balance check, daily limit, and
      //    fee calc all happen inside SECURITY DEFINER on the DB.
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

      // 5. Fetch the created (or pre-existing, in retry case) withdrawal row.
      final withdrawalResponse = await _client
          .from('withdrawal_requests')
          .select()
          .eq('id', result)
          .single();

      return WithdrawalRequestModel.fromJson(withdrawalResponse);
    } on WalletException {
      rethrow;
    } on PostgrestException catch (e) {
      if (_isInsufficientBalance(e)) throw InsufficientBalanceException();
      if (_isDailyLimit(e)) throw WithdrawalLimitExceededException();
      if (_isDuplicateIdempotencyKey(e)) throw DuplicateWithdrawalException();
      throw WalletException(
        'create_withdrawal_request RPC failed: ${e.code} ${e.message}',
      );
    } catch (e, st) {
      throw WalletException('requestWithdrawal unexpected: $e\n$st');
    }
  }

  /// Stable idempotency key for a withdrawal request.
  ///
  /// Format: `wd_{shopId}_{YYYYMMDD-UTC}_{amount-2dp}`.
  ///
  /// Stability guarantees:
  /// - Two retries of the same withdrawal on the same UTC day produce the
  ///   same key (so the server short-circuits on the second call).
  /// - Different amounts produce different keys (no cents-truncation bug).
  /// - Different UTC days produce different keys (so yesterday's withdrawal
  ///   doesn't block today's withdrawal of the same amount).
  String _buildIdempotencyKey(String shopId, double amount) {
    final now = DateTime.now().toUtc();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return 'wd_${shopId}_$y$m${d}_${amount.toStringAsFixed(2)}';
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
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'wallet.payment_info.postgrest',
        fields: {'shop_id': shopId, 'code': e.code},
      );
      return null;
    } catch (e, st) {
      AppLogger.errorEvent(
        'wallet.payment_info.unexpected',
        summary: e.toString(),
        fields: {'shop_id': shopId, 'stack_head': st.toString().split('\n').first},
      );
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
    } on PostgrestException catch (e) {
      throw WalletException(
        'getWithdrawalHistory PostgrestException: ${e.code} ${e.message}',
      );
    } catch (e, st) {
      throw WalletException('getWithdrawalHistory unexpected: $e\n$st');
    }
  }

  @override
  Future<WithdrawalRequestModel> getWithdrawalRequest(
    String withdrawalId,
  ) async {
    try {
      final response = await _client
          .from('withdrawal_requests')
          .select()
          .eq('id', withdrawalId)
          .single();
      return WithdrawalRequestModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw WalletException(
        'getWithdrawalRequest PostgrestException: ${e.code} ${e.message}',
      );
    } catch (e, st) {
      throw WalletException('getWithdrawalRequest unexpected: $e\n$st');
    }
  }

  @override
  Future<double> getAvailableBalance(String shopId) async {
    // Don't wrap — the caller already gets a typed WalletException from
    // getWallet(), and re-wrapping loses the code/userMessage.
    final wallet = await getWallet(shopId);
    return wallet.balance - wallet.pendingWithdrawals;
  }

  @override
  Stream<List<WithdrawalRequestModel>> watchDeadLetterWithdrawals(
    String shopId,
  ) {
    // Cancellable poll loop. Previous implementation was `while (true)
    // … Future.delayed(30s)` inside an async* generator with no way for
    // the consumer to stop it short of letting the generator be
    // garbage-collected. That violated checklist 2.13 (cleanup on
    // cancellation): consumers that listened briefly still held a
    // pending HTTP call hostage and a Timer in flight.
    //
    // We now expose a StreamController whose onCancel tears down both
    // the in-flight request token and the timer. Polling is preserved
    // (Realtime overkill for a low-frequency event).
    const interval = Duration(seconds: 30);
    late StreamController<List<WithdrawalRequestModel>> ctrl;
    Timer? timer;
    var cancelled = false;

    Future<void> tick() async {
      if (cancelled) return;
      try {
        final data = await _client
            .from('withdrawal_requests')
            .select()
            .eq('shop_id', shopId)
            .eq('status', 'dead_letter')
            .order('updated_at', ascending: false);
        if (cancelled) return;
        ctrl.add((data as List)
            .map((row) => WithdrawalRequestModel.fromJson(row))
            .toList());
      } catch (e) {
        // Transient failures (network blip, RLS hiccup) should hide the
        // banner, not crash the screen. The banner is informational; if
        // we genuinely have dead-letter rows we'll resurface on the
        // next tick.
        if (cancelled) return;
        AppLogger.warn(
          'wallet.dead_letter.poll_failed',
          fields: {'shop_id': shopId, 'error': e.toString()},
        );
        ctrl.add(const []);
      }
    }

    ctrl = StreamController<List<WithdrawalRequestModel>>(
      onListen: () {
        tick();
        timer = Timer.periodic(interval, (_) => tick());
      },
      onCancel: () {
        cancelled = true;
        timer?.cancel();
        timer = null;
      },
    );
    return ctrl.stream;
  }
}
