import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

/// A reusable horizontal scrollable section for displaying shops
class HorizontalShopSection extends StatelessWidget {
  final String title;
  final String body;

  final IconData? titleIcon;
  final Color? titleIconColor;
  final List<ShopListItemDTO> shops;
  final VoidCallback? onSeeAllPressed;
  final Widget? loadingShimmer;
  final bool isLoading;
  final Function(Shop) onShopTap;

  const HorizontalShopSection({
    super.key,
    required this.title,
    required this.body,
    this.titleIcon,
    this.titleIconColor,
    required this.shops,
    this.onSeeAllPressed,
    this.loadingShimmer,
    this.isLoading = false,
    required this.onShopTap,
  });

  @override
  Widget build(BuildContext context) {
    return CardInkWell(
      onTap: () {},
      margin: EdgeInsets.only(bottom: Spacing.sm.h),
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(Spacing.lg.h),
          if (!isLoading) _header(context, false),
          if (!isLoading) Gap(Spacing.md.h),

          // Horizontal list or loading shimmer
          if (isLoading)
            (loadingShimmer ?? _buildDefaultLoadingShimmer(context))
          else if (shops.isEmpty)
            _buildEmptyState()
          else
            Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: SizedBox(
                height: 400.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: shops.length,
                  separatorBuilder: (_, __) => Gap(Spacing.md.w),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 250.w,
                      child: ShopCard(
                        showIcon: false,
                        shopName: shops[index].shopName,
                        luxuryLevel: shops[index].luxuryLevel ?? '',
                        averageRating: shops[index].averageRating ?? 0,
                        distanceKm: shops[index].distanceKm ?? 0,
                        numberClientsWorked:
                            shops[index].numberClientsWorked ?? 0,
                        shopId: shops[index].id,
                        coverImageUrl: shops[index].coverImageUrl,
                      ),
                    );
                  },
                ),
              ),
            ),
          Gap(Spacing.lg.h),
        ],
      ),
    );
  }

  _header(BuildContext context, bool isLoading) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: Spacing.horizontalLG,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                BottomSheetUtils.showDocumentationBottomSheet(
                  maxHeight: 320.h,
                  context: context,
                  widget: Column(
                    children: [
                      Gap(Spacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onBackground,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          AppTextButton(),
                        ],
                      ),
                      Gap(Spacing.md),
                      Text(
                        body,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: title,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onBackground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: isLoading ? '\nLoading...' : '\nLearn more',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ),
          if (onSeeAllPressed != null)
            AppTextButton(text: 'See all', onPressed: onSeeAllPressed),
        ],
      ),
    );
  }

  Widget _buildDefaultLoadingShimmer(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(Spacing.lg.h),
        _header(context, true),
        Gap(Spacing.md.h),
        SizedBox(
          height: 400.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
            itemCount: 3,
            separatorBuilder: (_, __) => Gap(Spacing.md.w),
            itemBuilder: (_, __) => ShopSchimmerSkeleton(width: 250.w),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return CardInkWell(
      onTap: () {},
      child: EmptyStateWidget(
        type: EmptyStateType.noShops,
        compact: true,
        title: 'No shops found nearby',
        subtitle: 'Shops would be shown here once they become available',
      ),
    );
  }
}
