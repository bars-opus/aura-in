import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/chat/config/chat_config.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/conversation.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/message.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/state/chat_state.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/widgets/animated_entry.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/widgets/chat_text_field.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFieldFocus = FocusNode();
  final Map<String, GlobalKey> _messageKeys = {};
  String? _highlightedMessageId;

  // Messages that exist before this timestamp don't animate on initial render.
  late final DateTime _openedAt;

  // G5: whether the list is scrolled near the newest message. When false, a new
  // incoming message shows a "jump to latest" pill instead of yanking the view.
  bool _isNearBottom = true;
  // Newest message id we've seen while the user was at the bottom; used to
  // decide whether an arriving message is genuinely new (show the pill).
  String? _lastSeenMessageId;

  String get _channelUrl => widget.conversation.id;

  @override
  void initState() {
    super.initState();
    _openedAt = DateTime.now();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _textFieldFocus.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load older messages when scrolling near the top (list is reversed)
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 200 &&
        !ref.read(chatControllerProvider(_channelUrl)).isLoadingMore) {
      ref.read(chatControllerProvider(_channelUrl).notifier).loadMoreMessages();
    }

    // G5: track whether the user is near the bottom (newest). In a reversed
    // list, offset 0 == bottom. Within ~120px counts as "at the bottom".
    final nearBottom = _scrollController.offset <=
        _scrollController.position.minScrollExtent + 120;
    if (nearBottom != _isNearBottom) {
      setState(() => _isNearBottom = nearBottom);
    }

    // G4: mark as read when the user reaches the bottom — debounced so a flick
    // doesn't fire a network call per frame.
    if (nearBottom) {
      ref
          .read(chatControllerProvider(_channelUrl).notifier)
          .markAsReadDebounced();
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final notifier = ref.read(chatControllerProvider(_channelUrl).notifier);
    final chatState = ref.read(chatControllerProvider(_channelUrl));

    if (chatState.editingMessageId != null) {
      notifier.editMessage(chatState.editingMessageId!, content);
    } else {
      notifier.sendMessage(content);
    }

    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _sendFile(
    File file,
    String fileName,
    String mimeType, {
    Map<String, dynamic>? data,
  }) async {
    await ref
        .read(chatControllerProvider(_channelUrl).notifier)
        .sendFileMessage(
          filePath: file.path,
          fileName: fileName,
          mimeType: mimeType,
          data: data,
        );
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider(_channelUrl));
    final typingUsers = ref.watch(typingUsersProvider(_channelUrl));
    final notifier = ref.read(chatControllerProvider(_channelUrl).notifier);

    // G5: when a new message arrives, auto-scroll ONLY if the user is already
    // at the bottom. Otherwise leave their scroll position alone — the
    // jump-to-latest pill (rendered below) lets them catch up on demand.
    ref.listen(chatControllerProvider(_channelUrl), (prev, next) {
      if (next.messages.isEmpty) return;
      final newestId = next.messages.first.id;
      if (newestId == _lastSeenMessageId) return;
      final isMine = next.messages.first.isFromUser;
      if (_isNearBottom || isMine) {
        _lastSeenMessageId = newestId;
        _scrollToBottom();
      } else {
        // Trigger a rebuild so the pill appears for the new message.
        setState(() {});
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: ref.read(chatConfigProvider).chatAppBarTitle?.call(
              widget.conversation,
              context,
            ) ??
            _DefaultChatAppBarTitle(
              conversation: widget.conversation,
              statusText: _onlineStatusText(typingUsers),
            ),
        actions: [
          AppIconButton(icon: Icons.videocam_outlined, onPressed: () {}),
          AppIconButton(icon: Icons.phone_outlined, onPressed: () {}),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Connection banner (G2) ───────────────────────────────────
            _ConnectionBanner(),

            // ── Messages ────────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  _buildMessageList(chatState),
                  // G5: jump-to-latest pill, shown only when scrolled up.
                  if (!_isNearBottom)
                    Positioned(
                      right: 12.w,
                      bottom: 12.h,
                      child: _JumpToLatestButton(
                        onTap: () {
                          _scrollToBottom();
                          setState(() => _isNearBottom = true);
                        },
                      ),
                    ),
                ],
              ),
            ),

            // ── Typing indicator ─────────────────────────────────────────
            _buildTypingIndicator(typingUsers),

            // ── Reply banner ─────────────────────────────────────────────
            if (chatState.replyingToMessage != null)
              _buildReplyBanner(chatState, notifier),

            // ── Edit mode banner ─────────────────────────────────────────
            if (chatState.editingMessageId != null)
              _buildEditBanner(chatState, notifier),

            // ── Input ────────────────────────────────────────────────────
            ChatTextField(
              controller: _messageController,
              focusNode: _textFieldFocus,
              onSend: _sendMessage,
              isSending: chatState.isSending,
              hintText:
                  chatState.editingMessageId != null
                      ? 'Edit message...'
                      : chatState.replyingToMessage != null
                          ? 'Reply...'
                          : 'Type a message...',
              onTypingStarted: notifier.startTyping,
              onTypingStopped: notifier.endTyping,
              onFilePicked: _sendFile,
              onContactShare: notifier.sendProfileCard,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(ChatState chatState) {
    if (chatState.isLoading) {
      return const Center(child: CircularLoadingIndicator());
    }

    if (chatState.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64.h,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: Spacing.md.h),
            Text(
              'No messages yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: Spacing.xs.h),
            Text(
              'Send the first message!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: EdgeInsets.only(top: Spacing.sm.h, bottom: Spacing.md.h),
      itemCount: chatState.messages.length + (chatState.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Pagination spinner at the bottom of the reversed list (oldest end)
        if (index == chatState.messages.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularLoadingIndicator()),
          );
        }

        final message = chatState.messages[index];
        // In a reversed list, index-1 is the NEWER message rendered below.
        final newerMessage = index > 0 ? chatState.messages[index - 1] : null;
        final showAvatar =
            newerMessage == null ||
            newerMessage.sender != message.sender ||
            message.timestamp.difference(newerMessage.timestamp).inMinutes > 5;

        final isLastUserMessage =
            index == 0 && message.sender == MessageSender.user;

        // Show date separator when day changes going to an older message above.
        final showDateSeparator = newerMessage != null &&
            !_isSameDay(message.timestamp, newerMessage.timestamp);

        // Look up the message this one is replying to (if in loaded window).
        Message? replyToMessage;
        if (message.replyToMessageId != null) {
          for (final m in chatState.messages) {
            if (m.id == message.replyToMessageId) {
              replyToMessage = m;
              break;
            }
          }
        }

        final msgKey = _messageKeys.putIfAbsent(message.id, () => GlobalKey());

        final isUploadingThisFile =
            message.status == MessageStatus.sending &&
            (message.isFile || message.isImage || message.isVideo || message.isAudio);

        final bubble = MessageBubble(
          key: msgKey,
          message: message,
          replyToMessage: replyToMessage,
          isHighlighted: _highlightedMessageId == message.id,
          showAvatar: showAvatar,
          showStatus: isLastUserMessage,
          uploadProgress: isUploadingThisFile ? chatState.fileUploadProgress : null,
          onDelete: () => ref
              .read(chatControllerProvider(_channelUrl).notifier)
              .deleteMessage(message.id),
          onEdit: () {
            ref
                .read(chatControllerProvider(_channelUrl).notifier)
                .startEditing(message.id);
            _messageController.text = message.content;
          },
          onReply: () {
            ref
                .read(chatControllerProvider(_channelUrl).notifier)
                .startReplying(message);
            _textFieldFocus.requestFocus();
          },
          onReplyPreviewTapped: message.replyToMessageId != null
              ? () => _scrollToMessage(message.replyToMessageId!)
              : null,
          // G1: tap a failed message to re-send it (reuses its client_req_id).
          onRetry: message.status == MessageStatus.failed
              ? () => ref
                  .read(chatControllerProvider(_channelUrl).notifier)
                  .retryMessage(message.id)
              : null,
          // G7: real sender name + cached avatar for incoming messages.
          otherName: widget.conversation.name,
          otherAvatarUrl: widget.conversation.avatarUrl,
        );

        // Animate in two cases only:
        //   1. Optimistic messages (id starts with '_opt_') — the user just
        //      sent this; it should slide in immediately.
        //   2. Incoming messages from another user that arrived after the
        //      screen was opened.
        //
        // Confirmed messages (non-_opt_) that replace optimistic ones are
        // intentionally excluded: they already played their animation as the
        // optimistic version so a second slide would look like a glitch.
        final isOptimistic = message.id.startsWith('_opt_');
        final isNewIncoming =
            !message.isFromUser && message.timestamp.isAfter(_openedAt);
        final shouldAnimate = isOptimistic || isNewIncoming;

        // Incoming and outgoing messages slide in from opposite sides.
        final slideBegin = message.isFromUser
            ? const Offset(0.08, 0.08)   // right + up
            : const Offset(-0.08, 0.08); // left + up

        final animated = AnimatedEntry(
          key: ValueKey(message.id),
          animate: shouldAnimate,
          beginOffset: slideBegin,
        child: bubble,
        );

        if (showDateSeparator) {
          return Column(
            children: [
              _DateSeparator(date: message.timestamp),
              animated,
            ],
          );
        }
        return animated;
      },
    );
  }

  Widget _buildTypingIndicator(AsyncValue<List<String>> typingUsers) {
    return typingUsers.when(
      data: (users) {
        if (users.isEmpty) return const SizedBox.shrink();
        final names =
            users.length == 1
                ? '${users.first} is typing'
                : '${users.length} people are typing';
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.md.w,
            vertical: 4.h,
          ),
          child: Row(
            children: [
              _TypingDots(),
              SizedBox(width: 8.w),
              Text(
                names,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildEditBanner(ChatState chatState, ChatController notifier) {
    final msg = chatState.messages.firstWhere(
      (m) => m.id == chatState.editingMessageId,
      orElse: () => chatState.messages.first,
    );
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: EdgeInsets.symmetric(horizontal: Spacing.md.w, vertical: 6.h),
      child: Row(
        children: [
          Icon(
            Icons.edit,
            size: 16.h,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              msg.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            padding: EdgeInsets.zero,
            onPressed: notifier.cancelEditing,
          ),
        ],
      ),
    );
  }

  Future<void> _scrollToMessage(String messageId) async {
    final key = _messageKeys[messageId];

    if (key?.currentContext != null) {
      // Item is already built — scroll directly to it.
      await Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    } else {
      // Item is off-screen and not built yet. Find its index and jump to an
      // approximate offset so the ListView builds the item, then fine-tune.
      final messages = ref.read(chatControllerProvider(_channelUrl)).messages;
      final index = messages.indexWhere((m) => m.id == messageId);
      if (index == -1) return;

      final approxOffset = (index * 76.0)
          .clamp(0.0, _scrollController.position.maxScrollExtent);
      _scrollController.jumpTo(approxOffset);

      // Wait one frame for the item to be laid out.
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;

      if (key?.currentContext != null) {
        await Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.5,
        );
      }
    }

    // Flash highlight on the target message.
    if (!mounted) return;
    setState(() => _highlightedMessageId = messageId);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _highlightedMessageId = null);
  }

  Widget _buildReplyBanner(ChatState chatState, ChatController notifier) {
    final msg = chatState.replyingToMessage!;
    return Container(
      color: Theme.of(context).colorScheme.secondaryContainer,
      padding: EdgeInsets.symmetric(horizontal: Spacing.md.w, vertical: 6.h),
      child: Row(
        children: [
          Icon(
            Icons.reply,
            size: 16.h,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.sender == MessageSender.user
                      ? 'You'
                      : widget.conversation.name,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  msg.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            padding: EdgeInsets.zero,
            onPressed: notifier.cancelReplying,
          ),
        ],
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _onlineStatusText(AsyncValue<List<String>> typingUsers) {
    return typingUsers.maybeWhen(
      data: (users) => users.isNotEmpty ? 'typing...' : '',
      orElse: () => '',
    );
  }
}

// ─── Generic chat app bar title ──────────────────────────────────────────────

class _DefaultChatAppBarTitle extends StatelessWidget {
  final Conversation conversation;
  final String statusText;

  const _DefaultChatAppBarTitle({
    required this.conversation,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarUrl = conversation.avatarUrl;
    final initial =
        conversation.name.isNotEmpty
            ? conversation.name[0].toUpperCase()
            : '?';

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
          child:
              (avatarUrl == null || avatarUrl.isEmpty)
                  ? Text(
                    initial,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : null,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              conversation.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600, color: 
                                  theme.colorScheme.onSurface,
              ),
            ),
            if (statusText.isNotEmpty)
              Text(
                statusText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ─── Connection banner (G2) ──────────────────────────────────────────────────

/// Slim banner that appears when the chat socket is disconnected, so the user
/// understands why messages aren't sending (checklist 5.1: actionable state).
/// Messages typed while it's showing are still queued and auto-sent on
/// reconnect (G3) — the banner says exactly that.
class _ConnectionBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(connectionProvider);
    final theme = Theme.of(context);

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: isConnected
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              color: theme.colorScheme.errorContainer,
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.md.w,
                vertical: 6.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 12.h,
                    height: 12.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      'Connecting… messages will send when you’re back online',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─── Jump-to-latest pill (G5) ─────────────────────────────────────────────────

class _JumpToLatestButton extends StatelessWidget {
  final VoidCallback onTap;

  const _JumpToLatestButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 3,
      shape: const CircleBorder(),
      color: theme.colorScheme.surface,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(8.h),
          child: Icon(
            Icons.keyboard_arrow_down,
            color: theme.colorScheme.primary,
            size: 24.h,
          ),
        ),
      ),
    );
  }
}

// ─── Animated typing dots ─────────────────────────────────────────────────────

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final progress =
                ((_controller.value - i * 0.2) % 1.0).clamp(0.0, 1.0);
            final opacity = (progress < 0.5 ? progress * 2 : (1 - progress) * 2)
                .clamp(0.3, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

// ─── Date separator ────────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final DateTime date;

  const _DateSeparator({required this.date});

  static String _label(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(date.year, date.month, date.day);

    if (msgDay == today) return 'Today';

    final yesterday = today.subtract(const Duration(days: 1));
    if (msgDay == yesterday) return 'Yesterday';

    if (now.difference(date).inDays < 7) {
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return days[date.weekday - 1];
    }

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _label(date),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}
