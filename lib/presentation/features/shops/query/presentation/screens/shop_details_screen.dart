// lib/features/shops/presentation/screens/shop_details_screen.dart
import 'dart:io';
import 'package:nano_embryo/presentation/features/profile/widgets/tab_bar_delegate.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/screens/client/service_selection_screen.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/screens/shop_details_content.dart';
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
                    content: Padding(
                      padding: const EdgeInsets.all(Spacing.md),
                      child: MediaQuery.removePadding(
                        removeTop: true,
                        context: context,
                        child: ServiceSelectionScreen(shopId: widget.shopId, shopCurrency: shopDetails.currency??'',),
                      ),
                    ),
                  ),
                  AppTabItem(label: 'Buy', icon: null, content: Container()),
                  AppTabItem(label: 'Works', icon: null, content: Container()),
                ];
              });
            }
          });
        }
        return ShopDetailsContent(
          shop: shopDetails,
          tabController: _tabController,
          tabs: _tabs,
        );
      },
      loading: () => _loadingSchimmer(context, widget.coverImageUrl),
      error: (error, _) => _buildErrorWidget(error),
    );
  }

  Widget _loadingSchimmer(BuildContext context, String coverImageUrl) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 450.h,
                  width: double.infinity,
                  child: ShopImagePageview(shopImageUrls: [coverImageUrl]),
                ),
                Positioned(
                  top: 50.h,
                  left: 10.h,
                  child: AppIconButton(
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: colorScheme.background.withOpacity(.6),
                    icon: Icons.close,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.md),
              child: Column(
                children: [
                  Gap(20.h),
                  CompactProfileSchimmer(),
                  Gap(20.h),
                  ShopSchimmerSkeleton(height: 20.h),
                  Gap(5.h),
                  ShopSchimmerSkeleton(height: 20.h),
                  Gap(5.h),
                  ShopSchimmerSkeleton(height: 20.h),
                  Gap(20.h),
                  ShopSchimmerSkeleton(),
                ],
              ),
            ),
          ],
        ),
      ),
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
