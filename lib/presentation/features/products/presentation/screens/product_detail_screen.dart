import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/presentation/features/products/data/exceptions/marketplace_exceptions.dart';
import 'package:nano_embryo/presentation/features/products/data/models/cart_item_model.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/currency.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_logger.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_strings.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/cart_provider.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/product_providers.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_details_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_header_widget.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_image_pageview.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/providers/product_review_providers.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/product_review_display_widget.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  bool _isAddingToCart = false;

  Future<void> _addToCart(ProductModel product) async {
    if (_isAddingToCart) return;

    if (!product.isActive) {
      _toast('This product is no longer available.');
      return;
    }
    if (product.stockQuantity < _quantity) {
      _toast(
        product.stockQuantity == 0
            ? 'Out of stock'
            : 'Only ${product.stockQuantity} left in stock',
      );
      return;
    }

    setState(() => _isAddingToCart = true);

    try {
      final shopName =
          product.shopName ??
          (await ref.read(shopNameByIdProvider(product.shopId).future));

      final item = CartItemModel(
        productId: product.id,
        productName: product.name,
        price: product.price,
        imageUrl: product.images.isNotEmpty ? product.images.first : null,
        quantity: _quantity,
        shopId: product.shopId,
        shopName: shopName ?? 'Unknown shop',
        currencySymbol: product.shopCurrencySymbol,
        currencyCode: product.shopCurrencyCode,
      );

      await ref.read(cartNotifierProvider.notifier).addItem(item);

      if (!mounted) return;
      context.showSuccessSnackbar(MarketplaceStrings.addedToCart);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text(MarketplaceStrings.addedToCart),
      //     action: SnackBarAction(
      //       label: MarketplaceStrings.viewCart,
      //       onPressed: () => context.pushNamed('cart'),
      //     ),
      //   ),
      // );
    } on MultiShopCartException catch (_) {
      if (!mounted) return;
      final confirmed = await _confirmReplaceCart();
      if (confirmed == true && mounted) {
        await ref.read(cartNotifierProvider.notifier).clearCart();
        // Retry once now that the cart is empty.
        if (!mounted) return;
        await _addToCart(product);
        return;
      }
    } on MarketplaceException catch (e, stack) {
      MarketplaceLogger.warn('add to cart rejected', error: e, stack: stack);
      _toast(e.message);
    } catch (e, stack) {
      MarketplaceLogger.error('add to cart failed', error: e, stack: stack);
      _toast('Failed to add to cart');
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    context.showInfoSnackbar(msg);
  }

  String _buttonLabel(ProductModel product) {
    if (_isAddingToCart) return MarketplaceStrings.addingToCart;
    if (!product.isActive) return MarketplaceStrings.unavailable;
    if (product.stockQuantity == 0) return MarketplaceStrings.outOfStock;
    return '${MarketplaceStrings.addToCart} '
        '(${Currency.formatCompact(product.price * _quantity)})';
  }

  Future<bool?> _confirmReplaceCart() => showDialog<bool>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: const Text(MarketplaceStrings.replaceCartTitle),
          content: const Text(MarketplaceStrings.replaceCartBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(MarketplaceStrings.keepCart),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(MarketplaceStrings.replace),
            ),
          ],
        ),
  );

  // Add this method to your ProductDetailScreen
  Widget _buildReviewsSection(String productId) {
    final reviewsAsync = ref.watch(productReviewsProvider(productId));

    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16.w),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.rate_review_outlined, size: 48.w),
                  SizedBox(height: 8.h),
                  Text('No reviews yet'),
                  SizedBox(height: 8.h),
                  Text(
                    'Be the first to review this product',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Customer Reviews',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Show all reviews
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder:
                            (context) => DraggableScrollableSheet(
                              initialChildSize: 0.9,
                              minChildSize: 0.5,
                              maxChildSize: 0.95,
                              builder: (context, scrollController) {
                                return Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16.w),
                                      child: Text(
                                        'All Reviews',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleLarge,
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        controller: scrollController,
                                        padding: EdgeInsets.all(16.w),
                                        itemCount: reviews.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom: 12.h,
                                            ),
                                            child: ProductReviewDisplayWidget(
                                              review: reviews[index],
                                              isShopOwner: false,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                      );
                    },
                    child: Text('See All (${reviews.length})'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            ...reviews
                .take(3)
                .map(
                  (review) => Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                    child: ProductReviewDisplayWidget(
                      review: review,
                      isShopOwner: false,
                      compact: false,
                    ),
                  ),
                ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productProvider(widget.productId));
    final theme = Theme.of(context);

    return Scaffold(
      body: productAsync.when(
        data: (product) {
          return CustomScrollView(
            slivers: [
              // App Bar with image
              SliverAppBar(
                expandedHeight: 300.h,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: ShopImagePageview(
                    isPreview: false,
                    shopImageUrls: product.images,
                  ),
                ),
              ),

              // Product details
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seller identity. Every product belongs to a shop row —
                      // a real shop OR the lightweight shop created for a
                      // product-seller account. The DTO's shopType chip
                      // ("Salon", "Product Seller", …) tells the buyer who's
                      // selling. Tapping opens the seller's shop page.
                      _SellerHeader(
                        shopId: product.shopId,
                        fallbackName: product.shopName,
                        fallbackVerified: product.shopVerified ?? false,
                      ),

                      // Product name
                      Text(
                        product.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Price
                      Text(
                        product.formattedPrice,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Category
                      Chip(
                        label: Text(
                          ProductCategory.fromString(
                            product.category,
                          ).displayName,
                        ),
                        backgroundColor: theme.colorScheme.primaryContainer,
                      ),
                      SizedBox(height: 16.h),

                      // Description
                      if (product.description != null) ...[
                        Text(
                          'Description',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          product.description!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                      SizedBox(height: 24.h),

                      // Quantity selector
                      Text(
                        'Quantity',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                              }
                            },
                          ),
                          Container(
                            width: 50.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: Text(
                                '$_quantity',
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            // Cap at available stock — can't add more than exists.
                            onPressed:
                                _quantity < product.stockQuantity
                                    ? () => setState(() => _quantity++)
                                    : null,
                          ),
                        ],
                      ),
                      _buildReviewsSection(product.id),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Center(child: const CircularLoadingIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.w),
                  SizedBox(height: 16.h),
                  Text('Failed to load product'),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(productProvider(widget.productId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),

      // Bottom bar with Add to Cart button
      bottomNavigationBar: productAsync.when(
        data: (product) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8.r,
                  offset: Offset(0, -2.h),
                ),
              ],
            ),
            child: Semantics(
              button: true,
              label: _buttonLabel(product),
              enabled:
                  !(_isAddingToCart ||
                      !product.isActive ||
                      product.stockQuantity == 0),
              child: AppButton(
                label: _buttonLabel(product),
                onPressed:
                    _isAddingToCart ||
                            !product.isActive ||
                            product.stockQuantity == 0
                        ? null
                        : () => _addToCart(product),
                width: double.infinity,
              ),
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (error, stack) => const SizedBox.shrink(),
      ),
    );
  }
}

/// Shows who is selling the product. Resolves the product's shop row (a real
/// shop OR the lightweight shop created for a product-seller account) and
/// renders ShopHeaderWidget from it — so buyers see the seller's name, type
/// chip, rating and overview either way. Tapping opens the seller's shop page.
class _SellerHeader extends ConsumerWidget {
  final String shopId;
  final String? fallbackName;
  final bool fallbackVerified;

  const _SellerHeader({
    required this.shopId,
    required this.fallbackName,
    required this.fallbackVerified,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(shopByIdProvider(shopId));

    Widget headerFromDto(ShopDetailsDTO shop) => GestureDetector(
      onTap:
          () => context.pushNamed(
            'shopDetailsScreen',
            extra: <String, String?>{
              'shopId': shop.id,
              'coverImageUrl': shop.shopLogoUrl ?? '',
            },
          ),
      child: ShopHeaderWidget(
        name: shop.shopName,
        luxuryLevel: shop.luxuryLevel ?? '',
        logoUrl: shop.shopLogoUrl ?? '',
        verified: shop.verified,
        shopType: shop.shopType ?? '',
        latitude: shop.latitude,
        longitude: shop.longitude,
        averageRating: shop.averageRating,
        numberClientsWorked: shop.numberClientsWorked,
        overview: shop.overview,
        id: shop.id,
        isShop: true,
      ),
    );

    return shopAsync.when(
      data: (shop) {
        if (shop == null) return _fallback();
        return headerFromDto(shop);
      },
      // While the shop resolves, show the name we already have from the
      // product so the header doesn't flash empty.
      loading: () => _fallback(),
      error: (_, __) => _fallback(),
    );
  }

  /// Minimal seller line when the full shop DTO isn't available yet / fails.
  Widget _fallback() {
    final name =
        (fallbackName == null || fallbackName!.isEmpty)
            ? 'Seller'
            : fallbackName!;
    return Builder(
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;
        return Row(
          children: [
            ProfileAvatar(avatarUrl: '', currentUserId: shopId, size: 40.r),
            Gap(20.w),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (fallbackVerified) ...[
                    Gap(Spacing.xs.w),
                    Icon(Icons.verified, size: 15.sp, color: Colors.blue),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
