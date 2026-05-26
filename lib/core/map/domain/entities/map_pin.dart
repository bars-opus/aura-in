import 'package:equatable/equatable.dart';

/// Universal map entity. Replaces per-app DTOs (`ShopLocationDTO`,
/// future `EventLocationDTO`, etc.).
///
/// App-specific fields go in [data] — read with `pin.data['shop_type']`
/// from the resolver/tap callback in your `MapConfig`. Mirrors the
/// `ScheduledNotification.metadata` pattern from the notification engine.
class MapPin extends Equatable {
  final String id;
  final double latitude;
  final double longitude;
  final Map<String, dynamic> data;

  const MapPin({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.data = const {},
  });

  @override
  List<Object?> get props => [id, latitude, longitude, data];
}
