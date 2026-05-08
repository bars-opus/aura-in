import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'near_you_shops_provider.g.dart';

@riverpod
Future<List<ShopListItemDTO>> nearYouShops(NearYouShopsRef ref) {
  final userLocation = ref.watch(userLocationNotifierProvider);

  // If no location set, return empty list
  if (userLocation == null) {
    return Future.value([]);
  }

  final repository = ref.watch(shopRepositoryProvider);

  return repository.getNearbyShops(
    latitude: userLocation.latitude,
    longitude: userLocation.longitude,
    radiusKm: 10.0,
    limit: 10,
  );
}
