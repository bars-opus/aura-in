// lib/features/shops/presentation/screens/shop_details_screen.dart
import 'package:nano_embryo/presentation/features/profile/widgets/profile_buys_tab.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/screens/client/service_selection_screen.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/screens/shop_details_content.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_loading_schimmer.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class ShopDetailsScreen extends ConsumerStatefulWidget {
  final String shopId;
  final String coverImageUrl;

  const ShopDetailsScreen({
    super.key,
    required this.shopId,
    required this.coverImageUrl,
  });

  @override
  ConsumerState<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends ConsumerState<ShopDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<AppTabItem> _tabs;
  bool _tabsInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabs = _getInitialTabs();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  List<AppTabItem> _getInitialTabs() {
    return [
      AppTabItem(label: 'Info', icon: null, content: const SizedBox()),
      AppTabItem(label: 'Services', icon: null, content: const SizedBox()),
      AppTabItem(label: 'Buy', icon: null, content: const SizedBox()),
      AppTabItem(label: 'Works', icon: null, content: const SizedBox()),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shopAsync = ref.watch(shopDetailsProvider(shopId: widget.shopId));
    final colorScheme = Theme.of(context).colorScheme;

    print(widget.shopId);
    return shopAsync.when(
      data: (shopDetails) {
        // Update tabs with real content after data loads (only once).
        // Use a boolean flag instead of `is SizedBox` — type checks on
        // const widgets are unreliable under AOT tree-shaking in release mode.
        if (!_tabsInitialized) {
          _tabsInitialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _tabs = [
                  AppTabItem(
                    label: 'Info',
                    icon: null,
                    content: ShopDetailsInfoSection(shop: shopDetails),
                  ),
                  AppTabItem(
                    label: 'Services',
                    icon: null,
                    content: Material(
                      color: colorScheme.background,
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.md),
                        child: MediaQuery.removePadding(
                          removeTop: true,
                          context: context,
                          child: ServiceSelectionScreen(
                            shopId: widget.shopId,
                            shopCurrency: shopDetails.currency ?? '',
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppTabItem(
                    label: 'Buy',
                    icon: null,
                    content: Material(
                      color: colorScheme.background,
                      child: ProfileBuysTab(
                        profileUserId: widget.shopId,
                        isCurrentUser: false,
                      ),
                    ),
                  ),
                  AppTabItem(
                    label: 'Works',
                    icon: null,
                    content: Material(
                      color: colorScheme.background,
                      child: Container(),
                    ),
                  ),
                ];
              });
            }
          });
        }
        return ShopDetailsContent(
          coverImageUrl: widget.coverImageUrl,
          shop: shopDetails,
          tabController: _tabController,
          tabs: _tabs,
        );
      },
      loading:
          () => ShopDetailsLoadingSchimmer(coverImageUrl: widget.coverImageUrl),
      error: (error, _) => _buildErrorWidget(error),
    );
  }

  Widget _buildErrorWidget(Object error) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: ErrorStateWidget(
          title: '',
          subtitle: 'Failed to load shop details',
          onPrimaryAction:
              () => ref.invalidate(shopDetailsProvider(shopId: widget.shopId)),
        ),
      ),
    );
  }
}
