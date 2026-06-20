import 'package:nano_embryo/presentation/features/discover/providers/discovery_seed_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/search_radius_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'near_you_shops_provider.g.dart';

@riverpod
Future<List<ShopListItemDTO>> nearYouShops(NearYouShopsRef ref) {
  final userLocation = ref.watch(userLocationNotifierProvider);

  if (userLocation == null) {
    return Future.value([]);
  }

  final repository = ref.watch(shopRepositoryProvider);
  // Watch radius so this provider re-runs when the slider commits.
  final radiusKm = ref.watch(searchRadiusKmProvider);
  final seed = ref.watch(discoverySeedProvider);

  return repository.getNearbyShops(
    latitude: userLocation.latitude,
    longitude: userLocation.longitude,
    radiusKm: radiusKm,
    limit: 10,
    seed: seed,
  );
}
