// lib/features/search/domain/models/paginated_result.dart
/// Generic paginated result wrapper - matches Supabase repository pattern
class PaginatedResult<T> {
  final List<T> items;
  final String? nextCursor;
  final int totalCount;
  final int? nextOffset;

  const PaginatedResult({
    required this.items,
    this.nextCursor,
    this.nextOffset,
    required this.totalCount,
  });

  /// Helper to check if there are more items to load
  bool get hasMore => nextCursor != null && items.isNotEmpty;

  /// Factory for empty result
  factory PaginatedResult.empty() {
    return const PaginatedResult(items: [], nextCursor: null, totalCount: 0, nextOffset:0);
  }

  /// Create a copy with updated fields
  PaginatedResult<T> copyWith({
    List<T>? items,
    String? nextCursor,
    int? totalCount,
    int? nextOffset,
  }) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      totalCount: totalCount ?? this.totalCount,
      nextOffset: nextOffset ?? this.nextOffset,
    );
  }
}
