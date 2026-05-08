import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/conversation.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/message.dart';

void main() {
  group('Conversation Tests', () {
    final lastMessage = Message(
      id: 'msg_1',
      content: 'Last message content',
      timestamp: DateTime.now(),
      sender: MessageSender.other,
      status: MessageStatus.read,
    );

    final conversation = Conversation(
      id: 'conv_123',
      name: 'Test Conversation',
      avatarUrl: 'https://example.com/avatar.jpg',
      lastMessage: lastMessage,
      unreadCount: 3,
      updatedAt: DateTime.now(),
      participants: ['user1', 'user2', 'user3'],
      isGroup: true,
      customData: '{"type": "test"}',
    );

    test('should create Conversation instance', () {
      expect(conversation.id, 'conv_123');
      expect(conversation.name, 'Test Conversation');
      expect(conversation.isGroup, isTrue);
    });

    test('should have correct unread count', () {
      expect(conversation.unreadCount, 3);
    });

    test('should have participants', () {
      expect(conversation.participants.length, 3);
      expect(conversation.participants, contains('user1'));
    });
  });
}
