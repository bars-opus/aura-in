// lib/features/wallet/data/repositories/wallet_repository.dart

import 'package:nano_embryo/presentation/features/shops/wallet/data/models/wallet_model.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/data/models/wallet_transaction_model.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/data/models/withdrawal_request_model.dart';

abstract class WalletRepository {
  /// Get wallet for a shop
  Future<WalletModel> getWallet(String shopId);

  /// Get transaction history with pagination
  Future<List<WalletTransactionModel>> getTransactions({
    required String shopId,
    int? limit,
    int? offset,
    DateTime? fromDate,
    DateTime? toDate,
    TransactionType? type,
  });

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
