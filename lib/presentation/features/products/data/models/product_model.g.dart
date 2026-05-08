// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      category: json['category'] as String,
      isActive: json['isActive'] as bool? ?? true,
      totalOrdersCount: (json['totalOrdersCount'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shopId': instance.shopId,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'images': instance.images,
      'category': instance.category,
      'isActive': instance.isActive,
      'totalOrdersCount': instance.totalOrdersCount,
      'averageRating': instance.averageRating,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
