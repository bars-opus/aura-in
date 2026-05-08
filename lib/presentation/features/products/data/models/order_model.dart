// lib/features/orders/data/models/order_model.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

enum OrderStatus {
  pending_confirmation,
  confirmed,
  out_for_delivery,
  delivered,
  cancelled,
  disputed,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending_confirmation:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.out_for_delivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.disputed:
        return 'Disputed';
    }
  }

  Color getColor(ColorScheme colorScheme) {
    switch (this) {
      case OrderStatus.pending_confirmation:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.out_for_delivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.disputed:
        return Colors.red.shade700;
    }
  }
}

@JsonSerializable()
class OrderModel extends Equatable {
  final String id;
  final String userId;
  final String shopId;
  final DateTime orderDate;
  final OrderStatus status;
  final double totalAmount;
  final String deliveryAddress;
  final String customerPhone;
  final String? customerNotes;
  final String? shopNotes;
  final String? deliveryNotes;
  final DateTime? confirmedAt;
  final DateTime? dispatchedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? shopName;
  final bool? shopVerified;
  final String? shopLogo;

  // Customer info (joined from profiles/users table)
  final String? customerName;
  final String? customerEmail;
  final String? customerAvatarUrl;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.customerPhone,
    this.customerNotes,
    this.shopNotes,
    this.deliveryNotes,
    this.confirmedAt,
    this.dispatchedAt,
    this.deliveredAt,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
    this.customerName,
    this.customerEmail,
    this.customerAvatarUrl,
    this.shopName,
    this.shopVerified,
    this.shopLogo,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  @override
  List<Object?> get props => [
    id,
    userId,
    shopId,
    orderDate,
    status,
    totalAmount,
    deliveryAddress,
    customerPhone,
    customerNotes,
    shopNotes,
    deliveryNotes,
    confirmedAt,
    dispatchedAt,
    deliveredAt,
    cancelledAt,
    createdAt,
    updatedAt,
  ];
}

@JsonSerializable()
class OrderItemModel extends Equatable {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final DateTime createdAt;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.createdAt,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  @override
  List<Object?> get props => [
    id,
    orderId,
    productId,
    productName,
    productImage,
    quantity,
    unitPrice,
    subtotal,
    createdAt,
  ];
}
