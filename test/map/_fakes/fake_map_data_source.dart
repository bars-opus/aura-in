import 'package:nano_embryo/core/map/domain/data_source/map_data_source.dart';
import 'package:nano_embryo/core/map/domain/entities/map_bounds.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';

/// In-memory MapDataSource for unit tests.
///
/// Records every call and returns the queued response (or throws the queued
/// error). Use [queueViewport] / [queueNearby] / [queueError] to script
/// behaviour. Defaults to returning an empty list.
class FakeMapDataSource implements MapDataSource {
  final List<List<MapPin>> _viewportQueue = [];
  final List<List<MapPin>> _nearbyQueue = [];
  Object? _nextError;

  int viewportCalls = 0;
  int nearbyCalls = 0;
  Map<String, dynamic> lastViewportFilters = const {};
  Map<String, dynamic> lastNearbyFilters = const {};

  void queueViewport(List<MapPin> pins) => _viewportQueue.add(pins);
  void queueNearby(List<MapPin> pins) => _nearbyQueue.add(pins);
  void queueError(Object error) => _nextError = error;

  @override
  Future<List<MapPin>> fetchInViewport({
    required MapBounds bounds,
    required Map<String, dynamic> filters,
    int limit = 100,
  }) async {
    viewportCalls++;
    lastViewportFilters = filters;
    if (_nextError != null) {
      final e = _nextError!;
      _nextError = null;
      throw e;
    }
    if (_viewportQueue.isEmpty) return const [];
    return _viewportQueue.removeAt(0);
  }

  @override
  Future<List<MapPin>> fetchNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
    required Map<String, dynamic> filters,
    int limit = 50,
  }) async {
    nearbyCalls++;
    lastNearbyFilters = filters;
    if (_nextError != null) {
      final e = _nextError!;
      _nextError = null;
      throw e;
    }
    if (_nearbyQueue.isEmpty) return const [];
    return _nearbyQueue.removeAt(0);
  }
}
