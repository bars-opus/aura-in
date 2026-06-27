// lib/features/dashboard/presentation/widgets/monthly_revenue_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/utils/money.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/monthly_revenue.dart';

class DetailedQuarterlyMonthlyRevenueChart extends StatelessWidget {
  final List<MonthlyRevenue> data;
  final String shopCurrencyCode;
  final bool isLoading;

  const DetailedQuarterlyMonthlyRevenueChart({
    super.key,
    required this.data,
    required this.shopCurrencyCode,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return _buildLoadingState(theme);
    }

    if (data.isEmpty || data.every((d) => d.revenue == 0)) {
      return _buildEmptyState(theme, colorScheme);
    }

    final maxRevenue = data
        .map((d) => d.revenue)
        .reduce((a, b) => a > b ? a : b);
    final spots = List.generate(data.length, (index) {
      return FlSpot(index.toDouble(), data[index].revenue);
    });

    return CardInkWell(
      onTap: () {},
      child: SizedBox(
        height: 350.h,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < data.length) {
                      return Padding(
                        padding: EdgeInsets.only(top: Spacing.xs.h),
                        child: Text(
                          data[index].monthName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onBackground,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                  reservedSize: 30.h,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const Text('');
                    // Format as thousands with 'k'
                    return Text(
                      formatCompactNumber(value),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onBackground,
                      ),
                    );
                  },
                  reservedSize: 40.w,
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            minY: 0,
            maxY: maxRevenue * 1.2,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: colorScheme.primary,
                barWidth: 3,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: colorScheme.primary.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return ShopSchimmerSkeleton(height: 350.h);
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return CardInkWell(
      onTap: () {},
      child: SizedBox(
        height: 350.h,
        child: Center(
          child: EmptyStateWidget(
            icon: Icons.line_axis,
            title: '',
            subtitle: 'No monthly graph data available for this quarter',
          ),
        ),
      ),
    );
  }
}
