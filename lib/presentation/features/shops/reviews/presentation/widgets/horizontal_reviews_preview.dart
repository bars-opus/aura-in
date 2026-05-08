import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_details_section.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/review_providers.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/widgets/review_display_widget.dart';

class HorizontalReviewsPreview extends ConsumerWidget {
  final String shopId;
  final VoidCallback onViewAllPressed;

  const HorizontalReviewsPreview({
    super.key,
    required this.shopId,
    required this.onViewAllPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(shopReviewsProvider(shopId));

    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return const SizedBox.shrink();
        }
        // Take only the latest 5 reviews
        final latestReviews = reviews.take(5).toList();
        return ShopDetailsSection(
          showCard: false,
          title: 'Reviews',
          seeAllOnperssed: latestReviews.length > 4 ? () {} : null,
          widget: SizedBox(
            height: 180.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(right: Spacing.md.w),
              itemCount: latestReviews.length,
              separatorBuilder: (_, __) => SizedBox(width: Spacing.sm.w),
              itemBuilder: (context, index) {
                final review = latestReviews[index];
                return SizedBox(
                  width: 280.w,
                  child: ReviewDisplayWidget(
                    review: review,
                    isShopOwner: false,
                    compact: true, // You may need to add a compact mode
                  ),
                );
              },
            ),
          ),
        );
      },
      loading: () => _buildLoadingState(context),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return LoadingStateWidget(type: LoadingStateType.inline);
  }
}
