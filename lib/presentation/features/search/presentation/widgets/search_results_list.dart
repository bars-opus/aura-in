// lib/features/search/presentation/widgets/search_results_list.dart
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/search/models/shop_search_result.dart';
import 'package:nano_embryo/presentation/features/search/presentation/widgets/shop_result_card.dart';

class SearchResultsList extends StatelessWidget {
  final List<ShopSearchResult> results;
  final Function(ShopSearchResult)? onResultTap;
  final ScrollController? scrollController;
  final bool hasMore;
  final bool isLoadingMore;

  const SearchResultsList({
    super.key,
    required this.results,
    this.onResultTap,
    this.scrollController,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(Spacing.md.h),
      itemCount: results.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == results.length) {
          // Show loading indicator at the bottom
          return Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.md.h),
            child: Center(child: CircularLoadingIndicator()),
          );
        }

        final result = results[index];
        return Padding(
          padding: EdgeInsets.only(bottom: Spacing.sm.h),
          child: ShopResultCard(
            shop: result,
            onTap: onResultTap != null ? () => onResultTap!(result) : null,
          ),
        );
      },
    );
  }
}
