import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'top_rated_shops_provider.g.dart';

@riverpod
Future<List<ShopListItemDTO>> topRatedShops(TopRatedShopsRef ref) {
  final shopType = ref.watch(selectedServiceCategoryProvider);
  final repository = ref.watch(shopRepositoryProvider);
  return repository.getTopRatedShops(shopType: shopType, limit: 10);
}
