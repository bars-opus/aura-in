import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/horizontal_category_tabs.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/selected_luxury_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/service_category_provider.dart';

class ServiceCategoryTabs extends ConsumerWidget {
  const ServiceCategoryTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(serviceCategoryListProvider);
    final selectedCategory = ref.watch(selectedServiceCategoryProvider);

    return categoriesAsync.when(
      data: (counts) {
        final hasShopsMap = {
          for (final c in counts) c.shopType: c.count > 0,
        };
        return HorizontalCategoryTabs(
          categories: AppConstants.shopCategories,
          selectedCategory: selectedCategory,
          hasShopsMap: hasShopsMap,
          onCategorySelected: (category) {
            ref
                .read(selectedServiceCategoryProvider.notifier)
                .selectCategory(category ?? '');
            ref.read(selectedLuxuryLevelProvider.notifier).selectLuxury(null);
          },
          tabWidth: 90.w,
          containerHeight: 45.h,
          showBottomBorder: true,
        );
      },
      loading: () => HorizontalCategoryTabs(
        categories: AppConstants.shopCategories,
        selectedCategory: selectedCategory,
        onCategorySelected: (_) {},
        isLoading: true,
        tabWidth: 90.w,
        containerHeight: 45.h,
        showBottomBorder: true,
      ),
      error: (_, __) => HorizontalCategoryTabs(
        categories: AppConstants.shopCategories,
        selectedCategory: selectedCategory,
        onCategorySelected: (_) {},
        isLoading: true,
        tabWidth: 90.w,
        containerHeight: 45.h,
        showBottomBorder: true,
      ),
    );
  }
}
