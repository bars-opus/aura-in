import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:nano_embryo/presentation/features/chat/config/chat_config.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_channel.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_message.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_types.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_user.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/conversation.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/message.dart';
import 'package:nano_embryo/presentation/features/chat/utils/chat_log.dart';
import 'chat_repository.dart';

/// Production-ready Sendbird Chat Repository for SDK 3.2.20.
///
/// Mixes in ChannelEventHandler / ConnectionEventHandler directly (the v3
/// Flutter SDK pattern). The class itself IS the handler.
class SendbirdChatRepository
    with ChannelEventHandler, ConnectionEventHandler
    implements ChatRepository {
  late final SendbirdSdk _sendbird;
  final ChatConfig _config;
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

  // 3.2: trailing-debounce timers per channel so bursty events (read/delivery
  // receipts, rapid inbound messages) collapse into a single refetch instead
  // of a network round-trip storm.
  final Map<String, Timer> _broadcastDebouncers = {};

  SendbirdChatRepository(SendbirdSdk sendbird, {required ChatConfig config})
      : _config = config {
    _sendbird = sendbird;
    _setupEventHandlers();
  }

  /// Wraps an external Sendbird/SDK call with the configured per-request
  /// timeout (checklist 1.2). Throws [TimeoutException] on expiry, which the
  /// caller maps to a user-facing message.
  Future<T> _withTimeout<T>(Future<T> future) =>
      future.timeout(_config.networkTimeout);

  void _setupEventHandlers() {
    _sendbird.addChannelEventHandler('main', this);
    _sendbird.addConnectionEventHandler('main', this);
  }

  // ── Connection events ──────────────────────────────────────────────────────

  // NOTE: the v3 connection-handler callbacks below are optional mixin hooks,
  // not abstract overrides, so they carry no @override annotation.
  void onConnected(User user) {
    ChatLog.d('🔌 [SB] connected as ${ChatLog.shortId(user.userId)}');
    _connectionController.add(null);
  }

  void onDisconnected(String userId) {
    ChatLog.d('🔌 [SB] disconnected');
    _connectionController.add(null);
  }

  void onReconnectStarted() => ChatLog.d('🔌 [SB] reconnect started');

  void onReconnectSucceeded() {
    ChatLog.d('🔌 [SB] reconnect succeeded');
    _connectionController.add(null);
  }

  void onReconnectFailed() => ChatLog.d('🔌 [SB] reconnect failed');

  // ── Channel events ─────────────────────────────────────────────────────────

  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    ChatLog.d(
      '📨 [SB] message received | channel=${ChatLog.shortId(channel.channelUrl)} '
      '| msgId=${message.messageId}',
    );
    // New message → refresh promptly but still debounced so multi-recipient
    // fan-out (one event per member in some configs) collapses.
    _scheduleBroadcast(channel.channelUrl);
  }

  @override
  void onMessageUpdated(BaseChannel channel, BaseMessage message) {
    _scheduleBroadcast(channel.channelUrl);
  }

  @override
  void onMessageDeleted(BaseChannel channel, int messageId) {
    _scheduleBroadcast(channel.channelUrl);
  }

  @override
  void onReadReceiptUpdated(GroupChannel channel) {
    // Read receipts fire very frequently in an active chat. Debounce hard so
    // we don't refetch 50 messages on every keystroke-driven read event.
    _scheduleBroadcast(channel.channelUrl);
  }

  @override
  void onDeliveryReceiptUpdated(GroupChannel channel) {
    _scheduleBroadcast(channel.channelUrl);
  }

  @override
  void onTypingStatusUpdated(GroupChannel channel) {
    _broadcastTypingUsers(channel.channelUrl);
  }

  @override
  void onChannelChanged(BaseChannel channel) => _channelListController.add(null);

  @override
  void onUserJoined(GroupChannel channel, User user) =>
      _channelListController.add(null);

  void onUserLeft(GroupChannel channel, User user) =>
      _channelListController.add(null);

  // ── Broadcasting ─────────────────────────────────────────────────────────

  /// Schedules a debounced refetch+broadcast for [channelUrl]. Repeated calls
  /// inside the debounce window reset the timer so only one fetch fires.
  void _scheduleBroadcast(String channelUrl) {
    if (!_messageStreams.containsKey(channelUrl)) return;
    _broadcastDebouncers[channelUrl]?.cancel();
    _broadcastDebouncers[channelUrl] = Timer(_config.broadcastDebounce, () {
      _broadcastDebouncers.remove(channelUrl);
      _loadAndBroadcastMessages(channelUrl);
    });
  }

  Future<void> _loadAndBroadcastMessages(String channelUrl) async {
    try {
      final messages = await getMessages(channelUrl);
      ChatLog.d(
        '📡 [SB] broadcast | channel=${ChatLog.shortId(channelUrl)} '
        '| count=${messages.length}',
      );
      _messageStreams[channelUrl]?.add(messages);
    } catch (e) {
      // Background broadcast: never throw into the event loop. A failure here
      // just means the next event (or manual refresh) will retry.
      ChatLog.e('broadcast failed', e);
    }
  }

  Future<void> _broadcastTypingUsers(String channelUrl) async {
    try {
      final channel = await _withTimeout(GroupChannel.getChannel(channelUrl));
      final userIds = channel.getTypingUsers().map((u) => u.userId).toList();
      _typingStreams[channelUrl]?.add(userIds);
    } catch (e) {
      ChatLog.e('typing users failed', e);
    }
  }

  // ── Connection management ────────────────────────────────────────────────

  @override
  Future<void> connect(
    String userId, {
    String? nickname,
    String? accessToken,
  }) async {
    try {
      _currentUserId = userId;
      final user = await _withTimeout(
        _sendbird.connect(userId, accessToken: accessToken),
      );
      if (nickname != null && nickname.isNotEmpty) {
        await _withTimeout(_sendbird.updateCurrentUserInfo(nickname: nickname));
      }
      ChatLog.d('🔌 [SB] connect ok as ${ChatLog.shortId(user.userId)}');
      _connectionController.add(null);
    } catch (e) {
      ChatLog.e('connect failed', e);
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _withTimeout(_sendbird.disconnect());
      _currentUserId = null;
      ChatLog.d('🔌 [SB] disconnected');
      _connectionController.add(null);
    } catch (e) {
      ChatLog.e('disconnect failed', e);
      rethrow;
    }
  }

  @override
  Future<bool> isConnected() async => _sendbird.currentUser != null;

  // ── Channel management ───────────────────────────────────────────────────

  @override
  Future<List<Conversation>> getChannels({
    SBChannelFilter filter = SBChannelFilter.all,
    int limit = 20,
    String? token,
  }) async {
    // Rethrow on failure (checklist 5.1): the conversations StreamProvider must
    // distinguish "network failed → show retry" from "genuinely empty list".
    final query = GroupChannelListQuery()..limit = limit;
    final channels = await _withTimeout(query.loadNext());
    ChatLog.d('📋 [SB] getChannels | count=${channels.length}');
    return channels
        .map((c) => Conversation.fromSBChannel(
              _mapToSBChannel(c),
              _currentUserId ?? '',
            ))
        .toList();
  }

  SBChannel _mapToSBChannel(GroupChannel channel) {
    return SBChannel(
      channelUrl: channel.channelUrl,
      name: channel.name ?? '',
      coverUrl: channel.coverUrl,
      customType: channel.customType,
      channelType: channel.isPublic ? SBChannelType.open : SBChannelType.group,
      createdAt: channel.createdAt != null
          ? DateTime.fromMillisecondsSinceEpoch(channel.createdAt!)
          : DateTime.now(),
      updatedAt: channel.lastMessage?.createdAt != null
          ? DateTime.fromMillisecondsSinceEpoch(channel.lastMessage!.createdAt)
          : channel.createdAt != null
              ? DateTime.fromMillisecondsSinceEpoch(channel.createdAt!)
              : DateTime.now(),
      lastMessage: channel.lastMessage != null
          ? _mapToSBMessage(channel.lastMessage!)
          : null,
      unreadMessageCount: channel.unreadMessageCount,
      members: channel.members
          .map((m) => SBUser(
                userId: m.userId,
                nickname: m.nickname,
                profileUrl: m.profileUrl,
              ))
          .toList(),
      invitedMembers: const [],
      isDistinct: channel.isDistinct,
      isPublic: channel.isPublic,
      isEphemeral: channel.isEphemeral,
      isSuper: channel.isSuper,
      isBroadcast: channel.isBroadcast,
      isFrozen: channel.isFrozen,
      data: channel.data != null ? {'raw': channel.data} : null,
      messageOffsetTimestamp: channel.messageOffsetTimestamp ?? 0,
      messageSurvivalSeconds: channel.messageSurvivalSeconds,
    );
  }

  // Sendbird returns "" instead of null when no data is set. jsonDecode("")
  // throws FormatException — guard against it here.
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
        message: message.message,
        sender: message.sender != null
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
        // secureUrl appends ?auth=<eKey> when Sendbird file access control is
        // enabled (requireAuth=true). Without it every CDN request returns 401.
        url: message.secureUrl ?? message.url,
        name: message.name ?? '',
        type: message.type ?? '',
        size: message.size ?? 0,
        message: message.message,
        sender: message.sender != null
            ? SBUser(
                userId: message.sender!.userId,
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
      final params = GroupChannelParams()
        ..name = name
        ..userIds = userIds
        ..isDistinct = isDistinct
        ..isPublic = isPublic
        ..data = data?.toString();

      final channel = await _withTimeout(GroupChannel.createChannel(params));
      ChatLog.d(
        '🔨 [SB] createChannel | url=${ChatLog.shortId(channel.channelUrl)} '
        '| members=${channel.members.length}',
      );
      return Conversation.fromSBChannel(
        _mapToSBChannel(channel),
        _currentUserId ?? '',
      );
    } catch (e) {
      ChatLog.e('createChannel failed', e);
      rethrow;
    }
  }

  @override
  Future<Conversation> getChannel(String channelUrl) async {
    try {
      final channel = await _withTimeout(GroupChannel.getChannel(channelUrl));
      return Conversation.fromSBChannel(
        _mapToSBChannel(channel),
        _currentUserId ?? '',
      );
    } catch (e) {
      ChatLog.e('getChannel failed', e);
      rethrow;
    }
  }

  @override
  Future<void> joinChannel(String channelUrl) async {
    try {
      final channel = await _withTimeout(GroupChannel.getChannel(channelUrl));
      await _withTimeout(channel.join());
    } catch (e) {
      ChatLog.e('joinChannel failed', e);
      rethrow;
    }
  }

  @override
  Future<void> leaveChannel(String channelUrl) async {
    try {
      final channel = await _withTimeout(GroupChannel.getChannel(channelUrl));
      await _withTimeout(channel.leave());
    } catch (e) {
      ChatLog.e('leaveChannel failed', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteChannel(String channelUrl) async {
    try {
      final channel = await _withTimeout(GroupChannel.getChannel(channelUrl));
      await _withTimeout(channel.deleteChannel());
    } catch (e) {
      ChatLog.e('deleteChannel failed', e);
      rethrow;
    }
  }

  @override
  Future<void> freezeChannel(String channelUrl, bool freeze) async {
    try {
      final channel = await _withTimeout(GroupChannel.getChannel(channelUrl));
      if (freeze) {
        await _withTimeout(channel.freeze());
      } else {
        await _withTimeout(channel.unfreeze());
      }
    } catch (e) {
      ChatLog.e('freezeChannel failed', e);
      rethrow;
    }
  }

  // ── Message management ───────────────────────────────────────────────────

  @override
  Future<List<Message>> getMessages(
    String channelUrl, {
    int? limit,
    String? token,
    bool reverse = true,
  }) async {
    // Rethrow on failure (checklist 5.1): an empty list must mean "no messages",
    // not "the fetch failed". Callers surface the error as a retryable state.
    final channel = await _withTimeout(GroupChannel.getChannel(channelUrl));

    // reverse=true → newest-first; with ListView(reverse:true) index-0 sits at
    // the bottom near the composer. replyType.all keeps quoted replies inline.
    final params = MessageListParams()
      ..previousResultSize = limit ?? _config.messagePageSize
      ..reverse = true
      ..replyType = ReplyType.all;

    // token is the oldest message's timestamp in ms (pagination cursor).
    final timestamp = token != null
        ? (int.tryParse(token) ?? DateTime.now().millisecondsSinceEpoch)
        : DateTime.now().millisecondsSinceEpoch;

    final messages =
        await _withTimeout(channel.getMessagesByTimestamp(timestamp, params));
    ChatLog.d(
      '📥 [SB] getMessages | channel=${ChatLog.shortId(channelUrl)} '
      '| count=${messages.length}',
    );

    return messages
        .map((m) => Message.fromSBMessage(_mapToSBMessage(m), _currentUserId ?? ''))
        .toList();
  }

  @override
  Future<Message> sendTextMessage(
    String channelUrl,
    String content, {
    Map<String, dynamic>? data,
    int? parentMessageId,
  }) async {
    try {
      final channel = await _withTimeout(GroupChannel.getChannel(channelUrl));

      final params = UserMessageParams(message: content)
        ..data = data != null ? jsonEncode(data) : null
        ..parentMessageId = parentMessageId
        ..replyToChannel = parentMessageId != null;

      final completer = Completer<UserMessage>();
      channel.sendUserMessage(
        params,
        onCompleted: (message, error) {
          if (error != null) {
            completer.completeError(error);
          } else {
            completer.complete(message);
          }
        },
      );

      final message = await _withTimeout(completer.future);
      ChatLog.d('✅ [SB] sendText ok | msgId=${message.messageId}');
      // onMessageReceived never fires for the sender — broadcast manually so the
      // sender's list updates immediately.
      unawaited(_loadAndBroadcastMessages(channelUrl));
      return Message.fromSBMessage(_mapToSBMessage(message), _currentUserId ?? '');
    } catch (e) {
      ChatLog.e('sendText failed', e);
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
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final channel = await _withTimeout(GroupChannel.getChannel(channelUrl));

      final file = File(filePath);
      final params = FileMessageParams.withFile(file, name: fileName);
      // Override auto-detected MIME: temp paths from image_picker / cropper may
      // lack a recognised extension, so detection can mis-type or fail.
      params.uploadFile = FileInfo.fromData(
        name: fileName,
        file: file,
        mimeType: mimeType,
      );
      params.data = data != null ? jsonEncode(data) : null;

      final completer = Completer<FileMessage>();
      channel.sendFileMessage(
        params,
        progress: onProgress,
        onCompleted: (message, error) {
          if (error != null) {
            completer.completeError(error);
          } else {
            completer.complete(message);
          }
        },
      );

      // No _withTimeout here: large uploads legitimately exceed the per-request
      // timeout. Progress is surfaced via onProgress; the UI shows a bar and a
      // cancel/retry affordance instead of a hard deadline.
      final message = await completer.future;
      ChatLog.d('✅ [SB] sendFile ok | msgId=${message.messageId}');
      unawaited(_loadAndBroadcastMessages(channelUrl));
      return Message.fromSBMessage(_mapToSBMessage(message), _currentUserId ?? '');
    } catch (e) {
      ChatLog.e('sendFile failed', e);
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
      final channel = await _withTimeout(GroupChannel.getChannel(channelUrl));
      await _withTimeout(
        channel.updateUserMessage(messageId, UserMessageParams(message: content)),
      );
    } catch (e) {
      ChatLog.e('updateMessage failed', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteMessage(String channelUrl, int messageId) async {
    try {
      final channel = await _withTimeout(GroupChannel.getChannel(channelUrl));
      await _withTimeout(channel.deleteMessage(messageId));
    } catch (e) {
      ChatLog.e('deleteMessage failed', e);
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String channelUrl) async {
    try {
      final channel = await _withTimeout(GroupChannel.getChannel(channelUrl));
      await _withTimeout(channel.markAsRead());
    } catch (e) {
      // Non-fatal: read receipts are best-effort.
      ChatLog.e('markAsRead failed', e);
    }
  }

  @override
  Future<void> markAsDelivered(String channelUrl) async {
    // markAsDelivered() does not exist on GroupChannel in Flutter SDK v3;
    // delivery receipts are tracked automatically by the SDK. Intentional no-op.
  }

  // ── Real-time listeners ──────────────────────────────────────────────────

  @override
  Stream<List<Message>> watchMessages(String channelUrl) {
    final controller = _messageStreams.putIfAbsent(channelUrl, () {
      final c = StreamController<List<Message>>.broadcast();
      // First load on subscription. The class-level mixin handler (registered
      // once) handles realtime updates for every channel.
      _loadAndBroadcastMessages(channelUrl);
      return c;
    });
    return controller.stream;
  }

  @override
  Stream<List<String>> watchTypingUsers(String channelUrl) {
    final controller = _typingStreams.putIfAbsent(channelUrl, () {
      final c = StreamController<List<String>>.broadcast();
      c.add(const []);
      return c;
    });
    return controller.stream;
  }

  @override
  Stream<int> watchUnreadCount() => _unreadCountController.stream;

  @override
  Stream<void> watchConnectionStatus() => _connectionController.stream;

  @override
  Stream<void> watchChannelListChanges() => _channelListController.stream;

  // ── User management ──────────────────────────────────────────────────────

  @override
  Future<void> updateUserProfile({String? nickname, String? profileUrl}) async {
    try {
      await _withTimeout(_sendbird.updateCurrentUserInfo(nickname: nickname));
    } catch (e) {
      ChatLog.e('updateUserProfile failed', e);
      rethrow;
    }
  }

  @override
  Future<void> startTyping(String channelUrl) async {
    try {
      final channel = await _withTimeout(GroupChannel.getChannel(channelUrl));
      channel.startTyping();
    } catch (e) {
      ChatLog.e('startTyping failed', e);
    }
  }

  @override
  Future<void> endTyping(String channelUrl) async {
    try {
      final channel = await _withTimeout(GroupChannel.getChannel(channelUrl));
      channel.endTyping();
    } catch (e) {
      ChatLog.e('endTyping failed', e);
    }
  }

  // ── Cleanup ──────────────────────────────────────────────────────────────

  @override
  Future<void> dispose() async {
    // Remove handlers before closing streams to avoid stale callbacks firing
    // during teardown.
    _sendbird.removeChannelEventHandler('main');
    _sendbird.removeConnectionEventHandler('main');

    for (final t in _broadcastDebouncers.values) {
      t.cancel();
    }
    _broadcastDebouncers.clear();

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
