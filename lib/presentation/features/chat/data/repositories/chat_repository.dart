import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_types.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/conversation.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/message.dart';

/// Sendbird-compatible chat repository interface
/// This interface matches Sendbird's SDK methods
abstract class ChatRepository {
  // ========== Connection Management (Sendbird: connect/disconnect) ==========
  Future<void> connect(String userId, {String? nickname, String? accessToken});
  Future<void> disconnect();
  Future<bool> isConnected();

  // ========== Channel Management (Sendbird: GroupChannel) ==========
  Future<List<Conversation>> getChannels({
    SBChannelFilter filter = SBChannelFilter.all,
    int limit = 20,
    String? token,
  });

  Future<Conversation> createChannel({
    required String name,
    required List<String> userIds,
    String? coverUrl,
    bool isDistinct = true,
    bool isPublic = false,
    Map<String, dynamic>? data,
  });

  Future<Conversation> getChannel(String channelUrl);
  Future<void> joinChannel(String channelUrl);
  Future<void> leaveChannel(String channelUrl);
  Future<void> deleteChannel(String channelUrl);
  Future<void> freezeChannel(String channelUrl, bool freeze);

  // ========== Message Management (Sendbird: BaseMessage) ==========
  Future<List<Message>> getMessages(
    String channelUrl, {
    int? limit,
    String? token,
    bool reverse = false,
  });

  Future<Message> sendTextMessage(
    String channelUrl,
    String content, {
    Map<String, dynamic>? data,
    int? parentMessageId,
  });

  Future<Message> sendFileMessage(
    String channelUrl,
    String filePath,
    String fileName,
    String mimeType, {
    String? caption,
    Map<String, dynamic>? data,
    void Function(int sent, int total)? onProgress,
  });

  Future<void> updateMessage(String channelUrl, int messageId, String content);

  Future<void> deleteMessage(String channelUrl, int messageId);

  Future<void> markAsRead(String channelUrl);
  Future<void> markAsDelivered(String channelUrl);

  // ========== Real-time Listeners (Sendbird: ChannelHandler) ==========
  Stream<List<Message>> watchMessages(String channelUrl);
  Stream<List<String>> watchTypingUsers(String channelUrl);
  Stream<int> watchUnreadCount();
  Stream<void> watchConnectionStatus();

  /// Emits whenever any channel in the user's list changes (new message,
  /// name update, member join/leave). Used to keep the conversation list
  /// in sync without polling.
  Stream<void> watchChannelListChanges();

  // ========== User Management ==========
  Future<void> updateUserProfile({String? nickname, String? profileUrl});

  // ========== Typing Indicators (Sendbird: startTyping/endTyping) ==========
  Future<void> startTyping(String channelUrl);
  Future<void> endTyping(String channelUrl);

  // ========== Cleanup ==========
  Future<void> dispose();
}
