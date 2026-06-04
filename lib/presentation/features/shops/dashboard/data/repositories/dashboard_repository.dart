// lib/features/dashboard/data/repositories/dashboard_repository.dart

import 'package:nano_embryo/presentation/features/shops/calendar/data/models/shop_calendar_booking.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/booking_heatmap_data.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/monthly_revenue.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/quaterly_category_breakdown.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/weekly_revenue.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/clients/client_profile.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/dashboard_metrics.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/lost_booking_metrics.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/export_report.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/performance_alert.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/quarterly_revenue.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/today_schedule_item.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/top_service.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/workers/worker_attendance.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/workers/worker_performance.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/workers/worker_profile.dart';

/// Exception thrown by dashboard repository operations
class DashboardRepositoryException implements Exception {
  final String message;
  final Object? originalError;

  DashboardRepositoryException(this.message, {this.originalError});

  @override
  String toString() => 'DashboardRepositoryException: $message';
}

/// Abstract repository for dashboard data
abstract class DashboardRepository {
  /// Get KPIs for shop owner dashboard
  ///
  /// [shopId] - The shop to get metrics for
  /// [date] - Optional date (defaults to today)
  Future<DashboardMetrics> getMetrics({required String shopId, DateTime? date});

  /// Get today's schedule appointments
  ///
  /// [shopId] - The shop to get schedule for
  /// [date] - Optional date (defaults to today)
  Future<List<TodayScheduleItem>> getTodaySchedule({
    required String shopId,
    DateTime? date,
  });

  /// Get total available slots for today (for occupancy calculation)
  Future<int> getTotalAvailableSlots({
    required String shopId,
    required DateTime date,
  });

  // Add to existing DashboardRepository abstract class

  /// Get quarterly revenue for the current year
  Future<YearlyRevenue> getQuarterlyRevenue({
    required String shopId,
    int? year,
  });

  /// Get top services for a given period
  Future<TopServicesData> getTopServices({
    required String shopId,
    required AnalyticsPeriod period,
    int limit = 5,
  });

  /// Get top workers for a given period
  Future<TopWorkersData> getTopWorkers({
    required String shopId,
    required AnalyticsPeriod period,
    int limit = 5,
  });

  /// Get all workers for a shop
  Future<List<WorkerProfile>> getWorkers({
    required String shopId,
    bool? isActive,
  });

  /// Get a single worker by ID
  Future<WorkerProfile?> getWorkerById({required String workerId});

  /// Create a new worker
  /// Create a new worker (employee only)
  Future<WorkerProfile> createWorker({
    required String shopId,
    required String name,
    String? bio,
    String? profileImageUrl,
    List<String>? specialties,
    double? hourlyRate,
    String? employmentType, // 'full_time', 'part_time', 'contractor'
    DateTime? employmentStart,
  });

  /// Update an existing worker
  Future<WorkerProfile> updateWorker({
    required String workerId,
    String? name,
    String? bio,
    String? profileImageUrl,
    List<String>? specialties,
    bool? isActive,
    double? hourlyRate,
    String? employmentType,
    DateTime? employmentEnd,
  });

  /// Delete a worker (soft delete)
  Future<void> deleteWorker({required String workerId, bool softDelete = true});

  /// Set worker's unavailability
  Future<void> setWorkerUnavailability({
    required String workerId,
    required DateTime startTime,
    required DateTime endTime,
    String? reason,
  });

  /// Get today's attendance for all workers in a shop
  Future<List<Map<String, dynamic>>> getTodayAttendance({
    required String shopId,
  });

  /// Get attendance summary for a worker
  Future<Map<String, dynamic>> getWorkerAttendanceSummary({
    required String workerId,
    DateTime? month,
  });

  /// Get attendance history for a worker
  Future<List<WorkerAttendance>> getWorkerAttendanceHistory({
    required String workerId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  // ============ Client Management ============

  /// Get all clients for a shop
  Future<List<ClientProfile>> getClients({
    required String shopId,
    String? searchQuery,
    bool? isActive,
    int? limit,
  });

  /// Get a single client by ID
  Future<ClientProfile?> getClientById({required String clientId});

  /// Get client analytics (total spend, frequency, etc.)
  Future<Map<String, dynamic>> getClientAnalytics({required String clientId});

  /// Get new vs returning client stats
  Future<Map<String, dynamic>> getClientStats({
    required String shopId,
    int months = 6,
  });

  // Add to existing DashboardRepository abstract class

  // ============ Waitlist Management ============

  // ============ Performance Alerts ============

  /// Get performance alerts for shop
  Future<List<PerformanceAlert>> getAlerts({
    required String shopId,
    bool? unreadOnly,
    int? limit,
  });

  /// Mark alert as read
  Future<void> markAlertRead(String alertId);

  /// Dismiss/resolve alert
  Future<void> resolveAlert(String alertId);

  /// Generate alerts based on current metrics
  Future<List<PerformanceAlert>> generateAlerts(String shopId);

  // ============ Heatmap Analytics ============

  /// Get booking heatmap data
  Future<BookingHeatmapData> getBookingHeatmap({
    required String shopId,
    required DateTime startDate,
    required DateTime endDate,
  });

  // ============ Export Reports ============

  /// Export report based on configuration
  Future<ExportResult> exportReport(ExportConfig config);

  /// Get available report types with data
  Future<List<ReportType>> getAvailableReports(String shopId);

  // ============ Reminder Settings ============

  /// Get reminder settings for shop
  Future<Map<String, dynamic>> getReminderSettings(String shopId);

  /// Update reminder settings
  Future<void> updateReminderSettings({
    required String shopId,
    bool? enabled,
    int? reminderHours,
    bool? smsEnabled,
    bool? emailEnabled,
    bool? marketingEnabled,
  });

  // Add to dashboard_repository.dart


  // Add to DashboardRepository
  Future<List<ShopCalendarBooking>> getWorkerBookings({
    required String workerId,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit = 50,
  });

  /// Get bookings for a specific service (slot)
  Future<List<ShopCalendarBooking>> getServiceBookings({
    required String slotId,
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
  });

  /// Get workers who performed a specific service with their performance
  Future<List<WorkerPerformance>> getWorkersForService({
    required String slotId,
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
  });

  /// Get top services by date range
  Future<List<TopService>> getTopServicesByDateRange({
    required String shopId,
    required DateTime startDate,
    required DateTime endDate,
    int limit = 5,
  });

  /// Get monthly revenue breakdown for a specific quarter
  Future<List<MonthlyRevenue>> getMonthlyRevenueForQuarter({
    required String shopId,
    required int year,
    required int quarter,
  });

  /// Get category breakdown for a specific quarter
  Future<List<QuaterlyCategoryBreakdown>> getCategoryBreakdownForQuarter({
    required String shopId,
    required int year,
    required int quarter,
  });

  // Add these methods
  Future<List<WeeklyRevenue>> getWeeklyRevenueBreakdown({
    required String shopId,
    int weeks = 12,
  });

  Future<List<MonthlyRevenue>> getMonthlyRevenueBreakdown({
    required String shopId,
    int months = 12,
  });

  /// Send manual reminder for a booking
  Future<void> sendManualReminder(String bookingId);

  /// Send bulk reminders for upcoming appointments
  Future<int> sendBulkReminders(String shopId, {DateTime? date});

  /// Get weekly and monthly revenue comparisons
  Future<Map<String, dynamic>> getRevenueComparisons({required String shopId});

  // ============ Lost-booking metrics (Phase 10) ============
  //
  // All three back the Analytics > Revenue headline card. They wrap
  // SECURITY DEFINER RPCs that enforce auth.uid()-owns-shop. On error
  // they throw [DashboardRepositoryException] with a sanitized message;
  // implementations MUST NOT echo raw PostgrestException text.

  /// Returns the lost-booking headline KPI and period-over-period delta
  /// for [shopId] over the last [periodDays] (server-capped to [1, 90]).
  Future<LostBookingSummary> getLostBookingSummary({
    required String shopId,
    int periodDays = 7,
  });

  /// Returns the per-ISO-week lost-booking series for the sparkline.
  /// [weeks] is server-capped to [1, 52].
  Future<List<LostBookingWeek>> getLostBookingWeeklySeries({
    required String shopId,
    int weeks = 12,
  });

  /// Returns the top 50 repeat-offender clients (by lost count) for
  /// [shopId] over the last [lookbackDays]. Guests are excluded server-side
  /// (no joinable identity). [lookbackDays] is server-capped to [7, 365];
  /// [minLost] to [1, 50].
  Future<List<LostBookingOffender>> getLostBookingOffenders({
    required String shopId,
    int lookbackDays = 90,
    int minLost = 2,
  });
}
