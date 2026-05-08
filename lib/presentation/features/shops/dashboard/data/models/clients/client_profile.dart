// lib/features/dashboard/data/models/client_profile.dart
import 'package:equatable/equatable.dart';

/// Client profile data model
class ClientProfile extends Equatable {
  final String id;
  // final String? email;
  final String? fullName;
    final String? username;

  // final String? phone;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? lastBookingAt;
  final int totalBookings;
  final double totalSpent;
  final double? averageRating;
  final bool isActive;

  const ClientProfile({
    required this.id,
    // this.email,
    this.fullName,
    // this.phone,
    this.avatarUrl,
    this.createdAt,
    this.lastBookingAt,
    this.totalBookings = 0,
    this.totalSpent = 0,
    this.averageRating,
    this.isActive = true,
      this.username,
  });

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    return ClientProfile(
      id: json['id'],
      // email: json['email'],
      fullName: json['full_name'],
       username: json['username'] as String?,
      // phone: json['phone'],
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      lastBookingAt: json['last_booking_at'] != null
          ? DateTime.parse(json['last_booking_at'])
          : null,
      totalBookings: json['total_bookings'] ?? 0,
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
      averageRating: json['average_rating']?.toDouble(),
      isActive: json['is_active'] ?? true,
    );
  }

  String get displayName => fullName ?? 'Guest';


  String get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final parts = fullName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return fullName![0].toUpperCase();
    }
    // if (email != null && email!.isNotEmpty) {
    //   return email![0].toUpperCase();
    // }
    return '?';
  }

  @override
  List<Object?> get props => [
    id, 
    // email,
     fullName,
       username,
      // phone,
       avatarUrl, createdAt, lastBookingAt,
    totalBookings, totalSpent, averageRating, isActive
  ];
}
