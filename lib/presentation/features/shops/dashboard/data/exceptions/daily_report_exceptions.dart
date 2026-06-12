// lib/presentation/features/shops/dashboard/data/exceptions/daily_report_exceptions.dart
//
// Phase 16 — typed exception hierarchy for the daily-report RPCs.
// Mirrors PricingOverrideException's shape: stable `code` + sanitized
// `userMessage`. The screen layer maps `code` to a localized string via
// app_en.arb; the fallback keeps the DTO testable.

class DailyReportException implements Exception {
  /// Internal/debug message. Logs only. May contain identifiers.
  final String message;

  /// Stable identifier the UI maps to localized copy.
  final String code;

  /// Sanitized, user-facing message safe to show as-is.
  final String userMessage;

  DailyReportException(
    this.message, {
    this.code = 'REPORT_GENERIC',
    String? userMessage,
  }) : userMessage = userMessage ?? 'Something went wrong. Please try again.';

  @override
  String toString() => 'DailyReportException($code): $message';
}

class ReportAccessDeniedException extends DailyReportException {
  ReportAccessDeniedException()
      : super(
          'Caller does not own the parent shop (42501 / OWNER_NOT_FOUND)',
          code: 'REPORT_NOT_FOUND',
          userMessage: "We couldn't find that report.",
        );
}

class ReportDateInvalidException extends DailyReportException {
  ReportDateInvalidException()
      : super(
          'Report date is in the future or > 365 days ago',
          code: 'REPORT_DATE_INVALID',
          userMessage: 'That date is out of range.',
        );
}

class ReportNotFoundException extends DailyReportException {
  ReportNotFoundException()
      : super(
          'No report exists for this date',
          code: 'REPORT_NOT_FOUND',
          userMessage: 'No report yet for that date.',
        );
}

class ReportGenerationFailedException extends DailyReportException {
  ReportGenerationFailedException()
      : super(
          'Server failed to generate the report (REPORT_RPC_FAILED)',
          code: 'REPORT_RPC_FAILED',
          userMessage: "We couldn't build the report. Please try again.",
        );
}
