// lib/presentation/features/shops/dashboard/data/exceptions/broadcast_exceptions.dart
//
// Phase 14 — owner broadcast exception hierarchy. Mirrors
// PromotionException's shape: stable `code` + sanitized `userMessage`.
//
// `userMessage` is the EN fallback string baked into the exception. The
// screen layer maps the `code` to a localized string via app_en.arb when
// available; the fallback keeps the DTO testable in isolation and matches
// the Phase 13 PromotionException precedent.

class BroadcastException implements Exception {
  /// Internal/debug message. Logs only. May contain identifiers.
  final String message;

  /// Stable identifier the UI maps to localized copy.
  final String code;

  /// Sanitized, user-facing message safe to show as-is.
  final String userMessage;

  BroadcastException(
    this.message, {
    this.code = 'BROADCAST_GENERIC',
    String? userMessage,
  }) : userMessage = userMessage ?? 'Something went wrong. Please try again.';

  @override
  String toString() => 'BroadcastException($code): $message';
}

class BroadcastRateLimitException extends BroadcastException {
  BroadcastRateLimitException()
      : super(
          'Broadcast 1/UTC-day rate limit hit',
          code: 'BROADCAST_RATE_LIMIT',
          userMessage:
              "You've already sent a broadcast today. Try again tomorrow.",
        );
}

class BroadcastInFlightException extends BroadcastException {
  BroadcastInFlightException()
      : super(
          'Advisory lock contention — another broadcast is being processed',
          code: 'BROADCAST_IN_FLIGHT',
          userMessage:
              'Another broadcast is being processed. Please wait a moment.',
        );
}

class BroadcastInvalidAudienceException extends BroadcastException {
  BroadcastInvalidAudienceException()
      : super(
          'Audience type / param failed server-side validation',
          code: 'BROADCAST_INVALID_AUDIENCE',
          userMessage:
              "Please pick a valid audience and (if 'By service') a service.",
        );
}

class BroadcastPromoInvalidException extends BroadcastException {
  BroadcastPromoInvalidException()
      : super(
          'Attached promo failed re-validation at send time',
          code: 'BROADCAST_PROMO_INVALID',
          userMessage:
              'This code is no longer valid. Pick another or remove the code.',
        );
}

class BroadcastCapExceededException extends BroadcastException {
  BroadcastCapExceededException()
      : super(
          'Audience exceeded the 1000-recipient cap',
          code: 'BROADCAST_CAP_EXCEEDED',
          userMessage:
              'This audience is larger than the 1000-recipient cap. Try a narrower audience.',
        );
}

class BroadcastSaveFailedException extends BroadcastException {
  BroadcastSaveFailedException()
      : super(
          'send_broadcast RPC failed (unmapped error)',
          code: 'BROADCAST_SAVE_FAILED',
          userMessage: 'Could not send broadcast. Please try again.',
        );
}
