import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_channel.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_types.dart';

void main() {
  group('SBChannel Tests', () {
    final testChannel = SBChannel(
      channelUrl: 'test_channel_123',
      name: 'Test Channel',
      coverUrl: 'https://example.com/cover.jpg',
      customType: 'test',
      channelType: SBChannelType.group,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
      unreadMessageCount: 5,
      members: [],
      invitedMembers: [],
      isDistinct: true,
      isPublic: false,
    );

    test('should create SBChannel instance', () {
      expect(testChannel.channelUrl, 'test_channel_123');
      expect(testChannel.name, 'Test Channel');
      expect(testChannel.channelType, SBChannelType.group);
    });

    test('should have correct unread count', () {
      expect(testChannel.hasUnreadMessages, isTrue);
      expect(testChannel.unreadMessageCount, 5);
    });

    test('should return member IDs', () {
      expect(testChannel.memberIds, isEmpty);
    });

    test('should check if user is member', () {
      expect(testChannel.isMember('user123'), isFalse);
    });

    test('should update unread count', () {
      final updatedChannel = SBChannel(
        channelUrl: testChannel.channelUrl,
        name: testChannel.name,
        channelType: testChannel.channelType,
        createdAt: testChannel.createdAt,
        updatedAt: testChannel.updatedAt,
        unreadMessageCount: 0,
        members: testChannel.members,
        invitedMembers: testChannel.invitedMembers,
      );
      expect(updatedChannel.hasUnreadMessages, isFalse);
    });
  });
}
