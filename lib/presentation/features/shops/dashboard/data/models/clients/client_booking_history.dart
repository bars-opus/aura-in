// lib/features/dashboard/data/models/client_booking_history.dart
import 'package:equatable/equatable.dart';

/// Service within a booking
class ClientBookingService extends Equatable {
  final String id;
  final String name;
  final String? workerName;
  final double price;
  final int durationMinutes;

  const ClientBookingService({
    required this.id,
    required this.name,
    this.workerName,
    required this.price,
    required this.durationMinutes,
  });

  factory ClientBookingService.fromJson(Map<String, dynamic> json) {
    return ClientBookingService(
      id: json['id'],
      name: json['service_name'] ?? json['name'],
      workerName: json['worker_name'],
      price: (json['price'] ?? 0).toDouble(),
      durationMinutes: json['duration_minutes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_name': name,
      'worker_name': workerName,
      'price': price,
      'duration_minutes': durationMinutes,
    };
  }

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
    }
    return '$minutes min';
  }

  @override
  List<Object?> get props => [id, name, workerName, price, durationMinutes];
}

/// Client's booking history item
class ClientBookingHistory extends Equatable {
  final String id;
  final String shopId;
  final String shopName;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final double totalAmount;
  final double depositPaid;
  final List<ClientBookingService> services;

  const ClientBookingHistory({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalAmount,
    required this.depositPaid,
    required this.services,
  });

  factory ClientBookingHistory.fromJson(Map<String, dynamic> json) {
    final services = List<Map<String, dynamic>>.from(
      json['services'] ?? [],
    ).map(ClientBookingService.fromJson).toList();

    return ClientBookingHistory(
      id: json['id'],
      shopId: json['shop_id'],
      shopName: json['shop_name'] ?? '',
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      status: json['status'],
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      depositPaid: (json['deposit_paid'] ?? 0).toDouble(),
      services: services,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'shop_name': shopName,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status,
      'total_amount': totalAmount,
      'deposit_paid': depositPaid,
      'services': services.map((s) => s.toJson()).toList(),
    };
  }

  String get formattedDate {
    return '${startTime.month}/${startTime.day}/${startTime.year}';
  }

  String get formattedTime {
    String _formatTime(DateTime time) {
      final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
    }
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  double get remainingBalance => totalAmount - depositPaid;

  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isConfirmed => status == 'confirmed';
  bool get isPending => status == 'pending';

  @override
  List<Object?> get props => [
    id, shopId, shopName, startTime, endTime, status,
    totalAmount, depositPaid, services
  ];
}

/// Paginated client booking history
class PaginatedClientBookings extends Equatable {
  final List<ClientBookingHistory> bookings;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool hasNextPage;

  const PaginatedClientBookings({
    required this.bookings,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.hasNextPage,
  });

  factory PaginatedClientBookings.fromJson(Map<String, dynamic> json) {
    final bookings = List<Map<String, dynamic>>.from(json['bookings'] ?? [])
        .map(ClientBookingHistory.fromJson)
        .toList();

    return PaginatedClientBookings(
      bookings: bookings,
      totalCount: json['total_count'] ?? 0,
      currentPage: json['current_page'] ?? 1,
      pageSize: json['page_size'] ?? 20,
      hasNextPage: json['has_next_page'] ?? false,
    );
  }

  PaginatedClientBookings copyWith({
    List<ClientBookingHistory>? bookings,
    int? totalCount,
    int? currentPage,
    int? pageSize,
    bool? hasNextPage,
  }) {
    return PaginatedClientBookings(
      bookings: bookings ?? this.bookings,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }

  @override
  List<Object?> get props => [
    bookings, totalCount, currentPage, pageSize, hasNextPage
  ];
}
