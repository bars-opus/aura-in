import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/core/widgets/feedback/empty_state.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/review_providers.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/review_display_widget.dart';

class ShopReviewsScreen extends ConsumerWidget {
  final String shopId;
  final String shopName;

  const ShopReviewsScreen({
    super.key,
    required this.shopId,
    required this.shopName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(shopReviewsProvider(shopId));

    return Scaffold(
      appBar: AppBar(title: Text('Reviews for $shopName'), centerTitle: false),
      body: reviewsAsync.when(
        data: (reviews) {
          if (reviews.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: EdgeInsets.all(Spacing.md.w),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Padding(
                padding: EdgeInsets.only(bottom: Spacing.md.h),
                child: ReviewDisplayWidget(review: review, isShopOwner: false),
              );
            },
          );
        },
        loading: () => const Center(child: CircularLoadingIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.w,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  SizedBox(height: Spacing.md.h),
                  Text(
                    'Failed to load reviews',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: Spacing.sm.h),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: EmptyStateWidget(
        title: '',
        icon: Icons.rate_review_outlined,
        subtitle: 'No reviews yet',
      ),
    );
  }
}
