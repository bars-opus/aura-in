import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/weekly_revenue.dart';

class RevenueWeeklyCard extends StatelessWidget {
  final WeeklyRevenue week;

  const RevenueWeeklyCard({required this.week});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCurrentWeek = week.isPartial;
    final dominantMonth = _getDominantMonth(week.startDate, week.endDate);
    final isDifferentMonth = week.startDate.month != week.endDate.month;
    return CardInkWell(
      margin: EdgeInsets.only(bottom: Spacing.sm.h),
      onTap: () {},
      color:
          isCurrentWeek
              ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
              : Theme.of(context).cardColor,

      child: Row(
        children: [
          // Week info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      week.weekLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    if (isDifferentMonth) ...[
                      Gap(Spacing.sm.w),
                      MiniContainerIndicator(
                        color: colorScheme.warning,
                        text: 'Cross-month',
                      ),
                    ],
                    if (isCurrentWeek) ...[
                      Gap(Spacing.xs.w),
                      MiniContainerIndicator(
                        color: colorScheme.primary,
                        text: 'Current',
                      ),
                    ],
                  ],
                ),
                Gap(Spacing.xs.h),
                Text(
                  _formatWeekRange(week.startDate, week.endDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Stats
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${week.revenue.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  '${week.bookingCount} bookings',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to determine which month has majority of days in a week
  DateTime _getDominantMonth(DateTime startDate, DateTime endDate) {
    final daysInStartMonth = _getDaysInMonth(startDate.year, startDate.month);
    final daysInEndMonth = _getDaysInMonth(endDate.year, endDate.month);

    // Calculate days in start month vs end month
    final startMonthDays = daysInStartMonth - startDate.day + 1;
    final endMonthDays = endDate.day;

    if (startMonthDays >= endMonthDays) {
      return DateTime(startDate.year, startDate.month, 1);
    } else {
      return DateTime(endDate.year, endDate.month, 1);
    }
  }

  int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      final isLeapYear =
          (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonth[month - 1];
  }

  String _formatWeekRange(DateTime start, DateTime end) {
    if (start.month == end.month) {
      return '${_getMonthAbbr(start.month)} ${start.day} - ${end.day}';
    } else {
      return '${_getMonthAbbr(start.month)} ${start.day} - ${_getMonthAbbr(end.month)} ${end.day}';
    }
  }

  String _getMonthAbbr(int month) {
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
    return months[month - 1];
  }
}
