// lib/features/shop/presentation/providers/shop_details_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/shop_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_details_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/repositories/shop_repository.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_repository_provider.dart';

class ShopDetailsNotifier extends StateNotifier<AsyncValue<ShopDetailsDTO?>> {
  final ShopRepository _repository;

  ShopDetailsNotifier({required ShopRepository repository})
    : _repository = repository,
      super(const AsyncValue.data(null));

  Future<void> loadShop(String shopId) async {
    state = const AsyncValue.loading();
    try {
      final shop = await _repository.getShopDetailsById(shopId);
      state = AsyncValue.data(shop);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final shopDetailsProvider = StateNotifierProvider.family<
  ShopDetailsNotifier,
  AsyncValue<ShopDetailsDTO?>,
  String
>((ref, shopId) {
  final repository = ref.watch(shopRepositoryProvider);
  final notifier = ShopDetailsNotifier(repository: repository);
  notifier.loadShop(shopId);
  return notifier;
});

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
      socialLinks:
          socialLinks
              .map(
                (link) => SocialLinkDraft(
                  platform: SocialPlatform.fromString(
                    link.platform.displayName,
                  ), // Convert string to enum
                  url: link.url,
                ),
              )
              .toList(),
      services: [], // Will be populated from appointment slots
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
      profileId: null, // Will be set by provider
    );
  }
}
