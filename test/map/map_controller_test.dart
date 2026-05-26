import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/map/domain/entities/map_bounds.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';
import 'package:nano_embryo/core/map/presentation/controllers/map_controller.dart';

import '_fakes/fake_map_data_source.dart';

void main() {
  group('MapController', () {
    late FakeMapDataSource fake;
    late MapController controller;

    setUp(() {
      fake = FakeMapDataSource();
      controller = MapController(
        dataSource: fake,
        viewportDebounce: const Duration(milliseconds: 50),
        viewportLimit: 100,
        nearbyLimit: 50,
      );
    });

    tearDown(() => controller.dispose());

    test('updateViewport debounces multiple rapid calls into one fetch', () async {
      fake.queueViewport(const [
        MapPin(id: 'a', latitude: 0, longitude: 0),
      ]);

      const bounds = MapBounds(north: 1, south: 0, east: 1, west: 0);

      await controller.updateViewport(bounds, const {'k': 'v1'});
      await controller.updateViewport(bounds, const {'k': 'v2'});
      await controller.updateViewport(bounds, const {'k': 'v3'});

      expect(fake.viewportCalls, 0);

      await Future<void>.delayed(const Duration(milliseconds: 80));

      expect(fake.viewportCalls, 1);
      expect(fake.lastViewportFilters, equals({'k': 'v3'}));
      expect(controller.state.pins.length, 1);
      expect(controller.state.fetchMode, MapFetchMode.browse);
    });

    test('fetchNearby switches mode and records anchor location', () async {
      fake.queueNearby(const [
        MapPin(id: 'b', latitude: 5, longitude: 5),
      ]);

      await controller.fetchNearby(
        latitude: 5.0,
        longitude: 5.0,
        radiusKm: 5.0,
        filters: const {},
        mode: MapFetchMode.deviceGps,
      );

      expect(controller.state.fetchMode, MapFetchMode.deviceGps);
      expect(controller.state.anchorLocation?.latitude, 5.0);
      expect(controller.state.anchorLocation?.longitude, 5.0);
      expect(controller.state.pins.length, 1);
    });

    test('stale fetch is discarded (generation token)', () async {
      fake.queueNearby(const [MapPin(id: 'old', latitude: 0, longitude: 0)]);
      fake.queueNearby(const [MapPin(id: 'new', latitude: 1, longitude: 1)]);

      final firstFuture = controller.fetchNearby(
        latitude: 0,
        longitude: 0,
        radiusKm: 5.0,
        filters: const {},
        mode: MapFetchMode.deviceGps,
      );

      final secondFuture = controller.fetchNearby(
        latitude: 1,
        longitude: 1,
        radiusKm: 5.0,
        filters: const {},
        mode: MapFetchMode.deviceGps,
      );

      await firstFuture;
      await secondFuture;

      expect(controller.state.pins.single.id, 'new');
    });

    test('fetch error populates error and clears loading', () async {
      fake.queueError(Exception('boom'));

      await controller.fetchNearby(
        latitude: 0,
        longitude: 0,
        radiusKm: 5.0,
        filters: const {},
        mode: MapFetchMode.deviceGps,
      );

      expect(controller.state.error, contains('boom'));
      expect(controller.state.isLoading, isFalse);
    });

    test('clearError wipes error without touching pins', () async {
      fake.queueNearby(const [MapPin(id: 'a', latitude: 0, longitude: 0)]);
      await controller.fetchNearby(
        latitude: 0,
        longitude: 0,
        radiusKm: 5.0,
        filters: const {},
        mode: MapFetchMode.deviceGps,
      );

      fake.queueError(Exception('boom'));
      await controller.fetchNearby(
        latitude: 1,
        longitude: 1,
        radiusKm: 5.0,
        filters: const {},
        mode: MapFetchMode.deviceGps,
      );

      // Pins from the first successful fetch must still be there after the
      // failed second fetch and after clearError — the test name says so.
      expect(controller.state.error, isNotNull);
      expect(controller.state.pins.single.id, 'a');
      controller.clearError();
      expect(controller.state.error, isNull);
      expect(controller.state.pins.single.id, 'a');
    });
  });
}
