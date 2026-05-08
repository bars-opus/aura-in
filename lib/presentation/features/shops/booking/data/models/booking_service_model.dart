// lib/features/booking/data/models/booking_service_model.dart

import 'package:equatable/equatable.dart';

class BookingServiceModel extends Equatable {
  final String id;
  final String bookingId;
  final String slotId;
  final String? workerId;
  final double priceAtBooking;
  final int durationMinutes;
  final DateTime createdAt;
  final DateTime? startTime;
  final String? serviceName; // ← NEW
  final String? workerName; // ← NEW
  final String? specialRequirements;

  const BookingServiceModel({
    required this.id,
    required this.bookingId,
    required this.slotId,
    required this.startTime,
    this.workerId,
    required this.priceAtBooking,
    required this.durationMinutes,
    required this.createdAt,
    this.serviceName, // ← NEW
    this.workerName, // ← NEW
    this.specialRequirements,
  });

  factory BookingServiceModel.fromJson(Map<String, dynamic> json) {
    return BookingServiceModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      slotId: json['slot_id'] as String,
      workerId: json['worker_id'] as String?,
      priceAtBooking: (json['price_at_booking'] as num).toDouble(),
      durationMinutes: json['duration_minutes'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      serviceName: json['service_name'] as String?, // ← NEW
      workerName: json['worker_name'] as String?, // ← NEW
      startTime:
          json['start_time'] != null
              ? DateTime.parse(json['start_time'] as String)
              : null,
      specialRequirements: json['special_requirements'] as String?,
    );
  }

  /// Converts to JSON for Supabase.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'slot_id': slotId,
      'start_time': startTime?.toIso8601String(),
      'worker_id': workerId,
      'price_at_booking': priceAtBooking,
      'duration_minutes': durationMinutes,
      'worker_name': workerName,
      'service_name': serviceName,
      if (specialRequirements != null && specialRequirements!.isNotEmpty)
        'special_requirements': specialRequirements,
    };
  }

  BookingServiceModel copyWith({
    String? id,
    String? bookingId,
    String? slotId,
    String? workerId,
    double? priceAtBooking,
    int? durationMinutes,
    DateTime? createdAt,
    String? specialRequirements,
    String? serviceName,
    String? workerName,
    String? workerImage,
    DateTime? startTime,
  }) {
    return BookingServiceModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      slotId: slotId ?? this.slotId,
      workerId: workerId ?? this.workerId,
      priceAtBooking: priceAtBooking ?? this.priceAtBooking,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      createdAt: createdAt ?? this.createdAt,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      serviceName: serviceName ?? this.serviceName,
      workerName: workerName ?? this.workerName,
      startTime: startTime ?? this.startTime,
    );
  }

  @override
  List<Object?> get props => [
    id,
    bookingId,
    slotId,
    startTime,
    workerId,
    priceAtBooking,
    durationMinutes,
    workerName,
    serviceName,
    specialRequirements,
  ];
}
