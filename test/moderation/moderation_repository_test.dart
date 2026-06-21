import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nano_embryo/core/moderation/data/moderation_models.dart';
import 'package:nano_embryo/core/moderation/data/moderation_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _FakeFilterBuilder extends Fake implements PostgrestFilterBuilder<dynamic> {
  _FakeFilterBuilder(this._future);

  final Future<dynamic> _future;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(dynamic value) onValue, {
    Function? onError,
  }) {
    return _future.then(onValue, onError: onError);
  }

  @override
  Stream<dynamic> asStream() => Stream.fromFuture(_future);

  @override
  Future<dynamic> catchError(
    Function onError, {
    bool Function(Object error)? test,
  }) =>
      _future.catchError(onError, test: test);

  @override
  Future<dynamic> timeout(
    Duration timeLimit, {
    FutureOr<dynamic> Function()? onTimeout,
  }) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<dynamic> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);
}

void main() {
  late _MockSupabaseClient client;
  late List<ModerationLogEvent> log;

  setUp(() {
    client = _MockSupabaseClient();
    log = [];
  });

  ModerationRepository makeRepo({
    Duration timeout = const Duration(seconds: 5),
  }) {
    return ModerationRepository(
      client,
      timeout: timeout,
      logger: log.add,
    );
  }

  group('getBlockStatus', () {
    test('parses jsonb result and logs success', () async {
      when(
        () => client.rpc(
          'is_moderation_blocked',
          params: any(named: 'params'),
        ),
      ).thenAnswer(
        (_) => _FakeFilterBuilder(
          Future.value({
            'is_blocked': true,
            'is_blocked_by_current_user': true,
            'is_blocking_current_user': false,
          }),
        ),
      );

      final result = await makeRepo().getBlockStatus('user-2');

      expect(result.isBlocked, isTrue);
      expect(result.isBlockedByCurrentUser, isTrue);
      expect(result.isBlockingCurrentUser, isFalse);
      expect(log, hasLength(1));
      expect(log.first.operation, 'is_moderation_blocked');
      expect(log.first.success, isTrue);
      expect(log.first.errorCode, isNull);
    });
  });

  group('blockUser', () {
    test('parses {success: true} and logs success', () async {
      when(
        () => client.rpc('block_user', params: any(named: 'params')),
      ).thenAnswer(
        (_) => _FakeFilterBuilder(Future.value({'success': true})),
      );

      final result = await makeRepo().blockUser(blockedUserId: 'user-2');

      expect(result.success, isTrue);
      expect(log.single.operation, 'block_user');
      expect(log.single.success, isTrue);
    });

    test('maps SQL hint to stable error code and logs failure', () async {
      when(
        () => client.rpc('block_user', params: any(named: 'params')),
      ).thenAnswer(
        (_) => _FakeFilterBuilder(
          Future<dynamic>.error(
            PostgrestException(
              message: 'self_block_not_allowed',
              code: 'P0001',
              hint: ModerationErrorCode.selfBlockNotAllowed,
            ),
          ),
        ),
      );

      await expectLater(
        makeRepo().blockUser(blockedUserId: 'self'),
        throwsA(
          isA<ModerationException>().having(
            (e) => e.code,
            'code',
            ModerationErrorCode.selfBlockNotAllowed,
          ),
        ),
      );

      expect(log.single.success, isFalse);
      expect(log.single.errorCode, ModerationErrorCode.selfBlockNotAllowed);
    });

    test('TimeoutException → ModerationException(timeout)', () async {
      when(
        () => client.rpc('block_user', params: any(named: 'params')),
      ).thenAnswer(
        (_) => _FakeFilterBuilder(
          // Never completes — forces the .timeout to fire.
          Completer<dynamic>().future,
        ),
      );

      await expectLater(
        makeRepo(timeout: const Duration(milliseconds: 50))
            .blockUser(blockedUserId: 'user-2'),
        throwsA(
          isA<ModerationException>().having(
            (e) => e.code,
            'code',
            ModerationErrorCode.timeout,
          ),
        ),
      );

      expect(log.single.errorCode, ModerationErrorCode.timeout);
    });
  });

  group('submitReport', () {
    test('passes the idempotency key through to RPC', () async {
      Map<String, dynamic>? capturedParams;
      when(
        () => client.rpc(
          'submit_moderation_report',
          params: any(named: 'params'),
        ),
      ).thenAnswer((invocation) {
        capturedParams =
            invocation.namedArguments[#params] as Map<String, dynamic>;
        return _FakeFilterBuilder(Future.value({'success': true}));
      });

      const target = ModerationTarget(
        targetType: ModerationTargetType.shop,
        targetId: 'shop-1',
        targetOwnerId: 'owner-1',
        displayName: 'Joe’s Shop',
      );

      await makeRepo().submitReport(
        target: target,
        reason: 'spam',
        details: 'persistent dm spam',
        clientIdempotencyKey: 'stable-key-1',
      );

      expect(capturedParams?['p_client_idempotency_key'], 'stable-key-1');
      expect(capturedParams?['p_target_type'], 'shop');
      expect(capturedParams?['p_reason'], 'spam');
    });
  });
}
