import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_channel.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_message.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_types.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_user.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/conversation.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/message.dart';
import 'chat_repository.dart';

/// Production-ready Sendbird Chat Repository for SDK 3.2.20
// FIX 1: Mix in ChannelEventHandler and ConnectionEventHandler directly on the
// class — this is the correct v3 Flutter SDK event handler pattern.
class SendbirdChatRepository
    with ChannelEventHandler, ConnectionEventHandler
    implements ChatRepository {
  late final SendbirdSdk _sendbird;
  String? _currentUserId;

  // Stream controllers
  final Map<String, StreamController<List<Message>>> _messageStreams = {};
  final Map<String, StreamController<List<String>>> _typingStreams = {};
  final StreamController<int> _unreadCountController =
      StreamController.broadcast();
  final StreamController<void> _connectionController =
      StreamController.broadcast();
  final StreamController<void> _channelListController =
      StreamController.broadcast();

  SendbirdChatRepository(SendbirdSdk sendbird) {
    _sendbird = sendbird; // Use the passed instance directly
    _setupEventHandlers();
  }

  void _setupEventHandlers() {
    // FIX 2: Use addChannelEventHandler / addConnectionEventHandler with the
    // mixin pattern. The class itself IS the handler since it mixes in the
    // handler traits. No separate ConnectionDelegate/ChannelDelegate objects.
    _sendbird.addChannelEventHandler('main', this);
    _sendbird.addConnectionEventHandler('main', this);
  }

  // FIX 3: Override the mixin methods directly on this class instead of
  // creating separate delegate objects. These replace _setupChannelDelegate().

  @override
  void onConnected(User user) {
    print('Sendbird: Connected as ${user.userId}');
    _connectionController.add(null);
  }

  @override
  void onDisconnected(String userId) {
    print('Sendbird: Disconnected');
    _connectionController.add(null);
  }

  @override
  void onReconnectStarted() {
    print('Sendbird: Reconnect started');
  }

  @override
  void onReconnectSucceeded() {
    print('Sendbird: Reconnect succeeded');
    _connectionController.add(null);
  }

  @override
  void onReconnectFailed() {
    print('Sendbird: Reconnect failed');
  }

  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    debugPrint('📨 [SB-EVENT] onMessageReceived | channel=${channel.channelUrl} | msgId=${message.messageId} | sender=${message is UserMessage ? message.sender?.userId : "?"} | content=${message is UserMessage ? message.message : "[file]"}');
    _loadAndBroadcastMessages(channel.channelUrl);
  }

  @override
  void onMessageUpdated(BaseChannel channel, BaseMessage message) {
    print('Message updated in ${channel.channelUrl}');
    _loadAndBroadcastMessages(channel.channelUrl);
  }

  @override
  void onMessageDeleted(BaseChannel channel, int messageId) {
    print('Message deleted in ${channel.channelUrl}');
    _loadAndBroadcastMessages(channel.channelUrl);
  }

  @override
  void onReadReceiptUpdated(GroupChannel channel) {
    _loadAndBroadcastMessages(channel.channelUrl);
  }

  @override
  void onDeliveryReceiptUpdated(GroupChannel channel) {
    _loadAndBroadcastMessages(channel.channelUrl);
  }

  @override
  void onTypingStatusUpdated(GroupChannel channel) {
    print('Typing status updated in ${channel.channelUrl}');
    _broadcastTypingUsers(channel.channelUrl);
  }

  @override
  void onChannelChanged(BaseChannel channel) {
    // Fires when any channel property changes (last message, unread count,
    // member join/leave, name update). Signal the conversation list to refresh.
    _channelListController.add(null);
  }

  @override
  void onUserJoined(GroupChannel channel, User user) {
    print('User ${user.userId} joined ${channel.channelUrl}');
    _channelListController.add(null);
  }

  @override
  void onUserLeft(GroupChannel channel, User user) {
    print('User ${user.userId} left ${channel.channelUrl}');
    _channelListController.add(null);
  }

  Future<void> _loadAndBroadcastMessages(String channelUrl) async {
    try {
      final messages = await getMessages(channelUrl);
      debugPrint('📡 [BROADCAST] channelUrl=$channelUrl | msgCount=${messages.length} | hasStream=${_messageStreams.containsKey(channelUrl)}');
      if (messages.isNotEmpty) {
        debugPrint('   [BROADCAST] newest=${messages.first.content.substring(0, messages.first.content.length.clamp(0,30))} @ ${messages.first.timestamp}');
        debugPrint('   [BROADCAST] oldest=${messages.last.content.substring(0, messages.last.content.length.clamp(0,30))} @ ${messages.last.timestamp}');
      }
      if (_messageStreams.containsKey(channelUrl)) {
        _messageStreams[channelUrl]?.add(messages);
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  Future<void> _broadcastTypingUsers(String channelUrl) async {
    try {
      final channel = await GroupChannel.getChannel(channelUrl);
      final typingUsers = channel.getTypingUsers();
      final userIds = typingUsers.map((u) => u.userId).toList();
      if (_typingStreams.containsKey(channelUrl)) {
        _typingStreams[channelUrl]?.add(userIds);
      }
    } catch (e) {
      debugPrint('Error getting typing users: $e');
    }
  }

  // ========== Connection Management ==========

  @override
  Future<void> connect(
    String userId, {
    String? nickname,
    String? accessToken,
  }) async {
    try {
      _currentUserId = userId;
      final user = await _sendbird.connect(
        userId,
        accessToken: accessToken,
      );

      if (nickname != null && nickname.isNotEmpty) {
        await _sendbird.updateCurrentUserInfo(nickname: nickname);
      }

      debugPrint('Sendbird: Connected as ${user.userId}');
      _connectionController.add(null);
    } catch (e) {
      debugPrint('Sendbird connection error: $e');
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _sendbird.disconnect();
      _currentUserId = null;
      debugPrint('Sendbird: Disconnected');
      _connectionController.add(null);
    } catch (e) {
      debugPrint('Sendbird disconnect error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isConnected() async {
    return _sendbird.currentUser != null;
  }

  // ========== Channel Management ==========

  @override
  Future<List<Conversation>> getChannels({
    SBChannelFilter filter = SBChannelFilter.all,
    int limit = 20,
    String? token,
  }) async {
    try {
      // FIX 4: Use loadNext() which is the correct async v3 API.
      final query = GroupChannelListQuery()..limit = limit;
      final channels = await query.loadNext();

      debugPrint('📋 [GET-CHANNELS] currentUserId=$_currentUserId | total=${channels.length} channels returned');
      for (final ch in channels) {
        final memberIds = ch.members.map((m) => m.userId).toList();
        debugPrint('   [CHANNEL] url=${ch.channelUrl} | name="${ch.name}" | members=$memberIds | isDistinct=${ch.isDistinct} | isPublic=${ch.isPublic} | memberCount=${ch.members.length}');
      }

      return channels.map((channel) {
        return Conversation.fromSBChannel(
          _mapToSBChannel(channel),
          _currentUserId ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting channels: $e');
      return [];
    }
  }

  SBChannel _mapToSBChannel(GroupChannel channel) {
    return SBChannel(
      channelUrl: channel.channelUrl,
      name: channel.name ?? '',
      coverUrl: channel.coverUrl,
      customType: channel.customType,
      channelType: channel.isPublic ? SBChannelType.open : SBChannelType.group,
      // FIX: createdAt/updatedAt are int? (ms since epoch) — convert to DateTime
      createdAt:
          channel.createdAt != null
              ? DateTime.fromMillisecondsSinceEpoch(channel.createdAt!)
              : DateTime.now(),
      updatedAt:
          channel.lastMessage?.createdAt != null
              ? DateTime.fromMillisecondsSinceEpoch(
                channel.lastMessage!.createdAt,
              )
              : channel.createdAt != null
              ? DateTime.fromMillisecondsSinceEpoch(channel.createdAt!)
              : DateTime.now(),
      lastMessage:
          channel.lastMessage != null
              ? _mapToSBMessage(channel.lastMessage!)
              : null,
      unreadMessageCount: channel.unreadMessageCount,
      members:
          channel.members
              .map(
                (m) => SBUser(
                  userId: m.userId,
                  nickname: m.nickname,
                  profileUrl: m.profileUrl,
                ),
              )
              .toList(),
      // FIX: invitedMembers doesn't exist on GroupChannel in v3 — use empty list
      invitedMembers: [],
      isDistinct: channel.isDistinct,
      isPublic: channel.isPublic,
      isEphemeral: channel.isEphemeral,
      isSuper: channel.isSuper,
      isBroadcast: channel.isBroadcast,
      isFrozen: channel.isFrozen,
      // FIX: channel.data is String? — parse it to Map if needed, or pass null
      data: channel.data != null ? {'raw': channel.data} : null,
      // FIX: messageOffsetTimestamp is int? — provide fallback
      messageOffsetTimestamp: channel.messageOffsetTimestamp ?? 0,
      messageSurvivalSeconds: channel.messageSurvivalSeconds,
    );
  }

  // Sendbird returns "" (empty string) instead of null when no data is set.
  // jsonDecode("") throws FormatException — guard against it here.
  Map<String, dynamic>? _decodeData(String? data) {
    if (data == null || data.isEmpty) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  SBMessage _mapToSBMessage(BaseMessage message) {
    if (message is UserMessage) {
      return SBUserMessage(
        messageId: message.messageId,
        channelUrl: message.channelUrl,
        createdAt: DateTime.fromMillisecondsSinceEpoch(message.createdAt),
        // updatedAt: message.updatedAt,
        message: message.message,
        sender:
            message.sender != null
                ? SBUser(
                  userId: message.sender!.userId,
                  nickname: message.sender!.nickname,
                  profileUrl: message.sender!.profileUrl,
                )
                : null,
        sendingStatus: _mapSendingStatus(message.sendingStatus),
        data: _decodeData(message.data),

        parentMessageId: message.parentMessageId,
        isPinned: message.isPinnedMessage,
      );
    } else if (message is FileMessage) {
      return SBFileMessage(
        messageId: message.messageId,
        channelUrl: message.channelUrl,
        createdAt: DateTime.fromMillisecondsSinceEpoch(message.createdAt),

        // updatedAt: message.updatedAt,
        url: message.url,
        name: message.name ?? '',
        type: message.type ?? '',
        size: message.size ?? 0,
        // ... thumbnails ...
        message: message.message,
        sender:
            message.sender != null
                ? SBUser(
                  // FIX: userId is String? in sender — provide fallback
                  userId: message.sender!.userId ?? '',
                  nickname: message.sender!.nickname,
                )
                : null,
        sendingStatus: _mapSendingStatus(message.sendingStatus),
        data: _decodeData(message.data),
      );
    } else if (message is AdminMessage) {
      return SBAdminMessage(
        messageId: message.messageId,
        channelUrl: message.channelUrl,
        createdAt: DateTime.fromMillisecondsSinceEpoch(message.createdAt),

        message: message.message,
      );
    }

    throw Exception('Unknown message type');
  }

  SBMessageSendingStatus _mapSendingStatus(MessageSendingStatus? status) {
    switch (status) {
      case MessageSendingStatus.pending:
        return SBMessageSendingStatus.pending;
      case MessageSendingStatus.failed:
        return SBMessageSendingStatus.failed;
      case MessageSendingStatus.succeeded:
        return SBMessageSendingStatus.succeeded;
      default:
        return SBMessageSendingStatus.none;
    }
  }

  @override
  Future<Conversation> createChannel({
    required String name,
    required List<String> userIds,
    String? coverUrl,
    bool isDistinct = true,
    bool isPublic = false,
    Map<String, dynamic>? data,
  }) async {
    try {
      debugPrint('🔨 [CREATE-CHANNEL] name="$name" | userIds=$userIds | isDistinct=$isDistinct | isPublic=$isPublic | sdkCurrentUser=$_currentUserId');

      final params =
          GroupChannelParams()
            ..name = name
            ..userIds = userIds
            ..isDistinct = isDistinct
            ..isPublic = isPublic
            ..data = data != null ? data.toString() : null;

      final channel = await GroupChannel.createChannel(params);

      final resultMemberIds = channel.members.map((m) => m.userId).toList();
      debugPrint('✅ [CREATE-CHANNEL] result: url=${channel.channelUrl} | members=$resultMemberIds | memberCount=${channel.members.length} | isDistinct=${channel.isDistinct}');

      return Conversation.fromSBChannel(
        _mapToSBChannel(channel),
        _currentUserId ?? '',
      );
    } catch (e) {
      debugPrint('Error creating channel: $e');
      rethrow;
    }
  }

  @override
  Future<Conversation> getChannel(String channelUrl) async {
    try {
      final channel = await GroupChannel.getChannel(channelUrl);
      return Conversation.fromSBChannel(
        _mapToSBChannel(channel),
        _currentUserId ?? '',
      );
    } catch (e) {
      debugPrint('Error getting channel: $e');
      rethrow;
    }
  }

  @override
  Future<void> joinChannel(String channelUrl) async {
    try {
      final channel = await GroupChannel.getChannel(channelUrl);
      await channel.join();
    } catch (e) {
      debugPrint('Error joining channel: $e');
      rethrow;
    }
  }

  @override
  Future<void> leaveChannel(String channelUrl) async {
    try {
      final channel = await GroupChannel.getChannel(channelUrl);
      await channel.leave();
    } catch (e) {
      debugPrint('Error leaving channel: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteChannel(String channelUrl) async {
    try {
      final channel = await GroupChannel.getChannel(channelUrl);
      await channel.deleteChannel(); // <-- was channel.delete()
    } catch (e) {
      debugPrint('Error deleting channel: $e');
      rethrow;
    }
  }

  @override
  Future<void> freezeChannel(String channelUrl, bool freeze) async {
    try {
      final channel = await GroupChannel.getChannel(channelUrl);
      // FIX: freeze() and unfreeze() are separate methods with no argument
      if (freeze) {
        await channel.freeze();
      } else {
        await channel.unfreeze();
      }
    } catch (e) {
      debugPrint('Error freezing channel: $e');
      rethrow;
    }
  }

  // ========== Message Management ==========

  @override
  Future<List<Message>> getMessages(
    String channelUrl, {
    int limit = 50,
    String? token,
    bool reverse = true,
  }) async {
    try {
      final channel = await GroupChannel.getChannel(channelUrl);

      // reverse=true → Sendbird returns messages newest-first (descending).
      // ListView.builder with reverse:true puts index-0 at the bottom, so
      // index-0 = newest means newest appears near the text field. ✓
      final params =
          MessageListParams()
            ..previousResultSize = limit
            ..reverse = true;

      // token is the oldest message's timestamp in milliseconds (for pagination).
      final timestamp =
          token != null
              ? (int.tryParse(token) ?? DateTime.now().millisecondsSinceEpoch)
              : DateTime.now().millisecondsSinceEpoch;

      debugPrint('📥 [GET-MESSAGES] channel=$channelUrl | token=$token | timestamp=$timestamp | limit=$limit | reverse=true');

      final messages = await channel.getMessagesByTimestamp(timestamp, params);

      debugPrint('   [GET-MESSAGES] raw count=${messages.length}');
      if (messages.isNotEmpty) {
        final first = messages.first;
        final last = messages.last;
        debugPrint('   [GET-MESSAGES] [0](newest?): id=${first.messageId} ts=${first.createdAt} content=${first is UserMessage ? first.message.substring(0, first.message.length.clamp(0, 30)) : "[file]"}');
        debugPrint('   [GET-MESSAGES] [last](oldest?): id=${last.messageId} ts=${last.createdAt} content=${last is UserMessage ? last.message.substring(0, last.message.length.clamp(0, 30)) : "[file]"}');
      }

      return messages.map((message) {
        return Message.fromSBMessage(
          _mapToSBMessage(message),
          _currentUserId ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting messages: $e');
      return [];
    }
  }

  @override
  Future<Message> sendTextMessage(
    String channelUrl,
    String content, {
    Map<String, dynamic>? data,
    int? parentMessageId,
  }) async {
    try {
      debugPrint('📤 [SEND-MSG] channel=$channelUrl | content="${content.substring(0, content.length.clamp(0, 50))}" | currentUser=$_currentUserId');

      final channel = await GroupChannel.getChannel(channelUrl);

      final params =
          UserMessageParams(message: content)
            ..data = data != null ? jsonEncode(data) : null
            ..parentMessageId = parentMessageId;

      final completer = Completer<UserMessage>();
      channel.sendUserMessage(
        params,
        onCompleted: (message, error) {
          if (error != null) {
            debugPrint('❌ [SEND-MSG] error: $error');
            completer.completeError(error);
          } else {
            debugPrint('✅ [SEND-MSG] success: msgId=${message.messageId} ts=${message.createdAt} sender=${message.sender?.userId}');
            completer.complete(message);
          }
        },
      );

      final message = await completer.future;
      // onMessageReceived only fires for other users, never the sender.
      // Broadcast manually so the sender's message list updates immediately.
      unawaited(_loadAndBroadcastMessages(channelUrl));
      return Message.fromSBMessage(
        _mapToSBMessage(message),
        _currentUserId ?? '',
      );
    } catch (e) {
      debugPrint('Error sending text message: $e');
      rethrow;
    }
  }

  @override
  Future<Message> sendFileMessage(
    String channelUrl,
    String filePath,
    String fileName,
    String mimeType, {
    String? caption,
    Map<String, dynamic>? data,
  }) async {
    try {
      final channel = await GroupChannel.getChannel(channelUrl);

      // FIX: Use FileMessageParams.withFile() named constructor.
      // fileName, mimeType, message, data are set directly on the params object.
      final file = File(filePath); // requires import 'dart:io'
      final params = FileMessageParams.withFile(file, name: fileName)
        // ..mimeType = mimeType
        ..data = data != null ? jsonEncode(data) : null;
      // caption maps to the top-level message field via a different setter:
      // ..message is not available on FileMessageParams — caption is separate

      final completer = Completer<FileMessage>();
      channel.sendFileMessage(
        params,
        onCompleted: (message, error) {
          if (error != null) {
            completer.completeError(error);
          } else {
            completer.complete(message);
          }
        },
      );

      final message = await completer.future;
      return Message.fromSBMessage(
        _mapToSBMessage(message),
        _currentUserId ?? '',
      );
    } catch (e) {
      debugPrint('Error sending file message: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateMessage(
    String channelUrl,
    int messageId,
    String content,
  ) async {
    try {
      final channel = await GroupChannel.getChannel(channelUrl);
      // FIX 9: Same UserMessageParams required-param fix here too.
      final params = UserMessageParams(message: content);
      await channel.updateUserMessage(messageId, params);
    } catch (e) {
      debugPrint('Error updating message: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteMessage(String channelUrl, int messageId) async {
    try {
      final channel = await GroupChannel.getChannel(channelUrl);
      await channel.deleteMessage(messageId);
    } catch (e) {
      debugPrint('Error deleting message: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String channelUrl) async {
    try {
      final channel = await GroupChannel.getChannel(channelUrl);
      await channel.markAsRead();
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  @override
  Future<void> markAsDelivered(String channelUrl) async {
    // FIX: markAsDelivered() does not exist on GroupChannel in Flutter SDK v3.
    // Delivery receipts are tracked automatically by the SDK.
    // This is intentionally left as a no-op.
    print('markAsDelivered: handled automatically by Sendbird SDK');
  }

  // ========== Real-time Listeners ==========

  @override
  Stream<List<Message>> watchMessages(String channelUrl) {
    if (!_messageStreams.containsKey(channelUrl)) {
      final controller = StreamController<List<Message>>.broadcast();
      _messageStreams[channelUrl] = controller;
      // No per-channel delegate setup needed — the class-level mixin
      // handler (registered once in _setupEventHandlers) handles all channels.
      _loadAndBroadcastMessages(channelUrl);
    }

    return _messageStreams[channelUrl]!.stream;
  }

  @override
  Stream<List<String>> watchTypingUsers(String channelUrl) {
    if (!_typingStreams.containsKey(channelUrl)) {
      final controller = StreamController<List<String>>.broadcast();
      _typingStreams[channelUrl] = controller;
      controller.add([]);
    }

    return _typingStreams[channelUrl]!.stream;
  }

  @override
  Stream<int> watchUnreadCount() {
    return _unreadCountController.stream;
  }

  @override
  Stream<void> watchConnectionStatus() {
    return _connectionController.stream;
  }

  @override
  Stream<void> watchChannelListChanges() {
    return _channelListController.stream;
  }

  // ========== User Management ==========

  @override
  Future<void> updateUserProfile({String? nickname, String? profileUrl}) async {
    try {
      await _sendbird.updateCurrentUserInfo(nickname: nickname);
      debugPrint('Profile updated - nickname: $nickname');
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  @override
  Future<void> startTyping(String channelUrl) async {
    try {
      final channel = await GroupChannel.getChannel(channelUrl);
      channel.startTyping();
    } catch (e) {
      debugPrint('Error starting typing: $e');
    }
  }

  @override
  Future<void> endTyping(String channelUrl) async {
    try {
      final channel = await GroupChannel.getChannel(channelUrl);
      channel.endTyping();
    } catch (e) {
      debugPrint('Error ending typing: $e');
    }
  }

  @override
  Future<void> dispose() async {
    // FIX 10: Remove the event handlers before closing streams to avoid
    // stale callbacks firing during teardown.
    _sendbird.removeChannelEventHandler('main');
    _sendbird.removeConnectionEventHandler('main');

    for (final controller in _messageStreams.values) {
      await controller.close();
    }
    for (final controller in _typingStreams.values) {
      await controller.close();
    }

    await _unreadCountController.close();
    await _connectionController.close();
    await _channelListController.close();

    await _sendbird.disconnect();
  }
}
