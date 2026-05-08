// lib/features/dashboard/presentation/widgets/stats_chip.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';

class StatsChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? backgroundColor;

  const StatsChip({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xs.w,
        vertical: Spacing.xs.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: IconSizes.xs,
            color: iconColor ?? colorScheme.onSurfaceVariant,
          ),
          Gap(Spacing.xs.w),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: iconColor ?? colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
