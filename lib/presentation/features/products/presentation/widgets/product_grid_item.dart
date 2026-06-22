// lib/features/products/presentation/widgets/product_grid_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_icon_button.dart';
import 'package:nano_embryo/core/widgets/card_inkwell.dart';
import 'package:nano_embryo/core/widgets/info_row_widget.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';

class ProductGridItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final bool showVertical;

  const ProductGridItem({
    super.key,
    required this.product,
    required this.onTap,
    this.showVertical = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      label:
          'Product: ${product.name}, ${product.formattedPrice}'
          '${product.stockQuantity == 0 ? ', out of stock' : ''}'
          '${product.shopVerified == true ? ', from a verified shop' : ''}',
      child: CardInkWell(
        // elevation: 0,
        padding:
            showVertical
                ? const EdgeInsets.all(Spacing.md)
                : const EdgeInsets.all(0),
        onTap: onTap,
        child:
            showVertical
                ? InfoRowWidget(
                  isNotAvatarImage: true,
                  subtitle: product.description ?? '',
                  title: product.name,
                  icon: Icons.image_outlined,
                  iconSize: 50.0,

                  imageUrl: product.images.first,
                  titleFontSize: FontSizeTokens.lg,
                  avatarRadius: 70.h,

                  onTap: onTap,
                  disableTrailing: false,
                  showAvatar: false,
                  showDivider: false,
                  showTrailingArrow: false,
                  trailing: Text(
                    product.formattedPrice,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Stack(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12.r),
                            ),
                            child:
                                product.images.isNotEmpty
                                    ? Image.network(
                                      product.images.first,
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

                        if (product.shopVerified == true)
                          Positioned(
                            top: 6.w,
                            right: 6.w,
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.verified,
                                size: 14.w,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        if (!product.isActive || product.stockQuantity == 0)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12.r),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                product.isActive
                                    ? 'Out of stock'
                                    : 'Unavailable',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name
                            Text(
                              product.name,
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onBackground,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Gap(Spacing.sm),

                            // Price
                            Text(
                              product.formattedPrice,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),

                            if (product.totalOrdersCount > 0) ...[
                              Gap(Spacing.sm),
                              Row(
                                children: [
                                  Icon(
                                    Icons.shopping_bag_outlined,
                                    size: IconSizes.md,
                                    color: Colors.grey.shade600,
                                  ),
                                  Gap(4.w),
                                  Text(
                                    '${product.totalOrdersCount} sold',
                                    style: TextStyle(
                                      fontSize: FontSizeTokens.sm,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            Text(
                              product.description!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
