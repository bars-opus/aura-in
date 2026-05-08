import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/booking_heatmap_data.dart';

class HeatmapInsightsData {
  final HeatmapDataPoint mostBooked;
  final HeatmapDataPoint leastBooked;
  final MapEntry<int, int> busiestDayEntry;
  final MapEntry<int, int> quietestDayEntry;
  final HeatmapDataPoint? saturdayPeak;
  final HeatmapDataPoint? saturdayQuiet;

  HeatmapInsightsData({
    required this.mostBooked,
    required this.leastBooked,
    required this.busiestDayEntry,
    required this.quietestDayEntry,
    this.saturdayPeak,
    this.saturdayQuiet,
  });

  factory HeatmapInsightsData.empty() {
    return HeatmapInsightsData(
      mostBooked: const HeatmapDataPoint(
        dayOfWeek: 0,
        hour: 0,
        bookingCount: 0,
      ),
      leastBooked: const HeatmapDataPoint(
        dayOfWeek: 0,
        hour: 0,
        bookingCount: 0,
      ),
      busiestDayEntry: const MapEntry(0, 0),
      quietestDayEntry: const MapEntry(0, 0),
      saturdayPeak: null,
      saturdayQuiet: null,
    );
  }

  // Most booked time
  String get mostBookedTime =>
      '${_getDayName(mostBooked.dayOfWeek)} at ${_formatHour(mostBooked.hour)}';
  int get mostBookedCount => mostBooked.bookingCount;

  // Least booked time
  String get leastBookedTime =>
      '${_getDayName(leastBooked.dayOfWeek)} at ${_formatHour(leastBooked.hour)}';
  int get leastBookedCount => leastBooked.bookingCount;

  // Busiest day (renamed getters)
  String get busiestDayName => _getDayName(busiestDayEntry.key);
  int get busiestDayTotal => busiestDayEntry.value;

  // Quietest day (renamed getters)
  String get quietestDayName => _getDayName(quietestDayEntry.key);
  int get quietestDayTotal => quietestDayEntry.value;

  // Saturday specific
  String? get saturdayPeakTime =>
      saturdayPeak != null ? _formatHour(saturdayPeak!.hour) : null;
  String? get saturdayQuietTime =>
      saturdayQuiet != null ? _formatHour(saturdayQuiet!.hour) : null;

  String _getDayName(int day) {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return days[day];
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12am';
    if (hour < 12) return '${hour}am';
    if (hour == 12) return '12pm';
    return '${hour - 12}pm';
  }
}
