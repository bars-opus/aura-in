// lib/features/wallet/data/models/wallet_model.dart

import 'package:equatable/equatable.dart';

class WalletModel extends Equatable {
  final String id;
  final String shopId;
  final double balance;
  final double totalEarned;
  final double totalWithdrawn;
  final double pendingWithdrawals;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletModel({
    required this.id,
    required this.shopId,
    required this.balance,
    required this.totalEarned,
    required this.totalWithdrawn,
    required this.pendingWithdrawals,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      balance: (json['balance'] as num).toDouble(),
      totalEarned: (json['total_earned'] as num).toDouble(),
      totalWithdrawn: (json['total_withdrawn'] as num).toDouble(),
      pendingWithdrawals: (json['pending_withdrawals'] as num).toDouble(),
      currency: json['currency'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'balance': balance,
      'total_earned': totalEarned,
      'total_withdrawn': totalWithdrawn,
      'pending_withdrawals': pendingWithdrawals,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if shop can withdraw the requested amount
  bool canWithdraw(double amount) => balance >= amount && amount > 0;

  @override
  List<Object?> get props => [
        id,
        shopId,
        balance,
        totalEarned,
        totalWithdrawn,
        pendingWithdrawals,
        currency,
        createdAt,
        updatedAt,
      ];
}
