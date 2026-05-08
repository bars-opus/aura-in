// lib/features/freelancer/presentation/widgets/freelancer_reviews_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/freelancer/presentation/providers/freelancer_details_provider.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/shop_rating_widget.dart';
import 'package:path/path.dart';

/// Widget displaying freelancer's reviews
class FreelancerReviewsSection extends ConsumerWidget {
  final String freelancerId;

  const FreelancerReviewsSection({super.key, required this.freelancerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(freelancerReviewsProvider(freelancerId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reviews',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap(Spacing.sm.h),
              Container(
                padding: EdgeInsets.all(Spacing.lg.h),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review,
                      size: 48.h,
                      color: colorScheme.onSurface.withOpacity(0.3),
                    ),
                    Gap(Spacing.sm.h),
                    Text(
                      'No reviews yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Gap(Spacing.xs.h),
                    Text(
                      'Be the first to review this freelancer',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reviews',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Show all reviews
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            Gap(Spacing.sm.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length > 3 ? 3 : reviews.length,
              separatorBuilder: (_, __) => Gap(Spacing.md.h),
              itemBuilder: (context, index) {
                final review = reviews[index];
                return _buildReviewTile(review, theme, colorScheme);
              },
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildReviewTile(
    dynamic review,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: EdgeInsets.all(Spacing.md.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage:
                    review.clientAvatarUrl != null
                        ? NetworkImage(review.clientAvatarUrl)
                        : null,
                child:
                    review.clientAvatarUrl == null
                        ? Icon(Icons.person, size: 20.h)
                        : null,
              ),
              Gap(Spacing.sm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.clientName ?? 'Anonymous',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Rating stars widget
                    Expanded(
                      child: DetailedShopRatingWidget(
                        onTap: () {
                          // context.push(
                          //   '/shopReviewsScreen',
                          //   extra: {'shopId': freelancerId, 'shopName': ''},
                          // );
                        },
                        shopId: freelancerId,
                      ),
                    ),
                    Row(
                      children: [
                        Gap(Spacing.xs.w),
                        Text(
                          review.createdAt != null
                              ? _formatDate(review.createdAt)
                              : '',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            Gap(Spacing.sm.h),
            Text(review.comment!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) return 'Today';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30)
      return '${(difference.inDays / 7).floor()} weeks ago';
    if (difference.inDays < 365)
      return '${(difference.inDays / 30).floor()} months ago';
    return '${(difference.inDays / 365).floor()} years ago';
  }
}
