import 'package:flutter/foundation.dart';

/// Tiny logging facade so the marketplace feature stops calling `print()`
/// directly. Swap the body for Sentry / Crashlytics / a real logger in
/// production without touching every callsite.
class MarketplaceLogger {
  MarketplaceLogger._();

  static void debug(String message, {Object? error, StackTrace? stack}) {
    if (!kDebugMode) return;
    debugPrint('[marketplace][debug] $message');
    if (error != null) debugPrint('   error: $error');
    if (stack != null) debugPrint('   stack: $stack');
  }

  static void warn(String message, {Object? error, StackTrace? stack}) {
    debugPrint('[marketplace][warn]  $message');
    if (error != null) debugPrint('   error: $error');
    if (stack != null) debugPrint('   stack: $stack');
  }

  static void error(String message, {Object? error, StackTrace? stack}) {
    debugPrint('[marketplace][ERROR] $message');
    if (error != null) debugPrint('   error: $error');
    if (stack != null) debugPrint('   stack: $stack');
    // TODO: forward to Sentry/Crashlytics here.
  }
}
