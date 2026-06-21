// lib/features/shops/presentation/widgets/shop_card.dart
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/shop_card_info_section.dart';

class ShopCard extends StatelessWidget {
  // final ShopListItemDTO shop;
  // final VoidCallback onTap;

  final String shopName;
  final String luxuryLevel;
  final double averageRating;
  final double distanceKm;
  final int numberClientsWorked;
  final String shopId;
  final String? coverImageUrl;
  final bool showIcon;
  final bool shouldPop;

  const ShopCard({
    super.key,
    required this.shopName,
    required this.luxuryLevel,
    required this.averageRating,
    required this.distanceKm,
    required this.numberClientsWorked,
    required this.shopId,
    required this.coverImageUrl,
    required this.showIcon,
    this.shouldPop = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CardInkWell(
      // elevation: 0,
      padding: const EdgeInsets.all(0),
      onTap: () {
        if (shouldPop) {
          Navigator.pop(context);
        }
        context.push(
          '/shopDetailsScreen',
          extra: {'shopId': shopId, 'coverImageUrl': coverImageUrl ?? ''},
        );
      },
      child: Container(
        // width: 250.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colorScheme.background),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                child:
                    coverImageUrl != null
                        ? Image.network(
                          coverImageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder:
                              (_, __, ___) => Center(
                                child: Icon(
                                  Icons.image_not_supported_rounded,
                                  color: Colors.grey.shade500,
                                  size: 50.h,
                                ),
                              ),
                        )
                        : Center(
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            size: 50.h,
                            color: Colors.grey.shade500,
                          ),
                        ),
              ),
            ),
            // Content
            Expanded(
              flex: 1,
              child: ShopCardInfoSection(
                showIcon: showIcon,
                shopName: shopName,
                luxuryLevel: luxuryLevel,

                averageRating: averageRating,
                distanceKm: distanceKm,
                numberClientsWorked: numberClientsWorked,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
