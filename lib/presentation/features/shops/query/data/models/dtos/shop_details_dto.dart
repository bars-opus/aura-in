// lib/features/shops/data/dtos/shop_details_dto.dart

import 'dart:io';

import 'package:nano_embryo/presentation/features/shops/creation/domain/models/shop_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/award_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class ShopDetailsDTO extends Equatable {
  // Core info
  final String id;
  final String shopName;
  final String? shopLogoUrl;
  final bool verified;
  final String? shopType;
  final String? luxuryLevel;
  final double? averageRating;
  final int? numberClientsWorked;
  final int? totalReviews;
  final String userId;

  // Detailed info
  final String? overview;
  final String? terms;
  final String? address;
  final String? city;
  final String? country;
  final String? currency;

  // Contact & social
  final String? phone;
  final String? email;
  final String? website;
  final List<SocialLinkDraft> socialLinks;

  // Media
  final List<String> professionalImages;
  final List<String> documentImages;
  // Full media objects (id + url) needed for reliable deletion by primary key
  final List<SimpleMedia> professionalImageMedias;
  final List<SimpleMedia> documentMedias;

  // Staff & services
  final List<WorkerDTO> workers;

  // Awards
  final List<AwardDTO> awards;

  // Operating hours
  final List<OpeningHoursDTO> openingHours;

  // Location
  final double? latitude;
  final double? longitude;

  // Distance (if user location available)
  final double? distanceKm;

  final List<AppointmentSlotDTO> services;
  final List<String> amenityIds;

  const ShopDetailsDTO({
    required this.id,
    required this.userId,
    required this.shopName,
    this.shopLogoUrl,
    required this.verified,
    this.shopType,
    this.luxuryLevel,
    this.averageRating,
    this.numberClientsWorked,
    this.overview,
    this.terms,
    this.address,
    this.city,
    this.country,
    this.currency,
    this.phone,
    this.email,
    this.website,
    this.socialLinks = const [],
    this.professionalImages = const [],
    this.documentImages = const [],
    this.professionalImageMedias = const [],
    this.documentMedias = const [],
    this.workers = const [],
    this.awards = const [],
    this.openingHours = const [],
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.services = const [],
    this.amenityIds = const [],
    this.totalReviews,
  });

  factory ShopDetailsDTO.fromJson(Map<String, dynamic> json) {
    // Parse appointment slots (services)
    final services =
        (json['appointment_slots'] as List?)
            ?.map((e) => AppointmentSlotDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Parse social links
    final socialLinks =
        (json['shop_social_links'] as List?)
            ?.map((e) => SocialLinkDraft.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Parse awards
    final awards =
        (json['shop_awards'] as List?)
            ?.map((e) => AwardDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Parse opening hours
    final openingHours =
        (json['shop_opening_hours'] as List?)
            ?.map((e) => OpeningHoursDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Parse shop_media
    List<SimpleMedia> mediaList = [];
    if (json['shop_media'] != null) {
      mediaList =
          (json['shop_media'] as List)
              .map((m) => SimpleMedia.fromJson(m))
              .toList();
    }

    final professionalImages =
        mediaList
            .where((m) => m.mediaType == 'professional')
            .map((m) => m.url)
            .toList();

    final documentImages =
        mediaList
            .where((m) => m.mediaType == 'document') // ← Check this line
            .map((m) => m.url)
            .toList();

    // Amenities (if stored as array in shops table)
    final amenityIds = (json['amenities'] as List?)?.cast<String>() ?? [];

    // Parse workers - now directly from 'workers' key
    final workers =
        (json['workers'] as List?)
            ?.map((w) => WorkerDTO.fromJson(w as Map<String, dynamic>))
            .toList() ??
        [];

    // Parse contacts to get phone, email, website

    String? phone;
    String? email;
    String? website;
    final contactsList = json['shop_contacts'] as List?;

    print('📞 CONTACT DEBUG:');
    print('   contactsList is null? ${contactsList == null}');
    print('   contactsList length: ${contactsList?.length ?? 0}');

    if (contactsList != null) {
      for (var contact in contactsList) {
        print('   Raw contact: $contact');
        final type = contact['contact_type'] as String?;
        final value = contact['value'] as String?;
        print('   Contact - type: $type, value: $value');

        if (type == 'phone') {
          phone = value;
        } else if (type == 'email') {
          email = value;
        } else if (type == 'website') {
          website = value;
        }
      }
    }

    print('📞 Extracted - phone: $phone, email: $email, website: $website');

    return ShopDetailsDTO(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      shopName: json['shop_name'] as String,
      shopLogoUrl: json['shop_logo_url'] as String?,
      verified: json['verified'] as bool? ?? false,
      shopType: json['shop_type'] as String?,
      luxuryLevel: json['luxury_level'] as String?,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      totalReviews: json['total_reviews'] as int?,

      numberClientsWorked: json['number_clients_worked'] as int?,
      overview: json['overview'] as String?,
      terms: json['terms'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      // The shops table stores this as 'currency_code'; fall back to either key.
      currency: (json['currency'] ?? json['currency_code']) as String?,
      phone: phone,
      email: email,
      website: website,
      socialLinks: socialLinks,
      professionalImages: professionalImages,
      documentImages: documentImages,
      professionalImageMedias:
          mediaList.where((m) => m.mediaType == 'professional').toList(),
      documentMedias:
          mediaList.where((m) => m.mediaType == 'document').toList(),
      workers: workers, // Not fetched in this query
      awards: awards,
      openingHours: openingHours,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      services: services, // ✅ Now populated
      amenityIds: amenityIds, // ✅ Now populated
    );
  }

  /// Creates a preview ShopDetailsDTO from a ShopDraft
  // Add this method to ShopDetailsDTO class

  /// Creates a preview ShopDetailsDTO from a ShopDraft
  factory ShopDetailsDTO.fromDraft(ShopDraft draft) {
    // Convert opening hours
    final openingHours =
        draft.openingHours
            .map(
              (hour) => OpeningHoursDTO(
                dayOfWeek: hour.dayOfWeek,
                opensAt: hour.opensAt,
                closesAt: hour.closesAt,
                isClosed: hour.isClosed,
                id: '',
              ),
            )
            .toList();

    // Convert social links
    final socialLinks =
        draft.socialLinks
            .map(
              (link) => SocialLinkDraft(platform: link.platform, url: link.url),
            )
            .toList();

    // Convert awards
    final awards =
        draft.awards
            .map(
              (award) => AwardDTO(
                name: award.name,
                link: award.link,
                description: award.description,
                issuer: award.issuer,
                dateReceived: award.dateReceived,
                id: '',
              ),
            )
            .toList();

    // Get professional images from localImagePaths (file paths)
    final professionalImages = List<String>.from(draft.localImagePaths);

    // FIX: Convert document files to paths (strings)
    final documentImages = draft.documents.map((doc) => doc.file.path).toList();

    // Determine currency
    final currencyCode = draft.currency?.code ?? draft.currencyCode ?? 'GHS';
    final currencySymbol =
        draft.currency?.symbol ?? draft.currencySymbol ?? '₵';

    // Convert workers (empty for preview)
    final workers = <WorkerDTO>[];

    return ShopDetailsDTO(
      id: draft.shopId ?? 'preview_${DateTime.now().millisecondsSinceEpoch}',
      userId: draft.userId ?? '',
      shopName: draft.shopName ?? 'Preview Shop',
      shopLogoUrl: draft.localLogoPath,
      verified: false,
      shopType: draft.shopType,
      luxuryLevel: draft.luxuryLevel,
      averageRating: null,
      totalReviews: null,
      numberClientsWorked: null,
      overview: draft.overview,
      terms: draft.terms,
      address: draft.address,
      city: draft.city,
      country: draft.country,
      currency: currencyCode,
      phone: draft.phone,
      email: draft.email,
      website: draft.website,
      socialLinks: socialLinks,
      professionalImages: professionalImages,
      documentImages: documentImages, // Now properly converted to List<String>
      workers: workers,
      awards: awards,
      openingHours: openingHours,
      latitude: draft.latitude,
      longitude: draft.longitude,
      distanceKm: null,
      services: draft.services,
      amenityIds: draft.amenityIds,
    );
  }
  @override
  List<Object?> get props => [id, shopName];
}
