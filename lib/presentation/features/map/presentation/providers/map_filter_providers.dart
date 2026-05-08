import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Selected shop type category for map filtering
final selectedMapCategoryProvider = StateProvider<String?>((ref) => null); // null = "all"

/// Selected luxury level for map filtering
final selectedMapLuxuryProvider = StateProvider<String?>((ref) => null); // null = "all"

/// Combined map filters
final mapFiltersProvider = Provider<MapFilters>((ref) {
  final category = ref.watch(selectedMapCategoryProvider);
  final luxury = ref.watch(selectedMapLuxuryProvider);
  return MapFilters(
    shopType: category == 'all' ? null : category,
    luxuryLevel: luxury == 'all' ? null : luxury,
  );
});

class MapFilters {
  final String? shopType;
  final String? luxuryLevel;

  const MapFilters({this.shopType, this.luxuryLevel});

  bool get hasFilters => shopType != null || luxuryLevel != null;

  @override
  String toString() => 'MapFilters(shopType: $shopType, luxuryLevel: $luxuryLevel)';
}
