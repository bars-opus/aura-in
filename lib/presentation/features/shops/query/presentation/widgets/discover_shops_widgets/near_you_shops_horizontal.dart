import 'package:nano_embryo/presentation/features/shops/query/providers/search_radius_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class NearYouShopsHorizontal extends ConsumerWidget {
  const NearYouShopsHorizontal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final hasLocation = ref.watch(hasLocationProvider);
    final selectedLuxury = ref.watch(selectedLuxuryLevelProvider);
    final nearYouAsync = ref.watch(nearYouShopsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final userLocation = ref.watch(userLocationNotifierProvider);
    final loc = AppLocalizations.of(context)!;

    final radiusKm = ref.watch(searchRadiusKmProvider);
    final title = loc.nearYouShopsTitle(radiusKm.toInt());

    // // If no location set, show empty state with CTA
    // if (!hasLocation) {
    //   return ShopNoLocationSet();
    // }

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
          body: loc.nearYouShopsBody(radiusKm.toInt()),
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
    final loc = AppLocalizations.of(context)!;
    return CardInkWell(
      margin: EdgeInsets.only(bottom: Spacing.sm.h),
      onTap: () {},
      child: EmptyStateWidget(
        type: EmptyStateType.noShops,
        compact: true,
        title:
            selectedLuxury == null
                ? loc.nearYouShopsEmptyNoFilter
                : loc.nearYouShopsEmptyWithFilter(selectedLuxury),
        subtitle: loc.nearYouShopsEmptySubtitle(location),
      ),
    );
  }
}
