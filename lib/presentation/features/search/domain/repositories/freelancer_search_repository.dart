// lib/features/search/data/repositories/freelancer_search_repository.dart
import 'package:nano_embryo/presentation/features/freelancer/data/models/nearby_freelancer_dto.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/repositories/freelancer_repository.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/repositories/supabase_freelancer_repository.dart';
import 'package:nano_embryo/presentation/features/search/domain/repositories/search_repository.dart';
import 'package:nano_embryo/presentation/features/search/models/freelancer_search_result.dart';
import 'package:nano_embryo/presentation/features/search/models/search_filters.dart';
import 'package:nano_embryo/presentation/features/search/models/search_paginated_result.dart';

class FreelancerSearchRepository
    implements SearchRepository<FreelancerSearchResult> {
  final SupabaseFreelancerRepository _freelancerRepository;

  FreelancerSearchRepository(this._freelancerRepository);

  @override
  Future<SearchPaginatedResult<FreelancerSearchResult>> search({
    required String query,
    required SearchFilters filters,
    String? cursor,
    int limit = 20,
  }) async {
    // If there's a text query, search by name first
    if (query.isNotEmpty) {
      try {
        final offset = cursor != null ? int.tryParse(cursor) ?? 0 : 0;

        final result = await _freelancerRepository.searchFreelancersByName(
          query: query,
          limit: limit,
          offset: offset,
        );

        final results =
            result.items.map((freelancer) {
              return FreelancerSearchResult.fromNearbyFreelancer(
                freelancer,
                query,
              );
            }).toList();

        final nextCursor = result.nextOffset?.toString();

        if (results.isNotEmpty) {
          return SearchPaginatedResult(
            items: results,
            nextCursor: nextCursor,
            totalCount: result.totalCount,
          );
        }
      } catch (e) {
        print('Name search failed: $e');
      }
    }

    // Fallback to nearby search if location is available
    if (filters.userLocation != null) {
      try {
        final offset = cursor != null ? int.tryParse(cursor) ?? 0 : 0;

        final result = await _freelancerRepository
            .getNearbyFreelancersPaginated(
              latitude: filters.userLocation!.latitude,
              longitude: filters.userLocation!.longitude,
              radiusKm: 20,
              offset: offset,
              freelancerTypes: _getFreelancerTypesFromFilters(filters),
              limit: limit,
            );

        final results =
            result.items.map((freelancer) {
              return FreelancerSearchResult.fromNearbyFreelancer(
                freelancer,
                query,
              );
            }).toList();

        final nextCursor = result.nextOffset?.toString();

        return SearchPaginatedResult(
          items: results,
          nextCursor: nextCursor,
          totalCount: result.totalCount,
        );
      } catch (e) {
        print('Nearby search failed: $e');
      }
    }

    return SearchPaginatedResult.empty();
  }

  List<String>? _getFreelancerTypesFromFilters(SearchFilters filters) {
    // This can be expanded based on your filter needs
    // For example, if you add a freelancerType filter to SearchFilters
    return null;
  }

  @override
  Future<List<String>> getSuggestions(String partialQuery) async {
    return [];
  }

  @override
  Future<void> logSearch(String query, int resultCount) async {
    // Implement analytics if needed
  }

  @override
  Future<List<String>> getPopularSearches({int limit = 10}) async {
    return [];
  }
}
