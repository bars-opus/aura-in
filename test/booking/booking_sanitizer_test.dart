import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/utils/booking_sanitizer.dart';

void main() {
  group('BookingSanitizer.clean', () {
    test('returns null for null input', () {
      expect(BookingSanitizer.clean(null), isNull);
    });

    test('returns null for whitespace-only input', () {
      expect(BookingSanitizer.clean('   '), isNull);
      expect(BookingSanitizer.clean('\n\t  '), isNull);
    });

    test('trims surrounding whitespace', () {
      expect(BookingSanitizer.clean('   hello   '), 'hello');
    });

    test('strips zero-width space (U+200B)', () {
      final zws = String.fromCharCode(0x200B);
      expect(BookingSanitizer.clean('hi${zws}there'), 'hithere');
    });

    test('strips bidi override (U+202E) — the spoofing vector', () {
      final rlo = String.fromCharCode(0x202E);
      expect(BookingSanitizer.clean('safe${rlo}admin.exe'), 'safeadmin.exe');
    });

    test('strips BOM (U+FEFF)', () {
      final bom = String.fromCharCode(0xFEFF);
      expect(BookingSanitizer.clean('${bom}hello'), 'hello');
    });

    test('strips word joiner (U+2060)', () {
      final wj = String.fromCharCode(0x2060);
      expect(BookingSanitizer.clean('a${wj}b'), 'ab');
    });

    test('strips C0 control chars but preserves TAB / LF / CR', () {
      final nul = String.fromCharCode(0x00);
      final bs = String.fromCharCode(0x08);
      expect(BookingSanitizer.clean('a${nul}b${bs}c'), 'abc');
      expect(BookingSanitizer.clean('line1\nline2\tcol3\rfoo'),
          'line1\nline2\tcol3\rfoo');
    });

    test('strips DEL (U+007F) and C1 controls', () {
      final del = String.fromCharCode(0x7F);
      final c1 = String.fromCharCode(0x9F);
      expect(BookingSanitizer.clean('a${del}b${c1}c'), 'abc');
    });

    test('preserves unicode letters and base emoji code points', () {
      // Note: complex emoji *compounds* that rely on ZWJ (U+200D) like
      // 💇‍♀️ (haircut + ZWJ + female) will have the joiner stripped —
      // that's intentional: ZWJ is in the [0x200B, 0x200F] spoofing
      // range. The trade-off favors security over emoji fidelity for
      // user-typed text fields like cancellation_reason and address.
      expect(BookingSanitizer.clean('Olúwáṣẹ́yí Lagos'), 'Olúwáṣẹ́yí Lagos');
      expect(BookingSanitizer.clean('thanks 🙏'), 'thanks 🙏');
    });

    test('strips ZWJ (U+200D) so emoji compounds collapse — intentional', () {
      final zwj = String.fromCharCode(0x200D);
      // 💇 + ZWJ + ♀ + variation selector. After stripping ZWJ, the two
      // base code points stand apart instead of rendering as one emoji.
      expect(BookingSanitizer.clean('a${zwj}b'), 'ab');
    });
  });

  group('BookingSanitizer.cleanAndCap', () {
    test('returns null for null', () {
      expect(BookingSanitizer.cleanAndCap(null, 10), isNull);
    });

    test('passes through short strings unchanged', () {
      expect(BookingSanitizer.cleanAndCap('hi', 10), 'hi');
    });

    test('truncates strings longer than the cap', () {
      final long = 'x' * 50;
      expect(BookingSanitizer.cleanAndCap(long, 10), 'xxxxxxxxxx');
    });

    test('cleans first, then caps (control chars do not consume the budget)', () {
      final zws = String.fromCharCode(0x200B);
      final input = 'abc${zws}def${zws}ghi';
      // After cleaning: 'abcdefghi' (9 chars). Cap=9 should pass through.
      expect(BookingSanitizer.cleanAndCap(input, 9), 'abcdefghi');
      // Cap=5 truncates the cleaned form.
      expect(BookingSanitizer.cleanAndCap(input, 5), 'abcde');
    });

    test('returns null for whitespace-only input', () {
      expect(BookingSanitizer.cleanAndCap('   ', 100), isNull);
    });
  });

  group('BookingSanitizer.isValidCoordinate', () {
    test('rejects nulls', () {
      expect(BookingSanitizer.isValidCoordinate(null, null), isFalse);
      expect(BookingSanitizer.isValidCoordinate(0.0, null), isFalse);
      expect(BookingSanitizer.isValidCoordinate(null, 0.0), isFalse);
    });

    test('rejects out-of-range latitudes', () {
      expect(BookingSanitizer.isValidCoordinate(90.1, 0.0), isFalse);
      expect(BookingSanitizer.isValidCoordinate(-90.1, 0.0), isFalse);
    });

    test('rejects out-of-range longitudes', () {
      expect(BookingSanitizer.isValidCoordinate(0.0, 180.1), isFalse);
      expect(BookingSanitizer.isValidCoordinate(0.0, -180.1), isFalse);
    });

    test('rejects the (0,0) null-island footgun', () {
      expect(BookingSanitizer.isValidCoordinate(0.0, 0.0), isFalse);
    });

    test('accepts valid coordinates inside bounds', () {
      // Lagos, Nigeria
      expect(BookingSanitizer.isValidCoordinate(6.5244, 3.3792), isTrue);
      // Cape Town (negative lat)
      expect(BookingSanitizer.isValidCoordinate(-33.9249, 18.4241), isTrue);
      // Hawaii (negative lng)
      expect(BookingSanitizer.isValidCoordinate(21.3069, -157.8583), isTrue);
    });

    test('accepts boundary coordinates', () {
      expect(BookingSanitizer.isValidCoordinate(90.0, 180.0), isTrue);
      expect(BookingSanitizer.isValidCoordinate(-90.0, -180.0), isTrue);
    });
  });

  group('BookingSanitizer caps match DB CHECK constraints', () {
    // These constants must stay synchronized with
    // supabase/migrations/20260517020000_booking_hardening.sql. Any
    // change to one must change the other in the same commit.
    test('cancellationReason cap matches DB (500)', () {
      expect(BookingSanitizer.maxCancellationReason, 500);
    });
    test('address cap matches DB (500)', () {
      expect(BookingSanitizer.maxAddress, 500);
    });
    test('specialRequirements cap matches DB (1000)', () {
      expect(BookingSanitizer.maxSpecialRequirements, 1000);
    });
    test('serviceName cap matches DB (200)', () {
      expect(BookingSanitizer.maxServiceName, 200);
    });
    test('workerName cap matches DB (200)', () {
      expect(BookingSanitizer.maxWorkerName, 200);
    });
  });
}
