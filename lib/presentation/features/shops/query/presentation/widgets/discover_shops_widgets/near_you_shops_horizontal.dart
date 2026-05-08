import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/shop_no_location_set.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class NearYouShopsHorizontal extends ConsumerWidget {
  const NearYouShopsHorizontal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasLocation = ref.watch(hasLocationProvider);
    final selectedLuxury = ref.watch(selectedLuxuryLevelProvider);
    final nearYouAsync = ref.watch(nearYouShopsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final userLocation = ref.watch(userLocationNotifierProvider);

    String title = 'Near You\nwithin 2km';

    // If no location set, show empty state with CTA
    if (!hasLocation) {
      return ShopNoLocationSet();
    }

    return nearYouAsync.when(
      data: (shops) {
        // Filter shops based on selected luxury level
        final filteredShops =
            selectedLuxury == null
                ? shops // "All" - show all nearby shops
                : shops
                    .where((shop) => shop.luxuryLevel == selectedLuxury)
                    .toList();

        if (filteredShops.isEmpty) {
          return _buildEmptyState(
            context,
            selectedLuxury,
            userLocation?.displayName ?? 'your city',
          );
        }
        return HorizontalShopSection(
          title: title,
          body:
              'Shops located within 2 km of your current location, shown from closest to farthest. Simply set your location once, and we\'ll show you what\'s nearby—whether you\'re at home, work, or exploring a new neighborhood. Handy for last‑minute bookings or when you prefer to walk.',
          titleIcon: Icons.near_me,
          titleIconColor: colorScheme.primary,
          shops: filteredShops,
          isLoading: false,
          onSeeAllPressed: () {
            context.push('/nearYouShopsScreen');
          },
          onShopTap: (shop) {
            // Navigate to shop details
          },
        );
      },
      loading:
          () => HorizontalShopSection(
            title: title,
            titleIcon: Icons.near_me,
            titleIconColor: colorScheme.primary,
            shops: const [],
            body: '',
            isLoading: true,
            onShopTap: (_) {},
          ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String? selectedLuxury,
    String location,
  ) {
    return CardInkWell(
      margin: EdgeInsets.only(bottom: Spacing.sm.h),
      onTap: () {},
      child: EmptyStateWidget(
        type: EmptyStateType.noShops,
        compact: true,
        title:
            selectedLuxury == null
                ? 'No shops found nearby'
                : 'No $selectedLuxury shops found nearby',
        subtitle:
            'Shops in ${location} would be shown here once they become available',
      ),
    );
  }
}
