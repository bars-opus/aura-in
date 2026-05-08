import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';

class DayLabel extends StatelessWidget {
  final int day;

  const DayLabel({required this.day});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // PostgreSQL DOW: 0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Center(
      child: Text(
        days[day],
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: FontSizeTokens.xs.sp,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
