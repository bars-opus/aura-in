import 'package:equatable/equatable.dart';

class BookingReview extends Equatable {
  final String id;
  final String bookingId;
  final String userId;
  final String shopId;
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
  final String? shopName;
  final String? shopLogo;

  const BookingReview({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.shopId,
    required this.rating,
    this.review,
    this.shopResponse,
    this.respondedAt,
    this.isEdited = false,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userAvatar,
    this.shopName,
    this.shopLogo,
  });

  factory BookingReview.fromJson(Map<String, dynamic> json) {
    return BookingReview(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      userId: json['user_id'] as String,
      shopId: json['shop_id'] as String,
      rating: json['rating'] as int,
      review: json['review'] as String?,
      shopResponse: json['shop_response'] as String?,
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
      isEdited: json['is_edited'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userName: json['user'] != null
          ? (json['user']['display_name'] as String?) ??
              (json['user']['username'] as String?)
          : null,
      userAvatar: json['user'] != null
          ? json['user']['avatar_url'] as String?
          : null,
      shopName: json['shop'] != null
          ? json['shop']['shop_name'] as String?
          : null,
      shopLogo: json['shop'] != null
          ? json['shop']['shop_logo_url'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'user_id': userId,
      'shop_id': shopId,
      'rating': rating,
      'review': review,
      'shop_response': shopResponse,
      'responded_at': respondedAt?.toIso8601String(),
      'is_edited': isEdited,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  BookingReview copyWith({
    String? id,
    String? bookingId,
    String? userId,
    String? shopId,
    int? rating,
    String? review,
    String? shopResponse,
    DateTime? respondedAt,
    bool? isEdited,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingReview(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      shopId: shopId ?? this.shopId,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      shopResponse: shopResponse ?? this.shopResponse,
      respondedAt: respondedAt ?? this.respondedAt,
      isEdited: isEdited ?? this.isEdited,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName,
      userAvatar: userAvatar,
      shopName: shopName,
      shopLogo: shopLogo,
    );
  }

  @override
  List<Object?> get props => [
    id, bookingId, userId, shopId, rating, review, 
    shopResponse, respondedAt, isEdited, createdAt, updatedAt
  ];
}
