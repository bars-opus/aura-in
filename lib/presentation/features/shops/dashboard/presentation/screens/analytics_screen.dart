// lib/features/dashboard/presentation/screens/analytics_screen.dart
import 'package:nano_embryo/core/widgets/custom_universal_tabs.dart';
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/top_service.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/analytics_controller.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/analytics_loading_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_headline_card.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/quarterly_revenue_chart.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/quarterly_revenue_detail_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/revenue_comparison_card.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/top_services_list.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/top_workers_list.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  final String shopId;
  final String shopCurrencyCode;

  const AnalyticsScreen({
    super.key,
    required this.shopId,
    required this.shopCurrencyCode,
  });

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  AnalyticsTab _selectedTab = AnalyticsTab.revenue;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      analyticsControllerProviderFamily(AnalyticsParams(shopId: widget.shopId)),
    );
    return _buildContent(state);
  }

  Widget _buildContent(AnalyticsState state) {
    final loc = AppLocalizations.of(context)!;

    if (state.isLoading) {
      return const AnalyticsLoadingScreen();
    }

    if (state.hasError) {
      return Center(
        child: ErrorStateWidget(
          subtitle: loc.analyticsLoadError,
          title: '',
          onPrimaryAction:
              () =>
                  ref
                      .read(
                        analyticsControllerProviderFamily(
                          AnalyticsParams(shopId: widget.shopId),
                        ).notifier,
                      )
                      .refresh(),
        ),
      );
    }

    if (state.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.analytics_outlined,
          title: loc.analyticsEmpty,
          subtitle: loc.analyticsEmptySubtitle,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(
              analyticsControllerProviderFamily(
                AnalyticsParams(shopId: widget.shopId),
              ).notifier,
            )
            .refresh();
      },
      // ListView is already scrollable — Expanded + SingleChildScrollView
      // inside it was invalid (Expanded requires Flex; nested scrollables
      // blank in release while debug let it slide via different layout
      // assertion paths).
      child: ListView(
        children: [
          CustomUniversalTabs(
            tabs: _buildAnalyticsTabs(context),
            selectedIndex: _selectedTab.index,
            onIndexChanged: (index) {
              setState(() {
                _selectedTab = AnalyticsTab.values[index];
              });
            },
            height: 70.h,
            iconSize: 20.sp,
            fontSize: 12.sp,
            showUnderline: true,
            showLabels: true,
            animateIconScale: true,
            showBottomBorder: false,
          ),
          Padding(
            padding: EdgeInsets.all(Spacing.sm.h),
            child: _buildTabContent(state),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(AnalyticsState state) {
    switch (_selectedTab) {
      case AnalyticsTab.revenue:
        return Column(
          children: [
            Gap(Spacing.sm.h),
            if (state.revenueComparisons != null) ...[
              RevenueComparisonCard(
                shopId: widget.shopId,
                shopCurrencyCode: widget.shopCurrencyCode,
                weeklyRevenue:
                    state.revenueComparisons!['weekly_revenue']?.toDouble() ??
                    0,
                previousWeeklyRevenue:
                    state.revenueComparisons!['previous_weekly_revenue']
                        ?.toDouble() ??
                    0,
                monthlyRevenue:
                    state.revenueComparisons!['monthly_revenue']?.toDouble() ??
                    0,
                previousMonthlyRevenue:
                    state.revenueComparisons!['previous_monthly_revenue']
                        ?.toDouble() ??
                    0,
              ),
            ],
            LostBookingHeadlineCard(
              shopId: widget.shopId,
              shopCurrencyCode: widget.shopCurrencyCode,
            ),
            QuarterlyRevenueChart(
              data: state.quarterlyRevenue,
              shopCurrencyCode: widget.shopCurrencyCode,
              maxRevenue: _getMaxRevenue(state),
              onTap: () {
                BottomSheetUtils.showDocumentationBottomSheet(
                  context: context,
                  widget: QuarterlyRevenueDetailScreen(
                    shopId: widget.shopId,
                    shopCurrencyCode: widget.shopCurrencyCode,
                    yearlyRevenue: state.quarterlyRevenue,
                  ),
                );
              },
            ),
            Gap(Spacing.xxl.h * 2),
          ],
        );

      case AnalyticsTab.services:
        return Column(
          children: [
            Gap(Spacing.md.h),
            if (state.weeklyServices.services.isNotEmpty)
              TopServicesList(
                data: state.weeklyServices,
                shopId: widget.shopId,
                shopCurrencyCode: widget.shopCurrencyCode,
                peroid: AnalyticsPeriod.weekly,
              ),
            if (state.weeklyServices.services.isNotEmpty &&
                state.monthlyServices.services.isNotEmpty)
              Gap(Spacing.md.h),
            if (state.monthlyServices.services.isNotEmpty)
              TopServicesList(
                data: state.monthlyServices,
                shopId: widget.shopId,
                shopCurrencyCode: widget.shopCurrencyCode,
                peroid: AnalyticsPeriod.monthly,
              ),
          ],
        );

      case AnalyticsTab.workers:
        return Column(
          children: [
            Gap(Spacing.md.h),
            if (state.weeklyWorkers.workers.isNotEmpty)
              TopWorkersList(
                data: state.weeklyWorkers,
                shopCurrencyCode: widget.shopCurrencyCode,
              ),
            if (state.weeklyWorkers.workers.isNotEmpty &&
                state.monthlyWorkers.workers.isNotEmpty)
              Gap(Spacing.md.h),
            if (state.monthlyWorkers.workers.isNotEmpty)
              TopWorkersList(
                data: state.monthlyWorkers,
                shopCurrencyCode: widget.shopCurrencyCode,
              ),
          ],
        );
    }
  }

  double _getMaxRevenue(AnalyticsState state) {
    final quarters = state.quarterlyRevenue.quarters;
    if (quarters.isEmpty) return 10000;
    final max = quarters.map((q) => q.amount).reduce((a, b) => a > b ? a : b);
    return max * 1.2;
  }

  List<TabItem> _buildAnalyticsTabs(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      TabItem(
        label: loc.analyticsRevenue,
        icon: Icons.attach_money_outlined,
        selectedIcon: Icons.attach_money,
        value: AnalyticsTab.revenue,
      ),
      TabItem(
        label: loc.analyticsServices,
        icon: Icons.cut_outlined,
        selectedIcon: Icons.cut,
        value: AnalyticsTab.services,
      ),
      TabItem(
        label: loc.analyticsWorkers,
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        value: AnalyticsTab.workers,
      ),
    ];
  }
}

// AnalyticsTab enum if not already defined
enum AnalyticsTab { revenue, services, workers }

extension AnalyticsTabExtension on AnalyticsTab {
  String get label {
    switch (this) {
      case AnalyticsTab.revenue:
        return 'Revenue';
      case AnalyticsTab.services:
        return 'Services';
      case AnalyticsTab.workers:
        return 'Workers';
    }
  }
}
