// lib/features/shop/context/widgets/shop_switcher.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';

class ShopSwitcher extends ConsumerWidget {
  const ShopSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentShop = ref.watch(currentShopProvider);
    final userShopsAsync = ref.watch(userShopsProvider);
    final hasMultipleShopsAsync = ref.watch(hasMultipleShopsProvider);

    return userShopsAsync.when(
      data: (shops) {
        if (shops.isEmpty || currentShop == null) {
          return const SizedBox.shrink();
        }
        
        return GestureDetector(
          onTap: () => _showShopSwitcherSheet(context, ref, shops),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.sm.w,
              vertical: Spacing.xs.h,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.store,
                  size: 16.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: Spacing.xs.w),
                Text(
                  currentShop.shopName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (shops.length > 1)
                  Icon(
                    Icons.arrow_drop_down,
                    size: 20.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        width: 100,
        height: 32,
        child: Center(child: CircularLoadingIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showShopSwitcherSheet(BuildContext context, WidgetRef ref, List shops) {
    final currentShop = ref.read(currentShopProvider);
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
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
            ...shops.map((shop) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.store,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(shop.shopName),
              subtitle: Text(shop.shopType ?? 'Shop'),
              trailing: currentShop?.id == shop.id
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () {
                Navigator.pop(context);
                _switchShop(context, ref, shop.id);
              },
            )),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.add),
              ),
              title: const Text('Create New Shop'),
              onTap: () {
                Navigator.pop(context);
                context.push('/shop-creation');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _switchShop(BuildContext context, WidgetRef ref, String shopId) {
    // Load the selected shop details
    ref.read(shopByIdProvider(shopId).future).then((shop) {
      if (shop != null) {
        ref.read(currentShopProvider.notifier).state = shop;
        // Refresh dashboard or navigate
        context.go('/shop-dashboard/$shopId');
      }
    });
  }
}
