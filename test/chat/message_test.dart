import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/message.dart';

void main() {
  group('Message Tests', () {
    test('should create text message', () {
      final message = Message(
        id: 'msg_1',
        content: 'Hello world',
        timestamp: DateTime.now(),
        sender: MessageSender.user,
        status: MessageStatus.sent,
        type: MessageType.text,
      );

      expect(message.id, 'msg_1');
      expect(message.content, 'Hello world');
      expect(message.sender, MessageSender.user);
      expect(message.status, MessageStatus.sent);
      expect(message.type, MessageType.text);
    });

    test('should create file message', () {
      final fileMessage = Message(
        id: 'file_1',
        content: 'Image sent',
        timestamp: DateTime.now(),
        sender: MessageSender.other,
        status: MessageStatus.delivered,
        type: MessageType.image,
        fileUrl: 'https://example.com/image.jpg',
        fileName: 'photo.jpg',
        fileSize: 1024000,
      );

      expect(fileMessage.type, MessageType.image);
      expect(fileMessage.fileUrl, 'https://example.com/image.jpg');
      expect(fileMessage.fileName, 'photo.jpg');
    });

    test('should create system message', () {
      final systemMessage = Message(
        id: 'system_1',
        content: 'User joined the chat',
        timestamp: DateTime.now(),
        sender: MessageSender.system,
        status: MessageStatus.sent,
        type: MessageType.system,
      );

      expect(systemMessage.sender, MessageSender.system);
      expect(systemMessage.type, MessageType.system);
    });

    test('should handle message status changes', () {
      final message = Message(
        id: 'msg_1',
        content: 'Test',
        timestamp: DateTime.now(),
        sender: MessageSender.user,
        status: MessageStatus.sending,
      );

      expect(message.status, MessageStatus.sending);

      final updatedMessage = Message(
        id: message.id,
        content: message.content,
        timestamp: message.timestamp,
        sender: message.sender,
        status: MessageStatus.sent,
      );

      expect(updatedMessage.status, MessageStatus.sent);
    });
  });
}
