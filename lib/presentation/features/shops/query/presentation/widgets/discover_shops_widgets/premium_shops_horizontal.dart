import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class PremiumShopsHorizontal extends ConsumerWidget {
  const PremiumShopsHorizontal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLuxury = ref.watch(selectedLuxuryLevelProvider);
    final premiumAsync = ref.watch(premiumShopsProvider);
    String title = 'Premium shops\nfor premium looks';

    return premiumAsync.when(
      data: (shops) {
        // Filter shops based on selected luxury level
        final filteredShops =
            selectedLuxury == null
                ? shops // "All" - show all premium shops
                : shops
                    .where((shop) => shop.luxuryLevel == selectedLuxury)
                    .toList();

        if (filteredShops.isEmpty) {
          return _buildEmptyState(context, selectedLuxury);
        }

        return HorizontalShopSection(
          title: title,
          titleIcon: Icons.diamond,
          titleIconColor: Colors.purple,
          shops: filteredShops,
          isLoading: false,
          body:
              'Handpicked high‑end salons and spas offering luxury experiences. These shops are classified as Luxury or Ultra‑Luxury based on their services, pricing, and customer reviews. Perfect when you\'re looking for that extra touch of elegance.',
          onSeeAllPressed: () {
            context.push('/premiumShopsScreen');
          },
          onShopTap: (shop) {
            // Navigate to shop details
          },
        );
      },
      loading:
          () => HorizontalShopSection(
            title: title,
            body: '',
            titleIcon: Icons.diamond,
            titleIconColor: Colors.purple,
            shops: const [],
            isLoading: true,
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
                ? 'No premium shops available'
                : 'No $selectedLuxury premium shops available',
        subtitle: 'Shops would be shown here once they become available',
      ),
    );
  }
}
