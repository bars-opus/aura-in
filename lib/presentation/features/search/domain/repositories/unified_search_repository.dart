// lib/features/search/data/repositories/unified_search_repository.dart
import 'dart:async';
import 'dart:developer' as developer;
import 'package:nano_embryo/presentation/features/search/domain/models/category_search_section.dart';
import 'package:nano_embryo/presentation/features/search/domain/models/search_params.dart';
import 'package:nano_embryo/presentation/features/search/domain/repositories/freelancer_search_repository.dart';
import 'package:nano_embryo/presentation/features/search/domain/repositories/shop_search_repository.dart';
import 'package:nano_embryo/presentation/features/search/models/search_paginated_result.dart';
import 'package:nano_embryo/presentation/features/search/models/search_category.dart';
import 'package:nano_embryo/presentation/features/search/models/unified_search_result.dart';

import 'profile_search_repository.dart';

/// Repository that combines search results from multiple categories
class UnifiedSearchRepository {
  static const Duration _searchTimeout = Duration(seconds: 8);

  final ShopSearchRepository _shopRepository;
  final ProfileSearchRepository _profileRepository;
  final FreelancerSearchRepository _freelancerRepository;

  UnifiedSearchRepository({
    required ShopSearchRepository shopRepository,
    required ProfileSearchRepository profileRepository,
    required FreelancerSearchRepository freelancerRepository,
  }) : _shopRepository = shopRepository,
       _profileRepository = profileRepository,
       _freelancerRepository = freelancerRepository;

  /// Search all categories and return sections for "All" view
  Future<List<CategorySearchSection>> searchAllSections({
    required SearchParams params,
  }) async {
    // Run all searches in parallel
    final results = await Future.wait([
      _searchCategorySection(SearchCategory.shops, params),
      _searchCategorySection(SearchCategory.profiles, params),
      _searchCategorySection(SearchCategory.freelancers, params),
    ]);

    // Filter out empty sections
    return results.where((section) => section.results.isNotEmpty).toList();
  }

  /// Search a specific category with pagination support
  Future<SearchPaginatedResult<UnifiedSearchResult>> searchByCategory({
    required SearchParams params,
  }) async {
    if (params.category == null) {
      throw ArgumentError('Category must be specified for category search');
    }

    switch (params.category) {
      case SearchCategory.shops:
        return await _shopRepository
            .search(
              query: params.query,
              filters: params.filters,
              cursor: params.cursor,
              limit: params.limit,
            )
            .timeout(_searchTimeout);
      case SearchCategory.profiles:
        return await _profileRepository
            .search(
              query: params.query,
              limit: params.limit,
              cursor: params.cursor,
            )
            .timeout(_searchTimeout);
      case SearchCategory.freelancers:
        final result = await _freelancerRepository
            .search(
              query: params.query,
              limit: params.limit,
              cursor: params.cursor,
              filters: params.filters,
            )
            .timeout(_searchTimeout);
        return SearchPaginatedResult<UnifiedSearchResult>(
          items: result.items,
          nextCursor: result.nextCursor,
          totalCount: result.totalCount,
        );
      default:
        return SearchPaginatedResult<UnifiedSearchResult>.empty();
    }
  }

  /// Search a single category and return as a section
  Future<CategorySearchSection> _searchCategorySection(
    SearchCategory category,
    SearchParams params,
  ) async {
    try {
      final result = await searchByCategory(
        params: params.copyWith(category: category, cursor: null),
      );

      return CategorySearchSection(
        category: category,
        results: result.items,
        hasMore: result.hasMore,
        totalCount: result.totalCount,
      );
    } catch (e, stack) {
      developer.log(
        'category search failed: ${category.name}',
        name: 'search',
        error: e,
        stackTrace: stack,
      );
      return CategorySearchSection.empty(category);
    }
  }

  Future<void> logSearch(String query, int resultCount) async {
    try {
      await _shopRepository.logSearch(query, resultCount);
    } catch (e) {
      // Silent fail
    }
  }
}
