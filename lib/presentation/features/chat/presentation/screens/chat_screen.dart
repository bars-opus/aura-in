import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/chat/config/chat_config.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/conversation.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/message.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/state/chat_state.dart';
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

  String get _channelUrl => widget.conversation.id;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load older messages when scrolling near the top (list is reversed)
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 200 &&
        !ref.read(chatControllerProvider(_channelUrl)).isLoadingMore) {
      ref.read(chatControllerProvider(_channelUrl).notifier).loadMoreMessages();
    }

    // Mark as read when user reaches the bottom (newest messages)
    if (_scrollController.offset <=
        _scrollController.position.minScrollExtent + 50) {
      ref.read(chatControllerProvider(_channelUrl).notifier).markAsRead();
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

  Future<void> _sendFile(File file, String fileName, String mimeType) async {
    await ref
        .read(chatControllerProvider(_channelUrl).notifier)
        .sendFileMessage(
          filePath: file.path,
          fileName: fileName,
          mimeType: mimeType,
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
            // ── Messages ────────────────────────────────────────────────
            Expanded(
              child: _buildMessageList(chatState),
            ),

            // ── Typing indicator ─────────────────────────────────────────
            _buildTypingIndicator(typingUsers),

            // ── Edit mode banner ─────────────────────────────────────────
            if (chatState.editingMessageId != null)
              _buildEditBanner(chatState, notifier),

            // ── Input ────────────────────────────────────────────────────
            ChatTextField(
              controller: _messageController,
              onSend: _sendMessage,
              isSending: chatState.isSending,
              hintText:
                  chatState.editingMessageId != null
                      ? 'Edit message...'
                      : 'Type a message...',
              onTypingStarted: notifier.startTyping,
              onTypingStopped: notifier.endTyping,
              onFilePicked: _sendFile,
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
        final previousMessage =
            index > 0 ? chatState.messages[index - 1] : null;

        final showAvatar =
            previousMessage == null ||
            previousMessage.sender != message.sender ||
            message.timestamp.difference(previousMessage.timestamp).inMinutes >
                5;

        final isLastUserMessage =
            index == 0 && message.sender == MessageSender.user;

        return MessageBubble(
          message: message,
          showAvatar: showAvatar,
          showStatus: isLastUserMessage,
          onDelete: () => ref
              .read(chatControllerProvider(_channelUrl).notifier)
              .deleteMessage(message.id),
          onEdit: () {
            ref
                .read(chatControllerProvider(_channelUrl).notifier)
                .startEditing(message.id);
            _messageController.text = message.content;
          },
        );
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
