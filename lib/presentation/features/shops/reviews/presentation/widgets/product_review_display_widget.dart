import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/date_formatter.dart';
import 'package:nano_embryo/presentation/features/profile/widgets/profile_avatar.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/data/models/product_review_model.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/star_rating_widget.dart';


class ProductReviewDisplayWidget extends StatelessWidget {
  final ProductReview review;
  final bool isShopOwner;
  final bool compact;

  const ProductReviewDisplayWidget({
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
      return GestureDetector(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.all(Spacing.sm.h),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StarRatingWidget(
                rating: review.rating,
                interactive: false,
                size: 12,
              ),
              SizedBox(height: 8.h),
              Text(
                review.review ?? '',
                style: theme.textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
            children: [
              ProfileAvatar(
                avatarUrl: review.userAvatar ?? '',
                currentUserId: review.userId,
                size: 50.h,
              ),
              SizedBox(width: Spacing.sm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? 'Anonymous',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
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

          SizedBox(height: Spacing.sm.h),

          // Rating
          StarRatingWidget(
            rating: review.rating,
            interactive: false,
            size: 16,
          ),

          SizedBox(height: Spacing.sm.h),

          // Review Text
          if (review.review != null && review.review!.isNotEmpty)
            Text(
              review.review!,
              style: theme.textTheme.bodyMedium,
            ),

          // Product Info (optional, for shop owner view)
          if (isShopOwner && review.productName != null)
            Container(
              margin: EdgeInsets.only(top: Spacing.sm.h),
              padding: EdgeInsets.all(Spacing.sm.h),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  if (review.productImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        review.productImage!,
                        width: 40.w,
                        height: 40.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(width: Spacing.sm.w),
                  Expanded(
                    child: Text(
                      review.productName!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),

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
                  SizedBox(height: Spacing.xs.h),
                  Text(
                    review.shopResponse!,
                    style: theme.textTheme.bodySmall,
                  ),
                  if (review.respondedAt != null)
                    Text(
                      MyDateFormat.toDate(review.respondedAt!),
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
