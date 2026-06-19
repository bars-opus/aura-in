import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nano_embryo/core/feedback/config/feedback_config.dart';
import 'package:nano_embryo/core/feedback/data/services/feedback_screenshot_uploader.dart';
import 'package:nano_embryo/core/feedback/domain/entities/feedback.dart' as fb;
import 'package:nano_embryo/core/feedback/domain/repositories/feedback_repository.dart';
import 'package:nano_embryo/core/feedback/exceptions/feedback_exceptions.dart';
import 'package:nano_embryo/core/feedback/presentation/controllers/feedback_controller.dart';
import 'package:uuid/uuid.dart';

class _MockRepo extends Mock implements FeedbackRepository {}
class _MockUploader extends Mock implements FeedbackScreenshotUploader {}
class _FakeFeedback extends Fake implements fb.Feedback {}
class _FakeFile extends Fake implements File {}

FeedbackConfig _config({
  List<FeedbackTypeOption> types = const [
    FeedbackTypeOption(key: 'bug', label: 'Bug'),
    FeedbackTypeOption(key: 'suggestion', label: 'Suggestion'),
  ],
  bool enableScreenshots = true,
  int maxScreenshots = 3,
  void Function(String, Map<String, Object?>)? onEvent,
}) {
  return FeedbackConfig(
    appName: 'Test',
    types: types,
    enableScreenshots: enableScreenshots,
    maxScreenshots: maxScreenshots,
    onEvent: onEvent,
  );
}

FeedbackController _make({
  required _MockRepo repo,
  required _MockUploader uploader,
  FeedbackConfig? config,
  void Function(String, Map<String, Object?>)? onEvent,
  Uuid uuid = const Uuid(),
}) {
  return FeedbackController(
    repo,
    uploader,
    config ?? _config(onEvent: onEvent),
    'user-1',
    onEvent: onEvent,
    uuid: uuid,
  );
}

fb.Feedback _savedFeedback({
  String type = 'bug',
  List<String> screenshotUrls = const [],
  String? idempotencyKey = 'idk-1',
}) {
  final now = DateTime.utc(2026, 6, 14);
  return fb.Feedback(
    id: 'fb-1',
    userId: 'user-1',
    type: type,
    title: 'title',
    description: 'description',
    screenshotUrls: screenshotUrls,
    appVersion: '1.0.0+1',
    idempotencyKey: idempotencyKey,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late _MockRepo repo;
  late _MockUploader uploader;

  setUpAll(() {
    registerFallbackValue(_FakeFeedback());
    registerFallbackValue(<File>[]);
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    repo = _MockRepo();
    uploader = _MockUploader();
  });

  group('submitFeedback — validation', () {
    test('rejects empty title', () async {
      final c = _make(repo: repo, uploader: uploader);
      final r = await c.submitFeedback(
        type: 'bug',
        title: '   ',
        description: 'ok',
        appVersion: '1',
      );
      expect(r, isNull);
      expect(c.state.errorIsRetryable, isFalse);
      expect(c.state.errorMessage, contains('Title'));
      verifyNever(() => repo.submitFeedback(any()));
    });

    test('rejects over-long description', () async {
      final c = _make(
        repo: repo,
        uploader: uploader,
        config: _config()..hashCode, // sanity
      );
      final r = await c.submitFeedback(
        type: 'bug',
        title: 'ok',
        description: 'x' * 5001,
        appVersion: '1',
      );
      expect(r, isNull);
      expect(c.state.errorMessage, contains('Description'));
    });

    test('rejects too many screenshots', () async {
      final c = _make(
        repo: repo,
        uploader: uploader,
        config: _config(maxScreenshots: 1),
      );
      final r = await c.submitFeedback(
        type: 'bug',
        title: 'ok',
        description: 'ok',
        screenshots: [_FakeFile(), _FakeFile()],
        appVersion: '1',
      );
      expect(r, isNull);
      expect(c.state.errorMessage, contains('at most'));
    });

    test('rejects type not in the configured allow-list', () async {
      final events = <(String, Map<String, Object?>)>[];
      final c = _make(
        repo: repo,
        uploader: uploader,
        onEvent: (e, a) => events.add((e, a)),
      );
      final r = await c.submitFeedback(
        type: 'rogue_key',
        title: 'ok',
        description: 'ok',
        appVersion: '1',
      );
      expect(r, isNull);
      expect(c.state.errorIsRetryable, isFalse);
      expect(
        events.single.$1,
        'feedback_submit_failed',
      );
      expect(events.single.$2['category'], 'validation');
      verifyNever(() => repo.submitFeedback(any()));
    });
  });

  group('submitFeedback — happy path', () {
    test('submits without screenshots, emits telemetry', () async {
      when(() => repo.submitFeedback(any()))
          .thenAnswer((_) async => _savedFeedback());
      final events = <(String, Map<String, Object?>)>[];
      final c = _make(
        repo: repo,
        uploader: uploader,
        onEvent: (e, a) => events.add((e, a)),
      );

      final r = await c.submitFeedback(
        type: 'bug',
        title: 'broken',
        description: 'the button doesnt work',
        appVersion: '1',
      );

      expect(r, isNotNull);
      expect(c.state.isSubmitting, isFalse);
      expect(c.state.userFeedback, hasLength(1));
      expect(
        events.map((e) => e.$1).toList(),
        containsAllInOrder([
          'feedback_submit_started',
          'feedback_submitted',
        ]),
      );
      verifyNever(() => uploader.uploadAll(
            userId: any(named: 'userId'),
            files: any(named: 'files'),
            onProgress: any(named: 'onProgress'),
          ));
    });

    test('uploads screenshots, attaches URLs, succeeds', () async {
      when(() => uploader.uploadAll(
            userId: any(named: 'userId'),
            files: any(named: 'files'),
            onProgress: any(named: 'onProgress'),
          )).thenAnswer((_) async => const FeedbackUploadResult(
            urls: ['u/1.jpg', 'u/2.jpg'],
            storagePaths: ['user-1/1.jpg', 'user-1/2.jpg'],
          ));
      when(() => repo.submitFeedback(any())).thenAnswer((invocation) async {
        final draft = invocation.positionalArguments.single as fb.Feedback;
        // Verify the controller propagated the URLs.
        expect(draft.screenshotUrls, ['u/1.jpg', 'u/2.jpg']);
        return _savedFeedback(screenshotUrls: draft.screenshotUrls);
      });
      final c = _make(repo: repo, uploader: uploader);

      final r = await c.submitFeedback(
        type: 'bug',
        title: 'ok',
        description: 'ok',
        screenshots: [_FakeFile(), _FakeFile()],
        appVersion: '1',
      );

      expect(r, isNotNull);
      expect(r!.screenshotUrls, hasLength(2));
    });
  });

  group('submitFeedback — failure paths', () {
    test('DB failure AFTER upload triggers orphan cleanup', () async {
      when(() => uploader.uploadAll(
            userId: any(named: 'userId'),
            files: any(named: 'files'),
            onProgress: any(named: 'onProgress'),
          )).thenAnswer((_) async => const FeedbackUploadResult(
            urls: ['u/1.jpg'],
            storagePaths: ['user-1/1.jpg'],
          ));
      when(() => repo.submitFeedback(any()))
          .thenThrow(FeedbackDatabaseException('boom', code: '500'));
      when(() => uploader.deleteAll(any())).thenAnswer((_) async {});
      final c = _make(repo: repo, uploader: uploader);

      final r = await c.submitFeedback(
        type: 'bug',
        title: 'ok',
        description: 'ok',
        screenshots: [_FakeFile()],
        appVersion: '1',
      );

      expect(r, isNull);
      expect(c.state.errorIsRetryable, isTrue);
      // Cleanup is fire-and-forget — give the microtask queue a tick.
      await Future<void>.delayed(Duration.zero);
      verify(() => uploader.deleteAll(['user-1/1.jpg'])).called(1);
    });

    test('upload failure does NOT call repo and surfaces storage error',
        () async {
      when(() => uploader.uploadAll(
            userId: any(named: 'userId'),
            files: any(named: 'files'),
            onProgress: any(named: 'onProgress'),
          )).thenThrow(FeedbackStorageException('full'));
      final c = _make(repo: repo, uploader: uploader);

      final r = await c.submitFeedback(
        type: 'bug',
        title: 'ok',
        description: 'ok',
        screenshots: [_FakeFile()],
        appVersion: '1',
      );

      expect(r, isNull);
      expect(c.state.errorIsRetryable, isTrue);
      expect(c.state.errorMessage, contains('screenshot'));
      verifyNever(() => repo.submitFeedback(any()));
    });

    test('auth failure is non-retryable', () async {
      when(() => repo.submitFeedback(any()))
          .thenThrow(FeedbackAuthException('expired'));
      final c = _make(repo: repo, uploader: uploader);

      await c.submitFeedback(
        type: 'bug',
        title: 'ok',
        description: 'ok',
        appVersion: '1',
      );

      expect(c.state.errorIsRetryable, isFalse);
      expect(c.state.errorMessage, contains('log in'));
    });

    test('timeout maps to retryable error', () async {
      when(() => repo.submitFeedback(any()))
          .thenThrow(FeedbackTimeoutException('slow'));
      final c = _make(repo: repo, uploader: uploader);

      await c.submitFeedback(
        type: 'bug',
        title: 'ok',
        description: 'ok',
        appVersion: '1',
      );

      expect(c.state.errorIsRetryable, isTrue);
      expect(c.state.errorMessage, contains('Try again'));
    });
  });

  group('submitFeedback — concurrency + dispose', () {
    test('reentrant double-tap fires only one repo call', () async {
      final pending = Completer<fb.Feedback>();
      when(() => repo.submitFeedback(any()))
          .thenAnswer((_) => pending.future);
      final c = _make(repo: repo, uploader: uploader);

      final first = c.submitFeedback(
        type: 'bug',
        title: 'ok',
        description: 'ok',
        appVersion: '1',
      );
      final second = c.submitFeedback(
        type: 'bug',
        title: 'ok',
        description: 'ok',
        appVersion: '1',
      );

      expect(await second, isNull); // short-circuits while first in flight
      pending.complete(_savedFeedback());
      expect(await first, isNotNull);
      verify(() => repo.submitFeedback(any())).called(1);
    });

    test('safe across dispose — no setState after disposal', () async {
      final pending = Completer<fb.Feedback>();
      when(() => repo.submitFeedback(any()))
          .thenAnswer((_) => pending.future);
      final c = _make(repo: repo, uploader: uploader);

      final f = c.submitFeedback(
        type: 'bug',
        title: 'ok',
        description: 'ok',
        appVersion: '1',
      );
      c.dispose();
      pending.complete(_savedFeedback());
      expect(await f, isNull); // dispose was honored, no crash
    });
  });

  group('submitFeedback — telemetry', () {
    test('onEvent that throws does not break the submit flow', () async {
      when(() => repo.submitFeedback(any()))
          .thenAnswer((_) async => _savedFeedback());
      final c = _make(
        repo: repo,
        uploader: uploader,
        onEvent: (_, _) => throw StateError('analytics down'),
      );

      final r = await c.submitFeedback(
        type: 'bug',
        title: 'ok',
        description: 'ok',
        appVersion: '1',
      );
      expect(r, isNotNull);
    });
  });

  group('loadFeedbackHistory', () {
    test('populates state on success', () async {
      when(() => repo.getUserFeedback()).thenAnswer((_) async => [
            _savedFeedback(),
            _savedFeedback(type: 'suggestion'),
          ]);
      final c = _make(repo: repo, uploader: uploader);
      await c.loadFeedbackHistory();
      expect(c.state.userFeedback, hasLength(2));
      expect(c.state.errorMessage, isNull);
    });

    test('database failure → retryable error', () async {
      when(() => repo.getUserFeedback())
          .thenThrow(FeedbackDatabaseException('5xx'));
      final c = _make(repo: repo, uploader: uploader);
      await c.loadFeedbackHistory();
      expect(c.state.errorIsRetryable, isTrue);
    });
  });
}
