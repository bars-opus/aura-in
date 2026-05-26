import 'package:equatable/equatable.dart';

/// Tier-3 fallback used when neither device GPS nor app-location is
/// available. The engine flies the camera here and runs an initial
/// viewport fetch.
class MapFallback extends Equatable {
  final double latitude;
  final double longitude;
  final double initialZoom;

  const MapFallback({
    required this.latitude,
    required this.longitude,
    this.initialZoom = 12.0,
  });

  @override
  List<Object?> get props => [latitude, longitude, initialZoom];
}
