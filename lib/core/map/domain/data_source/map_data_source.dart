import 'package:nano_embryo/core/map/domain/entities/map_bounds.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';

/// Abstract adapter the engine calls to fetch pins.
///
/// Each app provides one concrete implementation (e.g.
/// `SupabaseShopMapDataSource`) and references it from `MapConfig`.
/// The engine itself never knows what backend or what entity shape
/// is being queried — it only consumes [MapPin] lists.
///
/// The `filters` map is assembled by the engine from
/// `MapFilterSchema`'s primary/secondary selections. Adapters pull
/// the keys they recognise (e.g. `filters['shop_type']`) and ignore
/// the rest.
abstract class MapDataSource {
  Future<List<MapPin>> fetchInViewport({
    required MapBounds bounds,
    required Map<String, dynamic> filters,
    int limit = 100,
  });

  Future<List<MapPin>> fetchNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
    required Map<String, dynamic> filters,
    int limit = 50,
  });
}
