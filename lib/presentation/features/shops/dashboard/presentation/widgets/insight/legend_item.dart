import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        Gap(Spacing.xs.w),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: FontSizeTokens.xxs.sp,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
