import 'package:equatable/equatable.dart';

/// Axis-aligned bounding box for viewport queries on the map.
class MapBounds extends Equatable {
  final double north;
  final double south;
  final double east;
  final double west;

  const MapBounds({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });

  bool isValid() => north > south && east > west;

  @override
  List<Object?> get props => [north, south, east, west];
}
