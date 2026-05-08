// lib/features/dashboard/data/models/dashboard_metrics.dart
import 'package:equatable/equatable.dart';

/// Core KPIs for shop owner dashboard
class DashboardMetrics extends Equatable {
  /// Today's total revenue (deposits collected + expected today)
  final double todayRevenue;

  /// Number of bookings for today
  final int todayBookings;

  /// Occupancy rate (0.0 - 1.0) - percentage of available slots filled
  final double occupancyRate;

  /// Cancellation rate for current period (0.0 - 1.0)
  final double cancellationRate;

  /// Optional: Change percentages for trends
  final double? revenueChangePercent;
  final double? bookingsChangePercent;

  const DashboardMetrics({
    required this.todayRevenue,
    required this.todayBookings,
    required this.occupancyRate,
    required this.cancellationRate,
    this.revenueChangePercent,
    this.bookingsChangePercent,
  });

  /// Empty state for loading/error
  static const empty = DashboardMetrics(
    todayRevenue: 0,
    todayBookings: 0,
    occupancyRate: 0,
    cancellationRate: 0,
  );

  /// Create from JSON (from Supabase query)
  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      todayRevenue: (json['today_revenue'] ?? 0).toDouble(),
      todayBookings: json['today_bookings'] ?? 0,
      occupancyRate: (json['occupancy_rate'] ?? 0).toDouble(),
      cancellationRate: (json['cancellation_rate'] ?? 0).toDouble(),
      revenueChangePercent: json['revenue_change_percent']?.toDouble(),
      bookingsChangePercent: json['bookings_change_percent']?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    todayRevenue,
    todayBookings,
    occupancyRate,
    cancellationRate,
    revenueChangePercent,
    bookingsChangePercent,
  ];
}
