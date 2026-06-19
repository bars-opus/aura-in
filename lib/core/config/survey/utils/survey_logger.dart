import 'package:flutter/foundation.dart';

/// Severity for log records routed through [SurveyLogger].
enum SurveyLogLevel { debug, warn, error }

/// Signature for the external sink (Sentry/Crashlytics/etc.).
typedef SurveyLogSink = void Function(
  SurveyLogLevel level,
  String message, {
  Object? error,
  StackTrace? stack,
  Map<String, Object?>? attributes,
});

/// Tiny logging facade so the survey engine has a single integration point
/// for error tracking. Wire Sentry once from app bootstrap:
///
///   SurveyLogger.setSink((level, msg, {error, stack, attributes}) {
///     if (level == SurveyLogLevel.error) {
///       Sentry.captureException(error ?? msg, stackTrace: stack);
///     }
///   });
class SurveyLogger {
  SurveyLogger._();

  static SurveyLogSink? _sink;

  static void setSink(SurveyLogSink sink) => _sink = sink;
  static void clearSink() => _sink = null;

  static void debug(
    String message, {
    Object? error,
    StackTrace? stack,
    Map<String, Object?>? attributes,
  }) => _log(
    SurveyLogLevel.debug,
    message,
    error: error,
    stack: stack,
    attributes: attributes,
  );

  static void warn(
    String message, {
    Object? error,
    StackTrace? stack,
    Map<String, Object?>? attributes,
  }) => _log(
    SurveyLogLevel.warn,
    message,
    error: error,
    stack: stack,
    attributes: attributes,
  );

  static void error(
    String message, {
    Object? error,
    StackTrace? stack,
    Map<String, Object?>? attributes,
  }) => _log(
    SurveyLogLevel.error,
    message,
    error: error,
    stack: stack,
    attributes: attributes,
  );

  static void _log(
    SurveyLogLevel level,
    String message, {
    Object? error,
    StackTrace? stack,
    Map<String, Object?>? attributes,
  }) {
    if (level != SurveyLogLevel.debug || kDebugMode) {
      final tag = switch (level) {
        SurveyLogLevel.debug => '[survey][debug]',
        SurveyLogLevel.warn => '[survey][warn] ',
        SurveyLogLevel.error => '[survey][ERROR]',
      };
      debugPrint('$tag $message');
      if (attributes != null && attributes.isNotEmpty) {
        debugPrint('   attrs: $attributes');
      }
      if (error != null) debugPrint('   error: $error');
      if (stack != null) debugPrint('   stack: $stack');
    }
    final sink = _sink;
    if (sink != null) {
      try {
        sink(level, message, error: error, stack: stack, attributes: attributes);
      } catch (_) {
        // Sink itself blew up — swallow; logging must not crash.
      }
    }
  }
}
