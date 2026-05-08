// lib/features/dashboard/data/models/worker_service_performance.dart
import 'package:equatable/equatable.dart';

/// Represents a worker's performance for a specific service
class WorkerServicePerformance extends Equatable {
  final String serviceId;
  final String serviceName;
  final int bookingCount;
  final double revenue;
  final double percentage;

  const WorkerServicePerformance({
    required this.serviceId,
    required this.serviceName,
    required this.bookingCount,
    required this.revenue,
    this.percentage = 0,
  });

  factory WorkerServicePerformance.fromJson(Map<String, dynamic> json) {
    return WorkerServicePerformance(
      serviceId: json['service_id'],
      serviceName: json['service_name'],
      bookingCount: json['booking_count'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'service_name': serviceName,
      'booking_count': bookingCount,
      'revenue': revenue,
      'percentage': percentage,
    };
  }

  WorkerServicePerformance copyWith({
    String? serviceId,
    String? serviceName,
    int? bookingCount,
    double? revenue,
    double? percentage,
  }) {
    return WorkerServicePerformance(
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      bookingCount: bookingCount ?? this.bookingCount,
      revenue: revenue ?? this.revenue,
      percentage: percentage ?? this.percentage,
    );
  }

  @override
  List<Object?> get props => [serviceId, serviceName, bookingCount, revenue, percentage];
}
