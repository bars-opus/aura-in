import 'package:equatable/equatable.dart';

/// Engine-local lightweight coordinate pair.
///
/// Kept independent of `geolocator.Position` and Mapbox's `Point` so that
/// the engine has no dependency on either when consumers wire in their
/// own location providers.
class LatLng extends Equatable {
  final double latitude;
  final double longitude;

  const LatLng({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}
