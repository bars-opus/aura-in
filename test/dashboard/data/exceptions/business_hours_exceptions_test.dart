// test/dashboard/data/exceptions/business_hours_exceptions_test.dart
//
// Locks the shape contract of the BusinessHoursException hierarchy.
// The UI switches on `code` and renders `userMessage` directly; any
// change here is intentional and should be reviewed against UI copy
// at the same time.

import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/business_hours_exceptions.dart';

void main() {
  group('BusinessHoursException (base)', () {
    test('default code is HOURS_GENERIC', () {
      final e = BusinessHoursException('boom');
      expect(e.code, 'HOURS_GENERIC');
    });

    test('default userMessage is safe to render', () {
      final e = BusinessHoursException('boom');
      expect(e.userMessage, 'Something went wrong. Please try again.');
      expect(e.userMessage, isNot(contains('boom')));
    });

    test('toString embeds code + internal message', () {
      final e = BusinessHoursException('boom');
      expect(e.toString(), 'BusinessHoursException(HOURS_GENERIC): boom');
    });
  });

  group('Subtype contracts', () {
    test('InvalidHoursPayloadException', () {
      final e = InvalidHoursPayloadException();
      expect(e.code, 'HOURS_INVALID_PAYLOAD');
      expect(e.userMessage, 'Please re-check your hours for each day.');
    });

    test('DayOfWeekOutOfRangeException', () {
      final e = DayOfWeekOutOfRangeException();
      expect(e.code, 'HOURS_DOW_RANGE');
      expect(e.userMessage, 'One of the days is not in a valid range.');
    });

    test('HoursNotFoundException keeps shopId out of userMessage', () {
      final e =
          HoursNotFoundException('00000000-0000-0000-0000-000000000001');
      expect(e.code, 'HOURS_NOT_FOUND');
      expect(e.userMessage, "We couldn't find this shop.");
      expect(e.userMessage, isNot(contains('00000000')));
    });

    test('HoursSaveFailedException', () {
      final e = HoursSaveFailedException();
      expect(e.code, 'HOURS_SAVE_FAILED');
      expect(e.userMessage,
          "We couldn't save the hours. Please try again.");
    });
  });
}
