import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/core/utils/constants.dart';
import 'package:nano_embryo/core/widgets/shop_category_tabs.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/selected_luxury_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/service_category_provider.dart';

class ServiceCategoryTabs extends ConsumerWidget {
  const ServiceCategoryTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(serviceCategoryListProvider);
    final selectedCategory = ref.watch(selectedServiceCategoryProvider);

    return categoriesAsync.when(
      data: (categories) {
        return ShopCategoryTabs(
          categories: AppConstants.shopCategories,
          selectedCategory: selectedCategory,
          onCategorySelected: (category) {
            // Update filter state only. shopListProvider watches
            // selectedServiceCategoryProvider and will auto-reload.
            ref
                .read(selectedServiceCategoryProvider.notifier)
                .selectCategory(category ?? '');
            // Reset luxury selection — levels are category-specific.
            ref.read(selectedLuxuryLevelProvider.notifier).selectLuxury(null);
          },
          isLoading: false,
          tabWidth: 90.w,
          containerHeight: 45.h,
          showBottomBorder: true,
        );
      },
      loading: () => ShopCategoryTabs(
        categories: AppConstants.shopCategories,
        selectedCategory: selectedCategory,
        onCategorySelected: (_) {},
        isLoading: true,
        tabWidth: 90.w,
        containerHeight: 43.h,
        showBottomBorder: true,
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
