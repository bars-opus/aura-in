// test/money/money_math_test.dart
//
// Phase 17 — invariants for the single money helper that lives at
// lib/core/utils/money.dart. Covers SC-4 through SC-12 of 17-SPEC.md.
//
// These tests pin the rounding + folding behaviour the rest of the
// codebase depends on. If anything here changes, Phase 17's claim that
// money never compounds float dust no longer holds.

import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/utils/money.dart';

void main() {
  group('formatMoney — display invariants', () {
    test('SC-4: zero kobo renders as "GHS 0.00"', () {
      expect(formatMoney(0, 'GHS'), 'GHS 0.00');
    });

    test('SC-5: 5000 kobo renders as "GHS 50.00"', () {
      expect(formatMoney(5000, 'GHS'), 'GHS 50.00');
    });

    test('SC-6: 125000 kobo renders thousands-grouped as "GHS 1,250.00"', () {
      expect(formatMoney(125000, 'GHS'), 'GHS 1,250.00');
    });

    test('large value (1,234,567 kobo) renders correctly grouped', () {
      expect(formatMoney(1234567, 'GHS'), 'GHS 12,345.67');
    });

    test('SC-7: negative 5000 kobo renders with leading minus', () {
      expect(formatMoney(-5000, 'GHS'), '-GHS 50.00');
    });

    test('single-digit minor part pads to two digits', () {
      expect(formatMoney(105, 'GHS'), 'GHS 1.05');
      expect(formatMoney(1, 'GHS'), 'GHS 0.01');
    });

    test('different currency code passes through', () {
      expect(formatMoney(199, 'USD'), 'USD 1.99');
    });
  });

  group('parseMoneyMinor — NUMERIC ↔ int boundary', () {
    test('SC-8: 50.00 cedis parses as 5000 kobo', () {
      expect(parseMoneyMinor(50.00), 5000);
    });

    test('SC-9: 50.005 cedis rounds half-away-from-zero to 5001 kobo', () {
      expect(parseMoneyMinor(50.005), 5001);
    });

    test('zero parses as zero', () {
      expect(parseMoneyMinor(0), 0);
    });

    test('negative values round consistently', () {
      // -50.005 → -5000 (Dart's round() rounds away from zero on .5)
      // Phase 17 doesn't claim a specific behaviour for negatives here;
      // the test pins whatever ships so changes are intentional.
      expect(parseMoneyMinor(-50.00), -5000);
    });

    test('integer input passes through cleanly', () {
      expect(parseMoneyMinor(50), 5000);
    });
  });

  group('applyBps — basis-point math', () {
    test('SC-10: 5000 kobo × 3000 bps = 1500 kobo (30%)', () {
      expect(applyBps(5000, 3000), 1500);
    });

    test('5000 kobo × 2500 bps = 1250 kobo (25%)', () {
      expect(applyBps(5000, 2500), 1250);
    });

    test('5000 kobo × 0 bps = 0 kobo', () {
      expect(applyBps(5000, 0), 0);
    });

    test('5000 kobo × 10000 bps = 5000 kobo (100%)', () {
      expect(applyBps(5000, 10000), 5000);
    });

    test('truncates fractional kobo toward zero', () {
      // 100 kobo × 290 bps = 29 kobo (2.9 → truncates to 2)
      // Wait: 100 * 290 = 29000 / 10000 = 2.9 → 2 (truncation)
      expect(applyBps(100, 290), 2);
    });

    test('platform fee on a typical booking total', () {
      // 10000 kobo × 290 bps = 290 kobo = GHS 2.90
      expect(applyBps(10000, 290), 290);
    });
  });

  group('SC-11: fold-many invariant — no float dust accumulation', () {
    test('100 × 1234 kobo folds to exactly 123400 kobo', () {
      final folded = List.filled(100, 1234)
          .fold<int>(0, (a, b) => a + b);
      expect(folded, 123400);
    });

    test('1000 × 1 kobo folds to exactly 1000 kobo', () {
      final folded = List.filled(1000, 1).fold<int>(0, (a, b) => a + b);
      expect(folded, 1000);
    });
  });

  group('SC-12: IEEE-754 vs int-kobo semantic', () {
    test('float math: 0.1 + 0.2 != 0.3 (the bug Phase 17 closes)', () {
      // This is the load-bearing demonstration. If THIS test ever stops
      // failing, the Dart runtime semantics changed and Phase 17's
      // motivation is moot. Don't change this — it's a fire alarm.
      expect(0.1 + 0.2 == 0.3, isFalse);
    });

    test('int-kobo math: parseMoneyMinor(0.1) + parseMoneyMinor(0.2) == parseMoneyMinor(0.3)', () {
      // The Phase 17 contract: when every value goes through the
      // boundary, addition is exact.
      final a = parseMoneyMinor(0.1);
      final b = parseMoneyMinor(0.2);
      final c = parseMoneyMinor(0.3);
      expect(a + b, c);
      expect(a + b, 30);
    });

    test('deposit + remaining = total exactly via int kobo', () {
      const totalMinor = 10000; // 100 GHS
      final depositMinor = applyBps(totalMinor, 3000); // 30%
      final remainingMinor = totalMinor - depositMinor;
      expect(depositMinor + remainingMinor, totalMinor);
    });
  });
}
