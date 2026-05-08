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
                  return FilterChip(
                    label: Text('All'),
                    selected: selectedCategory == null,
                    onSelected: (_) => onCategorySelected(null),
                  );
                }

                final category = ProductCategory.values[index - 1];
                return FilterChip(
                  label: Text(category.displayName),
                  selected: selectedCategory == category.name,
                  onSelected: (_) => onCategorySelected(category.name),
                );
              },
            ),
          ),

          SizedBox(width: 8.w),

          // Filter button
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: IconButton(
              icon: Icon(Icons.filter_list, size: 20.w),
              onPressed: onFilterPressed,
              padding: EdgeInsets.all(8.w),
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }
}
