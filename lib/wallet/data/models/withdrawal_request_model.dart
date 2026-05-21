// lib/features/wallet/data/models/withdrawal_request_model.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum WithdrawalStatus {
  pending,
  processing,
  completed,
  failed,
  refunded;

  String get value => name.toLowerCase();
  
  static WithdrawalStatus fromString(String value) {
    return WithdrawalStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WithdrawalStatus.pending,
    );
  }
  
  String get displayName {
    switch (this) {
      case WithdrawalStatus.pending:
        return 'Pending';
      case WithdrawalStatus.processing:
        return 'Processing';
      case WithdrawalStatus.completed:
        return 'Completed';
      case WithdrawalStatus.failed:
        return 'Failed';
      case WithdrawalStatus.refunded:
        return 'Refunded';
    }
  }
  
  Color get statusColor {
    switch (this) {
      case WithdrawalStatus.pending:
        return Colors.orange;
      case WithdrawalStatus.processing:
        return Colors.blue;
      case WithdrawalStatus.completed:
        return Colors.green;
      case WithdrawalStatus.failed:
        return Colors.red;
      case WithdrawalStatus.refunded:
        return Colors.grey;
    }
    
  }



  
}

class WithdrawalRequestModel extends Equatable {
  final String id;
  final String shopId;
  final double amount;
  final WithdrawalStatus status;
  final String paymentProvider;
  final String transferRecipientId;
  final String? providerTransferId;
  final String idempotencyKey;
  final DateTime? processedAt;
  final String? failedReason;
  final String? deadLetterReason;
  final String? requestedByIp;
  final double feeAmount;
  final double netAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WithdrawalRequestModel({
    required this.id,
    required this.shopId,
    required this.amount,
    required this.status,
    required this.paymentProvider,
    required this.transferRecipientId,
    required this.idempotencyKey,
    this.providerTransferId,
    this.processedAt,
    this.failedReason,
    this.deadLetterReason,
    this.requestedByIp,
    required this.feeAmount,
    required this.netAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WithdrawalRequestModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequestModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: WithdrawalStatus.fromString(json['status'] as String),
      paymentProvider: json['payment_provider'] as String,
      transferRecipientId: json['transfer_recipient_id'] as String,
      providerTransferId: json['provider_transfer_id'] as String?,
      idempotencyKey: json['idempotency_key'] as String,
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
      failedReason: json['failed_reason'] as String?,
      deadLetterReason: json['dead_letter_reason'] as String?,
      requestedByIp: json['requested_by_ip'] as String?,
      feeAmount: (json['fee_amount'] as num?)?.toDouble() ?? 0,
      netAmount: (json['net_amount'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'amount': amount,
      'status': status.value,
      'payment_provider': paymentProvider,
      'transfer_recipient_id': transferRecipientId,
      'provider_transfer_id': providerTransferId,
      'idempotency_key': idempotencyKey,
      'processed_at': processedAt?.toIso8601String(),
      'failed_reason': failedReason,
      'dead_letter_reason': deadLetterReason,
      'requested_by_ip': requestedByIp,
      'fee_amount': feeAmount,
      'net_amount': netAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        shopId,
        amount,
        status,
        paymentProvider,
        providerTransferId,
        deadLetterReason,
        createdAt,
        updatedAt,
      ];
}
