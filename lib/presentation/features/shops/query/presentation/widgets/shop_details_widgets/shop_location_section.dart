// lib/features/shops/presentation/widgets/shop_details/shop_location_section.dart
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/shop.dart';

class ShopLocationSection extends StatelessWidget {
  final Shop shop;

  const ShopLocationSection({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),

        Gap(Spacing.md.h),

        // Map placeholder
        Container(
          height: 150.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.map,
                  size: 50.sp,
                  color: colorScheme.primary.withOpacity(0.3),
                ),
              ),
              Positioned(
                bottom: Spacing.md.h,
                left: Spacing.md.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.sm.w,
                    vertical: Spacing.xs.h,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16.sp,
                        color: colorScheme.primary,
                      ),
                      Gap(Spacing.xs.w),
                      Text(
                        'View on map',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Gap(Spacing.md.h),

        // Address
        Row(
          children: [
            Icon(Icons.location_on, size: 20.sp, color: colorScheme.primary),
            Gap(Spacing.sm.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (shop.address != null) ...[
                    Text(
                      shop.address!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Gap(Spacing.xs.h),
                  ],
                  Text(
                    '${shop.city ?? ''}, ${shop.country ?? ''}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        Gap(Spacing.md.h),

        // Get directions button
        OutlinedButton.icon(
          onPressed: () {
            // Open maps
          },
          icon: const Icon(Icons.directions),
          label: const Text('Get Directions'),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, 48.h),
          ),
        ),
      ],
    );
  }
}
