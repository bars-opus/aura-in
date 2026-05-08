// lib/features/search/domain/models/unified_search_result.dart
import 'dart:convert';

import 'search_category.dart';

/// Base sealed class for all search results
class UnifiedSearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final SearchCategory category;
  final double relevanceScore;
  final Map<String, dynamic> metadata;

  UnifiedSearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.category,
    required this.relevanceScore,
    this.metadata = const {},
  });

  String get actionLabel {
    switch (category) {
      case SearchCategory.shops:
        return 'View Shop';
      case SearchCategory.profiles:
        return 'View Profile';
      case SearchCategory.freelancers:
        return 'Hire';
      case SearchCategory.products:
        return 'Buy';
      case SearchCategory.all:
        return 'View';
    }
  }

  /// Get a brief description for the result
  String get briefDescription => subtitle;

  @override
  String toString() => '$runtimeType: $title (${category.displayName})';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      // store enum by name for readability/stability
      'category': category.name,
      // ensure double is preserved
      'relevanceScore': relevanceScore,
      // metadata should already be Map<String, dynamic>, but ensure it's JSON-friendly
      'metadata': metadata,
    };
  }

  /// Creates a UnifiedSearchResult from a JSON map.
  /// Throws a FormatException if required fields are missing or invalid.
  factory UnifiedSearchResult.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw FormatException('json is null');
    }

    // Helper to parse enum by name safely
    SearchCategory parseCategory(dynamic value) {
      if (value == null) {
        throw FormatException('Missing required field "category"');
      }
      if (value is SearchCategory) return value;
      final v = value.toString();
      try {
        return SearchCategory.values.firstWhere(
          (e) => e.name == v || e.toString().split('.').last == v,
        );
      } catch (_) {
        // Fallback: try case-insensitive match on name
        final lower = v.toLowerCase();
        final match = SearchCategory.values.firstWhere(
          (e) =>
              e.name.toLowerCase() == lower ||
              e.toString().split('.').last.toLowerCase() == lower,
          orElse:
              () =>
                  throw FormatException('Unknown SearchCategory value: $value'),
        );
        return match;
      }
    }

    String parseStringField(String key, {bool required = true}) {
      final v = json[key];
      if (v == null) {
        if (required) throw FormatException('Missing required field "$key"');
        return '';
      }
      return v.toString();
    }

    final id = parseStringField('id');
    final title = parseStringField('title');
    final subtitle = parseStringField('subtitle');

    final imageUrlDynamic = json['imageUrl'];
    final String? imageUrl =
        imageUrlDynamic == null ? null : imageUrlDynamic.toString();

    final category = parseCategory(json['category']);

    // relevanceScore may be int, double, or string. Parse to double.
    double parseRelevance(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) {
        final parsed = double.tryParse(v);
        if (parsed != null) return parsed;
      }
      throw FormatException('Invalid relevanceScore: $v');
    }

    final relevanceScore = parseRelevance(json['relevanceScore']);

    // metadata: ensure Map<String, dynamic>
    final metadataDynamic = json['metadata'];
    Map<String, dynamic> metadata;
    if (metadataDynamic == null) {
      metadata = {};
    } else if (metadataDynamic is Map) {
      // Cast keys to String, values to dynamic
      metadata = Map<String, dynamic>.from(metadataDynamic);
    } else if (metadataDynamic is String) {
      // Try parsing from JSON string
      try {
        final decoded = jsonDecode(metadataDynamic);
        if (decoded is Map) {
          metadata = Map<String, dynamic>.from(decoded);
        } else {
          metadata = {};
        }
      } catch (_) {
        metadata = {};
      }
    } else {
      metadata = {};
    }

    return UnifiedSearchResult(
      id: id,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      category: category,
      relevanceScore: relevanceScore,
      metadata: metadata,
    );
  }
}
