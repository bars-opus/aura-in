// lib/features/dashboard/presentation/widgets/worker_attendance_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/utility/calendar_export.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/workers/worker_attendance.dart';

class WorkerAttendanceList extends StatelessWidget {
  final List<WorkerAttendance> attendances;
  final Function(WorkerAttendance)? onItemTap;

  const WorkerAttendanceList({
    super.key,
    required this.attendances,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (attendances.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 48.w,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            Gap(Spacing.sm.h),
            Text(
              'No attendance records',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: attendances.length,
      itemBuilder: (context, index) {
        final attendance = attendances[index];
        return _AttendanceListItem(
          attendance: attendance,
          onTap: () => onItemTap?.call(attendance),
        );
      },
    );
  }
}

class _AttendanceListItem extends StatelessWidget {
  final WorkerAttendance attendance;
  final VoidCallback? onTap;

  const _AttendanceListItem({required this.attendance, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _getStatusColor(attendance.status, colorScheme);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: Spacing.sm.h),
        padding: EdgeInsets.all(Spacing.md.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.1),
            width: BorderWidthTokens.hairline,
          ),
        ),
        child: Row(
          children: [
            // Date
            Container(
              width: 80.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(attendance.date),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatDay(attendance.date),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Status badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.xs.w,
                vertical: Spacing.xs.h,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                attendance.status.displayName,
                style: theme.textTheme.labelSmall?.copyWith(color: statusColor),
              ),
            ),
            Gap(Spacing.sm.w),

            // Time info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    attendance.formattedClockIn,
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    attendance.formattedClockOut,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Hours
            Container(
              width: 60.w,
              child: Text(
                attendance.formattedTotalHours,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status, ColorScheme colorScheme) {
    switch (status) {
      case AttendanceStatus.present:
        return colorScheme.success;
      case AttendanceStatus.absent:
        return colorScheme.error;
      case AttendanceStatus.late:
        return colorScheme.warning;
      case AttendanceStatus.halfDay:
        return colorScheme.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  String _formatDay(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
