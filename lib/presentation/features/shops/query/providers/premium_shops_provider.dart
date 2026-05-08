import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'premium_shops_provider.g.dart';

// In premium_shops_provider.dart
@riverpod
Future<List<ShopListItemDTO>> premiumShops(PremiumShopsRef ref) {
  final shopType = ref.watch(selectedServiceCategoryProvider);
  final selectedLuxury = ref.watch(selectedLuxuryLevelProvider);
  final userLocation = ref.watch(userLocationNotifierProvider); // 👈 Get location
  final repository = ref.watch(shopRepositoryProvider);
  
  return repository.getPremiumShops(
    shopType: shopType,
    luxuryLevel: selectedLuxury,
    userLocation: userLocation, // 👈 Pass it to repository
    limit: 10,
  );
}
