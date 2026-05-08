import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/tools/kpi_card.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/presentation/screens/wallet_screen.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/presentation/widgets/wallet_balance_card.dart';

class TodaysView extends ConsumerWidget {
  final String shopId;
  const TodaysView({super.key, required this.shopId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      ownerDashboardControllerProviderFamily(
        OwnerDashboardParams(shopId: shopId),
      ),
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Loading state
    if (state.isLoading) {
      return Center(child: CircularLoadingIndicator());
    }

    // Error state
    if (state.hasError) {
      return Center(
        child: ErrorStateWidget(
          subtitle: 'Failed to load dashboard for today',
          onPrimaryAction: () => _refreshDashboard(ref), // ✅ Pass ref
        ),
      );
    }

    // Empty state
    if (state.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          subtitle:
              'No Data Available\nNo bookings or metrics available for today.',
        ),
      );
    }

    // Prepare KPI data
    final kpiDataList = [
      _KpiData(
        title: 'Today\'s Revenue',
        value: '\$${state.metrics.todayRevenue.toStringAsFixed(0)}',
        icon: Icons.money,
        iconColor: colorScheme.success,
        trendPercent: state.metrics.revenueChangePercent,
        trendUpIsPositive: true,
      ),
      _KpiData(
        title: 'Bookings',
        value: state.metrics.todayBookings.toString(),
        icon: Icons.calendar_month,
        iconColor: colorScheme.primary,
      ),
      _KpiData(
        title: 'Occupancy',
        value: '${(state.metrics.occupancyRate * 100).toStringAsFixed(0)}%',
        icon: Icons.space_dashboard,
        iconColor: colorScheme.info,
      ),
      _KpiData(
        title: 'Cancellations',
        value: '${(state.metrics.cancellationRate * 100).toStringAsFixed(0)}%',
        icon: Icons.cancel_outlined,
        iconColor: colorScheme.error,
      ),
    ];

    // Data state
    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(
              ownerDashboardControllerProviderFamily(
                OwnerDashboardParams(shopId: shopId),
              ).notifier,
            )
            .refresh();
      },
      child: _buildKPISection(theme, colorScheme, kpiDataList),
    );
  }

  // ✅ Add refresh method with ref parameter
  Future<void> _refreshDashboard(WidgetRef ref) async {
    await ref
        .read(
          ownerDashboardControllerProviderFamily(
            OwnerDashboardParams(shopId: shopId),
          ).notifier,
        )
        .refresh();
  }

  Widget _buildKPISection(
    ThemeData theme,
    ColorScheme colorScheme,
    List<_KpiData> kpiDataList,
  ) {
    return CardInkWell(
      onTap: () {},
      margin: EdgeInsets.only(bottom: Spacing.md.h),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Today\'s revenue',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Gap(Spacing.xs.h),
          SizedBox(
            height: kpiDataList.length * 65.h,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
              itemCount: kpiDataList.length,
              itemBuilder: (context, index) {
                final data = kpiDataList[index];
                return KpiCard(
                  title: data.title,
                  value: data.value,
                  icon: data.icon,
                  iconColor: data.iconColor,
                  trendPercent: data.trendPercent,
                  trendUpIsPositive: data.trendUpIsPositive,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  

}

// Helper data class
class _KpiData {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final double? trendPercent;
  final bool trendUpIsPositive;

  _KpiData({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.trendPercent,
    this.trendUpIsPositive = false,
  });
}
