// lib/features/shop/creation/presentation/providers/shop_creation_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/auth_providers.dart';
import 'package:nano_embryo/core/services/media/image_file_service.dart';
import 'package:nano_embryo/presentation/features/currency/domain/entities/currency.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/local_draft_storage.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/shop_draft.dart'
    show OpeningHoursDraft, AppointmentSlotDTO, ShopDraft, SocialLinkDraft;
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/award_dto.dart';

/// State notifier for shop creation.
class ShopCreationNotifier extends StateNotifier<ShopDraft> {
  final Ref _ref;
  final LocalDraftStorage _storage;
  final String _profileId;
  ShopCreationNotifier({
    required Ref ref,
    required LocalDraftStorage storage,
    required this.documentPaths, // ← Now in notifier
    required String profileId,
  }) : _ref = ref,
       _storage = storage,
       _profileId = profileId,
       super(
         ShopDraft(
           profileId: profileId,
           //  documentPaths: documentPaths, // ← MUST pass to ShopDraft!
         ),
       ) {
    _loadInitialDraft();
  }

  /// Load draft from local storage on startup.
  Future<void> _loadInitialDraft() async {
    final saved = _storage.loadDraft(_profileId);
    if (saved != null) {
      // Verify image files still exist
      final validImagePaths = <String>[];
      for (final path in saved.localImagePaths) {
        if (await ImageFileService.fileExists(path)) {
          validImagePaths.add(path);
        }
      }

      // Update draft with only valid images
      if (validImagePaths.length != saved.localImagePaths.length) {
        state = saved.copyWith(localImagePaths: validImagePaths);
      } else {
        state = saved;
      }
    }
  }

  /// Auto-save to local storage after any change.
  Future<void> _persist() async {
    await _storage.saveDraft(_profileId, state);
  }

  /// Update basics section.
  void updateBasics({
    String? shopName,
    String? shopType,
    String? luxuryLevel,
    String? overview,
    String? terms,
  }) {
    state = state.copyWith(
      shopName: shopName,
      shopType: shopType,
      luxuryLevel: luxuryLevel,
      overview: overview,
      terms: terms,
    );
    _persist();
  }

  void updateLogo(String? logoPath) {
    state = state.copyWith(localLogoPath: logoPath);
    _persist();
  }

  /// Update location.
  void updateLocation({
    String? address,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? currencyCode,
    String? currencySymbol,
  }) {
    state = state.copyWith(
      address: address,
      city: city,
      country: country,
      latitude: latitude,
      longitude: longitude,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
    );
    _persist();
  }

  // Add method to update currency separately (for edit mode)
  void updateCurrency(Currency currency) {
    state = state.copyWith(
      currencyCode: currency.code,
      currencySymbol: currency.symbol,
    );
    _persist();
  }

  /// Update contact info.
  void updateContact({
    String? phone,
    String? email,
    String? website,
    List<SocialLinkDraft>? socialLinks,
  }) {
    state = state.copyWith(
      phone: phone,
      email: email,
      website: website,
      socialLinks: socialLinks ?? state.socialLinks,
    );
    _persist();
  }

  /// Add a service.
  void addService(AppointmentSlotDTO service) {
    state = state.copyWith(services: [...state.services, service]);
    _persist();
  }

  /// Remove a service.
  void removeService(int index) {
    final updated = List<AppointmentSlotDTO>.from(state.services)
      ..removeAt(index);
    state = state.copyWith(services: updated);
    _persist();
  }

  /// Update opening hours.
  void setOpeningHours(List<OpeningHoursDraft> hours) {
    state = state.copyWith(openingHours: hours);
    _persist();
  }

  /// Add local image path (after picking).
  void addImagePath(String path) {
    // Max 5 images as per phase 4.
    if (state.localImagePaths.length >= 5) return;
    state = state.copyWith(localImagePaths: [...state.localImagePaths, path]);
    _persist();
  }

  /// Remove image path.
  void removeImagePath(int index) {
    final updated = List<String>.from(state.localImagePaths)..removeAt(index);
    state = state.copyWith(localImagePaths: updated);
    _persist();
  }

  /// Reorder images.
  void reorderImages(int oldIndex, int newIndex) {
    final images = List<String>.from(state.localImagePaths);
    if (oldIndex < newIndex) newIndex -= 1;
    final item = images.removeAt(oldIndex);
    images.insert(newIndex, item);
    state = state.copyWith(localImagePaths: images);
    _persist();
  }

  /// Clear the entire draft (e.g., after publish or logout).
  Future<void> clearDraft() async {
    await _storage.clearDraft(_profileId);
    state =
        ShopDraft(); // reset to empty, but keep profileId? We'll need to pass profileId again.
    // Actually we should set profileId again.
    state = state.copyWith(profileId: _profileId);
  }

  // Add to ShopCreationNotifier class

  void updateService(int index, AppointmentSlotDTO service) {
    final updated = List<AppointmentSlotDTO>.from(state.services);
    updated[index] = service;
    state = state.copyWith(services: updated);
    _persist();
  }

  void reorderServices(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final services = List<AppointmentSlotDTO>.from(state.services);
    final item = services.removeAt(oldIndex);
    services.insert(newIndex, item);
    state = state.copyWith(services: services);
    _persist();
  }

  // Add to ShopCreationNotifier class
  void updateImagePaths(List<String> paths) {
    state = state.copyWith(localImagePaths: paths);
    _persist();
  }

  /// Load existing shop data for editing
  void loadFromDraft(ShopDraft draft) {
    state = draft.copyWith(lastUpdated: DateTime.now());
    _persist();
  }

  // In shop_creation_provider.dart

  void loadPublishedShop(ShopDraft publishedShop) {
    state = publishedShop.copyWith(lastUpdated: DateTime.now());
    _persist();
  }

  void addSocialLink(SocialLinkDraft link) {
    state = state.copyWith(socialLinks: [...state.socialLinks, link]);
    _persist();
  }

  void updateSocialLink(int index, SocialLinkDraft link) {
    final updated = List<SocialLinkDraft>.from(state.socialLinks);
    updated[index] = link;
    state = state.copyWith(socialLinks: updated);
    _persist();
  }

  void removeSocialLink(int index) {
    final updated = List<SocialLinkDraft>.from(state.socialLinks)
      ..removeAt(index);
    state = state.copyWith(socialLinks: updated);
    _persist();
  }

  void reorderSocialLinks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final links = List<SocialLinkDraft>.from(state.socialLinks);
    final item = links.removeAt(oldIndex);
    links.insert(newIndex, item);
    state = state.copyWith(socialLinks: links);
    _persist();
  }

  void updateAmenities(List<String> amenityIds) {
    state = state.copyWith(amenityIds: amenityIds);
    _persist();
  }

  // Add method
  // void updateDocumentPaths(List<String> paths) {
  //   state = state.copyWith(documentPaths: paths);
  //   _persist();
  // }

  // Add this method
  void updateAwards(List<AwardDTO> awards) {
    state = state.copyWith(awards: awards);
    _persist();
  }

  // Add this method
  void updateContacts(List<ContactDraft> contacts) {
    // Extract primary phone and email for backward compatibility
    final phone =
        contacts
            .firstWhere(
              (c) => c.type == ContactType.phone,
              orElse: () => ContactDraft(type: ContactType.phone, value: ''),
            )
            .value;

    final email =
        contacts
            .firstWhere(
              (c) => c.type == ContactType.email,
              orElse: () => ContactDraft(type: ContactType.email, value: ''),
            )
            .value;

    final website =
        contacts
            .firstWhere(
              (c) => c.type == ContactType.website,
              orElse: () => ContactDraft(type: ContactType.website, value: ''),
            )
            .value;

    state = state.copyWith(
      contacts: contacts,
      phone: phone.isNotEmpty ? phone : null,
      email: email.isNotEmpty ? email : null,
      website: website.isNotEmpty ? website : null,
    );
    _persist();
  }

  // lib/features/shop/creation/presentation/providers/shop_creation_provider.dart

  // Add these methods to ShopCreationNotifier for better auto-save support

  /// Update overview with debounced save
  void updateOverview(String overview) {
    state = state.copyWith(overview: overview);
    _persist();
  }

  /// Update terms with debounced save
  void updateTerms(String terms) {
    state = state.copyWith(terms: terms);
    _persist();
  }

  /// Toggle amenity (immediate save)
  void toggleAmenity(String amenityId) {
    final current = state.amenityIds;
    final updated =
        current.contains(amenityId)
            ? current.where((id) => id != amenityId).toList()
            : [...current, amenityId];

    state = state.copyWith(amenityIds: updated);
    _persist();
  }

  /// Update opening hours for a specific day (immediate save)
  void updateDayHours(
    int dayOfWeek,
    String opensAt,
    String closesAt,
    bool isClosed,
  ) {
    final current = List<OpeningHoursDraft>.from(state.openingHours);
    final index = current.indexWhere((h) => h.dayOfWeek == dayOfWeek);

    final updatedHour = OpeningHoursDraft(
      dayOfWeek: dayOfWeek,
      opensAt: opensAt,
      closesAt: closesAt,
      isClosed: isClosed,
    );

    if (index >= 0) {
      current[index] = updatedHour;
    } else {
      current.add(updatedHour);
    }

    state = state.copyWith(openingHours: current);
    _persist();
  }

  /// Batch update for hours (when multiple changes happen)
  void updateAllHours(List<OpeningHoursDraft> hours) {
    state = state.copyWith(openingHours: hours);
    _persist();
  }

  /// Update services list
  void updateServices(List<AppointmentSlotDTO> services) {
    state = state.copyWith(services: services);
    _persist();
  }

  /// Update social links list
  void updateSocialLinks(List<SocialLinkDraft> socialLinks) {
    state = state.copyWith(socialLinks: socialLinks);
    _persist();
  }

  void updateDocuments(List<DocumentDraft> documents) {
    state = state.copyWith(documents: documents);
    _persist();
  }

  /// Check if we're in edit mode
  bool get isEditMode => state.shopId != null;

  // Add these fields to ShopDraft
  final List<String> documentPaths; // Store paths locally

  /// The shop ID (only available in edit mode)
  String? get shopId => state.shopId;
}

/// Provider for the notifier. It depends on the profile ID.
// In shop_creation_provider.dart
// In shop_creation_provider.dart

final shopCreationProvider =
    StateNotifierProvider<ShopCreationNotifier, ShopDraft>((ref) {
      final profileId = ref.watch(currentProfileIdProvider);
      if (profileId == null) {
        throw Exception('User not authenticated');
      }

      LocalDraftStorage storage;
      try {
        storage = ref.watch(localDraftStorageProvider);
      } catch (e) {
        throw Exception('Storage not ready. Please restart the app.');
      }

      return ShopCreationNotifier(
        ref: ref,
        storage: storage,
        profileId: profileId,
        documentPaths: const [], // ✅ Pass empty list as initial value
      );
    });
// final shopCreationProvider =
//     StateNotifierProvider<ShopCreationNotifier, ShopDraft>((ref) {
//       final profileId = ref.watch(currentProfileIdProvider);

//       if (profileId == null) {
//         // Handle not logged in – maybe return a dummy or throw.
//         throw Exception('User not authenticated');
//       }
//       final storage = ref.watch(localDraftStorageProvider).value!;
//       return ShopCreationNotifier(
//         ref: ref,
//         storage: storage,
//         profileId: profileId,
//         documentPaths: [],
//       );
//     });
