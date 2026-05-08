// lib/features/dashboard/presentation/screens/quarterly_revenue_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/app_tabs.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/quarterly_revenue.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/quarterly_revenue_controller.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/detailed_quarterly_summary_card.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/quarterly_category_breakdown_list.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/detailed_quarterly_monthly_revenue_chart.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_schimmer_skeleton.dart';
import 'package:nano_embryo/presentation/home/widgets/tabs_with_content.dart';

class QuarterlyRevenueDetailScreen extends ConsumerStatefulWidget {
  final String shopId;
  final YearlyRevenue yearlyRevenue;

  const QuarterlyRevenueDetailScreen({
    super.key,
    required this.shopId,
    required this.yearlyRevenue,
  });

  @override
  ConsumerState<QuarterlyRevenueDetailScreen> createState() =>
      _QuarterlyRevenueDetailScreenState();
}

class _QuarterlyRevenueDetailScreenState
    extends ConsumerState<QuarterlyRevenueDetailScreen> {
  // Cache the provider value to avoid recreating
  late final QuarterlyRevenueParams _params;

  @override
  void initState() {
    super.initState();
    _params = QuarterlyRevenueParams(
      shopId: widget.shopId,
      year: widget.yearlyRevenue.year,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Build content for a specific quarter
  Widget _buildQuarterContent(int quarter) {
    final state = ref.watch(quarterlyRevenueControllerProviderFamily(_params));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final quarterData = widget.yearlyRevenue.quarters.firstWhere(
      (q) => q.quarter == quarter,
      orElse:
          () => QuarterlyRevenue(
            quarter: quarter,
            amount: 0,
            year: widget.yearlyRevenue.year,
          ),
    );

    // Use the current data getters
    final totalBookings = state.currentTotalBookings;
    final monthlyData = state.currentMonthlyData;
    final categories = state.currentCategories;
    final isCurrentQuarterLoaded = state.isCurrentQuarterLoaded;

    // Show loading skeleton
    if (state.isLoading && !isCurrentQuarterLoaded) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Gap(Spacing.md),
            ShopSchimmerSkeleton(height: 100.h),
            Gap(Spacing.md),
            Gap(Spacing.sm),
            ShopSchimmerSkeleton(height: 400.h),
            Gap(Spacing.md),
            Gap(Spacing.sm),
            ShopSchimmerSkeleton(height: 350.h),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(Spacing.md.h),
          DetailedQuarterlySummaryCard(
            quarter: quarter,
            quarterData: quarterData,
            totalBookings: totalBookings,
          ),
          Gap(Spacing.md.h),
          Text(
            'Monthly revenue graph',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onBackground,
            ),
          ),
          Gap(Spacing.sm.h),
          DetailedQuarterlyMonthlyRevenueChart(
            data: monthlyData,
            isLoading: false,
          ),
          Gap(Spacing.lg.h),
          Text(
            'Top Services',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onBackground,
            ),
          ),
          Gap(Spacing.sm.h),
          CategoryBreakdownList(categories: categories, isLoading: false),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Build tabs with their respective content
    final tabs = [
      AppTabItem(label: 'Q1', content: _buildQuarterContent(1)),
      AppTabItem(label: 'Q2', content: _buildQuarterContent(2)),
      AppTabItem(label: 'Q3', content: _buildQuarterContent(3)),
      AppTabItem(label: 'Q4', content: _buildQuarterContent(4)),
    ];

    return Scaffold(
      backgroundColor: colorScheme.background,

      body: TabsWithContent(
        headertext: 'Quarterly breakdown',
        tabs: tabs,
        initialIndex: 0,
        scrollable: false,
        showContent: true,

        enableSwipe: true,
        useNestedScrollMode: true,

        onTabChanged: (index) {
          final quarter = index + 1;
          final controller = ref.read(
            quarterlyRevenueControllerProviderFamily(_params).notifier,
          );
          if (controller.state.selectedQuarter != quarter &&
              !controller.state.isLoading) {
            controller.setQuarter(quarter);
          }
        },
      ),
    );
  }
}
