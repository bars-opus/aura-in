// lib/features/booking/presentation/widgets/service_selection/service_category_chips.dart
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

/// Horizontal scrollable category chips for filtering services.
///
/// Similar to your ShopCategoryChips pattern, but for service categories.
///
/// ## Features
/// - Horizontal scrolling
/// - Active category highlighting
/// - "All" category included by default
/// - Smooth animations on selection
///
/// ## Usage
/// ```dart
/// ServiceCategoryChips(
///   categories: ['Haircuts', 'Beard', 'Color', 'Treatments'],
///   selectedCategory: selectedCategory,
///   onCategorySelected: (category) => updateCategory(category),
/// )
/// ```
class ServiceCategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final bool showAllOption;

  const ServiceCategoryChips({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.showAllOption = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final allCategories = showAllOption ? ['All', ...categories] : categories;

    return SizedBox(
      height: 48.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final isSelected = category == selectedCategory;

          return AnimatedScaleFade(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            child: Padding(
              padding: EdgeInsets.only(right: Spacing.sm.w),
              child: AppFilterChip(
                label: category,
                borderRadius: BorderRadius.circular(10.r),
                selected: isSelected,
                onSelected: (_) => onCategorySelected(category),
                selectedColor: colorScheme.primary,
                backgroundColor: colorScheme.surfaceVariant,

                labelColor:
                    isSelected ? colorScheme.primary : colorScheme.onSurface,
                borderWidth: 0.3,
              ),
            ),
          );
        },
      ),
    );
  }
}
