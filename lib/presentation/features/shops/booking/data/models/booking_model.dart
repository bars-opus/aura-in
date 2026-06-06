// lib/features/booking/data/models/booking_model.dart

import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/booking_service_model.dart';

/// Represents a booking/appointment in the system.
///
/// A booking can contain multiple services (e.g., haircut + beard trim)
/// through the associated [BookingServiceModel]s. This model maps directly
/// to the `bookings` table in Supabase.
///
/// ## Features
/// - Supports single and multi-service bookings
/// - Tracks payment status and amount
/// - Maintains audit trail with timestamps
/// - Handles cancellation and rescheduling
///
/// ## Example
/// ```dart
/// final booking = BookingModel(
///   id: '123e4567-e89b-12d3-a456-426614174000',
///   userId: 'auth0|123',
///   shopId: 'shop_456',
///   bookingDate: DateTime(2024, 2, 1),
///   startTime: DateTime(2024, 2, 1, 9, 0),
///   endTime: DateTime(2024, 2, 1, 10, 30),
///   status: BookingStatus.confirmed,
///   totalAmount: 85.00,
///   paymentStatus: PaymentStatus.paid,
/// );
/// ```

class BookingModel extends Equatable {
  // Original fields
  final String id;
  final String userId;
  final String shopId;

  /// Guest-booking identity. Mutually exclusive with [userId] at the
  /// server (bookings_one_of_user_or_guest_chk). When non-null, the
  /// booking is a guest booking and [userId] will be empty.
  final String? guestProfileId;
  final DateTime bookingDate;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime actualEndTime;
  final BookingStatus status;
  final double totalAmount;
  final double depositAmount;
  final double? platformFee;
  final String? paymentMethod;
  final PaymentStatus paymentStatus;
  final String? paymentIntentId;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<BookingServiceModel>? bookingServices;

  // ADD THESE FIELDS for joined data (used in calendar views)
  // Client view fields
  final double? latitude;
  final double? longitude;
  final String? shopAddress;
  // final String? shopPhone;

  // Shop owner view fields
  final String? clientName;
  final String? clientAvatarUrl;
  // final String? clientPhone;
  final String? specialRequirements;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.shopId,
    this.guestProfileId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.actualEndTime,
    required this.status,
    required this.totalAmount,
    required this.depositAmount,
    this.platformFee,
    this.paymentMethod,
    required this.paymentStatus,
    this.paymentIntentId,
    this.cancellationReason,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
    this.bookingServices,
    // Add these with default values
    this.latitude,
    this.longitude,
    required this.shopAddress,
    // this.shopPhone,
    this.clientName,
    this.clientAvatarUrl,
    // this.clientPhone,
    this.specialRequirements,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Extract location from shop and its locations
    double? latitude;
    double? longitude;
    String? shopAddress;

    if (json['shop'] != null) {
      final shop = json['shop'] as Map<String, dynamic>;

      // Try to get address from shop first
      shopAddress = shop['address'] as String?;

      // Get coordinates from locations array (primary location)
      final locations = shop['locations'] as List?;
      if (locations != null && locations.isNotEmpty) {
        final primaryLocation = locations.first as Map<String, dynamic>;
        latitude = (primaryLocation['latitude'] as num?)?.toDouble();
        longitude = (primaryLocation['longitude'] as num?)?.toDouble();

        // Override address if more detailed in locations
        if (primaryLocation['address'] != null &&
            primaryLocation['address'] != '') {
          shopAddress = primaryLocation['address'] as String?;
        }
      }
    }

    return BookingModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      shopId: json['shop_id'] as String? ?? '',
      guestProfileId: json['guest_profile_id'] as String?,

      bookingDate:
          json['booking_date'] != null
              ? DateTime.parse(json['booking_date'] as String)
              : DateTime.now(),
      startTime:
          json['start_time'] != null
              ? DateTime.parse(json['start_time'] as String)
              : DateTime.now(),
      endTime:
          json['end_time'] != null
              ? DateTime.parse(json['end_time'] as String)
              : DateTime.now(),
      actualEndTime:
          json['actual_end_time'] != null
              ? DateTime.parse(json['actual_end_time'] as String)
              : DateTime.now(),
      status:
          json['status'] != null
              ? BookingStatus.fromString(json['status'] as String)
              : BookingStatus.pending,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      depositAmount: (json['deposit_amount'] as num?)?.toDouble() ?? 0.0,
      platformFee: (json['platform_fee'] as num?)?.toDouble(),

      specialRequirements: json['special_requirements'] as String?,
      paymentMethod: json['payment_method'] as String?,
      paymentStatus:
          json['payment_status'] != null
              ? PaymentStatus.fromString(json['payment_status'] as String)
              : PaymentStatus.unpaid,
      paymentIntentId: json['payment_intent_id'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      cancelledAt:
          json['cancelled_at'] != null
              ? DateTime.parse(json['cancelled_at'] as String)
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : DateTime.now(),

      // Services
      bookingServices:
          json['booking_services'] != null
              ? (json['booking_services'] as List)
                  .map(
                    (e) =>
                        BookingServiceModel.fromJson(e as Map<String, dynamic>),
                  )
                  .toList()
              : [],

      // Shop info (from joined data)
      shopAddress: shopAddress,
      latitude: latitude,
      longitude: longitude,

      // Client info (for shop owner view)
      clientName:
          json['client'] != null
              ? (json['client']['display_name'] as String?) ??
                  (json['client']['username'] as String?) ??
                  'Client'
              : null,
      clientAvatarUrl:
          json['client'] != null
              ? json['client']['avatar_url'] as String?
              : null,

      // clientPhone:
      //     json['client'] != null ? json['client']['phone'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'shop_id': shopId,
      'guest_profile_id': guestProfileId,
      'booking_date': bookingDate.toIso8601String(),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'actual_end_time': actualEndTime.toIso8601String(),
      'status': status.value,
      'total_amount': totalAmount,
      'deposit_amount': depositAmount,
      'platform_fee': platformFee,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus.value,
      'payment_intent_id': paymentIntentId,
      'cancellation_reason': cancellationReason,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'specialRequirements': specialRequirements,

      'address': shopAddress,
      'latitude': latitude,
      'longitude': longitude,

      // Note: We don't save joined data back to the database
    };
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? shopId,
    String? guestProfileId,
    DateTime? bookingDate,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? actualEndTime,
    BookingStatus? status,
    double? totalAmount,
    double? depositAmount,
    double? platformFee,
    String? paymentMethod,
    PaymentStatus? paymentStatus,
    String? paymentIntentId,
    String? cancellationReason,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<BookingServiceModel>? bookingServices,
    double? latitude,
    double? longitude,
    String? shopAddress,
    String? shopPhone,
    String? clientName,
    String? clientAvatarUrl,
    String? specialRequirements,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopId: shopId ?? this.shopId,
      guestProfileId: guestProfileId ?? this.guestProfileId,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      depositAmount: depositAmount ?? this.depositAmount,
      platformFee: platformFee ?? this.platformFee,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bookingServices: bookingServices ?? this.bookingServices,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      shopAddress: shopAddress ?? this.shopAddress,
      // shopPhone: shopPhone ?? this.shopPhone,
      clientName: clientName ?? this.clientName,
      clientAvatarUrl: clientAvatarUrl ?? this.clientAvatarUrl,
      specialRequirements: specialRequirements ?? this.specialRequirements,
    );
  }

  bool get isActive =>
      status == BookingStatus.confirmed || status == BookingStatus.pending;

  bool canCancel({Duration cancellationWindow = const Duration(hours: 24)}) {
    if (!isActive) return false;
    final now = DateTime.now();
    return startTime.difference(now) > cancellationWindow;
  }

  double get remainingBalance => totalAmount - depositAmount;

  bool get isFullyPaid =>
      paymentStatus == PaymentStatus.paid && depositAmount > 0;

  @override
  List<Object?> get props => [
    id,
    userId,
    shopId,
    guestProfileId,
    bookingDate,
    startTime,
    endTime,
    actualEndTime,
    status,
    totalAmount,
    depositAmount,
    platformFee,
    paymentMethod,
    paymentStatus,
    createdAt,
    updatedAt,
    latitude,
    longitude,
    shopAddress,
    // shopPhone,
    clientName,
    clientAvatarUrl,
    specialRequirements,
  ];
}

/// Represents the possible states of a booking.
enum BookingStatus {
  pending('pending'),
  confirmed('confirmed'),
  cancelled('cancelled'),
  completed('completed'),
  noShow('no_show');

  final String value;
  const BookingStatus(this.value);

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BookingStatus.pending,
    );
  }
}

/// Represents the payment status of a booking.
enum PaymentStatus {
  unpaid('unpaid'),
  paid('paid'),
  refunded('refunded'),
  failed('failed');

  final String value;
  const PaymentStatus(this.value);

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentStatus.unpaid,
    );
  }
}
