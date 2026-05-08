// lib/features/search/domain/models/search_result_item.dart
import 'search_category.dart';

/// Base sealed class for all search results
/// This allows polymorphic handling of different result types
class SearchResultItem {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final SearchCategory category;
  final double relevanceScore;
  final Map<String, dynamic> metadata;

  const SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.category,
    this.relevanceScore = 0.0,
    this.metadata = const {},
  });

  /// Get a brief description for the result (used in UI)
  String get briefDescription => subtitle;

  /// Get the primary action label (e.g., "View Shop", "Hire", "Buy")
  String get actionLabel {
    switch (category) {
      case SearchCategory.shops:
        return 'View Shop';
      case SearchCategory.freelancers:
        return 'Hire';
      case SearchCategory.products:
        return 'View Product';
      case SearchCategory.profiles:
        return 'View Profiles';
      case SearchCategory.all:
        return 'View All';
    }
  }
}
