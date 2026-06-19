/// Base exception for feedback-engine errors.
class FeedbackException implements Exception {
  final String message;
  final String? code;

  FeedbackException(this.message, {this.code});

  @override
  String toString() =>
      'FeedbackException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Thrown when a Postgres / network call fails.
class FeedbackDatabaseException extends FeedbackException {
  FeedbackDatabaseException(super.message, {super.code});
}

/// Thrown when the caller is not authenticated.
class FeedbackAuthException extends FeedbackException {
  FeedbackAuthException(super.message, {super.code});
}

/// Thrown when a validation rule (length, type, etc.) fails.
class FeedbackValidationException extends FeedbackException {
  FeedbackValidationException(super.message);
}

/// Thrown when a screenshot upload fails.
class FeedbackStorageException extends FeedbackException {
  FeedbackStorageException(super.message);
}

/// Thrown when a network call exceeds its configured deadline (after retries).
class FeedbackTimeoutException extends FeedbackException {
  FeedbackTimeoutException(super.message);
}
