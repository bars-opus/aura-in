import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class ShopListItemDTO extends Equatable {
  final String id;
  final String shopName;
  final String? coverImageUrl;
  final double? averageRating;
  final int? numberClientsWorked;
  final String? luxuryLevel;
  final double? distanceKm;
  final bool verified;
  final String? shopType;
  final bool isOpen;
  final String? openStatus;
  final String? overview;

  const ShopListItemDTO({
    required this.id,
    required this.shopName,
    this.coverImageUrl,
    this.averageRating,
    this.numberClientsWorked,
    this.luxuryLevel,
    this.distanceKm,
    required this.verified,
    this.shopType,
    required this.isOpen,
    this.openStatus,
    this.overview,
  });

  factory ShopListItemDTO.fromJson(Map<String, dynamic> json) {
    // ✅ Extract cover image from shop_media relationship
    return ShopListItemDTO(
      id: json['id'] as String,
      shopName: json['shop_name'] as String,
      coverImageUrl:
          json['shop_logo_url'] as String? ??
          json['cover_image_url'] as String?,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      numberClientsWorked: json['number_clients_worked'] as int?,
      luxuryLevel: json['luxury_level'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      verified: json['verified'] as bool? ?? false,
      shopType: json['shop_type'] as String?,
      isOpen: json['is_open'] as bool? ?? false,
      openStatus: json['open_status'] as String?,
      overview: json['overview'] as String?,
    );
  }

  factory ShopListItemDTO.fromDomain(Shop shop) {
    return ShopListItemDTO(
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
      averageRating: shop.averageRating,
      numberClientsWorked: shop.numberClientsWorked,
      luxuryLevel: shop.luxuryLevel,
      distanceKm: null,
      verified: shop.verified,
      shopType: shop.shopType,
      isOpen: false,
      openStatus: null,
      overview: shop.overview,
    );
  }

  @override
  List<Object?> get props => [
    id,
    shopName,
    coverImageUrl,
    averageRating,
    numberClientsWorked,
    luxuryLevel,
    distanceKm,
    verified,
    shopType,
    isOpen,
    openStatus,
    overview,
  ];
}
