// lib/features/search/presentation/state/search_state.dart
import 'package:flutter/foundation.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

// Make sure these imports are at the top:
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nano_embryo/presentation/features/search/models/search_filters.dart';
import 'package:nano_embryo/presentation/features/search/models/searh_results.dart';



// If you also want JSON serialization:
/// Represents the current state of search operations
class SearchState {
  final bool isLoading;
  final List<SearchResultItem>? results;
  final String? error;
  final String query;
  final bool isEmpty;
  final SearchFilters filters; // SINGLE parameter - named 'filters'

  const SearchState._({
    this.isLoading = false,
    this.results,
    this.error,
    this.query = '',
    this.isEmpty = false,
    required this.filters, // Just 'filters'
  });

  // Factory constructors - ALL use 'filters' parameter
  factory SearchState.initial() =>
      SearchState._(filters: const SearchFilters());

  factory SearchState.loading({
    required String query,
    required SearchFilters filters, // 'filters'
  }) => SearchState._(isLoading: true, query: query, filters: filters);

  factory SearchState.success({
    required List<SearchResultItem> results,
    required String query,
    required SearchFilters filters, // 'filters'
  }) => SearchState._(results: results, query: query, filters: filters);

  factory SearchState.empty({
    required String query,
    required SearchFilters filters, // 'filters'
  }) => SearchState._(query: query, isEmpty: true, filters: filters);

  factory SearchState.error({
    required String error,
    required String query,
    required SearchFilters filters, // 'filters'
  }) => SearchState._(error: error, query: query, filters: filters);

  // Helper methods
  bool get isInitial =>
      !isLoading && results == null && error == null && query.isEmpty;

  // Pattern matching
  T map<T>({
    required T Function() initial,
    required T Function(String query, SearchFilters filters) loading,
    required T Function(
      List<SearchResultItem> results,
      String query,
      SearchFilters filters,
    )
    success,
    required T Function(String query, SearchFilters filters) empty,
    required T Function(String error, String query, SearchFilters filters)
    error,
  }) {
    if (isLoading) return loading(query, filters);
    if (this.error != null) return error(this.error!, query, filters);
    if (isEmpty) return empty(query, filters);
    if (results != null) return success(results!, query, filters);
    return initial();
  }

  
}
