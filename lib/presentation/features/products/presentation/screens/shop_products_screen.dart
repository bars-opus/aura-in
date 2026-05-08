// lib/features/products/presentation/screens/shop_products_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/product_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/product_form_screen.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/product_card.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

class ShopProductsScreen extends ConsumerWidget {
  final String shopId;

  const ShopProductsScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(shopProductsProvider(shopId));
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Products',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ProductFormScreen(
                        shopId: shopId,
                        mode: FormMode.create,
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(shopProductsProvider(shopId));
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ProductFormScreen(
                              shopId: shopId,
                              mode: FormMode.edit,
                              product: product,
                            ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularLoadingIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.w,
                    color: theme.colorScheme.error,
                  ),
                  SizedBox(height: 16.h),
                  Text('Failed to load products', style: textTheme.titleMedium),
                  SizedBox(height: 8.h),
                  Text(
                    error.toString(),
                    style: textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  AppButton(
                    label: 'Retry',
                    onPressed: () {
                      ref.invalidate(shopProductsProvider(shopId));
                    },
                    size: ButtonSize.small,
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 80.w,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'No products yet',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start selling your products by adding your first item',
            style: textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          AppButton(
            label: 'Add Product',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ProductFormScreen(
                        shopId: shopId,
                        mode: FormMode.create,
                      ),
                ),
              );
            },
            width: 200.w,
          ),
        ],
      ),
    );
  }
}
