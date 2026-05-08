// lib/features/products/data/models/product_review_model.dart

import 'package:equatable/equatable.dart';

class ProductReview extends Equatable {
  final String id;
  final String orderId;
  final String productId;
  final String userId;
  final int rating;
  final String? review;
  final String? shopResponse;
  final DateTime? respondedAt;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined data
  final String? userName;
  final String? userAvatar;
  final String? productName;
  final String? productImage;

  const ProductReview({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.userId,
    required this.rating,
    this.review,
    this.shopResponse,
    this.respondedAt,
    this.isEdited = false,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userAvatar,
    this.productName,
    this.productImage,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      userId: json['user_id'] as String,
      rating: json['rating'] as int,
      review: json['comment'] as String?,
      shopResponse: json['shop_response'] as String?,
      respondedAt:
          json['shop_response_at'] != null
              ? DateTime.parse(json['shop_response_at'] as String)
              : null,
      isEdited: false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userName:
          json['profiles'] != null
              ? json['profiles']['full_name'] as String?
              : null,
      userAvatar:
          json['profiles'] != null
              ? json['profiles']['avatar_url'] as String?
              : null,
      productName:
          json['products'] != null ? json['products']['name'] as String? : null,
      productImage:
          json['products'] != null && json['products']['images'] is List
              ? (json['products']['images'] as List).isNotEmpty
                  ? (json['products']['images'] as List)[0] as String?
                  : null
              : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    productId,
    userId,
    rating,
    review,
    shopResponse,
    respondedAt,
    isEdited,
    createdAt,
    updatedAt,
  ];
}
