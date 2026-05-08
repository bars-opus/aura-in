// lib/features/shops/data/dtos/opening_hours_dto.dart

class OpeningHoursDTO {
  final String id;
  final int dayOfWeek;
  final String opensAt;
  final String closesAt;
  final bool isClosed;

  const OpeningHoursDTO({
    required this.id,
    required this.dayOfWeek,
    required this.opensAt,
    required this.closesAt,
    required this.isClosed,
  });

  factory OpeningHoursDTO.fromJson(Map<String, dynamic> json) {
    return OpeningHoursDTO(
      id: json['id'] as String,
      dayOfWeek: json['day_of_week'] as int,
      opensAt: json['opens_at'] as String,
      closesAt: json['closes_at'] as String,
      isClosed: json['is_closed'] as bool? ?? false,
    );
  }

  // Helper to convert to display format
  String get displayRange {
    if (isClosed) return 'Closed';
    return '$opensAt - $closesAt';
  }

  // Get day name
  String get dayName {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dayOfWeek];
  }
}
