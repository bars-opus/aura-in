// lib/features/shops/presentation/widgets/category_bottom_sheet.dart
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';


class CategoryBottomSheet extends StatelessWidget {
  final List<ShopTypeCount> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryBottomSheet({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(Spacing.lg.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Gap(Spacing.lg.h),
          Text(
            'All Shop Types',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap(Spacing.md.h),
          ...categories.map((category) {
            final isSelected = category.shopType == selectedCategory;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isSelected 
                    ? colorScheme.primary 
                    : colorScheme.primary.withOpacity(0.1),
                child: Text(
                  category.count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                category.shopType,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: isSelected 
                  ? Icon(Icons.check, color: colorScheme.primary)
                  : null,
              onTap: () => onCategorySelected(category.shopType),
            );
          }).toList(),
        ],
      ),
    );
  }
}
