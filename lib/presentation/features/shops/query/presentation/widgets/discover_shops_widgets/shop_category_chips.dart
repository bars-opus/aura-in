// lib/features/shops/presentation/widgets/shop_category_chips.dart

import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class ShopCategoryChips extends ConsumerWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const ShopCategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(shopTypeListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return typesAsync.when(
      data: (types) {
        if (types.isEmpty) {
          return const SizedBox.shrink();
        }

        // Define all possible categories your platform supports
        final allCategories = [
          'salon',
          'barbershop',
          'spa',
          'nail_salon',
          'lash_studio',
          'waxing',
          'massage',
          'makeup',
          'skincare',
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
              child: Text(
                'SHOP TYPES',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Gap(Spacing.sm.h),
            SizedBox(
              height: 48.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allCategories.length,
                padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
                itemBuilder: (context, index) {
                  final categoryType = allCategories[index];

                  // Find if this category exists in the database and get its count
                  final existingType = types.firstWhere(
                    (t) => t.shopType == categoryType,
                    orElse:
                        () => ShopTypeCount(shopType: categoryType, count: 0),
                  );

                  final hasShops = existingType.count > 0;
                  final isSelected = categoryType == selectedCategory;
                  final displayName = _formatCategoryName(categoryType);

                  return Padding(
                    padding: EdgeInsets.only(right: Spacing.sm.w),
                    child: FilterChip(
                      label: Text(
                        displayName,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : (hasShops
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurface.withOpacity(0.3)),
                          fontWeight: isSelected ? FontWeight.w600 : null,
                        ),
                      ),
                      selected: isSelected,
                      onSelected:
                          hasShops
                              ? (_) => onCategorySelected(categoryType)
                              : null, // Disabled if no shops
                      backgroundColor:
                          hasShops
                              ? (isSelected
                                  ? colorScheme.primary
                                  : Colors.grey.shade100)
                              : Colors.grey.shade100.withOpacity(0.3),
                      selectedColor: colorScheme.primary,
                      showCheckmark: false,
                      avatar:
                          hasShops
                              ? CircleAvatar(
                                radius: 10.r,
                                backgroundColor:
                                    isSelected
                                        ? Colors.white.withOpacity(0.2)
                                        : colorScheme.primary.withOpacity(0.1),
                                child: Text(
                                  '${existingType.count}',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                              : CircleAvatar(
                                radius: 10.r,
                                backgroundColor: Colors.grey.withOpacity(0.1),
                                child: Text(
                                  '0',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.md.w,
                        vertical: Spacing.sm.h,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => _buildLoadingShimmer(),
      error:
          (error, stack) => Center(
            child: Text(
              'Error loading categories: $error',
              style: TextStyle(color: Colors.red),
            ),
          ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
          child: Container(
            width: 80.w,
            height: 16.h,
            color: Colors.grey.shade300,
          ),
        ),
        Gap(Spacing.sm.h),
        SizedBox(
          height: 48.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: Spacing.sm.w),
                child: Container(
                  width: 80.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatCategoryName(String type) {
    switch (type) {
      case 'salon':
        return 'Salons';
      case 'barbershop':
        return 'Barbers';
      case 'spa':
        return 'Spas';
      case 'nail_salon':
        return 'Nail Shops';
      case 'lash_studio':
        return 'Lash Studios';
      case 'waxing':
        return 'Waxing';
      case 'massage':
        return 'Massage';
      case 'makeup':
        return 'Makeup';
      case 'skincare':
        return 'Skincare';
      default:
        return type
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }
}
