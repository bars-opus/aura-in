// lib/features/dashboard/data/models/today_schedule_item.dart
import 'package:equatable/equatable.dart';
import 'package:nano_embryo/app/theme/app_colors.dart';

/// Single appointment item for today's schedule
class TodayScheduleItem extends Equatable {
  final String id;
  final String clientName;
  final String serviceName;
  final String workerName;
  final String workerId;
  final DateTime startTime;
  final DateTime endTime;
  final StatusColor status;
  final double price;
  final double? depositPaid;
  final String? clientPhone;
  final String? clientAvatarUrl;

  const TodayScheduleItem({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.workerName,
    required this.workerId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.price,
    this.depositPaid,
    this.clientPhone,
    this.clientAvatarUrl,
  });

  /// Format start time for display (e.g., "9:30 AM")
  String get formattedStartTime {
    // Using intl package - placeholder implementation
    final hour = startTime.hour;
    final minute = startTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $period';
  }

  Map<String, dynamic> toJson() {
    String statusToString(StatusColor s) {
      switch (s) {
        case StatusColor.confirmed:
          return 'confirmed';
        case StatusColor.completed:
          return 'completed';
        case StatusColor.cancelled:
          return 'cancelled';
        case StatusColor.noShow:
          return 'no_show';
        case StatusColor.pending:
        default:
          return 'pending';
      }
    }

    return {
      'id': id,
      'client_name': clientName,
      'service_name': serviceName,
      'worker_name': workerName,
      'worker_id': workerId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': statusToString(status),
      'price': price,
      // Only include deposit_paid if not null to keep payload compact
      if (depositPaid != null) 'deposit_paid': depositPaid,
      if (clientPhone != null) 'client_phone': clientPhone,
      if (clientAvatarUrl != null) 'client_avatar_url': clientAvatarUrl,
    };
  }

  factory TodayScheduleItem.fromJson(Map<String, dynamic> json) {
    return TodayScheduleItem(
      id: json['id'],
      clientName: json['client_name'] ?? 'Unknown Client',
      serviceName: json['service_name'] ?? 'Service',
      workerName: json['worker_name'] ?? 'Unassigned',
      workerId: json['worker_id'] ?? '',
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      status: _parseStatus(json['status']),
      price: (json['price'] ?? 0).toDouble(),
      depositPaid: json['deposit_paid']?.toDouble(),
      clientPhone: json['client_phone'],
      clientAvatarUrl: json['client_avatar_url'],
    );
  }

  static StatusColor _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return StatusColor.confirmed;
      case 'completed':
        return StatusColor.completed;
      case 'cancelled':
        return StatusColor.cancelled;
      case 'no_show':
      case 'noshow':
        return StatusColor.noShow;
      default:
        return StatusColor.pending;
    }
  }

  @override
  List<Object?> get props => [
    id,
    clientName,
    serviceName,
    workerName,
    startTime,
    status,
    price,
  ];
}
