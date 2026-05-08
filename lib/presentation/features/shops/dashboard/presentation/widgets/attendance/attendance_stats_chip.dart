// lib/features/dashboard/presentation/widgets/attendance_stats_chip.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';

/// Small chip displaying a single attendance stat
class AttendanceStatsChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const AttendanceStatsChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm.w,
        vertical: Spacing.xs.h,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: IconSizes.xs,
            color: color ?? colorScheme.onSurfaceVariant,
          ),
          Gap(Spacing.xs.w),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Gap(Spacing.xs.w),
          Text(
            value,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color ?? colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
