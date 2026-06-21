import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/chat/config/chat_config.dart';
import 'package:nano_embryo/presentation/features/chat/data/cache/chat_cache_service.dart';
import 'package:nano_embryo/presentation/features/chat/data/cache/pending_send.dart';
import 'package:nano_embryo/presentation/features/chat/data/repositories/chat_repository.dart';
import 'package:nano_embryo/presentation/features/chat/data/repositories/sendbird_chat_repository.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/conversation.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/message.dart';
import 'package:nano_embryo/presentation/features/chat/utils/chat_error.dart';
import 'package:nano_embryo/presentation/features/chat/utils/chat_log.dart';
import 'package:nano_embryo/core/notifications/presentation/providers/notification_provider.dart';
import 'package:sendbird_sdk/sdk/sendbird_sdk_api.dart';

// ─── Repository provider ─────────────────────────────────────────────────────
// App ID comes from ChatConfig — no hardcoded env var.

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final config = ref.read(chatConfigProvider);
  final sendbird = SendbirdSdk(appId: config.appId);
  return SendbirdChatRepository(sendbird, config: config);
});

// ─── Connection ──────────────────────────────────────────────────────────────

final connectionProvider = StateNotifierProvider<ConnectionNotifier, bool>(
  (ref) => ConnectionNotifier(ref.read(chatRepositoryProvider), ref),
);

class ConnectionNotifier extends StateNotifier<bool> with WidgetsBindingObserver {
  final ChatRepository _repository;
  final Ref _ref;
  StreamSubscription? _subscription;

  ConnectionNotifier(this._repository, this._ref) : super(false) {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    final connected = await _repository.isConnected();
    if (mounted) state = connected;

    _subscription = _repository.watchConnectionStatus().listen((_) async {
      final newState = await _repository.isConnected();
      if (mounted && newState != state) state = newState;
    });

    // Auto-connect using the authenticated Supabase user ID.
    if (!state) {
      final currentUser = _ref.read(currentUserProvider);
      if (currentUser != null) {
        await connect(currentUser.id);
      }
    }
  }

  Future<void> connect(String userId, {String? nickname}) async {
    final accessToken = await _fetchSendbirdToken();
    await _repository.connect(userId, nickname: nickname, accessToken: accessToken);
    if (mounted) state = true;
  }

  Future<String?> _fetchSendbirdToken() async {
    try {
      final config = _ref.read(chatConfigProvider);
      final supabase = _ref.read(supabaseClientProvider);
      final session = supabase.auth.currentSession;
      if (session == null) {
        ChatLog.d('🔑 [SB] token skipped — no Supabase session yet');
        return null;
      }
      // 1.2: bound the edge-function call so connect() can't hang forever.
      final response = await supabase.functions
          .invoke(
            config.tokenFunctionName,
            headers: {'Authorization': 'Bearer ${session.accessToken}'},
          )
          .timeout(config.networkTimeout);
      final data = response.data as Map<String, dynamic>?;
      return data?['token'] as String?;
    } catch (e) {
      // Non-fatal: fall back to connecting without a session token.
      ChatLog.e('fetch Sendbird token failed', e);
      return null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !this.state) {
      final currentUser = _ref.read(currentUserProvider);
      if (currentUser != null) {
        connect(currentUser.id);
      }
    }
  }

  Future<void> disconnect() async {
    await _repository.disconnect();
    if (mounted) state = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    super.dispose();
  }
}

// ─── Conversations (real-time) ────────────────────────────────────────────────
// Uses StreamController + ref.listen instead of async* + ref.watch so that
// Sendbird reconnects trigger a silent refresh() rather than restarting the
// generator (which would emit AsyncLoading and flash a spinner).

final conversationsProvider = StreamProvider<List<Conversation>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  final cache = ref.read(chatCacheServiceProvider);
  final controller = StreamController<List<Conversation>>();

  Future<void> refresh() async {
    try {
      final channels = await repository.getChannels();
      if (!controller.isClosed) {
        controller.add(channels);
        // R8: write-through so next cold-start skips the spinner.
        if (channels.isNotEmpty) {
          unawaited(cache.writeConversations(channels));
        }
      }
    } catch (e) {
      if (!controller.isClosed) controller.addError(e);
    }
  }

  // Reconnect → silent refresh; no AsyncLoading emitted.
  ref.listen<bool>(connectionProvider, (prev, next) {
    if (next == true && prev != true) refresh();
  });

  // Re-fetch when any channel metadata changes (new message, unread count, etc.)
  final channelSub = repository.watchChannelListChanges().listen((_) => refresh());

  ref.onDispose(() {
    channelSub.cancel();
    controller.close();
  });

  // R7: emit cached list synchronously so first frame has no spinner.
  final cached = cache.readConversations();
  if (cached.isNotEmpty) controller.add(cached);

  // Always attempt a fetch on creation. If Sendbird isn't connected yet,
  // getChannels() will throw and the stream emits an error (retryable UI)
  // instead of spinning forever. The ref.listen above will fire a clean
  // refresh when the connection comes up.
  refresh();

  return controller.stream;
});

// ─── Messages per channel ─────────────────────────────────────────────────────

final messagesProvider = StreamProvider.family<List<Message>, String>((
  ref,
  channelUrl,
) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchMessages(channelUrl);
});

// ─── Typing users per channel ─────────────────────────────────────────────────

final typingUsersProvider = StreamProvider.family<List<String>, String>((
  ref,
  channelUrl,
) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchTypingUsers(channelUrl);
});

// ─── Total unread count ───────────────────────────────────────────────────────

final unreadCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchUnreadCount();
});

// ─── Chat controller ──────────────────────────────────────────────────────────
// keepAlive: state stays in memory for 5 minutes after the last listener leaves
// so navigating back to a channel skips the Sendbird fetch entirely.

final chatControllerProvider = StateNotifierProvider.autoDispose
    .family<ChatController, ChatState, String>((ref, channelUrl) {
      final link = ref.keepAlive();
      final keepAlive = ref.read(chatConfigProvider).controllerKeepAlive;
      Timer? evictTimer;

      ref.onCancel(() {
        evictTimer = Timer(keepAlive, link.close);
      });
      ref.onResume(() => evictTimer?.cancel());
      ref.onDispose(() => evictTimer?.cancel());

      return ChatController(ref, channelUrl);
    });

class ChatController extends StateNotifier<ChatState> {
  final Ref ref;
  final String channelUrl;

  // G4: coalesce the markAsRead spam the scroll listener produces. Without this
  // every scroll-to-bottom fires a network call; debounced it fires at most
  // once per window.
  Timer? _markReadDebounce;

  ChatController(this.ref, this.channelUrl) : super(ChatState.initial()) {
    _init();
  }

  Future<void> _init() async {
    // Layer 2: pre-populate from Hive so the first frame shows cached messages
    // with no spinner. loadMessages() below will only show the spinner when
    // state.messages is still empty (genuine cold start with no cache).
    final cached = ref.read(chatCacheServiceProvider).readMessages(channelUrl);
    if (cached.isNotEmpty && mounted) {
      state = state.copyWith(messages: cached);
    }

    await loadMessages();
    _subscribeToMessages();
    _subscribeToTyping();
    _subscribeToConnection();
    await markAsRead();

    // G3: replay anything left over from a previous session (app killed mid-
    // send) now that the channel is loaded. Safe: confirmed entries were already
    // removed from the outbox; clientReqId guards against double-posting.
    unawaited(flushOutbox());
  }

  /// G3: when the connection recovers, replay any queued sends for this channel.
  void _subscribeToConnection() {
    ref.listen<bool>(connectionProvider, (prev, next) {
      if (next == true && prev != true) {
        unawaited(flushOutbox());
      }
    });
  }

  Future<void> loadMessages() async {
    if (!mounted) return;
    // Only show the spinner when there are no messages to display yet.
    // If _init() pre-populated from cache, state.messages is non-empty and
    // the Sendbird fetch runs silently in the background.
    if (state.messages.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    }
    try {
      final pageSize = ref.read(chatConfigProvider).messagePageSize;
      final repository = ref.read(chatRepositoryProvider);
      final messages =
          await repository.getMessages(channelUrl, limit: pageSize);
      ChatLog.d(
        '🔄 [LOAD] channel=${ChatLog.shortId(channelUrl)} | count=${messages.length}',
      );
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        messages: messages,
        hasMore: messages.length >= pageSize,
      );
      // Write-through: keep Hive in sync after every successful fetch.
      unawaited(
        ref.read(chatCacheServiceProvider).writeMessages(channelUrl, messages),
      );
    } catch (e) {
      ChatLog.e('loadMessages failed', e);
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          error: ChatError.toUserMessage(e),
        );
      }
    }
  }

  Future<void> loadMoreMessages() async {
    if (!mounted || state.isLoadingMore || !state.hasMore) return;
    if (state.messages.isEmpty) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final pageSize = ref.read(chatConfigProvider).messagePageSize;
      final repository = ref.read(chatRepositoryProvider);
      final oldest = state.messages.last;
      final olderMessages = await repository.getMessages(
        channelUrl,
        limit: pageSize,
        token: oldest.timestamp.millisecondsSinceEpoch.toString(),
      );
      if (!mounted) return;
      state = state.copyWith(
        isLoadingMore: false,
        messages: [...state.messages, ...olderMessages],
        hasMore: olderMessages.length >= pageSize,
      );
    } catch (e) {
      ChatLog.e('loadMoreMessages failed', e);
      if (mounted) state = state.copyWith(isLoadingMore: false);
    }
  }

  void _subscribeToMessages() {
    ref.listen(messagesProvider(channelUrl), (_, next) {
      next.whenData((messages) {
        ChatLog.d(
          '🔔 [SUB] channel=${ChatLog.shortId(channelUrl)} | ${messages.length} msgs',
        );
        if (mounted) {
          final existing = {for (final m in state.messages) m.id: m};

          // G8: index any optimistic bubbles by their client_req_id so a
          // confirmed message carrying the same id can (a) inherit the local
          // file path for a seamless thumbnail and (b) let us drop the now-
          // redundant optimistic placeholder + clear it from the outbox.
          final optByReqId = <String, Message>{};
          for (final m in state.messages) {
            if (!m.id.startsWith('_opt_')) continue;
            final rid = m.metadata?['client_req_id'] as String?;
            if (rid != null) optByReqId[rid] = m;
          }

          final confirmedReqIds = <String>{};
          final enriched = messages.map((m) {
            final prev = existing[m.id];
            final rid = m.metadata?['client_req_id'] as String?;
            final opt = rid != null ? optByReqId[rid] : null;
            if (rid != null && opt != null) {
              confirmedReqIds.add(rid);
              // Inherit the local file path from the optimistic twin.
              return m.copyWith(localFilePath: opt.localFilePath);
            }
            return (prev?.localFilePath != null)
                ? m.copyWith(localFilePath: prev!.localFilePath)
                : m;
          }).toList();

          // The confirmed message replaced its optimistic twin → remove it from
          // the durable outbox (it landed via realtime, not our own await).
          if (confirmedReqIds.isNotEmpty) {
            final cache = ref.read(chatCacheServiceProvider);
            for (final rid in confirmedReqIds) {
              unawaited(cache.removeOutbox(rid));
            }
          }

          // Merge: retain confirmed (non-optimistic) messages in current state
          // absent from the incoming list (guards the send→refetch race), and
          // drop any optimistic bubble now superseded by a confirmed twin (G8).
          final incomingIds = {for (final m in enriched) m.id};
          final preserved = state.messages.where((m) {
            if (m.id.startsWith('_opt_')) {
              final rid = m.metadata?['client_req_id'] as String?;
              // Drop optimistic bubbles whose confirmed twin just arrived.
              return !(rid != null && confirmedReqIds.contains(rid));
            }
            return !incomingIds.contains(m.id);
          }).toList();

          final merged = preserved.isEmpty
              ? enriched
              : ([...enriched, ...preserved]
                  ..sort((a, b) => b.timestamp.compareTo(a.timestamp)));

          state = state.copyWith(messages: merged);
          // Write-through: only cache Sendbird-sourced messages (not preserved locals).
          unawaited(
            ref.read(chatCacheServiceProvider).writeMessages(channelUrl, messages),
          );
        }
      });
    });
  }

  void _subscribeToTyping() {
    ref.listen(typingUsersProvider(channelUrl), (_, next) {
      next.whenData((typingUsers) {
        if (mounted) state = state.copyWith(typingUsers: typingUsers);
      });
    });
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || !mounted) return;

    // Capture reply target before clearing it from state.
    final replyToId = state.replyingToMessage?.id;
    final parentMessageId = replyToId != null ? int.tryParse(replyToId) : null;

    final requestId = _newRequestId();

    // G3: persist the intent BEFORE the optimistic insert so an app kill mid-
    // send doesn't lose the message — it'll be replayed from the outbox on next
    // launch. clientReqId rides every retry (2.18 / 2.20).
    final pending = PendingSend(
      clientReqId: requestId,
      channelUrl: channelUrl,
      kind: PendingSendKind.text,
      text: content,
      parentMessageId: parentMessageId,
      data: {'client_req_id': requestId},
      createdAt: DateTime.now(),
    );
    unawaited(ref.read(chatCacheServiceProvider).putOutbox(pending));

    // Optimistic UI: insert a pending message immediately. The optimistic id is
    // derived from the requestId so a later confirmed message carrying the same
    // client_req_id can collapse it (G8 dedupe).
    final optimisticMsg = Message(
      id: _optIdFor(requestId),
      content: content,
      timestamp: DateTime.now(),
      sender: MessageSender.user,
      status: MessageStatus.sending,
      replyToMessageId: replyToId,
      metadata: {'client_req_id': requestId},
    );
    state = state.copyWith(
      isSending: true,
      messages: [optimisticMsg, ...state.messages],
      clearReplyingToMessage: true,
    );

    await _attemptTextSend(pending);
  }

  /// Performs (or retries) the network send for a queued text [pending].
  /// On success removes it from the outbox; on failure leaves it queued and
  /// flips the optimistic bubble to failed so the user can tap-retry (G1).
  Future<void> _attemptTextSend(PendingSend pending) async {
    final cache = ref.read(chatCacheServiceProvider);
    try {
      final repository = ref.read(chatRepositoryProvider);
      await repository.sendTextMessage(
        channelUrl,
        pending.text ?? '',
        parentMessageId: pending.parentMessageId,
        data: pending.data,
      );
      await repository.markAsRead(channelUrl);
      await cache.removeOutbox(pending.clientReqId);
      if (mounted) state = state.copyWith(isSending: false);
      unawaited(_notifyOtherParticipants(preview: pending.text ?? ''));
    } catch (e) {
      ChatLog.e('text send failed', e);
      await cache.putOutbox(pending.copyWith(attempts: pending.attempts + 1));
      if (mounted) {
        state = state.copyWith(
          isSending: false,
          messages: _markFailed(_optIdFor(pending.clientReqId)),
          error: ChatError.toUserMessage(e),
        );
      }
    }
  }

  /// Optimistic id derived from a clientReqId so confirmed messages carrying the
  /// same id can be matched back to their optimistic placeholder (G8).
  static String _optIdFor(String requestId) => '_opt_$requestId';

  List<Message> _markFailed(String messageId) => state.messages
      .map((m) =>
          m.id == messageId ? m.copyWith(status: MessageStatus.failed) : m)
      .toList();

  /// G1: re-send a message the user tapped after it failed. Reuses the original
  /// clientReqId (never regenerated — 2.20) so it can't double-post.
  Future<void> retryMessage(String messageId) async {
    if (!mounted) return;
    final cache = ref.read(chatCacheServiceProvider);
    // Find the queued send backing this optimistic bubble.
    final reqId = messageId.startsWith('_opt_')
        ? messageId.substring('_opt_'.length)
        : null;
    PendingSend? pending;
    for (final p in cache.readOutbox()) {
      if (p.clientReqId == reqId) {
        pending = p;
        break;
      }
    }
    if (pending == null) {
      ChatLog.d('🔁 [RETRY] no outbox entry for ${ChatLog.shortId(messageId)}');
      return;
    }

    // Flip the bubble back to "sending" while we retry.
    state = state.copyWith(
      messages: state.messages
          .map((m) => m.id == messageId
              ? m.copyWith(status: MessageStatus.sending)
              : m)
          .toList(),
    );

    if (pending.kind == PendingSendKind.text) {
      await _attemptTextSend(pending);
    } else {
      await _attemptFileSend(pending);
    }
  }

  /// G3: replay every queued send for this channel, oldest first. Called when
  /// the connection comes back. Skips entries already represented by a non-
  /// failed optimistic bubble to avoid racing an in-flight attempt.
  Future<void> flushOutbox() async {
    if (!mounted) return;
    final cache = ref.read(chatCacheServiceProvider);
    final queued =
        cache.readOutbox().where((p) => p.channelUrl == channelUrl).toList();
    if (queued.isEmpty) return;
    ChatLog.d('🔁 [FLUSH] ${queued.length} queued send(s) for '
        '${ChatLog.shortId(channelUrl)}');

    for (final pending in queued) {
      if (!mounted) return;
      final optId = _optIdFor(pending.clientReqId);
      // Ensure an optimistic bubble exists (e.g. after a cold start where the
      // outbox survived but state didn't).
      if (!state.messages.any((m) => m.id == optId)) {
        state = state.copyWith(messages: [
          Message(
            id: optId,
            content: pending.text ?? pending.caption ?? '',
            timestamp: pending.createdAt,
            sender: MessageSender.user,
            status: MessageStatus.sending,
            type: pending.kind == PendingSendKind.file
                ? MessageType.file
                : MessageType.text,
            fileName: pending.fileName,
            localFilePath: pending.filePath,
            metadata: pending.data,
          ),
          ...state.messages,
        ]);
      }
      if (pending.kind == PendingSendKind.text) {
        await _attemptTextSend(pending);
      } else {
        await _attemptFileSend(pending);
      }
    }
  }

  /// Stable client request id used as a send dedupe key (checklist 2.18).
  static String _newRequestId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_seq++}';
  static int _seq = 0;

  Future<void> sendFileMessage({
    required String filePath,
    required String fileName,
    required String mimeType,
    String? caption,
    Map<String, dynamic>? data,
  }) async {
    if (!mounted) return;

    // 2.5: enforce the size limit at the controller boundary, not only in the
    // UI. Reject oversized files before allocating an optimistic bubble.
    final maxBytes = ref.read(chatConfigProvider).maxFileSizeBytes;
    try {
      final length = await File(filePath).length();
      if (length > maxBytes) {
        final mb = (maxBytes / (1024 * 1024)).round();
        state = state.copyWith(error: 'That file is too large. Maximum size is $mb MB.');
        return;
      }
    } catch (e) {
      ChatLog.e('file size check failed', e);
      // If we can't stat the file, fall through — the SDK upload will surface
      // a real error and we map it below.
    }

    // Stable client request id for send dedupe (checklist 2.18).
    final requestId = _newRequestId();
    final sendData = {...?data, 'client_req_id': requestId};

    // Derive message type from MIME so the bubble renders correctly.
    final MessageType optimisticType;
    if (mimeType.startsWith('image/')) {
      optimisticType = MessageType.image;
    } else if (mimeType.startsWith('video/')) {
      optimisticType = MessageType.video;
    } else if (mimeType.startsWith('audio/')) {
      optimisticType = MessageType.audio;
    } else {
      optimisticType = MessageType.file;
    }

    // G3: persist the send intent. The local file path is captured so a retry
    // (even after a cold start) can re-upload from disk.
    final pending = PendingSend(
      clientReqId: requestId,
      channelUrl: channelUrl,
      kind: PendingSendKind.file,
      filePath: filePath,
      fileName: fileName,
      mimeType: mimeType,
      caption: caption,
      data: sendData,
      createdAt: DateTime.now(),
    );
    unawaited(ref.read(chatCacheServiceProvider).putOutbox(pending));

    // Optimistic message — shows the local file immediately while uploading.
    final optimisticMsg = Message(
      id: _optIdFor(requestId),
      content: caption ?? '',
      timestamp: DateTime.now(),
      sender: MessageSender.user,
      status: MessageStatus.sending,
      type: optimisticType,
      fileName: fileName,
      localFilePath: filePath,
      metadata: sendData,
    );

    state = state.copyWith(
      isSending: true,
      fileUploadProgress: 0.0,
      messages: [optimisticMsg, ...state.messages],
    );

    await _attemptFileSend(pending);
  }

  /// Performs (or retries) a queued file upload. Mirrors [_attemptTextSend]:
  /// removes from the outbox on success, keeps it queued + marks failed on
  /// error so the bubble offers tap-to-retry (G1).
  Future<void> _attemptFileSend(PendingSend pending) async {
    final cache = ref.read(chatCacheServiceProvider);
    final optId = _optIdFor(pending.clientReqId);
    try {
      final repository = ref.read(chatRepositoryProvider);
      final confirmed = await repository.sendFileMessage(
        channelUrl,
        pending.filePath ?? '',
        pending.fileName ?? 'file',
        pending.mimeType ?? 'application/octet-stream',
        caption: pending.caption,
        data: pending.data,
        onProgress: (sent, total) {
          if (mounted && total > 0) {
            state = state.copyWith(fileUploadProgress: sent / total);
          }
        },
      );
      await cache.removeOutbox(pending.clientReqId);
      if (mounted) {
        // Swap the optimistic message out for the confirmed Sendbird message,
        // preserving localFilePath so the bubble shows the local file as the
        // CachedNetworkImage placeholder while the CDN download completes.
        final updated = state.messages.map((m) {
          return m.id == optId
              ? confirmed.copyWith(localFilePath: m.localFilePath)
              : m;
        }).toList();
        state = state.copyWith(
          isSending: false,
          clearFileUploadProgress: true,
          messages: updated,
        );

        final isLocation = pending.data?['type'] == 'location';
        final caption = pending.caption;
        final preview = isLocation
            ? '📍 Location'
            : (caption != null && caption.trim().isNotEmpty
                ? caption
                : _filePreview(
                    pending.mimeType ?? '',
                    fileName: pending.fileName,
                  ));
        unawaited(_notifyOtherParticipants(preview: preview));
      }
    } catch (e) {
      ChatLog.e('file send failed', e);
      await cache.putOutbox(pending.copyWith(attempts: pending.attempts + 1));
      if (mounted) {
        state = state.copyWith(
          isSending: false,
          error: ChatError.toUserMessage(e),
          clearFileUploadProgress: true,
          messages: _markFailed(optId),
        );
      }
    }
  }

  Future<void> deleteMessage(String messageId) async {
    if (!mounted) return;
    // Optimistically remove from local state
    final updated = state.messages.where((m) => m.id != messageId).toList();
    state = state.copyWith(messages: updated);
    try {
      final repository = ref.read(chatRepositoryProvider);
      await repository.deleteMessage(channelUrl, int.parse(messageId));
    } catch (e) {
      ChatLog.e('deleteMessage failed', e);
      // Re-fetch on failure so state stays consistent
      await loadMessages();
      if (mounted) state = state.copyWith(error: ChatError.toUserMessage(e));
    }
  }

  Future<void> editMessage(String messageId, String newContent) async {
    if (!mounted || newContent.trim().isEmpty) return;
    // Optimistically update content in local state
    final updated = state.messages.map((m) {
      return m.id == messageId ? m.copyWith(content: newContent) : m;
    }).toList();
    state = state.copyWith(messages: updated, clearEditingMessageId: true);
    try {
      final repository = ref.read(chatRepositoryProvider);
      await repository.updateMessage(channelUrl, int.parse(messageId), newContent);
    } catch (e) {
      ChatLog.e('editMessage failed', e);
      await loadMessages();
      if (mounted) state = state.copyWith(error: ChatError.toUserMessage(e));
    }
  }

  void startEditing(String messageId) {
    if (mounted) state = state.copyWith(editingMessageId: messageId);
  }

  void cancelEditing() {
    if (mounted) state = state.copyWith(clearEditingMessageId: true);
  }

  void startReplying(Message message) {
    if (mounted) state = state.copyWith(replyingToMessage: message);
  }

  void cancelReplying() {
    if (mounted) state = state.copyWith(clearReplyingToMessage: true);
  }

  Future<void> startTyping() async {
    final repository = ref.read(chatRepositoryProvider);
    await repository.startTyping(channelUrl);
  }

  Future<void> endTyping() async {
    final repository = ref.read(chatRepositoryProvider);
    await repository.endTyping(channelUrl);
  }

  Future<void> markAsRead() async {
    final repository = ref.read(chatRepositoryProvider);
    await repository.markAsRead(channelUrl);
  }

  /// G4: debounced markAsRead for high-frequency callers (the scroll listener).
  /// Collapses a burst of scroll events into a single network call.
  void markAsReadDebounced() {
    _markReadDebounce?.cancel();
    _markReadDebounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) markAsRead();
    });
  }

  @override
  void dispose() {
    _markReadDebounce?.cancel();
    super.dispose();
  }

  /// Queues an OneSignal push for every other channel member after a send
  /// succeeds. Fire-and-forget — failures are swallowed because notifications
  /// must never break the chat flow. The Supabase `scheduled_notifications`
  /// cron picks up the row and calls OneSignal; the receiver's tap is routed
  /// to the chat via the `new_message` type already handled in main.dart.
  Future<void> _notifyOtherParticipants({required String preview}) async {
    ChatLog.d('🔔 [NOTIFY] start | channel=${ChatLog.shortId(channelUrl)}');
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        ChatLog.d('🔔 [NOTIFY] skipped — no current user');
        return;
      }

      final repository = ref.read(chatRepositoryProvider);
      final conv = await repository.getChannel(channelUrl);
      ChatLog.d(
        '🔔 [NOTIFY] isGroup=${conv.isGroup} '
        'participants=${ChatLog.shortIds(conv.participants)}',
      );

      final recipients =
          conv.participants.where((id) => id != user.id).toList();
      if (recipients.isEmpty) {
        ChatLog.d('🔔 [NOTIFY] no recipients');
        return;
      }

      final senderName =
          (user.userMetadata?['full_name'] as String?)?.trim().isNotEmpty == true
              ? user.userMetadata!['full_name'] as String
              : (user.userMetadata?['name'] as String?) ??
                  user.email ??
                  'Someone';

      // For group chats include the channel name so the receiver has context.
      final title = conv.isGroup ? '$senderName · ${conv.name}' : senderName;

      // Truncate the preview so the push body stays compact.
      final maxLen = ref.read(chatConfigProvider).notificationPreviewMaxLength;
      final body = preview.length > maxLen
          ? '${preview.substring(0, maxLen - 3)}...'
          : preview;

      ChatLog.d(
        '🔔 [NOTIFY] queueing ${recipients.length} push(es) | '
        'title=${ChatLog.redact(title)} body=${ChatLog.redact(body)} '
        'recipients=${ChatLog.shortIds(recipients)}',
      );

      final notificationService = ref.read(notificationServiceProvider);
      for (final recipientId in recipients) {
        try {
          // Await so failures surface here instead of being lost in unawaited.
          await notificationService.sendImmediateNotification(
            userId: recipientId,
            title: title,
            body: body,
            data: {
              'type': 'new_message',
              'channel_url': channelUrl,
              'sender_id': user.id,
            },
            priority: 'high',
          );
          ChatLog.d('🔔 [NOTIFY] ✅ queued for ${ChatLog.shortId(recipientId)}');
        } catch (e) {
          ChatLog.e('notify queue failed for ${ChatLog.shortId(recipientId)}', e);
        }
      }
    } catch (e) {
      ChatLog.e('notify unexpected error', e);
    }
  }

  /// Builds a human-readable preview from a file's MIME type, used as the
  /// push notification body when the user sends media instead of text.
  static String _filePreview(String mimeType, {String? fileName}) {
    final m = mimeType.toLowerCase();
    if (m.startsWith('image/')) return '📷 Photo';
    if (m.startsWith('video/')) return '📹 Video';
    if (m.startsWith('audio/')) return '🎤 Voice message';
    if (fileName != null && fileName.isNotEmpty) return '📎 $fileName';
    return '📎 File';
  }

  Future<void> sendProfileCard() async {
    final user = ref.read(currentUserProvider);
    if (user == null || !mounted) return;
    final name = (user.userMetadata?['full_name'] as String?) ??
        user.email ??
        user.id;
    final avatarUrl = (user.userMetadata?['avatar_url'] as String?) ?? '';
    final data = {
      'type': 'profile_card',
      'userId': user.id,
      'name': name,
      'role': 'freelancer',
      'avatarUrl': avatarUrl,
      'url': 'nano://freelancer/${user.id}',
    };
    final content = '\u{1F464} $name shared their profile';
    final sendData = {...data, 'client_req_id': _newRequestId()};
    try {
      final repository = ref.read(chatRepositoryProvider);
      await repository.sendTextMessage(channelUrl, content, data: sendData);
      unawaited(_notifyOtherParticipants(preview: content));
    } catch (e) {
      ChatLog.e('sendProfileCard failed', e);
      if (mounted) state = state.copyWith(error: ChatError.toUserMessage(e));
    }
  }

}

// ─── Chat state ───────────────────────────────────────────────────────────────

class ChatState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSending;
  final bool hasMore;
  final List<Message> messages;
  final List<String> typingUsers;
  final String? error;
  final String? editingMessageId;
  final Message? replyingToMessage;
  final double? fileUploadProgress; // null = idle; 0.0–1.0 during upload

  const ChatState({
    required this.isLoading,
    required this.isLoadingMore,
    required this.isSending,
    required this.hasMore,
    required this.messages,
    required this.typingUsers,
    this.error,
    this.editingMessageId,
    this.replyingToMessage,
    this.fileUploadProgress,
  });

  factory ChatState.initial() => const ChatState(
    isLoading: false,
    isLoadingMore: false,
    isSending: false,
    hasMore: false,
    messages: [],
    typingUsers: [],
  );

  ChatState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSending,
    bool? hasMore,
    List<Message>? messages,
    List<String>? typingUsers,
    String? error,
    String? editingMessageId,
    bool clearEditingMessageId = false,
    Message? replyingToMessage,
    bool clearReplyingToMessage = false,
    double? fileUploadProgress,
    bool clearFileUploadProgress = false,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSending: isSending ?? this.isSending,
      hasMore: hasMore ?? this.hasMore,
      messages: messages ?? this.messages,
      typingUsers: typingUsers ?? this.typingUsers,
      error: error,
      editingMessageId: clearEditingMessageId ? null : (editingMessageId ?? this.editingMessageId),
      replyingToMessage: clearReplyingToMessage ? null : (replyingToMessage ?? this.replyingToMessage),
      fileUploadProgress: clearFileUploadProgress ? null : (fileUploadProgress ?? this.fileUploadProgress),
    );
  }
}
