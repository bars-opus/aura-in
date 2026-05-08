// // lib/features/search/data/analytics/search_analytics.dart



// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:nano_embryo/presentation/features/search/models/search_category.dart';
// import 'package:nano_embryo/presentation/features/search/models/search_filters.dart';
// import 'package:nano_embryo/presentation/features/search/models/unified_search_result.dart';

// class SearchAnalytics {
//   static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

//   /// Log search performed
//   static Future<void> logSearch({
//     required String query,
//     required int resultCount,
//     required bool hasFilters,
//     String? category,
//   }) async {
//     await _analytics.logSearch(
//       searchTerm: query,
//       parameters: {
//         'result_count': resultCount,
//         'has_filters': hasFilters,
//         'category': category ?? 'all',
//         'timestamp': DateTime.now().millisecondsSinceEpoch,
//       },
//     );
//   }

//   /// Log result click
//   static Future<void> logResultClick({
//     required UnifiedSearchResult result,
//     required int position,
//     required String query,
//   }) async {
//     await _analytics.logSelectContent(
//       contentType: result.category.displayName,
//       itemId: result.id,
//       parameters: {
//         'title': result.title,
//         'position': position,
//         'search_query': query,
//         'category': result.category.displayName,
//       },
//     );
//   }

//   /// Log filter application
//   static Future<void> logFilterApplied({
//     required SearchFilters filters,
//     required String query,
//   }) async {
//     final params = <String, dynamic>{
//       'query': query,
//       'verified_only': filters.verifiedOnly ?? false,
//       'sort_by': filters.sortBy ?? 'relevance',
//     };
    
//     if (filters.luxuryLevel != null) {
//       params['luxury_level'] = filters.luxuryLevel;
//     }
//     if (filters.minRating != null) {
//       params['min_rating'] = filters.minRating;
//     }
    
//     await _analytics.logEvent(
//       name: 'apply_filters',
//       parameters: params,
//     );
//   }

//   /// Log "See All" click
//   static Future<void> logSeeAllClick({
//     required SearchCategory category,
//     required String query,
//     required int resultCount,
//   }) async {
//     await _analytics.logEvent(
//       name: 'see_all_click',
//       parameters: {
//         'category': category.displayName,
//         'query': query,
//         'result_count': resultCount,
//       },
//     );
//   }

//   /// Log pagination load more
//   static Future<void> logLoadMore({
//     required SearchCategory category,
//     required String query,
//     required int currentPage,
//   }) async {
//     await _analytics.logEvent(
//       name: 'load_more',
//       parameters: {
//         'category': category.displayName,
//         'query': query,
//         'page': currentPage,
//       },
//     );
//   }

//   /// Log error
//   static Future<void> logSearchError({
//     required String query,
//     required String error,
//     String? category,
//   }) async {
//     await _analytics.logEvent(
//       name: 'search_error',
//       parameters: {
//         'query': query,
//         'error': error,
//         'category': category ?? 'all',
//       },
//     );
//   }
// }
