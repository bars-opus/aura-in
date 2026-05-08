// lib/features/dashboard/presentation/widgets/revenue_comparison_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/app_colors.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/revenue_breakdown_screen.dart';

class RevenueComparisonCard extends StatelessWidget {
  final double weeklyRevenue;
  final double previousWeeklyRevenue;
  final double monthlyRevenue;
  final double previousMonthlyRevenue;
  final String shopId;

  const RevenueComparisonCard({
    super.key,
    required this.weeklyRevenue,
    required this.previousWeeklyRevenue,
    required this.monthlyRevenue,
    required this.shopId,
    required this.previousMonthlyRevenue,
  });

  double get weeklyChangePercent {
    if (previousWeeklyRevenue == 0) return 0;
    return (weeklyRevenue - previousWeeklyRevenue) / previousWeeklyRevenue;
  }

  double get monthlyChangePercent {
    if (previousMonthlyRevenue == 0) return 0;
    return (monthlyRevenue - previousMonthlyRevenue) / previousMonthlyRevenue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CardInkWell(
      onTap: () {
        BottomSheetUtils.showDocumentationBottomSheet(
          showButtons: true,
          // maxHeight: 320.h,
          context: context,
          widget: RevenueBreakdownScreen(
            shopId: shopId,
            initialType: BreakdownType.weekly,
          ),
        );
      },
      child: Row(
        children: [
          Expanded(
            child: _ComparisonItem(
              label: 'This Week',
              revenue: weeklyRevenue,
              changePercent: weeklyChangePercent,
              isPositiveGood: true,
            ),
          ),
          Container(
            width: 1.w,
            height: 60.h,
            color: colorScheme.outline.withOpacity(0.1),
          ),
          Expanded(
            child: _ComparisonItem(
              label: 'This Month',
              revenue: monthlyRevenue,
              changePercent: monthlyChangePercent,
              isPositiveGood: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonItem extends StatelessWidget {
  final String label;
  final double revenue;
  final double changePercent;
  final bool isPositiveGood;

  const _ComparisonItem({
    required this.label,
    required this.revenue,
    required this.changePercent,
    required this.isPositiveGood,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isPositive = changePercent >= 0;
    final isGood = isPositive == isPositiveGood;

    return Column(
      children: [
        Icon(Icons.arrow_upward, size: 20.w, color: colorScheme.success),
        Gap(Spacing.xs.h),
        Text(
          '\$${revenue.toStringAsFixed(0)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),

        Gap(Spacing.xs.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              size: IconSizes.xs,
              color: isGood ? colorScheme.success : colorScheme.error,
            ),
            Gap(Spacing.xs.w),
            Text(
              '${(changePercent.abs() * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isGood ? colorScheme.success : colorScheme.error,
              ),
            ),
            Gap(Spacing.xs.w),
            Text(
              'vs last ${label.toLowerCase()}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
