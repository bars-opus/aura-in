// lib/features/dashboard/presentation/widgets/quarterly_summary_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/core/widgets/card_inkwell.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/quarterly_revenue.dart';

class DetailedQuarterlySummaryCard extends StatelessWidget {
  final int quarter;
  final QuarterlyRevenue quarterData;
  final int totalBookings;

  const DetailedQuarterlySummaryCard({
    super.key,
    required this.quarter,
    required this.quarterData,
    required this.totalBookings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CardInkWell(
      
      onTap: () {},
      child: Row(
        children: [
          Expanded(
            child: _widget(
              context,
              'Q$quarter Revenue\n',
              quarterData.amount > 0
                  ? '\$${quarterData.amount.toStringAsFixed(0)}'
                  : '--',
            ),
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: colorScheme.outline.withOpacity(0.1),
          ),
          Expanded(
            child: _widget(
              context,
              'Total Bookings\n',
              totalBookings.toString(),
            ),
          ),
        ],
      ),
    );
  }

  _widget(BuildContext context, String title, String body) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        children: [
          TextSpan(
            text: title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          TextSpan(
            text: body,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      maxLines: 2,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    );
  }
}
