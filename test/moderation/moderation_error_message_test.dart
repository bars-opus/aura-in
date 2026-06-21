import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/moderation/config/moderation_texts.dart';
import 'package:nano_embryo/core/moderation/data/moderation_repository.dart';
import 'package:nano_embryo/core/moderation/utils/moderation_error_message.dart';

void main() {
  const texts = ModerationTexts();

  String message(String code) =>
      moderationErrorMessage(texts, ModerationException(code));

  group('moderationErrorMessage', () {
    test('every stable code routes to a non-fallback string', () {
      const codes = [
        ModerationErrorCode.authRequired,
        ModerationErrorCode.selfBlockNotAllowed,
        ModerationErrorCode.selfReportNotAllowed,
        ModerationErrorCode.targetNotFound,
        ModerationErrorCode.targetMissing,
        ModerationErrorCode.reasonMax300,
        ModerationErrorCode.detailsMax1000,
        ModerationErrorCode.rateLimitedHour,
        ModerationErrorCode.rateLimitedTarget,
        ModerationErrorCode.timeout,
      ];

      for (final code in codes) {
        final msg = message(code);
        expect(msg, isNotEmpty, reason: 'code=$code');
        // Specific codes should not fall through to the generic actionFailed.
        expect(
          msg,
          isNot(equals(texts.actionFailed)),
          reason: 'code=$code should map to a specific string',
        );
      }
    });

    test('reason_invalid surfaces the reasonRequired prompt', () {
      expect(
        message(ModerationErrorCode.reasonInvalid),
        texts.reasonRequired,
      );
    });

    test('rate_limited_hour and rate_limited_target are distinct', () {
      expect(
        message(ModerationErrorCode.rateLimitedHour),
        isNot(equals(message(ModerationErrorCode.rateLimitedTarget))),
      );
    });

    test('unknown code falls back to actionFailed', () {
      expect(
        message(ModerationErrorCode.unknown),
        texts.actionFailed,
      );
    });

    test('non-ModerationException error falls back to actionFailed', () {
      expect(
        moderationErrorMessage(texts, Exception('boom')),
        texts.actionFailed,
      );
    });
  });
}
