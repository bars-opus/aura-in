// lib/features/shop/creation/presentation/providers/edit_shop_provider.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:nano_embryo/presentation/features/currency/domain/entities/currency.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/upload_shop_media.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/award_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/shop_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/repository/supabase_shop_creation_repository.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/award_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_details_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_repository_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class EditShopState {
  final bool isLoading;
  final String? error;
  final ShopDraft? draft;
  final List<File> existingImages; // URLs to display but not re-upload
  final List<String> existingImageUrls;
  final List<String> existingDocumentUrls;
  // Maps each downloaded local temp path back to its original Supabase URL.
  // Used at save time to distinguish "kept existing" from "truly new" images.
  final Map<String, String> localPathToOriginalUrl;
  final Map<String, String> localDocPathToOriginalUrl;
  // Maps each Supabase URL → shop_media.id so we delete by PK, not URL string.
  final Map<String, String> imageUrlToId;
  final Map<String, String> docUrlToId;

  const EditShopState({
    this.isLoading = false,
    this.error,
    this.draft,
    this.existingImages = const [],
    this.existingImageUrls = const [],
    this.existingDocumentUrls = const [],
    this.localPathToOriginalUrl = const {},
    this.localDocPathToOriginalUrl = const {},
    this.imageUrlToId = const {},
    this.docUrlToId = const {},
  });

  EditShopState copyWith({
    bool? isLoading,
    String? error,
    ShopDraft? draft,
    List<String>? existingImageUrls,
    List<String>? existingDocumentUrls,
    Map<String, String>? localPathToOriginalUrl,
    Map<String, String>? localDocPathToOriginalUrl,
    Map<String, String>? imageUrlToId,
    Map<String, String>? docUrlToId,
  }) {
    return EditShopState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      draft: draft ?? this.draft,
      existingImageUrls: existingImageUrls ?? this.existingImageUrls,
      existingDocumentUrls: existingDocumentUrls ?? this.existingDocumentUrls,
      localPathToOriginalUrl:
          localPathToOriginalUrl ?? this.localPathToOriginalUrl,
      localDocPathToOriginalUrl:
          localDocPathToOriginalUrl ?? this.localDocPathToOriginalUrl,
      imageUrlToId: imageUrlToId ?? this.imageUrlToId,
      docUrlToId: docUrlToId ?? this.docUrlToId,
    );
  }
}

class EditShopNotifier extends StateNotifier<EditShopState> {
  final Ref _ref;
  final String shopId;

  EditShopNotifier(this._ref, this.shopId) : super(const EditShopState()) {
    loadShopData();
  }

  // In edit_shop_provider.dart
  // lib/features/shop/creation/presentation/providers/edit_shop_provider.dart
  Future<void> loadShopData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final shopRepository = _ref.read(shopRepositoryProvider);
      final shopDetails = await shopRepository.getShopDetailsById(shopId);

      final draft = _convertToDraft(shopDetails);
      final existingImageUrls = List<String>.from(
        shopDetails.professionalImages,
      );
      final existingDocumentUrls = List<String>.from(
        shopDetails.documentImages,
      );

      // Download images and documents to local files
      final localImagePaths = await _downloadFiles(existingImageUrls);
      final localDocumentDrafts = await _downloadDocuments(
        existingDocumentUrls,
      );

      // Build temp-path → original-URL maps so _saveChanges can tell
      // "kept existing" from "truly new" without string.contains(url).
      final Map<String, String> localPathToOriginalUrl = {};
      for (
        int i = 0;
        i < existingImageUrls.length && i < localImagePaths.length;
        i++
      ) {
        localPathToOriginalUrl[localImagePaths[i]] = existingImageUrls[i];
      }

      final Map<String, String> localDocPathToOriginalUrl = {};
      for (
        int i = 0;
        i < existingDocumentUrls.length && i < localDocumentDrafts.length;
        i++
      ) {
        localDocPathToOriginalUrl[localDocumentDrafts[i].file.path] =
            existingDocumentUrls[i];
      }

      // Build URL → shop_media.id maps for reliable PK-based deletion.
      final Map<String, String> imageUrlToId = {
        for (final m in shopDetails.professionalImageMedias) m.url: m.id,
      };
      final Map<String, String> docUrlToId = {
        for (final m in shopDetails.documentMedias) m.url: m.id,
      };

      final updatedDraft = draft.copyWith(
        localImagePaths: localImagePaths,
        documents: localDocumentDrafts,
      );

      final creationNotifier = _ref.read(shopCreationProvider.notifier);
      creationNotifier.loadPublishedShop(updatedDraft);

      state = state.copyWith(
        isLoading: false,
        draft: updatedDraft,
        existingImageUrls: existingImageUrls,
        existingDocumentUrls: existingDocumentUrls,
        localPathToOriginalUrl: localPathToOriginalUrl,
        localDocPathToOriginalUrl: localDocPathToOriginalUrl,
        imageUrlToId: imageUrlToId,
        docUrlToId: docUrlToId,
      );
    } catch (e, stack) {
      debugPrint('loadShopData error: $e\n$stack');
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          error: 'Unable to load shop data. Please try again.',
        );
      }
    }
  }

  Future<List<String>> _downloadFiles(List<String> urls) async {
    final dir = await getTemporaryDirectory();
    final List<String> paths = [];
    for (int i = 0; i < urls.length; i++) {
      try {
        final response = await http.get(Uri.parse(urls[i]));
        if (response.statusCode == 200) {
          final file = File(
            '${dir.path}/edit_img_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
          );
          await file.writeAsBytes(response.bodyBytes);
          paths.add(file.path);
        }
      } catch (e) {
        print('Failed to download image $i: $e');
      }
    }
    return paths;
  }

  Future<List<DocumentDraft>> _downloadDocuments(List<String> urls) async {
    final dir = await getTemporaryDirectory();
    final List<DocumentDraft> docs = [];
    for (int i = 0; i < urls.length; i++) {
      try {
        final response = await http.get(Uri.parse(urls[i]));
        if (response.statusCode == 200) {
          final file = File(
            '${dir.path}/edit_doc_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
          );
          await file.writeAsBytes(response.bodyBytes);
          docs.add(
            DocumentDraft(
              type:
                  DocumentType
                      .other, // You might want to infer type from metadata
              file: file,
              title: 'Document ${i + 1}',
              isVerified: false,
            ),
          );
        }
      } catch (e) {
        print('Failed to download document $i: $e');
      }
    }
    return docs;
  }
  // lib/features/shop/creation/presentation/providers/edit_shop_provider.dart
  // In edit_shop_provider.dart

  ShopDraft _convertToDraft(ShopDetailsDTO dto) {
    return ShopDraft(
      shopId: dto.id,
      shopName: dto.shopName,
      shopType: dto.shopType,
      luxuryLevel: dto.luxuryLevel,
      overview: dto.overview,
      terms: dto.terms,
      localLogoPath: dto.shopLogoUrl,
      address: dto.address,
      city: dto.city,
      country: dto.country,
      latitude: dto.latitude,
      longitude: dto.longitude,
      phone: dto.phone,
      email: dto.email,
      website: dto.website,

      // ✅ Social Links
      socialLinks:
          dto.socialLinks
              .map(
                (link) => SocialLinkDraft(
                  platform: SocialPlatform.fromString(
                    link.platform.displayName,
                  ),
                  url: link.url,
                ),
              )
              .toList(),

      // ✅ Services (Appointment Slots)
      services: dto.services,

      // ✅ Opening Hours
      openingHours:
          dto.openingHours
              .map(
                (hour) => OpeningHoursDraft(
                  dayOfWeek: hour.dayOfWeek,
                  opensAt: hour.opensAt,
                  closesAt: hour.closesAt,
                  isClosed: hour.isClosed,
                ),
              )
              .toList(),

      // ✅ Awards
      awards:
          dto.awards
              .map(
                (award) => AwardDTO(
                  name: award.name,
                  id: const Uuid().v4(),
                  issuer: award.issuer,
                  description: award.description,
                  link: award.link,
                  dateReceived: award.dateReceived,
                  sortOrder: award.sortOrder,
                ),
              )
              .toList(),

      // ✅ Amenities (store as list of strings/IDs)
      amenityIds: dto.amenityIds,

      // ✅ Currency
      currencyCode: dto.currency,
      currencySymbol: _getCurrencySymbol(dto.currency),

      // ✅ Media - store image URLs (to be handled separately)
      localImagePaths: [], // No local files for published shop
      // ✅ Documents - if you have document images in shop_media
      documents: [], // You'll need to parse document images separately
      // ✅ Contacts — build from the extracted phone/email/website fields.
      // draft.contacts is the single source of truth for the edit flow.
      contacts: [
        if (dto.phone != null && dto.phone!.isNotEmpty)
          ContactDraft(
            type: ContactType.phone,
            value: dto.phone!,
            isPrimary: true,
          ),
        if (dto.email != null && dto.email!.isNotEmpty)
          ContactDraft(
            type: ContactType.email,
            value: dto.email!,
            isPrimary: true,
          ),
        if (dto.website != null && dto.website!.isNotEmpty)
          ContactDraft(
            type: ContactType.website,
            value: dto.website!,
            isPrimary: false,
          ),
      ],

      profileId: null,
      lastUpdated: DateTime.now(),
    );
  }

  String _getCurrencySymbol(String? code) {
    if (code == null) return '\$';
    return Currencies.fromCode(code)?.symbol ?? '\$';
  }

  Future<bool> saveChanges({
    required List<File> newImages,
    required List<String> imageIdsToDelete,
    required List<String> imagesToDelete, // URLs kept for storage deletion
    required List<DocumentDraft> newDocuments,
    required List<String> docIdsToDelete,
    required List<String>
    documentUrlsToDelete, // URLs kept for storage deletion
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final draft = _ref.read(shopCreationProvider);
      final repository = _ref.read(shopCreationRepositoryProvider);
      final uploadMedia = _ref.read(uploadShopMediaProvider);
      final profileId = _ref.read(currentProfileIdProvider)!;

      // Upload new images
      List<String> newImageUrls = [];
      if (newImages.isNotEmpty) {
        newImageUrls = await uploadMedia.execute(
          images: newImages,
          profileId: profileId,
          shopId: shopId,
        );
      }

      // Upload new documents
      List<String> newDocumentUrls = [];
      for (final doc in newDocuments) {
        final url = await uploadMedia.uploadSingleDocument(
          document: doc,
          profileId: profileId,
          shopId: shopId,
        );
        if (url != null) newDocumentUrls.add(url);
      }

      // Update shop in database (handles storage + DB deletion internally)
      await repository.updateShop(
        shopId: shopId,
        draft: draft,
        newImageUrls: newImageUrls,
        imageIdsToDelete: imageIdsToDelete,
        imagesToDelete: imagesToDelete,
        newDocumentUrls: newDocumentUrls,
        docIdsToDelete: docIdsToDelete,
        documentUrlsToDelete: documentUrlsToDelete,
      );

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final editShopProvider =
    StateNotifierProvider.family<EditShopNotifier, EditShopState, String>((
      ref,
      shopId,
    ) {
      return EditShopNotifier(ref, shopId);
    });
