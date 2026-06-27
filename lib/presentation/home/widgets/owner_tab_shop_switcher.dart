import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/utils/haptic_feedback_utils.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    // Hide when there is only one shop or details not loaded yet.
    if (shops.length <= 1 || currentShop == null) {
      return const SizedBox.shrink();
    }

    void onOpenSwitcher() {
      _showSwitcherSheet(context, ref, currentShop.id);
    }

    return GestureDetector(
      onTap: onOpenSwitcher,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.md.w,
          vertical: Spacing.xs.h,
        ),
        child: SizedBox(
          height: 56.h,
          width: 150.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppIconButton(icon: Icons.keyboard_arrow_down_rounded),
              Text(
                currentShop.shopName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,

                  color: colorScheme.onSurface,
                ),
              ),
              Gap(Spacing.sm),
              ProfileAvatar(
                avatarUrl: currentShop.shopLogoUrl ?? '',
                currentUserId: '',
                size: 35.h,
                enableHero: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSwitcherSheet(
    BuildContext context,
    WidgetRef ref,
    String selectedShopId,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      maxHeight: 400.h,
      widget: ListView(
        padding: EdgeInsets.fromLTRB(0, 0, 0, Spacing.xl.h),
        children: [
          Text(
            'Switch Business',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,

              color: colorScheme.onSurface,
            ),
          ),
          Gap(Spacing.md),
          AppDivider(),
          Gap(Spacing.md),
          ...shops.map(
            (shop) => CardInkWell(
              padding: EdgeInsets.all(Spacing.sm),
              // margin: EdgeInsets.only(bottom:  Spacing.lg : 0),
              child: _buildShopTile(
                context,
                shopName: shop.shopName,
                shopType: shop.shopType,
                coverImageUrl: shop.coverImageUrl,
                isSelected: selectedShopId == shop.id,
                onTap: () {
                  Navigator.pop(context);
                  _switchShop(ref, shop.id);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopTile(
    BuildContext context, {
    required String shopName,
    String? shopType,
    String? coverImageUrl,
    required bool isSelected,
    VoidCallback? onTap,
    // Widget? leadingAction,
  }) {
    return InfoRowWidget(
      title: shopName,
      subtitle: (shopType ?? 'Shop'),
      imageUrl: coverImageUrl ?? '',
      isNotAvatarImage: false,
      iconSize: 40,

      avatarRadius: 45.h,
      titleMaxLines: 1,
      subTitleMaxLines: 1,
      showDivider: false,
      showTrailingArrow: false,
      trailing:
          (isSelected
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const SizedBox.shrink()),
      onTap: onTap,
    );
  }

  Future<void> _switchShop(WidgetRef ref, String shopId) async {
    final shop = await ref.read(shopByIdProvider(shopId).future);
    if (shop == null) return;

    await HapticFeedbackUtils.triggerSelectionFeedback();
    ref.read(currentShopProvider.notifier).state = shop;
    await ref.read(ownerShopPreferenceProvider).save(shop.id);
  }
}
