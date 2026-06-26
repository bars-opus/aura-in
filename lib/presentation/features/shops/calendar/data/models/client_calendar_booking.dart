import 'package:equatable/equatable.dart';
import 'package:nano_embryo/core/utils/money.dart';

/// Minimal booking model for client calendar view.
/// Contains only what a client needs to see in the calendar list.
///
/// Money is stored as int minor units (kobo / cents). The conversion from
/// the NUMERIC(12,2) wire format happens in [fromJson] via
/// [parseMoneyMinor]. Display via `formatMoney(totalAmountMinor, currency)`.
/// Checklist v3.1 P0-U 2.19.
class ClientCalendarBooking extends Equatable {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final int totalAmountMinor;

  // Shop info (minimal)
  final String shopName;
  final String shopType;
  final String shopCurrency;

  final String shopLogoUrl;

  // First service info (for display)
  final String serviceName;

  const ClientCalendarBooking({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalAmountMinor,
    required this.shopName,
    required this.shopType,
    required this.shopCurrency,
    required this.shopLogoUrl,
    required this.serviceName,
  });

  factory ClientCalendarBooking.fromJson(Map<String, dynamic> json) {

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

    // Extract shop info - FIX: Use actual values, not fallback strings
    String shopName = '';
    String shopType = '';
    String shopCurrency = '';
    String? shopLogoUrl;

    try {
      final shop = json['shop'] as Map<String, dynamic>?;
      if (shop != null) {
        shopName = shop['shop_name'] as String? ?? '';
        shopType = shop['shop_type'] as String? ?? '';
        shopCurrency = shop['currency'] as String? ?? '';
        shopLogoUrl = shop['shop_logo_url'] as String?;
      }
    } catch (e) {
      // Keep empty values
    }
    if (shopCurrency.isEmpty) {
      shopCurrency = json['currency'] as String? ?? '';
    }

    // Handle main fields with null safety
    final id = json['id'] as String?;
    if (id == null) {
      throw Exception('Booking ID cannot be null');
    }

    final startTimeStr = json['start_time'] as String?;
    if (startTimeStr == null) {
      throw Exception('start_time cannot be null');
    }

    final endTimeStr = json['end_time'] as String?;
    if (endTimeStr == null) {
      throw Exception('end_time cannot be null');
    }

    final status = json['status'] as String? ?? 'pending';
    final totalAmountMinor = json['total_amount'] == null
        ? 0
        : parseMoneyMinor(json['total_amount'] as num);

    return ClientCalendarBooking(
      id: id,
      startTime: DateTime.parse(startTimeStr),
      endTime: DateTime.parse(endTimeStr),
      status: status,
      totalAmountMinor: totalAmountMinor,
      shopName: shopName.isEmpty ? 'Shop' : shopName, // Only fallback if empty
      shopLogoUrl: shopLogoUrl ?? '',
      serviceName: serviceName,
      shopType: shopType.isEmpty ? 'Salon' : shopType, // Only fallback if empty
      shopCurrency: shopCurrency, // Keep as is, could be empty
    );
  }

  /// Converts the ClientCalendarBooking instance to a JSON map.
  /// Money is emitted as major-unit decimal to match the NUMERIC(12,2)
  /// column type — never as int minor.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(), // Use ISO 8601 for DateTime
      'end_time': endTime.toIso8601String(),
      'status': status,
      'total_amount': totalAmountMinor / 100,
      'shop': {
        'shop_name': shopName,
        'shop_type': shopType,
        'currency': shopCurrency,
        'shop_logo_url': shopLogoUrl,
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
    totalAmountMinor,
    shopName,
    shopType,
    shopLogoUrl,
    serviceName,
    shopCurrency,
  ];
}
