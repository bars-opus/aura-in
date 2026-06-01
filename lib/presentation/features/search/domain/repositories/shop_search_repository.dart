// lib/features/search/data/repositories/shop_search_repository.dart
import 'dart:developer' as developer;
import 'package:nano_embryo/presentation/features/search/domain/mappers/shop_to_search_mapper.dart';
import 'package:nano_embryo/presentation/features/search/domain/repositories/search_repository.dart';
import 'package:nano_embryo/presentation/features/search/models/search_paginated_result.dart';
import 'package:nano_embryo/presentation/features/search/models/search_filters.dart';
import 'package:nano_embryo/presentation/features/search/models/shop_query_params.dart';
import 'package:nano_embryo/presentation/features/search/models/shop_search_result.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart';

/// Implementation of SearchRepository for shops
class ShopSearchRepository implements SearchRepository<ShopSearchResult> {
  final SupabaseShopRepository _shopRepository;

  ShopSearchRepository(this._shopRepository);

  @override
  Future<SearchPaginatedResult<ShopSearchResult>> search({
    required String query,
    required SearchFilters filters,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final shopParams = _mapFiltersToQueryParams(
        query: query,
        filters: filters,
        cursor: cursor,
        limit: limit,
      );

      final paginatedShops = await _shopRepository.getShops(shopParams);

      final results = ShopToSearchResultMapper.toSearchResults(
        paginatedShops.items,
      );

      return SearchPaginatedResult<ShopSearchResult>(
        items: results,
        nextCursor: paginatedShops.nextCursor,
        totalCount: paginatedShops.totalCount,
      );
    } catch (e, stack) {
      developer.log(
        'shop search failed',
        name: 'search',
        error: e,
        stackTrace: stack,
      );
      throw Exception('Search failed. Please try again.');
    }
  }

  @override
  Future<List<String>> getSuggestions(String partialQuery) async {
    if (partialQuery.isEmpty) return [];
    try {
      return await _shopRepository.getSearchSuggestions(partialQuery);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> logSearch(String query, int resultCount) async {
    try {
      await _shopRepository.logSearchAnalytics(query, resultCount);
    } catch (e) {
      // Silent fail
    }
  }

  @override
  Future<List<String>> getPopularSearches({int limit = 10}) async {
    try {
      return await _shopRepository.getPopularSearches(limit);
    } catch (e) {
      return [];
    }
  }

  ShopQueryParams _mapFiltersToQueryParams({
    required String query,
    required SearchFilters filters,
    String? cursor,
    required int limit,
  }) {
    final sortBy = _mapSortBy(filters.sortBy);

    return ShopQueryParams(
      shopType: filters.category?.displayName,
      luxuryLevel: filters.luxuryLevel,
      verifiedOnly: filters.verifiedOnly,
      sortBy: sortBy,
      cursor: cursor,
      limit: limit,
      minRating: filters.minRating,
      userLocation: filters.userLocation,
      searchQuery: query,
    );
  }

  String? _mapSortBy(String? sortBy) {
    switch (sortBy) {
      case 'rating':
        return 'rating';
      case 'name':
        return 'name';
      case 'distance':
        return 'distance';
      default:
        return 'relevance';
    }
  }
}
