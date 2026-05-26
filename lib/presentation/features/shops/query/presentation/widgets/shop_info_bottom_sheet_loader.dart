import 'package:nano_embryo/core/utils/location/route_preview_widget.dart';
import 'package:nano_embryo/presentation/features/auth/utility/auth_exports.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/map_shop_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_list_item_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/shop_card.dart';

/// Bottom sheet that loads shop details asynchronously
class ShopInfoBottomSheetLoader extends ConsumerStatefulWidget {
  final String shopId;

  const ShopInfoBottomSheetLoader({super.key, required this.shopId});

  @override
  ConsumerState<ShopInfoBottomSheetLoader> createState() =>
      _ShopInfoBottomSheetLoaderState();
}

class _ShopInfoBottomSheetLoaderState
    extends ConsumerState<ShopInfoBottomSheetLoader> {
  @override
  Widget build(BuildContext context) {
    final shopDetailsAsync = ref.watch(mapShopProvider(widget.shopId));
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(Spacing.md.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Gap(Spacing.md.h),
            // Content based on async state
            shopDetailsAsync.when(
              loading:
                  () => Expanded(
                    child: LoadingStateWidget(type: LoadingStateType.inline),
                  ),
              error:
                  (error, stackTrace) => Expanded(
                    child: Center(
                      child: ErrorStateWidget(
                        subtitle: 'Failed to load shop ',
                        errorDetails: error.toString(),
                      ),
                    ),
                  ),
              data: (shopDetails) => _buildContent(context, shopDetails),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ShopListItemDTO shopDetails) {
    return SizedBox(
      height: 400.h,
      child: ShopCard(
        showIcon: true,
        shouldPop: true,
        shopName: shopDetails.shopName,
        luxuryLevel: shopDetails.luxuryLevel ?? '',
        averageRating: shopDetails.averageRating ?? 0,
        distanceKm: shopDetails.distanceKm ?? 0,
        numberClientsWorked: shopDetails.numberClientsWorked ?? 0,
        shopId: shopDetails.id,
        coverImageUrl: shopDetails.coverImageUrl,
      ),
    );
  }
}
