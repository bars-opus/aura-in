// lib/features/dashboard/data/models/performance_alert.dart
import 'package:equatable/equatable.dart';

/// Alert severity level
enum AlertSeverity {
  info,
  warning,
  critical;

  String get displayName {
    switch (this) {
      case AlertSeverity.info:
        return 'Info';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }
}

/// Alert category
enum AlertCategory {
  cancellationRate,
  noShowRate,
  lowOccupancy,
  highDemand,
  revenueDrop,
  workerAvailability,
  clientChurn;

  String get displayName {
    switch (this) {
      case AlertCategory.cancellationRate:
        return 'Cancellation Rate';
      case AlertCategory.noShowRate:
        return 'No-Show Rate';
      case AlertCategory.lowOccupancy:
        return 'Low Occupancy';
      case AlertCategory.highDemand:
        return 'High Demand';
      case AlertCategory.revenueDrop:
        return 'Revenue Drop';
      case AlertCategory.workerAvailability:
        return 'Worker Availability';
      case AlertCategory.clientChurn:
        return 'Client Churn';
    }
  }
}

/// Performance alert for shop owners
class PerformanceAlert extends Equatable {
  final String id;
  final String shopId;
  final AlertCategory category;
  final AlertSeverity severity;
  final String title;
  final String message;
  final double? currentValue;
  final double? threshold;
  final String? suggestedAction;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const PerformanceAlert({
    required this.id,
    required this.shopId,
    required this.category,
    required this.severity,
    required this.title,
    required this.message,
    this.currentValue,
    this.threshold,
    this.suggestedAction,
    this.isRead = false,
    required this.createdAt,
    this.resolvedAt,
  });
  Map<String, dynamic> toJson() {
    String categoryToString(AlertCategory c) {
      switch (c) {
        case AlertCategory.cancellationRate:
          return 'cancellationRate';
        case AlertCategory.highDemand:
          return 'highDemand';
        case AlertCategory.noShowRate:
          return 'noShowRate';
        case AlertCategory.workerAvailability:
        default:
          return 'workerAvailability';
      }
    }

    String severityToString(AlertSeverity s) {
      switch (s) {
        case AlertSeverity.info:
          return 'info';
        case AlertSeverity.warning:
          return 'warning';
        case AlertSeverity.critical:
          return 'critical';
        default:
          return 'info';
      }
    }

    final map = <String, dynamic>{
      'id': id,
      'shop_id': shopId,
      'category': categoryToString(category),
      'severity': severityToString(severity),
      'title': title,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };

    if (currentValue != null) map['current_value'] = currentValue;
    if (threshold != null) map['threshold'] = threshold;
    if (suggestedAction != null) map['suggested_action'] = suggestedAction;
    if (resolvedAt != null) map['resolved_at'] = resolvedAt!.toIso8601String();

    return map;
  }

  factory PerformanceAlert.fromJson(Map<String, dynamic> json) {
    return PerformanceAlert(
      id: json['id'],
      shopId: json['shop_id'],
      category: _parseCategory(json['category']),
      severity: _parseSeverity(json['severity']),
      title: json['title'],
      message: json['message'],
      currentValue: json['current_value']?.toDouble(),
      threshold: json['threshold']?.toDouble(),
      suggestedAction: json['suggested_action'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      resolvedAt:
          json['resolved_at'] != null
              ? DateTime.parse(json['resolved_at'])
              : null,
    );
  }

  static AlertCategory _parseCategory(String category) {
    switch (category.toLowerCase()) {
      case 'cancellation_rate':
        return AlertCategory.cancellationRate;
      case 'no_show_rate':
        return AlertCategory.noShowRate;
      case 'low_occupancy':
        return AlertCategory.lowOccupancy;
      case 'high_demand':
        return AlertCategory.highDemand;
      case 'revenue_drop':
        return AlertCategory.revenueDrop;
      case 'worker_availability':
        return AlertCategory.workerAvailability;
      case 'client_churn':
        return AlertCategory.clientChurn;
      default:
        return AlertCategory.lowOccupancy;
    }
  }

  static AlertSeverity _parseSeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'info':
        return AlertSeverity.info;
      case 'warning':
        return AlertSeverity.warning;
      case 'critical':
        return AlertSeverity.critical;
      default:
        return AlertSeverity.info;
    }
  }

  @override
  List<Object?> get props => [
    id,
    shopId,
    category,
    severity,
    title,
    message,
    currentValue,
    threshold,
    suggestedAction,
    isRead,
    createdAt,
    resolvedAt,
  ];
}
