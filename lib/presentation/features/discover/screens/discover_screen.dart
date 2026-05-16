// lib/presentation/features/discover/screens/discover_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/utils/location/widgets/location_display_widget.dart';
import 'package:nano_embryo/core/widgets/card_inkwell.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/cart_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/widgets/freelancer_grid_sliver.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/widgets/near_you_freelancers_horizontal.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/widgets/top_rated_freelancers_horizontal.dart';
import 'package:nano_embryo/presentation/features/search/presentation/widgets/dummy_search_container.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/luxury_level_chips.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/near_you_shops_horizontal.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/premium_shops_horizontal.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/provider_type_tabs.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/service_category_tabs.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/shop_list_sliver.dart';
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
    // Single watch per provider — each used once below.
    final selectedType = ref.watch(selectedProviderTypeProvider);
    final serviceCategory = ref.watch(selectedServiceCategoryProvider);

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.md.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(Spacing.sm.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Discover',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onBackground,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const LocationDisplayWidget(),
                            _CartIconButton(),
                          ],
                        ),
                      ],
                    ),
                    Gap(Spacing.md.h),
                    AnimatedScaleFade(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                      child: DummySearchContainer(
                        hintText: 'Search...',
                        onTap: () => context.push('/search'),
                        elevation: 0,
                        showBorder: true,
                      ),
                    ),
                    Gap(Spacing.sm.h),
                  ],
                ),
              ),
            ),
          ),

          // ── Filter tabs ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: CardInkWell(
              onTap: () {},
              margin: EdgeInsets.only(bottom: Spacing.sm.h),
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  Gap(Spacing.md.h),
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
                  Gap(Spacing.md.h),
                ],
              ),
            ),
          ),

          // ── Curated horizontal sections ──────────────────────────────────
          if (selectedType == ProviderType.shops) ...[
            const SliverToBoxAdapter(child: PremiumShopsHorizontal()),
            const SliverToBoxAdapter(child: TopRatedShopsHorizontal()),
            const SliverToBoxAdapter(child: NearYouShopsHorizontal()),
            SliverToBoxAdapter(child: Gap(Spacing.md.h)),
          ] else if (selectedType == ProviderType.freelancers) ...[
            const SliverToBoxAdapter(child: TopRatedFreelancersHorizontal()),
            const SliverToBoxAdapter(child: NearYouFreelancersHorizontal()),
            SliverToBoxAdapter(child: Gap(Spacing.md.h)),
          ],

          // ── Section header ───────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
            sliver: SliverToBoxAdapter(
              child: Text(
                selectedType == ProviderType.shops
                    ? 'All shops in your region'
                    : selectedType == ProviderType.freelancers
                    ? 'All freelancers near you'
                    : 'Marketplace',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: Gap(Spacing.sm.h)),

          // ── Main content list ────────────────────────────────────────────
          if (selectedType == ProviderType.shops)
            const SliverPadding(
              padding: EdgeInsets.zero,
              sliver: ShopListSliver(),
            )
          else if (selectedType == ProviderType.freelancers)
            const FreelancerGridSliver()
          else
            SliverFillRemaining(child: _buildMarketplaceCTA(context)),
        ],
      ),
    );
  }

  Widget _buildMarketplaceCTA(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Spacing.lg.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80.sp,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
            Gap(Spacing.md.h),
            Text(
              'Marketplace',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Gap(Spacing.sm.h),
            Text(
              'Shop beauty products with cash on delivery',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            Gap(Spacing.lg.h),
            FilledButton.icon(
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Browse products'),
              onPressed: () => context.pushNamed('marketplace'),
            ),
            Gap(Spacing.sm.h),
            TextButton.icon(
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('My orders'),
              onPressed: () => context.pushNamed('customerOrders'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}

class _CartIconButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemCount = ref.watch(cartNotifierProvider).itemCount;
    final icon = IconButton(
      icon: const Icon(Icons.shopping_cart_outlined),
      tooltip: 'Cart',
      onPressed: () => context.pushNamed('cart'),
    );
    if (itemCount == 0) return icon;
    return Badge(
      label: Text('$itemCount'),
      offset: const Offset(-4, 4),
      child: icon,
    );
  }
}
