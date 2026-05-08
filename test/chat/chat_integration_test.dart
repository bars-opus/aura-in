import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/state/chat_state.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/conversation.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/message.dart';

void main() {
  group('Chat Flow Tests', () {
    test('ChatState initial state is correct', () {
      final state = ChatState.initial();

      expect(state.isLoading, false);
      expect(state.isSending, false);
      expect(state.messages, []);
      expect(state.typingUsers, []);
      expect(state.error, null);
    });

    test('ChatState updates correctly', () {
      var state = ChatState.initial();

      state = state.copyWith(isLoading: true);
      expect(state.isLoading, true);

      state = state.copyWith(isSending: true);
      expect(state.isSending, true);

      final testMessage = Message(
        id: '1',
        content: 'Test message',
        timestamp: DateTime.now(),
        sender: MessageSender.user,
        status: MessageStatus.sent,
      );

      state = state.copyWith(messages: [testMessage]);
      expect(state.messages.length, 1);
      expect(state.messages.first.content, 'Test message');
    });

    test('Message creation works', () {
      final message = Message(
        id: 'msg_1',
        content: 'Hello world',
        timestamp: DateTime.now(),
        sender: MessageSender.user,
        status: MessageStatus.sent,
      );

      expect(message.id, 'msg_1');
      expect(message.content, 'Hello world');
      expect(message.sender, MessageSender.user);
    });

    test('Conversation creation works', () {
      final lastMessage = Message(
        id: 'last_1',
        content: 'Last message',
        timestamp: DateTime.now(),
        sender: MessageSender.other,
        status: MessageStatus.read,
      );

      final conversation = Conversation(
        id: 'conv_1',
        name: 'Test Chat',
        lastMessage: lastMessage,
        unreadCount: 2,
        updatedAt: DateTime.now(),
        participants: ['user1', 'user2'],
        isGroup: false,
      );

      expect(conversation.id, 'conv_1');
      expect(conversation.name, 'Test Chat');
      expect(conversation.unreadCount, 2);
      expect(conversation.participants.length, 2);
    });
  });
}
