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
    final theme = Theme.of(context);

    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(Spacing.lg.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48.w,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  Gap(Spacing.sm.h),
                  Text('No reviews yet', style: theme.textTheme.titleMedium),
                  Gap(Spacing.xs.h),
                  Text(
                    'Be the first to review this product',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(Spacing.md.w),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => Gap(Spacing.sm.h),
          itemBuilder: (context, index) =>
              ProductReviewDisplayWidget(review: reviews[index]),
        );
      },
      loading: () => const Center(child: CircularLoadingIndicator()),
      error: (error, _) => Center(
        child: ErrorStateWidget(
          title: '',
          subtitle: 'Failed to load reviews',
          onPrimaryAction: () =>
              ref.invalidate(productReviewsProvider(productId)),
        ),
      ),
    );
  }
}
