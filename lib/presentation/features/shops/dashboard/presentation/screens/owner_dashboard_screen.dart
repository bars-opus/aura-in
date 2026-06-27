// lib/features/dashboard/presentation/screens/owner_dashboard_screen.dart
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/analytics_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/clients_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/insights_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/link_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/dashboard_workers_screen.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';
import 'package:nano_embryo/presentation/home/widgets/owner_tab_shop_switcher.dart';
import 'package:nano_embryo/wallet/presentation/screens/wallet_screen.dart';

class OwnerDashboardScreen extends ConsumerStatefulWidget {
  final String shopId;
  final String accountType;
  // final String? subaccountId;
  final String shopName;
  final String shopOwnerId;
  final bool isFreelancer;
  final String shopCountry;
  final String shopCurrencyCode;

  const OwnerDashboardScreen({
    super.key,
    required this.shopId,
    required this.shopOwnerId,
    required this.accountType,
    required this.shopName,
    // required this.subaccountId,
    required this.shopCurrencyCode,
    required this.shopCountry,
    required this.isFreelancer,
  });

  @override
  ConsumerState<OwnerDashboardScreen> createState() =>
      _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    final shopsAsync = ref.watch(userShopsProvider);
    final selectedShop = ref.watch(currentShopProvider);
    final activeShopId = selectedShop?.id ?? widget.shopId;
    final activeShopName = selectedShop?.shopName ?? widget.shopName;
    final activeShopOwnerId = selectedShop?.userId ?? widget.shopOwnerId;
    final activeShopCountry = selectedShop?.country ?? widget.shopCountry;
    final activeShopCurrency =
        selectedShop?.currency ?? widget.shopCurrencyCode;

    final List<AppTabItem> tabs = [
      AppTabItem(
        label: loc.dashboardTabRevenue,
        content: WalletScreen(
          shopId: activeShopId,
          shopOwnerId: activeShopOwnerId,
          shopName: activeShopName,
          shopCurrencyCode: activeShopCurrency,
          shopCountry: activeShopCountry,
        ),
      ),
      AppTabItem(
        label: loc.dashboardTabAnalytics,
        content: AnalyticsScreen(
          shopId: activeShopId,
          shopCurrencyCode: activeShopCurrency,
        ),
      ),
      AppTabItem(
        label: loc.dashboardTabInsights,
        content: InsightsScreen(shopId: activeShopId),
      ),
      AppTabItem(
        label: loc.dashboardTabTools,
        content: ToolsScreen(shopId: activeShopId),
      ),
      AppTabItem(label: 'Links', content: LinkScreen(shopId: activeShopId)),

      AppTabItem(
        label: loc.dashboardTabClients,
        content: ClientsScreen(shopId: activeShopId),
      ),
    ];

    // Only add Staff tab for shops (not freelancers)
    if (!widget.isFreelancer) {
      tabs.add(
        AppTabItem(
          label: loc.dashboardTabStaff,
          content: DashboardWorkersScreen(shopId: activeShopId),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          loc.dashboardTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          shopsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data:
                (shops) => Padding(
                  padding: EdgeInsets.only(right: Spacing.md.w),
                  child: OwnerTabShopSwitcher(shops: shops),
                ),
          ),
        ],
      ),
      body: TabsWithContent(
        useNestedScrollMode: false,
        tabs: tabs,
        initialIndex: 0,
        scrollable: true,
        showContent: true,
      ),
    );
  }
}
