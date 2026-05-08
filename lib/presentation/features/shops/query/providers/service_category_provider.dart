// lib/features/discover/providers/service_category_provider.dart
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'service_category_provider.g.dart';

/// Provider for service categories (salon, barbers, spa, etc.)
@riverpod
Future<List<ShopTypeCount>> serviceCategoryList(ServiceCategoryListRef ref) {
  final repository = ref.watch(shopRepositoryProvider);
  return repository.getShopTypeCounts();
}

/// Current selected service category
@riverpod
class SelectedServiceCategory extends _$SelectedServiceCategory {
  @override
  String build() {
    // Default to 'salon' or most popular
    return 'salon';
  }

  void selectCategory(String category) {
    state = category;
  }
}
