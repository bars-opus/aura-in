import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/custom_universal_tabs.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_schimmer_skeleton.dart';

class AnalyticsLoadingScreen extends StatelessWidget {
  const AnalyticsLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget _buildEmptyContent() {
      return ListView(
        children: [
          Gap(Spacing.md), // CustomUniversalTabs with local state approach
          CustomUniversalTabs(
            tabs: [
              TabItem(
                label: 'Revenue',
                icon: Icons.attach_money_outlined,
                selectedIcon: Icons.attach_money,
              ),
              TabItem(
                label: 'Services',
                icon: Icons.cut_outlined,
                selectedIcon: Icons.cut,
              ),
              TabItem(
                label: 'Workers',
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
              ),
            ],
            // Use local state approach
            selectedIndex: 0,
            onIndexChanged: (index) {},
            height: 70.h,
            iconSize: 25.sp,
            fontSize: 12.sp,
            showUnderline: true,
            showLabels: true,
            animateIconScale: true,
            showBottomBorder: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(Spacing.md.h),
              child: Column(
                children: [
                  Gap(Spacing.md),
                  ShopSchimmerSkeleton(height: 150.w),
                  Gap(Spacing.md),
                  ShopSchimmerSkeleton(height: 400.w),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return _buildEmptyContent();
  }
}
