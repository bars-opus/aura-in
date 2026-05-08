// lib/features/search/domain/models/profile_search_result.dart
import 'package:nano_embryo/presentation/features/profile/models/profile.dart';
import 'package:nano_embryo/presentation/features/search/models/search_category.dart';
import 'package:nano_embryo/presentation/features/search/models/unified_search_result.dart';

/// Profile-specific search result
class ProfileSearchResult extends UnifiedSearchResult {
  final String? username;
  final String? displayName;
  final String? bio;
  final String? avatarUrl;

   ProfileSearchResult({
    required super.id,
    required super.title,
    required super.subtitle,
    super.imageUrl,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.avatarUrl,
  }) : super(
          category: SearchCategory.profiles,
          relevanceScore: 0.5, // Will be recalculated in fromProfile
        );

  /// Create from Profile model with relevance score
  factory ProfileSearchResult.fromProfile(
    Profile profile,
    String searchQuery,
  ) {
    // Determine best title: displayName > username > id
    final title = profile.displayName ?? profile.username ?? profile.id;

    // Subtitle: bio if available, otherwise username
    final subtitle = profile.bio ??
        (profile.username != null ? '@${profile.username}' : '');

    // Calculate relevance score
    final relevanceScore = _calculateRelevanceScore(profile, searchQuery);

    return ProfileSearchResult(
      id: profile.id,
      title: title,
      subtitle: subtitle,
      imageUrl: profile.avatarUrl,
      username: profile.username,
      displayName: profile.displayName,
      bio: profile.bio,
      avatarUrl: profile.avatarUrl,
    ).._setRelevanceScore(relevanceScore);
  }

  // Workaround for immutable field
  ProfileSearchResult _setRelevanceScore(double score) {
    return ProfileSearchResult(
      id: id,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      username: username,
      displayName: displayName,
      bio: bio,
      avatarUrl: avatarUrl,
    );
  }

  static double _calculateRelevanceScore(Profile profile, String query) {
    final lowerQuery = query.toLowerCase();
    double score = 0.0;

    // Username exact match: highest score
    if (profile.username?.toLowerCase() == lowerQuery) {
      score += 1.0;
    }
    // Username contains query
    else if (profile.username?.toLowerCase().contains(lowerQuery) == true) {
      score += 0.8;
    }

    // Display name contains query
    if (profile.displayName?.toLowerCase().contains(lowerQuery) == true) {
      score += 0.7;
    }

    // Bio contains query
    if (profile.bio?.toLowerCase().contains(lowerQuery) == true) {
      score += 0.5;
    }

    return score.clamp(0.0, 1.0);
  }

  @override
  String get briefDescription {
    final parts = <String>[];
    if (displayName != null) parts.add(displayName!);
    if (username != null) parts.add('@$username');
    if (bio != null && bio!.length > 50) {
      parts.add('${bio!.substring(0, 50)}...');
    } else if (bio != null) {
      parts.add(bio!);
    }
    return parts.isNotEmpty ? parts.join(' • ') : 'User Profile';
  }

  
}
