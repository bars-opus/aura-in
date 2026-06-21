// lib/features/products/presentation/widgets/product_grid_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';

class ProductGridItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductGridItem({
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
      label: 'Product: ${product.name}, ${product.formattedPrice}'
          '${product.stockQuantity == 0 ? ', out of stock' : ''}'
          '${product.shopVerified == true ? ', from a verified shop' : ''}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(12.r)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: product.images.isNotEmpty
                        ? Image.network(
                            product.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _imageFallback(),
                          )
                        : _imageFallback(),
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
                        product.isActive ? 'Out of stock' : 'Unavailable',
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

            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),

                  // Price
                  Text(
                    product.formattedPrice,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),

                  if (product.totalOrdersCount > 0) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 12.w,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${product.totalOrdersCount} sold',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _imageFallback() => Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_outlined,
          size: 48.w,
          color: Colors.grey.shade400,
        ),
      );
}
