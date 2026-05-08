// lib/features/shop/creation/domain/entities/shop_draft.dart

import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/currency/domain/entities/currency.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/award_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/award_dto.dart';

/// Represents a draft of a shop being created.
/// All fields are optional; they become non-null only when the user completes that section.
class ShopDraft extends Equatable {
  final String? shopId;
  final String? userId;

  // Section 1: Basics
  final String? shopName;
  final String? shopType;
  final String? luxuryLevel;
  final String? overview;
  final String? terms;

  // Section 2: Location
  final String? address;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;

  // Section 3: Contact
  final String? phone;
  final String? email;
  final String? website;
  final List<SocialLinkDraft> socialLinks;

  // Section 4: Services
  final List<AppointmentSlotDTO> services;

  // Section 5: Opening Hours
  final List<OpeningHoursDraft> openingHours;

  // Section 6: Media
  final List<String> localImagePaths; // paths to local files (not yet uploaded)
  final String? localLogoPath; // local file path or existing http URL for logo

  // Metadata
  final DateTime? lastUpdated;
  final String? profileId; // owner's profile ID

  // New currency fields
  final String? currencyCode;
  final String? currencySymbol;
  final List<String> amenityIds;

  // final List<String> documentPaths;

  final List<DocumentDraft> documents;
  final List<AwardDTO> awards;
  final List<ContactDraft> contacts;

  const ShopDraft({
    this.shopName,
    this.shopId,
    this.userId,
    this.shopType,
    this.luxuryLevel,
    this.overview,
    this.terms,
    this.address,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.website,
    this.socialLinks = const [],
    this.services = const [],
    this.openingHours = const [],
    this.localImagePaths = const [],
    this.localLogoPath,
    this.lastUpdated,
    this.profileId,
    this.currencyCode,
    this.currencySymbol,
    this.amenityIds = const [],
    this.documents = const [],
    this.awards = const [],
    this.contacts = const [],
  });

  /// Creates a copy with updated fields.
  ShopDraft copyWith({
    String? shopId,
    String? userId,
    String? shopName,
    String? shopType,
    String? luxuryLevel,
    String? overview,
    String? terms,
    String? address,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    String? currencyCode,
    String? currencySymbol,
    List<SocialLinkDraft>? socialLinks,
    List<AppointmentSlotDTO>? services,
    List<OpeningHoursDraft>? openingHours,
    List<String>? localImagePaths,
    String? localLogoPath,
    DateTime? lastUpdated,
    String? profileId,
    List<String>? amenityIds,
    List<DocumentDraft>? documents,
    List<AwardDTO>? awards,
    List<ContactDraft>? contacts,
  }) {
    return ShopDraft(
      shopId: shopId ?? this.shopId,
      userId: userId ?? this.userId,
      shopName: shopName ?? this.shopName,
      shopType: shopType ?? this.shopType,
      luxuryLevel: luxuryLevel ?? this.luxuryLevel,
      overview: overview ?? this.overview,
      terms: terms ?? this.terms,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      socialLinks: socialLinks ?? this.socialLinks,
      services: services ?? this.services,
      openingHours: openingHours ?? this.openingHours,
      localImagePaths: localImagePaths ?? this.localImagePaths,
      localLogoPath: localLogoPath ?? this.localLogoPath,
      lastUpdated: lastUpdated ?? DateTime.now(),
      profileId: profileId ?? this.profileId,
      currencyCode: currencyCode ?? this.currencyCode,
      amenityIds: amenityIds ?? this.amenityIds,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      documents: documents ?? this.documents,
      awards: awards ?? this.awards,
      contacts: contacts ?? this.contacts,
    );
  }

  /// Converts to JSON for local storage.
  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'userId': userId,
      'shopName': shopName,
      'shopType': shopType,
      'luxuryLevel': luxuryLevel,
      'overview': overview,
      'terms': terms,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'website': website,
      'socialLinks': socialLinks.map((e) => e.toJson()).toList(),
      'services': services.map((e) => e.toJson()).toList(),
      'openingHours': openingHours.map((e) => e.toJson()).toList(),
      'localImagePaths': localImagePaths,
      'localLogoPath': localLogoPath,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'profileId': profileId,
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
      'amenityIds': amenityIds,
      'documents': documents.map((d) => d.toJson()).toList(),
      'awards': awards.map((a) => a.toJson()).toList(),
      'contacts': contacts.map((c) => c.toJson()).toList(),
    };
  }

  /// Creates from JSON.
  factory ShopDraft.fromJson(Map<String, dynamic> json) {
    // Convert dynamic map to String keys safely
    final safeJson = <String, dynamic>{};
    json.forEach((key, value) {
      safeJson[key.toString()] = value;
    });

    return ShopDraft(
      shopId: safeJson['shopId'] as String?,
      userId: safeJson['userId'] as String?,
      shopName: safeJson['shopName'] as String?,
      shopType: safeJson['shopType'] as String?,
      luxuryLevel: safeJson['luxuryLevel'] as String?,
      overview: safeJson['overview'] as String?,
      terms: safeJson['terms'] as String?,
      address: safeJson['address'] as String?,
      city: safeJson['city'] as String?,
      country: safeJson['country'] as String?,
      latitude: (safeJson['latitude'] as num?)?.toDouble(),
      longitude: (safeJson['longitude'] as num?)?.toDouble(),
      phone: safeJson['phone'] as String?,
      email: safeJson['email'] as String?,
      website: safeJson['website'] as String?,
      socialLinks:
          (safeJson['socialLinks'] as List?)
              ?.map(
                (e) => SocialLinkDraft.fromJson(
                  e is Map
                      ? Map<String, dynamic>.from(e)
                      : e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
      services:
          (safeJson['services'] as List?)
              ?.map(
                (e) => AppointmentSlotDTO.fromJson(
                  e is Map
                      ? Map<String, dynamic>.from(e)
                      : e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
      openingHours:
          (safeJson['openingHours'] as List?)
              ?.map(
                (e) => OpeningHoursDraft.fromJson(
                  e is Map
                      ? Map<String, dynamic>.from(e)
                      : e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
      localImagePaths:
          (safeJson['localImagePaths'] as List?)?.cast<String>() ?? const [],
      localLogoPath: safeJson['localLogoPath'] as String?,
      amenityIds: (safeJson['amenityIds'] as List?)?.cast<String>() ?? const [],
      documents:
          (safeJson['documents'] as List?)
              ?.map(
                (e) => DocumentDraft.fromJson(
                  e is Map
                      ? Map<String, dynamic>.from(e)
                      : e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
      awards:
          (safeJson['awards'] as List?)
              ?.map(
                (e) => AwardDTO.fromJson(
                  e is Map
                      ? Map<String, dynamic>.from(e)
                      : e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
      contacts:
          (safeJson['contacts'] as List?)
              ?.map(
                (e) => ContactDraft.fromJson(
                  e is Map
                      ? Map<String, dynamic>.from(e)
                      : e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
      lastUpdated:
          safeJson['lastUpdated'] != null
              ? DateTime.parse(safeJson['lastUpdated'] as String)
              : null,
      profileId: safeJson['profileId'] as String?,
      currencyCode: safeJson['currencyCode'] as String?,
      currencySymbol: safeJson['currencySymbol'] as String?,
    );
  }

  /// Section completion statuses.
  bool get isBasicsComplete =>
      shopName != null &&
      shopName!.isNotEmpty &&
      shopType != null &&
      localLogoPath != null;
  bool get isLocationComplete =>
      address != null; // lat/lng can be derived later
  bool get isContactComplete => phone != null || email != null;
  bool get isServicesComplete => services.isNotEmpty;
  bool get isAmenitiesComplete => amenityIds.isNotEmpty;

  bool get isDocumentsComplete => documents.isNotEmpty;
  bool get isHoursComplete => openingHours.any((hour) => !hour.isClosed);

  bool get isMediaComplete => localImagePaths.length >= 3; // min 3 images
  static const int maxImages = 5; // max 5 images
  Currency? get currency {
    if (currencyCode == null) return null;

    return Currencies.fromCode(currencyCode) ??
        Currency(
          code: currencyCode!,
          symbol: currencySymbol ?? _symbolFromCode(currencyCode!),
          name: currencyCode!,
          flag: _flagFromCode(currencyCode!),
        );
  }

  // Helper method to get flag from currency code
  String _flagFromCode(String code) {
    const flags = {
      'USD': '🇺🇸',
      'EUR': '🇪🇺',
      'GBP': '🇬🇧',
      'JPY': '🇯🇵',
      'CAD': '🇨🇦',
      'AUD': '🇦🇺',
      'CHF': '🇨🇭',
      'CNY': '🇨🇳',
      'INR': '🇮🇳',
      'BRL': '🇧🇷',
      'MXN': '🇲🇽',
      'SGD': '🇸🇬',
      'NZD': '🇳🇿',
      'HKD': '🇭🇰',
      'KRW': '🇰🇷',
      'SEK': '🇸🇪',
      'NOK': '🇳🇴',
      'DKK': '🇩🇰',
      'PLN': '🇵🇱',
      'TRY': '🇹🇷',
      'AED': '🇦🇪',
      'ZAR': '🇿🇦',
      'ILS': '🇮🇱',
      'THB': '🇹🇭',
    };
    return flags[code] ?? '🏳️'; // Default white flag if unknown
  }

  String _symbolFromCode(String code) {
    const symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'CAD': 'C\$',
      'AUD': 'A\$',
      'CHF': 'Fr',
      'CNY': '¥',
      'INR': '₹',
      'KRW': '₩',
      'BRL': 'R\$',
      'MXN': '\$',
    };
    return symbols[code] ?? '\$';
  }

  /// Minimum viable shop check.
  bool get isMinimumViable =>
      isBasicsComplete &&
      isLocationComplete &&
      isServicesComplete &&
      isAmenitiesComplete &&
      isDocumentsComplete &&
      isHoursComplete &&
      isMediaComplete;

  /// Number of completed sections.
  int get completedSectionsCount =>
      [
        isBasicsComplete,
        isLocationComplete,
        isContactComplete,
        isServicesComplete,
        isHoursComplete,
        isAmenitiesComplete,
        isDocumentsComplete,
        isMediaComplete,
      ].where((completed) => completed).length;

  /// Total sections count.
  static const int totalSections = 8;

  @override
  List<Object?> get props => [
    shopName,
    shopType,
    luxuryLevel,
    address,
    city,
    phone,
    email,
    services.length,
    openingHours.length,
    localImagePaths.length,
    localLogoPath,
    lastUpdated,
    profileId,
    currencyCode,
    currencySymbol,
    documents,
    awards,
    contacts,
  ];
}
