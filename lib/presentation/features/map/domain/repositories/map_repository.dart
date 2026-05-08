import 'package:nano_embryo/presentation/features/map/data/models/shop_location_dto.dart';

/// Abstract repository for map-related data operations.
/// Defines the contract for fetching shop locations from the data source.
abstract class MapRepository {
  /// Fetches shops within the specified viewport bounds.
  ///
  /// [north] - Northern latitude boundary
  /// [south] - Southern latitude boundary
  /// [east] - Eastern longitude boundary
  /// [west] - Western longitude boundary
  /// [limit] - Maximum number of shops to return (default: 100)
  ///
  /// Returns a list of [ShopLocationDTO] objects.
  ///

  Future<List<ShopLocationDTO>> getShopsInViewport({
    required double north,
    required double south,
    required double east,
    required double west,
    String? shopType,
    String? luxuryLevel,
    int limit = 100,
  });

  /// Fetches shops within a radius of a location.
  ///
  /// [latitude] - Center point latitude
  /// [longitude] - Center point longitude
  /// [radiusKm] - Search radius in kilometers (default: 10)
  /// [limit] - Maximum number of shops to return (default: 50)
  ///
  /// Returns a list of [ShopLocationDTO] objects with distanceKm populated.
  Future<List<ShopLocationDTO>> getShopsNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
    String? shopType,
    String? luxuryLevel,
    int limit = 50,
  });
}
