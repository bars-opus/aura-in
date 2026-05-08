import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_details_section.dart'
    show ShopDetailsSection;
import 'package:nano_embryo/presentation/features/shops/query/providers/review_providers.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/star_rating_widget.dart';

class DetailedShopRatingWidget extends ConsumerWidget {
  final String shopId;
  final VoidCallback? onTap;

  const DetailedShopRatingWidget({super.key, required this.shopId, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final colorScheme = Theme.of(context).colorScheme;
    final reviewsAsync = ref.watch(shopReviewsProvider(shopId));
    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return _buildEmptyState();
        }

        final averageRating = _calculateAverageRating(reviews);
        final totalReviews = reviews.length;
        final ratingCounts = _calculateRatingCounts(reviews);

        return GestureDetector(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(Spacing.md),
              Text(
                "Rating",
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),

              Gap(Spacing.xl),
              // Header with average rating
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side: Average rating
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: Theme.of(
                            context,
                          ).textTheme.displayMedium?.copyWith(
                            color: colorScheme.onBackground,
                            fontWeight: FontWeight.bold,
                            fontSize: 40.sp,
                          ),
                        ),
                        Gap(Spacing.xs.h),
                        StarRatingWidget(
                          rating: averageRating.round(),
                          interactive: false,
                          size: 10.sp,
                        ),
                        Gap(Spacing.xs.h),
                        Text(
                          '$totalReviews ${totalReviews == 1 ? 'review' : 'reviews'}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right side: Rating breakdown bars
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildRatingBar(
                          context,
                          5,
                          ratingCounts[5] ?? 0,
                          totalReviews,
                        ),
                        Gap(Spacing.xs.h),
                        _buildRatingBar(
                          context,
                          4,
                          ratingCounts[4] ?? 0,
                          totalReviews,
                        ),
                        Gap(Spacing.xs.h),
                        _buildRatingBar(
                          context,
                          3,
                          ratingCounts[3] ?? 0,
                          totalReviews,
                        ),
                        Gap(Spacing.xs.h),
                        _buildRatingBar(
                          context,
                          2,
                          ratingCounts[2] ?? 0,
                          totalReviews,
                        ),
                        Gap(Spacing.xs.h),
                        _buildRatingBar(
                          context,
                          1,
                          ratingCounts[1] ?? 0,
                          totalReviews,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Gap(Spacing.xl),
            ],
          ),
        );
      },
      loading: () => _buildLoadingState(),
      error: (_, __) => _buildEmptyState(),
    );
  }

  Widget _buildRatingBar(
    BuildContext context,
    int starCount,
    int count,
    int total,
  ) {
    final percentage = total > 0 ? (count / total) : 0.0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        // Star label
        Text(
          '$starCount',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        Gap(Spacing.xs.w),
        // Progress bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: colorScheme.onBackground.withOpacity(0.1),
              color: Colors.amber,
              minHeight: 6.h,
            ),
          ),
        ),
        // Count
        SizedBox(
          width: 35.w,
          child: Text(
            count.toString(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ShopDetailsSection(
      title: 'Rating',
      seeAllOnperssed: null,
      widget: Center(
        child: EmptyStateWidget(
          title: '',
          subtitle: 'No ratings yet',
          icon: Icons.star_border_outlined,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return LoadingStateWidget(type: LoadingStateType.inline);
  }

  double _calculateAverageRating(List<dynamic> reviews) {
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }

  Map<int, int> _calculateRatingCounts(List<dynamic> reviews) {
    final counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final review in reviews) {
      counts[review.rating] = (counts[review.rating] ?? 0) + 1;
    }
    return counts;
  }
}
