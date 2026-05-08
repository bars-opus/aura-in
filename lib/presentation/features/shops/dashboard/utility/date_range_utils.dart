// lib/core/utils/date_range_utils.dart
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/top_service.dart';

/// Utility class for consistent date range calculations
class DateRangeUtils {
  /// Get date range for a given analytics period
  ///
  /// Returns a tuple of (startDate, endDate) where endDate is inclusive
  /// (set to 23:59:59 of the last day)
  static (DateTime startDate, DateTime endDate) getDateRangeForPeriod(
    AnalyticsPeriod period,
  ) {
    final now = DateTime.now();

    switch (period) {
      case AnalyticsPeriod.weekly:
        return getWeeklyDateRange(now);
      case AnalyticsPeriod.monthly:
        return getMonthlyDateRange(now);
      // case AnalyticsPeriod.daily:
      //   return getDailyDateRange(now);
    }
  }

  /// Get date range for a custom date range with inclusive end date
  static (DateTime startDate, DateTime endDate) getCustomDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return (_normalizeToStartOfDay(startDate), _normalizeToEndOfDay(endDate));
  }

  /// Get weekly date range (Monday to Sunday inclusive)
  static (DateTime startDate, DateTime endDate) getWeeklyDateRange([
    DateTime? referenceDate,
  ]) {
    final now = referenceDate ?? DateTime.now();

    // Find Monday of current week
    final daysSinceMonday = now.weekday - DateTime.monday;
    final startDate = DateTime(now.year, now.month, now.day - daysSinceMonday);

    // End date is Sunday at 23:59:59
    final endDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day + 6,
      23,
      59,
      59,
    );

    return (_normalizeToStartOfDay(startDate), endDate);
  }

  /// Get monthly date range (1st to last day of month inclusive)
  static (DateTime startDate, DateTime endDate) getMonthlyDateRange([
    DateTime? referenceDate,
  ]) {
    final now = referenceDate ?? DateTime.now();

    // Start of month
    final startDate = DateTime(now.year, now.month, 1);

    // End of month (last day at 23:59:59)
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final endDate = DateTime(
      nextMonth.year,
      nextMonth.month,
      nextMonth.day - 1,
      23,
      59,
      59,
    );

    return (startDate, endDate);
  }

  /// Get daily date range (today inclusive)
  static (DateTime startDate, DateTime endDate) getDailyDateRange([
    DateTime? referenceDate,
  ]) {
    final now = referenceDate ?? DateTime.now();

    final startDate = _normalizeToStartOfDay(now);
    final endDate = _normalizeToEndOfDay(now);

    return (startDate, endDate);
  }

  /// Get date range for last N days
  static (DateTime startDate, DateTime endDate) getLastNDays(
    int days, [
    DateTime? referenceDate,
  ]) {
    final now = referenceDate ?? DateTime.now();
    final endDate = _normalizeToEndOfDay(now);
    final startDate = _normalizeToStartOfDay(
      now.subtract(Duration(days: days - 1)),
    );

    return (startDate, endDate);
  }

  /// Normalize a DateTime to the start of the day (00:00:00)
  static DateTime _normalizeToStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Normalize a DateTime to the end of the day (23:59:59)
  static DateTime _normalizeToEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Convert date range to ISO strings for Supabase queries
  static (String startDateStr, String endDateStr) toIsoStrings(
    DateTime startDate,
    DateTime endDate,
  ) {
    return (startDate.toIso8601String(), endDate.toIso8601String());
  }

  /// Format date range for display
  static String formatDateRange(
    DateTime startDate,
    DateTime endDate, {
    String format = 'MMM dd',
  }) {
    final startFormatted = _formatDate(startDate, format);
    final endFormatted = _formatDate(endDate, format);

    if (startDate.month == endDate.month && startDate.year == endDate.year) {
      return '$startFormatted - $endFormatted';
    }
    return '$startFormatted - $endFormatted';
  }

  static String _formatDate(DateTime date, String format) {
    // Simple formatting - you can use intl package for more options
    if (format == 'MMM dd') {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}';
    }
    return '${date.month}/${date.day}';
  }
}

/// Analytics period enum (copy from your existing enum)

