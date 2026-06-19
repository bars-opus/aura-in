import 'package:nano_embryo/core/feedback/exceptions/feedback_exceptions.dart';

/// Validates the feedback `type` string against the configured allow-list
/// AND the canonical charset (mirrors the DB CHECK constraint added in
/// 20260614000100_feedback_engine.sql).
///
/// Fails fast client-side so we don't pay a round-trip on a row RLS / DB
/// would have rejected anyway.
class FeedbackTypeValidator {
  static final RegExp _allowed = RegExp(r'^[a-z0-9_]+$');
  static const int maxLength = 64;

  /// Throws [FeedbackValidationException] on bad input.
  static void validate(String type, Iterable<String> allowedKeys) {
    if (type.isEmpty || type.length > maxLength) {
      throw FeedbackValidationException(
        'feedback type must be 1..$maxLength characters',
      );
    }
    if (!_allowed.hasMatch(type)) {
      throw FeedbackValidationException(
        'feedback type must match [a-z0-9_]+ (got "$type")',
      );
    }
    if (!allowedKeys.contains(type)) {
      throw FeedbackValidationException(
        'feedback type "$type" is not in the configured allow-list',
      );
    }
  }
}
