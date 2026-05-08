import 'package:nano_embryo/core/utils/date_formatter.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/data/models/booking_review.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/star_rating_widget.dart';

class ReviewDisplayWidget extends StatelessWidget {
  final BookingReview review;
  final bool isShopOwner;
  final bool compact;

  const ReviewDisplayWidget({
    super.key,
    required this.review,
    this.isShopOwner = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (compact) {
      // Compact version for horizontal scrolling
      return CardInkWell(
        // elevation: 0,
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StarRatingWidget(
              rating: review.rating,
              interactive: false,
              size: 12,
            ),

            Text(
              review.review!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(Spacing.md.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Avatar
              ProfileAvatar(
                avatarUrl: review.userAvatar ?? '',
                currentUserId: review.userId,
                size: 50.h,
              ),

              Gap(Spacing.sm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? 'Anonymous',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gap(2.h),
                    Text(
                      MyDateFormat.toDate(review.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Gap(Spacing.sm.h),

          // Rating
          StarRatingWidget(rating: review.rating, interactive: false, size: 16),

          Gap(Spacing.sm.h),

          // Review Text
          if (review.review != null && review.review!.isNotEmpty)
            Text(review.review!, style: theme.textTheme.bodyMedium),

          // Shop Response
          if (review.shopResponse != null && review.shopResponse!.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: Spacing.sm.h),
              padding: EdgeInsets.all(Spacing.sm.h),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shop Response:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  Gap(Spacing.xs.h),
                  Text(review.shopResponse!, style: theme.textTheme.bodySmall),
                  if (review.respondedAt != null)
                    Text(
                      MyDateFormat.toDate(review.respondedAt ?? DateTime.now()),

                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
