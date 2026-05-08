// lib/features/shops/presentation/widgets/shop_details/shop_gallery_section.dart

import 'package:flutter/material.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/shop.dart';

class ShopGallerySection extends StatelessWidget {
  final Shop shop;

  const ShopGallerySection({
    super.key,
    required this.shop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gallery',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Show full gallery
              },
              child: const Text('View All'),
            ),
          ],
        ),
        
        Gap(Spacing.md.h),
        
        SizedBox(
          height: 150.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 5, // Placeholder
            separatorBuilder: (_, __) => Gap(Spacing.md.w),
            itemBuilder: (context, index) {
              return _buildGalleryImage(context, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryImage(BuildContext context, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 200.w,
        color: Colors.grey.shade300,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (index == 0 && shop.shopLogoUrl != null)
              Image.network(
                shop.shopLogoUrl!,
                fit: BoxFit.cover,
              )
            else
              Container(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.image,
                  size: 40.sp,
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
            if (index == 4)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Text(
                    '+5 more',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
