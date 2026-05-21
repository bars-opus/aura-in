import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nano_embryo/presentation/features/shops/calendar/utility/calendar_export.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/providers/product_review_providers.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/star_rating_widget.dart';

class ProductReviewBottomSheet extends ConsumerStatefulWidget {
  final String orderId;
  final String productId;
  final String productName;
  final VoidCallback onReviewSubmitted;

  const ProductReviewBottomSheet({
    super.key,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.onReviewSubmitted,
  });

  @override
  ConsumerState<ProductReviewBottomSheet> createState() =>
      _ProductReviewBottomSheetState();
}

class _ProductReviewBottomSheetState
    extends ConsumerState<ProductReviewBottomSheet> {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(Spacing.md.h),
              child: Column(
                children: [
                  Text(
                    'Rate Your Product',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    widget.productName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Divider(height: 1.h),

            SizedBox(height: Spacing.lg.h),

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

            SizedBox(height: Spacing.md.h),

            // Review Text Field
            AppTextFormField(
              controller: _reviewController,
              label: 'Your Review',
              hintText: 'Share your experience with this product...',
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
            ),

            SizedBox(height: Spacing.xl.h),

            // Submit Button
            _isSubmitting
                ? const Center(child: CircularLoadingIndicator())
                : AppButton(
                  elevation: 0,
                  label: 'Submit Review',
                  onPressed:
                      _selectedRating > 0 && !_isSubmitting
                          ? _submitReview
                          : null,
                  size: ButtonSize.small,
                  width: double.infinity,
                  padding: Spacing.horizontalMd,
                  height: 45.h,
                ),

            SizedBox(height: Spacing.lg.h),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(
        submitProductReviewProvider({
          'orderId': widget.orderId,
          'productId': widget.productId,
          'rating': _selectedRating,
          'review':
              _reviewController.text.trim().isEmpty
                  ? null
                  : _reviewController.text.trim(),
        }).future,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onReviewSubmitted();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your review!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to submit review: $e')));
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
