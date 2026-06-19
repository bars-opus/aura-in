import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/moderation/data/moderation_models.dart';
import 'package:nano_embryo/core/moderation/utils/moderation_block_guard.dart';

void main() {
  group('moderationBlockGuard', () {
    test('null result → not blocked', () {
      expect(moderationBlockGuard(null), isFalse);
    });

    test('all false → not blocked', () {
      const result = ModerationCheckResult(
        isBlocked: false,
        isBlockedByCurrentUser: false,
        isBlockingCurrentUser: false,
      );
      expect(moderationBlockGuard(result), isFalse);
    });

    test('blocked by current user → blocked', () {
      const result = ModerationCheckResult(
        isBlocked: true,
        isBlockedByCurrentUser: true,
        isBlockingCurrentUser: false,
      );
      expect(moderationBlockGuard(result), isTrue);
    });

    test('blocked by other user → blocked (mutual semantics)', () {
      const result = ModerationCheckResult(
        isBlocked: true,
        isBlockedByCurrentUser: false,
        isBlockingCurrentUser: true,
      );
      expect(moderationBlockGuard(result), isTrue);
    });
  });
}
