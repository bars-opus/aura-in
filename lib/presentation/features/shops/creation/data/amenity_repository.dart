// lib/features/shop/creation/data/amenity_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/amenity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AmenityRepository {
  final SupabaseClient _client;

  AmenityRepository(this._client);

  /// Get all available amenities from the database
  Future<List<Amenity>> getAllAmenities() async {
    try {
      final response = await _client
          .from('amenities')
          .select('*')
          .order('display_order', ascending: true);

      return (response as List)
          .map((json) => Amenity.fromJson(json))
          .toList();
    } catch (e) {
      return _getDefaultAmenities(); // Fallback to defaults
    }
  }

  /// Get amenities grouped by category
  Future<List<AmenityCategory>> getAmenitiesByCategory() async {
    final amenities = await getAllAmenities();
    
    // Group by category
    final Map<String, List<Amenity>> grouped = {};
    for (var amenity in amenities) {
      final category = amenity.category ?? 'Other';
      grouped.putIfAbsent(category, () => []).add(amenity);
    }

    // Convert to list of AmenityCategory
    return grouped.entries.map((entry) {
      return AmenityCategory(
        name: entry.key,
        amenities: entry.value..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)),
      );
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name)); // Sort categories alphabetically
  }

  /// Default amenities in case database fetch fails
  List<Amenity> _getDefaultAmenities() {
    return const [
      Amenity(id: 'wifi', name: 'Free WiFi', iconName: 'wifi', category: 'General', displayOrder: 1),
      Amenity(id: 'parking', name: 'Parking', iconName: 'local_parking', category: 'General', displayOrder: 2),
      Amenity(id: 'wheelchair', name: 'Wheelchair Access', iconName: 'accessible', category: 'Accessibility', displayOrder: 3),
      Amenity(id: 'coffee', name: 'Coffee/Tea', iconName: 'free_breakfast', category: 'Refreshments', displayOrder: 4),
      Amenity(id: 'credit_card', name: 'Credit Cards Accepted', iconName: 'credit_card', category: 'Payment', displayOrder: 5),
      Amenity(id: 'steam_room', name: 'Steam Room', iconName: 'hot_tub', category: 'Facilities', displayOrder: 6),
      Amenity(id: 'sauna', name: 'Sauna', iconName: 'hot_tub', category: 'Facilities', displayOrder: 7),
      Amenity(id: 'locker_room', name: 'Locker Room', iconName: 'locker', category: 'Facilities', displayOrder: 8),
    ];
  }
}

// Provider
final amenityRepositoryProvider = Provider<AmenityRepository>((ref) {
  final client = Supabase.instance.client;
  return AmenityRepository(client);
});

// Provider for amenities list
final allAmenitiesProvider = FutureProvider<List<Amenity>>((ref) {
  final repository = ref.watch(amenityRepositoryProvider);
  return repository.getAllAmenities();
});

// Provider for amenities by category
final amenitiesByCategoryProvider = FutureProvider<List<AmenityCategory>>((ref) {
  final repository = ref.watch(amenityRepositoryProvider);
  return repository.getAmenitiesByCategory();
});
