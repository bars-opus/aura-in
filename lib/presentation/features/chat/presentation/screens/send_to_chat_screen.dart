import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/conversation.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/screens/conversations_screen.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/state/chat_state.dart';

/// Forwards a piece of text (an entity share link) into a conversation the user
/// picks from their chat list. Backs the "Send" action in the More menu.
class SendToChatScreen extends ConsumerStatefulWidget {
  final String currentUserId;
  final String message;

  const SendToChatScreen({
    super.key,
    required this.currentUserId,
    required this.message,
  });

  @override
  ConsumerState<SendToChatScreen> createState() => _SendToChatScreenState();
}

class _SendToChatScreenState extends ConsumerState<SendToChatScreen> {
  bool _sending = false;

  Future<void> _send(Conversation conversation) async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      // Ensure the SDK is connected before sending.
      if (!ref.read(connectionProvider) && widget.currentUserId.isNotEmpty) {
        await ref.read(connectionProvider.notifier).connect(widget.currentUserId);
      }
      await ref
          .read(chatRepositoryProvider)
          .sendTextMessage(conversation.id, widget.message);
      if (!mounted) return;
      context.showInfoSnackbar('Sent to ${conversation.name}');
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      context.showErrorSnackbar('Could not send. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ConversationsScreen(
          currentUserId: widget.currentUserId,
          onConversationSelected: _send,
        ),
        if (_sending)
          const ColoredBox(
            color: Color(0x66000000),
            child: Center(child: CircularLoadingIndicator()),
          ),
      ],
    );
  }
}
