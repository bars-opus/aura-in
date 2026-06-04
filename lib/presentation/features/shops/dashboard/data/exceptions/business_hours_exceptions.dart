// lib/presentation/features/shops/dashboard/data/exceptions/business_hours_exceptions.dart
//
// BusinessHoursException hierarchy. Same shape as WalletException and
// PromotionException: every subtype carries a stable `code` so the UI
// can switch on it without parsing English error strings, plus a
// `userMessage` safe to render directly. `message` is internal/debug
// only and MUST NOT reach the UI.

class BusinessHoursException implements Exception {
  /// Internal/debug message. Logs only. May contain ids.
  final String message;

  /// Stable identifier the UI maps to localized copy.
  final String code;

  /// Sanitized, user-facing message safe to show as-is.
  final String userMessage;

  BusinessHoursException(
    this.message, {
    this.code = 'HOURS_GENERIC',
    String? userMessage,
  }) : userMessage = userMessage ?? 'Something went wrong. Please try again.';

  @override
  String toString() => 'BusinessHoursException($code): $message';
}

class InvalidHoursPayloadException extends BusinessHoursException {
  InvalidHoursPayloadException()
      : super(
          'Hours payload failed server-side shape validation',
          code: 'HOURS_INVALID_PAYLOAD',
          userMessage: 'Please re-check your hours for each day.',
        );
}

class DayOfWeekOutOfRangeException extends BusinessHoursException {
  DayOfWeekOutOfRangeException()
      : super(
          'day_of_week out of range 0..7',
          code: 'HOURS_DOW_RANGE',
          userMessage: 'One of the days is not in a valid range.',
        );
}

class HoursNotFoundException extends BusinessHoursException {
  HoursNotFoundException(String shopId)
      : super(
          'Shop not found for hours rebuild: $shopId',
          code: 'HOURS_NOT_FOUND',
          userMessage: "We couldn't find this shop.",
        );
}

class HoursSaveFailedException extends BusinessHoursException {
  HoursSaveFailedException()
      : super(
          'Hours RPC failed (unmapped error)',
          code: 'HOURS_SAVE_FAILED',
          userMessage: "We couldn't save the hours. Please try again.",
        );
}
