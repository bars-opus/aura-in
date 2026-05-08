import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/message.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/state/chat_state.dart';

void main() {
  group('ChatState Tests', () {
    test('should create initial state', () {
      final state = ChatState.initial();

      expect(state.isLoading, isFalse);
      expect(state.isSending, isFalse);
      expect(state.messages, isEmpty);
      expect(state.typingUsers, isEmpty);
      expect(state.error, isNull);
    });

    test('should copy with new values', () {
      final state = ChatState.initial();
      final updatedState = state.copyWith(
        isLoading: true,
        isSending: true,
        error: 'Test error',
      );

      expect(updatedState.isLoading, isTrue);
      expect(updatedState.isSending, isTrue);
      expect(updatedState.error, 'Test error');
      expect(updatedState.messages, isEmpty);
    });

    test('should update messages', () {
      final state = ChatState.initial();
      final testMessage = Message(
        id: '1',
        content: 'Test message',
        timestamp: DateTime.now(),
        sender: MessageSender.user,
        status: MessageStatus.sent,
      );

      final updatedState = state.copyWith(messages: [testMessage]);

      expect(updatedState.messages.length, 1);
      expect(updatedState.messages.first.id, '1');
      expect(updatedState.messages.first.content, 'Test message');
    });

    test('should update typing users', () {
      final state = ChatState.initial();
      final updatedState = state.copyWith(typingUsers: ['user1', 'user2']);

      expect(updatedState.typingUsers.length, 2);
      expect(updatedState.typingUsers, contains('user1'));
      expect(updatedState.typingUsers, contains('user2'));
    });

    test('should handle error state', () {
      final state = ChatState.initial();
      final updatedState = state.copyWith(error: 'Network connection failed');

      expect(updatedState.error, 'Network connection failed');
      expect(updatedState.isLoading, isFalse);
      expect(updatedState.isSending, isFalse);
    });

    test('should reset error when creating new state', () {
      final stateWithError = ChatState.initial().copyWith(error: 'Some error');
      expect(stateWithError.error, 'Some error');

      // Create a fresh state (which has null error)
      final freshState = ChatState.initial();
      expect(freshState.error, isNull);
    });
  });
}
