import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nano_embryo/presentation/features/map/data/models/shop_location_dto.dart';

class SupabaseMapDataSource {
  final SupabaseClient _client;

  SupabaseMapDataSource(this._client);

  /// Calls the get_shops_in_viewport Supabase function.
  Future<List<ShopLocationDTO>> getShopsInViewport({
    required double north,
    required double south,
    required double east,
    required double west,
    String? shopType,
    String? luxuryLevel,
    required int limit,
  }) async {
    try {
      // ✅ Use Map<String, dynamic> to accept both num and string values
      final Map<String, dynamic> params = {
        'p_north': north,
        'p_south': south,
        'p_east': east,
        'p_west': west,
        'p_limit': limit,
      };

      // Add optional filters if provided
      if (shopType != null && shopType.isNotEmpty) {
        params['p_shop_type'] = shopType;
      }
      if (luxuryLevel != null && luxuryLevel.isNotEmpty) {
        params['p_luxury_level'] = luxuryLevel;
      }

      final response = await _client.rpc(
        'get_shops_in_viewport',
        params: params,
      );

      if (response == null || response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => ShopLocationDTO.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw _handlePostgrestError(e, 'get_shops_in_viewport');
    } catch (e) {
      throw MapDataSourceException(
        message: 'Unexpected error fetching shops in viewport',
        originalError: e,
      );
    }
  }

  /// Calls the get_shops_nearby Supabase function.
  Future<List<ShopLocationDTO>> getShopsNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? shopType,
    String? luxuryLevel,
    required int limit,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'p_latitude': latitude,
        'p_longitude': longitude,
        'p_radius_km': radiusKm,
        'p_limit': limit,
      };

      if (shopType != null && shopType.isNotEmpty) {
        params['p_shop_type'] = shopType;
      }
      if (luxuryLevel != null && luxuryLevel.isNotEmpty) {
        params['p_luxury_level'] = luxuryLevel;
      }

      final response = await _client.rpc('get_shops_nearby', params: params);

      if (response == null || response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => ShopLocationDTO.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw _handlePostgrestError(e, 'get_shops_nearby');
    } catch (e) {
      print(e);
      throw MapDataSourceException(
        message: 'Unexpected error fetching shops nearby',
        originalError: e,
      );
    }
  }

  MapDataSourceException _handlePostgrestError(
    PostgrestException e,
    String operation,
  ) {
    print('Supabase error in $operation: ${e.message}');

    if (e.message?.contains('permission denied') ?? false) {
      return MapDataSourceException(
        message: 'Permission denied. Please check RLS policies.',
        originalError: e,
      );
    }

    if (e.message?.contains('does not exist') ?? false) {
      return MapDataSourceException(
        message:
            'Database function not found. Please ensure migrations are applied.',
        originalError: e,
      );
    }

    return MapDataSourceException(
      message: 'Database error: ${e.message}',
      originalError: e,
    );
  }
}

class MapDataSourceException implements Exception {
  final String message;
  final dynamic originalError;

  MapDataSourceException({required this.message, this.originalError});

  @override
  String toString() => 'MapDataSourceException: $message';
}
