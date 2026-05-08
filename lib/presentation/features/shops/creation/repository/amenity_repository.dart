// lib/features/shops/creation/data/repositories/amenity_repository.dart

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

      print('✅ Amenities loaded: ${(response as List).length} amenities found');
      return (response as List).map((json) => Amenity.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error loading amenities from database: $e');
      // Fallback to default amenities if database fetch fails
      return _getDefaultAmenities();
    }
  }

  /// Get amenities grouped by category
  Future<List<AmenityCategory>> getAmenitiesByCategory() async {
    final amenities = await getAllAmenities();

    final Map<String, List<Amenity>> grouped = {};
    for (final amenity in amenities) {
      final category = amenity.category ?? 'Other';
      grouped.putIfAbsent(category, () => []).add(amenity);
    }

    return grouped.entries.map((entry) {
        return AmenityCategory(
          name: entry.key,
          amenities:
              entry.value
                ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)),
        );
      }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Get amenities by specific category
  Future<List<Amenity>> getAmenitiesByCategoryName(String categoryName) async {
    final allAmenities = await getAllAmenities();
    return allAmenities
        .where((amenity) => amenity.category == categoryName)
        .toList();
  }

  /// Get shop's selected amenities
  Future<List<String>> getShopAmenities(String shopId) async {
    try {
      final response = await _client
          .from('shop_amenities')
          .select('amenity_id')
          .eq('shop_id', shopId);

      return (response as List)
          .map((json) => json['amenity_id'] as String)
          .toList();
    } catch (e) {
      print('Error getting shop amenities: $e');
      return [];
    }
  }

  /// Update shop's amenities
  Future<void> updateShopAmenities({
    required String shopId,
    required List<String> amenityIds,
  }) async {
    try {
      // Delete existing assignments
      await _client.from('shop_amenities').delete().eq('shop_id', shopId);

      // Insert new assignments
      if (amenityIds.isNotEmpty) {
        final assignments =
            amenityIds
                .map(
                  (amenityId) => {'shop_id': shopId, 'amenity_id': amenityId},
                )
                .toList();

        await _client.from('shop_amenities').insert(assignments);
        print('✅ Updated shop amenities: ${amenityIds.length} amenities');
      }
    } catch (e) {
      print('❌ Failed to update shop amenities: $e');
      throw Exception('Failed to update shop amenities: $e');
    }
  }

  /// Default amenities in case database fetch fails (fallback)
  List<Amenity> _getDefaultAmenities() {
    print('⚠️ Using default amenities (database fetch failed)');
    return const [
      Amenity(
        id: 'wifi',
        name: 'Free WiFi',
        iconName: 'wifi',
        category: 'General',
        displayOrder: 1,
      ),
      Amenity(
        id: 'parking',
        name: 'Free Parking',
        iconName: 'local_parking',
        category: 'General',
        displayOrder: 2,
      ),
      Amenity(
        id: 'credit_card',
        name: 'Credit Cards Accepted',
        iconName: 'credit_card',
        category: 'General',
        displayOrder: 3,
      ),
      Amenity(
        id: 'coffee',
        name: 'Complimentary Coffee/Tea',
        iconName: 'free_breakfast',
        category: 'Refreshments',
        displayOrder: 4,
      ),
      Amenity(
        id: 'wheelchair',
        name: 'Wheelchair Accessible',
        iconName: 'accessible',
        category: 'Accessibility',
        displayOrder: 5,
      ),
      Amenity(
        id: 'organic',
        name: 'Organic Products',
        iconName: 'eco',
        category: 'Eco-Friendly',
        displayOrder: 6,
      ),
    ];
  }
}

// Providers
final amenityRepositoryProvider = Provider<AmenityRepository>((ref) {
  final client = Supabase.instance.client;
  return AmenityRepository(client);
});

final allAmenitiesProvider = FutureProvider<List<Amenity>>((ref) {
  final repository = ref.watch(amenityRepositoryProvider);
  return repository.getAllAmenities();
});

final amenitiesByCategoryProvider = FutureProvider<List<AmenityCategory>>((
  ref,
) {
  final repository = ref.watch(amenityRepositoryProvider);
  return repository.getAmenitiesByCategory();
});
