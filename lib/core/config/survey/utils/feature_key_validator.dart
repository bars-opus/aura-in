import 'package:nano_embryo/core/config/survey/exceptions/survey_exceptions.dart';

/// Mirrors the DB CHECK constraints on `feature_survey_responses.feature_key`:
/// length 1..64 and `^[a-z0-9_]+$`. Fails fast client-side so we don't waste
/// a network round-trip on rows that RLS would have rejected anyway.
class FeatureKeyValidator {
  static final RegExp _allowed = RegExp(r'^[a-z0-9_]+$');
  static const int maxLength = 64;

  /// Throws [SurveyValidationException] on bad input. Idempotent — call as
  /// many times as needed.
  static void validate(String key) {
    if (key.isEmpty || key.length > maxLength) {
      throw SurveyValidationException(
        'featureKey must be 1..$maxLength characters',
      );
    }
    if (!_allowed.hasMatch(key)) {
      throw SurveyValidationException(
        'featureKey must match [a-z0-9_]+ (got "$key")',
      );
    }
  }
}
