import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class TopRatedShopsHorizontal extends ConsumerWidget {
  const TopRatedShopsHorizontal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedServiceCategoryProvider);
    final selectedLuxury = ref.watch(selectedLuxuryLevelProvider);
    final topRatedAsync = ref.watch(topRatedShopsProvider);
    final loc = AppLocalizations.of(context)!;

    final locRef = ProviderScope.containerOf(context, listen: false);
    final userLocation = ref.watch(userLocationNotifierProvider);
    String title =
        userLocation?.displayName == null
            ? loc.topRatedShopsHorizontalTitle
            : loc.topRatedShopsHorizontalTitleWithLocation(userLocation?.displayName ?? '');

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
          body: loc.topRatedShopsHorizontalBody,
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
    final loc = AppLocalizations.of(context)!;
    return CardInkWell(
      margin: EdgeInsets.only(bottom: Spacing.sm.h),
      onTap: () {},
      child: EmptyStateWidget(
        type: EmptyStateType.noShops,
        compact: true,
        title:
            selectedLuxury == null
                ? loc.topRatedShopsHorizontalEmptyNoFilter
                : loc.topRatedShopsHorizontalEmptyWithFilter(selectedLuxury),
        subtitle: loc.topRatedShopsHorizontalEmptySubtitle,
      ),
    );
  }
}
