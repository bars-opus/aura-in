// lib/features/search/data/repositories/profile_search_repository.dart
import 'dart:developer' as developer;
import 'package:nano_embryo/presentation/features/profile/models/profile_search_result.dart';
import 'package:nano_embryo/presentation/features/search/models/search_paginated_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nano_embryo/presentation/features/profile/models/profile.dart';

/// Repository for searching profiles
class ProfileSearchRepository {
  static const int _maxLimit = 50;
  static const int _maxQueryLength = 100;

  final SupabaseClient _client;

  ProfileSearchRepository(this._client);

  /// Search profiles by query string
  Future<SearchPaginatedResult<ProfileSearchResult>> search({
    required String query,
    int limit = 20,
    String? cursor,
  }) async {
    if (query.isEmpty || query.length > _maxQueryLength) {
      return SearchPaginatedResult.empty();
    }

    final clampedLimit = limit.clamp(1, _maxLimit);
    final escapedQuery = _escapeLike(query);
    // Offset pagination keeps profile-search consistent with shops and
    // freelancers. The previous keyset on raw UUID was unsound — UUIDs
    // sort lexicographically, not by insertion order, so pages could
    // skip or repeat rows depending on how Postgres ordered the OR-set.
    final offset = int.tryParse(cursor ?? '') ?? 0;

    try {
      final hiddenResponse = await _client.rpc(
        'get_moderation_hidden_user_ids',
      );
      final hiddenIds =
          (hiddenResponse as List<dynamic>)
              .map((value) => value.toString())
              .where((value) => value.isNotEmpty)
              .toList();

      PostgrestFilterBuilder queryBuilder = _client
          .from('profiles')
          .select()
          .or(
            'username.ilike.%$escapedQuery%,'
            'display_name.ilike.%$escapedQuery%,'
            'bio.ilike.%$escapedQuery%',
          );

      if (hiddenIds.isNotEmpty) {
        final inList = hiddenIds.map((id) => '"$id"').join(',');
        queryBuilder = queryBuilder.not('id', 'in', '($inList)');
      }

      final response = await queryBuilder
          .order('created_at', ascending: false)
          .order('id')
          .range(offset, offset + clampedLimit);

      final profiles =
          (response as List).map((json) => Profile.fromJson(json)).toList();

      final hasMore = profiles.length > clampedLimit;
      final itemsToTake = hasMore ? clampedLimit : profiles.length;
      final items = profiles.take(itemsToTake).toList();

      final results =
          items.map((profile) {
            return ProfileSearchResult.fromProfile(profile, query);
          }).toList();

      final nextCursor = hasMore ? (offset + clampedLimit).toString() : null;

      return SearchPaginatedResult(
        items: results,
        nextCursor: nextCursor,
        totalCount: 0,
      );
    } catch (e, stack) {
      developer.log(
        'profile search failed',
        name: 'search',
        error: e,
        stackTrace: stack,
      );
      throw Exception('Search failed. Please try again.');
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

  /// Escapes `%`, `_`, `\` so user-typed wildcards match literally in ilike.
  static String _escapeLike(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll('%', '\\%')
        .replaceAll('_', '\\_');
  }
}
