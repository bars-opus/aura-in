import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class ActiveShopInfo extends Equatable {
  final String id;
  final String shopName;
  final String? coverImageUrl; // First professional image or logo
  final String? shopType; // Computed from opening hours
  final bool verified;

  const ActiveShopInfo({
    required this.id,
    required this.shopName,
    this.coverImageUrl,
    required this.verified,
    required this.shopType,
  });

  factory ActiveShopInfo.fromJson(Map<String, dynamic> json) {
    return ActiveShopInfo(
      id: json['id'] as String,
      shopName: json['shop_name'] as String,
      coverImageUrl: json['cover_image_url'] as String?,
      verified: json['verified'] as bool? ?? false,
      shopType: json['shop_type'] as String?,
    );
  }

  // Convert from domain entity (if needed)
  factory ActiveShopInfo.fromDomain(Shop shop) {
    return ActiveShopInfo(
      id: shop.id,
      shopName: shop.shopName,
      coverImageUrl:
          shop.media
              ?.firstWhere(
                (m) => m?.mediaType == 'professional',
                orElse:
                    () => SimpleMedia(
                      mediaType: 'logo',
                      url: shop.shopLogoUrl ?? '',
                      id: '',
                    ),
              )
              .url,

      verified: shop.verified,
      shopType: shop.shopType,
    );
  }

  @override
  List<Object?> get props => [id, shopName, coverImageUrl, verified, shopType];
}
