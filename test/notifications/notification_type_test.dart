// test/features/notifications/domain/entities/notification_type_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/notifications/domain/entities/notification_type.dart';

void main() {
  group('NotificationType', () {
    test('should create with required value', () {
      final type = NotificationType(value: 'test_type');
      expect(type.value, 'test_type');
      expect(type.priority, 5); // default priority
    });

    test('should create with custom priority', () {
      final type = NotificationType(value: 'high_priority', priority: 10);
      expect(type.priority, 10);
    });

    test('should be equal when values match', () {
      final type1 = NotificationType(value: 'same');
      final type2 = NotificationType(value: 'same');
      expect(type1, type2);
    });

    test('should not be equal when values differ', () {
      final type1 = NotificationType(value: 'type1');
      final type2 = NotificationType(value: 'type2');
      expect(type1, isNot(type2));
    });
  });
}
