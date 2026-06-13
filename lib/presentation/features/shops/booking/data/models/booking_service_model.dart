// lib/features/booking/data/models/booking_service_model.dart

import 'package:equatable/equatable.dart';
import 'package:nano_embryo/core/utils/money.dart';

class BookingServiceModel extends Equatable {
  final String id;
  final String bookingId;
  final String slotId;
  final String? workerId;

  /// Phase 17: int minor units (kobo). Server returns NUMERIC(12,2) major
  /// units; `parseMoneyMinor` converts at the fromJson boundary.
  final int priceAtBookingMinor;

  final int durationMinutes;
  final DateTime createdAt;
  final DateTime? startTime;
  final String? serviceName;
  final String? workerName;
  final String? specialRequirements;

  const BookingServiceModel({
    required this.id,
    required this.bookingId,
    required this.slotId,
    required this.startTime,
    this.workerId,
    required this.priceAtBookingMinor,
    required this.durationMinutes,
    required this.createdAt,
    this.serviceName,
    this.workerName,
    this.specialRequirements,
  });

  factory BookingServiceModel.fromJson(Map<String, dynamic> json) {
    return BookingServiceModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      slotId: json['slot_id'] as String,
      workerId: json['worker_id'] as String?,
      // Phase 17: NUMERIC major → int minor at the boundary.
      priceAtBookingMinor: parseMoneyMinor(json['price_at_booking'] as num),
      durationMinutes: json['duration_minutes'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      serviceName: json['service_name'] as String?,
      workerName: json['worker_name'] as String?,
      startTime:
          json['start_time'] != null
              ? DateTime.parse(json['start_time'] as String)
              : null,
      specialRequirements: json['special_requirements'] as String?,
    );
  }

  /// Converts to JSON for Supabase. Phase 17: storage stays NUMERIC major
  /// so write back as `kobo / 100`.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'slot_id': slotId,
      'start_time': startTime?.toIso8601String(),
      'worker_id': workerId,
      'price_at_booking': priceAtBookingMinor / 100,
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
    int? priceAtBookingMinor,
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
      priceAtBookingMinor: priceAtBookingMinor ?? this.priceAtBookingMinor,
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
    priceAtBookingMinor,
    durationMinutes,
    workerName,
    serviceName,
    specialRequirements,
  ];
}
