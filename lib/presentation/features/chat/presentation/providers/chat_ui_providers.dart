// lib/features/chat/presentation/providers/chat_ui_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/conversation.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/state/chat_state.dart';

// UI State Providers

final searchQueryProvider = StateProvider<String>((ref) => '');

final sortCriteriaProvider = StateProvider<SortCriteria>(
  (ref) => SortCriteria.recent,
);

enum SortCriteria {
  recent('Most Recent'),
  unread('Unread First'),
  groups('Groups Only'),
  individuals('Individuals Only'),
  alphabetical('A-Z');

  final String label;
  const SortCriteria(this.label);
}

// Enhanced conversations provider with search & sort
final filteredConversationsProvider = Provider<List<Conversation>>((ref) {
  final conversationsAsync = ref.watch(conversationsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final sortCriteria = ref.watch(sortCriteriaProvider);

  return conversationsAsync.when(
    data: (conversations) {
      // Early return if no conversations
      if (conversations.isEmpty) return [];

      // 1. Apply search filter (optimized)
      List<Conversation> filtered = _applySearchFilter(
        conversations,
        searchQuery,
      );

      // Early return if search yields no results
      if (filtered.isEmpty) return [];

      // 2. Apply sorting (optimized with caching considerations)
      filtered = _applySorting(filtered, sortCriteria);

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// ========== HELPER FUNCTIONS ==========

// Extract search logic for readability and potential reuse
List<Conversation> _applySearchFilter(
  List<Conversation> conversations,
  String searchQuery,
) {
  if (searchQuery.isEmpty) return List.from(conversations);

  final query = searchQuery.toLowerCase();

  return conversations.where((conversation) {
    // Check name
    if (conversation.name.toLowerCase().contains(query)) {
      return true;
    }

    // Check last message content (with null safety)
    final lastMessage = conversation.lastMessage;
    if (lastMessage != null &&
        lastMessage.content.toLowerCase().contains(query)) {
      return true;
    }

    // Check ID
    if (conversation.id.toLowerCase().contains(query)) {
      return true;
    }

    return false;
  }).toList();
}

// Extract sorting logic for better performance and testing
List<Conversation> _applySorting(
  List<Conversation> conversations,
  SortCriteria criteria,
) {
  // Create a copy to avoid mutating the original list
  final sorted = List<Conversation>.from(conversations);

  // Define comparator functions for each criteria
  int Function(Conversation a, Conversation b) comparator;

  switch (criteria) {
    case SortCriteria.recent:
      comparator = (a, b) {
        // Handle potential null lastMessage
        final aTime = a.lastMessage?.timestamp ?? DateTime(1970);
        final bTime = b.lastMessage?.timestamp ?? DateTime(1970);
        return bTime.compareTo(aTime);
      };
      break;

    case SortCriteria.unread:
      comparator = (a, b) {
        // Unread first
        if (a.unreadCount > 0 && b.unreadCount == 0) return -1;
        if (a.unreadCount == 0 && b.unreadCount > 0) return 1;

        // Then by recent
        final aTime = a.lastMessage?.timestamp ?? DateTime(1970);
        final bTime = b.lastMessage?.timestamp ?? DateTime(1970);
        return bTime.compareTo(aTime);
      };
      break;

    case SortCriteria.groups:
      comparator = (a, b) {
        // Use the isGroup property directly
        if (a.isGroup && !b.isGroup) return -1;
        if (!a.isGroup && b.isGroup) return 1;
        final aTime = a.lastMessage?.timestamp ?? DateTime(1970);
        final bTime = b.lastMessage?.timestamp ?? DateTime(1970);
        return bTime.compareTo(aTime);
      };
      break;

    case SortCriteria.individuals:
      comparator = (a, b) {
        // Individuals are NOT groups
        if (!a.isGroup && b.isGroup) return -1;
        if (a.isGroup && !b.isGroup) return 1;
        final aTime = a.lastMessage?.timestamp ?? DateTime(1970);
        final bTime = b.lastMessage?.timestamp ?? DateTime(1970);
        return bTime.compareTo(aTime);
      };
      break;

    case SortCriteria.alphabetical:
      comparator = (a, b) => a.name.compareTo(b.name);
      break;
  }

  // Sort with the selected comparator
  sorted.sort(comparator);
  return sorted;
}
