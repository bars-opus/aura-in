import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/providers/product_review_providers.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/product_review_display_widget.dart';

class ProductDetailReviewSection extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailReviewSection({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailReviewSection> createState() =>
      _ProductDetailReviewSectionState();
}

class _ProductDetailReviewSectionState
    extends ConsumerState<ProductDetailReviewSection> {
  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(productReviewsProvider(widget.productId));

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
}
