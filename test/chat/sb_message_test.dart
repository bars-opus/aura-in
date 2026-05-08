import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_message.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_user.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_types.dart';

void main() {
  group('SBUserMessage Tests', () {
    final sender = SBUser(userId: 'user123', nickname: 'Test User');
    final userMessage = SBUserMessage(
      messageId: 12345,
      channelUrl: 'channel_123',
      createdAt: DateTime.now(),
      message: 'Hello, world!',
      sender: sender,
      sendingStatus: SBMessageSendingStatus.succeeded,
    );

    test('should create UserMessage', () {
      expect(userMessage.messageId, 12345);
      expect(userMessage.message, 'Hello, world!');
      expect(userMessage.messageType, SBMessageType.user);
    });

    test('should have correct sender info', () {
      expect(userMessage.sender?.userId, 'user123');
      expect(userMessage.sender?.nickname, 'Test User');
    });

    test('should have correct sending status', () {
      expect(userMessage.sendingStatus, SBMessageSendingStatus.succeeded);
    });
  });

  group('SBFileMessage Tests', () {
    final fileMessage = SBFileMessage(
      messageId: 67890,
      channelUrl: 'channel_123',
      createdAt: DateTime.now(),
      url: 'https://example.com/file.pdf',
      name: 'document.pdf',
      type: 'application/pdf',
      size: 1024000,
      message: 'Check this file',
    );

    test('should create FileMessage', () {
      expect(fileMessage.url, 'https://example.com/file.pdf');
      expect(fileMessage.name, 'document.pdf');
      expect(fileMessage.size, 1024000);
      expect(fileMessage.messageType, SBMessageType.file);
    });

    test('should have correct file info', () {
      expect(fileMessage.type, 'application/pdf');
      expect(fileMessage.name, contains('.pdf'));
    });
  });

  group('SBAdminMessage Tests', () {
    final adminMessage = SBAdminMessage(
      messageId: 11111,
      channelUrl: 'channel_123',
      createdAt: DateTime.now(),
      message: 'Channel created',
    );

    test('should create AdminMessage', () {
      expect(adminMessage.message, 'Channel created');
      expect(adminMessage.messageType, SBMessageType.admin);
    });
  });
}
