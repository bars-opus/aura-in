// lib/features/shop/workers/models/worker_invite.dart

import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/worker_dto.dart';

class WorkerInvite extends Equatable {
  final String id;
  final String shopId;
  final String workerId;
  final String? invitedBy;
  final String status;
  final String? message;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final WorkerDTO? worker;
  final Map<String, dynamic>? inviter;

  const WorkerInvite({
    required this.id,
    required this.shopId,
    required this.workerId,
    this.invitedBy,
    required this.status,
    this.message,
    required this.expiresAt,
    required this.createdAt,
    this.respondedAt,
    this.worker,
    this.inviter,
  });

  factory WorkerInvite.fromJson(Map<String, dynamic> json) {
    return WorkerInvite(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      workerId: json['worker_id'] as String,
      invitedBy: json['invited_by'] as String?,
      status: json['status'] as String,
      message: json['message'] as String?,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
      worker: json['worker'] != null
          ? WorkerDTO.fromJson(json['worker'] as Map<String, dynamic>)
          : null,
      inviter: json['inviter'] as Map<String, dynamic>?,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';

  @override
  List<Object?> get props => [
    id,
    shopId,
    workerId,
    invitedBy,
    status,
    message,
    expiresAt,
    createdAt,
    respondedAt,
    worker,
  ];
}
