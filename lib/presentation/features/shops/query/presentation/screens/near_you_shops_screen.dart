import 'package:nano_embryo/presentation/features/shops/query/providers/search_radius_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class NearYouShopsScreen extends ConsumerStatefulWidget {
  const NearYouShopsScreen({super.key});

  @override
  ConsumerState<NearYouShopsScreen> createState() => _NearYouShopsScreenState();
}

class _NearYouShopsScreenState extends ConsumerState<NearYouShopsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(nearYouShopsListProvider.notifier).loadFirstPage();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(nearYouShopsListProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(nearYouShopsListProvider);
    // Access theme for consistent styling
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Access localization for language prefence
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Shops near you',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        actions: [
          AppIconButton(
            icon: Icons.filter_list,
            onPressed: () {
              // Initialize temp values from current state

              // Get current state from provider

              // Get the luxury level from Discover page (via provider)
              final discoverLuxuryLevel = ref.read(selectedLuxuryLevelProvider);

              BottomSheetUtils.showDocumentationBottomSheet(
                maxHeight: 650.h,
                context: context,
                widget: ShopFilterBottomSheet(
                  selectedCategory: ref.read(selectedServiceCategoryProvider),
                  initialLuxuryLevel: discoverLuxuryLevel,
                  initialVerifiedOnly: false,
                  initialSortByRating: true,
                  initialRadiusKm: ref.read(searchRadiusKmProvider),
                  onReset: () {},
                  onApply: (luxuryLevel, verifiedOnly, sortByRating, radiusKm) {
                    ref
                        .read(nearYouShopsListProvider.notifier)
                        .applyFilters(
                          luxuryLevel: luxuryLevel,
                          verifiedOnly: verifiedOnly,
                          sortBy: sortByRating ? 'rating' : 'name',
                          radiusKm: radiusKm,
                        );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: stateAsync.when(
        data: (state) {
          // 👈 Show loading indicator at bottom if loading more
          if (state.shops.isEmpty && state.isLoading) {
            return const ShopListviewLoadingShimmer();
          }

          if (state.shops.isEmpty && !state.isLoading) {
            return EmptyStateWidget(
              type: EmptyStateType.noShops,
              compact: true,
              subtitle: 'No shops found nearby',
              onAction:
                  () => ref.read(nearYouShopsListProvider.notifier).refresh(),
            );
          }

          return RefreshIndicator(
            onRefresh:
                () => ref.read(nearYouShopsListProvider.notifier).refresh(),
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(Spacing.sm.h),
              itemCount: state.shops.length + (state.hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index >= state.shops.length) {
                  // 👈 Show loading indicator only if not reached max and not loading
                  if (!state.hasReachedMax && state.isLoading) {
                    return ShopSchimmerSkeleton(height: 400.h);
                  }
                  return const SizedBox.shrink(); // Nothing to show
                }
                final shop = state.shops[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: Spacing.sm.h),
                  child: SizedBox(
                    height: 400.h,
                    child: ShopCard(
                      showIcon: true,
                      shopName: shop.shopName,
                      luxuryLevel: shop.luxuryLevel ?? '',
                      averageRating: shop.averageRating ?? 0,
                      distanceKm: shop.distanceKm ?? 0,
                      numberClientsWorked: shop.numberClientsWorked ?? 0,
                      shopId: shop.id,
                      coverImageUrl: shop.coverImageUrl,
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const ShopListviewLoadingShimmer(),
        error:
            (error, stack) => Center(
              child: ErrorStateWidget(
                title: 'Something went wrong',
                compact: true,
                subtitle: error.toString(),
                type: ErrorStateType.genericError,
                onPrimaryAction:
                    () => ref.read(nearYouShopsListProvider.notifier).refresh(),
              ),
            ),
      ),
    );
  }
}
