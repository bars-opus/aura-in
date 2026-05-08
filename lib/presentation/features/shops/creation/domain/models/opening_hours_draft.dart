import 'package:equatable/equatable.dart';

class OpeningHoursDraft extends Equatable {
  final int dayOfWeek; // 1-7 (Monday=1)
  final String opensAt; // "09:00"
  final String closesAt; // "17:00"
  final bool isClosed;
  final bool isSet;

  const OpeningHoursDraft({
    required this.dayOfWeek,
    required this.opensAt,
    required this.closesAt,
    this.isClosed = false,
    this.isSet = false,
  });

  Map<String, dynamic> toJson() => {
    'dayOfWeek': dayOfWeek,
    'opensAt': opensAt,
    'closesAt': closesAt,
    'isClosed': isClosed,
    'isSet': isSet,
  };

  factory OpeningHoursDraft.fromJson(Map<String, dynamic> json) =>
      OpeningHoursDraft(
        // Support both camelCase (Hive local storage) and snake_case (Supabase DB).
        dayOfWeek: (json['day_of_week'] ?? json['dayOfWeek']) as int,
        opensAt: (json['opens_at'] ?? json['opensAt']) as String,
        closesAt: (json['closes_at'] ?? json['closesAt']) as String,
        isClosed: (json['is_closed'] ?? json['isClosed']) as bool? ?? false,
        isSet: (json['is_set'] ?? json['isSet']) as bool? ?? false,
      );

  @override
  List<Object?> get props => [dayOfWeek, opensAt, closesAt, isClosed];
}
