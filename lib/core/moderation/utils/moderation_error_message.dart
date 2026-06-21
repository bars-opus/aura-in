import 'package:nano_embryo/core/moderation/config/moderation_texts.dart';
import 'package:nano_embryo/core/moderation/data/moderation_repository.dart';

/// Maps a thrown [error] (typically a [ModerationException]) to user-facing copy.
String moderationErrorMessage(ModerationTexts texts, Object error) {
  if (error is! ModerationException) {
    return texts.actionFailed;
  }

  return switch (error.code) {
    ModerationErrorCode.authRequired => texts.authRequired,
    ModerationErrorCode.selfBlockNotAllowed => texts.selfBlockNotAllowed,
    ModerationErrorCode.selfReportNotAllowed => texts.selfReportNotAllowed,
    ModerationErrorCode.targetNotFound => texts.targetNotFound,
    ModerationErrorCode.targetMissing => texts.targetNotFound,
    ModerationErrorCode.targetTypeInvalid => texts.invalidInput,
    ModerationErrorCode.reasonInvalid => texts.reasonRequired,
    ModerationErrorCode.reasonMax300 => texts.blockReasonTooLong,
    ModerationErrorCode.detailsMax1000 => texts.detailsTooLong,
    ModerationErrorCode.idempotencyRequired => texts.actionFailed,
    ModerationErrorCode.rateLimitedHour => texts.rateLimitedHour,
    ModerationErrorCode.rateLimitedTarget => texts.rateLimitedTarget,
    ModerationErrorCode.timeout => texts.timeout,
    ModerationErrorCode.invalidInput => texts.invalidInput,
    _ => texts.actionFailed,
  };
}
