// lib/features/search/presentation/widgets/horizontal_shop_list.dart
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/search/models/unified_search_result.dart';
import 'package:nano_embryo/presentation/features/search/presentation/widgets/category_header.dart';
import 'package:nano_embryo/presentation/features/search/presentation/widgets/category_result_card.dart';

class HorizontalShopList extends StatelessWidget {
  final List<UnifiedSearchResult> shops;
  final VoidCallback onSeeAll;
  final Function(UnifiedSearchResult) onItemTap;

  const HorizontalShopList({
    super.key,
    required this.shops,
    required this.onSeeAll,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (shops.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(Spacing.md),
        CategoryHeader(
          title: loc.searchResultsShopsHeader,
          showSeeAll: shops.length > 4,
          onPressed: onSeeAll,
        ),

        Gap(Spacing.sm.h),
        CardInkWell(
          onTap: () {},
          margin: EdgeInsets.only(bottom: Spacing.sm.h),
          padding: EdgeInsets.symmetric(vertical: Spacing.md.h),
          child: SizedBox(
            height: 400.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
              itemCount: shops.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 250.w,
                  child: CategoryResultCard(
                    result: shops[index],
                    onTap: () => onItemTap(shops[index]),
                    isHorizontal: true,
                  ),
                );
              },
            ),
          ),
        ),
        Gap(Spacing.lg.h),
      ],
    );
  }
}
