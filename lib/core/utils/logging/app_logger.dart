// lib/core/utils/logging/app_logger.dart
//
// Minimal structured logger. Zero dependencies (pure stdlib + flutter
// foundation).
//
// Why this exists
// ─────────────────
// Repositories and controllers were sprinkled with `print(...)` calls
// that landed user identifiers, error payloads, and Postgrest responses
// straight into the platform console — visible in adb logcat / Xcode
// Console in release builds. Checklist v3.1 4.4 (PII redaction) treats
// that as a P0-U leak.
//
// Contract
//   - In release builds: emits NOTHING. Logger is a hard no-op.
//   - In debug/profile builds: emits one structured line per call, with
//     a redaction pass over the values map. The redaction patterns are
//     conservative; extend `_redactValue` when new categories appear.
//   - Never accepts an exception object directly; callers must build a
//     short `summary` string so the logger doesn't end up doing fragile
//     reflection on third-party types.
//
// Usage
//   AppLogger.warn('wallet.request_withdrawal.duplicate',
//     fields: {'shop_id': shopId, 'amount': amount});
//
//   AppLogger.errorEvent('wallet.repo.unexpected',
//     summary: e.toString(),
//     fields: {'shop_id': shopId});

import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warn, error }

abstract class AppLogger {
  static void debug(String event, {Map<String, Object?> fields = const {}}) =>
      _emit(LogLevel.debug, event, fields, null);

  static void info(String event, {Map<String, Object?> fields = const {}}) =>
      _emit(LogLevel.info, event, fields, null);

  static void warn(String event, {Map<String, Object?> fields = const {}}) =>
      _emit(LogLevel.warn, event, fields, null);

  static void errorEvent(
    String event, {
    required String summary,
    Map<String, Object?> fields = const {},
  }) =>
      _emit(LogLevel.error, event, fields, summary);

  static void _emit(
    LogLevel level,
    String event,
    Map<String, Object?> fields,
    String? summary,
  ) {
    if (kReleaseMode) return;
    final ts = DateTime.now().toUtc().toIso8601String();
    final redacted = <String, Object?>{
      for (final entry in fields.entries)
        entry.key: _redactValue(entry.key, entry.value),
    };
    final summaryPart = summary == null ? '' : ' summary=${_redactFreeform(summary)}';
    debugPrint('[$ts] ${level.name.toUpperCase()} $event $redacted$summaryPart');
  }

  // Conservative PII redaction for known sensitive keys.
  static Object? _redactValue(String key, Object? value) {
    if (value == null) return null;
    final lower = key.toLowerCase();
    if (lower.contains('email')) return _maskEmail(value.toString());
    if (lower.contains('phone')) return _maskTail(value.toString(), keep: 2);
    if (lower.contains('token') ||
        lower.contains('secret') ||
        lower.contains('api_key') ||
        lower.contains('authorization')) {
      return '***';
    }
    if (lower.contains('pan') || lower.contains('card')) {
      return '***';
    }
    // F-P2-2: any free-form string (e.g. fields: {'error': e.toString()})
    // gets the bearer/sk/pk/email pattern sweep so a key called 'error' or
    // 'message' can't smuggle a token or email through verbatim.
    if (value is String) return _redactFreeform(value);
    return value;
  }

  static String _redactFreeform(String s) {
    // Strip bearer tokens, basic-auth blobs, and email-shaped substrings.
    return s
        .replaceAll(RegExp(r'Bearer\s+[A-Za-z0-9._-]+'), 'Bearer ***')
        .replaceAll(RegExp(r'sk_[A-Za-z0-9_-]+'), 'sk_***')
        .replaceAll(RegExp(r'pk_[A-Za-z0-9_-]+'), 'pk_***')
        .replaceAllMapped(
          RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'),
          (m) => _maskEmail(m.group(0)!),
        );
  }

  static String _maskEmail(String s) {
    final at = s.indexOf('@');
    if (at <= 0) return '***';
    final local = s.substring(0, at);
    final domain = s.substring(at);
    final head = local.isNotEmpty ? local[0] : '*';
    return '$head***$domain';
  }

  static String _maskTail(String s, {int keep = 4}) {
    if (s.length <= keep) return '***';
    return '***${s.substring(s.length - keep)}';
  }
}
