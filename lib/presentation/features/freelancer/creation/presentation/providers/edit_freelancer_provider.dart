// lib/features/freelancer/creation/presentation/providers/edit_freelancer_provider.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/auth_providers.dart';
import 'package:http/http.dart' as http;
import 'package:nano_embryo/presentation/features/freelancer/creation/domain/models/freelancer_draft.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/models/freelancer_details_dto.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/repositories/supabase_freelancer_repository.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/upload_shop_media.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/award_dto.dart';
import 'package:path_provider/path_provider.dart';
import 'freelancer_creation_provider.dart';

const _kDownloadTimeout = Duration(seconds: 15);
const _kMaxDownloadRetries = 2;

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

      // Start all futures before awaiting any — they run concurrently.
      final freelancerF       = repository.getFreelancerById(freelancerId);
      final portfolioF        = repository.getFreelancerPortfolio(freelancerId);
      final documentUrlsF     = repository.getFreelancerDocumentUrls(freelancerId);
      final servicesF         = repository.getFreelancerServices(freelancerId);
      final hoursF            = repository.getFreelancerHoursDraft(freelancerId);
      final contactsF         = repository.getFreelancerContacts(freelancerId);
      final socialLinksF      = repository.getFreelancerSocialLinks(freelancerId);
      final awardsF           = repository.getFreelancerAwards(freelancerId);
      final imageMediasF      = repository.getFreelancerImageMedias(freelancerId);
      final documentMediasF   = repository.getFreelancerDocumentMedias(freelancerId);

      final freelancer      = await freelancerF;
      final portfolioImages = await portfolioF;
      final documentUrls    = await documentUrlsF;
      final services        = await servicesF;
      final openingHours    = await hoursF;
      final contacts        = await contactsF;
      final socialLinks     = await socialLinksF;
      final awards          = await awardsF;
      final imageMedias     = await imageMediasF;
      final documentMedias  = await documentMediasF;

      if (freelancer == null) {
        throw Exception('Freelancer not found');
      }

      // Start both downloads before awaiting either — they run concurrently.
      final imageDownloadF = _downloadFiles(portfolioImages);
      final docDownloadF   = _downloadDocuments(documentUrls);
      final localImagePaths     = await imageDownloadF;
      final localDocumentDrafts = await docDownloadF;

      // Build temp-path → original-URL maps
      final Map<String, String> localPathToOriginalUrl = {};
      for (int i = 0; i < portfolioImages.length && i < localImagePaths.length; i++) {
        localPathToOriginalUrl[localImagePaths[i]] = portfolioImages[i];
      }

      final Map<String, String> localDocPathToOriginalUrl = {};
      for (int i = 0; i < documentUrls.length && i < localDocumentDrafts.length; i++) {
        localDocPathToOriginalUrl[localDocumentDrafts[i].file.path] = documentUrls[i];
      }

      // Build URL → shop_media.id maps for reliable PK-based deletion.
      final Map<String, String> imageUrlToId = {
        for (final media in imageMedias) media.url: media.id,
      };
      final Map<String, String> docUrlToId = {
        for (final media in documentMedias) media.url: media.id,
      };

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
    } catch (e, stack) {
      debugPrint('EditFreelancerNotifier._loadFreelancerData: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load your profile. Please try again.',
      );
    }
  }

  // Fetches a URL with a timeout and one retry on transient failure.
  Future<http.Response?> _fetchWithRetry(String url) async {
    for (int attempt = 1; attempt <= _kMaxDownloadRetries; attempt++) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(_kDownloadTimeout);
        if (response.statusCode == 200) return response;
        return null; // non-200 is not retryable
      } on TimeoutException {
        if (attempt == _kMaxDownloadRetries) return null;
        await Future.delayed(Duration(milliseconds: 300 * attempt));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // Downloads all URLs concurrently.
  Future<List<String>> _downloadFiles(List<String> urls) async {
    if (urls.isEmpty) return [];
    final dir = await getTemporaryDirectory();
    final futures = List.generate(urls.length, (i) async {
      try {
        final response = await _fetchWithRetry(urls[i]);
        if (response == null) return null;
        final file = File(
          '${dir.path}/freelancer_edit_img_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        );
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      } catch (e) {
        debugPrint('Failed to download image $i: $e');
        return null;
      }
    });
    final results = await Future.wait(futures);
    return results.whereType<String>().toList();
  }

  // Downloads all document URLs concurrently.
  Future<List<DocumentDraft>> _downloadDocuments(List<String> urls) async {
    if (urls.isEmpty) return [];
    final dir = await getTemporaryDirectory();
    final futures = List.generate(urls.length, (i) async {
      try {
        final response = await _fetchWithRetry(urls[i]);
        if (response == null) return null;
        final file = File(
          '${dir.path}/freelancer_edit_doc_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        );
        await file.writeAsBytes(response.bodyBytes);
        return DocumentDraft(
          type: DocumentType.other,
          file: file,
          title: 'Document ${i + 1}',
          isVerified: false,
        );
      } catch (e) {
        debugPrint('Failed to download document $i: $e');
        return null;
      }
    });
    final results = await Future.wait(futures);
    return results.whereType<DocumentDraft>().toList();
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

  // Deletes temp files that were downloaded during this edit session.
  Future<void> _cleanupTempFiles() async {
    final allPaths = [
      ...state.localPathToOriginalUrl.keys,
      ...state.localDocPathToOriginalUrl.keys,
    ];
    for (final path in allPaths) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }

  Future<bool> saveChanges({
    required List<File> newImages,
    required List<String> imageIdsToDelete,
    required List<String> imagesToDelete,
    required List<DocumentDraft> newDocuments,
    required List<String> docIdsToDelete,
    required List<String> documentUrlsToDelete,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final draft = _ref.read(freelancerCreationProvider);
      final repository = _ref.read(freelancerRepositoryProvider);
      final uploadMedia = _ref.read(uploadShopMediaProvider);
      final profileId = _ref.read(currentProfileIdProvider)!;

      // Start both uploads before awaiting either — they run concurrently.
      final imageUploadF = newImages.isNotEmpty
          ? uploadMedia.execute(
              images: newImages,
              profileId: profileId,
              shopId: freelancerId,
            )
          : Future.value(<String>[]);
      final docUploadF = () async {
        final urls = <String>[];
        for (final doc in newDocuments) {
          final url = await uploadMedia.uploadSingleDocument(
            document: doc,
            profileId: profileId,
            shopId: freelancerId,
          );
          if (url != null) urls.add(url);
        }
        return urls;
      }();
      final newImageUrls    = await imageUploadF;
      final newDocumentUrls = await docUploadF;

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

      // Clean up temp files now that the save succeeded.
      await _cleanupTempFiles();

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e, stack) {
      debugPrint('EditFreelancerNotifier.saveChanges: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save changes. Please try again.',
      );
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
