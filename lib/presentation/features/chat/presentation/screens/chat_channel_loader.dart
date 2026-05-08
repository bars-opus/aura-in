import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/conversation.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/screens/chat_screen.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/state/chat_state.dart';

/// Fetches a channel by URL and renders [ChatScreen].
///
/// Used when navigating from a push notification tap, where only the
/// channel URL is available (no pre-loaded [Conversation] object).
class ChatChannelLoader extends ConsumerWidget {
  final String channelUrl;

  const ChatChannelLoader({super.key, required this.channelUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Conversation>(
      future: ref.read(chatRepositoryProvider).getChannel(channelUrl),
      builder: (context, snapshot) {
        if (snapshot.hasError || channelUrl.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 12),
                  const Text('Could not open conversation.'),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return ChatScreen(conversation: snapshot.data!);
      },
    );
  }
}
