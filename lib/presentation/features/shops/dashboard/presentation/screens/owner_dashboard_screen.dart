// lib/features/dashboard/presentation/screens/owner_dashboard_screen.dart
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/dashboard_metrics.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/owner_dashboard_controller.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/analytics_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/clients_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/insights_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/todays_view.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/dashboard_workers_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/tools/kpi_card.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/today_schedule_list.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';
import 'package:nano_embryo/payment/presentation/widgets/payment_setup_banner.dart';
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

    final List<AppTabItem> tabs = [
      AppTabItem(
        label: 'Revenue',
        content: WalletScreen(
          shopId: widget.shopId,
          shopOwnerId: widget.shopOwnerId,
          shopName: widget.shopName,
          shopCurrencyCode: widget.shopCurrencyCode,
          shopCountry: widget.shopCountry,
        ),
      ),
      AppTabItem(
        label: 'Analytics',
        content: AnalyticsScreen(shopId: widget.shopId),
      ),
      AppTabItem(
        label: 'Insights',
        content: InsightsScreen(shopId: widget.shopId),
      ),
      AppTabItem(label: 'Tools', content: ToolsScreen(shopId: widget.shopId)),
      AppTabItem(
        label: 'Clients',
        content: ClientsScreen(shopId: widget.shopId),
      ),
    ];

    // Only add Staff tab for shops (not freelancers)
    if (!widget.isFreelancer) {
      tabs.add(
        AppTabItem(
          label: 'Staff',
          content: DashboardWorkersScreen(shopId: widget.shopId),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          'Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
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
