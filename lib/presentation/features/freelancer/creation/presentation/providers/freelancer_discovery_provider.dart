// lib/features/freelancer/presentation/providers/freelancer_discovery_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/location_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/models/nearby_freelancer_dto.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/repositories/supabase_freelancer_repository.dart';
import 'package:nano_embryo/presentation/features/freelancer/enums/freelancer_category_mapper.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/paginated_result.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/search_radius_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/service_category_provider.dart';

/// Filter state for freelancer discovery
class FreelancerFilterState {
  final double radiusKm;
  final String? freelancerType;
  final double? minRating;
  final String sortBy;

  const FreelancerFilterState({
    this.radiusKm = 10,
    this.freelancerType,
    this.minRating,
    this.sortBy = 'distance',
  });

  FreelancerFilterState copyWith({
    double? radiusKm,
    String? freelancerType,
    double? minRating,
    String? sortBy,
  }) {
    return FreelancerFilterState(
      radiusKm: radiusKm ?? this.radiusKm,
      freelancerType: freelancerType ?? this.freelancerType,
      minRating: minRating ?? this.minRating,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

/// Provider for freelancer filter state
final freelancerFilterProvider = StateProvider<FreelancerFilterState>((ref) {
  return const FreelancerFilterState();
});

/// Provider for nearby freelancers discovery (main grid - requires location)
final freelancerDiscoveryProvider = FutureProvider<List<NearbyFreelancerDTO>>((
  ref,
) async {
  final userLocation = ref.watch(userLocationNotifierProvider);
  final selectedCategory = ref.watch(selectedServiceCategoryProvider);
  final filter = ref.watch(freelancerFilterProvider);
  final repository = ref.watch(freelancerRepositoryProvider);

  if (userLocation == null) {
    throw Exception('Location not available. Please set your location.');
  }

  final freelancerTypes =
      FreelancerCategoryMapper.getFreelancerTypesForCategory(selectedCategory);

  return repository.getNearbyFreelancers(
    latitude: userLocation.latitude,
    longitude: userLocation.longitude,
    radiusKm: filter.radiusKm,
    limit: 50,
    freelancerTypes: freelancerTypes.isEmpty ? null : freelancerTypes,
    minRating: filter.minRating,
    sortBy: filter.sortBy,
  );
});

/// Provider for top rated freelancers (horizontal section)
final topRatedFreelancersProvider = FutureProvider<List<NearbyFreelancerDTO>>((
  ref,
) async {
  final userLocation = ref.watch(userLocationNotifierProvider);
  final selectedCategory = ref.watch(selectedServiceCategoryProvider);
  final repository = ref.watch(freelancerRepositoryProvider);

  if (userLocation == null) return [];
  final freelancerTypes =
      FreelancerCategoryMapper.getFreelancerTypesForCategory(selectedCategory);

  return repository.getNearbyFreelancers(
    latitude: userLocation.latitude,
    longitude: userLocation.longitude,
    radiusKm: 20,
    limit: 10,
    freelancerTypes: freelancerTypes.isEmpty ? null : freelancerTypes,
    minRating: 4.5,
    sortBy: 'rating',
  );
});

/// Provider for nearby freelancers (horizontal section).
/// Watches the discover-screen radius slider so changes refetch automatically.
final nearYouFreelancersProvider = FutureProvider<List<NearbyFreelancerDTO>>((
  ref,
) async {
  final userLocation = ref.watch(userLocationNotifierProvider);
  final selectedCategory = ref.watch(selectedServiceCategoryProvider);
  final repository = ref.watch(freelancerRepositoryProvider);
  final radiusKm = ref.watch(searchRadiusKmProvider);

  if (userLocation == null) return [];
  final freelancerTypes =
      FreelancerCategoryMapper.getFreelancerTypesForCategory(selectedCategory);

  return repository.getNearbyFreelancers(
    latitude: userLocation.latitude,
    longitude: userLocation.longitude,
    radiusKm: radiusKm,
    freelancerTypes: freelancerTypes.isEmpty ? null : freelancerTypes,
    limit: 10,
    sortBy: 'distance',
  );
});

/// ✅ Provider for main freelancer grid with pagination support
// In freelancer_discovery_provider.dart

/// Provider for all freelancers (handles both location and no location).
/// Watches the discover-screen radius slider so changes refetch automatically.
final allFreelancersProvider = FutureProvider<List<NearbyFreelancerDTO>>((ref) async {
  final userLocation = ref.watch(userLocationNotifierProvider);
  final selectedCategory = ref.watch(selectedServiceCategoryProvider);
  final repository = ref.watch(freelancerRepositoryProvider);
  final radiusKm = ref.watch(searchRadiusKmProvider);

  final freelancerTypes = FreelancerCategoryMapper.getFreelancerTypesForCategory(selectedCategory);

  // If location is available, get nearby
  if (userLocation != null) {
    return repository.getNearbyFreelancers(
      latitude: userLocation.latitude,
      longitude: userLocation.longitude,
      radiusKm: radiusKm,
      limit: 50,
      freelancerTypes: freelancerTypes.isEmpty ? null : freelancerTypes,
      sortBy: 'distance',
    );
  }
  
  // No location: fetch random freelancers from database
  final result = await repository.getAllFreelancers(
    latitude: 0,
    longitude: 0,
    hasLocation: false,
    limit: 50,
    offset: 0,
    freelancerTypes: freelancerTypes.isEmpty ? null : freelancerTypes,
  );
  
  return result.items;
});

/// Provider for checking if freelancers are available in user's area
final hasFreelancersNearbyProvider = FutureProvider<bool>((ref) async {
  final userLocation = ref.watch(userLocationNotifierProvider);
  final repository = ref.watch(freelancerRepositoryProvider);

  if (userLocation == null) return false;

  final freelancers = await repository.getNearbyFreelancers(
    latitude: userLocation.latitude,
    longitude: userLocation.longitude,
    radiusKm: 10,
    limit: 1,
  );

  return freelancers.isNotEmpty;
});
