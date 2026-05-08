import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/card_inkwell.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/monthly_revenue.dart';

class RevenueMonthlyCard extends StatelessWidget {
  final MonthlyRevenue month;

  const RevenueMonthlyCard({required this.month});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CardInkWell(
      margin: EdgeInsets.only(bottom: Spacing.sm.h),
      onTap: () {},
      child: Row(
        children: [
          SizedBox(
            width: 100.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month.monthName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  month.year.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${month.revenue.toStringAsFixed(0)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
                Text(
                  '${month.bookingCount} bookings',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
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
