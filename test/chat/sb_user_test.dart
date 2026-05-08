import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_user.dart';

void main() {
  group('SBUser Tests', () {
    final user = SBUser(
      userId: 'user_123',
      nickname: 'John Doe',
      profileUrl: 'https://example.com/avatar.jpg',
      isActive: true,
      lastSeenAt: DateTime.now(),
    );

    test('should create SBUser instance', () {
      expect(user.userId, 'user_123');
      expect(user.nickname, 'John Doe');
      expect(user.profileUrl, 'https://example.com/avatar.jpg');
    });

    test('should return display name', () {
      expect(user.displayName, 'John Doe');
    });

    test('should handle missing nickname', () {
      final userWithoutNickname = SBUser(userId: 'user_456');
      expect(userWithoutNickname.displayName, 'user_456');
    });

    test('should be active', () {
      expect(user.isActive, isTrue);
    });
  });
}
