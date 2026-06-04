// test/dashboard/lost_booking_thresholds_test.dart
//
// Unit tests for LostBookingThresholds.classify boundaries (Task 7.2).
// Locks the load-bearing <= operator semantics: any drift between this
// test and the implementation in lost_booking_thresholds.dart is a bug.

import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_thresholds.dart';

void main() {
  group('LostBookingThresholds.classify', () {
    test('null rate => healthy (no data is not alarming)', () {
      expect(
        LostBookingThresholds.classify(null),
        LostBookingSeverity.healthy,
      );
    });

    test('rate well below healthyMax => healthy', () {
      expect(
        LostBookingThresholds.classify(0.0),
        LostBookingSeverity.healthy,
      );
      expect(
        LostBookingThresholds.classify(0.069),
        LostBookingSeverity.healthy,
      );
    });

    test('rate exactly at healthyMax (0.07) => healthy (inclusive)', () {
      expect(
        LostBookingThresholds.classify(0.07),
        LostBookingSeverity.healthy,
      );
    });

    test('rate just above healthyMax => watch', () {
      expect(
        LostBookingThresholds.classify(0.0701),
        LostBookingSeverity.watch,
      );
    });

    test('rate exactly at watchMax (0.12) => watch (inclusive)', () {
      expect(
        LostBookingThresholds.classify(0.12),
        LostBookingSeverity.watch,
      );
    });

    test('rate just above watchMax => hot', () {
      expect(
        LostBookingThresholds.classify(0.1201),
        LostBookingSeverity.hot,
      );
    });

    test('rate well above watchMax => hot', () {
      expect(
        LostBookingThresholds.classify(0.25),
        LostBookingSeverity.hot,
      );
      expect(
        LostBookingThresholds.classify(1.0),
        LostBookingSeverity.hot,
      );
    });

    test('thresholds match their documented values', () {
      // Catches accidental constant edits — the test file is the
      // canonical reference for "what is the threshold".
      expect(LostBookingThresholds.healthyMax, 0.07);
      expect(LostBookingThresholds.watchMax, 0.12);
    });
  });
}
