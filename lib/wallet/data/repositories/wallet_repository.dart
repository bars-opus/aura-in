// lib/features/wallet/data/repositories/wallet_repository.dart

import 'package:nano_embryo/wallet/data/models/wallet_model.dart';
import 'package:nano_embryo/wallet/data/models/wallet_transaction_model.dart';
import 'package:nano_embryo/wallet/data/models/withdrawal_request_model.dart';

abstract class WalletRepository {
  /// Get wallet for a shop
  Future<WalletModel> getWallet(String shopId);

  /// Get transaction history with pagination
  ///
  /// Pass [before] for cursor-based pagination — returns rows with
  /// created_at strictly less than the cursor. [offset] still works for
  /// existing call sites that use it.
  Future<List<WalletTransactionModel>> getTransactions({
    required String shopId,
    int? limit,
    int? offset,
    DateTime? before,
    DateTime? fromDate,
    DateTime? toDate,
    TransactionType? type,
  });

  /// Stream of withdrawals currently in 'dead_letter' status for [shopId].
  /// Emits the current list, then a fresh list every 30 seconds.
  Stream<List<WithdrawalRequestModel>> watchDeadLetterWithdrawals(
    String shopId,
  );

  /// Add transaction to wallet (atomic operation)
  Future<WalletTransactionModel> addTransaction({
    required String shopId,
    required double amount,
    required TransactionType type,
    String? bookingId,
    String? description,
    String? reference,
    Map<String, dynamic>? metadata,
  });

  /// Request withdrawal
  Future<WithdrawalRequestModel> requestWithdrawal({
    required String shopId,
    required double amount,
  });

  /// Get withdrawal history
  Future<List<WithdrawalRequestModel>> getWithdrawalHistory({
    required String shopId,
    int? limit,
    WithdrawalStatus? status,
  });
}
