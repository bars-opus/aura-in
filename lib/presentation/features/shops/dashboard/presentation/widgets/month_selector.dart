// lib/features/dashboard/presentation/widgets/month_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final Function(DateTime) onMonthChanged;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md.h,
        vertical: Spacing.sm.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppIconButton(
            icon: Icons.chevron_left,
            onPressed: () {
              onMonthChanged(
                DateTime(selectedMonth.year, selectedMonth.month - 1),
              );
            },
          ),
          Text(
            _formatMonthYear(selectedMonth),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          AppIconButton(
            icon: Icons.chevron_right,
            onPressed: () {
              onMonthChanged(
                DateTime(selectedMonth.year, selectedMonth.month + 1),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
