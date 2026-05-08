// lib/features/dashboard/presentation/widgets/attendance_summary_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/utility/calendar_export.dart';

/// Small card showing attendance summary for a worker
class AttendanceSummaryCard extends StatelessWidget {
  final int daysWorked;
  final double totalHours;
  final double onTimeRate;
  final int lateArrivals;
  final VoidCallback? onTap;

  const AttendanceSummaryCard({
    super.key,
    required this.daysWorked,
    required this.totalHours,
    required this.onTimeRate,
    required this.lateArrivals,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          // Days worked
          Expanded(
            child: Column(
              children: [
                Text(
                  daysWorked.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Days',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 30.h, width: 0.5.w, color: Colors.grey),
          // Total hours
          Expanded(
            child: Column(
              children: [
                Text(
                  '${totalHours.toStringAsFixed(1)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Hours',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 30.h, width: 0.5.w, color: Colors.grey),
          // On-time rate
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: IconSizes.xs,
                      color:
                          onTimeRate >= 90
                              ? colorScheme.success
                              : onTimeRate >= 70
                              ? colorScheme.warning
                              : colorScheme.error,
                    ),
                    Gap(Spacing.xs.w),
                    Text(
                      '${onTimeRate.toStringAsFixed(0)}%',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            onTimeRate >= 90
                                ? colorScheme.success
                                : onTimeRate >= 70
                                ? colorScheme.warning
                                : colorScheme.error,
                      ),
                    ),
                  ],
                ),
                Text(
                  'On Time',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          // Late arrivals
          if (lateArrivals > 0)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.xs.w,
                vertical: Spacing.xs.h,
              ),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: IconSizes.xs,
                    color: colorScheme.error,
                  ),
                  Gap(Spacing.xs.w),
                  Text(
                    lateArrivals.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
