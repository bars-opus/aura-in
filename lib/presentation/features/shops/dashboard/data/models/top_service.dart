// lib/features/dashboard/data/models/top_service.dart
import 'package:equatable/equatable.dart';

/// Time period for analytics
enum AnalyticsPeriod {
  weekly,
  monthly;

  String get displayName {
    switch (this) {
      case AnalyticsPeriod.weekly:
        return 'This Week';
      case AnalyticsPeriod.monthly:
        return 'This Month';
    }
  }

  String get apiParam {
    switch (this) {
      case AnalyticsPeriod.weekly:
        return 'week';
      case AnalyticsPeriod.monthly:
        return 'month';
    }
  }
}

/// Top service analytics data
class TopService extends Equatable {
  final String id;
  final String name;
  final int bookingCount;
  final double percentage;
  final double revenue;
  final double? revenueChangePercent;

  const TopService({
    required this.id,
    required this.name,
    required this.bookingCount,
    required this.percentage,
    required this.revenue,
    this.revenueChangePercent,
  });

  factory TopService.fromJson(Map<String, dynamic> json) {
    return TopService(
      id: json['service_id'] ?? json['id'],
      name: json['service_name'] ?? json['name'],
      bookingCount: json['booking_count'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      revenue: (json['revenue'] ?? 0).toDouble(),
      revenueChangePercent: json['revenue_change_percent']?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    id, name, bookingCount, percentage, revenue, revenueChangePercent
  ];
}

/// Collection of top services
class TopServicesData extends Equatable {
  final AnalyticsPeriod period;
  final List<TopService> services;
  final int totalBookings;
  final double totalRevenue;

  const TopServicesData({
    required this.period,
    required this.services,
    required this.totalBookings,
    required this.totalRevenue,
  });

  factory TopServicesData.fromJson(Map<String, dynamic> json) {
    final servicesData = List<Map<String, dynamic>>.from(json['services'] ?? []);
    final services = servicesData.map(TopService.fromJson).toList();

    return TopServicesData(
      period: json['period'] == 'week'
          ? AnalyticsPeriod.weekly
          : AnalyticsPeriod.monthly,
      services: services,
      totalBookings: json['total_bookings'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
    );
  }

  static const empty = TopServicesData(
    period: AnalyticsPeriod.weekly,
    services: [],
    totalBookings: 0,
    totalRevenue: 0,
  );

  @override
  List<Object?> get props => [period, services, totalBookings, totalRevenue];
}
