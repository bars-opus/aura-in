/// Base exception for survey-engine errors.
class SurveyException implements Exception {
  final String message;
  final String? code;

  SurveyException(this.message, {this.code});

  @override
  String toString() =>
      'SurveyException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Thrown when a Postgres / network call fails.
class SurveyDatabaseException extends SurveyException {
  SurveyDatabaseException(super.message, {super.code});
}

/// Thrown when the caller is not authenticated.
class SurveyAuthException extends SurveyException {
  SurveyAuthException(super.message, {super.code});
}

/// Thrown when a network call exceeds its configured deadline.
class SurveyTimeoutException extends SurveyException {
  SurveyTimeoutException(super.message);
}

/// Thrown when the caller passes a featureKey that fails client-side validation
/// (length, charset). Mirrors the DB CHECK constraints so we fail fast without
/// a round-trip.
class SurveyValidationException extends SurveyException {
  SurveyValidationException(super.message);
}
