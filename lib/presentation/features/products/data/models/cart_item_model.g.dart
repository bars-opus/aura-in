// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) =>
    CartItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      shopId: json['shopId'] as String,
      shopName: json['shopName'] as String,
    );

Map<String, dynamic> _$CartItemModelToJson(CartItemModel instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'quantity': instance.quantity,
      'shopId': instance.shopId,
      'shopName': instance.shopName,
    };
