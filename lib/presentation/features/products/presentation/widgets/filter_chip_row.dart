// lib/features/products/presentation/widgets/filter_chip_row.dart

import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';

class FilterChipRow extends StatelessWidget {
  final String? selectedCategory;
  final void Function(String?) onCategorySelected;
  final VoidCallback onFilterPressed;

  const FilterChipRow({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          // Categories
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ProductCategory.values.length + 1,
              separatorBuilder: (context, index) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                if (index == 0) {
                  // "All" chip
                  return AppFilterChip(
                    label: 'All',
                    selected: selectedCategory == null,
                    onSelected: (_) => onCategorySelected(null),
                    backgroundColor: colorScheme.background,
                    labelColor: colorScheme.onBackground,
                    borderWidth: 0.1,

                    // fontSize: ,
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.sm.w,
                      vertical: Spacing.xs.h,
                    ),
                  );
                }

                final category = ProductCategory.values[index - 1];
                return AppFilterChip(
                  label: category.displayName,
                  selected: selectedCategory == category.name,
                  onSelected: (_) => onCategorySelected(category.name),
                  backgroundColor: colorScheme.background,
                  labelColor: colorScheme.onBackground,
                  borderWidth: 0.1,

                  // fontSize: ,
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.sm.w,
                    vertical: Spacing.xs.h,
                  ),
                );

                // FilterChip(
                //   label: Text(category.displayName),
                //   selected: selectedCategory == category.name,
                //   onSelected: (_) => onCategorySelected(category.name),
                // );
              },
            ),
          ),

          SizedBox(width: 8.w),

          // Filter button
          AppIconButton(icon: Icons.filter_list, onPressed: onFilterPressed),
        ],
      ),
    );
  }
}
