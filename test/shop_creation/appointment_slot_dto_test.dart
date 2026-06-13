import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';

AppointmentSlotDTO _dto({
  String id = 'svc-1',
  int price = 5000,
}) {
  return AppointmentSlotDTO(
    id: id,
    serviceName: 'Haircut',
    serviceType: null,
    duration: '30 minutes',
    price: price,
    slotType: 'regular',
    maxClients: 1,
    daysOfWeek: const [1, 2, 3, 4, 5],
    selectPreferredWorker: false,
    workerIds: const [],
    bufferMinutes: 0,
  );
}

void main() {
  group('AppointmentSlotDTO.price — integer minor units', () {
    test('round-trips through toJson / fromJson unchanged', () {
      final dto = _dto(price: 5000);
      final json = dto.toJson();
      final restored = AppointmentSlotDTO.fromJson(json);
      expect(restored.price, 5000);
    });

    test('fromJson truncates fractional minor-units via round()', () {
      final json = {
        'id': 'svc-1',
        'service_name': 'Haircut',
        'service_type': null,
        'duration': '30 minutes',
        'price': 49.9,
        'slot_type': 'regular',
        'max_clients': 1,
        'days_of_week': [1, 2, 3, 4, 5],
        'select_preferred_worker': false,
        'worker_ids': <String>[],
        'buffer_minutes': 0,
      };
      final dto = AppointmentSlotDTO.fromJson(json);
      expect(dto.price, 50); // rounds to nearest integer
    });

    test('zero price is stored as 0', () {
      final dto = _dto(price: 0);
      expect(dto.toJson()['price'], 0);
    });
  });

  group('AppointmentSlotDTO equality and copying', () {
    test('two DTOs with the same data are equal', () {
      final a = _dto();
      final b = _dto();
      expect(a, b);
    });

    test('different IDs produce different DTOs', () {
      final a = _dto(id: 'svc-1');
      final b = _dto(id: 'svc-2');
      expect(a, isNot(b));
    });
  });
}
