import 'dart:async';
import 'dart:io';

/// Maps raw SDK / network exceptions to user-facing, actionable messages.
///
/// Checklist 5.1 (actionable errors) + 5.5 (no internal info leaked in UI):
/// the UI must never render `e.toString()` from the Sendbird SDK or Supabase —
/// those strings can expose internal paths, schema, or request internals.
/// Every error shown to the user goes through [ChatError.toUserMessage].
class ChatError {
  const ChatError._();

  /// Returns a short, actionable, PII-free message for [error].
  static String toUserMessage(Object? error) {
    if (error == null) return _generic;

    if (error is TimeoutException) {
      return "This is taking longer than usual. Check your connection and try again.";
    }
    if (error is SocketException) {
      return "You appear to be offline. Reconnect and try again.";
    }

    final text = error.toString().toLowerCase();

    if (text.contains('timeout') || text.contains('timed out')) {
      return "This is taking longer than usual. Check your connection and try again.";
    }
    if (text.contains('socket') ||
        text.contains('network') ||
        text.contains('connection') ||
        text.contains('host')) {
      return "Couldn't reach the chat server. Check your connection and try again.";
    }
    if (text.contains('401') ||
        text.contains('unauthor') ||
        text.contains('token') ||
        text.contains('session')) {
      return "Your session expired. Pull to refresh to reconnect.";
    }
    if (text.contains('too large') || text.contains('size')) {
      return "That file is too large to send.";
    }
    if (text.contains('not found') || text.contains('404')) {
      return "This conversation is no longer available.";
    }

    return _generic;
  }

  static const _generic =
      "Something went wrong. Please try again in a moment.";
}
