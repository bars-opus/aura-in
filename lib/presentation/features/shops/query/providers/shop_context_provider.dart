// lib/features/shop/context/providers/shop_context_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/auth_providers.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_details_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_list_item_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_repository_provider.dart';

/// Provider for the list of shops owned by the current user
final userShopsProvider = FutureProvider<List<ShopListItemDTO>>((ref) async {
  final profileId = ref.watch(currentProfileIdProvider);
  if (profileId == null) return [];
  final repository = ref.watch(shopRepositoryProvider);
  return repository.getShopsByProfileId(profileId);
});

/// Provider for the currently selected/active shop
final currentShopProvider = StateProvider<ShopDetailsDTO?>((ref) => null);

/// Provider for current shop ID (convenience)
final currentShopIdProvider = Provider<String?>((ref) {
  return ref.watch(currentShopProvider)?.id;
});

/// Provider to check if user has multiple shops
final hasMultipleShopsProvider = FutureProvider<bool>((ref) async {
  final shops = await ref.watch(userShopsProvider.future);
  return shops.length > 1;
});

/// Provider to get a shop by ID
final shopByIdProvider = FutureProvider.family<ShopDetailsDTO?, String>((ref, shopId) async {
  final repository = ref.watch(shopRepositoryProvider);
  return repository.getShopDetailsById(shopId);
});
