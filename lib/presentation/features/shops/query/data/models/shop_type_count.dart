// lib/features/shops/data/models/shop_type_count.dart

class ShopTypeCount {
  final String shopType;
  final int count;

  ShopTypeCount({required this.shopType, required this.count});

  factory ShopTypeCount.fromJson(Map<String, dynamic> json) {
    return ShopTypeCount(
      shopType: json['shop_type'] as String,
      count: (json['count'] as num).toInt(),
    );
  }
}
