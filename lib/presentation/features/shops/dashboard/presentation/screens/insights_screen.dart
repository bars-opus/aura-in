// lib/features/dashboard/presentation/screens/insights_screen.dart
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/alerts_controller.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/heatmap_controller.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/alerts_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/insight/heatmap_insights.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/tools/alert_card.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/insight/booking_heatmap.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  final String shopId;

  const InsightsScreen({super.key, required this.shopId});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  @override
  Widget build(BuildContext context) {
    final alertsState = ref.watch(
      alertsControllerProviderFamily(AlertsParams(shopId: widget.shopId)),
    );
    final heatmapState = ref.watch(
      heatmapControllerProviderFamily(HeatmapParams(shopId: widget.shopId)),
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref
              .read(
                alertsControllerProviderFamily(
                  AlertsParams(shopId: widget.shopId),
                ).notifier,
              )
              .refresh();
          ref
              .read(
                heatmapControllerProviderFamily(
                  HeatmapParams(shopId: widget.shopId),
                ).notifier,
              )
              .refresh();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: Spacing.md.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(Spacing.md.h),
              _buildHeatmapSection(heatmapState),
              Gap(Spacing.lg.h),
              _buildAlertsSection(alertsState),
              Gap(Spacing.xxl.h * 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsSection(AlertsState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.insightsReports,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AlertsScreen(shopId: widget.shopId),
                    ),
                  ),
              child: Text(loc.insightsSeeAll),
            ),
          ],
        ),
        Gap(Spacing.sm.h),
        if (state.isLoading)
          SizedBox(
            height: 600.h,
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 3,
              separatorBuilder: (_, __) => Gap(Spacing.md.w),
              itemBuilder: (_, __) => ShopSchimmerSkeleton(height: 100.h),
            ),
          )
        else if (state.hasError)
          Center(child: ErrorStateWidget(subtitle: loc.insightsLoadError))
        else if (state.alerts.isEmpty)
          CardInkWell(
            elevation: 0,
            onTap: () {},
            child: Center(
              child: EmptyStateWidget(
                subtitle: loc.insightsNoAlerts,
                icon: Icons.check_circle_outline,
              ),
            ),
          )
        else
          Column(
            children:
                state.alerts
                    .take(3)
                    .map((alert) => AlertCard(alert: alert, onTap: () {}))
                    .toList(),
          ),
      ],
    );
  }

  Widget _buildHeatmapSection(HeatmapState state) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.isLoading)
          Column(
            children: [
              ShopSchimmerSkeleton(height: 350.h),
              ShopSchimmerSkeleton(height: 400.h),
            ],
          )
        else if (state.hasError)
          CardInkWell(
            onTap: () {},
            child: ErrorStateWidget(subtitle: loc.insightsHeatmapError),
          )
        else if (state.heatmapData == null ||
            state.heatmapData!.dataPoints.isEmpty)
          CardInkWell(
            elevation: 0,
            padding: const EdgeInsets.all(0),
            onTap: () {},
            child: SizedBox(
              height: 400.h,
              child: Center(
                child: EmptyStateWidget(
                  subtitle: loc.insightsNoHeatmapData,
                  icon: Icons.show_chart_outlined,
                ),
              ),
            ),
          )
        else
          BookingHeatmap(data: state.heatmapData!),
      ],
    );
  }
}
