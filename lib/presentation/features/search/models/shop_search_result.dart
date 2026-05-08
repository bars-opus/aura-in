// lib/features/search/domain/models/shop_search_result.dart
import 'unified_search_result.dart';
import 'search_category.dart';

/// Shop-specific search result
class ShopSearchResult extends UnifiedSearchResult {
  final double? averageRating;
  final int? reviewCount;
  final bool verified;
  final String? luxuryLevel;
  final double? distanceKm;
  final List<String>? topServices;
  final bool isOpenNow;

  ShopSearchResult({
    required super.id,
    required super.title,
    required super.subtitle,
    super.imageUrl,
    required this.averageRating,
    required this.reviewCount,
    required this.verified,
    this.luxuryLevel,
    this.distanceKm,
    this.topServices,
    this.isOpenNow = false,
  }) : super(
         category: SearchCategory.shops,
         relevanceScore: _calculateRelevanceScore(averageRating, verified),
       );

  static double _calculateRelevanceScore(double? rating, bool verified) {
    double score = 0.5;
    if (verified) score += 0.3;
    if (rating != null && rating >= 4.5) score += 0.2;
    return score;
  }

  @override
  String get briefDescription {
    final parts = <String>[];
    if (averageRating != null)
      parts.add('${averageRating!.toStringAsFixed(1)}★');
    if (reviewCount != null) parts.add('(${reviewCount!} reviews)');
    if (distanceKm != null) parts.add('${distanceKm!.toStringAsFixed(1)}km');
    if (luxuryLevel != null) parts.add(luxuryLevel!);
    return parts.isEmpty ? 'Beauty & Grooming' : parts.join(' • ');
  }
}
