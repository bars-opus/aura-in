// lib/features/search/domain/models/search_params.dart


import 'package:nano_embryo/presentation/features/search/models/search_category.dart';
import 'package:nano_embryo/presentation/features/search/models/search_filters.dart';

/// Base parameters for search operations
class SearchParams {
  final String query;
  final SearchFilters filters;
  final SearchCategory? category;
  final String? cursor;
  final int limit;

  const SearchParams({
    required this.query,
    required this.filters,
    this.category,
    this.cursor,
    this.limit = 20,
  });

  /// Create params for "All" view (5 items per category)
  factory SearchParams.forAllView({
    required String query,
    required SearchFilters filters,
  }) {
    return SearchParams(
      query: query,
      filters: filters,
      limit: 5,
    );
  }

  /// Create params for category-specific view (15 initial, 5 per page)
  factory SearchParams.forCategoryView({
    required String query,
    required SearchFilters filters,
    required SearchCategory category,
    String? cursor,
    bool isInitialLoad = true, required int limit,
  }) {
    return SearchParams(
      query: query,
      filters: filters,
      category: category,
      cursor: cursor,
      limit: isInitialLoad ? 15 : 5,
    );
  }

  SearchParams copyWith({
    String? query,
    SearchFilters? filters,
    SearchCategory? category,
    String? cursor,
    int? limit,
  }) {
    return SearchParams(
      query: query ?? this.query,
      filters: filters ?? this.filters,
      category: category ?? this.category,
      cursor: cursor ?? this.cursor,
      limit: limit ?? this.limit,
    );
  }
}
