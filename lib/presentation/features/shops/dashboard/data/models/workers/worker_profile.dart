// lib/features/dashboard/data/models/worker_profile.dart
import 'package:equatable/equatable.dart';

/// Worker profile model (unified for both shop employees and freelancers)
class WorkerProfile extends Equatable {
  // Core fields (from workers table)
  final String id;
  final String? shopId; // NULL for freelancers
  final String name;
  final String? bio;
  final String? profileImageUrl;
  final List<String> specialties;
  final bool isActive;
  final bool isFreelancer;

  // Employee fields (from employee_details, NULL if freelancer)
  final double? hourlyRate;
  final DateTime? employmentStart;
  final DateTime? employmentEnd;
  final String? employmentType; // 'full_time', 'part_time', 'contractor'

  // Freelancer fields (from freelancer_details, NULL if employee)
  final List<String> tools;
  final String? subaccountId;
  final String? transferRecipientId;
  final String? freelancerType;
  final List<String> freelancerTypes; // Array for multiple types
  final bool canTravel;
  final double? freelancerRating;
  final int? freelancerTotalReviews;
  final double? freelancerTotalRevenue;
  
  // Freelancer location & settings
  final double? baseLatitude;
  final double? baseLongitude;
  final int travelRadiusKm;
  final bool autoAcceptBookings;
  final int maxBookingsPerDay;
  final int bufferMinutesBetweenBookings;
  final bool isIdentityVerified;
  final bool isBackgroundChecked;
  final DateTime? verifiedAt;

  // Performance metrics (calculated from bookings - for both types)
  final double? averageRating; // from reviews
  final int? totalReviews; // from reviews
  final int totalBookings; // from bookings
  final double totalRevenue; // from bookings (for employees) or freelancer_details (for freelancers)

  // Attendance stats (only for employees, always 0/null for freelancers)
  final int daysWorkedThisMonth;
  final double totalHoursThisMonth;
  final double onTimeRate;
  final int lateArrivalsThisMonth;
  final int absentDaysThisMonth;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WorkerProfile({
    required this.id,
    this.shopId,
    required this.name,
    this.bio,
    this.profileImageUrl,
    this.specialties = const [],
    this.isActive = true,
    this.isFreelancer = false,
    // Employee fields
    this.hourlyRate,
    this.employmentStart,
    this.employmentEnd,
    this.employmentType,
    // Freelancer fields
    this.tools = const [],
    this.subaccountId,
    this.transferRecipientId,
    this.freelancerType,
    this.freelancerTypes = const [],
    this.canTravel = false,
    this.freelancerRating,
    this.freelancerTotalReviews,
    this.freelancerTotalRevenue,
    // Freelancer location & settings
    this.baseLatitude,
    this.baseLongitude,
    this.travelRadiusKm = 10,
    this.autoAcceptBookings = false,
    this.maxBookingsPerDay = 10,
    this.bufferMinutesBetweenBookings = 15,
    this.isIdentityVerified = false,
    this.isBackgroundChecked = false,
    this.verifiedAt,
    // Performance metrics
    this.averageRating,
    this.totalReviews,
    this.totalBookings = 0,
    this.totalRevenue = 0,
    // Attendance stats
    this.daysWorkedThisMonth = 0,
    this.totalHoursThisMonth = 0,
    this.onTimeRate = 0,
    this.lateArrivalsThisMonth = 0,
    this.absentDaysThisMonth = 0,
    // Timestamps
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON (handles both employee and freelancer data)
  factory WorkerProfile.fromJson(Map<String, dynamic> json) {
    // Extract employee details if present
    final employeeDetails = json['employee_details'] as Map<String, dynamic>?;

    // Extract freelancer details if present
    final freelancerDetails = json['freelancer_details'] as Map<String, dynamic>?;

    final isFreelancer = json['is_freelancer'] ?? false;

    // Employee fields - only if NOT freelancer
    double? hourlyRate;
    DateTime? employmentStart;
    DateTime? employmentEnd;
    String? employmentType;

    if (!isFreelancer && employeeDetails != null) {
      hourlyRate = employeeDetails['hourly_rate']?.toDouble();
      if (employeeDetails['employment_start'] != null) {
        employmentStart = DateTime.parse(employeeDetails['employment_start']);
      }
      if (employeeDetails['employment_end'] != null) {
        employmentEnd = DateTime.parse(employeeDetails['employment_end']);
      }
      employmentType = employeeDetails['employment_type'];
    }

    // Freelancer fields - only if freelancer
    List<String> tools = [];
    String? subaccountId;
    String? transferRecipientId;
    String? freelancerType;
    List<String> freelancerTypes = [];
    bool canTravel = false;
    double? freelancerRating;
    int? freelancerTotalReviews;
    double? freelancerTotalRevenue;
    double? baseLatitude;
    double? baseLongitude;
    int travelRadiusKm = 10;
    bool autoAcceptBookings = false;
    int maxBookingsPerDay = 10;
    int bufferMinutesBetweenBookings = 15;
    bool isIdentityVerified = false;
    bool isBackgroundChecked = false;
    DateTime? verifiedAt;

    if (isFreelancer && freelancerDetails != null) {
      tools = List<String>.from(freelancerDetails['tools'] ?? []);
      subaccountId = freelancerDetails['subaccount_id'];
      transferRecipientId = freelancerDetails['transfer_recipient_id'];
      freelancerType = freelancerDetails['freelancer_type'];
      freelancerTypes = List<String>.from(freelancerDetails['freelancer_types'] ?? []);
      canTravel = freelancerDetails['can_travel'] ?? false;
      freelancerRating = freelancerDetails['rating']?.toDouble();
      freelancerTotalReviews = freelancerDetails['total_reviews'];
      freelancerTotalRevenue = freelancerDetails['total_revenue']?.toDouble();
      baseLatitude = (freelancerDetails['base_latitude'] as num?)?.toDouble();
      baseLongitude = (freelancerDetails['base_longitude'] as num?)?.toDouble();
      travelRadiusKm = freelancerDetails['travel_radius_km'] ?? 10;
      autoAcceptBookings = freelancerDetails['auto_accept_bookings'] ?? false;
      maxBookingsPerDay = freelancerDetails['max_bookings_per_day'] ?? 10;
      bufferMinutesBetweenBookings = freelancerDetails['buffer_minutes_between_bookings'] ?? 15;
      isIdentityVerified = freelancerDetails['is_identity_verified'] ?? false;
      isBackgroundChecked = freelancerDetails['is_background_checked'] ?? false;
      if (freelancerDetails['verified_at'] != null) {
        verifiedAt = DateTime.parse(freelancerDetails['verified_at']);
      }
    }

    return WorkerProfile(
      id: json['id'],
      shopId: json['shop_id'],
      name: json['name'],
      bio: json['bio'],
      profileImageUrl: json['profile_image'],
      specialties: List<String>.from(json['specialties'] ?? []),
      isActive: json['is_active'] ?? true,
      isFreelancer: isFreelancer,

      // Employee fields
      hourlyRate: hourlyRate,
      employmentStart: employmentStart,
      employmentEnd: employmentEnd,
      employmentType: employmentType,

      // Freelancer fields
      tools: tools,
      subaccountId: subaccountId,
      transferRecipientId: transferRecipientId,
      freelancerType: freelancerType,
      freelancerTypes: freelancerTypes,
      canTravel: canTravel,
      freelancerRating: freelancerRating,
      freelancerTotalReviews: freelancerTotalReviews,
      freelancerTotalRevenue: freelancerTotalRevenue,
      
      // Freelancer location & settings
      baseLatitude: baseLatitude,
      baseLongitude: baseLongitude,
      travelRadiusKm: travelRadiusKm,
      autoAcceptBookings: autoAcceptBookings,
      maxBookingsPerDay: maxBookingsPerDay,
      bufferMinutesBetweenBookings: bufferMinutesBetweenBookings,
      isIdentityVerified: isIdentityVerified,
      isBackgroundChecked: isBackgroundChecked,
      verifiedAt: verifiedAt,

      // Performance metrics
      averageRating: json['average_rating']?.toDouble(),
      totalReviews: json['total_reviews'],
      totalBookings: json['total_bookings'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),

      // Attendance stats (from view or separate query)
      daysWorkedThisMonth: json['days_worked'] ?? 0,
      totalHoursThisMonth: (json['total_hours'] ?? 0).toDouble(),
      onTimeRate: (json['on_time_rate'] ?? 0).toDouble(),
      lateArrivalsThisMonth: json['late_arrivals'] ?? 0,
      absentDaysThisMonth: json['absent_days'] ?? 0,

      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  /// Convert to JSON for database operations
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'name': name,
      'bio': bio,
      'profile_image': profileImageUrl,
      'specialties': specialties,
      'is_active': isActive,
      'is_freelancer': isFreelancer,
      // Employee fields
      if (!isFreelancer) ...{
        'hourly_rate': hourlyRate,
        'employment_start': employmentStart?.toIso8601String().split('T').first,
        'employment_end': employmentEnd?.toIso8601String().split('T').first,
        'employment_type': employmentType,
      },
      // Freelancer fields
      if (isFreelancer) ...{
        'tools': tools,
        'subaccount_id': subaccountId,
        'transfer_recipient_id': transferRecipientId,
        'freelancer_type': freelancerType,
        'freelancer_types': freelancerTypes,
        'can_travel': canTravel,
        'base_latitude': baseLatitude,
        'base_longitude': baseLongitude,
        'travel_radius_km': travelRadiusKm,
        'auto_accept_bookings': autoAcceptBookings,
        'max_bookings_per_day': maxBookingsPerDay,
        'buffer_minutes_between_bookings': bufferMinutesBetweenBookings,
        'is_identity_verified': isIdentityVerified,
        'is_background_checked': isBackgroundChecked,
        'verified_at': verifiedAt?.toIso8601String(),
      },
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  WorkerProfile copyWith({
    String? id,
    String? shopId,
    String? name,
    String? bio,
    String? profileImageUrl,
    List<String>? specialties,
    bool? isActive,
    bool? isFreelancer,
    double? hourlyRate,
    DateTime? employmentStart,
    DateTime? employmentEnd,
    String? employmentType,
    List<String>? tools,
    String? subaccountId,
    String? transferRecipientId,
    String? freelancerType,
    List<String>? freelancerTypes,
    bool? canTravel,
    double? freelancerRating,
    int? freelancerTotalReviews,
    double? freelancerTotalRevenue,
    double? baseLatitude,
    double? baseLongitude,
    int? travelRadiusKm,
    bool? autoAcceptBookings,
    int? maxBookingsPerDay,
    int? bufferMinutesBetweenBookings,
    bool? isIdentityVerified,
    bool? isBackgroundChecked,
    DateTime? verifiedAt,
    double? averageRating,
    int? totalReviews,
    int? totalBookings,
    double? totalRevenue,
    int? daysWorkedThisMonth,
    double? totalHoursThisMonth,
    double? onTimeRate,
    int? lateArrivalsThisMonth,
    int? absentDaysThisMonth,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkerProfile(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      specialties: specialties ?? this.specialties,
      isActive: isActive ?? this.isActive,
      isFreelancer: isFreelancer ?? this.isFreelancer,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      employmentStart: employmentStart ?? this.employmentStart,
      employmentEnd: employmentEnd ?? this.employmentEnd,
      employmentType: employmentType ?? this.employmentType,
      tools: tools ?? this.tools,
      subaccountId: subaccountId ?? this.subaccountId,
      transferRecipientId: transferRecipientId ?? this.transferRecipientId,
      freelancerType: freelancerType ?? this.freelancerType,
      freelancerTypes: freelancerTypes ?? this.freelancerTypes,
      canTravel: canTravel ?? this.canTravel,
      freelancerRating: freelancerRating ?? this.freelancerRating,
      freelancerTotalReviews: freelancerTotalReviews ?? this.freelancerTotalReviews,
      freelancerTotalRevenue: freelancerTotalRevenue ?? this.freelancerTotalRevenue,
      baseLatitude: baseLatitude ?? this.baseLatitude,
      baseLongitude: baseLongitude ?? this.baseLongitude,
      travelRadiusKm: travelRadiusKm ?? this.travelRadiusKm,
      autoAcceptBookings: autoAcceptBookings ?? this.autoAcceptBookings,
      maxBookingsPerDay: maxBookingsPerDay ?? this.maxBookingsPerDay,
      bufferMinutesBetweenBookings: bufferMinutesBetweenBookings ?? this.bufferMinutesBetweenBookings,
      isIdentityVerified: isIdentityVerified ?? this.isIdentityVerified,
      isBackgroundChecked: isBackgroundChecked ?? this.isBackgroundChecked,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalBookings: totalBookings ?? this.totalBookings,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      daysWorkedThisMonth: daysWorkedThisMonth ?? this.daysWorkedThisMonth,
      totalHoursThisMonth: totalHoursThisMonth ?? this.totalHoursThisMonth,
      onTimeRate: onTimeRate ?? this.onTimeRate,
      lateArrivalsThisMonth: lateArrivalsThisMonth ?? this.lateArrivalsThisMonth,
      absentDaysThisMonth: absentDaysThisMonth ?? this.absentDaysThisMonth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Helper to check if this is a shop employee (not freelancer)
  bool get isShopEmployee => !isFreelancer;

  /// Helper to get display name for employment type
  String get employmentTypeDisplay {
    switch (employmentType) {
      case 'full_time':
        return 'Full Time';
      case 'part_time':
        return 'Part Time';
      case 'contractor':
        return 'Contractor';
      default:
        return 'Employee';
    }
  }

  /// Helper to get formatted on-time rate
  String get formattedOnTimeRate => '${onTimeRate.toStringAsFixed(0)}%';

  /// Helper to get formatted total hours
  String get formattedTotalHours => '${totalHoursThisMonth.toStringAsFixed(1)} hrs';

  /// Helper to check if freelancer profile is complete
  bool get isFreelancerProfileComplete {
    if (!isFreelancer) return true;
    return name.isNotEmpty &&
        baseLatitude != null &&
        baseLongitude != null &&
        travelRadiusKm > 0;
  }

  /// Helper to get formatted travel radius
  String get formattedTravelRadius => '$travelRadiusKm km';

  /// Helper to get primary type display name
  String get primaryTypeDisplay => freelancerType ?? 'Freelancer';

  /// Helper to get all types display names
  List<String> get allTypesDisplay => freelancerTypes;

  @override
  List<Object?> get props => [
    id,
    shopId,
    name,
    bio,
    profileImageUrl,
    specialties,
    isActive,
    isFreelancer,
    hourlyRate,
    employmentStart,
    employmentEnd,
    employmentType,
    tools,
    subaccountId,
    transferRecipientId,
    freelancerType,
    freelancerTypes,
    canTravel,
    freelancerRating,
    freelancerTotalReviews,
    freelancerTotalRevenue,
    baseLatitude,
    baseLongitude,
    travelRadiusKm,
    autoAcceptBookings,
    maxBookingsPerDay,
    bufferMinutesBetweenBookings,
    isIdentityVerified,
    isBackgroundChecked,
    verifiedAt,
    averageRating,
    totalReviews,
    totalBookings,
    totalRevenue,
    daysWorkedThisMonth,
    totalHoursThisMonth,
    onTimeRate,
    lateArrivalsThisMonth,
    absentDaysThisMonth,
    createdAt,
    updatedAt,
  ];
}
