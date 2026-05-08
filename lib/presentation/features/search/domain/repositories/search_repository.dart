// lib/features/search/domain/repositories/search_repository.dart

import 'package:nano_embryo/presentation/features/search/models/search_paginated_result.dart';
import 'package:nano_embryo/presentation/features/search/models/search_filters.dart';
import 'package:nano_embryo/presentation/features/search/models/unified_search_result.dart';

/// Generic repository interface for search
abstract class SearchRepository<T extends UnifiedSearchResult> {
  Future<SearchPaginatedResult<T>> search({
    required String query,
    required SearchFilters filters,
    String? cursor,
    int limit = 20,
  });

  Future<List<String>> getSuggestions(String partialQuery);
  Future<void> logSearch(String query, int resultCount);
  Future<List<String>> getPopularSearches({int limit = 10});
}
