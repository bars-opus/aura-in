// lib/features/dashboard/data/models/worker_attendance.dart
import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/workers/worker_break.dart';

/// Status of attendance for a day
enum AttendanceStatus {
  present,
  absent,
  late,
  halfDay;

  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.halfDay:
        return 'Half Day';
    }
  }

  String get value {
    switch (this) {
      case AttendanceStatus.present:
        return 'present';
      case AttendanceStatus.absent:
        return 'absent';
      case AttendanceStatus.late:
        return 'late';
      case AttendanceStatus.halfDay:
        return 'half_day';
    }
  }

  static AttendanceStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      case 'half_day':
        return AttendanceStatus.halfDay;
      default:
        return AttendanceStatus.present;
    }
  }
}

/// Worker attendance record for a single day
class WorkerAttendance extends Equatable {
  final String id;
  final String workerId;
  final String shopId;
  final DateTime date;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final AttendanceStatus status;
  final double? totalHours;
  final String? notes;
  final List<WorkerBreak>? breaks;
  final DateTime createdAt;
  final DateTime updatedAt;

  // GPS location data
  final double? clockInLatitude;
  final double? clockInLongitude;
  final double? clockOutLatitude;
  final double? clockOutLongitude;

  const WorkerAttendance({
    required this.id,
    required this.workerId,
    required this.shopId,
    required this.date,
    this.clockIn,
    this.clockOut,
    required this.status,
    this.totalHours,
    this.notes,
    this.breaks,
    required this.createdAt,
    required this.updatedAt,
    this.clockInLatitude,
    this.clockInLongitude,
    this.clockOutLatitude,
    this.clockOutLongitude,
  });

  factory WorkerAttendance.fromJson(Map<String, dynamic> json) {
    // Parse breaks if present
    List<WorkerBreak>? breaks;
    if (json['breaks'] != null) {
      breaks = (json['breaks'] as List)
          .map((b) => WorkerBreak.fromJson(b as Map<String, dynamic>))
          .toList();
    }

    return WorkerAttendance(
      id: json['id'],
      workerId: json['worker_id'],
      shopId: json['shop_id'],
      date: DateTime.parse(json['date']),
      clockIn: json['clock_in'] != null
          ? DateTime.parse(json['clock_in'])
          : null,
      clockOut: json['clock_out'] != null
          ? DateTime.parse(json['clock_out'])
          : null,
      status: AttendanceStatus.fromString(json['status'] ?? 'present'),
      totalHours: json['total_hours']?.toDouble(),
      notes: json['notes'],
      breaks: breaks,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      clockInLatitude: json['clock_in_latitude']?.toDouble(),
      clockInLongitude: json['clock_in_longitude']?.toDouble(),
      clockOutLatitude: json['clock_out_latitude']?.toDouble(),
      clockOutLongitude: json['clock_out_longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'worker_id': workerId,
      'shop_id': shopId,
      'date': date.toIso8601String().split('T').first,
      'clock_in': clockIn?.toIso8601String(),
      'clock_out': clockOut?.toIso8601String(),
      'status': status.value,
      'total_hours': totalHours,
      'notes': notes,
      'clock_in_latitude': clockInLatitude,
      'clock_in_longitude': clockInLongitude,
      'clock_out_latitude': clockOutLatitude,
      'clock_out_longitude': clockOutLongitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Helper to get formatted clock in time
  String get formattedClockIn {
    if (clockIn == null) return '--:--';
    return _formatTime(clockIn!);
  }

  /// Helper to get formatted clock out time
  String get formattedClockOut {
    if (clockOut == null) return '--:--';
    return _formatTime(clockOut!);
  }

  /// Helper to get formatted total hours
  String get formattedTotalHours {
    if (totalHours == null) return '-- hrs';
    return '${totalHours!.toStringAsFixed(1)} hrs';
  }

  /// Helper to check if worker is currently clocked in (no clock out)
  bool get isClockedIn => clockIn != null && clockOut == null;

  /// Helper to get total break duration for the day
  double get totalBreakDuration {
    if (breaks == null || breaks!.isEmpty) return 0;
    return breaks!.fold<double>(
      0,
      (sum, b) => sum + (b.breakDuration ?? 0),
    );
  }

  /// Helper to get formatted break duration
  String get formattedBreakDuration {
    final duration = totalBreakDuration;
    if (duration == 0) return '--';
    final hours = duration.floor();
    final minutes = ((duration - hours) * 60).round();
    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
    }
    return '$minutes min';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  List<Object?> get props => [
    id, workerId, shopId, date, clockIn, clockOut, status,
    totalHours, notes, breaks, createdAt, updatedAt,
    clockInLatitude, clockInLongitude, clockOutLatitude, clockOutLongitude,
  ];
}
