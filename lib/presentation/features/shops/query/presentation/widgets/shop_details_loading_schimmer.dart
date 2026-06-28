import 'package:flutter/widgets.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/compact_profile_schimmer.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_image_pageview.dart';

class ShopDetailsLoadingSchimmer extends StatelessWidget {
  final String coverImageUrl;
  const ShopDetailsLoadingSchimmer({super.key, required this.coverImageUrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 460.h,
                  width: double.infinity,
                  child: ShopImagePageview(shopImageUrls: [coverImageUrl]),
                ),
                Positioned(
                  top: 60.h,
                  left: 10.h,
                  child: AppIconButton(
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: colorScheme.background.withOpacity(.6),
                    icon: Icons.close,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.md),
              child: Column(
                children: [
                  Gap(20.h),
                  CompactProfileSchimmer(),
                  Gap(20.h),
                  ShopSchimmerSkeleton(height: 20.h),
                  Gap(5.h),
                  ShopSchimmerSkeleton(height: 20.h),
                  Gap(5.h),
                  ShopSchimmerSkeleton(height: 20.h),
                  Gap(20.h),
                  ShopSchimmerSkeleton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
