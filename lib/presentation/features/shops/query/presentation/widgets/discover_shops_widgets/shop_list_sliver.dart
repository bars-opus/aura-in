// lib/features/shops/presentation/widgets/shop_list_sliver.dart

import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

/// Paginated sliver list of shops for the Discover screen.
///
/// Deliberately a simple presenter — all loading logic lives in
/// ShopList (shop_list_provider.dart). The provider auto-reloads whenever
/// the selected category or luxury level changes, so this widget never needs
/// to trigger a load itself.
class ShopListSliver extends ConsumerWidget {
  const ShopListSliver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopsAsync = ref.watch(shopListProvider);

    return SliverPadding(
      padding: EdgeInsets.only(bottom: Spacing.md.h),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildItem(context, ref, shopsAsync, index),
          childCount: _childCount(shopsAsync),
        ),
      ),
    );
  }

  int _childCount(AsyncValue<ShopListState> async) {
    return async.when(
      data: (s) {
        if (s.shops.isEmpty)
          return 1; // empty state or shimmer (shouldn't happen post-build)
        return s.shops.length + (s.hasReachedMax ? 0 : 1);
      },
      loading: () => 1,
      error: (_, __) => 1,
    );
  }

  Widget _buildItem(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<ShopListState> async,
    int index,
  ) {
    return async.when(
      // Initial load — provider is in AsyncLoading
      loading: () => const ShopListviewLoadingShimmer(),

      error:
          (error, stack) => Padding(
            padding: const EdgeInsets.only(top: Spacing.xl),
            child: ErrorStateWidget(
              title: '',
              subtitle:
                  'Failed to load shops\nCheck your connection and try again.',
              errorDetails: stack.toString(),
              type: ErrorStateType.networkError,
              onPrimaryAction:
                  () => ref.read(shopListProvider.notifier).refresh(),
            ),
          ),

      data: (state) {
        // Empty result after a successful fetch
        if (state.shops.isEmpty) {
          return CardInkWell(
            elevation: 0,
            padding: const EdgeInsets.all(0),
            child: Center(
              child: EmptyStateWidget(
                type: EmptyStateType.noShops,
                compact: true,
                subtitle: 'No shops found',
              ),
            ),
          );
        }

        // Pagination spinner / end-of-list sentinel at the tail position
        if (index >= state.shops.length) {
          return state.isLoading
              ? Center(child: CircularLoadingIndicator())
              : const SizedBox.shrink();
        }

        // Shop card
        final shop = state.shops[index];
        return Padding(
          padding: EdgeInsets.only(bottom: Spacing.md.h),
          child: SizedBox(
            height: 400.h,
            child: ShopCard(
              shopName: shop.shopName,
              luxuryLevel: shop.luxuryLevel ?? '',
              averageRating: shop.averageRating ?? 0,
              distanceKm: shop.distanceKm ?? 0,
              numberClientsWorked: shop.numberClientsWorked ?? 0,
              shopId: shop.id,
              coverImageUrl: shop.coverImageUrl,
              showIcon: true,
            ),
          ),
        );
      },
    );
  }
}
