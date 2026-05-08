// lib/features/search/domain/models/search_filters.dart
import 'package:equatable/equatable.dart';
import 'search_category.dart';

/// Base search filters applicable to all categories
class SearchFilters extends Equatable {
  final String? query;
  final SearchCategory? category;
  final bool? verifiedOnly;
  final String? sortBy; // 'relevance', 'rating', 'distance', 'newest'
  final double? minRating;
  final UserLocation? userLocation;
  final String? luxuryLevel;

  const SearchFilters({
    this.query,
    this.category,
    this.verifiedOnly,
    this.sortBy,
    this.minRating,
    this.userLocation,
    this.luxuryLevel,
  });

  /// Create a copy with updated fields
  SearchFilters copyWith({
    String? query,
    SearchCategory? category,
    bool? verifiedOnly,
    String? sortBy,
    double? minRating,
    UserLocation? userLocation,
    String? luxuryLevel,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      category: category ?? this.category,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      sortBy: sortBy ?? this.sortBy,
      minRating: minRating ?? this.minRating,
      userLocation: userLocation ?? this.userLocation,
      luxuryLevel: luxuryLevel ?? this.luxuryLevel,
    );
  }

  @override
  List<Object?> get props => [
    query,
    category,
    verifiedOnly,
    sortBy,
    minRating,
    userLocation,
    luxuryLevel,
  ];
}

/// User location for distance-based search
class UserLocation extends Equatable {
  final double latitude;
  final double longitude;

  const UserLocation({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}
