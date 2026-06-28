import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/currency.dart';

class ProductModel extends Equatable {
  final String id;
  final String shopId;
  final String name;
  final String? description;
  final double price;
  final List<String> images;
  final String category;
  final bool isActive;
  final int stockQuantity;
  final int totalOrdersCount;
  final double averageRating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined fields from `shops!inner(...)` selects.
  final String? shopName;
  final bool? shopVerified;
  final List<String> shopTypes;
  final String? shopCurrencySymbol;
  final String? shopCurrencyCode;
  final double? distanceKm;

  const ProductModel({
    required this.id,
    required this.shopId,
    required this.name,
    this.description,
    required this.price,
    required this.images,
    required this.category,
    this.isActive = true,
    this.stockQuantity = 0,
    this.totalOrdersCount = 0,
    this.averageRating = 0,
    this.reviewCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.shopName,
    this.shopVerified,
    this.shopTypes = const [],
    this.shopCurrencySymbol,
    this.shopCurrencyCode,
    this.distanceKm,
  });

  /// Price formatted in the owning shop's currency (falls back to the default
  /// marketplace symbol when the shop currency is unknown).
  String get formattedPrice => Currency.formatWithCurrency(
    price,
    currencySymbol: shopCurrencySymbol,
    currencyCode: shopCurrencyCode,
  );

  /// Parses a row in the snake_case shape returned by Supabase.
  /// If the row was selected with a `shops!inner(...)` join the
  /// nested map is unwrapped into shopName / shopVerified.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final shop = json['shops'] as Map<String, dynamic>?;
    return ProductModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      images:
          (json['images'] as List?)?.map((e) => e as String).toList() ??
          const [],
      category: json['category'] as String,
      isActive: json['is_active'] as bool? ?? true,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      totalOrdersCount: (json['total_orders_count'] as num?)?.toInt() ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      shopName: shop?['shop_name'] as String?,
      shopVerified: shop?['verified'] as bool?,
      shopTypes:
          (json['shop_types'] as List?)?.map((e) => e as String).toList() ??
          const [],
      shopCurrencySymbol: shop?['currency_symbol'] as String?,
      shopCurrencyCode: shop?['currency'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'shop_id': shopId,
    'name': name,
    'description': description,
    'price': price,
    'images': images,
    'category': category,
    'is_active': isActive,
    'stock_quantity': stockQuantity,
    'total_orders_count': totalOrdersCount,
    'average_rating': averageRating,
    'review_count': reviewCount,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'shop_types': shopTypes,
  };

  bool get isInStock => stockQuantity > 0;

  @override
  List<Object?> get props => [
    id,
    shopId,
    name,
    description,
    price,
    images,
    category,
    isActive,
    stockQuantity,
    totalOrdersCount,
    averageRating,
    reviewCount,
    createdAt,
    updatedAt,
    shopName,
    shopVerified,
    shopTypes,
    shopCurrencySymbol,
    shopCurrencyCode,
    distanceKm,
  ];
}

enum ProductCategory {
  hair('Hair'),
  skin('Skin'),
  tools('Tools'),
  accessories('Accessories');

  final String displayName;
  const ProductCategory(this.displayName);

  static ProductCategory fromString(String value) {
    return values.firstWhere((e) => e.name == value, orElse: () => hair);
  }
}
