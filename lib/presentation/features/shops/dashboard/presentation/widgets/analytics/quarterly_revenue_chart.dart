// lib/features/dashboard/presentation/widgets/quarterly_revenue_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/utils/money.dart';
import 'package:nano_embryo/core/widgets/buttons/app_text_button.dart';
import 'package:nano_embryo/core/widgets/card_inkwell.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/quarterly_revenue.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/quarter_summary_row.dart';

class QuarterlyRevenueChart extends StatelessWidget {
  final YearlyRevenue data;
  final double maxRevenue;
  final String shopCurrencyCode;
  final VoidCallback? onTap;

  const QuarterlyRevenueChart({
    super.key,
    required this.data,
    required this.maxRevenue,
    required this.shopCurrencyCode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (data.quarters.isEmpty) {
      return _buildEmptyState(context);
    }
    // Calculate proper maxY (add 20% padding above the highest bar)
    final highestBar = data.quarters
        .map((q) => q.amount)
        .reduce((a, b) => a > b ? a : b);
    final calculatedMaxY = highestBar * 1.2; // 20% padding
    return CardInkWell(
      // elevation: 0,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quarterly Revenue ${data.year.toString()}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      AppTextButton(
                        padding: Spacing.horizontalSm,
                        text: 'Expand',
                        fontSize: 12.sp,
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: colorScheme.primary,
                        size: IconSizes.md,
                      ),
                    ],
                  ),
                ],
              ),
              RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  children: [
                    TextSpan(
                      text: 'Total:\n',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    TextSpan(
                      text: formatMajorMoney(
                        data.totalRevenue,
                        shopCurrencyCode,
                        fractionDigits: 0,
                      ),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.success,
                      ),
                    ),
                  ],
                ),
                maxLines: 2,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Gap(Spacing.sm.h),

          // Total revenue
          Gap(Spacing.lg.h),

          // Bar chart
          SizedBox(
            height: 250.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: calculatedMaxY,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (groupIndex >= data.quarters.length) {
                        return null;
                      }
                      final quarter = data.quarters[groupIndex];
                      return BarTooltipItem(
                        '${quarter.quarterName}\n${formatMajorMoney(quarter.amount, shopCurrencyCode, fractionDigits: 0)}',
                        theme.textTheme.labelSmall!.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.quarters.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: Spacing.xs.h),
                            child: Text(
                              data.quarters[index].quarterName,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: FontSizeTokens.xs.sp,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 20.h,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('');
                        // Format based on value magnitude
                        if (value >= 1000) {
                          return Text(
                            formatCompactNumber(value),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: FontSizeTokens.xs.sp,
                              color: colorScheme.onSurface,
                            ),
                          );
                        }
                        return Text(
                          formatCompactNumber(value),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: FontSizeTokens.xs.sp,
                            color: colorScheme.onSurface,
                          ),
                        );
                      },
                      reservedSize: 45.w,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: calculatedMaxY / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: colorScheme.outline.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups:
                    data.quarters.asMap().entries.map((entry) {
                      final index = entry.key;
                      final quarter = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: quarter.amount,
                            color: colorScheme.primary,
                            width: Spacing.md,
                            borderRadius: BorderRadius.circular(0.r),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: calculatedMaxY,
                              color: colorScheme.primary.withOpacity(0.1),
                            ),
                          ),
                        ],
                        showingTooltipIndicators: [],
                      );
                    }).toList(),
              ),
            ),
          ),
          AppDivider(),

          // Quarter Summary Row - Quick reference for each quarter
          QuarterSummaryRow(
            quarters: data.quarters,
            colorScheme: colorScheme,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(Spacing.lg.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: BorderWidthTokens.hairline,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.show_chart_outlined,
              size: 48.w,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            Gap(Spacing.sm.h),
            Text(
              'No revenue data available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
