// lib/features/shop/creation/data/upload_shop_media.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:nano_embryo/core/providers/media_%20service_providers.dart';
import 'package:nano_embryo/core/repositories/models/media_upload.dart';
import 'package:nano_embryo/core/services/media/media_upload_service.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadShopMedia {
  final MediaUploadService _mediaUploadService;

  static const int _maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB

  UploadShopMedia({required MediaUploadService mediaUploadService})
    : _mediaUploadService = mediaUploadService;

  /// Upload multiple shop images and return their public URLs
  Future<List<String>> execute({
    required List<File> images,
    required String profileId,
    required String shopId,
  }) async {
    final List<String> uploadedUrls = [];

    for (int i = 0; i < images.length; i++) {
      final file = images[i];

      final fileSize = await file.length();
      if (fileSize > _maxFileSizeBytes) {
        throw Exception(
          'Image ${i + 1} exceeds the 10 MB size limit '
          '(${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB). '
          'Please choose a smaller image.',
        );
      }

      final isCover = i == 0;

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
              'is_cover': isCover.toString(),
              'sort_order': i.toString(),
            },
          ),
          userId: profileId,
        );

        if (result != null) {
          uploadedUrls.add(result.publicUrl);
        }
      } catch (e) {
        debugPrint('Failed to upload image $i: $e');
        // Continue with remaining images
      }
    }

    return uploadedUrls;
  }

  Future<String?> uploadSingleDocument({
    required DocumentDraft document,
    required String profileId,
    required String shopId,
  }) async {
    final fileSize = await document.file.length();
    if (fileSize > _maxFileSizeBytes) {
      throw Exception(
        'Document "${document.title ?? document.type.displayName}" exceeds '
        'the 10 MB size limit. Please choose a smaller file.',
      );
    }

    try {
      final result = await _mediaUploadService.uploadFile(
        request: MediaUploadRequest(
          file: document.file,
          mediaType: MediaType.document, // was MediaType.image — incorrect
          bucket: 'shop-documents',
          customPath:
              'shops/$profileId/$shopId/documents/${DateTime.now().millisecondsSinceEpoch}',
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
      debugPrint('Error uploading document: $e');
      return null;
    }
  }
}

// Provider
final uploadShopMediaProvider = Provider<UploadShopMedia>((ref) {
  final mediaUploadService = ref.watch(mediaUploadServiceProvider);
  return UploadShopMedia(mediaUploadService: mediaUploadService);
});
