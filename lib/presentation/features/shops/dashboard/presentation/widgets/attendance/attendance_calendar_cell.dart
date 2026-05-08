// lib/features/dashboard/presentation/widgets/attendance_calendar_cell.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/utility/calendar_export.dart';

class AttendanceCalendarCell extends StatelessWidget {
  final int day;
  final Map<String, dynamic>? attendance;

  const AttendanceCalendarCell({super.key, required this.day, this.attendance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasData = attendance != null;
    final status = attendance?['status'] ?? '';
    final clockIn = attendance?['clock_in'] ?? '';
    final clockOut = attendance?['clock_out'] ?? '';

    Color getStatusColor() {
      if (!hasData) return colorScheme.onSurface.withOpacity(0.1);
      switch (status.toLowerCase()) {
        case 'present':
          return colorScheme.success;
        case 'late':
          return colorScheme.warning;
        case 'absent':
          return colorScheme.error;
        case 'half_day':
          return colorScheme.info;
        default:
          return colorScheme.onSurface.withOpacity(0.3);
      }
    }

    IconData getStatusIcon() {
      if (!hasData) return Icons.remove;
      switch (status.toLowerCase()) {
        case 'present':
          return Icons.check_circle;
        case 'late':
          return Icons.warning_amber;
        case 'absent':
          return Icons.cancel;
        case 'half_day':
          return Icons.hourglass_empty;
        default:
          return Icons.remove;
      }
    }

    return Container(
      width: 80.w,
      padding: EdgeInsets.all(Spacing.xs.h),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(getStatusIcon(), size: IconSizes.md, color: getStatusColor()),
          if (hasData) ...[
            Gap(Spacing.xs.h),
            Text(
              clockIn,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: FontSizeTokens.xxs.sp,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              clockOut,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: FontSizeTokens.xxs.sp,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
