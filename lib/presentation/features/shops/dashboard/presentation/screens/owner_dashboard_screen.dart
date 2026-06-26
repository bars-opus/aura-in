// lib/features/dashboard/presentation/screens/owner_dashboard_screen.dart
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/analytics_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/clients_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/insights_screen.dart';
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
    final dashboardDocs = DashboardDocs();
    final shopsAsync = ref.watch(userShopsProvider);

    final List<AppTabItem> tabs = [
      AppTabItem(
        label: loc.dashboardTabRevenue,
        content: WalletScreen(
          shopId: widget.shopId,
          shopOwnerId: widget.shopOwnerId,
          shopName: widget.shopName,
          shopCurrencyCode: widget.shopCurrencyCode,
          shopCountry: widget.shopCountry,
        ),
      ),
      AppTabItem(
        label: loc.dashboardTabAnalytics,
        content: AnalyticsScreen(shopId: widget.shopId),
      ),
      AppTabItem(
        label: loc.dashboardTabInsights,
        content: InsightsScreen(shopId: widget.shopId),
      ),
      AppTabItem(label: loc.dashboardTabTools, content: ToolsScreen(shopId: widget.shopId)),
      AppTabItem(
        label: loc.dashboardTabClients,
        content: ClientsScreen(shopId: widget.shopId),
      ),
    ];

    // Only add Staff tab for shops (not freelancers)
    if (!widget.isFreelancer) {
      tabs.add(
        AppTabItem(
          label: loc.dashboardTabStaff,
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
            data: (shops) => Padding(
              padding: EdgeInsets.only(right: Spacing.md.w),
              child: OwnerTabShopSwitcher(shops: shops),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              Spacing.md.w,
              Spacing.sm.h,
              Spacing.md.w,
              0,
            ),
            child: GestureDetector(
              onTap: () {
                BottomSheetUtils.showDocumentationBottomSheet(
                  context: context,
                  showButtons: false,
                  widget: DocumentationTabView(
                    documentation: dashboardDocs.getSections(context),
                    faqs: dashboardDocs.getFAQs(context),
                    showDocumentationFirst: true,
                  ),
                );
              },
              child: SemanticContainerWidget(
                title: dashboardDocs.getTitle(context),
                content:
                    'Track revenue, review analytics, manage tools, and keep clients and staff in sync from one place.',
                icon: dashboardDocs.icon,
                trailingIcon: Icons.arrow_forward_ios_sharp,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
                borderColor: colorScheme.primary,
                iconColor: colorScheme.primary,
                textTheme: theme.textTheme,
              ),
            ),
          ),
          Expanded(
            child: TabsWithContent(
              useNestedScrollMode: false,
              tabs: tabs,
              initialIndex: 0,
              scrollable: true,
              showContent: true,
            ),
          ),
        ],
      ),
    );
  }
}
