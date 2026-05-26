import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';

void main() {
  group('MapPin', () {
    test('two pins with same fields are equal', () {
      const a = MapPin(
        id: 'shop-1',
        latitude: 6.5244,
        longitude: 3.3792,
        data: {'shop_type': 'salon', 'luxury_level': 'Luxury'},
      );
      const b = MapPin(
        id: 'shop-1',
        latitude: 6.5244,
        longitude: 3.3792,
        data: {'shop_type': 'salon', 'luxury_level': 'Luxury'},
      );

      expect(a, equals(b));
    });

    test('pins differ when data map differs', () {
      const a = MapPin(
        id: 'shop-1',
        latitude: 6.5244,
        longitude: 3.3792,
        data: {'shop_type': 'salon'},
      );
      const b = MapPin(
        id: 'shop-1',
        latitude: 6.5244,
        longitude: 3.3792,
        data: {'shop_type': 'barbershop'},
      );

      expect(a, isNot(equals(b)));
    });

    test('data defaults to empty map', () {
      const pin = MapPin(id: 'x', latitude: 0, longitude: 0);
      expect(pin.data, isEmpty);
    });
  });
}
