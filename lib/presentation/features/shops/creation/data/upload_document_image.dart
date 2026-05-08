// lib/features/shop/creation/data/upload_document_image.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/media_%20service_providers.dart';
import 'package:nano_embryo/core/repositories/models/media_upload.dart';
import 'package:nano_embryo/core/services/media/media_upload_service.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';

class UploadDocumentImage {
  final MediaUploadService _mediaUploadService;

  UploadDocumentImage({required MediaUploadService mediaUploadService})
    : _mediaUploadService = mediaUploadService;

  /// Upload a single document and return its public URL
  Future<String?> execute({
    required DocumentDraft document,
    required String profileId,
    required String shopId,
  }) async {
    try {
      final result = await _mediaUploadService.uploadFile(
        request: MediaUploadRequest(
          file: document.file,
          mediaType:
              MediaType.document, // You'll need to add this to MediaType enum
          bucket: 'shop-documents',
          customPath:
              'shops/$profileId/$shopId/documents/${DateTime.now().millisecondsSinceEpoch}_${document.fileName}',
          metadata: {
            'document_type': document.type.name,
            'title': document.title ?? document.type.displayName,
            'expiry_date': document.expiryDate?.toIso8601String() ?? '',
            'sort_order': document.sortOrder.toString(),
          },
        ),
        userId: profileId,
      );

      return result?.publicUrl;
    } catch (e) {
      return null;
    }
  }

  /// Upload multiple documents
  Future<List<String>> uploadMultiple({
    required List<DocumentDraft> documents,
    required String profileId,
    required String shopId,
  }) async {
    final List<String> uploadedUrls = [];

    for (var i = 0; i < documents.length; i++) {
      final document = documents[i].copyWith(sortOrder: i);
      final url = await execute(
        document: document,
        profileId: profileId,
        shopId: shopId,
      );
      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    return uploadedUrls;
  }
}

// Provider
final uploadDocumentImageProvider = Provider<UploadDocumentImage>((ref) {
  final mediaUploadService = ref.watch(mediaUploadServiceProvider);
  return UploadDocumentImage(mediaUploadService: mediaUploadService);
});
