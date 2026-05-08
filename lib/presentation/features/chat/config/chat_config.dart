import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/conversation.dart';

/// The single configuration object for the chat engine.
///
/// Drop this into any Flutter + Sendbird project.
/// Override [chatConfigProvider] in your root [ProviderScope]:
///
/// ```dart
/// ProviderScope(
///   overrides: [
///     chatConfigProvider.overrideWithValue(ChatConfig(appId: 'YOUR_APP_ID')),
///   ],
///   child: MyApp(),
/// )
/// ```
///
/// See CHAT_ENGINE.md for the full integration guide.
class ChatConfig {
  /// Your Sendbird application ID.
  ///
  /// Found in: Sendbird Dashboard → Settings → Application → Application ID.
  final String appId;

  /// Name of the Supabase Edge Function that issues Sendbird session tokens.
  ///
  /// Defaults to `'sendbird-auth'`. Change if you name your function differently.
  /// See CHAT_ENGINE.md for the edge function source code.
  final String tokenFunctionName;

  /// Title shown in the conversations screen app bar.
  final String conversationsTitle;

  /// Optional builder for the app bar widget inside [ChatScreen].
  ///
  /// Return `null` to use the built-in generic header (name + avatar circle).
  ///
  /// Use this when you want to show your app's custom profile widget
  /// (e.g. NanoEmbryo's `ProfileHeader`) or add call/video buttons.
  ///
  /// ```dart
  /// chatAppBarTitle: (conversation, context) => MyProfileHeader(
  ///   name: conversation.name,
  ///   avatarUrl: conversation.avatarUrl,
  /// ),
  /// ```
  final Widget Function(Conversation conversation, BuildContext context)?
  chatAppBarTitle;

  /// Optional builder for individual conversation list items.
  ///
  /// Return `null` to use the built-in list tile (name, last message, badge).
  ///
  /// Use this to apply your app's own list tile design system component.
  final Widget Function(
    Conversation conversation,
    VoidCallback onTap,
    BuildContext context,
  )?
  conversationItemBuilder;

  const ChatConfig({
    required this.appId,
    this.tokenFunctionName = 'sendbird-auth',
    this.conversationsTitle = 'Chat',
    this.chatAppBarTitle,
    this.conversationItemBuilder,
  });
}

/// Override this provider in your root [ProviderScope].
///
/// The default throws immediately to surface missing configuration early.
final chatConfigProvider = Provider<ChatConfig>((ref) {
  throw UnimplementedError(
    'chatConfigProvider has no value. '
    'Add chatConfigProvider.overrideWithValue(ChatConfig(appId: "...")) '
    'to your root ProviderScope. See CHAT_ENGINE.md.',
  );
});
