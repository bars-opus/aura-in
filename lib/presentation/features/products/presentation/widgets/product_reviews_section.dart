import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/providers/product_review_providers.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/product_review_display_widget.dart';

/// Reviews tab body for product detail. Lists product reviews, or an empty
/// state. Pure content (no Scaffold) — hosted inside ProductDetailContent.
class ProductReviewsSection extends ConsumerWidget {
  final String productId;

  const ProductReviewsSection({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(productReviewsProvider(productId));
    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Center(
              child: EmptyStateWidget(
                icon: Icons.rate_review_outlined,
                title: 'No reviews yet',
                subtitle: 'Be the first to review this product',
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(Spacing.md.w),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => Gap(Spacing.sm.h),
          itemBuilder:
              (context, index) =>
                  ProductReviewDisplayWidget(review: reviews[index]),
        );
      },
      loading: () => const Center(child: CircularLoadingIndicator()),
      error:
          (error, _) => SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Center(
              child: ErrorStateWidget(
                title: '',
                subtitle: 'Failed to load reviews',
                onPrimaryAction:
                    () => ref.invalidate(productReviewsProvider(productId)),
              ),
            ),
          ),
    );
  }
}
