import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class ShopCardInfoSection extends StatelessWidget {
  // final ShopListItemDTO shop;
  final String shopName;
  final String luxuryLevel;
  final double averageRating;
  final double distanceKm;
  final int numberClientsWorked;
  final bool showIcon;

  const ShopCardInfoSection({
    super.key,
    required this.shopName,
    required this.luxuryLevel,
    required this.averageRating,
    required this.distanceKm,
    required this.numberClientsWorked, required this.showIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.all(Spacing.sm.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(Spacing.sm.h),
          Text(
            shopName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onBackground,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Gap(Spacing.sm.h),
          if (luxuryLevel != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LuxuryIndicator(luxuryLevel: luxuryLevel ?? ''),
                Text(
                  'Open now',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          AppDivider(),
          ShopCardSubDetails(
            showIcon:showIcon,
            ratings:
                averageRating == null
                    ? ''
                    : averageRating?.toStringAsFixed(1) ?? 'New',
            clientWorks:
                numberClientsWorked == null
                    ? ''
                    : numberClientsWorked.toString(),
            distance:
                distanceKm == null
                    ? ''
                    : DistanceFormatter.format(distanceKm ?? 0),
          ),
        ],
      ),
    );
  }
}
