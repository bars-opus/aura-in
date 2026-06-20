// lib/features/shops/data/repositories/shop_repository.dart
import 'package:nano_embryo/presentation/features/search/models/search_paginated_result.dart';
import 'package:nano_embryo/presentation/features/search/models/shop_query_params.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_details_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/data/models/booking_review.dart';

/// Query parameters for fetching shops

// In your shop_query_params.dart file

abstract class ShopRepository {
  /// Get all shop types with their shop counts (only those with count > 0)
  Future<List<ShopTypeCount>> getShopTypeCounts();

  /// Get luxury levels with counts for a specific shop type
  Future<List<LuxuryLevelInfo>> getLuxuryLevels(String shopType);

  /// Get paginated list of shops based on filters
  Future<SearchPaginatedResult<ShopListItemDTO>> getShops(
    ShopQueryParams params,
  );


  // New methods for multi-shop support
  Future<List<ShopListItemDTO>> getShopsByProfileId(String profileId);


  /// Get a single shop by its ID (for details screen)
  Future<ShopDetailsDTO> getShopDetailsById(String shopId);

  /// Get all reviews for a specific shop
  Future<List<BookingReview>> getShopReviews(String shopId);

  /// Get all appointment slots for a shop
  Future<List<AppointmentSlotDTO>> getAppointmentSlots(String shopId);

  /// Get all workers for a shop
  Future<List<WorkerDTO>> getWorkers(String shopId);

  /// Get opening hours for a shop
  Future<Map<String, DateTimeRange>> getOpeningHours(String shopId);

  /// Get workers assigned to specific slots
  Future<Map<String, List<String>>> getSlotWorkerAssignments(String shopId);

  /// Get workers assigned to specific slots
  Future<List<WorkerDTO>> getAllWorkersForShop(String shopId);

  /// Get worker details by IDs
  Future<List<WorkerDTO>> getWorkersByIds(List<String> workerIds);

  /// Get premium shops (Luxury/UltraLuxury) for a specific shop type (limited)
  Future<List<ShopListItemDTO>> getPremiumShops({
    required String shopType,
    String? luxuryLevel,
    UserLocation? userLocation,
    int limit = 10,
    int seed = 0,
  });

  /// Get paginated premium shops for "See all"
  Future<SearchPaginatedResult<ShopListItemDTO>> getPremiumShopsPaginated({
    required String shopType,
    String? luxuryLevel,
    String? cursor,
    bool? verifiedOnly,
    String? sortBy,
    int limit = AppConstants.shopsPerPage,
    int seed = 0,
  });

  /// Get top rated shops (rating >= 4.5) for a specific shop type (limited)
  Future<List<ShopListItemDTO>> getTopRatedShops({
    required String shopType,
    double minRating = 4.5,
    int minReviews = 5,
    int limit = AppConstants.shopsPerPage,
    int seed = 0,
  });

  /// Get paginated top rated shops for "See all"
  Future<SearchPaginatedResult<ShopListItemDTO>> getTopRatedShopsPaginated({
    required String shopType,
    double minRating = 4.5,
    int minReviews = 5,
    String? cursor,
    String? luxuryLevel,
    int limit = AppConstants.shopsPerPage,
    bool? verifiedOnly,
    String? sortBy,
    int seed = 0,
  });

  /// Get shops near a location (within 2km)
  Future<List<ShopListItemDTO>> getNearbyShops({
    required double latitude,
    required double longitude,
    double radiusKm = 2.0,
    int limit = 10,
    int seed = 0,
  });

  /// Get paginated nearby shops for "See all"
  Future<SearchPaginatedResult<ShopListItemDTO>> getNearbyShopsPaginated({
    required double latitude,
    required double longitude,
    double radiusKm = 2.0,
    String? cursor,
    String? luxuryLevel,
    int limit = 20,
    bool? verifiedOnly,
    String? sortBy,
    int seed = 0,
  });

  //Get map shops
  Future<ShopListItemDTO> getMarkerShopDetails(String shopId);
}
