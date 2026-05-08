// lib/features/shop/creation/data/upload_shop_media.dart

import 'dart:io';
import 'package:nano_embryo/core/providers/media_%20service_providers.dart';
import 'package:nano_embryo/core/repositories/models/media_upload.dart';
import 'package:nano_embryo/core/services/media/media_upload_service.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadShopMedia {
  final MediaUploadService _mediaUploadService;

  UploadShopMedia({required MediaUploadService mediaUploadService})
    : _mediaUploadService = mediaUploadService;

  /// Upload multiple shop images and return their public URLs
  Future<List<String>> execute({
    required List<File> images,
    required String profileId,
    required String shopId, // Will be created first
  }) async {
    final List<String> uploadedUrls = [];

    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      final isCover = i == 0; // First image is cover

      try {
        final result = await _mediaUploadService.uploadFile(
          request: MediaUploadRequest(
            file: file,
            mediaType: MediaType.image,
            bucket: 'shop-media',
            customPath:
                'shops/$profileId/$shopId/${DateTime.now().millisecondsSinceEpoch}.jpg',
            metadata: {
              'type': 'shop_gallery',
              'is_cover': isCover.toString(), // ✅ Convert bool to string
              'sort_order': i.toString(), // ✅ Convert int to string
            },
          ),
          userId: profileId,
        );

        if (result != null) {
          uploadedUrls.add(result.publicUrl);
        }
      } catch (e) {
        // Continue with other images even if one fails
      }
    }

    return uploadedUrls;
  }

  // In upload_shop_media.dart

  Future<String?> uploadSingleDocument({
    required DocumentDraft document,
    required String profileId,
    required String shopId,
  }) async {
    try {
      final result = await _mediaUploadService.uploadFile(
        request: MediaUploadRequest(
          file: document.file,
          mediaType: MediaType.image,
          bucket: 'shop-documents',
          customPath:
              'shops/$profileId/$shopId/documents/${DateTime.now().millisecondsSinceEpoch}.jpg',
          metadata: {
            'document_type': document.type.name,
            'title': document.title ?? document.type.displayName,
            'expiry_date': document.expiryDate?.toIso8601String() ?? '',
          },
        ),
        userId: profileId,
      );
      return result?.publicUrl;
    } catch (e) {
      print('Error uploading document: $e');
      return null;
    }
  }
}

// Provider
final uploadShopMediaProvider = Provider<UploadShopMedia>((ref) {
  final mediaUploadService = ref.watch(mediaUploadServiceProvider);
  return UploadShopMedia(mediaUploadService: mediaUploadService);
});
