// lib/features/workers/data/models/worker_unavailability_model.dart

import 'package:equatable/equatable.dart';

class WorkerUnavailabilityModel extends Equatable {
  final String id;
  final String workerId;
  final DateTime startTime;
  final DateTime endTime;
  final String? reason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkerUnavailabilityModel({
    required this.id,
    required this.workerId,
    required this.startTime,
    required this.endTime,
    this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkerUnavailabilityModel.fromJson(Map<String, dynamic> json) {
    return WorkerUnavailabilityModel(
      id: json['id'] as String,
      workerId: json['worker_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'worker_id': workerId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if this unavailability period overlaps with a given time range
  bool overlaps(DateTime checkStart, DateTime checkEnd) {
    return checkStart.isBefore(endTime) && checkEnd.isAfter(startTime);
  }

  @override
  List<Object?> get props => [id, workerId, startTime, endTime, reason];
}
