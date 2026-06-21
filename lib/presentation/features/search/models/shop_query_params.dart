import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/search/models/search_filters.dart';

class ShopQueryParams extends Equatable {
  final String? shopType;
  final String? luxuryLevel;
  final bool? verifiedOnly;
  final String? sortBy;
  final String? cursor;
  final int limit;
  final double? minRating;
  final UserLocation? userLocation;
  final String? searchQuery;
  final int? seed;

  const ShopQueryParams({
    this.shopType,
    this.luxuryLevel,
    this.verifiedOnly,
    this.sortBy,
    this.cursor,
    required this.limit,
    this.minRating,
    this.userLocation,
    this.searchQuery,
    this.seed,
  });

  /// Copy with method for updating parameters
  ShopQueryParams copyWith({
    String? shopType,
    String? luxuryLevel,
    bool? verifiedOnly,
    String? sortBy,
    String? cursor,
    int? limit,
    double? minRating,
    UserLocation? userLocation,
    String? searchQuery,
    int? seed,
  }) {
    return ShopQueryParams(
      shopType: shopType ?? this.shopType,
      luxuryLevel: luxuryLevel ?? this.luxuryLevel,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      sortBy: sortBy ?? this.sortBy,
      cursor: cursor ?? this.cursor,
      limit: limit ?? this.limit,
      minRating: minRating ?? this.minRating,
      userLocation: userLocation ?? this.userLocation,
      searchQuery: searchQuery ?? this.searchQuery,
      seed: seed ?? this.seed,
    );
  }

  /// Convert to JSON map for API requests.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'limit': limit};
    if (shopType != null) data['shopType'] = shopType;
    if (luxuryLevel != null) data['luxuryLevel'] = luxuryLevel;
    if (verifiedOnly != null) data['verifiedOnly'] = verifiedOnly;
    if (sortBy != null) data['sortBy'] = sortBy;
    if (cursor != null) data['cursor'] = cursor;
    if (minRating != null) data['minRating'] = minRating;
    if (userLocation != null) data['userLocation'] = userLocation!;
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      data['searchQuery'] = searchQuery;
    }
    return data;
  }

  @override
  List<Object?> get props => [
    shopType,
    luxuryLevel,
    verifiedOnly,
    sortBy,
    cursor,
    limit,
    minRating,
    userLocation,
    searchQuery,
    seed,
  ];

  @override
  String toString() {
    return 'ShopQueryParams(shopType: $shopType, luxuryLevel: $luxuryLevel, verifiedOnly: $verifiedOnly, sortBy: $sortBy, cursor: $cursor, limit: $limit, minRating: $minRating, userLocation: $userLocation, searchQuery: $searchQuery)';
  }
}
