// lib/features/shops/presentation/providers/shop_type_provider.dart

import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shop_type_provider.g.dart';

/// Provider that fetches all available shop types with their counts
@riverpod
Future<List<ShopTypeCount>> shopTypeList(ShopTypeListRef ref) {
  final repository = ref.watch(shopRepositoryProvider);
  return repository.getShopTypeCounts();
}
