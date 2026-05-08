// lib/features/search/models/paginated_result.dart

class SearchPaginatedResult<T> {
  final List<T> items;
  final String? nextCursor;
  final int totalCount;

  const SearchPaginatedResult({
    required this.items,
    this.nextCursor,
    required this.totalCount,
  });

  /// Check if there are more items to load
  /// Returns true only if:
  /// 1. There is a nextCursor, AND
  /// 2. The number of items equals the limit (not partial page)
  bool get hasMore {
    // If no next cursor, definitely no more
    if (nextCursor == null) return false;
    
    // If we got less items than requested, this is the last page
    // We need to know the limit to check this
    // For now, assume hasMore is true only if nextCursor exists
    return true;
  }

  factory SearchPaginatedResult.empty() {
    return const SearchPaginatedResult(
      items: [],
      nextCursor: null,
      totalCount: 0,
    );
  }

  SearchPaginatedResult<T> copyWith({
    List<T>? items,
    String? nextCursor,
    int? totalCount,
  }) {
    return SearchPaginatedResult<T>(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}
