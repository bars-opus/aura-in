// lib/features/shops/presentation/widgets/shop_details/workers_section.dart

import 'package:flutter/material.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/shop.dart';

class ShopWorkersSection extends StatelessWidget {
  final Shop shop;

  const ShopWorkersSection({
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
              'Our Team',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Show all workers
              },
              child: const Text('View All'),
            ),
          ],
        ),
        
        Gap(Spacing.md.h),
        
        SizedBox(
          height: 120.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 5, // Placeholder
            separatorBuilder: (_, __) => Gap(Spacing.md.w),
            itemBuilder: (context, index) {
              return _buildWorkerCard(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWorkerCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: 100.w,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 30.sp,
              color: colorScheme.primary,
            ),
          ),
          Gap(Spacing.xs.h),
          Text(
            'Sarah',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Senior Stylist',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
