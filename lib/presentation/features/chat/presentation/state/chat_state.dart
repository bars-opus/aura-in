import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/chat/config/chat_config.dart';
import 'package:nano_embryo/presentation/features/chat/data/cache/chat_cache_service.dart';
import 'package:nano_embryo/presentation/features/chat/data/repositories/chat_repository.dart';
import 'package:nano_embryo/presentation/features/chat/data/repositories/sendbird_chat_repository.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/conversation.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/message.dart';
import 'package:sendbird_sdk/sdk/sendbird_sdk_api.dart';

// ─── Repository provider ─────────────────────────────────────────────────────
// App ID comes from ChatConfig — no hardcoded env var.

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final config = ref.read(chatConfigProvider);
  final sendbird = SendbirdSdk(appId: config.appId);
  return SendbirdChatRepository(sendbird);
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
      final supabase = _ref.read(supabaseClientProvider);
      final session = supabase.auth.currentSession;
      if (session == null) {
        debugPrint('Sendbird token skipped — no Supabase session yet');
        return null;
      }
      final fnName = _ref.read(chatConfigProvider).tokenFunctionName;
      final response = await supabase.functions.invoke(
        fnName,
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );
      final data = response.data as Map<String, dynamic>?;
      return data?['token'] as String?;
    } catch (e) {
      // Non-fatal: fall back to connecting without a session token.
      debugPrint('Could not fetch Sendbird session token: $e');
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

  // If already connected when the provider is first created, fetch immediately.
  if (ref.read(connectionProvider)) refresh();

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
      Timer? evictTimer;

      ref.onCancel(() {
        evictTimer = Timer(const Duration(minutes: 5), link.close);
      });
      ref.onResume(() => evictTimer?.cancel());
      ref.onDispose(() => evictTimer?.cancel());

      return ChatController(ref, channelUrl);
    });

class ChatController extends StateNotifier<ChatState> {
  final Ref ref;
  final String channelUrl;

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
    await markAsRead();
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
      final repository = ref.read(chatRepositoryProvider);
      final messages = await repository.getMessages(channelUrl, limit: 30);
      debugPrint('🔄 [LOAD-MSGS] channel=$channelUrl | count=${messages.length}');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        messages: messages,
        hasMore: messages.length >= 30,
      );
      // Write-through: keep Hive in sync after every successful fetch.
      unawaited(
        ref.read(chatCacheServiceProvider).writeMessages(channelUrl, messages),
      );
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMoreMessages() async {
    if (!mounted || state.isLoadingMore || !state.hasMore) return;
    if (state.messages.isEmpty) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final repository = ref.read(chatRepositoryProvider);
      final oldest = state.messages.last;
      final olderMessages = await repository.getMessages(
        channelUrl,
        limit: 30,
        token: oldest.timestamp.millisecondsSinceEpoch.toString(),
      );
      if (!mounted) return;
      state = state.copyWith(
        isLoadingMore: false,
        messages: [...state.messages, ...olderMessages],
        hasMore: olderMessages.length >= 30,
      );
    } catch (e) {
      if (mounted) state = state.copyWith(isLoadingMore: false);
    }
  }

  void _subscribeToMessages() {
    ref.listen(messagesProvider(channelUrl), (_, next) {
      next.whenData((messages) {
        debugPrint('🔔 [SUBSCRIBE] channel=$channelUrl | ${messages.length} msgs');
        if (mounted) {
          state = state.copyWith(messages: messages);
          // Write-through: real-time updates (new message, edit, delete) keep
          // the Hive cache current so the next cold-start shows fresh content.
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

    // Optimistic UI: insert a pending message immediately so the user sees
    // it at once without waiting for the Sendbird round-trip.
    final optimisticId = '_opt_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticMsg = Message(
      id: optimisticId,
      content: content,
      timestamp: DateTime.now(),
      sender: MessageSender.user,
      status: MessageStatus.sending,
    );
    state = state.copyWith(
      isSending: true,
      messages: [optimisticMsg, ...state.messages],
    );

    try {
      final repository = ref.read(chatRepositoryProvider);
      await repository.sendTextMessage(channelUrl, content);
      await repository.markAsRead(channelUrl);
      // _loadAndBroadcastMessages fires inside sendTextMessage and will push
      // the confirmed list (replacing the optimistic entry via _subscribeToMessages).
      if (mounted) state = state.copyWith(isSending: false);
    } catch (e) {
      debugPrint('❌ [SEND-MESSAGE] error: $e');
      if (mounted) {
        final updated = state.messages.map((m) {
          return m.id == optimisticId ? m.copyWith(status: MessageStatus.failed) : m;
        }).toList();
        state = state.copyWith(isSending: false, messages: updated, error: e.toString());
      }
    }
  }

  Future<void> sendFileMessage({
    required String filePath,
    required String fileName,
    required String mimeType,
    String? caption,
  }) async {
    if (!mounted) return;
    state = state.copyWith(isSending: true);
    try {
      final repository = ref.read(chatRepositoryProvider);
      await repository.sendFileMessage(
        channelUrl,
        filePath,
        fileName,
        mimeType,
        caption: caption,
      );
      if (mounted) state = state.copyWith(isSending: false);
    } catch (e) {
      if (mounted) state = state.copyWith(isSending: false, error: e.toString());
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
      // Re-fetch on failure so state stays consistent
      await loadMessages();
      if (mounted) state = state.copyWith(error: e.toString());
    }
  }

  Future<void> editMessage(String messageId, String newContent) async {
    if (!mounted || newContent.trim().isEmpty) return;
    // Optimistically update content in local state
    final updated = state.messages.map((m) {
      return m.id == messageId ? m.copyWith(content: newContent) : m;
    }).toList();
    state = state.copyWith(messages: updated, editingMessageId: null);
    try {
      final repository = ref.read(chatRepositoryProvider);
      await repository.updateMessage(channelUrl, int.parse(messageId), newContent);
    } catch (e) {
      await loadMessages();
      if (mounted) state = state.copyWith(error: e.toString());
    }
  }

  void startEditing(String messageId) {
    if (mounted) state = state.copyWith(editingMessageId: messageId);
  }

  void cancelEditing() {
    if (mounted) state = state.copyWith(editingMessageId: null);
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

  const ChatState({
    required this.isLoading,
    required this.isLoadingMore,
    required this.isSending,
    required this.hasMore,
    required this.messages,
    required this.typingUsers,
    this.error,
    this.editingMessageId,
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
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSending: isSending ?? this.isSending,
      hasMore: hasMore ?? this.hasMore,
      messages: messages ?? this.messages,
      typingUsers: typingUsers ?? this.typingUsers,
      error: error,
      editingMessageId: editingMessageId ?? this.editingMessageId,
    );
  }
}
