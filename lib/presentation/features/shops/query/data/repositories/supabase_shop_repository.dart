// lib/features/shops/data/repositories/supabase_shop_repository.dart
import 'package:nano_embryo/presentation/features/search/models/search_paginated_result.dart';
import 'package:nano_embryo/presentation/features/search/models/shop_query_params.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_details_dto.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/data/models/booking_review.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class SupabaseShopRepository implements ShopRepository {
  final SupabaseClient _client;

  SupabaseShopRepository(this._client);

  // ==================== HELPER METHODS ====================

  /// Removes duplicate shops by id, preserving first-occurrence order.
  ///
  /// Guards against two sources of duplicates:
  ///   1. The shops_with_cover view producing multiple rows per shop when its
  ///      underlying JOIN matches more than one media row.
  ///   2. Cursor-overlap when the sort column (rating, name) has ties.
  List<ShopListItemDTO> _dedupe(List<ShopListItemDTO> shops) {
    final seen = <String>{};
    return shops.where((s) => seen.add(s.id)).toList();
  }

  // ==================== EXISTING METHODS ====================

  @override
  Future<List<ShopTypeCount>> getShopTypeCounts() async {
    try {
      final response = await _client
          .from('shops')
          .select('shop_type')
          .neq('shop_type', 'null')
          .neq('shop_type', '');

      final Map<String, int> counts = {};
      for (var row in response) {
        final type = row['shop_type'] as String?;
        if (type != null && type.isNotEmpty) {
          counts[type] = (counts[type] ?? 0) + 1;
        }
      }

      return counts.entries
          .map((e) => ShopTypeCount(shopType: e.key, count: e.value))
          .toList()
        ..sort((a, b) => a.shopType.compareTo(b.shopType));
    } catch (e) {
      throw Exception('Failed to fetch shop types: $e');
    }
  }

  @override
  Future<List<LuxuryLevelInfo>> getLuxuryLevels(String shopType) async {
    try {
      final response = await _client
          .from('shops')
          .select('luxury_level')
          .eq('shop_type', shopType)
          .neq('luxury_level', 'null')
          .neq('luxury_level', '');

      final Map<String, int> counts = {};
      for (var row in response) {
        final level = row['luxury_level'] as String?;
        if (level != null && level.isNotEmpty) {
          counts[level] = (counts[level] ?? 0) + 1;
        }
      }

      return counts.entries
          .map((e) => LuxuryLevelInfo(level: e.key, count: e.value))
          .toList()
        ..sort((a, b) => a.level.compareTo(b.level));
    } catch (e) {
      throw Exception('Failed to fetch luxury levels: $e');
    }
  }

  // ==================== LIST VIEW METHODS (ShopListItemDTO) ====================
  @override
  Future<SearchPaginatedResult<ShopListItemDTO>> getShops(
    ShopQueryParams params,
  ) async {
    try {
      // ✅ Use view instead of shops table
      dynamic query = _client.from('shops_with_cover').select('''
      id,
      shop_name,
      average_rating,
      number_clients_worked,
      luxury_level,
      verified,
      shop_type,
      cover_image_url,
      created_at
    ''');

      // Add search condition
      if (params.searchQuery != null && params.searchQuery!.isNotEmpty) {
        query = query.ilike('shop_name', '%${params.searchQuery}%');
      }

      // Apply other filters
      if (params.shopType != null && params.shopType!.isNotEmpty) {
        query = query.eq('shop_type', params.shopType!);
      }
      if (params.luxuryLevel != null && params.luxuryLevel!.isNotEmpty) {
        query = query.eq('luxury_level', params.luxuryLevel!);
      }
      if (params.verifiedOnly == true) {
        query = query.eq('verified', true);
      }
      if (params.minRating != null) {
        query = query.gte('average_rating', params.minRating);
      }

      // Apply cursor pagination BEFORE sorting
      if (params.cursor != null && params.cursor!.isNotEmpty) {
        query = query.lt('id', params.cursor!);
      }

      // Apply sorting AFTER cursor pagination
      switch (params.sortBy) {
        case 'rating':
          query = query.order('average_rating', ascending: false);
          break;
        case 'name':
          query = query.order('shop_name', ascending: true);
          break;
        default:
          query = query.order('created_at', ascending: false);
      }

      final response = await query.limit(params.limit) as PostgrestList;

      // ✅ No need to fetch media separately - cover_image_url is already in the view
      final shops =
          response
              .map(
                (json) => ShopListItemDTO(
                  id: json['id'] as String,
                  shopName: json['shop_name'] as String,
                  coverImageUrl: json['cover_image_url'] as String?,
                  averageRating: (json['average_rating'] as num?)?.toDouble(),
                  numberClientsWorked: json['number_clients_worked'] as int?,
                  luxuryLevel: json['luxury_level'] as String?,
                  distanceKm: null,
                  verified: json['verified'] as bool? ?? false,
                  shopType: json['shop_type'] as String?,
                  isOpen: false,
                  openStatus: null,
                ),
              )
              .toList();

      final uniqueShops = _dedupe(shops);
      final nextCursor = uniqueShops.isNotEmpty ? uniqueShops.last.id : null;

      return SearchPaginatedResult(
        items: uniqueShops,
        nextCursor: nextCursor,
        totalCount: 0,
      );
    } catch (e) {
      throw Exception('Failed to fetch shops: $e');
    }
  }

  @override
  Future<List<ShopListItemDTO>> getPremiumShops({
    required String shopType,
    String? luxuryLevel,
    UserLocation? userLocation,
    int limit = 10,
  }) async {
    try {
      if (userLocation == null) {
        return await _getPremiumShopsUnsorted(shopType, luxuryLevel, limit);
      }

      final response = await _client.rpc(
        'get_premium_shops_by_distance',
        params: {
          'p_shop_type': shopType,
          'p_user_lat': userLocation.latitude,
          'p_user_lng': userLocation.longitude,
          'p_luxury_level': luxuryLevel,
          'p_limit': limit,
        },
      );

      final List<dynamic> data = response as List<dynamic>;
      final shops = <ShopListItemDTO>[];

      for (var item in data) {
        final shopJson = item['shop'] as Map<String, dynamic>;
        final distanceKm = (item['distance_km'] as num).toDouble();

        // Get cover image from the RPC result or from separate query
        String? coverImageUrl = shopJson['cover_image_url'] as String?;

        // If RPC doesn't return cover image, fetch it
        if (coverImageUrl == null) {
          final mediaResponse = await _client
              .from('shop_media')
              .select('url, is_cover')
              .eq('shop_id', shopJson['id'])
              .eq('media_type', 'professional')
              .order('is_cover', ascending: false)
              .order('sort_order')
              .limit(1);

          if (mediaResponse.isNotEmpty) {
            coverImageUrl = mediaResponse.first['url'] as String?;
          }
        }

        shops.add(
          ShopListItemDTO(
            id: shopJson['id'] as String,
            shopName: shopJson['shop_name'] as String,
            coverImageUrl: coverImageUrl,
            averageRating: (shopJson['average_rating'] as num?)?.toDouble(),
            numberClientsWorked: shopJson['number_clients_worked'] as int?,
            luxuryLevel: shopJson['luxury_level'] as String?,
            distanceKm: distanceKm,
            verified: shopJson['verified'] as bool? ?? false,
            shopType: shopJson['shop_type'] as String?,
            isOpen: false,
            openStatus: null,
          ),
        );
      }

      // Sort by distance
      shops.sort((a, b) {
        if (a.distanceKm != null && b.distanceKm != null) {
          return a.distanceKm!.compareTo(b.distanceKm!);
        }
        if (a.distanceKm != null) return -1;
        if (b.distanceKm != null) return 1;
        return 0;
      });

      return _dedupe(shops);
    } catch (e) {
      return await _getPremiumShopsUnsorted(shopType, luxuryLevel, limit);
    }
  }

  Future<List<ShopListItemDTO>> _getPremiumShopsUnsorted(
    String shopType,
    String? luxuryLevel,
    int limit,
  ) async {
    // ✅ Use view
    var query = _client
        .from('shops_with_cover')
        .select('''
        id,
        shop_name,
        average_rating,
        number_clients_worked,
        luxury_level,
        verified,
        shop_type,
        cover_image_url
      ''')
        .eq('shop_type', shopType);

    if (luxuryLevel != null && luxuryLevel.isNotEmpty) {
      query = query.eq('luxury_level', luxuryLevel);
    } else {
      query = query.inFilter('luxury_level', ['Luxury', 'UltraLuxury']);
    }

    final response = await query.limit(limit);

    return _dedupe(
      response
          .map(
            (json) => ShopListItemDTO(
              id: json['id'] as String,
              shopName: json['shop_name'] as String,
              coverImageUrl: json['cover_image_url'] as String?,
              averageRating: (json['average_rating'] as num?)?.toDouble(),
              numberClientsWorked: json['number_clients_worked'] as int?,
              luxuryLevel: json['luxury_level'] as String?,
              distanceKm: null,
              verified: json['verified'] as bool? ?? false,
              shopType: json['shop_type'] as String?,
              isOpen: false,
              openStatus: null,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<SearchPaginatedResult<ShopListItemDTO>> getPremiumShopsPaginated({
    required String shopType,
    String? luxuryLevel,
    String? cursor,
    int limit = 20,
    bool? verifiedOnly,
    String? sortBy,
  }) async {
    try {
      // ✅ Use the view
      dynamic query = _client
          .from('shops_with_cover')
          .select('''
          id,
          shop_name,
          average_rating,
          number_clients_worked,
          luxury_level,
          verified,
          shop_type,
          cover_image_url
        ''')
          .eq('shop_type', shopType);

      // Apply luxury level filter
      if (luxuryLevel != null && luxuryLevel.isNotEmpty) {
        query = query.eq('luxury_level', luxuryLevel);
      } else {
        query = query.inFilter('luxury_level', ['Luxury', 'UltraLuxury']);
      }

      // Apply verified only filter
      if (verifiedOnly == true) {
        query = query.eq('verified', true);
      }

      // Apply sorting before pagination so the offset is stable.
      switch (sortBy) {
        case 'name':
          query = query.order('shop_name', ascending: true).order('id');
          break;
        case 'rating':
        default:
          query = query.order('average_rating', ascending: false).order('id');
          break;
      }

      // Offset-based pagination — cursor encodes the next page start offset
      // as a decimal string. Using id-keyset with a rating sort caused
      // duplicates because UUIDs have no relationship to the sort column.
      final offset = int.tryParse(cursor ?? '') ?? 0;
      final response =
          await query.range(offset, offset + limit - 1) as PostgrestList;

      final shops = _dedupe(
        response
            .map(
              (json) => ShopListItemDTO(
                id: json['id'] as String,
                shopName: json['shop_name'] as String,
                coverImageUrl: json['cover_image_url'] as String?,
                averageRating: (json['average_rating'] as num?)?.toDouble(),
                numberClientsWorked: json['number_clients_worked'] as int?,
                luxuryLevel: json['luxury_level'] as String?,
                distanceKm: null,
                verified: json['verified'] as bool? ?? false,
                shopType: json['shop_type'] as String?,
                isOpen: false,
                openStatus: null,
              ),
            )
            .toList(),
      );

      // Null cursor = no more pages; string offset = start of next page.
      final nextCursor =
          shops.length < limit ? null : (offset + limit).toString();

      return SearchPaginatedResult(
        items: shops,
        nextCursor: nextCursor,
        totalCount: 0,
      );
    } catch (e) {
      throw Exception('Failed to fetch premium shops: $e');
    }
  }

  @override
  Future<List<ShopListItemDTO>> getTopRatedShops({
    required String shopType,
    double minRating = 4.5,
    int minReviews = 5,
    int limit = 10,
  }) async {
    try {
      // ✅ Use view
      var query = _client
          .from('shops_with_cover')
          .select('''
          id,
          shop_name,
          average_rating,
          number_clients_worked,
          luxury_level,
          verified,
          shop_type,
          cover_image_url
        ''')
          .eq('shop_type', shopType)
          .gte('average_rating', minRating)
          .gte('number_clients_worked', minReviews)
          .order('average_rating', ascending: false);

      final response = await query.limit(limit);
      return _dedupe(
        response
            .map(
              (json) => ShopListItemDTO(
                id: json['id'] as String,
                shopName: json['shop_name'] as String,
                coverImageUrl: json['cover_image_url'] as String?,
                averageRating: (json['average_rating'] as num?)?.toDouble(),
                numberClientsWorked: json['number_clients_worked'] as int?,
                luxuryLevel: json['luxury_level'] as String?,
                distanceKm: null,
                verified: json['verified'] as bool? ?? false,
                shopType: json['shop_type'] as String?,
                isOpen: false,
                openStatus: null,
              ),
            )
            .toList(),
      );
    } catch (e) {
      throw Exception('Failed to fetch top rated shops: $e');
    }
  }

  @override
  Future<SearchPaginatedResult<ShopListItemDTO>> getTopRatedShopsPaginated({
    required String shopType,
    double minRating = 4.5,
    int minReviews = 5,
    String? cursor,
    String? luxuryLevel,
    int limit = 20,
    bool? verifiedOnly,
    String? sortBy,
  }) async {
    try {
      // ✅ Use view
      dynamic query = _client
          .from('shops_with_cover')
          .select('''
          id,
          shop_name,
          average_rating,
          number_clients_worked,
          luxury_level,
          verified,
          shop_type,
          cover_image_url
        ''')
          .eq('shop_type', shopType)
          .gte('average_rating', minRating)
          .gte('number_clients_worked', minReviews);

      if (luxuryLevel != null && luxuryLevel.isNotEmpty) {
        query = query.eq('luxury_level', luxuryLevel);
      } else {
        query = query.inFilter('luxury_level', ['Luxury', 'UltraLuxury']);
      }

      if (verifiedOnly == true) {
        query = query.eq('verified', true);
      }

      switch (sortBy) {
        case 'name':
          query = query.order('shop_name', ascending: true).order('id');
          break;
        case 'rating':
        default:
          query = query.order('average_rating', ascending: false).order('id');
          break;
      }

      // Offset-based pagination — same rationale as getPremiumShopsPaginated.
      final offset = int.tryParse(cursor ?? '') ?? 0;
      final response =
          await query.range(offset, offset + limit - 1) as PostgrestList;

      final shops = _dedupe(
        response
            .map(
              (json) => ShopListItemDTO(
                id: json['id'] as String,
                shopName: json['shop_name'] as String,
                coverImageUrl: json['cover_image_url'] as String?,
                averageRating: (json['average_rating'] as num?)?.toDouble(),
                numberClientsWorked: json['number_clients_worked'] as int?,
                luxuryLevel: json['luxury_level'] as String?,
                distanceKm: null,
                verified: json['verified'] as bool? ?? false,
                shopType: json['shop_type'] as String?,
                isOpen: false,
                openStatus: null,
              ),
            )
            .toList(),
      );

      final nextCursor =
          shops.length < limit ? null : (offset + limit).toString();

      return SearchPaginatedResult(
        items: shops,
        nextCursor: nextCursor,
        totalCount: 0,
      );
    } catch (e) {
      throw Exception('Failed to fetch top rated shops: $e');
    }
  }

  // @override
  // Future<List<ShopListItemDTO>> getNearbyShops({
  //   required double latitude,
  //   required double longitude,
  //   double radiusKm = 2.0,
  //   int limit = 10,
  // }) async {
  //   try {
  //     final response = await _client.rpc(
  //       'get_nearby_shops',
  //       params: {
  //         'user_lat': latitude,
  //         'user_lng': longitude,
  //         'radius_km': radiusKm,
  //         'page_limit': limit,
  //       },
  //     );

  //     final List<dynamic> data = response as List<dynamic>;
  //     final result = <ShopListItemDTO>[];

  //     for (var item in data) {
  //       try {
  //         // The RPC should include cover_image_url now - update your RPC function
  //         final dto = _mapToShopListItemDTO(item as Map<String, dynamic>);
  //         result.add(dto);
  //       } catch (e) {
  //         continue;
  //       }
  //     }
  //     return result;
  //   } catch (e) {
  //     print(e);
  //     throw Exception('Failed to fetch nearby shops: $e');
  //   }
  // }

  @override
  Future<List<ShopListItemDTO>> getNearbyShops({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    int limit = 10,
  }) async {
    try {
      final response = await _client.rpc(
        'get_nearby_shops',
        params: {
          'user_lat': latitude,
          'user_lng': longitude,
          'radius_km': radiusKm,
          'filter_luxury_level': null,
          'verified_only': false,
          'sort_by': 'distance',
          'cursor_id': null,
          'page_limit': limit,
        },
      );

      final List<dynamic> data = response as List<dynamic>;

      if (data.isNotEmpty) {}

      final result = <ShopListItemDTO>[];
      for (var json in data) {
        try {
          final dto = ShopListItemDTO(
            id: json['id'] as String,
            shopName: json['shop_name'] as String,
            coverImageUrl: json['cover_image_url'] as String?,
            averageRating: (json['average_rating'] as num?)?.toDouble(),
            numberClientsWorked: json['number_clients_worked'] as int?,
            luxuryLevel: json['luxury_level'] as String?,
            distanceKm: (json['distance_km'] as num?)?.toDouble(),
            verified: json['verified'] as bool? ?? false,
            shopType: json['shop_type'] as String?,
            isOpen: false,
            openStatus: null,
          );
          result.add(dto);
        } catch (e) {
          continue;
        }
      }

      return _dedupe(result);
    } catch (e) {
      throw Exception('Failed to fetch nearby shops: $e');
    }
  }

  @override
  Future<SearchPaginatedResult<ShopListItemDTO>> getNearbyShopsPaginated({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? cursor,
    String? luxuryLevel,
    int limit = 20,
    bool? verifiedOnly,
    String? sortBy,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'user_lat': latitude,
        'user_lng': longitude,
        'radius_km': radiusKm,
        'filter_luxury_level': null,
        'verified_only': false,
        'sort_by': 'distance',
        'cursor_id': null,
        'page_limit': limit,
      };
      if (luxuryLevel != null && luxuryLevel.isNotEmpty) {
        params['filter_luxury_level'] = luxuryLevel;
      }
      if (verifiedOnly == true) {
        params['verified_only'] = true;
      }
      if (sortBy != null) {
        params['sort_by'] = sortBy;
      }
      if (cursor != null && cursor.isNotEmpty) {
        params['cursor_id'] = cursor;
      }
      final response = await _client.rpc('get_nearby_shops', params: params);
      final List<dynamic> data = response as List<dynamic>;
      final shops =
          data
              .map(
                (json) => ShopListItemDTO(
                  id: json['id'] as String,
                  shopName: json['shop_name'] as String,
                  coverImageUrl: json['cover_image_url'] as String?,
                  averageRating: (json['average_rating'] as num?)?.toDouble(),
                  numberClientsWorked: json['number_clients_worked'] as int?,
                  luxuryLevel: json['luxury_level'] as String?,
                  distanceKm: (json['distance_km'] as num?)?.toDouble(),
                  verified: json['verified'] as bool? ?? false,
                  shopType: json['shop_type'] as String?,
                  isOpen: false,
                  openStatus: null,
                ),
              )
              .toList();

      final uniqueShops = _dedupe(shops);
      final nextCursor = uniqueShops.isNotEmpty ? uniqueShops.last.id : null;
      return SearchPaginatedResult(
        items: uniqueShops,
        nextCursor: nextCursor,
        totalCount: 0,
      );
    } catch (e) {
      throw Exception('Failed to fetch nearby shops: $e');
    }
  }

  // ==================== DETAILS VIEW METHODS (ShopDetailsDTO) ====================

  @override
  Future<List<ShopListItemDTO>> getShopsByProfileId(String profileId) async {
    try {
      final shopsResponse = await _client
          .from('shops')
          .select('''
          id,
          shop_name,
          average_rating,
          number_clients_worked,
          luxury_level,
          verified,
          shop_type
        ''')
          .eq('user_id', profileId)
          .order('created_at', ascending: false);

      final List<ShopListItemDTO> shops = [];

      for (var shopJson in shopsResponse) {
        final shopId = shopJson['id'] as String;

        final mediaResponse = await _client
            .from('shop_media')
            .select('url, media_type, sort_order, is_cover')
            .eq('shop_id', shopId)
            .eq('media_type', 'professional')
            .order('sort_order', ascending: true);

        // Find cover image - Option 3 (cleanest)
        final coverImages =
            mediaResponse.where((m) => m['is_cover'] == true).toList();
        String? coverImageUrl;

        if (coverImages.isNotEmpty) {
          coverImageUrl = coverImages.first['url'] as String?;
        } else if (mediaResponse.isNotEmpty) {
          // Fallback to first image if no cover
          coverImageUrl = mediaResponse.first['url'] as String?;
        }

        shops.add(
          ShopListItemDTO(
            id: shopId,
            shopName: shopJson['shop_name'] as String,
            coverImageUrl: coverImageUrl,
            averageRating: (shopJson['average_rating'] as num?)?.toDouble(),
            numberClientsWorked: shopJson['number_clients_worked'] as int?,
            luxuryLevel: shopJson['luxury_level'] as String?,
            distanceKm: null,
            verified: shopJson['verified'] as bool? ?? false,
            shopType: shopJson['shop_type'] as String?,
            isOpen: false,
            openStatus: null,
          ),
        );
      }

      return shops;
    } catch (e) {
      print('Error in getShopsByProfileId: $e');
      throw Exception('Error fetching shops: $e');
    }
  }

  @override
  Future<ShopDetailsDTO> getShopDetailsById(String shopId) async {
    try {
      // First fetch shop data without any joins
      final response =
          await _client.from('shops').select('*').eq('id', shopId).single();

      // Fetch all related data separately
      final [
        workersResponse,
        mediaResponse,
        awardsResponse,
        socialLinksResponse,
        contactsResponse,
        openingHoursResponse,
        slotsResponse,
        locationsResponse,
      ] = await Future.wait([
        _client.from('shop_workers').select('*').eq('shop_id', shopId),
        _client
            .from('shop_media')
            .select('*')
            .eq('shop_id', shopId)
            .order('sort_order', ascending: true),
        _client
            .from('shop_awards')
            .select('*')
            .eq('shop_id', shopId)
            .order('sort_order', ascending: true),
        _client.from('shop_social_links').select('*').eq('shop_id', shopId),
        _client.from('shop_contacts').select('*').eq('shop_id', shopId),
        _client
            .from('shop_opening_hours')
            .select('*')
            .eq('shop_id', shopId)
            .order('day_of_week', ascending: true),
        _client.from('appointment_slots').select('*').eq('shop_id', shopId),
        _client.from('shop_locations').select('*').eq('shop_id', shopId),
      ]);

      // Extract location data
      String? address;
      String? city;
      String? country;
      double? latitude;
      double? longitude;

      if (locationsResponse.isNotEmpty) {
        final primaryLocation = locationsResponse.firstWhere(
          (loc) => loc['is_primary'] == true,
          orElse: () => locationsResponse.first,
        );
        address = primaryLocation['address'] as String?;
        city = primaryLocation['city'] as String?;
        country = primaryLocation['country'] as String?;
        latitude = (primaryLocation['latitude'] as num?)?.toDouble();
        longitude = (primaryLocation['longitude'] as num?)?.toDouble();
      }

      // Extract contacts
      String? phone;
      String? email;
      String? website;
      for (var contact in contactsResponse) {
        final type = contact['contact_type'] as String?;
        final value = contact['value'] as String?;
        if (type == 'phone')
          phone = value;
        else if (type == 'email')
          email = value;
        else if (type == 'website')
          website = value;
      }

      // Build enriched response
      final enrichedResponse = {
        ...response,
        'shop_workers': workersResponse,
        'shop_media': mediaResponse,
        'shop_awards': awardsResponse,
        'shop_social_links': socialLinksResponse,
        'shop_contacts': contactsResponse,
        'shop_opening_hours': openingHoursResponse,
        'appointment_slots': slotsResponse,
        'locations': locationsResponse,
        'address': address ?? response['address'],
        'city': city ?? response['city'],
        'country': country ?? response['country'],
        'latitude': latitude ?? (response['latitude'] as num?)?.toDouble(),
        'longitude': longitude ?? (response['longitude'] as num?)?.toDouble(),
        'currency': response['currency'] ?? response['currency_code'],
        'phone': phone,
        'email': email,
        'website': website,
      };

      return ShopDetailsDTO.fromJson(enrichedResponse);
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to fetch shop details: $e');
    }
  }

  // In your repository (e.g., SupabaseShopRepository)
  @override
  Future<List<WorkerDTO>> getAllWorkersForShop(String shopId) async {
    final response = await _client
        .from('workers')
        .select('*')
        .eq('shop_id', shopId)
        .order('name', ascending: true);

    return response.map((json) => WorkerDTO.fromJson(json)).toList();
  }

  @override
  Future<List<BookingReview>> getShopReviews(String shopId) async {
    try {
      final response = await _client
          .from('booking_reviews')
          .select('''
          *,
          user:profiles!user_id(
            display_name,
            username,
            avatar_url
          )
        ''')
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => BookingReview.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
  // ==================== NEW BOOKING METHOD IMPLEMENTATIONS ====================

  @override
  Future<List<AppointmentSlotDTO>> getAppointmentSlots(String shopId) async {
    try {
      final response = await _client
          .from('appointment_slots')
          .select('*')
          .eq('shop_id', shopId)
          .order('price', ascending: true);

      // Explicitly map to AppointmentSlotDTO
      return response.map<AppointmentSlotDTO>((json) {
        return AppointmentSlotDTO.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch appointment slots: $e');
    }
  }

  @override
  Future<List<WorkerDTO>> getWorkers(String shopId) async {
    try {
      // Now with active filter
      final activeWorkers = await _client
          .from('workers')
          .select('*')
          .eq('shop_id', shopId)
          .eq('is_active', true);

      return activeWorkers.map((json) => WorkerDTO.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch workers: $e');
    }
  }

  @override
  Future<Map<String, List<String>>> getSlotWorkerAssignments(
    String shopId,
  ) async {
    try {
      final response = await _client
          .from('slot_worker_assignments')
          .select('''
            slot_id,
            worker_id,
            appointment_slots!inner(shop_id)
          ''')
          .eq('appointment_slots.shop_id', shopId);

      final Map<String, List<String>> assignments = {};
      for (var row in response) {
        final slotId = row['slot_id'] as String;
        final workerId = row['worker_id'] as String;
        assignments.putIfAbsent(slotId, () => []).add(workerId);
      }
      return assignments;
    } catch (e) {
      throw Exception('Failed to fetch slot worker assignments: $e');
    }
  }

  @override
  Future<Map<String, DateTimeRange>> getOpeningHours(String shopId) async {
    try {
      final response = await _client
          .from('shop_opening_hours')
          .select('*')
          .eq('shop_id', shopId);

      final Map<String, DateTimeRange> hours = {};
      for (var row in response) {
        final day = _getDayName(row['day_of_week'] as int);
        final opensAt = _parseTime(row['opens_at'] as String);
        final closesAt = _parseTime(row['closes_at'] as String);
        hours[day] = DateTimeRange(start: opensAt, end: closesAt);
      }
      return hours;
    } catch (e) {
      throw Exception('Failed to fetch opening hours: $e');
    }
  }

  @override
  Future<List<WorkerDTO>> getWorkersByIds(List<String> workerIds) async {
    if (workerIds.isEmpty) return [];

    try {
      final response = await _client
          .from('workers')
          .select('*')
          .inFilter('id', workerIds);

      return response.map((json) => WorkerDTO.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch workers by IDs: $e');
    }
  }

  /// Get search suggestions based on partial query
  Future<List<String>> getSearchSuggestions(String partialQuery) async {
    if (partialQuery.isEmpty) return [];

    try {
      // Get shop names that start with the partial query
      final shopNames = await _client
          .from('shops')
          .select('shop_name')
          .ilike('shop_name', '%$partialQuery%')
          .limit(5);

      // Get service names that match (if you have a services table)
      // For now, return shop names
      final suggestions =
          shopNames.map((s) => s['shop_name'] as String).toList();

      // Add some popular search terms if we don't have enough
      if (suggestions.length < 3) {
        final popular = await _getPopularSearchTerms();
        suggestions.addAll(
          popular
              .where((p) => p.contains(partialQuery))
              .take(3 - suggestions.length),
        );
      }

      return suggestions;
    } catch (e) {
      return [];
    }
  }

  /// Get popular search terms from analytics
  Future<List<String>> _getPopularSearchTerms() async {
    try {
      // Query search analytics for popular terms
      final response = await _client
          .from('search_analytics')
          .select('query, count')
          .order('count', ascending: false)
          .limit(10);

      return response.map((r) => r['query'] as String).toList();
    } catch (e) {
      // Return default popular searches if table doesn't exist yet
      return ['Haircut', 'Massage', 'Nails', 'Facial', 'Barber'];
    }
  }

  /// Log search for analytics
  Future<void> logSearchAnalytics(String query, int resultCount) async {
    try {
      // Try to update existing analytics or insert new
      final existing =
          await _client
              .from('search_analytics')
              .select()
              .eq('query', query)
              .maybeSingle();

      if (existing != null) {
        // Update existing
        await _client
            .from('search_analytics')
            .update({
              'count': (existing['count'] as int) + 1,
              'last_searched_at': DateTime.now().toIso8601String(),
            })
            .eq('query', query);
      } else {
        // Insert new
        await _client.from('search_analytics').insert({
          'query': query,
          'count': 1,
          'result_count': resultCount,
          'first_searched_at': DateTime.now().toIso8601String(),
          'last_searched_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      // Silent fail - don't break the search experience
      print('Failed to log search analytics: $e');
    }
  }

  /// Get popular searches from analytics table
  Future<List<String>> getPopularSearches(int limit) async {
    try {
      // Query the search_analytics table for most frequent searches
      final response = await _client
          .from('search_analytics')
          .select('query, count')
          .order('count', ascending: false)
          .limit(limit);

      return response.map((row) => row['query'] as String).toList();
    } catch (e) {
      // If table doesn't exist yet, return default list
      print('Failed to fetch popular searches: $e');
      return _getDefaultPopularSearches();
    }
  }

  @override
  Future<ShopListItemDTO> getMarkerShopDetails(String shopId) async {
    try {
      // Use the view that already includes cover_image_url
      final response =
          await _client
              .from('shops_with_cover')
              .select('''
          id,
          shop_name,
          average_rating,
          number_clients_worked,
          luxury_level,
          verified,
          shop_type,
          cover_image_url
        ''')
              .eq('id', shopId)
              .single();

      return ShopListItemDTO.fromJson(response);
    } catch (e) {
      print(e);
      throw Exception('Failed to fetch shop details: $e');
    }
  }

  List<String> _getDefaultPopularSearches() {
    return [
      'Haircut',
      'Massage',
      'Manicure',
      'Facial',
      'Barber',
      'Spa',
      'Nail Art',
      'Waxing',
      'Makeup',
      'Blowout',
    ];
  }

  // ==================== HELPER METHODS ====================

  String _getDayName(int dayOfWeek) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[dayOfWeek - 1]; // SQL day_of_week (1-7) to index (0-6)
  }

  DateTime _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }
}
