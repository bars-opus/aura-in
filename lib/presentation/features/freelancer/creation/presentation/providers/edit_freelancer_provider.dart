// lib/features/freelancer/creation/presentation/providers/edit_freelancer_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:nano_embryo/presentation/features/freelancer/creation/domain/models/freelancer_draft.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/models/freelancer_details_dto.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/repositories/supabase_freelancer_repository.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/upload_shop_media.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/award_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/award_dto.dart';
import 'package:path_provider/path_provider.dart';
import 'freelancer_creation_provider.dart';

/// State for edit freelancer operation
class EditFreelancerState {
  final bool isLoading;
  final String? error;
  final FreelancerDraft? draft;
  final List<String> existingImageUrls;
  final List<String> existingDocumentUrls;
  // Maps each downloaded local temp path back to its original Supabase URL.
  // Used at save time to distinguish "kept existing" from "truly new" images.
  final Map<String, String> localPathToOriginalUrl;
  final Map<String, String> localDocPathToOriginalUrl;
  // Maps each Supabase URL → shop_media.id so we delete by PK, not URL string.
  final Map<String, String> imageUrlToId;
  final Map<String, String> docUrlToId;

  const EditFreelancerState({
    this.isLoading = false,
    this.error,
    this.draft,
    this.existingImageUrls = const [],
    this.existingDocumentUrls = const [],
    this.localPathToOriginalUrl = const {},
    this.localDocPathToOriginalUrl = const {},
    this.imageUrlToId = const {},
    this.docUrlToId = const {},
  });

  EditFreelancerState copyWith({
    bool? isLoading,
    String? error,
    FreelancerDraft? draft,
    List<String>? existingImageUrls,
    List<String>? existingDocumentUrls,
    Map<String, String>? localPathToOriginalUrl,
    Map<String, String>? localDocPathToOriginalUrl,
    Map<String, String>? imageUrlToId,
    Map<String, String>? docUrlToId,
  }) {
    return EditFreelancerState(
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

/// Notifier for editing an existing freelancer profile
class EditFreelancerNotifier extends StateNotifier<EditFreelancerState> {
  final Ref _ref;
  final String freelancerId;

  EditFreelancerNotifier(this._ref, this.freelancerId)
    : super(const EditFreelancerState()) {
    _loadFreelancerData();
  }

  
  Future<void> _loadFreelancerData() async {
  state = state.copyWith(isLoading: true, error: null);

  try {
    final repository = _ref.read(freelancerRepositoryProvider);
    final freelancer = await repository.getFreelancerById(freelancerId);

    if (freelancer == null) {
      throw Exception('Freelancer not found');
    }

    // Fetch data using the correct methods
    final portfolioImages = await repository.getFreelancerPortfolio(freelancerId);
    final documentUrls = await repository.getFreelancerDocumentUrls(freelancerId);
    final services = await repository.getFreelancerServices(freelancerId);
    final openingHours = await repository.getFreelancerHoursDraft(freelancerId);
    final contacts = await repository.getFreelancerContacts(freelancerId);
    final socialLinks = await repository.getFreelancerSocialLinks(freelancerId);
    final awards = await repository.getFreelancerAwards(freelancerId);
    
    // ✅ Use SimpleMedia for image and document medias
    final imageMedias = await repository.getFreelancerImageMedias(freelancerId);
    final documentMedias = await repository.getFreelancerDocumentMedias(freelancerId);

    // Download images to local files
    final localImagePaths = await _downloadFiles(portfolioImages);
    final localDocumentDrafts = await _downloadDocuments(documentUrls);

    // Build temp-path → original-URL maps
    final Map<String, String> localPathToOriginalUrl = {};
    for (int i = 0; i < portfolioImages.length && i < localImagePaths.length; i++) {
      localPathToOriginalUrl[localImagePaths[i]] = portfolioImages[i];
    }

    final Map<String, String> localDocPathToOriginalUrl = {};
    for (int i = 0; i < documentUrls.length && i < localDocumentDrafts.length; i++) {
      localDocPathToOriginalUrl[localDocumentDrafts[i].file.path] = documentUrls[i];
    }

    // Build URL → shop_media.id maps for reliable PK-based deletion using SimpleMedia
    final Map<String, String> imageUrlToId = {
      for (final media in imageMedias) media.url: media.id,
    };
    final Map<String, String> docUrlToId = {
      for (final media in documentMedias) media.url: media.id,
    };

    // Convert to draft
    final draft = _convertToDraft(
      freelancer: freelancer,
      services: services,
      openingHours: openingHours,
      contacts: contacts,
      socialLinks: socialLinks,
      awards: awards,
    );

    final updatedDraft = draft.copyWith(
      localImagePaths: localImagePaths,
      documents: localDocumentDrafts,
    );

    // Load into creation provider
    final creationNotifier = _ref.read(freelancerCreationProvider.notifier);
    creationNotifier.loadExistingFreelancer(updatedDraft);

    state = state.copyWith(
      isLoading: false,
      draft: updatedDraft,
      existingImageUrls: portfolioImages,
      existingDocumentUrls: documentUrls,
      localPathToOriginalUrl: localPathToOriginalUrl,
      localDocPathToOriginalUrl: localDocPathToOriginalUrl,
      imageUrlToId: imageUrlToId,
      docUrlToId: docUrlToId,
    );
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      error: 'Failed to load freelancer: $e',
    );
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
            '${dir.path}/freelancer_edit_img_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
          );
          await file.writeAsBytes(response.bodyBytes);
          paths.add(file.path);
        }
      } catch (e) {
        debugPrint('Failed to download image $i: $e');
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
            '${dir.path}/freelancer_edit_doc_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
          );
          await file.writeAsBytes(response.bodyBytes);
          docs.add(
            DocumentDraft(
              type: DocumentType.other,
              file: file,
              title: 'Document ${i + 1}',
              isVerified: false,
            ),
          );
        }
      } catch (e) {
        debugPrint('Failed to download document $i: $e');
      }
    }
    return docs;
  }

  FreelancerDraft _convertToDraft({
    required FreelancerDetailsDTO freelancer,
    required List<AppointmentSlotDTO> services,
    required List<OpeningHoursDraft> openingHours,
    required List<ContactDraft> contacts,
    required List<SocialLinkDraft> socialLinks,
    required List<AwardDTO> awards,
  }) {
    return FreelancerDraft(
      freelancerId: freelancer.id,
      userId: null,
      name: freelancer.name,
      bio: freelancer.bio,
      terms: freelancer.terms,
      profileImagePath: freelancer.profileImageUrl,
      specialties: freelancer.specialties,
      freelancerType: freelancer.freelancerType?.name,
      freelancerTypes: freelancer.freelancerTypes.map((t) => t.name).toList(),
      toolIds: freelancer.tools,
      baseLatitude: freelancer.baseLatitude,
      baseLongitude: freelancer.baseLongitude,
      travelRadiusKm: freelancer.travelRadiusKm,
      canTravel: freelancer.canTravel,
      services: services,
      openingHours: openingHours,
      localImagePaths: [], // Will be set after download
      documents: [], // Will be set after download
      contacts: contacts,
      socialLinks: socialLinks,
      awards: awards,
      subaccountId: freelancer.subaccountId,
      transferRecipientId: freelancer.transferRecipientId,
      autoAcceptBookings: freelancer.autoAcceptBookings,
      maxBookingsPerDay: freelancer.maxBookingsPerDay,
      bufferMinutesBetweenBookings: freelancer.bufferMinutesBetweenBookings,
    );
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
      final draft = _ref.read(freelancerCreationProvider);
      final repository = _ref.read(freelancerRepositoryProvider);
      final uploadMedia = _ref.read(uploadShopMediaProvider);
      final profileId = _ref.read(currentProfileIdProvider)!;

      // Upload new images
      List<String> newImageUrls = [];
      if (newImages.isNotEmpty) {
        newImageUrls = await uploadMedia.execute(
          images: newImages,
          profileId: profileId,
          shopId: freelancerId,
        );
      }

      // Upload new documents
      List<String> newDocumentUrls = [];
      for (final doc in newDocuments) {
        final url = await uploadMedia.uploadSingleDocument(
          document: doc,
          profileId: profileId,
          shopId: freelancerId,
        );
        if (url != null) newDocumentUrls.add(url);
      }

      // Update freelancer in database (handles storage + DB deletion internally)
      await repository.updateFreelancer(
        workerId: freelancerId,
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

// Provider for edit freelancer
final editFreelancerProvider = StateNotifierProvider.family<
  EditFreelancerNotifier,
  EditFreelancerState,
  String
>((ref, freelancerId) => EditFreelancerNotifier(ref, freelancerId));
