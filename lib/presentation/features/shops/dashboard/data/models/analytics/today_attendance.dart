// lib/features/dashboard/data/models/today_attendance.dart
import 'package:equatable/equatable.dart';

/// Current status of a worker for today
enum TodayAttendanceStatus {
  notClocked,
  clockedIn,
  onBreak,
  clockedOut;

  String get displayName {
    switch (this) {
      case TodayAttendanceStatus.notClocked:
        return 'Not Clocked In';
      case TodayAttendanceStatus.clockedIn:
        return 'Clocked In';
      case TodayAttendanceStatus.onBreak:
        return 'On Break';
      case TodayAttendanceStatus.clockedOut:
        return 'Clocked Out';
    }
  }

  String get value {
    switch (this) {
      case TodayAttendanceStatus.notClocked:
        return 'not_clocked';
      case TodayAttendanceStatus.clockedIn:
        return 'clocked_in';
      case TodayAttendanceStatus.onBreak:
        return 'on_break';
      case TodayAttendanceStatus.clockedOut:
        return 'clocked_out';
    }
  }

  static TodayAttendanceStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'not_clocked':
        return TodayAttendanceStatus.notClocked;
      case 'clocked_in':
        return TodayAttendanceStatus.clockedIn;
      case 'on_break':
        return TodayAttendanceStatus.onBreak;
      case 'clocked_out':
        return TodayAttendanceStatus.clockedOut;
      default:
        return TodayAttendanceStatus.notClocked;
    }
  }
}

/// Real-time attendance status for a worker today
class TodayAttendance extends Equatable {
  final String workerId;
  final String workerName;
  final String shopId;
  final String? attendanceId;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final TodayAttendanceStatus currentStatus;
  final double? totalHours;
  final String? status; // 'present', 'absent', 'late', 'half_day'

  const TodayAttendance({
    required this.workerId,
    required this.workerName,
    required this.shopId,
    this.attendanceId,
    this.clockIn,
    this.clockOut,
    required this.currentStatus,
    this.totalHours,
    this.status,
  });

  factory TodayAttendance.fromJson(Map<String, dynamic> json) {
    return TodayAttendance(
      workerId: json['worker_id'],
      workerName: json['worker_name'],
      shopId: json['shop_id'],
      attendanceId: json['attendance_id'],
      clockIn: json['clock_in'] != null
          ? DateTime.parse(json['clock_in'])
          : null,
      clockOut: json['clock_out'] != null
          ? DateTime.parse(json['clock_out'])
          : null,
      currentStatus: TodayAttendanceStatus.fromString(
        json['current_status'] ?? 'not_clocked',
      ),
      totalHours: json['total_hours']?.toDouble(),
      status: json['status'],
    );
  }

  /// Helper to check if worker is currently working
  bool get isWorking => currentStatus == TodayAttendanceStatus.clockedIn ||
      currentStatus == TodayAttendanceStatus.onBreak;

  /// Helper to get formatted clock in time
  String get formattedClockIn {
    if (clockIn == null) return '--:--';
    final hour = clockIn!.hour > 12 ? clockIn!.hour - 12 : (clockIn!.hour == 0 ? 12 : clockIn!.hour);
    final period = clockIn!.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${clockIn!.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  List<Object?> get props => [
    workerId, workerName, shopId, attendanceId, clockIn, clockOut,
    currentStatus, totalHours, status,
  ];
}
