import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nano_embryo/core/map/domain/data_source/map_data_source.dart';
import 'package:nano_embryo/core/map/domain/entities/map_bounds.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';

/// Concrete `MapDataSource` that queries the existing
/// `get_shops_in_viewport` and `get_shops_nearby` Supabase RPC functions.
///
/// Translates rows into [MapPin] with shop-specific fields packed into
/// `pin.data` (`shop_type`, `luxury_level`). The engine never sees the
/// row structure directly.
class SupabaseShopMapDataSource implements MapDataSource {
  final SupabaseClient _client;

  SupabaseShopMapDataSource(this._client);

  @override
  Future<List<MapPin>> fetchInViewport({
    required MapBounds bounds,
    required Map<String, dynamic> filters,
    int limit = 100,
  }) async {
    final params = <String, dynamic>{
      'p_north': bounds.north,
      'p_south': bounds.south,
      'p_east': bounds.east,
      'p_west': bounds.west,
      'p_limit': limit,
    };

    final shopType = filters['shop_type'];
    if (shopType is String && shopType.isNotEmpty) {
      params['p_shop_type'] = shopType;
    }
    final luxuryLevel = filters['luxury_level'];
    if (luxuryLevel is String && luxuryLevel.isNotEmpty) {
      params['p_luxury_level'] = luxuryLevel;
    }

    try {
      final response =
          await _client.rpc('get_shops_in_viewport', params: params);
      return _rowsToPins(response);
    } on PostgrestException catch (e) {
      throw _wrap(e, 'get_shops_in_viewport');
    }
  }

  @override
  Future<List<MapPin>> fetchNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
    required Map<String, dynamic> filters,
    int limit = 50,
  }) async {
    final params = <String, dynamic>{
      'p_latitude': latitude,
      'p_longitude': longitude,
      'p_radius_km': radiusKm,
      'p_limit': limit,
    };

    final shopType = filters['shop_type'];
    if (shopType is String && shopType.isNotEmpty) {
      params['p_shop_type'] = shopType;
    }
    final luxuryLevel = filters['luxury_level'];
    if (luxuryLevel is String && luxuryLevel.isNotEmpty) {
      params['p_luxury_level'] = luxuryLevel;
    }

    try {
      final response = await _client.rpc('get_shops_nearby', params: params);
      return _rowsToPins(response);
    } on PostgrestException catch (e) {
      throw _wrap(e, 'get_shops_nearby');
    }
  }

  List<MapPin> _rowsToPins(dynamic response) {
    if (response == null || (response is List && response.isEmpty)) {
      return const [];
    }
    return (response as List).map((row) {
      final map = row as Map<String, dynamic>;
      return MapPin(
        id: map['id'] as String,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        data: {
          'shop_type': map['shop_type'],
          'luxury_level': map['luxury_level'],
        },
      );
    }).toList();
  }

  Exception _wrap(PostgrestException e, String op) {
    if (e.message.contains('permission denied')) {
      return Exception('Permission denied. Please check RLS policies.');
    }
    if (e.message.contains('does not exist')) {
      return Exception(
        'Database function $op not found. Please ensure migrations are applied.',
      );
    }
    return Exception('Database error in $op: ${e.message}');
  }
}
