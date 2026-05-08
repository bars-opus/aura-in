// lib/features/search/models/freelancer_search_result.dart
import 'package:nano_embryo/presentation/features/freelancer/data/models/nearby_freelancer_dto.dart';
import 'package:nano_embryo/presentation/features/freelancer/enums/freelancer_type.dart';
import 'unified_search_result.dart';
import 'search_category.dart';

class FreelancerSearchResult extends UnifiedSearchResult {
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

   FreelancerSearchResult({
    required super.id,
    required super.title,
    required super.subtitle,
    super.imageUrl,
    required this.name,
    required this.profileImage,
    required this.bio,
    required this.specialties,
    required this.freelancerType,
    required this.freelancerTypes,
    required this.tools,
    required this.canTravel,
    required this.travelRadiusKm,
    required this.averageRating,
    required this.totalReviews,
    required this.totalBookings,
    required this.totalRevenue,
    required this.distanceKm,
    required this.baseLatitude,
    required this.baseLongitude,
    required this.isIdentityVerified,
    required this.isBackgroundChecked,
  }) : super(
         category: SearchCategory.freelancers,
         relevanceScore: averageRating / 5.0, // Normalize rating to 0-1
       );

  /// Create from NearbyFreelancerDTO
  factory FreelancerSearchResult.fromNearbyFreelancer(
    NearbyFreelancerDTO freelancer,
    String searchQuery,
  ) {
    final title = freelancer.name;
    final subtitle = _buildSubtitle(freelancer);

    return FreelancerSearchResult(
      id: freelancer.id,
      title: title,
      subtitle: subtitle,
      imageUrl: freelancer.profileImage,
      name: freelancer.name,
      profileImage: freelancer.profileImage,
      bio: freelancer.bio,
      specialties: freelancer.specialties,
      freelancerType: freelancer.freelancerType,
      freelancerTypes: freelancer.freelancerTypes,
      tools: freelancer.tools,
      canTravel: freelancer.canTravel,
      travelRadiusKm: freelancer.travelRadiusKm,
      averageRating: freelancer.averageRating,
      totalReviews: freelancer.totalReviews,
      totalBookings: freelancer.totalBookings,
      totalRevenue: freelancer.totalRevenue,
      distanceKm: freelancer.distanceKm,
      baseLatitude: freelancer.baseLatitude,
      baseLongitude: freelancer.baseLongitude,
      isIdentityVerified: freelancer.isIdentityVerified,
      isBackgroundChecked: freelancer.isBackgroundChecked,
    );
  }

  static String _buildSubtitle(NearbyFreelancerDTO freelancer) {
    final parts = <String>[];

    if (freelancer.averageRating > 0) {
      parts.add('${freelancer.averageRating.toStringAsFixed(1)}★');
    }
    if (freelancer.totalReviews > 0) {
      parts.add('(${freelancer.totalReviews} reviews)');
    }
    if (freelancer.distanceKm > 0) {
      parts.add(freelancer.formattedDistance);
    }
    if (freelancer.specialties.isNotEmpty) {
      parts.add(freelancer.specialties.take(2).join(', '));
    }

    return parts.isEmpty ? 'Freelancer' : parts.join(' • ');
  }

  @override
  String get briefDescription => subtitle;

  /// Get formatted distance string
  String get formattedDistance {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }
    if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
    return '${distanceKm.round()} km';
  }

  /// Check if freelancer has verification badges
  bool get hasVerificationBadges => isIdentityVerified || isBackgroundChecked;
}
