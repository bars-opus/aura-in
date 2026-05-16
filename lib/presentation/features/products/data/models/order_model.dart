import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending_confirmation,
    );
  }
}

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

  // Joined data
  final String? shopName;
  final bool? shopVerified;
  final String? shopLogo;
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
    this.shopName,
    this.shopVerified,
    this.shopLogo,
    this.customerName,
    this.customerEmail,
    this.customerAvatarUrl,
  });

  /// Parses a snake_case row from Supabase. Joined `shops` / `profiles`
  /// data is unwrapped from either nested map shape or pre-flattened
  /// keys (the repository sometimes pre-flattens for convenience).
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final shop = json['shops'] as Map<String, dynamic>?;
    final profile = json['profiles'] as Map<String, dynamic>?;
    DateTime? dt(String key) {
      final v = json[key];
      return v == null ? null : DateTime.parse(v as String);
    }

    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      shopId: json['shop_id'] as String,
      orderDate: DateTime.parse(
        (json['order_date'] ?? json['created_at']) as String,
      ),
      status: OrderStatusExtension.fromString(json['status'] as String),
      totalAmount: (json['total_amount'] as num).toDouble(),
      deliveryAddress: json['delivery_address'] as String? ?? '',
      customerPhone: json['customer_phone'] as String? ?? '',
      customerNotes: json['customer_notes'] as String?,
      shopNotes: json['shop_notes'] as String?,
      deliveryNotes: json['delivery_notes'] as String?,
      confirmedAt: dt('confirmed_at'),
      dispatchedAt: dt('dispatched_at'),
      deliveredAt: dt('delivered_at'),
      cancelledAt: dt('cancelled_at'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      shopName: shop?['shop_name'] as String? ?? json['shop_name'] as String?,
      shopVerified:
          shop?['verified'] as bool? ?? json['shop_verified'] as bool?,
      shopLogo: shop?['shop_logo_url'] as String? ??
          json['shop_logo'] as String?,
      customerName:
          profile?['full_name'] as String? ?? json['customer_name'] as String?,
      customerEmail:
          profile?['email'] as String? ?? json['customer_email'] as String?,
      customerAvatarUrl: profile?['avatar_url'] as String? ??
          json['customer_avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'shop_id': shopId,
        'order_date': orderDate.toIso8601String(),
        'status': status.name,
        'total_amount': totalAmount,
        'delivery_address': deliveryAddress,
        'customer_phone': customerPhone,
        'customer_notes': customerNotes,
        'shop_notes': shopNotes,
        'delivery_notes': deliveryNotes,
        'confirmed_at': confirmedAt?.toIso8601String(),
        'dispatched_at': dispatchedAt?.toIso8601String(),
        'delivered_at': deliveredAt?.toIso8601String(),
        'cancelled_at': cancelledAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

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

  /// Parses a snake_case order_items row. The repository merges joined
  /// `products` data into `product_name` / `product_image` keys before
  /// calling this — handle either shape.
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['products'] as Map<String, dynamic>?;
    final unitPrice = (json['unit_price'] as num?)?.toDouble() ?? 0;
    final qty = (json['quantity'] as num).toInt();
    return OrderItemModel(
      id: json['id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      productId: json['product_id'] as String,
      productName: (json['product_name'] as String?) ??
          (product?['name'] as String?) ??
          '',
      productImage: (json['product_image'] as String?) ??
          (product?['images'] is List
              ? (product!['images'] as List).cast<String>().firstOrNull
              : null),
      quantity: qty,
      unitPrice: unitPrice,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? (unitPrice * qty),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'product_id': productId,
        'product_name': productName,
        'product_image': productImage,
        'quantity': quantity,
        'unit_price': unitPrice,
        'subtotal': subtotal,
        'created_at': createdAt.toIso8601String(),
      };

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
