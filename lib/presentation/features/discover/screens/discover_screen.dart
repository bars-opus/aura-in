// lib/presentation/features/discover/screens/discover_screen.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/utils/location/widgets/location_display_widget.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/cart_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/widgets/freelancer_grid_sliver.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/widgets/freelancer_tag_chips.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/widgets/near_you_freelancers_horizontal.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/widgets/top_rated_freelancers_horizontal.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/marketplace_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/marketplace_screen.dart'
    show FilterBottomSheet;
import 'package:nano_embryo/presentation/features/products/presentation/widgets/filter_chip_row.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/marketplace_grid_sliver.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/near_you_products_horizontal.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/top_rated_products_horizontal.dart';
import 'package:nano_embryo/presentation/features/search/presentation/widgets/dummy_search_container.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/luxury_level_chips.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/near_you_shops_horizontal.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/search_radius_slider.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/premium_shops_horizontal.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/provider_type_tabs.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/service_category_tabs.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/shop_list_sliver.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/shop_no_location_set.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/top_rated_shops_horizontal.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/provider_type_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/selected_luxury_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/service_category_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_list_provider.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Trigger loadNextPage when the user scrolls within 200 px of the end.
    // The CustomScrollView's controller lives here, so this is the only place
    // that can observe the scroll position for the whole page.
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    final selectedType = ref.read(selectedProviderTypeProvider);
    if (selectedType == ProviderType.shops) {
      ref.read(shopListProvider.notifier).loadNextPage();
    }
    // Freelancer pagination can be wired up here in the same pattern.
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    // Single watch per provider — each used once below.
    final selectedType = ref.watch(selectedProviderTypeProvider);
    final serviceCategory = ref.watch(selectedServiceCategoryProvider);
    final hasLocation = ref.watch(hasLocationProvider);

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      extendBodyBehindAppBar: true,

      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(Spacing.xl.h),
                  Gap(Spacing.xl.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.discoverScreenTitle,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Gap(Spacing.lg.w),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Flexible(child: LocationDisplayWidget()),
                            _CartIconButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!hasLocation) Gap(Spacing.sm.h),
                  if (!hasLocation) ShopNoLocationSet(),
                  Gap(Spacing.sm.h),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: CardInkWell(
              elevation: ElevationTokens.xs,
              borderRadius: BorderRadiusTokens.xlAll,
              margin: const EdgeInsets.all(0),
              padding: const EdgeInsets.all(0),

              child: Column(
                children: [
                  Gap(Spacing.sm.h),
                  Padding(
                    padding: EdgeInsets.all(Spacing.md.h),
                    child: AnimatedScaleFade(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                      child: DummySearchContainer(
                        hintText: loc.discoverSearchHint,
                        onTap: () => context.push('/search'),
                        elevation: ElevationTokens.xs,
                        showBorder: true,
                      ),
                    ),
                  ),

                  const ServiceCategoryTabs(),
                  const ProviderTypeTabs(),
                  Gap(Spacing.md.h),
                  if (selectedType == ProviderType.shops)
                    LuxuryLevelChips(
                      selectedCategory: serviceCategory,
                      selectedLuxuryLevel: ref.watch(
                        selectedLuxuryLevelProvider,
                      ),
                      // shopListProvider watches selectedLuxuryLevelProvider
                      // and auto-reloads — no manual loadFirstPage() needed.
                      onLuxurySelected: (level) {
                        ref
                            .read(selectedLuxuryLevelProvider.notifier)
                            .selectLuxury(level);
                      },
                    ),
                  // Buy tab: product category filter, same slot as shops'
                  // LuxuryLevelChips. marketplaceProductsPagedProvider watches
                  // marketplaceFilterProvider and auto-reloads on category change.
                  if (selectedType == ProviderType.buy)
                    FilterChipRow(
                      selectedCategory:
                          ref.watch(marketplaceFilterProvider).category,
                      onCategorySelected: (category) => ref
                          .read(marketplaceFilterProvider.notifier)
                          .setCategory(category),
                      onFilterPressed: () => _showMarketplaceFilterSheet(ref),
                    ),
                  // Radius slider: shows for shops and freelancers (both have
                  // proximity-based queries). Buy/marketplace tab has no data
                  // fetch yet so hide it there.
                  if (selectedType != ProviderType.buy) ...[
                    Gap(Spacing.sm.h),
                    const SearchRadiusSlider(),
                  ],
                  Gap(Spacing.xl.h),
                ],
              ),
            ),
          ),
          SliverGap(Spacing.sm.h),

          if (selectedType == ProviderType.shops) ...[
            const SliverToBoxAdapter(child: PremiumShopsHorizontal()),
            const SliverToBoxAdapter(child: TopRatedShopsHorizontal()),
            const SliverToBoxAdapter(child: NearYouShopsHorizontal()),
            SliverGap(Spacing.md.h),
          ] else if (selectedType == ProviderType.freelancers) ...[
            const SliverToBoxAdapter(child: FreelancerTagChips()),
            SliverGap(Spacing.sm.h),
            const SliverToBoxAdapter(child: TopRatedFreelancersHorizontal()),
            const SliverToBoxAdapter(child: NearYouFreelancersHorizontal()),
            SliverGap(Spacing.md.h),
          ] else if (selectedType == ProviderType.buy) ...[
            const SliverToBoxAdapter(child: TopRatedProductsHorizontal()),
            const SliverToBoxAdapter(child: NearYouProductsHorizontal()),
            SliverGap(Spacing.md.h),
          ],

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
            sliver: SliverToBoxAdapter(
              child: Text(
                selectedType == ProviderType.shops
                    ? loc.discoverAllShopsRegion
                    : selectedType == ProviderType.freelancers
                    ? loc.discoverAllFreelancers
                    : loc.discoverMarketplaceTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverGap(Spacing.sm.h),

          if (selectedType == ProviderType.shops)
            const ShopListSliver()
          else if (selectedType == ProviderType.freelancers)
            const FreelancerGridSliver()
          else
            const MarketplaceGridSliver(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Buy-tab price/sort/verified filter sheet. Reuses the marketplace
  /// FilterBottomSheet and applies into marketplaceFilterProvider, mirroring
  /// how the standalone Marketplace route applies its filters.
  void _showMarketplaceFilterSheet(WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => FilterBottomSheet(
        onApply: (minPrice, maxPrice, sortBy, showVerifiedOnly) {
          final notifier = ref.read(marketplaceFilterProvider.notifier);
          notifier.setPriceRange(minPrice, maxPrice);
          notifier.setSortBy(sortBy);
          notifier.setShowVerifiedOnly(showVerifiedOnly);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _CartIconButton extends ConsumerWidget {
  const _CartIconButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemCount = ref.watch(cartNotifierProvider).itemCount;
    final loc = AppLocalizations.of(context)!;
    final icon = AppIconButton(
      icon: Icons.shopping_cart_outlined,
      tooltip: loc.discoverCartTooltip,
      iconSize: 20,
      onPressed:
          //  () => context.push('/intro'),
          () => context.pushNamed('cart'),
    );
    if (itemCount == 0) return icon;
    return Badge(
      label: Text('$itemCount'),
      offset: const Offset(-4, 4),
      child: icon,
    );
  }
}
