// lib/features/shop/creation/domain/usecases/publish_shop_usecase.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/services/notification_service.dart';
import '../../data/upload_shop_media.dart';
import '../../repository/supabase_shop_creation_repository.dart';
import '../models/shop_draft.dart';
import '../models/document_draft.dart'; // ✅ Add this import

class PublishShopUseCase {
  final UploadShopMedia _uploadShopMedia;
  final SupabaseShopCreationRepository _repository;
  final NotificationService?
  _notificationService; // Add optional notification service

  PublishShopUseCase({
    required UploadShopMedia uploadShopMedia,
    required SupabaseShopCreationRepository repository,
    NotificationService? notificationService, // Make it optional
  }) : _uploadShopMedia = uploadShopMedia,
       _repository = repository,
       _notificationService = notificationService;

  /// Create a new shop
  Future<String> execute({
    required ShopDraft draft,
    required String profileId,
    required List<File> images,
    required List<DocumentDraft> documents,
  }) async {
    if (!draft.isMinimumViable) {
      throw Exception('Shop does not meet minimum requirements');
    }

    try {
      // 1. Upload logo if a new local file was selected
      String? logoUrl;
      if (draft.localLogoPath != null &&
          !draft.localLogoPath!.startsWith('http')) {
        final urls = await _uploadShopMedia.execute(
          images: [File(draft.localLogoPath!)],
          profileId: profileId,
          shopId: 'logo',
        );
        logoUrl = urls.isNotEmpty ? urls.first : null;
      } else {
        logoUrl = draft.localLogoPath; // already a network URL (edit mode)
      }

      // 2. Upload gallery images
      final imageUrls = await _uploadShopMedia.execute(
        images: images,
        profileId: profileId,
        shopId: 'temp', // temporary ID, actual shopId will be generated later
      );

      print('✅ Uploaded ${imageUrls.length} professional images'); // Debug

      // 3. Upload documents
      final documentUrls = <String>[];
      for (final doc in documents) {
        final url = await _uploadShopMedia.uploadSingleDocument(
          document: doc,
          profileId: profileId,
          shopId: 'temp',
        );
        if (url != null) documentUrls.add(url);
      }

      print('✅ Uploaded ${documentUrls.length} documents'); // Debug

      // 4. Create shop in database
      final shopId = await _repository.createShop(
        profileId: profileId,
        draft: draft,
        imageUrls: imageUrls,
        documentUrls: documentUrls,
        logoUrl: logoUrl,
      );

      // 4 SEND NOTIFICATION FOR NEW SHOP (NEW)
      // ============================================
      await _sendNewShopNotification(
        shopId: shopId,
        shopName: draft.shopName??'',
        latitude: draft.latitude,
        longitude: draft.longitude,
      );

      return shopId;
    } catch (e) {
      print('Error publishing shop: $e');
      rethrow;
    }
  }

  /// Send notification to nearby users about the new shop
  Future<void> _sendNewShopNotification({
    required String shopId,
    required String shopName,
    double? latitude,
    double? longitude,
  }) async {
    // Don't send if notification service is not available
    if (_notificationService == null) {
      print(
        '⚠️ Notification service not available, skipping new shop notification',
      );
      return;
    }

    // Don't send if location is missing
    if (latitude == null || longitude == null) {
      print('⚠️ Shop location missing, skipping nearby user notifications');
      return;
    }

    try {
      await _notificationService.notifyNearbyUsersNewShop(
        shopId: shopId,
        shopName: shopName,
        latitude: latitude,
        longitude: longitude,
        radiusKm: 10, // 10km radius
      );
      print('✅ Sent new shop notifications for: $shopName');
    } catch (e) {
      // Don't rethrow - notification failure shouldn't break shop creation
      print('❌ Failed to send new shop notifications: $e');
    }
  }

  /// Update an existing shop
  Future<void> update({
    required String shopId,
    required ShopDraft draft,
    required String profileId,
    List<File>? newImages,
    required List<String> imageIdsToDelete,
    required List<String> imagesToDelete,
    required List<DocumentDraft> newDocuments,
    required List<String> docIdsToDelete,
    required List<String> documentUrlsToDelete,
  }) async {
    try {
      List<String>? newImageUrls;
      List<String> newDocumentUrls = [];

      // Upload new images if any
      if (newImages != null && newImages.isNotEmpty) {
        newImageUrls = await _uploadShopMedia.execute(
          images: newImages,
          profileId: profileId,
          shopId: shopId,
        );
      }

      // Upload new documents if any
      if (newDocuments.isNotEmpty) {
        for (final doc in newDocuments) {
          final url = await _uploadShopMedia.uploadSingleDocument(
            document: doc,
            profileId: profileId,
            shopId: shopId,
          );
          if (url != null) newDocumentUrls.add(url);
        }
      }

      // Update shop in database
      await _repository.updateShop(
        shopId: shopId,
        draft: draft,
        newImageUrls: newImageUrls ?? [],
        imageIdsToDelete: imageIdsToDelete,
        imagesToDelete: imagesToDelete,
        newDocumentUrls: newDocumentUrls,
        docIdsToDelete: docIdsToDelete,
        documentUrlsToDelete: documentUrlsToDelete,
      );
    } catch (e) {
      print('Error updating shop: $e');
      rethrow;
    }
  }
}

// Provider
final publishShopUseCaseProvider = Provider<PublishShopUseCase>((ref) {
  final uploadShopMedia = ref.watch(uploadShopMediaProvider);
  final repository = ref.watch(shopCreationRepositoryProvider);
  return PublishShopUseCase(
    uploadShopMedia: uploadShopMedia,
    repository: repository,
  );
});
