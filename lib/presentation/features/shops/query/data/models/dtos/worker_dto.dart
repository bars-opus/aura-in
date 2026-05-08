import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/worker_unavailability_model.dart';

class WorkerDTO extends Equatable {
  final String id;
  final String? shopId;
  final String name;
  final String? bio;
  final String? profileImage;
  final List<String> specialties;
  final bool isActive;
  final double? ratingAverage;
  final List<WorkerUnavailabilityModel>? unavailability;

  // Shop relationship fields (from shop_workers)
  final String? shopWorkerId;
  final String? role;
  final List<String>? roles;
  final double? commissionPercentage;
  final String? status;
  final DateTime? joinedAt;

  const WorkerDTO({
    required this.id,
    this.shopId,
    required this.name,
    this.bio,
    this.profileImage,
    required this.specialties,
    required this.isActive,
    this.ratingAverage,
    this.unavailability,
    this.shopWorkerId,
    this.role,
    this.roles,
    this.commissionPercentage,
    this.status,
    this.joinedAt,
  });

  factory WorkerDTO.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw FormatException('WorkerDTO.fromJson: json is null');
    }

    // Helper to parse list of strings safely
    List<String> _parseStringList(dynamic input) {
      if (input == null) return <String>[];
      if (input is List) {
        return input.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
      }
      if (input is String) {
        return input.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }
      return <String>[];
    }

    // Parse unavailability list
    List<WorkerUnavailabilityModel>? _parseUnavailability(dynamic input) {
      if (input == null) return null;
      if (input is List) {
        return input.map<WorkerUnavailabilityModel>((u) {
          if (u is WorkerUnavailabilityModel) return u;
          if (u is Map<String, dynamic>) return WorkerUnavailabilityModel.fromJson(u);
          if (u is Map) return WorkerUnavailabilityModel.fromJson(Map<String, dynamic>.from(u));
          throw FormatException('Invalid unavailability item: $u');
        }).toList();
      }
      return null;
    }

    // Parse optional numeric
    double? _toDoubleNullable(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    // Parse optional DateTime
    DateTime? _toDateTimeNullable(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String) {
        try {
          return DateTime.parse(v);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    return WorkerDTO(
      id: json['id']?.toString() ?? '',
      shopId: json['shop_id']?.toString(),
      name: json['name']?.toString() ?? '',
      bio: json['bio']?.toString(),
      profileImage: json['profile_image_url']?.toString() ?? json['profile_image']?.toString(),
      specialties: _parseStringList(json['specialties'] ?? json['skills'] ?? json['areas_of_expertise']),
      isActive: json.containsKey('is_active')
          ? (json['is_active'] is bool
              ? json['is_active'] as bool
              : json['is_active'].toString().toLowerCase() == 'true')
          : true,
      ratingAverage: _toDoubleNullable(json['rating_average'] ?? json['rating']),
      unavailability: _parseUnavailability(json['worker_unavailability'] ?? json['unavailability']),
      shopWorkerId: json['shop_worker_id']?.toString() ?? json['shopWorkerId']?.toString(),
      role: json['role']?.toString() ?? json['primary_role']?.toString(),
      roles: _parseStringList(json['roles'] ?? json['role_list']),
      commissionPercentage: _toDoubleNullable(json['commission_percentage'] ?? json['commission']),
      status: json['status']?.toString(),
      joinedAt: _toDateTimeNullable(json['joined_at'] ?? json['joinedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (shopId != null) 'shop_id': shopId,
      'name': name,
      if (bio != null) 'bio': bio,
      if (profileImage != null) 'profile_image_url': profileImage,
      'specialties': specialties,
      'is_active': isActive,
      if (ratingAverage != null) 'rating_average': ratingAverage,
      if (unavailability != null) 'worker_unavailability': unavailability!.map((u) => u.toJson()).toList(),
      if (shopWorkerId != null) 'shop_worker_id': shopWorkerId,
      if (role != null) 'role': role,
      if (roles != null) 'roles': roles,
      if (commissionPercentage != null) 'commission_percentage': commissionPercentage,
      if (status != null) 'status': status,
      if (joinedAt != null) 'joined_at': joinedAt!.toIso8601String(),
    };
  }

  /// Check if worker is available for a given time range
  bool isAvailable(DateTime startTime, DateTime endTime) {
    if (unavailability == null || unavailability!.isEmpty) return true;

    return !unavailability!.any(
      (period) => period.overlaps(startTime, endTime),
    );
  }

  @override
  List<Object?> get props => [
        id,
        shopId,
        name,
        bio,
        profileImage,
        specialties,
        isActive,
        ratingAverage,
        unavailability,
        shopWorkerId,
        role,
        roles,
        commissionPercentage,
        status,
        joinedAt,
      ];
}
