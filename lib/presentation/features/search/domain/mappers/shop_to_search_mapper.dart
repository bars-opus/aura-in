// lib/features/search/domain/mappers/shop_to_search_mapper.dart

import 'package:nano_embryo/presentation/features/search/models/shop_search_result.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_list_item_dto.dart';

/// Mapper to convert ShopListItemDTO to ShopSearchResult
class ShopToSearchResultMapper {
  static ShopSearchResult toSearchResult(ShopListItemDTO shop) {
    return ShopSearchResult(
      id: shop.id,
      title: shop.shopName,
      subtitle: _buildSubtitle(shop),
      imageUrl: shop.coverImageUrl,
      averageRating: shop.averageRating,
      reviewCount: shop.numberClientsWorked,
      verified: shop.verified,
      luxuryLevel: shop.luxuryLevel,
      distanceKm: shop.distanceKm,
      topServices: null,
      isOpenNow: false,
    );
  }

  static List<ShopSearchResult> toSearchResults(List<ShopListItemDTO> shops) {
    return shops.map(toSearchResult).toList();
  }

  static String _buildSubtitle(ShopListItemDTO shop) {
    final parts = <String>[];

    if (shop.averageRating != null) {
      parts.add('${shop.averageRating!.toStringAsFixed(1)}★');
    }
    if (shop.numberClientsWorked != null) {
      parts.add('(${shop.numberClientsWorked} reviews)');
    }
    if (shop.luxuryLevel != null && shop.luxuryLevel!.isNotEmpty) {
      parts.add(shop.luxuryLevel!);
    }
    if (shop.distanceKm != null) {
      parts.add('${shop.distanceKm!.toStringAsFixed(1)}km');
    }

    return parts.isEmpty ? 'Beauty & Grooming' : parts.join(' • ');
  }
}
