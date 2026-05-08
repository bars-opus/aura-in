import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class CompactProfileSchimmer extends StatelessWidget {
  const CompactProfileSchimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
                children: [
                  ShopSchimmerSkeleton(
                    width: 50,
                    height: 50.h,
                    shape: BoxShape.circle,
                  ),
                  Gap(10.h),
                  Expanded(
                    child: Column(
                      children: [
                        ShopSchimmerSkeleton(height: 20.h),
                        Gap(5.h),
                        ShopSchimmerSkeleton(height: 20.h),
                      ],
                    ),
                  ),
                ],
              );
  }
}
