// lib/presentation/features/shops/dashboard/data/models/broadcast_dto.dart
//
// Phase 14 — owner-sent broadcast DTO. Locale-neutral (no Intl formatting
// inside the model; that's the screen's job).
//
// JSON shape matches the `broadcasts` table columns 1:1. Two enums carry
// `fromString` / SQL-value round-trip helpers matching the SQL CHECK
// constraint strings exactly — drift either side will surface as parse
// failures in tests, not silent mismatches at runtime.

enum BroadcastAudience {
  allClients('all_clients'),
  recent('recent'),
  lapsed('lapsed'),
  byService('by_service');

  final String sqlValue;
  const BroadcastAudience(this.sqlValue);

  static BroadcastAudience fromString(String s) {
    switch (s) {
      case 'all_clients':
        return BroadcastAudience.allClients;
      case 'recent':
        return BroadcastAudience.recent;
      case 'lapsed':
        return BroadcastAudience.lapsed;
      case 'by_service':
        return BroadcastAudience.byService;
      default:
        throw ArgumentError('Unknown BroadcastAudience: $s');
    }
  }
}

enum BroadcastStatus {
  pending('pending'),
  delivering('delivering'),
  delivered('delivered'),
  failed('failed');

  final String sqlValue;
  const BroadcastStatus(this.sqlValue);

  static BroadcastStatus fromString(String s) {
    switch (s) {
      case 'pending':
        return BroadcastStatus.pending;
      case 'delivering':
        return BroadcastStatus.delivering;
      case 'delivered':
        return BroadcastStatus.delivered;
      case 'failed':
        return BroadcastStatus.failed;
      default:
        throw ArgumentError('Unknown BroadcastStatus: $s');
    }
  }
}

class BroadcastDTO {
  final String id;
  final String shopId;
  final String subject;
  final String body;
  final BroadcastAudience audienceType;

  /// slot_id when [audienceType] is [BroadcastAudience.byService]; null
  /// otherwise. The server CHECK constraint enforces this XOR.
  final String? audienceParam;

  /// promotions.id when an owner_defined code was attached at send time.
  /// Server re-validates the code is still active at send; this column
  /// preserves the attachment record even if the code is later archived.
  final String? promotionId;

  final String createdByUserId;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final int recipientCount;
  final BroadcastStatus status;

  const BroadcastDTO({
    required this.id,
    required this.shopId,
    required this.subject,
    required this.body,
    required this.audienceType,
    required this.audienceParam,
    required this.promotionId,
    required this.createdByUserId,
    required this.createdAt,
    required this.deliveredAt,
    required this.recipientCount,
    required this.status,
  });

  factory BroadcastDTO.fromJson(Map<String, dynamic> json) => BroadcastDTO(
        id: json['id'] as String,
        shopId: json['shop_id'] as String,
        subject: json['subject'] as String,
        body: json['body'] as String,
        audienceType:
            BroadcastAudience.fromString(json['audience_type'] as String),
        audienceParam: json['audience_param'] as String?,
        promotionId: json['promotion_id'] as String?,
        createdByUserId: json['created_by_user_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        deliveredAt: json['delivered_at'] == null
            ? null
            : DateTime.parse(json['delivered_at'] as String),
        recipientCount: (json['recipient_count'] as num).toInt(),
        status: BroadcastStatus.fromString(json['status'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'shop_id': shopId,
        'subject': subject,
        'body': body,
        'audience_type': audienceType.sqlValue,
        'audience_param': audienceParam,
        'promotion_id': promotionId,
        'created_by_user_id': createdByUserId,
        'created_at': createdAt.toIso8601String(),
        'delivered_at': deliveredAt?.toIso8601String(),
        'recipient_count': recipientCount,
        'status': status.sqlValue,
      };
}
