import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/core/widgets/feedback/empty_state.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/screens/conversations_screen.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/state/chat_state.dart';

class ChatHomeScreen extends ConsumerWidget {
  final String currentUserId;
  const ChatHomeScreen({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Guest user — not logged in
    if (currentUserId.isEmpty) {
      return Scaffold(
        body: Center(
          child: EmptyStateWidget(
            compact: true,
            type: EmptyStateType.noMessages,
            title: 'Sign in to chat',
            subtitle: 'Log in to view your conversations and send messages.',
          ),
        ),
      );
    }

    final isConnected = ref.watch(connectionProvider);

    // ConnectionNotifier auto-connects using the real Supabase user ID.
    // Show a loader until the handshake completes.
    if (!isConnected) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularLoadingIndicator(),
              SizedBox(height: 16),
              Text('Setting up chat...'),
            ],
          ),
        ),
      );
    }

    return ConversationsScreen(currentUserId: currentUserId);
  }
}
