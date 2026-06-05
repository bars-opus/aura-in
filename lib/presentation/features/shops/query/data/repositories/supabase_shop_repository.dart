// lib/features/shops/data/repositories/supabase_shop_repository.dart
import 'dart:developer' as developer;

import 'package:nano_embryo/core/repositories/repository_helpers.dart';
import 'package:nano_embryo/presentation/features/search/models/search_paginated_result.dart';
import 'package:nano_embryo/presentation/features/search/models/shop_query_params.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/data/models/booking_review.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class SupabaseShopRepository implements ShopRepository {
  final SupabaseClient _client;

  SupabaseShopRepository(this._client);

  /// "Premium" maps to these luxury levels. Centralized so the definition
  /// stays consistent across all premium query methods.
  static const List<String> _premiumLuxuryLevels = ['Luxury', 'UltraLuxury'];

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
  Future<List<ShopTypeCount>> getShopTypeCounts() {
    return runRepoQuery(
      opName: 'getShopTypeCounts',
      userMessage: "Couldn't load shop categories. Please try again.",
      () async {
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
      },
    );
  }

  @override
  Future<List<LuxuryLevelInfo>> getLuxuryLevels(String shopType) {
    return runRepoQuery(
      opName: 'getLuxuryLevels',
      userMessage: "Couldn't load filters. Please try again.",
      () async {
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
      },
    );
  }

  // ==================== LIST VIEW METHODS (ShopListItemDTO) ====================
  @override
  Future<SearchPaginatedResult<ShopListItemDTO>> getShops(
    ShopQueryParams params,
  ) {
    return runRepoQuery(
      opName: 'getShops',
      userMessage: "Couldn't load shops. Please try again.",
      () async {
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

        if (params.searchQuery != null && params.searchQuery!.isNotEmpty) {
          // Escape ilike wildcards so user input "%" / "_" matches literally.
          query = query.ilike('shop_name', '%${_escapeLike(params.searchQuery!)}%');
        }

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

        // Sort with id tie-break so offset pagination is stable.
        switch (params.sortBy) {
          case 'rating':
            query =
                query.order('average_rating', ascending: false).order('id');
            break;
          case 'name':
            query = query.order('shop_name', ascending: true).order('id');
            break;
          default:
            query = query.order('created_at', ascending: false).order('id');
        }

        final offset = int.tryParse(params.cursor ?? '') ?? 0;
        final limit = params.limit.clamp(1, 50);
        final response =
            await query.range(offset, offset + limit - 1) as PostgrestList;

        final rawCount = response.length;
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

        // Compare raw response length (not deduped) so we don't terminate
        // pagination early when the view fans out duplicates.
        final nextCursor =
            rawCount < limit ? null : (offset + limit).toString();

        return SearchPaginatedResult(
          items: shops,
          nextCursor: nextCursor,
          totalCount: 0,
        );
      },
    );
  }

  /// Escapes `%`, `_`, `\` so user-typed wildcards match literally in ilike.
  static String _escapeLike(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll('%', '\\%')
        .replaceAll('_', '\\_');
  }

  @override
  Future<List<ShopListItemDTO>> getPremiumShops({
    required String shopType,
    String? luxuryLevel,
    UserLocation? userLocation,
    int limit = 10,
  }) async {
    final clampedLimit = limit.clamp(1, 50);

    if (userLocation == null) {
      return _getPremiumShopsUnsorted(shopType, luxuryLevel, clampedLimit);
    }

    // Try distance-sorted RPC first; fall back to unsorted on persistent failure
    // so the discover screen never goes blank just because the RPC is slow/broken.
    try {
      return await runRepoQuery(
        opName: 'getPremiumShops.byDistance',
        userMessage: '', // not surfaced — we fall back
        () async {
          final response = await _client.rpc(
            'get_premium_shops_by_distance',
            params: {
              'p_shop_type': shopType,
              'p_user_lat': userLocation.latitude,
              'p_user_lng': userLocation.longitude,
              'p_luxury_level': luxuryLevel,
              'p_limit': clampedLimit,
            },
          );

          final List<dynamic> data = response as List<dynamic>;

          // Batch-fetch any missing cover images in one query (was N+1).
          final missingCoverIds = <String>[
            for (final item in data)
              if ((item['shop']['cover_image_url'] as String?) == null)
                item['shop']['id'] as String,
          ];

          final coverByShopId = <String, String>{};
          if (missingCoverIds.isNotEmpty) {
            final mediaRows = await _client
                .from('shop_media')
                .select('shop_id, url, is_cover, sort_order')
                .inFilter('shop_id', missingCoverIds)
                .eq('media_type', 'professional')
                .order('is_cover', ascending: false)
                .order('sort_order');

            for (final row in mediaRows) {
              final shopId = row['shop_id'] as String;
              coverByShopId.putIfAbsent(shopId, () => row['url'] as String);
            }
          }

          // RPC already returns rows sorted by distance — no client-side sort.
          final shops = <ShopListItemDTO>[
            for (final item in data)
              ShopListItemDTO(
                id: item['shop']['id'] as String,
                shopName: item['shop']['shop_name'] as String,
                coverImageUrl:
                    (item['shop']['cover_image_url'] as String?) ??
                        coverByShopId[item['shop']['id'] as String],
                averageRating:
                    (item['shop']['average_rating'] as num?)?.toDouble(),
                numberClientsWorked:
                    item['shop']['number_clients_worked'] as int?,
                luxuryLevel: item['shop']['luxury_level'] as String?,
                distanceKm: (item['distance_km'] as num).toDouble(),
                verified: item['shop']['verified'] as bool? ?? false,
                shopType: item['shop']['shop_type'] as String?,
                isOpen: false,
                openStatus: null,
              ),
          ];

          return _dedupe(shops);
        },
      );
    } on RepositoryException {
      // RPC failed after retries — log was already emitted, fall back gracefully.
      return _getPremiumShopsUnsorted(shopType, luxuryLevel, clampedLimit);
    }
  }

  Future<List<ShopListItemDTO>> _getPremiumShopsUnsorted(
    String shopType,
    String? luxuryLevel,
    int limit,
  ) {
    return runRepoQuery(
      opName: 'getPremiumShops.unsorted',
      userMessage: "Couldn't load premium shops. Please try again.",
      () async {
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
          query = query.inFilter('luxury_level', _premiumLuxuryLevels);
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
      },
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
  }) {
    return runRepoQuery(
      opName: 'getPremiumShopsPaginated',
      userMessage: "Couldn't load premium shops. Please try again.",
      () async {
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

        if (luxuryLevel != null && luxuryLevel.isNotEmpty) {
          query = query.eq('luxury_level', luxuryLevel);
        } else {
          query = query.inFilter('luxury_level', _premiumLuxuryLevels);
        }

        if (verifiedOnly == true) {
          query = query.eq('verified', true);
        }

        // Sort with id tie-break so offset pagination is stable.
        switch (sortBy) {
          case 'name':
            query = query.order('shop_name', ascending: true).order('id');
            break;
          case 'rating':
          default:
            query =
                query.order('average_rating', ascending: false).order('id');
            break;
        }

        final offset = int.tryParse(cursor ?? '') ?? 0;
        final clampedLimit = limit.clamp(1, 50);
        final response =
            await query.range(offset, offset + clampedLimit - 1)
                as PostgrestList;

        final rawCount = response.length;
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

        // Compare raw response length (not deduped) — see getShops.
        final nextCursor = rawCount < clampedLimit
            ? null
            : (offset + clampedLimit).toString();

        return SearchPaginatedResult(
          items: shops,
          nextCursor: nextCursor,
          totalCount: 0,
        );
      },
    );
  }

  @override
  Future<List<ShopListItemDTO>> getTopRatedShops({
    required String shopType,
    double minRating = 4.5,
    int minReviews = 5,
    int limit = 10,
  }) {
    return runRepoQuery(
      opName: 'getTopRatedShops',
      userMessage: "Couldn't load top rated shops. Please try again.",
      () async {
        final clampedLimit = limit.clamp(1, 50);
        final response = await _client
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
            .order('average_rating', ascending: false)
            .order('id')
            .limit(clampedLimit);

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
      },
    );
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
  }) {
    return runRepoQuery(
      opName: 'getTopRatedShopsPaginated',
      userMessage: "Couldn't load top rated shops. Please try again.",
      () async {
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
          query = query.inFilter('luxury_level', _premiumLuxuryLevels);
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
            query =
                query.order('average_rating', ascending: false).order('id');
            break;
        }

        final offset = int.tryParse(cursor ?? '') ?? 0;
        final clampedLimit = limit.clamp(1, 50);
        final response =
            await query.range(offset, offset + clampedLimit - 1)
                as PostgrestList;

        final rawCount = response.length;
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

        // Compare raw response length (not deduped) — see getPremiumShopsPaginated.
        final nextCursor = rawCount < clampedLimit
            ? null
            : (offset + clampedLimit).toString();

        return SearchPaginatedResult(
          items: shops,
          nextCursor: nextCursor,
          totalCount: 0,
        );
      },
    );
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
  }) {
    return runRepoQuery(
      opName: 'getNearbyShops',
      userMessage: "Couldn't load nearby shops. Please try again.",
      () async {
        final clampedLimit = limit.clamp(1, 50);
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
            'page_limit': clampedLimit,
          },
        );

        final List<dynamic> data = response as List<dynamic>;
        return _dedupe(
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
              .toList(),
        );
      },
    );
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
  }) {
    return runRepoQuery(
      opName: 'getNearbyShopsPaginated',
      userMessage: "Couldn't load nearby shops. Please try again.",
      () async {
        final clampedLimit = limit.clamp(1, 50);
        final Map<String, dynamic> params = {
          'user_lat': latitude,
          'user_lng': longitude,
          'radius_km': radiusKm,
          'filter_luxury_level': null,
          'verified_only': false,
          'sort_by': 'distance',
          'cursor_id': null,
          'page_limit': clampedLimit,
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
        final response =
            await _client.rpc('get_nearby_shops', params: params);
        final List<dynamic> data = response as List<dynamic>;

        // Capture the raw last row's id BEFORE dedup so the next page anchors
        // to the actual server-side cursor position, not our deduped tail.
        final rawLastId =
            data.isNotEmpty ? data.last['id'] as String? : null;
        final rawCount = data.length;

        final shops = _dedupe(
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
              .toList(),
        );

        // Terminate when the RPC returned fewer rows than requested.
        // NOTE: assumes get_nearby_shops orders by (distance, id) and uses
        // cursor_id as a keyset on id within the same distance. Verify SQL.
        final nextCursor = rawCount < clampedLimit ? null : rawLastId;
        return SearchPaginatedResult(
          items: shops,
          nextCursor: nextCursor,
          totalCount: 0,
        );
      },
    );
  }

  // ==================== DETAILS VIEW METHODS (ShopDetailsDTO) ====================

  @override
  Future<List<ShopListItemDTO>> getShopsByProfileId(String profileId) {
    return runRepoQuery(
      opName: 'getShopsByProfileId',
      userMessage: "Couldn't load shops. Please try again.",
      () async {
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

        if (shopsResponse.isEmpty) return [];

        // Batch-fetch covers in one query (was N+1 before).
        final shopIds = [
          for (final s in shopsResponse) s['id'] as String,
        ];
        final mediaRows = await _client
            .from('shop_media')
            .select('shop_id, url, is_cover, sort_order')
            .inFilter('shop_id', shopIds)
            .eq('media_type', 'professional')
            .order('is_cover', ascending: false)
            .order('sort_order');

        // First row per shop wins (ordered is_cover desc, sort_order asc).
        final coverByShopId = <String, String>{};
        for (final row in mediaRows) {
          final id = row['shop_id'] as String;
          coverByShopId.putIfAbsent(id, () => row['url'] as String);
        }

        return shopsResponse
            .map(
              (shopJson) => ShopListItemDTO(
                id: shopJson['id'] as String,
                shopName: shopJson['shop_name'] as String,
                coverImageUrl: coverByShopId[shopJson['id'] as String],
                averageRating: (shopJson['average_rating'] as num?)?.toDouble(),
                numberClientsWorked:
                    shopJson['number_clients_worked'] as int?,
                luxuryLevel: shopJson['luxury_level'] as String?,
                distanceKm: null,
                verified: shopJson['verified'] as bool? ?? false,
                shopType: shopJson['shop_type'] as String?,
                isOpen: false,
                openStatus: null,
              ),
            )
            .toList();
      },
    );
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
        _client
            .from('appointment_slots')
            .select('*')
            .eq('shop_id', shopId)
            .isFilter('archived_at', null),
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
    } catch (e, stack) {
      developer.log(
        'getShopDetailsById failed',
        name: 'repository',
        error: e,
        stackTrace: stack,
      );
      throw RepositoryException(
        "Couldn't load shop details. Please try again.",
        cause: e,
        stackTrace: stack,
      );
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
          .isFilter('archived_at', null)
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
    } catch (e, stack) {
      developer.log(
        'getWorkers failed',
        name: 'repository',
        error: e,
        stackTrace: stack,
      );
      throw RepositoryException(
        "Couldn't load workers. Please try again.",
        cause: e,
        stackTrace: stack,
      );
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
            appointment_slots!inner(shop_id, archived_at)
          ''')
          .eq('appointment_slots.shop_id', shopId)
          .isFilter('appointment_slots.archived_at', null);

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

  /// Log search for analytics.
  ///
  /// Delegates to the `log_search_query` RPC which sanitizes the input
  /// (lower + trim + length cap), enforces a per-actor rate limit, and
  /// performs the upsert in a single round-trip. The client never writes
  /// raw user-typed text directly into the analytics table.
  Future<void> logSearchAnalytics(String query, int resultCount) async {
    try {
      await _client.rpc(
        'log_search_query',
        params: {
          'p_query': query,
          'p_category': 'shops',
          'p_result_count': resultCount,
        },
      );
    } catch (e, stack) {
      // Silent fail — analytics must never break the search experience.
      developer.log(
        'logSearchAnalytics failed',
        name: 'repository',
        error: e,
        stackTrace: stack,
      );
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
    } catch (e, stack) {
      developer.log(
        'getPopularSearches failed — falling back to defaults',
        name: 'repository',
        error: e,
        stackTrace: stack,
      );
      return _getDefaultPopularSearches();
    }
  }

  @override
  Future<ShopListItemDTO> getMarkerShopDetails(String shopId) {
    return runRepoQuery(
      opName: 'getMarkerShopDetails',
      userMessage: "Couldn't load shop details. Please try again.",
      () async {
        final response = await _client
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
      },
    );
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
