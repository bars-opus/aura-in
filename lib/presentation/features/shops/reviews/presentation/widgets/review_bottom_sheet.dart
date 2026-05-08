import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_text_button.dart';
import 'package:nano_embryo/presentation/features/shops/appointments/shop_daily_schedule/providers/daily_schedule_provider.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/star_rating_widget.dart';

class ReviewBottomSheet extends ConsumerStatefulWidget {
  final String bookingId;
  final String shopName;
  final VoidCallback onReviewSubmitted;

  const ReviewBottomSheet({
    super.key,
    required this.bookingId,
    required this.shopName,
    required this.onReviewSubmitted,
  });

  @override
  ConsumerState<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends ConsumerState<ReviewBottomSheet> {
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Header
        BottomSheetHeader(title: 'Rate Your Experience\n${widget.shopName}'),

        AppDivider(),

        Gap(Spacing.lg.h),

        // Star Rating
        StarRatingWidget(
          rating: _selectedRating,
          interactive: true,
          size: 32,
          onRatingChanged: (rating) {
            setState(() {
              _selectedRating = rating;
            });
          },
        ),

        Gap(Spacing.md.h),

        AppTextFormField(
          controller: _reviewController,
          isSmall: true,
          label: 'Review',
          hintText: 'Share your experience...',
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.done,
          suffixIcon: _isSubmitting ? TextFieldLoadingIndicator() : null,
        ),

        Gap(Spacing.xl.h),
        _isSubmitting
            ? CircularLoadingIndicator()
            : AppButton(
              elevation: 0,
              label: 'Submit Review',
              onPressed:
                  _selectedRating > 0 && !_isSubmitting ? _submitReview : null,
              size: ButtonSize.small,
              width: double.infinity,
              padding: Spacing.horizontalMd,
              height: 40.h,
            ),

        Gap(Spacing.lg.h),
      ],
    );
  }

  Future<void> _submitReview() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = ref.read(bookingRepositoryProvider);

      await repository.addReview(
        bookingId: widget.bookingId,
        rating: _selectedRating,
        review:
            _reviewController.text.trim().isEmpty
                ? null
                : _reviewController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onReviewSubmitted();
        context.showSuccessSnackbar('Thank you for your review!');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackbar('Failed to submit review: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
