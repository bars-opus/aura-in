// lib/features/shops/presentation/widgets/shop_details/shop_info_section.dart
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/shop.dart';

class ShopInfoSection extends StatelessWidget {
  final Shop shop;

  const ShopInfoSection({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),

        Gap(Spacing.md.h),

        // Overview
        if (shop.overview != null) ...[
          Text(shop.overview!, style: textTheme.bodyLarge),
          Gap(Spacing.md.h),
        ],

        // Quick info cards
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: Spacing.md.w,
          mainAxisSpacing: Spacing.md.h,
          childAspectRatio: 1.5,
          children: [
            _buildInfoCard(
              context,
              icon: Icons.location_on,
              label: 'Location',
              value: shop.city ?? 'Unknown',
            ),
            _buildInfoCard(
              context,
              icon: Icons.access_time,
              label: 'Opens',
              value: '9:00 AM', // We'll add later
            ),
            _buildInfoCard(
              context,
              icon: Icons.currency_exchange,
              label: 'Currency',
              value: shop.currency ?? 'USD',
            ),
            _buildInfoCard(
              context,
              icon: Icons.people,
              label: 'Workers',
              value: '8', // We'll add later
            ),
          ],
        ),

        Gap(Spacing.md.h),

        // Terms
        if (shop.terms != null) ...[
          Divider(),
          Gap(Spacing.md.h),
          Text(
            'Terms & Policies',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Gap(Spacing.sm.h),
          Text(
            shop.terms!,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(Spacing.sm.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16.sp, color: colorScheme.primary),
          Gap(Spacing.xs.h),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
