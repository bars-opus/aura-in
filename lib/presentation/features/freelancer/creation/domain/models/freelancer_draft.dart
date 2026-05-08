// lib/features/freelancer/creation/domain/models/freelancer_draft.dart
import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/award_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/award_dto.dart';

/// Draft model for freelancer creation flow
/// Similar to ShopDraft but for freelancers

/// Draft model for freelancer creation flow
/// Similar to ShopDraft but for freelancers
class FreelancerDraft extends Equatable {
  // Core fields
  final String? freelancerId;
  final String? userId;

  // Profile Information
  final String? name;
  final String? bio;
  final String? terms;

  final String? profileImagePath; // Local path, not yet uploaded
  final List<String> specialties;

  // Freelancer Type & Tools
  final String? freelancerType; // Primary type (barber, hairdresser, etc.)
  final List<String> freelancerTypes; // Multiple types if needed
  final List<String> toolIds; // Selected tool IDs

  // Location & Travel
  final double? baseLatitude;
  final double? baseLongitude;
  final int travelRadiusKm; // 5-50km
  final bool canTravel;
  final String? serviceAddress; // For clients to enter address

  // Services & Availability (Reuse from shops)
  final List<AppointmentSlotDTO> services;
  final List<OpeningHoursDraft> openingHours;

  // Media & Documents
  final List<String> localImagePaths; // Portfolio images
  final List<DocumentDraft> documents; // Certifications

  // Contact & Social
  final List<ContactDraft> contacts;
  final List<SocialLinkDraft> socialLinks;

  // Legacy contact fields (for backward compatibility with edit flow)
  String? get phone =>
      contacts
          .firstWhere(
            (c) => c.type == ContactType.phone,
            orElse: () => ContactDraft(type: ContactType.phone, value: ''),
          )
          .value
          .nullIfEmpty;

  String? get email =>
      contacts
          .firstWhere(
            (c) => c.type == ContactType.email,
            orElse: () => ContactDraft(type: ContactType.email, value: ''),
          )
          .value
          .nullIfEmpty;

  String? get website =>
      contacts
          .firstWhere(
            (c) => c.type == ContactType.website,
            orElse: () => ContactDraft(type: ContactType.website, value: ''),
          )
          .value
          .nullIfEmpty;

  // Awards (optional for freelancers)
  final List<AwardDTO> awards;

  // Payment Settings
  final String? subaccountId;
  final String? transferRecipientId;

  // Booking Settings
  final bool autoAcceptBookings;
  final int maxBookingsPerDay;
  final int bufferMinutesBetweenBookings;

  // Metadata
  final DateTime? lastUpdated;

  // ============================================
  // Section Completion Statuses
  // ============================================

  bool get isProfileComplete =>
      name != null &&
      name!.isNotEmpty &&
      freelancerType != null &&
      freelancerType!.isNotEmpty;

  bool get isLocationComplete =>
      baseLatitude != null && baseLongitude != null && travelRadiusKm >= 5;

  bool get isToolsComplete => toolIds.isNotEmpty;

  bool get isServicesComplete => services.isNotEmpty;

  bool get isHoursComplete => openingHours.any((hour) => !hour.isClosed);

  bool get isMediaComplete => localImagePaths.length >= 3;

  bool get isDocumentsComplete => documents.isNotEmpty;

  bool get isContactComplete => contacts.isNotEmpty;

  bool get isSocialComplete => socialLinks.isNotEmpty;

  // Minimum Viable Product check (for publishing)
  bool get isMinimumViable =>
      isProfileComplete &&
      isLocationComplete &&
      isMediaComplete &&
      isToolsComplete &&
      isServicesComplete &&
      isHoursComplete;

  // Total sections count (8 sections now)
  static const int totalSections = 8;

  int get completedSectionsCount =>
      [
        isProfileComplete,
        isLocationComplete,
        isToolsComplete,
        isServicesComplete,
        isHoursComplete,
        isMediaComplete,
        isDocumentsComplete,
        isContactComplete,
      ].where((completed) => completed).length;

  // ============================================
  // Constructor
  // ============================================

  const FreelancerDraft({
    this.freelancerId,
    this.userId,
    this.name,
    this.bio,
    this.profileImagePath,
    this.specialties = const [],
    this.freelancerType,
    this.freelancerTypes = const [],
    this.toolIds = const [],
    this.baseLatitude,
    this.baseLongitude,
    this.travelRadiusKm = 10,
    this.canTravel = true,
    this.serviceAddress,
    this.services = const [],
    this.openingHours = const [],
    this.localImagePaths = const [],
    this.documents = const [],
    this.contacts = const [],
    this.socialLinks = const [],
    this.awards = const [],
    this.subaccountId,
    this.transferRecipientId,
    this.autoAcceptBookings = false,
    this.maxBookingsPerDay = 10,
    this.bufferMinutesBetweenBookings = 15,
    this.lastUpdated,
    this.terms,
  });

  // ============================================
  // Copy With
  // ============================================

  /// Create a copy with updated fields
  FreelancerDraft copyWith({
    String? freelancerId,
    String? userId,
    String? name,
    String? bio,
    String? profileImagePath,
    List<String>? specialties,
    String? freelancerType,
    List<String>? freelancerTypes,
    List<String>? toolIds,
    double? baseLatitude,
    double? baseLongitude,
    int? travelRadiusKm,
    bool? canTravel,
    String? serviceAddress,
    List<AppointmentSlotDTO>? services,
    List<OpeningHoursDraft>? openingHours,
    List<String>? localImagePaths,
    List<DocumentDraft>? documents,
    List<ContactDraft>? contacts,
    List<SocialLinkDraft>? socialLinks,
    List<AwardDTO>? awards,
    String? subaccountId,
    String? transferRecipientId,
    String? terms,
    bool? autoAcceptBookings,
    int? maxBookingsPerDay,
    int? bufferMinutesBetweenBookings,
    DateTime? lastUpdated,
  }) {
    return FreelancerDraft(
      freelancerId: freelancerId ?? this.freelancerId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      specialties: specialties ?? this.specialties,
      freelancerType: freelancerType ?? this.freelancerType,
      freelancerTypes: freelancerTypes ?? this.freelancerTypes,
      toolIds: toolIds ?? this.toolIds,
      baseLatitude: baseLatitude ?? this.baseLatitude,
      baseLongitude: baseLongitude ?? this.baseLongitude,
      travelRadiusKm: travelRadiusKm ?? this.travelRadiusKm,
      canTravel: canTravel ?? this.canTravel,
      serviceAddress: serviceAddress ?? this.serviceAddress,
      services: services ?? this.services,
      openingHours: openingHours ?? this.openingHours,
      localImagePaths: localImagePaths ?? this.localImagePaths,
      documents: documents ?? this.documents,
      contacts: contacts ?? this.contacts,
      socialLinks: socialLinks ?? this.socialLinks,
      terms: terms?? this.terms,
      awards: awards ?? this.awards,
      subaccountId: subaccountId ?? this.subaccountId,
      transferRecipientId: transferRecipientId ?? this.transferRecipientId,
      autoAcceptBookings: autoAcceptBookings ?? this.autoAcceptBookings,
      maxBookingsPerDay: maxBookingsPerDay ?? this.maxBookingsPerDay,
      bufferMinutesBetweenBookings:
          bufferMinutesBetweenBookings ?? this.bufferMinutesBetweenBookings,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  // ============================================
  // JSON Serialization
  // ============================================

  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'freelancerId': freelancerId,
      'userId': userId,
      'name': name,
      'bio': bio,
      'profileImagePath': profileImagePath,
      'specialties': specialties,
      'freelancerType': freelancerType,
      'freelancerTypes': freelancerTypes,
      'toolIds': toolIds,
      'baseLatitude': baseLatitude,
      'baseLongitude': baseLongitude,
      'travelRadiusKm': travelRadiusKm,
      'canTravel': canTravel,
      'serviceAddress': serviceAddress,
      'services': services.map((s) => s.toJson()).toList(),
      'openingHours': openingHours.map((h) => h.toJson()).toList(),
      'localImagePaths': localImagePaths,
      'documents': documents.map((d) => d.toJson()).toList(),
      'contacts': contacts.map((c) => c.toJson()).toList(),
      'socialLinks': socialLinks.map((s) => s.toJson()).toList(),
      'awards': awards.map((a) => a.toJson()).toList(),
      'subaccountId': subaccountId,
      'transferRecipientId': transferRecipientId,
      'autoAcceptBookings': autoAcceptBookings,
      'maxBookingsPerDay': maxBookingsPerDay,
      'bufferMinutesBetweenBookings': bufferMinutesBetweenBookings,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'terms': terms,
    };
  }

  /// Create from JSON
  factory FreelancerDraft.fromJson(Map<String, dynamic> json) {
    return FreelancerDraft(
      freelancerId: json['freelancerId'] as String?,
      userId: json['userId'] as String?,
      name: json['name'] as String?,
      bio: json['bio'] as String?,
terms: json['terms'] as String?,
      
      profileImagePath: json['profileImagePath'] as String?,
      specialties: List<String>.from(json['specialties'] ?? []),
      freelancerType: json['freelancerType'] as String?,
      freelancerTypes: List<String>.from(json['freelancerTypes'] ?? []),
      toolIds: List<String>.from(json['toolIds'] ?? []),
      baseLatitude: (json['baseLatitude'] as num?)?.toDouble(),
      baseLongitude: (json['baseLongitude'] as num?)?.toDouble(),
      travelRadiusKm: json['travelRadiusKm'] as int? ?? 10,
      canTravel: json['canTravel'] as bool? ?? true,
      serviceAddress: json['serviceAddress'] as String?,
      services:
          (json['services'] as List?)
              ?.map((s) => AppointmentSlotDTO.fromJson(s))
              .toList() ??
          [],
      openingHours:
          (json['openingHours'] as List?)
              ?.map((h) => OpeningHoursDraft.fromJson(h))
              .toList() ??
          [],
      localImagePaths: List<String>.from(json['localImagePaths'] ?? []),
      documents:
          (json['documents'] as List?)
              ?.map((d) => DocumentDraft.fromJson(d))
              .toList() ??
          [],
      contacts:
          (json['contacts'] as List?)
              ?.map((c) => ContactDraft.fromJson(c))
              .toList() ??
          [],
      socialLinks:
          (json['socialLinks'] as List?)
              ?.map((s) => SocialLinkDraft.fromJson(s))
              .toList() ??
          [],
      awards:
          (json['awards'] as List?)
              ?.map((a) => AwardDTO.fromJson(a))
              .toList() ??
          [],
      subaccountId: json['subaccountId'] as String?,
      transferRecipientId: json['transferRecipientId'] as String?,
      autoAcceptBookings: json['autoAcceptBookings'] as bool? ?? false,
      maxBookingsPerDay: json['maxBookingsPerDay'] as int? ?? 10,
      bufferMinutesBetweenBookings:
          json['bufferMinutesBetweenBookings'] as int? ?? 15,
      lastUpdated:
          json['lastUpdated'] != null
              ? DateTime.parse(json['lastUpdated'])
              : null,
    );
  }

  @override
  List<Object?> get props => [
    freelancerId,
    userId,
    name,
    bio,
    profileImagePath,
    specialties,
    freelancerType,
    freelancerTypes,
    toolIds,
    baseLatitude,
    baseLongitude,
    travelRadiusKm,
    canTravel,
    serviceAddress,
    services.length,
    openingHours.length,
    localImagePaths.length,
    documents.length,
    contacts.length,
    socialLinks.length,
    awards.length,
    subaccountId,
    transferRecipientId,
    autoAcceptBookings,
    maxBookingsPerDay,
    bufferMinutesBetweenBookings,
    lastUpdated,
    terms,
  ];
}

/// Extension to help with null string handling
extension _NullIfEmpty on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
