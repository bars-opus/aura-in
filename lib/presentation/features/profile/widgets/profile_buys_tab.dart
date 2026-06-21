// The profile "Buys" tab: shows the products an account is selling.
// Owner (isCurrentUser) taps a product to edit it in ProductFormScreen;
// everyone else taps to view/buy it in ProductDetailScreen.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/account_products_provider.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/product_form_screen.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/product_card.dart';

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
    final productsAsync = ref.watch(accountProductsProvider(profileUserId));

    return productsAsync.when(
      loading: () => const Center(child: CircularLoadingIndicator()),
      error: (_, __) => Center(
        child: EmptyStateWidget(
          icon: Icons.error_outline,
          title: 'Could not load products',
          subtitle: 'Please try again.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(accountProductsProvider(profileUserId)),
        ),
      ),
      data: (products) {
        if (products.isEmpty) {
          return Center(
            child: EmptyStateWidget(
              icon: Icons.shopping_bag_outlined,
              title: isCurrentUser ? 'No products yet' : 'Nothing for sale',
              subtitle: isCurrentUser
                  ? 'Products you list for sale will appear here.'
                  : 'This account isn\'t selling any products yet.',
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: () {
                if (isCurrentUser) {
                  // Owner: edit the product. Use the product's OWN shopId so
                  // multi-shop accounts edit the right shop's product.
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
                  context.pushNamed('productDetail', extra: product.id);
                }
              },
            );
          },
        );
      },
    );
  }
}
