// lib/features/freelancer/data/models/nearby_freelancer_dto.dart
import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/freelancer/enums/freelancer_type.dart';

/// DTO for displaying freelancers in discovery lists
/// Contains only the data needed for list views (not full profile)
class NearbyFreelancerDTO extends Equatable {
  final String id;
  final String name;
  final String? profileImage;
  final String? bio;
  final List<String> specialties;
  final FreelancerType? freelancerType;
  final List<FreelancerType> freelancerTypes;
  final List<String> tools;
  final bool canTravel;
  final int travelRadiusKm;
  final double averageRating;
  final int totalReviews;
  final int totalBookings;
  final double totalRevenue;
  final double distanceKm;
  final double baseLatitude;
  final double baseLongitude;
  final bool isIdentityVerified;
  final bool isBackgroundChecked;

  const NearbyFreelancerDTO({
    required this.id,
    required this.name,
    this.profileImage,
    this.bio,
    this.specialties = const [],
    this.freelancerType,
    this.freelancerTypes = const [],
    this.tools = const [],
    this.canTravel = false,
    this.travelRadiusKm = 10,
    this.averageRating = 0,
    this.totalReviews = 0,
    this.totalBookings = 0,
    this.totalRevenue = 0,
    this.distanceKm = 0,
    this.baseLatitude = 0,
    this.baseLongitude = 0,
    this.isIdentityVerified = false,
    this.isBackgroundChecked = false,
  });

  /// Create from JSON (from get_nearby_freelancers RPC)
  factory NearbyFreelancerDTO.fromJson(Map<String, dynamic> json) {
    return NearbyFreelancerDTO(
      id: json['worker_id'] as String,
      name: json['name'] as String,
      profileImage: json['profile_image'] as String?,
      bio: json['bio'] as String?,
      specialties: List<String>.from(json['specialties'] ?? []),
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
      canTravel: json['can_travel'] ?? false,
      travelRadiusKm: json['travel_radius_km'] ?? 10,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      baseLatitude: (json['base_latitude'] ?? 0).toDouble(),
      baseLongitude: (json['base_longitude'] ?? 0).toDouble(),
      isIdentityVerified: json['is_identity_verified'] ?? false,
      isBackgroundChecked: json['is_background_checked'] ?? false,
    );
  }

  /// Helper to get formatted distance string
  String get formattedDistance {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }
    if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
    return '${distanceKm.round()} km';
  }

  /// Convert worker table JSON to NearbyFreelancerDTO format
  Map<String, dynamic> _convertWorkerToNearbyFormat(
    Map<String, dynamic> worker,
  ) {
    final details = worker['freelancer_details'] as Map<String, dynamic>? ?? {};

    return {
      'worker_id': worker['id'],
      'name': worker['name'],
      'profile_image': worker['profile_image_url'],
      'bio': worker['bio'],
      'specialties': worker['specialties'],
      'freelancer_type': details['freelancer_type'],
      'freelancer_types': details['freelancer_types'],
      'tools': details['tools'],
      'can_travel': details['can_travel'],
      'travel_radius_km': details['travel_radius_km'],
      'average_rating': details['rating'] ?? details['average_rating'],
      'total_reviews': details['total_reviews'],
      'total_bookings': details['total_bookings'],
      'total_revenue': details['total_revenue'],
      'distance_km': 0,
      'base_latitude': details['base_latitude'],
      'base_longitude': details['base_longitude'],
      'is_identity_verified': details['is_identity_verified'],
      'is_background_checked': details['is_background_checked'],
    };
  }

  /// Helper to get rating stars (0-5)
  double get ratingStars => averageRating.clamp(0.0, 5.0);

  /// Helper to check if freelancer has verified badges
  bool get hasVerificationBadges => isIdentityVerified || isBackgroundChecked;

  @override
  List<Object?> get props => [
    id,
    name,
    profileImage,
    bio,
    specialties,
    freelancerType,
    freelancerTypes,
    tools,
    canTravel,
    travelRadiusKm,
    averageRating,
    totalReviews,
    totalBookings,
    totalRevenue,
    distanceKm,
    baseLatitude,
    baseLongitude,
    isIdentityVerified,
    isBackgroundChecked,
  ];
}
