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

  // ── Operational tuning (checklist 4.11: no hardcoded magic numbers) ────────

  /// Page size for an initial message fetch and pagination.
  final int messagePageSize;

  /// Max messages cached per channel in the encrypted Hive box.
  final int maxCachedMessages;

  /// Per-request timeout for any Sendbird/Supabase call made by the chat layer.
  final Duration networkTimeout;

  /// How long the in-memory chat controller state survives after the last
  /// listener leaves (warm back-navigation without a refetch).
  final Duration controllerKeepAlive;

  /// Trailing-debounce window for collapsing bursty channel events (read /
  /// delivery receipts, rapid inbound messages) into a single refetch.
  final Duration broadcastDebounce;

  /// Maximum attachment size in bytes. Defaults to 25 MB.
  final int maxFileSizeBytes;

  /// Max characters of a message preview placed in a push notification body.
  final int notificationPreviewMaxLength;

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
    this.messagePageSize = 30,
    this.maxCachedMessages = 50,
    this.networkTimeout = const Duration(seconds: 20),
    this.controllerKeepAlive = const Duration(minutes: 5),
    this.broadcastDebounce = const Duration(milliseconds: 300),
    this.maxFileSizeBytes = 25 * 1024 * 1024,
    this.notificationPreviewMaxLength = 120,
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
