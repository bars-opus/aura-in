import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/chat/data/cache/pending_send.dart';

void main() {
  group('PendingSend', () {
    final created = DateTime.parse('2026-06-19T10:00:00.000Z');

    PendingSend textSend() => PendingSend(
          clientReqId: 'req-1',
          channelUrl: 'sendbird_group_channel_abc',
          kind: PendingSendKind.text,
          text: 'hello world',
          parentMessageId: 42,
          data: const {'client_req_id': 'req-1'},
          createdAt: created,
        );

    PendingSend fileSend() => PendingSend(
          clientReqId: 'req-2',
          channelUrl: 'sendbird_group_channel_abc',
          kind: PendingSendKind.file,
          filePath: '/tmp/photo.jpg',
          fileName: 'photo.jpg',
          mimeType: 'image/jpeg',
          caption: 'look at this',
          data: const {'client_req_id': 'req-2'},
          createdAt: created,
        );

    test('text send round-trips through JSON unchanged', () {
      final original = textSend();
      final restored = PendingSend.fromJson(original.toJson());

      expect(restored.clientReqId, original.clientReqId);
      expect(restored.channelUrl, original.channelUrl);
      expect(restored.kind, PendingSendKind.text);
      expect(restored.text, 'hello world');
      expect(restored.parentMessageId, 42);
      expect(restored.data, original.data);
      expect(restored.createdAt, created);
      expect(restored.attempts, 0);
    });

    test('file send round-trips through JSON unchanged', () {
      final original = fileSend();
      final restored = PendingSend.fromJson(original.toJson());

      expect(restored.kind, PendingSendKind.file);
      expect(restored.filePath, '/tmp/photo.jpg');
      expect(restored.fileName, 'photo.jpg');
      expect(restored.mimeType, 'image/jpeg');
      expect(restored.caption, 'look at this');
    });

    test('copyWith bumps attempts but preserves the clientReqId (2.20)', () {
      final original = textSend();
      final retried = original.copyWith(attempts: original.attempts + 1);

      // The dedupe key MUST be stable across retries.
      expect(retried.clientReqId, original.clientReqId);
      expect(retried.attempts, 1);
      expect(retried.text, original.text);
    });

    test('attempts survives a JSON round-trip', () {
      final retried = textSend().copyWith(attempts: 3);
      final restored = PendingSend.fromJson(retried.toJson());
      expect(restored.attempts, 3);
    });
  });
}
