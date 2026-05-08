// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      shopId: json['shopId'] as String,
      orderDate: DateTime.parse(json['orderDate'] as String),
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      deliveryAddress: json['deliveryAddress'] as String,
      customerPhone: json['customerPhone'] as String,
      customerNotes: json['customerNotes'] as String?,
      shopNotes: json['shopNotes'] as String?,
      deliveryNotes: json['deliveryNotes'] as String?,
      confirmedAt: json['confirmedAt'] == null
          ? null
          : DateTime.parse(json['confirmedAt'] as String),
      dispatchedAt: json['dispatchedAt'] == null
          ? null
          : DateTime.parse(json['dispatchedAt'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      customerName: json['customerName'] as String?,
      customerEmail: json['customerEmail'] as String?,
      customerAvatarUrl: json['customerAvatarUrl'] as String?,
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'shopId': instance.shopId,
      'orderDate': instance.orderDate.toIso8601String(),
      'status': _$OrderStatusEnumMap[instance.status]!,
      'totalAmount': instance.totalAmount,
      'deliveryAddress': instance.deliveryAddress,
      'customerPhone': instance.customerPhone,
      'customerNotes': instance.customerNotes,
      'shopNotes': instance.shopNotes,
      'deliveryNotes': instance.deliveryNotes,
      'confirmedAt': instance.confirmedAt?.toIso8601String(),
      'dispatchedAt': instance.dispatchedAt?.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'customerName': instance.customerName,
      'customerEmail': instance.customerEmail,
      'customerAvatarUrl': instance.customerAvatarUrl,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending_confirmation: 'pending_confirmation',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.out_for_delivery: 'out_for_delivery',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
  OrderStatus.disputed: 'disputed',
};

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productImage: json['productImage'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$OrderItemModelToJson(OrderItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'productId': instance.productId,
      'productName': instance.productName,
      'productImage': instance.productImage,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'subtotal': instance.subtotal,
      'createdAt': instance.createdAt.toIso8601String(),
    };
