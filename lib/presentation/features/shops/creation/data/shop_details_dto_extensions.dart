// lib/features/shop/data/models/shop_details_dto_extensions.dart

import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/shop_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_details_dto.dart';

/// Convert ShopDetailsDTO to ShopDraft for editing
extension ShopDetailsToDraft on ShopDetailsDTO {
  ShopDraft toDraft() {
    return ShopDraft(
      shopName: shopName,
      shopType: shopType,
      luxuryLevel: luxuryLevel,
      overview: overview,
      terms: terms,
      address: address,
      city: city,
      country: country,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
      email: email,
      website: website,
      socialLinks: List<SocialLinkDraft>.from(socialLinks),
      services: [], // Will need to be populated from appointment slots
      openingHours:
          openingHours
              .map(
                (hour) => OpeningHoursDraft(
                  dayOfWeek: hour.dayOfWeek,
                  opensAt: hour.opensAt,
                  closesAt: hour.closesAt,
                  isClosed: hour.isClosed,
                ),
              )
              .toList(),
      localImagePaths: [], // Remote images aren't local files
      lastUpdated: DateTime.now(),
      profileId: null,
    );
  }
}
