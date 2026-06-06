// lib/presentation/features/shops/dashboard/data/models/client_note_dto.dart
//
// Phase 12 — owner-private sticky note attached to a (shop, client)
// pair. Mirrors the upsert_client_note RPC return shape and the
// client_notes table column set.
//
// Identity is exactly one of userId or guestProfileId (server-side
// CHECK enforces this). The widget keys its provider on
// (shopId, userId | guestProfileId) — NOT booking_id — because the
// note persists across all bookings by the same client at the same
// shop.

import 'package:equatable/equatable.dart';

class ClientNoteDTO extends Equatable {
  /// Server-generated UUID. Null on the in-memory "no note yet" sentinel
  /// (before any save has happened for this shop+client pair).
  final String? id;

  final String shopId;

  /// Registered client identity. Mutually exclusive with [guestProfileId].
  final String? userId;

  /// Guest client identity. Mutually exclusive with [userId].
  final String? guestProfileId;

  /// Note body. Server caps at 2000 chars; the widget enforces the same
  /// via a LengthLimitingTextInputFormatter.
  final String body;

  final DateTime updatedAt;

  /// The owner user who last wrote the note. Forensic only.
  final String? updatedByUserId;

  const ClientNoteDTO({
    required this.id,
    required this.shopId,
    required this.userId,
    required this.guestProfileId,
    required this.body,
    required this.updatedAt,
    required this.updatedByUserId,
  });

  factory ClientNoteDTO.fromJson(Map<String, dynamic> json) {
    return ClientNoteDTO(
      id: json['id'] as String?,
      shopId: json['shop_id'] as String,
      userId: json['user_id'] as String?,
      guestProfileId: json['guest_profile_id'] as String?,
      body: (json['body'] as String?) ?? '',
      updatedAt: DateTime.parse(json['updated_at'] as String),
      updatedByUserId: json['updated_by_user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'shop_id': shopId,
        'user_id': userId,
        'guest_profile_id': guestProfileId,
        'body': body,
        'updated_at': updatedAt.toIso8601String(),
        'updated_by_user_id': updatedByUserId,
      };

  @override
  List<Object?> get props => [
        id,
        shopId,
        userId,
        guestProfileId,
        body,
        updatedAt,
        updatedByUserId,
      ];
}
