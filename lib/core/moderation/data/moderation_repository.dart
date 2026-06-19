import 'dart:async';

import 'package:nano_embryo/core/moderation/data/moderation_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef ModerationLogger = void Function(ModerationLogEvent event);

class ModerationLogEvent {
  final String operation;
  final Duration elapsed;
  final bool success;
  final String? errorCode;

  const ModerationLogEvent({
    required this.operation,
    required this.elapsed,
    required this.success,
    this.errorCode,
  });
}

class ModerationRepository {
  final SupabaseClient _client;
  final Duration _timeout;
  final ModerationLogger? _logger;

  ModerationRepository(
    this._client, {
    Duration timeout = const Duration(seconds: 15),
    ModerationLogger? logger,
  })  : _timeout = timeout,
        _logger = logger;

  Future<List<ModerationBlockRecord>> getBlockedAccounts({
    int limit = 50,
    DateTime? cursorCreatedAt,
  }) {
    return _runRpc('get_blocked_accounts', () async {
      final response = await _client
          .rpc(
            'get_blocked_accounts',
            params: {
              'p_limit': limit,
              'p_cursor_created_at': cursorCreatedAt?.toUtc().toIso8601String(),
            },
          )
          .timeout(_timeout);
      return (response as List<dynamic>)
          .map(
            (json) =>
                ModerationBlockRecord.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    });
  }

  Future<ModerationCheckResult> getBlockStatus(String otherUserId) {
    return _runRpc('is_moderation_blocked', () async {
      final response = await _client
          .rpc(
            'is_moderation_blocked',
            params: {'p_other_user_id': otherUserId},
          )
          .timeout(_timeout);
      return ModerationCheckResult.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    });
  }

  Future<Set<String>> getBlockedUserIds() async {
    final rows = await getBlockedAccounts(limit: 200);
    return rows.map((row) => row.blockedUserId).toSet();
  }

  Future<ModerationActionResult> blockUser({
    required String blockedUserId,
    String? reason,
  }) {
    return _runRpc('block_user', () async {
      final response = await _client
          .rpc(
            'block_user',
            params: {
              'p_blocked_user_id': blockedUserId,
              'p_reason': reason,
            },
          )
          .timeout(_timeout);
      return ModerationActionResult.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    });
  }

  Future<ModerationActionResult> unblockUser({
    required String blockedUserId,
  }) {
    return _runRpc('unblock_user', () async {
      final response = await _client
          .rpc(
            'unblock_user',
            params: {'p_blocked_user_id': blockedUserId},
          )
          .timeout(_timeout);
      return ModerationActionResult.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    });
  }

  Future<ModerationActionResult> submitReport({
    required ModerationTarget target,
    required String reason,
    String? details,
    required String clientIdempotencyKey,
  }) {
    return _runRpc('submit_moderation_report', () async {
      final response = await _client
          .rpc(
            'submit_moderation_report',
            params: {
              'p_target_type': target.targetType.value,
              'p_target_id': target.targetId,
              'p_target_owner_id': target.targetOwnerId,
              'p_reason': reason,
              'p_details': details,
              'p_client_idempotency_key': clientIdempotencyKey,
            },
          )
          .timeout(_timeout);
      return ModerationActionResult.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    });
  }

  Future<T> _runRpc<T>(
    String operation,
    Future<T> Function() action,
  ) async {
    final sw = Stopwatch()..start();
    try {
      final result = await action();
      sw.stop();
      _logger?.call(
        ModerationLogEvent(
          operation: operation,
          elapsed: sw.elapsed,
          success: true,
        ),
      );
      return result;
    } on TimeoutException {
      sw.stop();
      _logger?.call(
        ModerationLogEvent(
          operation: operation,
          elapsed: sw.elapsed,
          success: false,
          errorCode: ModerationErrorCode.timeout,
        ),
      );
      throw const ModerationException(ModerationErrorCode.timeout);
    } on PostgrestException catch (error) {
      sw.stop();
      final exception = ModerationException.fromPostgrest(error);
      _logger?.call(
        ModerationLogEvent(
          operation: operation,
          elapsed: sw.elapsed,
          success: false,
          errorCode: exception.code,
        ),
      );
      throw exception;
    } catch (_) {
      sw.stop();
      _logger?.call(
        ModerationLogEvent(
          operation: operation,
          elapsed: sw.elapsed,
          success: false,
          errorCode: ModerationErrorCode.unknown,
        ),
      );
      rethrow;
    }
  }
}

/// Stable error codes surfaced from the repository.
///
/// Engine UI maps these to user-facing copy via `ModerationTexts`.
class ModerationErrorCode {
  static const String authRequired = 'auth_required';
  static const String selfBlockNotAllowed = 'self_block_not_allowed';
  static const String selfReportNotAllowed = 'self_report_not_allowed';
  static const String targetNotFound = 'target_not_found';
  static const String targetMissing = 'target_missing';
  static const String targetTypeInvalid = 'target_type_invalid';
  static const String reasonInvalid = 'reason_invalid';
  static const String reasonMax300 = 'reason_max_300';
  static const String detailsMax1000 = 'details_max_1000';
  static const String idempotencyRequired = 'idempotency_required';
  static const String rateLimitedHour = 'rate_limited_hour';
  static const String rateLimitedTarget = 'rate_limited_target';
  static const String invalidInput = 'invalid_input';
  static const String timeout = 'timeout';
  static const String unknown = 'unknown';

  const ModerationErrorCode._();
}

class ModerationException implements Exception {
  final String code;

  const ModerationException(this.code);

  factory ModerationException.fromPostgrest(PostgrestException error) {
    final hint = (error.hint ?? '').toLowerCase().trim();
    final message = error.message.toLowerCase();

    // The SQL functions raise with `HINT = '<stable_code>'`. Prefer the hint;
    // fall back to message-substring scan for backwards-compat.
    const knownHints = <String>{
      ModerationErrorCode.authRequired,
      ModerationErrorCode.selfBlockNotAllowed,
      ModerationErrorCode.selfReportNotAllowed,
      ModerationErrorCode.targetNotFound,
      ModerationErrorCode.targetMissing,
      ModerationErrorCode.targetTypeInvalid,
      ModerationErrorCode.reasonInvalid,
      ModerationErrorCode.reasonMax300,
      ModerationErrorCode.detailsMax1000,
      ModerationErrorCode.idempotencyRequired,
      ModerationErrorCode.rateLimitedHour,
      ModerationErrorCode.rateLimitedTarget,
    };

    if (knownHints.contains(hint)) {
      return ModerationException(hint);
    }

    for (final known in knownHints) {
      if (message.contains(known)) {
        return ModerationException(known);
      }
    }

    if (message.contains('invalid_input')) {
      return const ModerationException(ModerationErrorCode.invalidInput);
    }

    return const ModerationException(ModerationErrorCode.unknown);
  }

  @override
  String toString() => 'ModerationException($code)';
}
