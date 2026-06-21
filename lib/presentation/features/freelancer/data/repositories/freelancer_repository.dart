// lib/features/freelancer/data/repositories/freelancer_repository.dart

import 'package:nano_embryo/presentation/features/freelancer/data/models/nearby_freelancer_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/paginated_result.dart';

/// A freelancer tag and how many discoverable freelancers carry it.
typedef TagCount = ({String tag, int count});

abstract class FreelancerRepository {
  // Get nearby freelancers (used by all)
  Future<List<NearbyFreelancerDTO>> getNearbyFreelancers({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
    int limit = 10,
    int offset = 0,
    String? freelancerType,
    List<String>? freelancerTypes,
    double? minRating,
    String sortBy = 'distance',
    List<String>? tags,
  });

  /// Distinct freelancer tags with counts, scoped to discoverable freelancers.
  Future<List<TagCount>> getFreelancerTags({
    double? latitude,
    double? longitude,
    double? radiusKm,
  });

  // Get top rated freelancers (paginated for "See All")
  Future<PaginatedResult<NearbyFreelancerDTO>> getTopRatedFreelancersPaginated({
    required double latitude,
    required double longitude,
    double radiusKm = 20,
    List<String>? freelancerTypes,
    int offset = 0,
    String? freelancerType,
    int limit = 20,
  });

  // Get nearby freelancers (paginated for "See All")
  Future<PaginatedResult<NearbyFreelancerDTO>> getNearbyFreelancersPaginated({
    required double latitude,
    required double longitude,
    double radiusKm = 5,
    int offset = 0,
    List<String>? freelancerTypes,
    String? freelancerType,
    int limit = 20,
  });

  // ✅ New: Get all freelancers with pagination (handles both location and no location)
  Future<PaginatedResult<NearbyFreelancerDTO>> getAllFreelancers({
    required double latitude,
    required double longitude,
    required bool hasLocation,
    int limit = 20,
    int offset = 0,
    List<String>? freelancerTypes,
  });
}
