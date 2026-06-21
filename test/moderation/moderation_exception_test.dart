import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/moderation/data/moderation_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  PostgrestException make({
    required String message,
    String? hint,
    String code = 'P0001',
  }) {
    return PostgrestException(
      message: message,
      code: code,
      details: null,
      hint: hint,
    );
  }

  group('ModerationException.fromPostgrest', () {
    test('maps every known HINT to its stable code', () {
      const hints = {
        ModerationErrorCode.authRequired: ModerationErrorCode.authRequired,
        ModerationErrorCode.selfBlockNotAllowed:
            ModerationErrorCode.selfBlockNotAllowed,
        ModerationErrorCode.selfReportNotAllowed:
            ModerationErrorCode.selfReportNotAllowed,
        ModerationErrorCode.targetNotFound: ModerationErrorCode.targetNotFound,
        ModerationErrorCode.targetMissing: ModerationErrorCode.targetMissing,
        ModerationErrorCode.targetTypeInvalid:
            ModerationErrorCode.targetTypeInvalid,
        ModerationErrorCode.reasonInvalid: ModerationErrorCode.reasonInvalid,
        ModerationErrorCode.reasonMax300: ModerationErrorCode.reasonMax300,
        ModerationErrorCode.detailsMax1000: ModerationErrorCode.detailsMax1000,
        ModerationErrorCode.idempotencyRequired:
            ModerationErrorCode.idempotencyRequired,
        ModerationErrorCode.rateLimitedHour:
            ModerationErrorCode.rateLimitedHour,
        ModerationErrorCode.rateLimitedTarget:
            ModerationErrorCode.rateLimitedTarget,
      };

      for (final entry in hints.entries) {
        final ex = ModerationException.fromPostgrest(
          make(message: 'something', hint: entry.key),
        );
        expect(ex.code, entry.value, reason: 'hint=${entry.key}');
      }
    });

    test('falls back to message scan when hint is missing', () {
      final ex = ModerationException.fromPostgrest(
        make(message: 'self_block_not_allowed by trigger', hint: null),
      );
      expect(ex.code, ModerationErrorCode.selfBlockNotAllowed);
    });

    test('returns invalid_input when message says so but no specific hint', () {
      final ex = ModerationException.fromPostgrest(
        make(message: 'invalid_input something', hint: null),
      );
      expect(ex.code, ModerationErrorCode.invalidInput);
    });

    test('returns unknown for completely unrecognised error', () {
      final ex = ModerationException.fromPostgrest(
        make(message: 'mystery error', hint: null),
      );
      expect(ex.code, ModerationErrorCode.unknown);
    });

    test('toString includes the code for debug logs', () {
      const ex = ModerationException(ModerationErrorCode.rateLimitedHour);
      expect(ex.toString(), contains(ModerationErrorCode.rateLimitedHour));
    });
  });
}
