import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/app_divider.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/controllers/booking_repository_provider.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/review_bottom_sheet.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/review_display_widget.dart';

class RatingSection extends ConsumerWidget {
  // final BookingModel booking;
  final String shopName;
  final String bookingId;
  final String status;

  const RatingSection({
    super.key,
    required this.bookingId,
    required this.shopName,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewAsync = ref.watch(bookingReviewProvider(bookingId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return reviewAsync.when(
      data: (review) {
        // If review exists, display it
        if (review != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDivider(),
              Gap(Spacing.md.h),
              Text(
                'Your Review',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Gap(Spacing.sm.h),
              ReviewDisplayWidget(review: review, isShopOwner: false),
            ],
          );
        }

        // If booking is completed and no review, show button to add one
        if (status == "completed") {
          return Column(
            children: [
              AppDivider(),
              Gap(Spacing.md.h),
              _buildAddReviewButton(context, ref),
            ],
          );
        }

        return const SizedBox();
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildAddReviewButton(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        SemanticContainerWidget(
          content:
              'Kindly wait for the payment to finish processing and return to your app to generate your appointment',
          icon: Icons.star_border,
          title: 'How was your experience?',
          backgroundColor: colorScheme.primary.withOpacity(0.1),
          borderColor: colorScheme.primary,
          iconColor: colorScheme.primary,
          textTheme: theme.textTheme,
        ),

        Gap(Spacing.md.h),

        AppButton(
          height: 35.h,
          // iconData: Icons.send,
          label: 'Write a Review',
          onPressed: () {
            BottomSheetUtils.showDocumentationBottomSheet(
              context: context,
              widget: ReviewBottomSheet(
                bookingId: bookingId,
                shopName: shopName,
                onReviewSubmitted: () {
                  ref.invalidate(bookingReviewProvider(bookingId));
                },
              ),
            );
          },
          padding: Spacing.horizontalMd,
          variant: ButtonVariant.outline,
          size: ButtonSize.small,
          width: double.infinity,
          elevation: 0,
        ),
        Gap(Spacing.lg.h),
      ],
    );
  }
}
