// lib/features/shops/presentation/widgets/shop_details/shop_services_section.dart
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/shop.dart';

class ShopServicesSection extends StatelessWidget {
  final Shop shop;

  const ShopServicesSection({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Services',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Show all services
              },
              child: const Text('View All'),
            ),
          ],
        ),

        Gap(Spacing.md.h),

        // Service list - We'll add real data later
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4, // Placeholder
          separatorBuilder: (_, __) => Divider(height: 1.h),
          itemBuilder: (context, index) {
            return _buildServiceItem(context);
          },
        ),
      ],
    );
  }

  Widget _buildServiceItem(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.content_cut,
              color: colorScheme.primary,
              size: 20.sp,
            ),
          ),
          Gap(Spacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Women\'s Haircut',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '45 min',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$75',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                'starting from',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
