// lib/features/products/presentation/widgets/marketplace_grid_sliver.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_strings.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/marketplace_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/product_grid_item.dart';

/// Paginated 2-column product grid as a sliver, for the Discover Buy tab and
/// the standalone Marketplace route. Mirrors ShopListSliver: a simple presenter
/// over [marketplaceProductsPagedProvider]; the notifier reloads when the
/// category / location / radius changes, so this widget only triggers
/// load-more by requesting the next page as the tail comes into view.
class MarketplaceGridSliver extends ConsumerWidget {
  const MarketplaceGridSliver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marketplaceProductsPagedProvider);
    final notifier = ref.read(marketplaceProductsPagedProvider.notifier);
    final loc = AppLocalizations.of(context)!;

    // Initial load.
    if (state.isInitialLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: Spacing.xl),
          child: Center(child: CircularLoadingIndicator()),
        ),
      );
    }

    // Error with nothing to show.
    if (state.error != null && state.items.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: Spacing.xl),
          child: ErrorStateWidget(
            subtitle: state.error!,
            title: MarketplaceStrings.failedToLoad,
            onPrimaryAction: notifier.refresh,
          ),
        ),
      );
    }

    // Empty after a successful fetch.
    if (state.items.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: Spacing.xl),
          child: EmptyStateWidget(
            subtitle: loc.discoverMarketplaceSubtitle,
            title: loc.discoverMarketplaceTitle,
            icon: Icons.shopping_bag_outlined,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, Spacing.md.h),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Kick off the next page as the user nears the end of the grid.
            if (state.hasMore && index >= state.items.length - 4) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => notifier.loadNext(),
              );
            }
            final product = state.items[index];
            return ProductGridItem(
              product: product,
              onTap: () => context.pushNamed('productDetail', extra: product.id),
            );
          },
          childCount: state.items.length,
        ),
      ),
    );
  }
}
