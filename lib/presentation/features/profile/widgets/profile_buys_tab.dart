// The profile "Buys" tab: shows the products an account is selling.
// Owner (isCurrentUser) taps a product to edit it in ProductFormScreen;
// everyone else taps to view/buy it in ProductDetailScreen.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/account_products_provider.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/paginated_list_notifier.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/product_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/product_form_screen.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/product_card.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';

class ProfileBuysTab extends ConsumerWidget {
  final String profileUserId;
  final bool isCurrentUser;

  const ProfileBuysTab({
    super.key,
    required this.profileUserId,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedShop = ref.watch(currentShopProvider);
    final selectedShopId = isCurrentUser ? selectedShop?.id : null;
    final state =
        selectedShopId == null
            ? ref.watch(accountProductsProvider(profileUserId))
            : ref.watch(shopProductsPagedProvider(selectedShopId));
    final PagedListNotifier<ProductModel> notifier =
        selectedShopId == null
            ? ref.read(accountProductsProvider(profileUserId).notifier)
            : ref.read(shopProductsPagedProvider(selectedShopId).notifier);

    if (state.isInitialLoading) {
      return const Center(child: CircularLoadingIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.error_outline,
          title: 'Could not load products',
          subtitle: 'Please try again.',
          actionLabel: 'Retry',
          onAction: notifier.refresh,
        ),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.shopping_bag_outlined,
          title: isCurrentUser ? 'No products yet' : 'Nothing for sale',
          subtitle:
              isCurrentUser
                  ? 'Products you list for sale will appear here.'
                  : 'This account isn\'t selling any products yet.',
        ),
      );
    }

    final managementShopId =
        selectedShopId ??
        (state.items.isNotEmpty ? state.items.first.shopId : '');

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 300 &&
            state.hasMore &&
            !state.isLoadingMore) {
          notifier.loadNext();
        }
        return false;
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount:
            state.items.length +
            (state.hasMore ? 1 : 0) +
            (isCurrentUser ? 1 : 0),
        itemBuilder: (context, index) {
          if (isCurrentUser && index == 0) {
            return _SellerManageOrdersCard(
              onTap:
                  managementShopId.isEmpty
                      ? null
                      : () => context.pushNamed(
                        'shopOrders',
                        extra: managementShopId,
                      ),
            );
          }

          final productIndex = isCurrentUser ? index - 1 : index;
          if (productIndex >= state.items.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          final product = state.items[productIndex];
          return ProductCard(
            product: product,
            onTap: () {
              if (isCurrentUser) {
                // Owner: edit. Use the product's OWN shopId so multi-shop
                // accounts edit the right shop's product.
                context.pushNamed(
                  'productForm',
                  extra: {
                    'shopId': product.shopId,
                    'mode': FormMode.edit,
                    'product': product,
                  },
                );
              } else {
                // Visitor: view + buy.
                context.pushNamed(
                  'productDetail',
                  extra: <String, String?>{
                    'productId': product.id,
                    'coverImageUrl': product.images.firstOrNull ?? '',
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _SellerManageOrdersCard extends StatelessWidget {
  final VoidCallback? onTap;

  const _SellerManageOrdersCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CardInkWell(
      margin: EdgeInsets.only(bottom: Spacing.sm),
      child: InfoRowWidget(
        subtitle: 'Confirm orders and manage fulfilment for this shop.',
        title: 'Manage your orders',
        icon: Icons.receipt_long_outlined,
        avatarRadius: 25.h,
        onTap: onTap,
        showAvatar: false,
        showTrailingArrow: true,
        showDivider: false,
      ),
    );
  }
}
