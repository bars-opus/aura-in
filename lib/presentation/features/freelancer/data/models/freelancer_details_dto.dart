// lib/features/freelancer/data/models/freelancer_details_dto.dart
import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/freelancer/enums/freelancer_type.dart';

/// Complete freelancer profile for details screen
/// Includes all data from workers + freelancer_details
class FreelancerDetailsDTO extends Equatable {
  // Core worker fields
  final String id;
  final String userId;
  final String? shopId; // Will be null for freelancers
  final String name;
  final String? terms;

  final String? bio;
  final String? profileImageUrl;
  final List<String> specialties;
  final bool isActive;
  final bool isFreelancer;

  // Freelancer-specific fields
  final FreelancerType? freelancerType;
  final List<FreelancerType> freelancerTypes;
  final List<String> tools;
  final String? subaccountId;
  final String? transferRecipientId;
  final bool canTravel;
  final double? baseLatitude;
  final double? baseLongitude;
  final int travelRadiusKm;
  final double rating;
  final int totalReviews;
  final double totalRevenue;
  final int totalBookings;
  final bool autoAcceptBookings;
  final int maxBookingsPerDay;
  final int bufferMinutesBetweenBookings;
  final bool isIdentityVerified;
  final bool isBackgroundChecked;
  final DateTime? verifiedAt;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FreelancerDetailsDTO({
    required this.id,
    required this.userId,
    this.shopId,
    required this.name,
    this.bio,
    this.profileImageUrl,
    this.specialties = const [],
    this.isActive = true,
    this.isFreelancer = true,
    this.freelancerType,
    this.freelancerTypes = const [],
    this.tools = const [],
    this.subaccountId,
    this.transferRecipientId,
    this.canTravel = false,
    this.baseLatitude,
    this.baseLongitude,
    this.travelRadiusKm = 10,
    this.rating = 0,
    this.totalReviews = 0,
    this.totalRevenue = 0,
    this.totalBookings = 0,
    this.autoAcceptBookings = false,
    this.maxBookingsPerDay = 10,
    this.bufferMinutesBetweenBookings = 15,
    this.isIdentityVerified = false,
    this.isBackgroundChecked = false,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
    this.terms,
  });

  /// Create from JSON (joining workers + freelancer_details)
  factory FreelancerDetailsDTO.fromJson(Map<String, dynamic> json) {
    // When queried via `select('*, freelancer_details:freelancer_details(*)')`,
    // Supabase nests the joined table under the 'freelancer_details' key.
    // Fall back to top-level for flattened queries (e.g. RPCs / views).
    final details = (json['freelancer_details'] as Map<String, dynamic>?) ?? {};

    return FreelancerDetailsDTO(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      shopId: json['shop_id'] as String?,
      name: json['name'] as String,
      terms: json['terms'] as String?, // ✅ Fixed - allows null
      bio: json['bio'] as String?,
      profileImageUrl:
          (json['profile_image'] ?? json['profile_image_url']) as String?,
      specialties: List<String>.from(json['specialties'] ?? []),
      isActive: json['is_active'] ?? true,
      isFreelancer: json['is_freelancer'] ?? true,
      freelancerType:
          json['freelancer_type'] != null
              ? FreelancerType.fromString(json['freelancer_type'])
              : null,
      freelancerTypes:
          (json['freelancer_types'] as List?)
              ?.map((e) => FreelancerType.fromString(e.toString()))
              .toList() ??
          [],
      tools: List<String>.from(json['tools'] ?? []),
      subaccountId: json['subaccount_id'] as String?,
      transferRecipientId: json['transfer_recipient_id'] as String?,
      canTravel:
          (details['can_travel'] ?? json['can_travel']) as bool? ?? false,
      baseLatitude:
          ((details['base_latitude'] ?? json['base_latitude']) as num?)
              ?.toDouble(),
      baseLongitude:
          ((details['base_longitude'] ?? json['base_longitude']) as num?)
              ?.toDouble(),
      travelRadiusKm:
          (details['travel_radius_km'] ?? json['travel_radius_km'] ?? 10)
              as int,
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      totalBookings: json['total_bookings'] ?? 0,
      autoAcceptBookings: json['auto_accept_bookings'] ?? false,
      maxBookingsPerDay: json['max_bookings_per_day'] ?? 10,
      bufferMinutesBetweenBookings:
          json['buffer_minutes_between_bookings'] ?? 15,
      isIdentityVerified: json['is_identity_verified'] ?? false,
      isBackgroundChecked: json['is_background_checked'] ?? false,
      verifiedAt:
          json['verified_at'] != null
              ? DateTime.parse(json['verified_at'])
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  /// Helper to get primary type display name
  String get primaryTypeDisplay => freelancerType?.displayName ?? 'Freelancer';

  /// Helper to get all types display names
  List<String> get allTypesDisplay =>
      freelancerTypes.map((t) => t.displayName).toList();

  /// Helper to check if profile is complete enough for publishing
  bool get isProfileComplete =>
      name.isNotEmpty &&
      baseLatitude != null &&
      baseLongitude != null &&
      travelRadiusKm > 0;

  @override
  List<Object?> get props => [
    id,
    userId,
    shopId,
    name,
    bio,
    profileImageUrl,
    specialties,
    isActive,
    isFreelancer,
    freelancerType,
    freelancerTypes,
    tools,
    subaccountId,
    transferRecipientId,
    canTravel,
    baseLatitude,
    baseLongitude,
    travelRadiusKm,
    rating,
    totalReviews,
    totalRevenue,
    totalBookings,
    autoAcceptBookings,
    maxBookingsPerDay,
    bufferMinutesBetweenBookings,
    isIdentityVerified,
    isBackgroundChecked,
    verifiedAt,
    createdAt,
    updatedAt,
    terms,
  ];
}
