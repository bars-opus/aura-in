// lib/features/shops/data/models/luxury_level_info.dart
class LuxuryLevelInfo {
  final String level;
  final int count;

  LuxuryLevelInfo({required this.level, required this.count});

  factory LuxuryLevelInfo.fromJson(Map<String, dynamic> json) {
    return LuxuryLevelInfo(
      level: json['luxury_level'] as String? ?? 'Unspecified',
      count: (json['count'] as num).toInt(),
    );
  }
}
