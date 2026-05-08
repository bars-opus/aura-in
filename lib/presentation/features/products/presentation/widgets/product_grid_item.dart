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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: AspectRatio(
                aspectRatio: 1,
                child:
                    product.images.isNotEmpty
                        ? Image.network(
                          product.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.image_outlined,
                                size: 48.w,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        )
                        : Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_outlined,
                            size: 48.w,
                            color: Colors.grey.shade400,
                          ),
                        ),
              ),
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
                    '₦${product.price.toStringAsFixed(2)}',
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
    );
  }
}
