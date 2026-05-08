import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/quarterly_revenue.dart';

class QuarterSummaryRow extends StatelessWidget {
  final List<QuarterlyRevenue> quarters;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const QuarterSummaryRow({
    required this.quarters,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        final quarterNumber = index + 1;
        final quarterData = quarters.firstWhere(
          (q) => q.quarter == quarterNumber,
          orElse:
              () => QuarterlyRevenue(
                quarter: quarterNumber,
                amount: 0,
                year: DateTime.now().year,
              ),
        );

        final isHighest =
            quarters.isNotEmpty &&
            quarterData.amount > 0 &&
            quarterData.amount ==
                quarters.map((q) => q.amount).reduce((a, b) => a > b ? a : b);

        return _QuarterSummaryItem(
          quarterName: 'Q$quarterNumber',
          amount: quarterData.amount,
          isHighest: isHighest,
          colorScheme: colorScheme,
          theme: theme,
        );
      }),
    );
  }
}

class _QuarterSummaryItem extends StatelessWidget {
  final String quarterName;
  final double amount;
  final bool isHighest;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _QuarterSummaryItem({
    required this.quarterName,
    required this.amount,
    required this.isHighest,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = amount > 0;

    return Expanded(
      child: Column(
        children: [
          Text(
            quarterName,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Gap(Spacing.xs.h),
          Text(
            hasData ? '\$${amount.toStringAsFixed(0)}' : '--',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color:
                  isHighest
                      ? colorScheme.info
                      : hasData
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          if (isHighest && hasData)
            MiniContainerIndicator(color: colorScheme.info, text: 'Best'),
        ],
      ),
    );
  }
}
