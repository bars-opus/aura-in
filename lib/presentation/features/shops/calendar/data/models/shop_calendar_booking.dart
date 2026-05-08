import 'package:equatable/equatable.dart';

/// Minimal booking model for shop owner calendar view.
/// Contains only what a shop owner needs to see in the calendar list.

class ShopCalendarBooking extends Equatable {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final double totalAmount;
  final String shopCurrency;

  // Client info (minimal)
  final String clientName;
  final String userName; // Changed from shopType to userName
  final String? clientAvatarUrl;

  // First service info (for display)
  final String serviceName;

  const ShopCalendarBooking({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.userName, // Now userName
    required this.totalAmount,
    required this.clientName,
    required this.shopCurrency,
    this.clientAvatarUrl,
    required this.serviceName,
  });

  factory ShopCalendarBooking.fromJson(Map<String, dynamic> json) {
    // Extract client info from nested 'client' object
    final client = json['client'] as Map<String, dynamic>?;

    // Extract shop info for currency
    final shop = json['shop'] as Map<String, dynamic>?; // ← Add this line

    String clientName = 'Client';
    String userName = 'Client';
    String? clientAvatarUrl;
    String shopCurrency = ''; // ← Default value

    if (client != null) {
      clientName = client['display_name'] as String? ?? 'Client';
      userName = client['username'] as String? ?? clientName;
      clientAvatarUrl = client['avatar_url'] as String?;
    }

    // Get currency from shop data
    if (shop != null) {
      shopCurrency = shop['currency'] as String? ?? '';
    }

    // Extract first service name safely
    String serviceName = 'Service';
    try {
      final services = json['booking_services'] as List?;
      if (services != null && services.isNotEmpty) {
        final firstService = services.first as Map<String, dynamic>?;
        if (firstService != null) {
          final slot = firstService['slot'] as Map<String, dynamic>?;
          if (slot != null) {
            serviceName = slot['service_name'] as String? ?? 'Service';
          }
        }
      }
    } catch (e) {
      serviceName = 'Service';
    }

    // Also check if service_name is directly in json (from view)
    if (serviceName == 'Service' && json['service_name'] != null) {
      serviceName = json['service_name'] as String;
    }

    return ShopCalendarBooking(
      id: json['id'] as String? ?? '',
      startTime:
          json['start_time'] != null
              ? DateTime.parse(json['start_time'] as String)
              : DateTime.now(),
      endTime:
          json['end_time'] != null
              ? DateTime.parse(json['end_time'] as String)
              : DateTime.now(),
      status: json['status'] as String? ?? 'pending',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      clientName: clientName,
      userName: userName,
      clientAvatarUrl: clientAvatarUrl,
      serviceName: serviceName,
      shopCurrency: shopCurrency, // ← Now properly defined
    );
  }

  /// Converts the ShopCalendarBooking instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status,
      'total_amount': totalAmount,
      'client': {
        'display_name': clientName,
        'username': userName,
        'currency': shopCurrency,
        'avatar_url': clientAvatarUrl,
      },
      'booking_services': [
        {
          'slot': {'service_name': serviceName},
        },
      ],
    };
  }

  @override
  List<Object?> get props => [
    id,
    startTime,
    endTime,
    status,
    totalAmount,
    clientName,
    userName,
    clientAvatarUrl,
    serviceName,
    shopCurrency,
  ];
}
