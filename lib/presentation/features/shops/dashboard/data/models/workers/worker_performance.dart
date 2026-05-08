// lib/features/dashboard/data/models/worker_performance.dart
import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/top_service.dart';

/// Performance metrics for a single worker
class WorkerPerformance extends Equatable {
  final String id;
  final String name;
  final String? profileImageUrl;
  final int bookingCount;
  final double revenue;
  final double? averageRating;
  final int? totalReviews;
  final double? bookingChangePercent;

  const WorkerPerformance({
    required this.id,
    required this.name,
    this.profileImageUrl,
    required this.bookingCount,
    required this.revenue,
    this.averageRating,
    this.totalReviews,
    this.bookingChangePercent,
  });

  factory WorkerPerformance.fromJson(Map<String, dynamic> json) {
    return WorkerPerformance(
      id: json['worker_id'] ?? json['id'],
      name: json['worker_name'] ?? json['name'],
      profileImageUrl: json['profile_image'],
      bookingCount: json['booking_count'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      averageRating: json['average_rating']?.toDouble(),
      totalReviews: json['total_reviews'],
      bookingChangePercent: json['booking_change_percent']?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    id, name, profileImageUrl, bookingCount, revenue,
    averageRating, totalReviews, bookingChangePercent
  ];
}

/// Collection of top workers
class TopWorkersData extends Equatable {
  final AnalyticsPeriod period;
  final List<WorkerPerformance> workers;
  final int totalBookings;
  final double totalRevenue;

  const TopWorkersData({
    required this.period,
    required this.workers,
    required this.totalBookings,
    required this.totalRevenue,
  });

  factory TopWorkersData.fromJson(Map<String, dynamic> json) {
    final workersData = List<Map<String, dynamic>>.from(json['workers'] ?? []);
    final workers = workersData.map(WorkerPerformance.fromJson).toList();

    return TopWorkersData(
      period: json['period'] == 'week'
          ? AnalyticsPeriod.weekly
          : AnalyticsPeriod.monthly,
      workers: workers,
      totalBookings: json['total_bookings'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
    );
  }

  static const empty = TopWorkersData(
    period: AnalyticsPeriod.weekly,
    workers: [],
    totalBookings: 0,
    totalRevenue: 0,
  );

  @override
  List<Object?> get props => [period, workers, totalBookings, totalRevenue];
}
