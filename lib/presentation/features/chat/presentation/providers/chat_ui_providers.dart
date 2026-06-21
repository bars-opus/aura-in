// lib/features/chat/presentation/providers/chat_ui_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/conversation.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/state/chat_state.dart';

// UI State Providers

final searchQueryProvider = StateProvider<String>((ref) => '');

final sortCriteriaProvider = StateProvider<SortCriteria>(
  (ref) => SortCriteria.recent,
);

/// Active filter chips. Each value is a chip label string (e.g. 'Unread').
/// Multiple chips are applied as AND: Unread + Groups = unread group chats only.
final activeFiltersProvider = StateProvider<Set<String>>((ref) => {});

enum SortCriteria {
  recent('Most Recent'),
  unread('Unread First'),
  groups('Groups Only'),
  individuals('Individuals Only'),
  alphabetical('A-Z');

  final String label;
  const SortCriteria(this.label);
}

/// Conversations with search text, chip filters, and sort applied.
final filteredConversationsProvider = Provider<List<Conversation>>((ref) {
  final conversationsAsync = ref.watch(conversationsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final sortCriteria = ref.watch(sortCriteriaProvider);
  final activeFilters = ref.watch(activeFiltersProvider);

  return conversationsAsync.when(
    data: (conversations) {
      if (conversations.isEmpty) return [];

      List<Conversation> filtered = _applySearchFilter(conversations, searchQuery);
      if (filtered.isEmpty) return [];

      filtered = _applyChipFilters(filtered, activeFilters);
      if (filtered.isEmpty) return [];

      filtered = _applySorting(filtered, sortCriteria);
      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// ========== HELPER FUNCTIONS ==========

List<Conversation> _applySearchFilter(
  List<Conversation> conversations,
  String searchQuery,
) {
  if (searchQuery.isEmpty) return List.from(conversations);

  final query = searchQuery.toLowerCase();

  return conversations.where((c) {
    if (c.name.toLowerCase().contains(query)) return true;
    final msg = c.lastMessage;
    if (msg != null && msg.content.toLowerCase().contains(query)) return true;
    return false;
  }).toList();
}

/// Applies active chip filters with mixed AND/OR logic:
///
/// • 'Unread' — AND dimension: conversation must have unread messages.
/// • 'Groups' / 'Individuals' — OR dimension: conversation must match at least
///   one of the selected type chips. Selecting both means "show either type"
///   (i.e. the same as no type filter). This prevents the counter-intuitive
///   result where selecting both chips produces an empty list.
List<Conversation> _applyChipFilters(
  List<Conversation> conversations,
  Set<String> activeFilters,
) {
  if (activeFilters.isEmpty) return conversations;

  return conversations.where((c) {
    // AND: unread filter always narrows the result independently.
    if (activeFilters.contains('Unread') && c.unreadCount == 0) return false;

    // OR: type filters — pass if the conversation matches any selected type.
    final wantsGroups = activeFilters.contains('Groups');
    final wantsIndividuals = activeFilters.contains('Individuals');
    if (wantsGroups || wantsIndividuals) {
      final matchesGroup = wantsGroups && c.isGroup;
      final matchesIndividual = wantsIndividuals && !c.isGroup;
      if (!matchesGroup && !matchesIndividual) return false;
    }

    return true;
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
