// lib/features/shop/creation/data/shop_creation_repository.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/shop_draft.dart';

class SupabaseShopCreationRepository {
  final SupabaseClient _client;

  SupabaseShopCreationRepository(this._client);

  /// Create a new shop record and return the shop ID
  Future<String> createShop({
    required String profileId,
    required ShopDraft draft,
    required List<String> imageUrls,
    required List<String> documentUrls,
    String? logoUrl,
  }) async {
    final shopId = Uuid().v4();
    bool success = false;

    try {
      // 1. Insert main shop record
      await _client.from('shops').insert({
        'id': shopId,
        'user_id': profileId,
        'shop_name': draft.shopName,
        'shop_type': draft.shopType,
        'luxury_level': draft.luxuryLevel,
        'overview': draft.overview,
        'terms': draft.terms,
        'verified': false,
        'average_rating': 0,
        'number_clients_worked': 0,
        // Fallback to USD when currency wasn't set (country not in mapper
        // or user skipped the location screen without selecting a currency).
        'currency': draft.currencyCode ?? 'USD',
        'currency_symbol': draft.currencySymbol ?? '\$',
        'amenities': draft.amenityIds,
        if (logoUrl != null) 'shop_logo_url': logoUrl,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 2. Location
      if (draft.address != null) {
        await _client.from('shop_locations').insert({
          'shop_id': shopId,
          'address': draft.address,
          'city': draft.city,
          'country': draft.country ?? 'USA',
          'latitude': draft.latitude,
          'longitude': draft.longitude,
          'is_primary': true,
        });
      }

      // 3. Contacts — draft.contacts is the source of truth.
      // Fall back to scalar fields for shops created before the contacts-list
      // migration. Never insert both — that causes duplicate rows.
      final contactsToSave =
          draft.contacts.isNotEmpty
              ? draft.contacts
              : [
                  if (draft.phone != null && draft.phone!.isNotEmpty)
                    ContactDraft(
                      type: ContactType.phone,
                      value: draft.phone!,
                      isPrimary: true,
                    ),
                  if (draft.email != null && draft.email!.isNotEmpty)
                    ContactDraft(
                      type: ContactType.email,
                      value: draft.email!,
                      isPrimary: true,
                    ),
                  if (draft.website != null && draft.website!.isNotEmpty)
                    ContactDraft(
                      type: ContactType.website,
                      value: draft.website!,
                      isPrimary: false,
                    ),
                ];
      for (final contact in contactsToSave) {
        await _client.from('shop_contacts').insert({
          'shop_id': shopId,
          'contact_type': contact.type.name,
          'value': contact.value,
          'is_primary': contact.isPrimary,
        });
      }

      // 4. Social links
      for (final link in draft.socialLinks) {
        await _client.from('shop_social_links').insert({
          'shop_id': shopId,
          'url': link.url,
        });
      }

      // 5. Services (Appointment Slots)
      for (final service in draft.services) {
        await _client.from('appointment_slots').insert({
          'id': Uuid().v4(),
          'shop_id': shopId,
          'service_name': service.serviceName,
          'duration': service.duration,
          'price': service.price,
          'slot_type': service.slotType,
          'max_clients': service.maxClients,
          'days_of_week': service.daysOfWeek,
          'select_preferred_worker': service.selectPreferredWorker,
          'buffer_before_minutes': service.bufferBeforeMinutes,
          'buffer_minutes': service.bufferMinutes,
          'is_online_booking_enabled': service.isOnlineBookingEnabled,
        });
      }

      // 6. Opening hours
      for (final hour in draft.openingHours) {
        await _client.from('shop_opening_hours').insert({
          'shop_id': shopId,
          'day_of_week': hour.dayOfWeek,
          'opens_at': hour.opensAt,
          'closes_at': hour.closesAt,
          'is_closed': hour.isClosed,
        });
      }

      // 7. Shop media (gallery images)
      for (int i = 0; i < imageUrls.length; i++) {
        await _client.from('shop_media').insert({
          'shop_id': shopId,
          'media_type': 'professional', // ✅ This must be 'professional'
          'url': imageUrls[i],
          'sort_order': i,
          'is_cover': i == 0,
        });
      }

      // 8. Documents
      for (int i = 0; i < documentUrls.length; i++) {
        await _client.from('shop_media').insert({
          'shop_id': shopId,
          'media_type': 'document',
          'url': documentUrls[i],
          'sort_order': i,
        });
      }

      // 9. Awards
      for (final award in draft.awards) {
        await _client.from('shop_awards').insert({
          'shop_id': shopId,
          'name': award.name,
          'issuer': award.issuer,
          'date_received': award.dateReceived,
          'description': award.description,
          'link': award.link,
          'sort_order': award.sortOrder,
        });
      }

      success = true;
      return shopId;
    } catch (e) {
      // If anything fails, delete the shop to avoid orphaned records
      if (!success) {
        try {
          await _deleteShopWithRelatedData(shopId);
          debugPrint('🗑️ Cleaned up orphaned shop: $shopId');
        } catch (cleanupError) {
          debugPrint('❌ Failed to clean up orphaned shop: $cleanupError');
        }
      }
      rethrow;
    }
  }

  // In shop_creation_repository.dart

  /// Helper to delete shop and all related data
  Future<void> _deleteShopWithRelatedData(String shopId) async {
    // Fetch slot IDs first — Supabase Dart client does not support subquery
    // objects as .filter() arguments; the list must be materialised first.
    final slots = await _client
        .from('appointment_slots')
        .select('id')
        .eq('shop_id', shopId);
    final slotIds = slots.map((s) => s['id'] as String).toList();
    if (slotIds.isNotEmpty) {
      await _client
          .from('slot_worker_assignments')
          .delete()
          .inFilter('slot_id', slotIds);
    }
    await _client.from('appointment_slots').delete().eq('shop_id', shopId);
    await _client.from('shop_workers').delete().eq('shop_id', shopId);
    await _client.from('shop_locations').delete().eq('shop_id', shopId);
    await _client.from('shop_contacts').delete().eq('shop_id', shopId);
    await _client.from('shop_social_links').delete().eq('shop_id', shopId);
    await _client.from('shop_opening_hours').delete().eq('shop_id', shopId);
    await _client.from('shop_media').delete().eq('shop_id', shopId);
    await _client.from('shop_awards').delete().eq('shop_id', shopId);
    await _client.from('shops').delete().eq('id', shopId);
  }

  /// Delete a shop using Supabase RPC function
  Future<void> deleteShop(String shopId) async {
    try {
      await _client.rpc('delete_shop', params: {'p_shop_id': shopId});
    } catch (e) {
      debugPrint('Error deleting shop: $e');
      rethrow;
    }
  }

  /// Update worker assignments for services
  Future<void> updateServiceWorkerAssignments({
    required String shopId,
    required List<AppointmentSlotDTO> services,
  }) async {
    try {
      // First, get all appointment slots for this shop
      final slots = await _client
          .from('appointment_slots')
          .select('id, service_id')
          .eq('shop_id', shopId);

      final Map<String, String> serviceIdToSlotId = {};
      for (var slot in slots) {
        final serviceId = slot['service_id'] as String?;
        if (serviceId != null) {
          serviceIdToSlotId[serviceId] = slot['id'];
        }
      }

      // For each service, update its slot assignments
      for (final service in services) {
        final slotId = serviceIdToSlotId[service.id];
        if (slotId == null) continue;

        // Delete existing assignments for this slot
        await _client
            .from('slot_worker_assignments')
            .delete()
            .eq('slot_id', slotId);

        // Add new assignments if any
        if (service.selectPreferredWorker &&
            service.workerIds != null &&
            service.workerIds!.isNotEmpty) {
          final assignments =
              service.workerIds!
                  .map(
                    (workerId) => {
                      'slot_id': slotId,
                      'worker_id': workerId,
                      'is_preferred': true,
                    },
                  )
                  .toList();

          await _client.from('slot_worker_assignments').insert(assignments);
        }
      }
    } catch (e) {
      debugPrint('Error updating service worker assignments: $e');
      rethrow;
    }
  }

  /// Update an existing shop
  Future<void> updateShop({
    required String shopId,
    required ShopDraft draft,
    required List<String> newImageUrls,
    required List<String> imageIdsToDelete,
    required List<String> imagesToDelete, // URLs used only for storage deletion
    required List<String> newDocumentUrls,
    required List<String> docIdsToDelete,
    required List<String>
    documentUrlsToDelete, // URLs used only for storage deletion
  }) async {
    try {
      // 1. Resolve logo URL — upload if a new local file was selected
      String? resolvedLogoUrl;
      if (draft.localLogoPath != null) {
        if (draft.localLogoPath!.startsWith('http')) {
          resolvedLogoUrl = draft.localLogoPath;
        } else {
          resolvedLogoUrl = await _uploadLogoImage(
            shopId,
            File(draft.localLogoPath!),
          );
        }
      }

      // 2. Update main shop record
      await _client
          .from('shops')
          .update({
            'shop_name': draft.shopName,
            'shop_type': draft.shopType,
            'luxury_level': draft.luxuryLevel,
            'overview': draft.overview,
            'terms': draft.terms,
            'currency': draft.currencyCode ?? 'USD',
            'currency_symbol': draft.currencySymbol ?? '\$',
            'amenities': draft.amenityIds,
            if (resolvedLogoUrl != null) 'shop_logo_url': resolvedLogoUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', shopId);

      // 2. Update location (delete old, insert new)
      await _client.from('shop_locations').delete().eq('shop_id', shopId);
      if (draft.address != null) {
        await _client.from('shop_locations').insert({
          'shop_id': shopId,
          'address': draft.address,
          'city': draft.city,
          'country': draft.country ?? 'USA',
          'latitude': draft.latitude,
          'longitude': draft.longitude,
          'is_primary': true,
        });
      }

      // 3. Update contacts — draft.contacts is the single source of truth.
      // Fall back to legacy phone/email/website fields if the list is empty
      // (handles shops created before the contacts-list migration).
      await _client.from('shop_contacts').delete().eq('shop_id', shopId);
      final contactsToSave =
          draft.contacts.isNotEmpty
              ? draft.contacts
              : [
                if (draft.phone != null && draft.phone!.isNotEmpty)
                  ContactDraft(
                    type: ContactType.phone,
                    value: draft.phone!,
                    isPrimary: true,
                  ),
                if (draft.email != null && draft.email!.isNotEmpty)
                  ContactDraft(
                    type: ContactType.email,
                    value: draft.email!,
                    isPrimary: true,
                  ),
                if (draft.website != null && draft.website!.isNotEmpty)
                  ContactDraft(
                    type: ContactType.website,
                    value: draft.website!,
                    isPrimary: false,
                  ),
              ];
      for (final contact in contactsToSave) {
        await _client.from('shop_contacts').insert({
          'shop_id': shopId,
          'contact_type': contact.type.name,
          'value': contact.value,
          'is_primary': contact.isPrimary,
        });
      }

      // 4. Update social links
      await _client.from('shop_social_links').delete().eq('shop_id', shopId);
      for (final link in draft.socialLinks) {
        await _client.from('shop_social_links').insert({
          'shop_id': shopId,
          'url': link.url,
        });
      }

      // 5. Update appointment slots
      await _client.from('appointment_slots').delete().eq('shop_id', shopId);
      for (final service in draft.services) {
        await _client.from('appointment_slots').insert({
          'id': Uuid().v4(),
          'shop_id': shopId,
          'service_name': service.serviceName,
          'duration': service.duration,
          'price': service.price,
          'slot_type': service.slotType,
          'max_clients': service.maxClients,
          'days_of_week': service.daysOfWeek,
          'select_preferred_worker': service.selectPreferredWorker,
          'buffer_before_minutes': service.bufferBeforeMinutes,
          'buffer_minutes': service.bufferMinutes,
          'is_online_booking_enabled': service.isOnlineBookingEnabled,
        });
      }

      // 6. Update opening hours
      await _client.from('shop_opening_hours').delete().eq('shop_id', shopId);
      for (final hour in draft.openingHours) {
        await _client.from('shop_opening_hours').insert({
          'shop_id': shopId,
          'day_of_week': hour.dayOfWeek,
          'opens_at': hour.opensAt,
          'closes_at': hour.closesAt,
          'is_closed': hour.isClosed,
        });
      }

      // ✅ 7. Delete removed images by primary key (not URL — avoids ?t= mismatch)
      for (int i = 0; i < imageIdsToDelete.length; i++) {
        await _client
            .from('shop_media')
            .delete()
            .eq('id', imageIdsToDelete[i]);
        final url = i < imagesToDelete.length ? imagesToDelete[i] : '';
        await _deleteImageFromStorage(url);
      }

      // ✅ 8. Delete removed documents by primary key
      for (int i = 0; i < docIdsToDelete.length; i++) {
        await _client
            .from('shop_media')
            .delete()
            .eq('id', docIdsToDelete[i]);
        final url =
            i < documentUrlsToDelete.length ? documentUrlsToDelete[i] : '';
        await _deleteImageFromStorage(url);
      }

      // ✅ 9. Get current count of existing professional images (after deletions)
      final existingMedia = await _client
          .from('shop_media')
          .select('id')
          .eq('shop_id', shopId)
          .eq('media_type', 'professional');

      final existingCount = existingMedia.length;

      // ✅ 10. Add ONLY NEW images (not all images)
      for (int i = 0; i < newImageUrls.length; i++) {
        await _client.from('shop_media').insert({
          'shop_id': shopId,
          'media_type': 'professional',
          'url': newImageUrls[i],
          'sort_order': existingCount + i,
          'is_cover': existingCount == 0 && i == 0,
        });
      }

      // ✅ 11. Get current count of existing documents (after deletions)
      final existingDocuments = await _client
          .from('shop_media')
          .select('id')
          .eq('shop_id', shopId)
          .eq('media_type', 'document');

      final existingDocCount = existingDocuments.length;

      // ✅ 12. Add ONLY NEW documents
      for (int i = 0; i < newDocumentUrls.length; i++) {
        await _client.from('shop_media').insert({
          'shop_id': shopId,
          'media_type': 'document',
          'url': newDocumentUrls[i],
          'sort_order': existingDocCount + i,
          'is_cover': false,
        });
      }

      // 13. Update awards
      await _client.from('shop_awards').delete().eq('shop_id', shopId);
      for (final award in draft.awards) {
        await _client.from('shop_awards').insert({
          'shop_id': shopId,
          'name': award.name,
          'issuer': award.issuer,
          'date_received': award.dateReceived,
          'description': award.description,
          'link': award.link,
          'sort_order': award.sortOrder,
        });
      }

      // Contacts are handled in section 3 above.
    } catch (e) {
      debugPrint('Error updating shop: $e');
      rethrow;
    }
  }

  Future<String?> _uploadLogoImage(String shopId, File image) async {
    try {
      final fileExt = image.path.split('.').last;
      final fileName =
          'shop_${shopId}_logo_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = 'shops/$shopId/logo/$fileName';
      await _client.storage
          .from('shop-media')
          .upload(path, image, fileOptions: const FileOptions(upsert: true));
      return _client.storage.from('shop-media').getPublicUrl(path);
    } catch (e) {
      debugPrint('Error uploading shop logo: $e');
      return null;
    }
  }

  /// Delete an image from Supabase Storage
  Future<void> _deleteImageFromStorage(String url) async {
    try {
      // Extract the path from the URL
      // URL format: https://your-project.supabase.co/storage/v1/object/public/bucket-name/path/to/file.jpg
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // Find the bucket and path
      final bucketIndex = pathSegments.indexOf('object') + 2;
      if (bucketIndex < pathSegments.length) {
        final bucket = pathSegments[bucketIndex];
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/'); 

        await _client.storage.from(bucket).remove([filePath]);
        debugPrint('✅ Deleted from storage: $bucket/$filePath');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to delete from storage: $e');
      // Don't throw - database record will still be deleted
    }
  }
}

// Provider
final shopCreationRepositoryProvider = Provider<SupabaseShopCreationRepository>(
  (ref) {
    final client = Supabase.instance.client;
    return SupabaseShopCreationRepository(client);
  },
);
