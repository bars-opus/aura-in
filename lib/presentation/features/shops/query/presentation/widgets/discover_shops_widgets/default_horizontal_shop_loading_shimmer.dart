import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_schimmer_skeleton.dart';

class DefaultHorizontalShopLoadingShimmer extends StatelessWidget {
  final Widget header;
  final bool isSearchScreen;
  const DefaultHorizontalShopLoadingShimmer({
    super.key,
    required this.header,
    required this.isSearchScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(Spacing.lg.h),
        header,
        Gap(Spacing.md.h),
        SizedBox(
          height: 400.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
            itemCount: 3,
            separatorBuilder: (_, __) => Gap(Spacing.md.w),
            itemBuilder: (_, __) => ShopSchimmerSkeleton(width: 250.w),
          ),
        ),
      ],
    );
    
  }
}
