// Loading list with shimmer
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/search/models/search_category.dart';
import 'package:nano_embryo/presentation/features/search/presentation/widgets/category_header.dart';
import 'package:nano_embryo/presentation/features/search/presentation/widgets/shop_card_shimmer.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/discover_shops_widgets/default_horizontal_shop_loading_shimmer.dart';

class SearchLoadingShimmer extends StatelessWidget {
  /// Null = "All" view (mixed sections); otherwise a single-category view.
  final SearchCategory? selectedCategory;

  const SearchLoadingShimmer({super.key, this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    // "All" view renders the same vertical/horizontal split as results:
    // a horizontal shop carousel on top, then a vertical list below.
    if (selectedCategory == null) {
      return Column(
        children: [
          DefaultHorizontalShopLoadingShimmer(
            header: CategoryHeader(
              title: 'Shop',
              body: '',
              showSeeAll: false,
              onPressed: () {},
            ),
            isSearchScreen: true,
          ),
          Gap(Spacing.md.h),
          CategoryHeader(
            title: 'Profile',
            body: '',
            showSeeAll: false,
            onPressed: () {},
          ),
          Expanded(child: _verticalShimmer(wrapInCard: false)),
        ],
      );
    }

    // Single-category view: match the wrapper VerticalCategoryList uses.
    // Freelancers renders on a transparent CardInkWell; Profiles/Shops use
    // the default surface color.

    return _verticalShimmer(wrapInCard: true);
  }

  Widget _verticalShimmer({required bool wrapInCard}) {
    final list = ListView.builder(
      padding: EdgeInsets.all(Spacing.sm.h),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: Spacing.xs.h),
          child:
              selectedCategory == SearchCategory.shops
                  ? const ShopSchimmerSkeleton()
                  : ShopCardShimmer(
                    category: selectedCategory?.displayName ?? '',
                  ),
        );
      },
    );

    if (!wrapInCard) return list;

    return CardInkWell(
      elevation: 0,
      color: Colors.transparent,
      padding: const EdgeInsets.all(0),
      onTap: () {},
      child: list,
    );
  }
}
