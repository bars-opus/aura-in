// lib/features/freelancer/creation/presentation/providers/freelancer_creation_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/auth_providers.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/data/local_freelancer_storage.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/domain/models/freelancer_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/award_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/award_dto.dart';

/// State notifier for freelancer creation
class FreelancerCreationNotifier extends StateNotifier<FreelancerDraft> {
  final Ref _ref;
  final LocalFreelancerStorage _storage;
  final String _profileId;
  // True once loadExistingFreelancer() has been called, preventing
  // _loadInitialDraft() from overwriting freshly loaded edit data if the
  // async storage read completes after the edit data is already in place.
  bool _editDataLoaded = false;

  FreelancerCreationNotifier({
    required Ref ref,
    required LocalFreelancerStorage storage,
    required String profileId,
  }) : _ref = ref,
       _storage = storage,
       _profileId = profileId,
       super(FreelancerDraft(userId: profileId)) {
    _loadInitialDraft();
  }

  /// Load draft from local storage on startup
  Future<void> _loadInitialDraft() async {
    final saved = await _storage.loadDraft(_profileId);
    if (saved != null && !_editDataLoaded) {
      state = saved;
    }
  }

  /// Auto-save to local storage after any change
  Future<void> _persist() async {
    await _storage.saveDraft(_profileId, state);
  }

  // ============ Profile Methods ============

  void updateProfile({
    String? name,
    String? bio,
    String? profileImagePath,
    List<String>? specialties,
  }) {
    state = state.copyWith(
      name: name,
      bio: bio,
      profileImagePath: profileImagePath,
      specialties: specialties,
    );
    _persist();
  }

  void updateFreelancerType(String? type) {
    state = state.copyWith(freelancerType: type);
    _persist();
  }

  void updateFreelancerTypes(List<String> types) {
    state = state.copyWith(freelancerTypes: types);
    _persist();
  }

  void updateTerms(String terms) {
    state = state.copyWith(terms: terms);
    _persist();
  }

  void updateTools(List<String> toolIds) {
    state = state.copyWith(toolIds: toolIds);
    _persist();
  }

  // ============ Location Methods ============

  void updateLocation({
    double? latitude,
    double? longitude,
    int? travelRadiusKm,
    bool? canTravel,
  }) {
    state = state.copyWith(
      baseLatitude: latitude,
      baseLongitude: longitude,
      travelRadiusKm: travelRadiusKm,
      canTravel: canTravel,
    );
    _persist();
  }

  // ============ Services Methods ============

  void addService(AppointmentSlotDTO service) {
    state = state.copyWith(services: [...state.services, service]);
    _persist();
  }

  void updateService(int index, AppointmentSlotDTO service) {
    final updated = List<AppointmentSlotDTO>.from(state.services);
    updated[index] = service;
    state = state.copyWith(services: updated);
    _persist();
  }

  void removeService(int index) {
    final updated = List<AppointmentSlotDTO>.from(state.services)
      ..removeAt(index);
    state = state.copyWith(services: updated);
    _persist();
  }

  void updateServices(List<AppointmentSlotDTO> services) {
    state = state.copyWith(services: services);
    _persist();
  }

  // ============ Opening Hours Methods ============

  void setOpeningHours(List<OpeningHoursDraft> hours) {
    debugPrint('🔵 DEBUG: Updating opening hours, count: ${hours.length}');
    state = state.copyWith(openingHours: hours);
    debugPrint('🔵 DEBUG: isHoursComplete: ${state.isHoursComplete}');
    _persist();
  }

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

  // ============ Media Methods ============
  void addImagePath(String path) {
    debugPrint('🔵 DEBUG: Adding image path: $path');
    debugPrint('🔵 DEBUG: Current images count: ${state.localImagePaths.length}');

    if (state.localImagePaths.length >= 10) return;
    state = state.copyWith(localImagePaths: [...state.localImagePaths, path]);

    debugPrint('🔵 DEBUG: New images count: ${state.localImagePaths.length}');
    debugPrint('🔵 DEBUG: isMediaComplete: ${state.isMediaComplete}');
    _persist();
  }

  void removeImagePath(int index) {
    debugPrint('🔵 DEBUG: Removing image at index: $index');
    final updated = List<String>.from(state.localImagePaths)..removeAt(index);
    state = state.copyWith(localImagePaths: updated);
    debugPrint('🔵 DEBUG: New images count: ${state.localImagePaths.length}');
    debugPrint('🔵 DEBUG: isMediaComplete: ${state.isMediaComplete}');
    _persist();
  }

  void updateImagePaths(List<String> paths) {
    state = state.copyWith(localImagePaths: paths);
    debugPrint(
      '🔵 DEBUG: updateImagePaths count: ${paths.length}, isMediaComplete: ${state.isMediaComplete}',
    );
    _persist();
  }

  // ============ Documents Methods ============

  void addDocument(DocumentDraft document) {
    state = state.copyWith(documents: [...state.documents, document]);
    _persist();
  }

  void removeDocument(int index) {
    final updated = List<DocumentDraft>.from(state.documents)..removeAt(index);
    state = state.copyWith(documents: updated);
    _persist();
  }

  void updateDocuments(List<DocumentDraft> documents) {
    debugPrint('🔵 DEBUG: Updating documents, count: ${documents.length}');
    state = state.copyWith(documents: documents);
    debugPrint('🔵 DEBUG: isDocumentsComplete: ${state.isDocumentsComplete}');
    _persist();
  }

  // ============ Contact Methods ============

  void updateContacts(List<ContactDraft> contacts) {
    debugPrint('🔵 DEBUG: Updating contacts, count: ${contacts.length}');
    state = state.copyWith(contacts: contacts);
    debugPrint('🔵 DEBUG: isContactComplete: ${state.isContactComplete}');
    _persist();
  }

  void updateSocialLinks(List<SocialLinkDraft> socialLinks) {
    debugPrint('🔵 DEBUG: Updating social links, count: ${socialLinks.length}');
    state = state.copyWith(socialLinks: socialLinks);
    debugPrint('🔵 DEBUG: isSocialComplete: ${state.socialLinks.isNotEmpty}');
    _persist();
  }

  // ============ Awards Methods ============

  void updateAwards(List<AwardDTO> awards) {
    state = state.copyWith(awards: awards);
    _persist();
  }

  // ============ Settings Methods ============

  void updateBookingSettings({
    bool? autoAcceptBookings,
    int? maxBookingsPerDay,
    int? bufferMinutesBetweenBookings,
  }) {
    state = state.copyWith(
      autoAcceptBookings: autoAcceptBookings,
      maxBookingsPerDay: maxBookingsPerDay,
      bufferMinutesBetweenBookings: bufferMinutesBetweenBookings,
    );
    _persist();
  }

  // ============ Clear Methods ============

  Future<void> clearDraft() async {
    await _storage.clearDraft(_profileId);
    state = FreelancerDraft(userId: _profileId);
  }

  /// Load existing freelancer data for editing.
  /// Sets [_editDataLoaded] before updating state so that any still-pending
  /// [_loadInitialDraft] call cannot overwrite the freshly loaded edit data.
  void loadExistingFreelancer(FreelancerDraft existing) {
    _editDataLoaded = true;
    state = existing.copyWith(lastUpdated: DateTime.now());
    _persist();
  }

  bool get isEditMode => state.freelancerId != null;
}

/// Provider for freelancer creation state
final freelancerCreationProvider =
    StateNotifierProvider<FreelancerCreationNotifier, FreelancerDraft>((ref) {
      final profileId = ref.watch(currentProfileIdProvider);
      if (profileId == null) {
        throw Exception('User not authenticated');
      }

      final storage = ref.watch(localFreelancerStorageProvider);
      return FreelancerCreationNotifier(
        ref: ref,
        storage: storage,
        profileId: profileId,
      );
    });
