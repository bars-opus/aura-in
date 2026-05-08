// lib/features/dashboard/data/models/worker_break.dart
import 'package:equatable/equatable.dart';

/// Type of break
enum BreakType {
  lunch,
  shortBreak;

  String get displayName {
    switch (this) {
      case BreakType.lunch:
        return 'Lunch';
      case BreakType.shortBreak:
        return 'Short Break';
    }
  }

  String get value {
    switch (this) {
      case BreakType.lunch:
        return 'lunch';
      case BreakType.shortBreak:
        return 'short_break';
    }
  }

  static BreakType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'lunch':
        return BreakType.lunch;
      case 'short_break':
        return BreakType.shortBreak;
      default:
        return BreakType.shortBreak;
    }
  }
}

/// Worker break record
class WorkerBreak extends Equatable {
  final String id;
  final String attendanceId;
  final DateTime? breakStart;
  final DateTime? breakEnd;
  final double? breakDuration;
  final BreakType breakType;
  final DateTime createdAt;

  // GPS location data
  final double? breakStartLatitude;
  final double? breakStartLongitude;
  final double? breakEndLatitude;
  final double? breakEndLongitude;

  const WorkerBreak({
    required this.id,
    required this.attendanceId,
    this.breakStart,
    this.breakEnd,
    this.breakDuration,
    required this.breakType,
    required this.createdAt,
    this.breakStartLatitude,
    this.breakStartLongitude,
    this.breakEndLatitude,
    this.breakEndLongitude,
  });

  factory WorkerBreak.fromJson(Map<String, dynamic> json) {
    return WorkerBreak(
      id: json['id'],
      attendanceId: json['attendance_id'],
      breakStart: json['break_start'] != null
          ? DateTime.parse(json['break_start'])
          : null,
      breakEnd: json['break_end'] != null
          ? DateTime.parse(json['break_end'])
          : null,
      breakDuration: json['break_duration']?.toDouble(),
      breakType: BreakType.fromString(json['break_type'] ?? 'short_break'),
      createdAt: DateTime.parse(json['created_at']),
      breakStartLatitude: json['break_start_latitude']?.toDouble(),
      breakStartLongitude: json['break_start_longitude']?.toDouble(),
      breakEndLatitude: json['break_end_latitude']?.toDouble(),
      breakEndLongitude: json['break_end_longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attendance_id': attendanceId,
      'break_start': breakStart?.toIso8601String(),
      'break_end': breakEnd?.toIso8601String(),
      'break_duration': breakDuration,
      'break_type': breakType.value,
      'break_start_latitude': breakStartLatitude,
      'break_start_longitude': breakStartLongitude,
      'break_end_latitude': breakEndLatitude,
      'break_end_longitude': breakEndLongitude,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Helper to check if break is currently active (started but not ended)
  bool get isActive => breakStart != null && breakEnd == null;

  /// Helper to get formatted break duration
  String get formattedDuration {
    if (breakDuration == null) return '--';
    final hours = breakDuration!.floor();
    final minutes = ((breakDuration! - hours) * 60).round();
    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
    }
    return '$minutes min';
  }

  /// Helper to get formatted break start time
  String get formattedStartTime {
    if (breakStart == null) return '--:--';
    return _formatTime(breakStart!);
  }

  /// Helper to get formatted break end time
  String get formattedEndTime {
    if (breakEnd == null) return '--:--';
    return _formatTime(breakEnd!);
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  List<Object?> get props => [
    id, attendanceId, breakStart, breakEnd, breakDuration, breakType, createdAt,
    breakStartLatitude, breakStartLongitude, breakEndLatitude, breakEndLongitude,
  ];
}
