// lib/features/shops/presentation/widgets/shop_details/shop_header_widget.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/distance_formatter.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_details_dto.dart';

class ShopHeaderWidget extends ConsumerWidget {
  final String name;
  final String logoUrl;
  final String id;
  final String luxuryLevel;
  final String shopType;
  final bool verified;
  final double? averageRating;
  final int? numberClientsWorked;
  final String? overview;
  final double? latitude;
  final double? longitude;
  final bool isShop;

  // final ShopDetailsDTO shop;

  const ShopHeaderWidget({
    required this.name,
    required this.logoUrl,
    required this.id,
    required this.luxuryLevel,
    required this.shopType,
    required this.verified,
    required this.averageRating,
    required this.numberClientsWorked,
    required this.overview,
    required this.latitude,
    required this.longitude,
    required this.isShop,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final distanceToShop = ref.watch(
      distanceToShopProvider(latitude ?? 0, longitude ?? 0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ProfileAvatar(
              avatarUrl: logoUrl ?? "",
              currentUserId: id,
              size: 40.r,
            ),
            Gap(20.w),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onBackground,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (luxuryLevel.isNotEmpty)
                            LuxuryIndicator(luxuryLevel: luxuryLevel ?? ''),
                          Gap(Spacing.sm.w - 4),
                          MiniContainerIndicator(
                            color: colorScheme.primary,
                            text: _formatShopType(shopType ?? 'Shop'),
                          ),
                          Gap(Spacing.sm.w - 4),
                          if (verified) ...[
                            Icon(
                              Icons.verified,
                              size: 15.sp,
                              color: Colors.blue,
                            ),
                            Gap(Spacing.xs.w),
                          ],
                        ],
                      ),
                      Text(
                        'Open now',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onBackground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Gap(Spacing.md.h),
        ShopCardSubDetails(
          isProduct: true,
          ratings:
              averageRating == null
                  ? ''
                  : averageRating?.toStringAsFixed(1) ?? 'New',
          clientWorks:
              numberClientsWorked == null ? '' : numberClientsWorked.toString(),
          distance: DistanceFormatter.format(distanceToShop ?? 0),
        ),
        Gap(Spacing.md.h),
        if (overview != null && overview!.isNotEmpty) ...[
          GestureDetector(
            onTap: () {
              BottomSheetUtils.showDocumentationBottomSheet(
                context: context,
                widget: ReadAll(body: overview ?? ''),
              );
            },
            child: Text(
              overview ?? '',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  String _formatShopType(String type) {
    return type
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
