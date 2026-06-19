import 'package:flutter/services.dart'; // For haptic feedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/chat_ui_providers.dart';
import 'package:nano_embryo/presentation/features/chat/config/chat_config.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/search_text_field.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/conversation.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/screens/chat_screen.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/screens/group_chat_creation_screen.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/state/chat_state.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/widgets/animated_entry.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/widgets/chat_sort.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  final String currentUserId;
  const ConversationsScreen({super.key, required this.currentUserId});

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  late AnimationController _animationController;
  final FocusNode _searchFocusNode = FocusNode();
  bool _hasRequestedFocus = false;

  // Conversations updated after this timestamp get entry animations.
  late final DateTime _openedAt;

  static const List<String> _availableFilters = [
    'Unread',
    'Groups',
    'Individuals',
  ];

  static const Map<String, IconData> _filterIcons = {
    'Unread': Icons.mark_chat_unread_outlined,
    'Groups': Icons.group_outlined,
    'Individuals': Icons.person_outlined,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _openedAt = DateTime.now();
    // Listen to search controller
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Unfocus when app loses focus
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _searchFocusNode.unfocus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchFocusNode.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(searchQueryProvider.notifier).state = _searchController.text;
  }

  void _toggleSearch() {
    // Cancel any pending focus requests
    _hasRequestedFocus = false;

    setState(() {
      _isSearching = !_isSearching;

      if (_isSearching) {
        _animationController.forward().then((_) {
          // Only request focus after animation AND if still searching
          if (mounted && _isSearching && !_hasRequestedFocus) {
            _hasRequestedFocus = true;
            _searchFocusNode.requestFocus();
          }
        });
      } else {
        _animationController.reverse();
        _searchController.clear();
        // IMPORTANT: Use Future.delayed to ensure focus is properly removed
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            _searchFocusNode.unfocus();
          }
        });
      }
    });
    _resetToDefault();
    HapticFeedback.lightImpact();
  }

  void _handleFiltersChanged(List<String> newFilters) {
    ref.read(activeFiltersProvider.notifier).state = Set.from(newFilters);
  }

  void _handleSearchSubmitted(String query) {
    // Search submitted logic
  }

  void _resetToDefault() {
    ref.read(sortCriteriaProvider.notifier).state = SortCriteria.recent;
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(activeFiltersProvider.notifier).state = {};
    _searchController.clear();
    HapticFeedback.mediumImpact();
  }

  void _showSortDialog() {
    // Unfocus before showing dialog
    _searchFocusNode.unfocus();

    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      showButtons: false,
      widget: ChatSortDialog(
        onClearSearch: () => _searchController.clear(),
        searchController: _searchController,
      ),
    );
  }

  // Build the search bar with animation - CRITICAL FIX HERE
  Widget _buildAnimatedSearchBar() {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.2, 1.0, curve: Curves.easeIn), // Delay fade
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutBack,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  width: 1.0,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.md.w,
                vertical: Spacing.sm.h,
              ),
              child: FilterableSearchFormField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: false,
                hintText: 'Search conversations...',
                filterChips: _availableFilters,
                filterIcons: _filterIcons,
                selectedFilters: ref.watch(activeFiltersProvider).toList(),
                onFiltersChanged: _handleFiltersChanged,
                onSearchSubmitted: _handleSearchSubmitted,
                onCancelPressed: _toggleSearch,
                onSearchChanged: (query) {
                  ref.read(searchQueryProvider.notifier).state = query;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build conversation list item
  Widget _buildConversationItem(Conversation conversation) {
    return Padding(
      padding: EdgeInsets.all(8.0.w),
      child: InfoRowWidget(
        subtitle:
            conversation.lastMessage == null
                ? ''
                : conversation.lastMessage!.content,
        title: conversation.name,
        imageUrl: conversation.avatarUrl,
        showDivider: false,
        iconColor: conversation.avatarUrl != null ? null : Colors.white,
        backgroundColor:
            conversation.avatarUrl != null
                ? null
                : Theme.of(context).colorScheme.primary,
        icon: conversation.avatarUrl == null ? Icons.group : null,
        trailing:
            conversation.unreadCount > 0
                ? CircleAvatar(
                  radius: 12.r,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    conversation.unreadCount > 9
                        ? '9+'
                        : conversation.unreadCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                : SizedBox.shrink(),
        avatarRadius: 25.h,
        onTap: () {
          // Unfocus before navigation
          _searchFocusNode.unfocus();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(conversation: conversation),
            ),
          );
        },
        showTrailingArrow: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final chatConfig = ref.read(chatConfigProvider);

    // Watch providers
    final filteredConversations = ref.watch(filteredConversationsProvider);
    final isSearchActive = ref.watch(searchQueryProvider).isNotEmpty;
    final isFilterActive = ref.watch(activeFiltersProvider).isNotEmpty;

    return SafeArea(
      child: Scaffold(
        appBar:
            _isSearching
                ? null
                : AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Consumer(
                    builder: (context, ref, child) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Consumer(
                          builder: (context, ref, child) {
                            final currentSort = ref.watch(sortCriteriaProvider);

                            return AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              switchInCurve: Curves.easeInOut,
                              switchOutCurve: Curves.easeInOut,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SizeTransition(
                                    sizeFactor: animation,
                                    axisAlignment: -1.0, // Animates from left
                                    child: child,
                                  ),
                                );
                              },
                              child: Text(
                                key: ValueKey(
                                  currentSort,
                                ), // Different key for each sort
                                currentSort == SortCriteria.recent
                                    ? chatConfig.conversationsTitle
                                    : currentSort.label,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                  fontSize:
                                      currentSort == SortCriteria.recent
                                          ? FontSizeTokens.xl.sp
                                          : 20.sp,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  actions: [
                    if (widget.currentUserId.isNotEmpty)
                      Consumer(
                        builder: (context, ref, child) {
                          return Row(
                            children: [
                              // New group button
                              AppIconButton(
                                icon: Icons.group_add_outlined,
                                onPressed: () {
                                  _searchFocusNode.unfocus();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              const GroupChatCreationScreen(),
                                    ),
                                  );
                                },
                              ),

                              // Search button
                              Consumer(
                                builder: (context, ref, child) {
                                  final currentSort = ref.watch(
                                    sortCriteriaProvider,
                                  );

                                  return currentSort == SortCriteria.recent
                                      ? AppIconButton(
                                        icon: Icons.search,
                                        onPressed: _toggleSearch,
                                      )
                                      : SizedBox.fromSize();
                                },
                              ),

                              // Reset button
                              Consumer(
                                builder: (context, ref, child) {
                                  final currentSort = ref.watch(
                                    sortCriteriaProvider,
                                  );
                                  final hasSearch =
                                      _searchController.text.isNotEmpty;

                                  if (currentSort == SortCriteria.recent &&
                                      !hasSearch) {
                                    return SizedBox.shrink();
                                  }

                                  return AppIconButton(
                                    icon: Icons.refresh,
                                    onPressed: _resetToDefault,
                                    iconColor: colorScheme.primary,
                                  );
                                },
                              ),

                              // Sort button
                              Consumer(
                                builder: (context, ref, child) {
                                  final currentSort = ref.watch(
                                    sortCriteriaProvider,
                                  );

                                  return AnimatedSwitcher(
                                    duration: Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) {
                                      return ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      );
                                    },
                                    child:
                                        currentSort == SortCriteria.recent
                                            ? AppIconButton(
                                              key: ValueKey('sort-default'),
                                              icon: Icons.sort,
                                              onPressed: _showSortDialog,
                                            )
                                            : Badge(
                                              key: ValueKey('sort-active'),
                                              smallSize: 6.h,
                                              child: AppIconButton(
                                                icon: _getSortIcon(currentSort),
                                                onPressed: _showSortDialog,
                                                iconColor:
                                                    colorScheme.onSurface,
                                              ),
                                            ),
                                  );
                                },
                              ),
                              Gap(10.w),
                            ],
                          );
                        },
                      ),
                  ],
                ),
        body:
            widget.currentUserId.isEmpty
                ? Center(
                  child: EmptyStateWidget(
                    compact: true,
                    type: EmptyStateType.noMessages,
                    title: 'No conversations yet',
                    subtitle:
                        'Your chats and conversations would appear here. You have to log in to start a conversation',
                  ),
                )
                : GestureDetector(
                  onTap: () {
                    // Tap anywhere outside to dismiss keyboard
                    _searchFocusNode.unfocus();
                  },
                  child: Column(
                    children: [
                      // Animated Search Bar
                      _buildAnimatedSearchBar(),

                      // Conversations List
                      Expanded(
                        child: ref
                            .watch(conversationsProvider)
                            .when(
                              data: (allConversations) {
                                if (filteredConversations.isEmpty) {
                                  final hasActiveQuery =
                                      isSearchActive || isFilterActive;
                                  return Center(
                                    child: EmptyStateWidget(
                                      compact: true,
                                      type:
                                          hasActiveQuery
                                              ? EmptyStateType.noResults
                                              : EmptyStateType.noMessages,
                                      title:
                                          hasActiveQuery
                                              ? 'No matches found'
                                              : 'No conversations yet',
                                      subtitle:
                                          hasActiveQuery
                                              ? 'Try a different search term or clear filters'
                                              : 'Start a new conversation to see it here',
                                      onAction:
                                          hasActiveQuery
                                              ? _resetToDefault
                                              : () {},
                                    ),
                                  );
                                }

                                return RefreshIndicator(
                                  onRefresh: () async {
                                    ref.invalidate(conversationsProvider);
                                    HapticFeedback.lightImpact();
                                  },
                                  child: ListView.builder(
                                    padding: EdgeInsets.only(top: Spacing.sm.h),
                                    itemCount: filteredConversations.length,
                                    itemBuilder: (context, index) {
                                      final conv = filteredConversations[index];
                                      // Key includes updatedAt so a
                                      // conversation bumped to the top by a
                                      // new message gets a fresh element and
                                      // replays its entry animation.
                                      final shouldAnimate = conv.updatedAt
                                          .isAfter(_openedAt);
                                      return AnimatedEntry(
                                        key: ValueKey(
                                          '${conv.id}-${conv.updatedAt.millisecondsSinceEpoch}',
                                        ),
                                        animate: shouldAnimate,
                                        beginOffset: const Offset(0, -0.06),
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        child: _buildConversationItem(conv),
                                      );
                                    },
                                  ),
                                );
                              },
                              loading:
                                  () => LoadingStateWidget(
                                    type: LoadingStateType.page,
                                  ),
                              error:
                                  (error, stackTrace) => Center(
                                    child: ErrorStateWidget(
                                      showDetails: true,
                                      compact: true,
                                      onPrimaryAction: () {
                                        ref.invalidate(conversationsProvider);
                                      },
                                      title: '',
                                      subtitle:
                                          'Unable to load conversations. This might be a temporary issue.',
                                      errorDetails: '',

                                      type: ErrorStateType.genericError,
                                    ),
                                  ),
                            ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  IconData _getSortIcon(SortCriteria criteria) {
    switch (criteria) {
      case SortCriteria.unread:
        return Icons.mark_chat_unread;
      case SortCriteria.groups:
        return Icons.group;
      case SortCriteria.individuals:
        return Icons.person;
      case SortCriteria.alphabetical:
        return Icons.sort_by_alpha;
      case SortCriteria.recent:
        return Icons.sort;
    }
  }
}
