import 'package:nano_embryo/presentation/features/map/data/models/shop_location_dto.dart';
import 'package:nano_embryo/presentation/features/map/domain/repositories/map_repository.dart';
import 'package:nano_embryo/presentation/features/map/presentation/data/datasources/supabase_map_datasource.dart';

/// Implementation of MapRepository using Supabase as the data source.
class MapRepositoryImpl implements MapRepository {
  final SupabaseMapDataSource _dataSource;

  MapRepositoryImpl(this._dataSource);

  @override
  Future<List<ShopLocationDTO>> getShopsInViewport({
    required double north,
    required double south,
    required double east,
    required double west,
    String? shopType,
    String? luxuryLevel,
    int limit = 100,
  }) async {
    // Validate bounds
    if (north <= south) {
      throw ArgumentError('North must be greater than south');
    }
    if (east <= west) {
      throw ArgumentError('East must be greater than west');
    }
    if (limit <= 0 || limit > 500) {
      throw ArgumentError('Limit must be between 1 and 500');
    }

    return await _dataSource.getShopsInViewport(
      north: north,
      south: south,
      east: east,
      west: west,
      shopType: shopType,
      luxuryLevel: luxuryLevel,
      limit: limit,
    );
  }

  @override
  Future<List<ShopLocationDTO>> getShopsNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
    String? shopType,
    String? luxuryLevel,
    int limit = 50,
  }) async {
    // Validate inputs
    if (latitude < -90 || latitude > 90) {
      throw ArgumentError('Latitude must be between -90 and 90');
    }
    if (longitude < -180 || longitude > 180) {
      throw ArgumentError('Longitude must be between -180 and 180');
    }
    if (radiusKm <= 0 || radiusKm > 100) {
      throw ArgumentError('Radius must be between 0.1 and 100 km');
    }
    if (limit <= 0 || limit > 200) {
      throw ArgumentError('Limit must be between 1 and 200');
    }

    return await _dataSource.getShopsNearby(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      shopType: shopType,
      luxuryLevel: luxuryLevel,
      limit: limit,
    );
  }
}
