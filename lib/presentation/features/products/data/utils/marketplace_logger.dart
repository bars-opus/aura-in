import 'package:flutter/foundation.dart';

/// Severity for log records routed through [MarketplaceLogger].
enum LogLevel { debug, warn, error }

/// Signature for the external sink (Sentry/Crashlytics/etc.).
typedef LogSink = void Function(
  LogLevel level,
  String message, {
  Object? error,
  StackTrace? stack,
});

/// Tiny logging facade so the marketplace feature stops calling `print()`
/// directly and so the error-tracking integration point is a single
/// `setSink` call from app bootstrap — no scattered TODOs.
///
/// Wire Sentry / Crashlytics at app start:
///
///   MarketplaceLogger.setSink((level, msg, {error, stack}) {
///     if (level == LogLevel.error) {
///       Sentry.captureException(error ?? msg, stackTrace: stack);
///     }
///   });
class MarketplaceLogger {
  MarketplaceLogger._();

  static LogSink? _sink;

  /// Install a forwarding sink. Called once from main() (or any DI bootstrap).
  static void setSink(LogSink sink) => _sink = sink;
  static void clearSink() => _sink = null;

  static void debug(String message, {Object? error, StackTrace? stack}) =>
      _log(LogLevel.debug, message, error: error, stack: stack);

  static void warn(String message, {Object? error, StackTrace? stack}) =>
      _log(LogLevel.warn, message, error: error, stack: stack);

  static void error(String message, {Object? error, StackTrace? stack}) =>
      _log(LogLevel.error, message, error: error, stack: stack);

  static void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stack,
  }) {
    // Console (debug builds only for debug-level; warn/error always).
    if (level != LogLevel.debug || kDebugMode) {
      final tag = switch (level) {
        LogLevel.debug => '[marketplace][debug]',
        LogLevel.warn => '[marketplace][warn] ',
        LogLevel.error => '[marketplace][ERROR]',
      };
      debugPrint('$tag $message');
      if (error != null) debugPrint('   error: $error');
      if (stack != null) debugPrint('   stack: $stack');
    }
    // External sink (Sentry/Crashlytics). Failure here must never crash the app.
    final sink = _sink;
    if (sink != null) {
      try {
        sink(level, message, error: error, stack: stack);
      } catch (_) {
        // Sink itself blew up — swallow; logging must not crash.
      }
    }
  }
}
