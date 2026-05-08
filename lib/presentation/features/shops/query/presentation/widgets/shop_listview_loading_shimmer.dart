import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class ShopListviewLoadingShimmer extends StatelessWidget {
  const ShopListviewLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: Spacing.sm.w),
      itemCount: 10,
      separatorBuilder: (_, __) => Gap(Spacing.md.w),
      itemBuilder: (_, __) => ShopSchimmerSkeleton(),
    );
  }
}
