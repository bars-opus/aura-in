// lib/features/shop/context/providers/shop_context_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/auth_providers.dart';
import 'package:nano_embryo/core/providers/shared_prefs_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_details_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_list_item_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_repository_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for the list of shops owned by the current user
final userShopsProvider = FutureProvider<List<ShopListItemDTO>>((ref) async {
  final profileId = ref.watch(currentProfileIdProvider);
  if (profileId == null) return [];
  final repository = ref.watch(shopRepositoryProvider);
  return repository.getShopsByProfileId(profileId);
});

/// Provider for the currently selected/active shop
final currentShopProvider = StateProvider<ShopDetailsDTO?>((ref) => null);

/// Persists the owner's active shop between app launches. The stored ID is
/// always validated against [userShopsProvider] before it is used.
final ownerShopPreferenceProvider = Provider<OwnerShopPreference>((ref) {
  return OwnerShopPreference(ref.watch(sharedPreferencesProvider));
});

class OwnerShopPreference {
  static const _key = 'active_shop_id';

  final SharedPreferences _preferences;

  const OwnerShopPreference(this._preferences);

  String? get selectedShopId => _preferences.getString(_key);

  Future<void> save(String shopId) => _preferences.setString(_key, shopId);
}

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
final shopByIdProvider = FutureProvider.family<ShopDetailsDTO?, String>((
  ref,
  shopId,
) async {
  final repository = ref.watch(shopRepositoryProvider);
  return repository.getShopDetailsById(shopId);
});
