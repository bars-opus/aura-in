import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_list_item_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_repository_provider.dart';

// ✅ New provider for fetching shop details by ID with caching
final mapShopProvider = FutureProvider.family<ShopListItemDTO, String>((
  ref,
  shopId,
) async {
  final repository = ref.watch(shopRepositoryProvider);
  return await repository.getMarkerShopDetails(shopId);
});
