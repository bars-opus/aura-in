// lib/features/search/domain/models/category_search_section.dart
import 'package:nano_embryo/presentation/features/search/models/search_category.dart';
import 'package:nano_embryo/presentation/features/search/models/unified_search_result.dart';

/// Represents a section of search results for a specific category
class CategorySearchSection {
  final SearchCategory category;
  final List<UnifiedSearchResult> results;
  final bool hasMore;
  final int totalCount;

  const CategorySearchSection({
    required this.category,
    required this.results,
    this.hasMore = false,
    this.totalCount = 0,
  });

  /// Check if "See All" button should be shown
  bool get showSeeAllButton => hasMore || (totalCount > results.length);

  /// Get display title for the section
  String get displayTitle => category.displayName;

  factory CategorySearchSection.empty(SearchCategory category) {
    return CategorySearchSection(
      category: category,
      results: const [],
      hasMore: false,
      totalCount: 0,
    );
  }
}
