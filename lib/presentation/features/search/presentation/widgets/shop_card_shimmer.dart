// lib/features/search/presentation/widgets/shop_card_shimmer.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ShopCardShimmer extends StatelessWidget {
  final String category;
  const ShopCardShimmer({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color valueColor = Colors.black.withOpacity(.2);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colorScheme.onBackground.withOpacity(.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.2),
              shape:
                  category == 'Products' ? BoxShape.rectangle : BoxShape.circle,
              borderRadius:
                  category == 'Products' ? BorderRadius.circular(8.r) : null,
            ),
          ),
          Gap(12.w),

          // Text placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: valueColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Gap(8.h),
                Container(
                  width: 100.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: valueColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Gap(8.h),
                if (category != 'Profiles')
                  Container(
                    width: 80.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: valueColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
