// lib/features/search/presentation/widgets/vertical_category_list.dart
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/search/domain/models/category_search_section.dart';
import 'package:nano_embryo/presentation/features/search/models/unified_search_result.dart';
import 'package:nano_embryo/presentation/features/search/presentation/widgets/category_header.dart';
import 'package:nano_embryo/presentation/features/search/presentation/widgets/category_result_card.dart';

class VerticalCategoryList extends StatelessWidget {
  final CategorySearchSection section;
  final VoidCallback onSeeAll;
  final Function(UnifiedSearchResult) onItemTap;

  const VerticalCategoryList({
    super.key,
    required this.section,
    required this.onSeeAll,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (section.results.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoryHeader(
          title: section.displayTitle,
          showSeeAll: section.showSeeAllButton,
          onPressed: onSeeAll,
        ),
        Gap(Spacing.sm.h),
        CardInkWell(
          color:
              section.category.displayName == 'Freelancers'
                  ? Colors.transparent
                  : null,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: Spacing.md.h),
          onTap: () {},
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
            itemCount: section.results.length,
            separatorBuilder: (_, __) => AppDivider(),
            itemBuilder: (context, index) {
              return CategoryResultCard(
                result: section.results[index],
                onTap: () => onItemTap(section.results[index]),
                isHorizontal: false,
              );
            },
          ),
        ),
        Gap(Spacing.lg.h),
      ],
    );
  }
}
