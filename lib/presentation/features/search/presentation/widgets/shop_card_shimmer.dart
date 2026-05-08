// lib/features/search/presentation/widgets/shop_card_shimmer.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShopCardShimmer extends StatelessWidget {
  const ShopCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            width: 70.w,
            height: 70.h,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          SizedBox(width: 12.w),

          // Text placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16.h,
                  color: Colors.grey,
                ),
                SizedBox(height: 8.h),
                Container(width: 100.w, height: 12.h, color: Colors.grey),
                SizedBox(height: 8.h),
                Container(width: 80.w, height: 10.h, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Loading list with shimmer
class SearchLoadingShimmer extends StatelessWidget {
  const SearchLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) => const ShopCardShimmer(),
    );
  }
}
