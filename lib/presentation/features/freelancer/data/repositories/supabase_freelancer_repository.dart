// lib/features/freelancer/data/repositories/supabase_freelancer_repository.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/domain/models/freelancer_draft.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/models/freelancer_details_dto.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/models/nearby_freelancer_dto.dart';
import 'package:nano_embryo/presentation/features/search/models/freelancer_search_result.dart';
import 'package:nano_embryo/presentation/features/search/models/search_paginated_result.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/award_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/award_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/paginated_result.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/simple_media.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/data/models/booking_review.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const String _storageBucket =
    'freelancer-media'; // Use the same bucket as shops

/// Repository for freelancer-related Supabase operations
class SupabaseFreelancerRepository {
  final SupabaseClient _client;

  SupabaseFreelancerRepository(this._client);

  /// Create a new freelancer profile
  /// Returns the worker_id (freelancer ID)
  Future<String> createFreelancer({
    required String userId,
    required FreelancerDraft draft,
    required List<File> portfolioImages,
    required List<File> documents,
  }) async {
    final workerId = const Uuid().v4();
    bool success = false;

    try {
      const String bucket = 'public'; // Use existing bucket

      // 1. Upload portfolio images
      final imageUrls = await _uploadPortfolioImages(
        workerId: workerId,
        images: portfolioImages,
        // bucket: bucket,
      );

      // 2. Upload documents
      final documentUrls = await _uploadDocuments(
        workerId: workerId,
        documents: documents,
        // bucket: bucket,
      );

      // 3. Insert into workers table (all freelancer fields are here)
      await _client.from('workers').insert({
        'id': workerId,
        'user_id': userId,
        'shop_id': null,
        'name': draft.name, 'terms': draft.terms,
        'bio': draft.bio,
        'profile_image_url':
            draft.profileImagePath != null
                ? await _uploadProfileImage(
                  workerId,
                  File(draft.profileImagePath!),
                  // bucket,
                )
                : null,
        'specialties': draft.specialties,
        'is_active': true,
        'is_freelancer': true,
        'created_at': DateTime.now().toIso8601String(),
        // Freelancer-specific columns (already in workers table)
        'tools': draft.toolIds,
        'subaccount_id': draft.subaccountId,
        'transfer_recipient_id': draft.transferRecipientId,
        'freelancer_type': draft.freelancerType,
        'can_travel': draft.canTravel,
        'freelancer_rating': 0,
        'freelancer_total_reviews': 0,
        'freelancer_total_revenue': 0,
      });

      // After inserting into workers table, add:
      await _client.from('freelancer_details').insert({
        'worker_id': workerId,
        'base_latitude': draft.baseLatitude,
        'base_longitude': draft.baseLongitude,
        'travel_radius_km': draft.travelRadiusKm,
        'can_travel': draft.canTravel,
        'freelancer_type': draft.freelancerType,
        'freelancer_types': draft.freelancerTypes,
        'tools': draft.toolIds,
        'rating': 0,
        'total_reviews': 0,
        'total_revenue': 0,
        'total_bookings': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 4. Insert services (appointment slots)
      for (final service in draft.services) {
        await _client.from('appointment_slots').insert({
          'id': const Uuid().v4(),
          'shop_id': workerId, // Use worker_id as shop_id
          'service_name': service.serviceName,
          'duration': service.duration,
          'price': service.price,
          'slot_type': service.slotType,
          'max_clients': service.maxClients,
          'days_of_week': service.daysOfWeek,
          'select_preferred_worker': false,
          'buffer_minutes': service.bufferMinutes,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // 5. Insert opening hours
      for (final hour in draft.openingHours) {
        await _client.from('shop_opening_hours').insert({
          'shop_id': workerId,
          'day_of_week': hour.dayOfWeek,
          'opens_at': hour.opensAt,
          'closes_at': hour.closesAt,
          'is_closed': hour.isClosed,
        });
      }

      // 6. Insert portfolio images into shop_media
      for (int i = 0; i < imageUrls.length; i++) {
        await _client.from('shop_media').insert({
          'shop_id': workerId,
          'media_type': 'professional',
          'url': imageUrls[i],
          'sort_order': i,
          'is_cover': i == 0,
        });
      }

      // 7. Insert documents into shop_media
      for (int i = 0; i < documentUrls.length; i++) {
        await _client.from('shop_media').insert({
          'shop_id': workerId,
          'media_type': 'document',
          'url': documentUrls[i],
          'sort_order': i,
        });
      }

      // 8. Insert contacts
      for (final contact in draft.contacts) {
        await _client.from('shop_contacts').insert({
          'shop_id': workerId,
          'contact_type': contact.type.name,
          'value': contact.value,
          'is_primary': contact.isPrimary,
        });
      }

      // 9. Insert social links
      for (final link in draft.socialLinks) {
        await _client.from('shop_social_links').insert({
          'shop_id': workerId,
          'url': link.url,
        });
      }

      // 10. Insert tools assignments
      if (draft.toolIds.isNotEmpty) {
        final toolAssignments =
            draft.toolIds
                .map((toolId) => {'freelancer_id': workerId, 'tool_id': toolId})
                .toList();
        await _client.from('freelancer_tools').insert(toolAssignments);
      }

      success = true;
      return workerId;
    } catch (e) {
      if (!success) {
        await _cleanupFailedCreation(workerId);
      }
      rethrow;
    }
  }

  /// Upload profile image
  Future<String?> _uploadProfileImage(String workerId, File image) async {
    try {
      final fileExt = image.path.split('.').last;
      final fileName =
          'freelancer_${workerId}_profile_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = 'freelancers/$workerId/profile/$fileName';

      await _client.storage
          .from(_storageBucket)
          .upload(path, image, fileOptions: const FileOptions(upsert: true));
      return _client.storage.from(_storageBucket).getPublicUrl(path);
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  /// Upload portfolio images
  Future<List<String>> _uploadPortfolioImages({
    required String workerId,
    required List<File> images,
  }) async {
    final List<String> urls = [];

    for (int i = 0; i < images.length; i++) {
      try {
        final image = images[i];
        final fileExt = image.path.split('.').last;
        final fileName =
            'freelancer_${workerId}_portfolio_${DateTime.now().millisecondsSinceEpoch}_$i.$fileExt';
        final path = 'freelancers/$workerId/portfolio/$fileName';

        await _client.storage
            .from(_storageBucket)
            .upload(path, image, fileOptions: const FileOptions(upsert: true));
        urls.add(_client.storage.from(_storageBucket).getPublicUrl(path));
      } catch (e) {
        print('Error uploading portfolio image $i: $e');
      }
    }
    return urls;
  }

  /// Upload documents
  Future<List<String>> _uploadDocuments({
    required String workerId,
    required List<File> documents,
  }) async {
    final List<String> urls = [];

    for (int i = 0; i < documents.length; i++) {
      try {
        final doc = documents[i];
        final fileExt = doc.path.split('.').last;
        final fileName =
            'freelancer_${workerId}_document_${DateTime.now().millisecondsSinceEpoch}_$i.$fileExt';
        final path = 'freelancers/$workerId/documents/$fileName';

        await _client.storage
            .from(_storageBucket)
            .upload(path, doc, fileOptions: const FileOptions(upsert: true));
        urls.add(_client.storage.from(_storageBucket).getPublicUrl(path));
      } catch (e) {
        print('Error uploading document $i: $e');
      }
    }
    return urls;
  }

  /// Delete image from storage (matches shop pattern)
  Future<void> _deleteImageFromStorage(String url) async {
    if (url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf('object') + 2;

      if (bucketIndex < pathSegments.length) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _client.storage.from(_storageBucket).remove([filePath]);
        print('✅ Deleted from storage: $filePath');
      }
    } catch (e) {
      print('⚠️ Failed to delete from storage: $e');
    }
  }

  /// Update an existing freelancer (matching shop pattern)
  Future<void> updateFreelancer({
    required String workerId,
    required FreelancerDraft draft,
    required List<String> newImageUrls,
    required List<String> imageIdsToDelete,
    required List<String> imagesToDelete, // URLs used only for storage deletion
    required List<String> newDocumentUrls,
    required List<String> docIdsToDelete,
    required List<String>
    documentUrlsToDelete, // URLs used only for storage deletion
  }) async {
    try {
      // 1. Update workers table
      // Upload new profile image if the path is a local file (not an http URL).
      String? profileImageUrl;
      if (draft.profileImagePath != null) {
        if (draft.profileImagePath!.startsWith('http')) {
          profileImageUrl = draft.profileImagePath;
        } else {
          profileImageUrl = await _uploadProfileImage(
            workerId,
            File(draft.profileImagePath!),
          );
        }
      }

      await _client
          .from('workers')
          .update({
            'name': draft.name,
            'bio': draft.bio,
            'specialties': draft.specialties,
            'terms': draft.terms,
            'tools': draft.toolIds,
            if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
          })
          .eq('id', workerId);

      // 2. Update freelancer_details
      await _client
          .from('freelancer_details')
          .update({
            'freelancer_type': draft.freelancerType,
            'freelancer_types': draft.freelancerTypes,
            'tools': draft.toolIds,
            'can_travel': draft.canTravel,
            'base_latitude': draft.baseLatitude,
            'base_longitude': draft.baseLongitude,
            'travel_radius_km': draft.travelRadiusKm,
            'auto_accept_bookings': draft.autoAcceptBookings,
            'max_bookings_per_day': draft.maxBookingsPerDay,
            'buffer_minutes_between_bookings':
                draft.bufferMinutesBetweenBookings,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('worker_id', workerId);

      // 3. Update tools (delete and re-insert)
      await _client
          .from('freelancer_tools')
          .delete()
          .eq('freelancer_id', workerId);
      if (draft.toolIds.isNotEmpty) {
        final toolAssignments =
            draft.toolIds
                .map((toolId) => {'freelancer_id': workerId, 'tool_id': toolId})
                .toList();
        await _client.from('freelancer_tools').insert(toolAssignments);
      }

      // 4. Update services (delete and re-insert)
      await _client.from('appointment_slots').delete().eq('shop_id', workerId);
      for (final service in draft.services) {
        await _client.from('appointment_slots').insert({
          'id': const Uuid().v4(),
          'shop_id': workerId,
          'service_name': service.serviceName,
          'duration': service.duration,
          'price': service.price,
          'slot_type': service.slotType,
          'max_clients': service.maxClients,
          'days_of_week': service.daysOfWeek,
          'select_preferred_worker': false,
          'buffer_minutes': service.bufferMinutes,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // 5. Update opening hours
      await _client.from('shop_opening_hours').delete().eq('shop_id', workerId);
      for (final hour in draft.openingHours) {
        await _client.from('shop_opening_hours').insert({
          'shop_id': workerId,
          'day_of_week': hour.dayOfWeek,
          'opens_at': hour.opensAt,
          'closes_at': hour.closesAt,
          'is_closed': hour.isClosed,
        });
      }

      // 6. Update contacts — draft.contacts is the single source of truth.
      // Fall back to legacy phone/email/website fields if the list is empty
      await _client.from('shop_contacts').delete().eq('shop_id', workerId);
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
          'shop_id': workerId,
          'contact_type': contact.type.name,
          'value': contact.value,
          'is_primary': contact.isPrimary,
        });
      }

      // 7. Update social links
      await _client.from('shop_social_links').delete().eq('shop_id', workerId);
      for (final link in draft.socialLinks) {
        await _client.from('shop_social_links').insert({
          'shop_id': workerId,
          'url': link.url,
        });
      }

      // 8. Delete removed images by primary key (not URL — avoids ?t= mismatch)
      for (int i = 0; i < imageIdsToDelete.length; i++) {
        final url = i < imagesToDelete.length ? imagesToDelete[i] : '';
        await _deleteImageFromStorage(url);
        await _client.from('shop_media').delete().eq('id', imageIdsToDelete[i]);
      }

      // 9. Delete removed documents by primary key
      for (int i = 0; i < docIdsToDelete.length; i++) {
        final url =
            i < documentUrlsToDelete.length ? documentUrlsToDelete[i] : '';
        await _deleteImageFromStorage(url);
        await _client.from('shop_media').delete().eq('id', docIdsToDelete[i]);
      }

      // 10. Get current count of existing professional images (after deletions)
      final existingMedia = await _client
          .from('shop_media')
          .select('id')
          .eq('shop_id', workerId)
          .eq('media_type', 'professional');

      final existingCount = existingMedia.length;

      // 11. Add ONLY NEW images (not all images)
      for (int i = 0; i < newImageUrls.length; i++) {
        await _client.from('shop_media').insert({
          'shop_id': workerId,
          'media_type': 'professional',
          'url': newImageUrls[i],
          'sort_order': existingCount + i,
          'is_cover': existingCount == 0 && i == 0,
        });
      }

      // 12. Get current count of existing documents (after deletions)
      final existingDocuments = await _client
          .from('shop_media')
          .select('id')
          .eq('shop_id', workerId)
          .eq('media_type', 'document');

      final existingDocCount = existingDocuments.length;

      // 13. Add ONLY NEW documents
      for (int i = 0; i < newDocumentUrls.length; i++) {
        await _client.from('shop_media').insert({
          'shop_id': workerId,
          'media_type': 'document',
          'url': newDocumentUrls[i],
          'sort_order': existingDocCount + i,
          'is_cover': false,
        });
      }

      // 14. Update awards (if freelancers have awards)
      if (draft.awards.isNotEmpty) {
        await _client.from('shop_awards').delete().eq('shop_id', workerId);
        for (final award in draft.awards) {
          await _client.from('shop_awards').insert({
            'shop_id': workerId,
            'name': award.name,
            'issuer': award.issuer,
            'date_received': award.dateReceived,
            'description': award.description,
            'link': award.link,
            'sort_order': award.sortOrder,
          });
        }
      }

      print('✅ Freelancer updated successfully: $workerId');
    } catch (e) {
      print('❌ Error updating freelancer: $e');
      throw Exception('Failed to update freelancer: $e');
    }
  }

  Future<List<DocumentDraft>> getFreelancerDocuments(
    String freelancerId,
  ) async {
    try {
      final response = await _client
          .from('shop_media')
          .select('id, url, caption, created_at')
          .eq('shop_id', freelancerId)
          .eq('media_type', 'document')
          .order('created_at', ascending: true);

      final List<dynamic> data = response as List;
      return data.map((json) => DocumentDraft.fromJson(json)).toList();
    } catch (e) {
      print('Error getting freelancer documents: $e');
      return [];
    }
  }

  /// Get freelancer's services from appointment_slots
  Future<List<AppointmentSlotDTO>> getFreelancerServices(
    String freelancerId,
  ) async {
    try {
      final response = await _client
          .from('appointment_slots')
          .select('*')
          .eq('shop_id', freelancerId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => AppointmentSlotDTO.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting freelancer services: $e');
      return [];
    }
  }

  /// Get freelancer's reviews
  Future<List<BookingReview>> getFreelancerReviews(String freelancerId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
          *,
          client:user_id(
            display_name,
            avatar_url
          )
        ''')
          .eq('shop_id', freelancerId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List;
      return data.map((json) => BookingReview.fromJson(json)).toList();
    } catch (e) {
      print('Error getting freelancer reviews: $e');
      return [];
    }
  }

  /// Get freelancer's portfolio images from shop_media
  Future<List<String>> getFreelancerPortfolio(String freelancerId) async {
    try {
      final response = await _client
          .from('shop_media')
          .select('url')
          .eq('shop_id', freelancerId)
          .eq('media_type', 'professional')
          .order('sort_order', ascending: true);

      final List<dynamic> data = response as List;
      return data.map((json) => json['url'] as String).toList();
    } catch (e) {
      print('Error getting freelancer portfolio: $e');
      return [];
    }
  }

  /// Get freelancer's opening hours
  Future<List<OpeningHoursDraft>> getFreelancerHoursDraft(
    String freelancerId,
  ) async {
    try {
      final response = await _client
          .from('shop_opening_hours')
          .select('*')
          .eq('shop_id', freelancerId)
          .order('day_of_week', ascending: true);

      final List<dynamic> data = response as List;
      return data.map((json) => OpeningHoursDraft.fromJson(json)).toList();
    } catch (e) {
      print('Error getting freelancer hours: $e');
      return [];
    }
  }

  Future<List<OpeningHoursDTO>> getFreelancerHours(String freelancerId) async {
    try {
      final response = await _client
          .from('shop_opening_hours')
          .select('*')
          .eq('shop_id', freelancerId)
          .order('day_of_week', ascending: true);

      final List<dynamic> data = response as List;
      return data.map((json) => OpeningHoursDTO.fromJson(json)).toList();
    } catch (e) {
      print('Error getting freelancer hours: $e');
      return [];
    }
  }

  /// Get freelancer's contacts
  Future<List<ContactDraft>> getFreelancerContacts(String freelancerId) async {
    try {
      final response = await _client
          .from('shop_contacts')
          .select('*')
          .eq('shop_id', freelancerId);

      final List<dynamic> data = response as List;
      return data.map((json) => ContactDraft.fromJson(json)).toList();
    } catch (e) {
      print('Error getting freelancer contacts: $e');
      return [];
    }
  }

  /// Get freelancer's social links
  Future<List<SocialLinkDraft>> getFreelancerSocialLinks(
    String freelancerId,
  ) async {
    try {
      final response = await _client
          .from('shop_social_links')
          .select('*')
          .eq('shop_id', freelancerId);

      final List<dynamic> data = response as List;
      return data.map((json) => SocialLinkDraft.fromJson(json)).toList();
    } catch (e) {
      print('Error getting freelancer social links: $e');
      return [];
    }
  }

  /// Clean up failed creation
  Future<void> _cleanupFailedCreation(String workerId) async {
    try {
      await _client.from('workers').delete().eq('id', workerId);
    } catch (e) {
      print('Cleanup failed: $e');
    }
  }

  /// Get freelancer by ID
  Future<FreelancerDetailsDTO?> getFreelancerById(String workerId) async {
    try {
      // First, just fetch from workers table
      final workerResponse =
          await _client
              .from('workers')
              .select('*')
              .eq('id', workerId)
              .eq('is_freelancer', true)
              .maybeSingle();

      if (workerResponse == null) {
        print('❌ No worker found');
        return null;
      }

      // Then fetch freelancer_details separately
      final detailsResponse =
          await _client
              .from('freelancer_details')
              .select('*')
              .eq('worker_id', workerId)
              .maybeSingle();

      // Combine the responses
      final combinedResponse = {
        ...workerResponse,
        'freelancer_details': detailsResponse,
      };

      return FreelancerDetailsDTO.fromJson(combinedResponse);
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  /// Get freelancer by user ID
  Future<FreelancerDetailsDTO?> getFreelancerByUserId(String userId) async {
    try {
      final response =
          await _client
              .from('workers')
              .select('''
            *,
            freelancer_details:freelancer_details(*)
          ''')
              .eq('user_id', userId)
              .eq('is_freelancer', true)
              .maybeSingle();

      if (response == null) return null;
      return FreelancerDetailsDTO.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Add these methods to the existing SupabaseFreelancerRepository class

  /// Get document URLs from shop_media (type = 'document')
  Future<List<String>> getFreelancerDocumentUrls(String freelancerId) async {
    try {
      final response = await _client
          .from('shop_media')
          .select('url')
          .eq('shop_id', freelancerId)
          .eq('media_type', 'document')
          .order('created_at', ascending: true);

      final List<dynamic> data = response as List;
      return data.map((json) => json['url'] as String).toList();
    } catch (e) {
      print('Error getting freelancer document URLs: $e');
      return [];
    }
  }

  /// Get image media objects with ID and URL (for deletion by PK)
  /// Get image media objects with ID and URL (for deletion by PK) using SimpleMedia
  Future<List<SimpleMedia>> getFreelancerImageMedias(
    String freelancerId,
  ) async {
    try {
      final response = await _client
          .from('shop_media')
          .select('id, url, media_type, sort_order, caption')
          .eq('shop_id', freelancerId)
          .eq('media_type', 'professional')
          .order('sort_order', ascending: true);

      final List<dynamic> data = response as List;
      return data.map((json) => SimpleMedia.fromJson(json)).toList();
    } catch (e) {
      print('Error getting freelancer image medias: $e');
      return [];
    }
  }

  /// Get document media objects with ID and URL (for deletion by PK) using SimpleMedia
  Future<List<SimpleMedia>> getFreelancerDocumentMedias(
    String freelancerId,
  ) async {
    try {
      final response = await _client
          .from('shop_media')
          .select('id, url, media_type, sort_order, caption')
          .eq('shop_id', freelancerId)
          .eq('media_type', 'document')
          .order('created_at', ascending: true);

      final List<dynamic> data = response as List;
      return data.map((json) => SimpleMedia.fromJson(json)).toList();
    } catch (e) {
      print('Error getting freelancer document medias: $e');
      return [];
    }
  }

  /// Get freelancer awards
  Future<List<AwardDTO>> getFreelancerAwards(String freelancerId) async {
    try {
      final response = await _client
          .from('shop_awards')
          .select('*')
          .eq('shop_id', freelancerId)
          .order('sort_order', ascending: true);

      final List<dynamic> data = response as List;
      return data.map((json) => AwardDTO.fromJson(json)).toList();
    } catch (e) {
      print('Error getting freelancer awards: $e');
      return [];
    }
  }

  /// Get freelancer's tools
  Future<List<String>> getFreelancerTools(String freelancerId) async {
    try {
      final response = await _client
          .from('freelancer_tools')
          .select('tool_id')
          .eq('freelancer_id', freelancerId);

      return (response as List)
          .map((json) => json['tool_id'] as String)
          .toList();
    } catch (e) {
      print('Error getting freelancer tools: $e');
      return [];
    }
  }

  // lib/features/freelancer/data/repositories/freelancer_repository.dart

  /// Get nearby freelancers
  @override
  Future<List<NearbyFreelancerDTO>> getNearbyFreelancers({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
    int limit = 10,
    int offset = 0,
    List<String>? freelancerTypes,
    double? minRating,
    String sortBy = 'distance',
  }) async {
    // Return empty if location not set
    if (latitude == 0 || longitude == 0) {
      return [];
    }

    try {
      final response = await _client.rpc(
        'get_nearby_freelancers',
        params: {
          'p_user_lat': latitude,
          'p_user_lng': longitude,
          'p_radius_km': radiusKm,
          'p_freelancer_types': freelancerTypes,
          'p_min_rating': minRating,
          'p_sort_by': sortBy,
          'p_page_limit': limit,
          'p_page_offset': offset,
        },
      );

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => NearbyFreelancerDTO.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching nearby freelancers: $e');
      return []; // Return empty instead of throwing
    }
  }

  @override
  Future<PaginatedResult<NearbyFreelancerDTO>> getTopRatedFreelancersPaginated({
    required double latitude,
    required double longitude,
    double radiusKm = 20,
    int offset = 0,
    List<String>? freelancerTypes,
    int limit = 20,
  }) async {
    try {
      // If location is not set (0,0), fetch top rated freelancers without location filter
      final hasValidLocation = latitude != 0 && longitude != 0;

      dynamic response;

      if (hasValidLocation) {
        // Use location-based query
        response = await _client.rpc(
          'get_nearby_freelancers',
          params: {
            'p_user_lat': latitude,
            'p_user_lng': longitude,
            'p_radius_km': radiusKm,
            'p_page_limit': limit,
            'p_page_offset': offset,
            'p_freelancer_types': freelancerTypes,
            'p_min_rating': 4.5,
            'p_sort_by': 'rating',
          },
        );
      } else {
        // No location: fetch top rated freelancers globally
        response = await _client
            .from('workers')
            .select('''
            id,
            name,
            bio,
            profile_image_url,
            specialties,
            is_freelancer,
            freelancer_details:freelancer_details(
              freelancer_type,
              freelancer_types,
              tools,
              can_travel,
              travel_radius_km,
              rating,
              total_reviews,
              total_bookings,
              total_revenue,
              base_latitude,
              base_longitude,
              is_identity_verified,
              is_background_checked
            )
          ''')
            .eq('is_freelancer', true)
            .eq('is_active', true)
            .order('freelancer_details->>rating', ascending: false)
            .range(offset, offset + limit - 1);
      }

      final List<dynamic> data = response as List<dynamic>;
      final freelancers =
          data.map((json) {
            // If from RPC, json is already in correct format
            // If from direct query, convert the nested structure
            if (hasValidLocation) {
              return NearbyFreelancerDTO.fromJson(json);
            } else {
              final flattenedJson = _convertWorkerToNearbyFormat(json);
              return NearbyFreelancerDTO.fromJson(flattenedJson);
            }
          }).toList();

      final nextOffset = freelancers.length == limit ? offset + limit : null;

      return PaginatedResult(
        items: freelancers,
        nextOffset: nextOffset,
        totalCount: 0,
      );
    } catch (e) {
      print('Error fetching top rated freelancers: $e');
      return PaginatedResult(items: [], nextOffset: null, totalCount: 0);
    }
  }

  @override
  Future<PaginatedResult<NearbyFreelancerDTO>> getNearbyFreelancersPaginated({
    required double latitude,
    required double longitude,
    double radiusKm = 5,
    int offset = 0,
    List<String>? freelancerTypes,
    int limit = 20,
  }) async {
    // Return empty if location not set
    if (latitude == 0 || longitude == 0) {
      return PaginatedResult(items: [], nextOffset: null, totalCount: 0);
    }

    try {
      final response = await _client.rpc(
        'get_nearby_freelancers',
        params: {
          'p_user_lat': latitude,
          'p_user_lng': longitude,
          'p_radius_km': radiusKm,
          'p_page_limit': limit,
          'p_page_offset': offset,
          'p_freelancer_types': freelancerTypes,
          'p_sort_by': 'distance',
        },
      );

      final List<dynamic> data = response as List<dynamic>;
      final freelancers =
          data.map((json) => NearbyFreelancerDTO.fromJson(json)).toList();

      final nextOffset = freelancers.length == limit ? offset + limit : null;

      return PaginatedResult(
        items: freelancers,
        nextOffset: nextOffset,
        totalCount: 0,
      );
    } catch (e) {
      print('Error fetching nearby freelancers: $e');
      return PaginatedResult(items: [], nextOffset: null, totalCount: 0);
    }
  }

  @override
  Future<PaginatedResult<NearbyFreelancerDTO>> getAllFreelancers({
    required double latitude,
    required double longitude,
    required bool hasLocation,
    int limit = 20,
    int offset = 0,
    List<String>? freelancerTypes,
  }) async {
    try {
      List<dynamic> data;

      if (hasLocation && latitude != 0 && longitude != 0) {
        // With location: fetch nearest to farthest using RPC
        data = await _client.rpc(
          'get_nearby_freelancers',
          params: {
            'p_user_lat': latitude,
            'p_user_lng': longitude,
            'p_radius_km': 100,
            'p_page_limit': limit,
            'p_page_offset': offset,
            'p_freelancer_types': freelancerTypes,
            'p_sort_by': 'distance',
          },
        );
      } else {
        // ✅ Without location: use the new RPC function
        data = await _client.rpc(
          'get_top_rated_freelancers',
          params: {
            'p_page_limit': limit,
            'p_page_offset': offset,
            'p_freelancer_types': freelancerTypes,
          },
        );
      }

      // Convert the response to DTOs
      final freelancers =
          data.map((json) => NearbyFreelancerDTO.fromJson(json)).toList();

      final nextOffset = freelancers.length == limit ? offset + limit : null;

      return PaginatedResult(
        items: freelancers,
        nextOffset: nextOffset,
        totalCount: 0,
      );
    } catch (e) {
      print('Error in getAllFreelancers: $e');
      return PaginatedResult(items: [], nextOffset: null, totalCount: 0);
    }
  }

  /// Search freelancers by name using direct database query
  Future<PaginatedResult<NearbyFreelancerDTO>> searchFreelancersByName({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Use dynamic type to handle both FilterBuilder and TransformBuilder
      dynamic queryBuilder = _client
          .from('workers')
          .select('''
          id,
          name,
          bio,
          profile_image_url,
          specialties,
          is_freelancer,
          freelancer_details:freelancer_details(
            freelancer_type,
            freelancer_types,
            tools,
            can_travel,
            travel_radius_km,
            rating,
            total_reviews,
            total_bookings,
            total_revenue,
            base_latitude,
            base_longitude,
            is_identity_verified,
            is_background_checked
          )
        ''')
          .eq('is_freelancer', true)
          .ilike('name', '%$query%');

      // Apply order first
      queryBuilder = queryBuilder.order('name', ascending: true);

      // Apply offset pagination using range (after order)
      if (offset > 0) {
        final endOffset = offset + limit - 1;
        queryBuilder = queryBuilder.range(offset, endOffset);
      }

      // Request one extra to check for more results
      final response = await queryBuilder.limit(limit + 1);

      final List<dynamic> data = response as List;

      // Check if there are more results
      final hasMore = data.length > limit;
      final itemsToTake = hasMore ? limit : data.length;
      final freelancersData = data.take(itemsToTake).toList();

      final results = <NearbyFreelancerDTO>[];

      for (final json in freelancersData) {
        final flattenedJson = _convertWorkerToNearbyFormat(json);
        results.add(NearbyFreelancerDTO.fromJson(flattenedJson));
      }

      final nextOffset = hasMore ? offset + limit : null;

      return PaginatedResult(
        items: results,
        nextOffset: nextOffset,
        totalCount: 0,
      );
    } catch (e) {
      print('Error searching freelancers by name: $e');
      return PaginatedResult(items: [], nextOffset: null, totalCount: 0);
    }
  }

  /// Convert worker table JSON to NearbyFreelancerDTO format
  Map<String, dynamic> _convertWorkerToNearbyFormat(
    Map<String, dynamic> worker,
  ) {
    final details = worker['freelancer_details'] as Map<String, dynamic>? ?? {};

    return {
      'worker_id': worker['id'],
      'name': worker['name'],
      'profile_image': worker['profile_image_url'],
      'bio': worker['bio'],
      'specialties': worker['specialties'],
      'freelancer_type': details['freelancer_type'],
      'freelancer_types': details['freelancer_types'],
      'tools': details['tools'],
      'can_travel': details['can_travel'],
      'travel_radius_km': details['travel_radius_km'],
      'average_rating': (details['rating'] ?? 0).toDouble(),
      'total_reviews': details['total_reviews'] ?? 0,
      'total_bookings': details['total_bookings'] ?? 0,
      'total_revenue': (details['total_revenue'] ?? 0).toDouble(),
      'distance_km': 0, // No distance for name search
      'base_latitude': (details['base_latitude'] ?? 0).toDouble(),
      'base_longitude': (details['base_longitude'] ?? 0).toDouble(),
      'is_identity_verified': details['is_identity_verified'] ?? false,
      'is_background_checked': details['is_background_checked'] ?? false,
    };
  }
}

// Providers
final freelancerRepositoryProvider = Provider<SupabaseFreelancerRepository>((
  ref,
) {
  final client = Supabase.instance.client;
  return SupabaseFreelancerRepository(client);
});
