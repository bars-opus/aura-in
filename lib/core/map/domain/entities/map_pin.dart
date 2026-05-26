import 'package:equatable/equatable.dart';

/// Universal map entity. Replaces per-app DTOs (`ShopLocationDTO`,
/// future `EventLocationDTO`, etc.).
///
/// App-specific fields go in [data] — read with `pin.data['shop_type']`
/// from the resolver/tap callback in your `MapConfig`. Mirrors the
/// `ScheduledNotification.metadata` pattern from the notification engine.
///
/// Equality note: `data` participates in `props`, so two pins compare
/// equal only when their `data` maps compare equal. Dart's `Map.==` is
/// reference-based for non-const maps and value-based only for const
/// canonicalized maps. In practice the engine identifies pins by [id]
/// (markers are tracked by `pin.id`), so non-const data maps don't cause
/// problems. If you need value-based equality of `MapPin`, ensure your
/// data maps are const or compose them through a wrapper that overrides
/// `==`.
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
