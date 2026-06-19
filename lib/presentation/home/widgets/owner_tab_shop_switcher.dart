import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_list_item_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';

/// Compact shop-switcher chip shown at the top of owner home tabs.
/// Unlike [ShopSwitcher], selecting a shop only updates [currentShopProvider]
/// — it does not navigate away from the home screen.
class OwnerTabShopSwitcher extends ConsumerWidget {
  final List<ShopListItemDTO> shops;

  const OwnerTabShopSwitcher({super.key, required this.shops});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentShop = ref.watch(currentShopProvider);

    // Hide when there is only one shop or details not loaded yet.
    if (shops.length <= 1 || currentShop == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.md.w, vertical: Spacing.xs.h),
      child: GestureDetector(
        onTap: () => _showSwitcherSheet(context, ref),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.sm.w,
            vertical: Spacing.xs.h,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.store, size: 16.sp, color: colorScheme.primary),
              SizedBox(width: Spacing.xs.w),
              Text(
                currentShop.shopName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                size: 20.sp,
                color: colorScheme.onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSwitcherSheet(BuildContext context, WidgetRef ref) {
    final currentShop = ref.read(currentShopProvider);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(Spacing.md.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Switch Business',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Spacing.md.h),
            ...shops.map(
              (shop) => ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.store,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(shop.shopName),
                subtitle: Text(shop.shopType ?? 'Shop'),
                trailing: currentShop?.id == shop.id
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _switchShop(ref, shop.id);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _switchShop(WidgetRef ref, String shopId) {
    ref.read(shopByIdProvider(shopId).future).then((shop) {
      if (shop != null) {
        ref.read(currentShopProvider.notifier).state = shop;
      }
    });
  }
}
