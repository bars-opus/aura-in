import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/moderation/data/moderation_models.dart';

void main() {
  group('ModerationTargetType.fromValue', () {
    test('maps known values', () {
      expect(
        ModerationTargetType.fromValue('profile'),
        ModerationTargetType.profile,
      );
      expect(
        ModerationTargetType.fromValue('shop'),
        ModerationTargetType.shop,
      );
      expect(
        ModerationTargetType.fromValue('freelancer'),
        ModerationTargetType.freelancer,
      );
    });

    test('falls back to profile for unknown / null', () {
      expect(
        ModerationTargetType.fromValue('unknown'),
        ModerationTargetType.profile,
      );
      expect(
        ModerationTargetType.fromValue(null),
        ModerationTargetType.profile,
      );
    });
  });

  group('ModerationActionResult', () {
    test('parses success=true with no reason', () {
      final result = ModerationActionResult.fromJson({'success': true});
      expect(result.success, isTrue);
      expect(result.reason, isNull);
    });

    test('parses success=true with already_blocked reason', () {
      final result = ModerationActionResult.fromJson({
        'success': true,
        'reason': 'already_blocked',
      });
      expect(result.success, isTrue);
      expect(result.reason, 'already_blocked');
    });

    test('parses success=false', () {
      final result = ModerationActionResult.fromJson({'success': false});
      expect(result.success, isFalse);
    });

    test('treats missing success as false', () {
      final result = ModerationActionResult.fromJson({});
      expect(result.success, isFalse);
    });
  });

  group('ModerationCheckResult', () {
    test('all three flags from server jsonb', () {
      final result = ModerationCheckResult.fromJson({
        'is_blocked': true,
        'is_blocked_by_current_user': true,
        'is_blocking_current_user': false,
      });
      expect(result.isBlocked, isTrue);
      expect(result.isBlockedByCurrentUser, isTrue);
      expect(result.isBlockingCurrentUser, isFalse);
    });

    test('all false when nothing matches', () {
      final result = ModerationCheckResult.fromJson({});
      expect(result.isBlocked, isFalse);
      expect(result.isBlockedByCurrentUser, isFalse);
      expect(result.isBlockingCurrentUser, isFalse);
    });
  });

  group('ModerationBlockRecord', () {
    test('parses full row', () {
      final record = ModerationBlockRecord.fromJson({
        'id': 'block-1',
        'blocked_user_id': 'user-2',
        'username': 'alice',
        'display_name': 'Alice',
        'avatar_url': 'https://example.com/a.png',
        'reason': 'spam',
        'created_at': '2026-06-01T10:00:00Z',
      });
      expect(record.id, 'block-1');
      expect(record.blockedUserId, 'user-2');
      expect(record.username, 'alice');
      expect(record.displayName, 'Alice');
      expect(record.reason, 'spam');
      expect(
        record.createdAt.toUtc(),
        DateTime.utc(2026, 6, 1, 10),
      );
    });

    test('tolerates missing optional fields', () {
      final record = ModerationBlockRecord.fromJson({
        'id': 'block-1',
        'blocked_user_id': 'user-2',
        'created_at': '2026-06-01T10:00:00Z',
      });
      expect(record.username, isNull);
      expect(record.displayName, isNull);
      expect(record.avatarUrl, isNull);
      expect(record.reason, isNull);
    });

    test('falls back to epoch on unparseable created_at', () {
      final record = ModerationBlockRecord.fromJson({
        'id': 'block-1',
        'blocked_user_id': 'user-2',
        'created_at': 'not-a-date',
      });
      expect(record.createdAt.millisecondsSinceEpoch, 0);
    });
  });
}
