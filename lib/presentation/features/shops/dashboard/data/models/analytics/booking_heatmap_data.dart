// lib/features/dashboard/data/models/booking_heatmap_models.dart

import 'package:equatable/equatable.dart';

// Top-level helper functions
int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

/// Individual data point for the heatmap
class HeatmapDataPoint extends Equatable {
  final int dayOfWeek;
  final int hour;
  final int bookingCount;
  final double occupancyRate;

  const HeatmapDataPoint({
    required this.dayOfWeek,
    required this.hour,
    required this.bookingCount,
    this.occupancyRate = 0.0,
  });

  factory HeatmapDataPoint.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const HeatmapDataPoint(dayOfWeek: 0, hour: 0, bookingCount: 0);
    }

    return HeatmapDataPoint(
      dayOfWeek: _toInt(json['day_of_week']),
      hour: _toInt(json['hour']),
      bookingCount: _toInt(json['booking_count']),
      occupancyRate: _toDouble(json['occupancy_rate']),
    );
  }

  @override
  List<Object?> get props => [dayOfWeek, hour, bookingCount, occupancyRate];
}

/// Complete heatmap data for a date range
class BookingHeatmapData extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final int maxBookingCount;
  final double maxOccupancyRate;
  final List<HeatmapDataPoint> dataPoints;

  const BookingHeatmapData({
    required this.startDate,
    required this.endDate,
    required this.maxBookingCount,
    required this.maxOccupancyRate,
    required this.dataPoints,
  });

  static final empty = BookingHeatmapData(
    startDate: DateTime(1970),
    endDate: DateTime(1970),
    maxBookingCount: 0,
    maxOccupancyRate: 0.0,
    dataPoints: [],
  );

  factory BookingHeatmapData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return BookingHeatmapData.empty;
    }

    try {
      DateTime startDate;
      try {
        startDate = DateTime.parse(json['start_date']?.toString() ?? '');
      } catch (e) {
        startDate = DateTime.now();
      }

      DateTime endDate;
      try {
        endDate = DateTime.parse(json['end_date']?.toString() ?? '');
      } catch (e) {
        endDate = DateTime.now();
      }

      final maxBookingCount = _toInt(json['max_booking_count']);
      final maxOccupancyRate = _toDouble(json['max_occupancy_rate']);

      List<HeatmapDataPoint> dataPoints = [];
      final dataPointsJson = json['data_points'];

      if (dataPointsJson != null && dataPointsJson is List) {
        dataPoints =
            dataPointsJson
                .map(
                  (point) =>
                      HeatmapDataPoint.fromJson(point as Map<String, dynamic>?),
                )
                .toList();
      }

      return BookingHeatmapData(
        startDate: startDate,
        endDate: endDate,
        maxBookingCount: maxBookingCount,
        maxOccupancyRate: maxOccupancyRate,
        dataPoints: dataPoints,
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing BookingHeatmapData: $e');
      return BookingHeatmapData.empty;
    }
  }

  Map<String, HeatmapDataPoint> get pointsMap {
    final map = <String, HeatmapDataPoint>{};
    for (final point in dataPoints) {
      final key = '${point.dayOfWeek}_${point.hour}';
      map[key] = point;
    }
    return map;
  }

  double getIntensity(int bookingCount) {
    if (maxBookingCount == 0) return 0.0;
    return (bookingCount / maxBookingCount).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    maxBookingCount,
    maxOccupancyRate,
    dataPoints,
  ];
}
