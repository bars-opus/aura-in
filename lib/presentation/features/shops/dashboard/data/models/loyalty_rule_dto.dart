// lib/presentation/features/shops/dashboard/data/models/loyalty_rule_dto.dart
//
// Phase 13 — per-shop loyalty rule.
//
// At most one ACTIVE rule per shop (server-enforced by partial unique
// index on (shop_id) WHERE is_active = TRUE). Inactive rows are kept
// for audit only.
//
// The bookings AFTER UPDATE trigger reads this row on every completed
// booking and, when the client's visit count mod triggerVisitCount = 0,
// issues a one-shot promo code via generate_loyalty_code(). When the
// row is missing or inactive, the trigger is a no-op.
//
// Mirrors the shape of promotion_model.dart but without Equatable —
// the screen reads single rows and never compares instances.

import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/promotion_model.dart';

class LoyaltyRuleDTO {
  /// Server-generated row id. Null on the in-memory "draft" instance
  /// before the first save.
  final String? id;

  final String shopId;

  /// N: issues a loyalty code on every Nth completed booking. 2..50.
  final int triggerVisitCount;

  /// Reuses the DiscountType enum from promotion_model.dart so the
  /// values pass through to generate_loyalty_code unchanged.
  final DiscountType discountType;

  final double discountValue;

  /// Only the active rule is read by the trigger. Owner may keep
  /// inactive rows for audit.
  final bool isActive;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LoyaltyRuleDTO({
    required this.id,
    required this.shopId,
    required this.triggerVisitCount,
    required this.discountType,
    required this.discountValue,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoyaltyRuleDTO.fromJson(Map<String, dynamic> json) {
    return LoyaltyRuleDTO(
      id: json['id'] as String?,
      shopId: json['shop_id'] as String,
      triggerVisitCount: json['trigger_visit_count'] as int,
      discountType: DiscountType.fromString(json['discount_type'] as String),
      discountValue: (json['discount_value'] as num).toDouble(),
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'shop_id': shopId,
        'trigger_visit_count': triggerVisitCount,
        'discount_type': discountType.value,
        'discount_value': discountValue,
        'is_active': isActive,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  LoyaltyRuleDTO copyWith({
    int? triggerVisitCount,
    DiscountType? discountType,
    double? discountValue,
    bool? isActive,
  }) {
    return LoyaltyRuleDTO(
      id: id,
      shopId: shopId,
      triggerVisitCount: triggerVisitCount ?? this.triggerVisitCount,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Default-shape draft for a shop that has no rule yet. Used by the
  /// LoyaltyRuleScreen on first load when the provider returns null.
  factory LoyaltyRuleDTO.draft(String shopId) => LoyaltyRuleDTO(
        id: null,
        shopId: shopId,
        triggerVisitCount: 6,
        discountType: DiscountType.percentage,
        discountValue: 15,
        isActive: true,
        createdAt: null,
        updatedAt: null,
      );
}
