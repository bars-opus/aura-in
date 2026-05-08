// lib/features/dashboard/presentation/widgets/heatmap_insights.dart
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/booking_heatmap_data.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/heatmap_insights_data.dart';

class HeatmapInsights extends StatelessWidget {
  final BookingHeatmapData data;

  const HeatmapInsights({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (data.dataPoints.isEmpty) {
      return const SizedBox.shrink();
    }

    final insights = _calculateInsights(data);

    _insightWidget(
      String title,
      String subtitle,
      Color color,
      IconData icon,
      bool showDivider,
    ) {
      return InfoRowWidget(
        title: title,
        subtitle: subtitle,
        iconColor: color,
        backgroundColor: color.withOpacity(.1),
        icon: icon,
        avatarRadius: 20.h,
        showTrailingArrow: false,
        disableTrailing: true,
        circularRadius: 10.r,
        showDivider: showDivider,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Insights',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        Gap(Spacing.md.h),
        // Most Booked Time
        _insightWidget(
          'Most Popular Time',
          '${insights.mostBookedCount} bookings during this hour\n${insights.mostBookedTime}',
          Colors.green,
          Icons.trending_up,
          true,
        ),
        Gap(Spacing.md.h),
        // Least Booked Time
        _insightWidget(
          'Least Popular Time',
          'Only ${insights.leastBookedCount} booking(s) during this hour\n${insights.leastBookedTime}',
          Colors.orange,
          Icons.trending_down,
          true,
        ),
        Gap(Spacing.md.h),
        // Best Day
        _insightWidget(
          'Busiest Day',
          '${insights.busiestDayTotal} total bookings on ${insights.busiestDayName}\n${insights.busiestDayName}',
          Colors.purple,
          Icons.celebration,
          true,
        ),
        Gap(Spacing.md.h),
        // Worst Day
        _insightWidget(
          'Quietest Day',
          'Only ${insights.quietestDayTotal} bookings on ${insights.quietestDayName}\n${insights.quietestDayName}',
          Colors.blueGrey,
          Icons.bedtime,
          false,
        ),

        if (insights.saturdayPeakTime != null) ...[
          Gap(Spacing.md.h),
          AppDivider(),
          Gap(Spacing.md.h),
          _insightWidget(
            'Saturday Peak',
            'Most bookings on Saturday at this time\n${insights.saturdayPeakTime}',
            Colors.teal,
            Icons.weekend,
            true,
          ),
        ],
        if (insights.saturdayQuietTime != null) ...[
          Gap(Spacing.sm.h),
          _insightWidget(
            'Saturday Quietest',
            'Fewest bookings on Saturday at this time\n${insights.saturdayQuietTime}',
            Colors.indigo,
            Icons.nights_stay,
            false,
          ),
        ],
      ],
    );
  }

  HeatmapInsightsData _calculateInsights(BookingHeatmapData data) {
    if (data.dataPoints.isEmpty) {
      return HeatmapInsightsData.empty();
    }

    // Find most and least booked
    HeatmapDataPoint? mostBooked;
    HeatmapDataPoint? leastBooked;

    for (final point in data.dataPoints) {
      if (mostBooked == null || point.bookingCount > mostBooked.bookingCount) {
        mostBooked = point;
      }
      if (leastBooked == null ||
          point.bookingCount < leastBooked.bookingCount) {
        leastBooked = point;
      }
    }

    // Aggregate by day
    final Map<int, int> dayTotals = {};
    for (final point in data.dataPoints) {
      dayTotals[point.dayOfWeek] =
          (dayTotals[point.dayOfWeek] ?? 0) + point.bookingCount;
    }

    // Find busiest and quietest day
    MapEntry<int, int>? busiestDayEntry;
    MapEntry<int, int>? quietestDayEntry;
    for (final entry in dayTotals.entries) {
      if (busiestDayEntry == null || entry.value > busiestDayEntry.value) {
        busiestDayEntry = entry;
      }
      if (quietestDayEntry == null || entry.value < quietestDayEntry.value) {
        quietestDayEntry = entry;
      }
    }

    // Saturday-specific insights (day 6 = Saturday)
    final saturdayPoints =
        data.dataPoints.where((p) => p.dayOfWeek == 6).toList();
    HeatmapDataPoint? saturdayPeak;
    HeatmapDataPoint? saturdayQuiet;

    for (final point in saturdayPoints) {
      if (saturdayPeak == null ||
          point.bookingCount > saturdayPeak.bookingCount) {
        saturdayPeak = point;
      }
      if (saturdayQuiet == null ||
          point.bookingCount < saturdayQuiet.bookingCount) {
        saturdayQuiet = point;
      }
    }

    return HeatmapInsightsData(
      mostBooked: mostBooked!,
      leastBooked: leastBooked!,
      busiestDayEntry: busiestDayEntry!,
      quietestDayEntry: quietestDayEntry!,
      saturdayPeak: saturdayPeak,
      saturdayQuiet: saturdayQuiet,
    );
  }
}
