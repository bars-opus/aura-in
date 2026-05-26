import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';
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

  const ShopMapCard({
    super.key,
    required this.pin,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final shopAsync = ref.watch(mapShopProvider(pin.id));

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm.w,
        vertical: Spacing.md.h,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(BorderRadiusTokens.lg),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isSelected ? 0.10 : 0.05,
              ),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: shopAsync.when(
          loading: () => _buildSkeleton(context),
          error: (e, st) => _buildError(context, e),
          data: (shop) {
            final coverImage = shop.coverImageUrl ?? '';
            final shopName = shop.shopName;
            final shopType = shop.shopType ?? '';
            final rating = shop.averageRating ?? 0.0;
            final reviewCount = shop.numberClientsWorked ?? 0;
            final luxuryLevel = shop.luxuryLevel ?? '';
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(BorderRadiusTokens.lg),
                    bottomLeft: Radius.circular(BorderRadiusTokens.lg),
                  ),
                  child: SizedBox(
                    width: 140.w,
                    child: coverImage.isEmpty
                        ? Container(
                            color: colorScheme.surfaceContainerHighest,
                          )
                        : Image.network(
                            coverImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: colorScheme.surfaceContainerHighest,
                            ),
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
                        Text(
                          shopName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          shopType,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 16.r,
                              color: Colors.amber.shade700,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              rating.toStringAsFixed(1),
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: Spacing.sm.w),
                            Text(
                              '($reviewCount)',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            if (luxuryLevel.isNotEmpty)
                              Text(
                                luxuryLevel,
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 140.w,
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
