import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class TopRatedShopsHorizontal extends ConsumerWidget {
  const TopRatedShopsHorizontal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedServiceCategoryProvider);
    final selectedLuxury = ref.watch(selectedLuxuryLevelProvider);
    final topRatedAsync = ref.watch(topRatedShopsProvider);

    final locRef = ProviderScope.containerOf(context, listen: false);
    final userLocation = ref.watch(userLocationNotifierProvider);
    String title = 'Top Rated \nin ${userLocation?.displayName}';

    return topRatedAsync.when(
      data: (shops) {
        // Filter shops based on selected luxury level
        final filteredShops =
            selectedLuxury == null
                ? shops // "All" - show all top rated shops
                : shops
                    .where((shop) => shop.luxuryLevel == selectedLuxury)
                    .toList();

        if (filteredShops.isEmpty) {
          return _buildEmptyState(context, selectedLuxury);
        }

        return HorizontalShopSection(
          title: title,
          titleIcon: Icons.star,
          titleIconColor: Colors.amber,
          shops: filteredShops,
          isLoading: false,
          body:
              'Shops with the highest customer ratings (4.5+ stars) and a solid number of reviews. These are the favorites among our community—consistently praised for quality, service, and professionalism. A great place to start if you want reliable, crowd‑approved options.',
          onSeeAllPressed: () {
            context.push('/topRatedShopsScreen');
          },
          onShopTap: (shop) {
            // Navigate to shop details
          },
        );
      },
      loading:
          () => HorizontalShopSection(
            title: title,
            titleIcon: Icons.star,
            titleIconColor: Colors.amber,
            shops: const [],
            isLoading: true,
            body: '',
            onShopTap: (_) {},
          ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildEmptyState(BuildContext context, String? selectedLuxury) {
    return CardInkWell(
      margin: EdgeInsets.only(bottom: Spacing.sm.h),
      onTap: () {},
      child: EmptyStateWidget(
        type: EmptyStateType.noShops,
        compact: true,
        title:
            selectedLuxury == null
                ? 'No top rated shops available'
                : 'No $selectedLuxury premium shops available',
        subtitle: 'Shops would be shown here once they become available',
      ),
    );
  }
}
