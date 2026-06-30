import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';
import 'package:nano_embryo/core/widgets/card_inkwell.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_header_widget.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/map_shop_provider.dart';

/// Compact carousel card for a shop on the map.
///
/// Lazy-loads full shop details via `mapShopProvider(pin.id)`. Shows
/// a skeleton state while loading and a thin error placeholder on
/// failure. When [isSelected] is true the card gets a primary-color
/// border to mirror the active marker.
class ShopMapCard extends ConsumerWidget {
  final MapPin pin;
  final bool isSelected;

  const ShopMapCard({super.key, required this.pin, required this.isSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final shopAsync = ref.watch(mapShopProvider(pin.id));

    return shopAsync.when(
      loading: () => CardInkWell(child: _buildSkeleton(context)),
      error: (e, st) => CardInkWell(child: _buildError(context, e)),
      data: (shop) {
        final shopLogoUrl = shop.coverImageUrl ?? '';

        return Padding(
          padding: EdgeInsets.only(top: Spacing.sm.h),
          child: CardInkWell(        borderRadius: BorderRadiusTokens.xlAll,

            margin: const EdgeInsets.all(0),
            elevation: isSelected ? 10 : 0,
            color:
                isSelected
                    ? colorScheme.surface
                    : colorScheme.surface.withOpacity(.8),
            onTap: () {
              context.push(
                '/shopDetailsScreen',
                extra: {'shopId': shop.id, 'coverImageUrl': shopLogoUrl},
              );
            },
            child: ShopHeaderWidget(
              name: shop.shopName,
              luxuryLevel: shop.luxuryLevel ?? '',
              logoUrl: shopLogoUrl,
              verified: shop.verified,
              shopType: shop.shopType ?? '',
              latitude: pin.latitude,
              longitude: pin.longitude,
              averageRating: shop.averageRating ?? 0.0,
              numberClientsWorked: shop.numberClientsWorked ?? 0,
              overview: shop.overview,
              isMini: true,
              id: shop.id,
              isShop: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 108.w,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(BorderRadiusTokens.lg),
              bottomLeft: Radius.circular(BorderRadiusTokens.lg),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(Spacing.md.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 14.h,
                  width: 120.w,
                  color: colorScheme.surfaceContainerHighest,
                ),
                Container(
                  height: 10.h,
                  width: 80.w,
                  color: colorScheme.surfaceContainerHighest,
                ),
                Container(
                  height: 12.h,
                  width: 60.w,
                  color: colorScheme.surfaceContainerHighest,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, Object? error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Spacing.md.w),
        child: Text(
          'Failed to load',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}
