// lib/features/dashboard/data/models/promotion_model.dart
import 'package:equatable/equatable.dart';

enum DiscountType {
  percentage,
  fixed,
  freeAddon;

  String get displayName {
    switch (this) {
      case DiscountType.percentage:
        return 'Percentage off';
      case DiscountType.fixed:
        return 'Fixed amount off';
      case DiscountType.freeAddon:
        return 'Free add-on';
    }
  }

  String get value {
    switch (this) {
      case DiscountType.percentage:
        return 'percentage';
      case DiscountType.fixed:
        return 'fixed';
      case DiscountType.freeAddon:
        return 'free_addon';
    }
  }

  static DiscountType fromString(String value) {
    switch (value) {
      case 'percentage':
        return DiscountType.percentage;
      case 'fixed':
        return DiscountType.fixed;
      case 'free_addon':
        return DiscountType.freeAddon;
      default:
        return DiscountType.percentage;
    }
  }
}

class Promotion extends Equatable {
  final String id;
  final String shopId;
  final String name;
  final String code;
  final DiscountType discountType;
  final double discountValue;
  final DateTime validFrom;
  final DateTime validTo;
  final int? usageLimit;
  final int usageCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Promotion({
    required this.id,
    required this.shopId,
    required this.name,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.validFrom,
    required this.validTo,
    this.usageLimit,
    this.usageCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isExpired => validTo.isBefore(DateTime.now());
  bool get isUnlimited => usageLimit == null;
  bool get hasReachedLimit => usageLimit != null && usageCount >= usageLimit!;
  bool get isValid => isActive && !isExpired && !hasReachedLimit;

  String get formattedDiscount {
    switch (discountType) {
      case DiscountType.percentage:
        return '${discountValue.toStringAsFixed(0)}% off';
      case DiscountType.fixed:
        return '\$${discountValue.toStringAsFixed(2)} off';
      case DiscountType.freeAddon:
        return 'Free add-on';
    }
  }

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'],
      shopId: json['shop_id'],
      name: json['name'],
      code: json['code'].toUpperCase(),
      discountType: DiscountType.fromString(json['discount_type']),
      discountValue: (json['discount_value'] as num).toDouble(),
      validFrom: DateTime.parse(json['valid_from']),
      validTo: DateTime.parse(json['valid_to']),
      usageLimit: json['usage_limit'],
      usageCount: json['usage_count'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'name': name,
      'code': code.toUpperCase(),
      'discount_type': discountType.value,
      'discount_value': discountValue,
      'valid_from': validFrom.toIso8601String().split('T').first,
      'valid_to': validTo.toIso8601String().split('T').first,
      'usage_limit': usageLimit,
      'usage_count': usageCount,
      'is_active': isActive,
    };
  }

  Promotion copyWith({
    String? name,
    String? code,
    DiscountType? discountType,
    double? discountValue,
    DateTime? validFrom,
    DateTime? validTo,
    int? usageLimit,
    bool? isActive,
  }) {
    return Promotion(
      id: id,
      shopId: shopId,
      name: name ?? this.name,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id, shopId, name, code, discountType, discountValue,
    validFrom, validTo, usageLimit, usageCount, isActive,
    createdAt, updatedAt,
  ];
}
