// lib/features/search/data/repositories/profile_search_repository.dart
import 'package:nano_embryo/presentation/features/profile/models/profile_search_result.dart';
import 'package:nano_embryo/presentation/features/search/models/search_paginated_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nano_embryo/presentation/features/profile/models/profile.dart';

/// Repository for searching profiles
class ProfileSearchRepository {
  final SupabaseClient _client;

  ProfileSearchRepository(this._client);

  /// Search profiles by query string
  @override
  Future<SearchPaginatedResult<ProfileSearchResult>> search({
    required String query,
    int limit = 20,
    String? cursor,
  }) async {
    if (query.isEmpty) {
      return SearchPaginatedResult.empty();
    }

    try {
      // Start with PostgrestFilterBuilder
      PostgrestFilterBuilder queryBuilder = _client
          .from('profiles')
          .select()
          .or(
            'username.ilike.%$query%,'
            'display_name.ilike.%$query%,'
            'bio.ilike.%$query%',
          );

      // Apply cursor pagination BEFORE ordering
      if (cursor != null && cursor.isNotEmpty) {
        queryBuilder = queryBuilder.gt('id', cursor);
      }

      // Request ONE extra item to check if there are more
      final response = await queryBuilder
          .order('id', ascending: true)
          .limit(limit + 1); // 👈 Request limit + 1

      final profiles =
          (response as List).map((json) => Profile.fromJson(json)).toList();

      // Determine if there are more results
      final hasMore = profiles.length > limit;

      // Take only the requested amount
      final itemsToTake = hasMore ? limit : profiles.length;
      final items = profiles.take(itemsToTake).toList();

      final results =
          items.map((profile) {
            return ProfileSearchResult.fromProfile(profile, query);
          }).toList();

      //  Set nextCursor only if there are more results
      final nextCursor = hasMore ? results.last.id : null;

      return SearchPaginatedResult(
        items: results,
        nextCursor: nextCursor,
        totalCount: 0,
      );
    } catch (e) {
      throw Exception('Failed to search profiles: $e');
    }
  }

  /// Get popular profile searches (for suggestions)
  Future<List<String>> getPopularProfileSearches({int limit = 10}) async {
    try {
      final response = await _client
          .from('search_analytics')
          .select('query')
          .eq('category', 'profiles')
          .order('count', ascending: false)
          .limit(limit);

      return response.map((row) => row['query'] as String).toList();
    } catch (e) {
      return [];
    }
  }
}
