import 'package:flutter/foundation.dart';

enum FeedbackLogLevel { debug, warn, error }

typedef FeedbackLogSink = void Function(
  FeedbackLogLevel level,
  String message, {
  Object? error,
  StackTrace? stack,
  Map<String, Object?>? attributes,
});

/// Tiny logging facade so the feedback engine has a single integration point
/// for error tracking. Wire Sentry once from app bootstrap:
///
///   FeedbackLogger.setSink((level, msg, {error, stack, attributes}) {
///     if (level == FeedbackLogLevel.error) {
///       Sentry.captureException(error ?? msg, stackTrace: stack);
///     }
///   });
class FeedbackLogger {
  FeedbackLogger._();

  static FeedbackLogSink? _sink;

  static void setSink(FeedbackLogSink sink) => _sink = sink;
  static void clearSink() => _sink = null;

  static void debug(
    String message, {
    Object? error,
    StackTrace? stack,
    Map<String, Object?>? attributes,
  }) => _log(
    FeedbackLogLevel.debug,
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
    FeedbackLogLevel.warn,
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
    FeedbackLogLevel.error,
    message,
    error: error,
    stack: stack,
    attributes: attributes,
  );

  static void _log(
    FeedbackLogLevel level,
    String message, {
    Object? error,
    StackTrace? stack,
    Map<String, Object?>? attributes,
  }) {
    if (level != FeedbackLogLevel.debug || kDebugMode) {
      final tag = switch (level) {
        FeedbackLogLevel.debug => '[feedback][debug]',
        FeedbackLogLevel.warn => '[feedback][warn] ',
        FeedbackLogLevel.error => '[feedback][ERROR]',
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
