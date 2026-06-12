// lib/presentation/features/shops/dashboard/data/models/pricing_override_dto.dart
//
// Phase 15 — per-(slot, day_of_week, time_window) price-adjustment rule.
//
// JSON shape matches the `pricing_overrides` table columns 1:1. The
// AdjustmentKind enum carries a SQL-value round-trip helper matching the
// SQL CHECK constraint strings exactly — drift either side surfaces as
// parse failures in tests, not silent mismatches at runtime.

/// Owner-defined adjustment shape. Four enum values matching the
/// pricing_overrides.adjustment_kind CHECK constraint.
enum AdjustmentKind {
  percentDiscount('percent_discount'),
  percentSurcharge('percent_surcharge'),
  fixedDiscount('fixed_discount'),
  fixedSurcharge('fixed_surcharge');

  const AdjustmentKind(this.sqlValue);

  /// SQL string value stored in the database.
  final String sqlValue;

  static AdjustmentKind fromString(String s) {
    switch (s) {
      case 'percent_discount':
        return AdjustmentKind.percentDiscount;
      case 'percent_surcharge':
        return AdjustmentKind.percentSurcharge;
      case 'fixed_discount':
        return AdjustmentKind.fixedDiscount;
      case 'fixed_surcharge':
        return AdjustmentKind.fixedSurcharge;
      default:
        throw ArgumentError('Unknown AdjustmentKind: $s');
    }
  }

  bool get isDiscount =>
      this == percentDiscount || this == fixedDiscount;
  bool get isSurcharge =>
      this == percentSurcharge || this == fixedSurcharge;
  bool get isPercent =>
      this == percentDiscount || this == percentSurcharge;
  bool get isFixed => this == fixedDiscount || this == fixedSurcharge;
}

class PricingOverrideDTO {
  final String id;
  final String slotId;
  final String name;

  /// 1..7 (Mon=1..Sun=7) or null (all-week).
  final int? dayOfWeek;

  /// "HH:mm:ss" — Postgres TIME serialized.
  final String timeWindowStart;
  final String timeWindowEnd;

  final AdjustmentKind kind;

  /// For percent_*: 0.01..100. For fixed_*: any positive currency value.
  final double value;

  final DateTime validFrom;

  /// Null = no expiry.
  final DateTime? validUntil;

  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PricingOverrideDTO({
    required this.id,
    required this.slotId,
    required this.name,
    required this.dayOfWeek,
    required this.timeWindowStart,
    required this.timeWindowEnd,
    required this.kind,
    required this.value,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PricingOverrideDTO.fromJson(Map<String, dynamic> json) {
    return PricingOverrideDTO(
      id: json['id'] as String,
      slotId: json['slot_id'] as String,
      name: json['name'] as String,
      dayOfWeek: json['day_of_week'] as int?,
      timeWindowStart: json['time_window_start'] as String,
      timeWindowEnd: json['time_window_end'] as String,
      kind: AdjustmentKind.fromString(json['adjustment_kind'] as String),
      value: (json['adjustment_value'] as num).toDouble(),
      validFrom: DateTime.parse(json['valid_from'] as String),
      validUntil: json['valid_until'] == null
          ? null
          : DateTime.parse(json['valid_until'] as String),
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slot_id': slotId,
        'name': name,
        'day_of_week': dayOfWeek,
        'time_window_start': timeWindowStart,
        'time_window_end': timeWindowEnd,
        'adjustment_kind': kind.sqlValue,
        'adjustment_value': value,
        'valid_from': validFrom.toIso8601String(),
        'valid_until': validUntil?.toIso8601String(),
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
