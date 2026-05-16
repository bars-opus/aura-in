// lib/features/products/presentation/widgets/product_card.dart


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/currency.dart';


class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Semantics(
      button: true,
      label: 'Product: ${product.name}, ${Currency.format(product.price)}'
          '${product.stockQuantity == 0 ? ', out of stock' : ''}'
          '${product.shopVerified == true ? ', from a verified shop' : ''}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        margin: EdgeInsets.only(bottom: Spacing.md.h),
        padding: EdgeInsets.all(Spacing.sm.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8.r),
                image: product.images.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(product.images.first),
                        fit: BoxFit.cover,
                        onError: (_, __) {},
                      )
                    : null,
              ),
              child: product.images.isEmpty
                  ? Icon(
                      Icons.image_outlined,
                      size: 32.w,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    )
                  : null,
            ),
            SizedBox(width: Spacing.md.w),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (product.shopVerified == true) ...[
                        SizedBox(width: 4.w),
                        Tooltip(
                          message: 'Verified shop',
                          child: Icon(
                            Icons.verified,
                            size: 16.w,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (product.description != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      product.description!,
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        Currency.format(product.price),
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      if (!product.isActive)
                        _StatusChip(
                          label: 'Inactive',
                          color: Colors.grey.shade200,
                          textColor: Colors.grey.shade700,
                          textTheme: textTheme,
                        )
                      else if (product.stockQuantity == 0)
                        _StatusChip(
                          label: 'Out of stock',
                          color: theme.colorScheme.errorContainer,
                          textColor: theme.colorScheme.onErrorContainer,
                          textTheme: textTheme,
                        )
                      else if (product.stockQuantity <= 5)
                        _StatusChip(
                          label: 'Only ${product.stockQuantity} left',
                          color: theme.colorScheme.tertiaryContainer,
                          textColor: theme.colorScheme.onTertiaryContainer,
                          textTheme: textTheme,
                        ),
                      if (product.totalOrdersCount > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 14.w,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${product.totalOrdersCount} orders',
                              style: textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final TextTheme textTheme;
  const _StatusChip({
    required this.label,
    required this.color,
    required this.textColor,
    required this.textTheme,
  });
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          label,
          style: textTheme.labelSmall?.copyWith(color: textColor),
        ),
      );
}
