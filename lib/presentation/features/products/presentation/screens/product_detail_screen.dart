import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/product_providers.dart';
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
                  background:
                      product.images.isNotEmpty
                          ? Image.network(
                            product.images.first,
                            fit: BoxFit.cover,
                          )
                          : Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.image_outlined,
                              size: 80.w,
                              color: Colors.grey.shade400,
                            ),
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
                        '₦${product.price.toStringAsFixed(2)}',
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
                            onPressed: () {
                              setState(() => _quantity++);
                            },
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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8.r,
                  offset: Offset(0, -2.h),
                ),
              ],
            ),
            child: AppButton(
              label:
                  'Add to Cart (₦${(product.price * _quantity).toStringAsFixed(2)})',
              onPressed: () {
                // TODO: Add to cart logic (Phase 3)
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Added to cart!')));
              },
              width: double.infinity,
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (error, stack) => const SizedBox.shrink(),
      ),
    );
  }
}
