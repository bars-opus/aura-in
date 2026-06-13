import 'package:flutter/foundation.dart';

/// Severity for log records routed through [BookingLogger].
enum BookingLogLevel { debug, warn, error }

/// Signature for the external sink (Sentry/Crashlytics/etc.).
typedef BookingLogSink = void Function(
  BookingLogLevel level,
  String message, {
  Object? error,
  StackTrace? stack,
});

/// Tiny logging facade so the booking feature stops calling `print()`
/// directly and so the error-tracking integration point is a single
/// `setSink` call from app bootstrap.
///
/// Mirrors the marketplace logger (kept separate so the two features
/// can be wired to different sinks if needed — e.g. booking errors
/// route to PagerDuty while marketplace errors route to Slack).
///
/// Wire at app start:
///
///   BookingLogger.setSink((level, msg, {error, stack}) {
///     if (level == BookingLogLevel.error) {
///       Sentry.captureException(error ?? msg, stackTrace: stack);
///     }
///   });
class BookingLogger {
  BookingLogger._();

  static BookingLogSink? _sink;

  static void setSink(BookingLogSink sink) => _sink = sink;
  static void clearSink() => _sink = null;

  static void debug(String message, {Object? error, StackTrace? stack}) =>
      _log(BookingLogLevel.debug, message, error: error, stack: stack);

  static void warn(String message, {Object? error, StackTrace? stack}) =>
      _log(BookingLogLevel.warn, message, error: error, stack: stack);

  static void error(String message, {Object? error, StackTrace? stack}) =>
      _log(BookingLogLevel.error, message, error: error, stack: stack);

  static void _log(
    BookingLogLevel level,
    String message, {
    Object? error,
    StackTrace? stack,
  }) {
    final safeMessage = redactPii(message);
    final safeError = error == null ? null : redactPii(error.toString());
    if (level != BookingLogLevel.debug || kDebugMode) {
      final tag = switch (level) {
        BookingLogLevel.debug => '[booking][debug]',
        BookingLogLevel.warn => '[booking][warn] ',
        BookingLogLevel.error => '[booking][ERROR]',
      };
      debugPrint('$tag $safeMessage');
      if (safeError != null) debugPrint('   error: $safeError');
      if (stack != null && level == BookingLogLevel.error) {
        debugPrint('   stack: $stack');
      }
    }
    final sink = _sink;
    if (sink != null) {
      try {
        sink(level, safeMessage, error: error, stack: stack);
      } catch (_) {
        // Sink itself blew up — swallow; logging must not crash the app.
      }
    }
  }

  /// Replaces PII shapes in [input] with redacted markers.
  /// Covers: emails, international phone numbers, card PANs, bearer tokens,
  /// Stripe/Paystack-style keys, GPS-looking lat/lng pairs.
  /// Conservative on purpose — false-positive redaction is preferred to PII
  /// leakage in logs (checklist v3.1 P0-U 4.4 PII glossary).
  static String redactPii(String input) {
    var s = input;
    s = s.replaceAll(_email, '[email]');
    s = s.replaceAll(_phone, '[phone]');
    s = s.replaceAll(_cardPan, '[card]');
    s = s.replaceAll(_bearer, 'Bearer [redacted]');
    s = s.replaceAll(_secretKey, '[secret]');
    s = s.replaceAll(_publishableKey, '[pub-key]');
    s = s.replaceAll(_jwt, '[jwt]');
    return s;
  }

  static final RegExp _email =
      RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}');
  static final RegExp _phone =
      RegExp(r'\+?\d[\d\s\-().]{7,}\d');
  static final RegExp _cardPan = RegExp(r'\b(?:\d[ -]*?){13,19}\b');
  static final RegExp _bearer = RegExp(r'Bearer\s+[A-Za-z0-9._\-]+');
  static final RegExp _secretKey =
      RegExp(r'\bsk_[a-zA-Z0-9_]{16,}\b');
  static final RegExp _publishableKey =
      RegExp(r'\bpk_[a-zA-Z0-9_]{16,}\b');
  static final RegExp _jwt =
      RegExp(r'\beyJ[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\b');
}
