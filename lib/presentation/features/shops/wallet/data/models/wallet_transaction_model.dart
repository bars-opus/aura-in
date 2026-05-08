// lib/features/wallet/data/models/wallet_transaction_model.dart

import 'package:equatable/equatable.dart';

enum TransactionType {
  deposit,
  servicePayment,
  withdrawal,
  refund,
  platformFee,
  adjustment;

  String get value => name.toLowerCase();
  
  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionType.adjustment,
    );
  }
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled;

  String get value => name.toLowerCase();
  
  static TransactionStatus fromString(String value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionStatus.pending,
    );
  }
}

class WalletTransactionModel extends Equatable {
  final String id;
  final String shopId;
  final String? bookingId;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String? description;
  final String? reference;
  final double balanceAfter;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? completedAt;

  const WalletTransactionModel({
    required this.id,
    required this.shopId,
    this.bookingId,
    required this.amount,
    required this.type,
    required this.status,
    this.description,
    this.reference,
    required this.balanceAfter,
    required this.metadata,
    required this.createdAt,
    this.completedAt,
  });

  /// Whether this is a credit (positive amount)
  bool get isCredit => amount > 0;

  /// Whether this is a debit (negative amount)
  bool get isDebit => amount < 0;

  /// Formatted amount with sign
  String get formattedAmount {
    final sign = amount > 0 ? '+' : '';
    return '$sign${amount.toStringAsFixed(2)}';
  }

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      bookingId: json['booking_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.fromString(json['type'] as String),
      status: TransactionStatus.fromString(json['status'] as String),
      description: json['description'] as String?,
      reference: json['reference'] as String?,
      balanceAfter: (json['balance_after'] as num).toDouble(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        shopId,
        bookingId,
        amount,
        type,
        status,
        description,
        reference,
        balanceAfter,
        createdAt,
      ];
}
