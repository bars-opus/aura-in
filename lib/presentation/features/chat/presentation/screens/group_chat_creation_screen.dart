import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/screens/chat_screen.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/state/chat_state.dart';

class GroupChatCreationScreen extends ConsumerStatefulWidget {
  const GroupChatCreationScreen({super.key});

  @override
  ConsumerState<GroupChatCreationScreen> createState() =>
      _GroupChatCreationScreenState();
}

class _GroupChatCreationScreenState
    extends ConsumerState<GroupChatCreationScreen> {
  final _groupNameController = TextEditingController();
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  final List<_UserResult> _selectedUsers = [];
  List<_UserResult> _searchResults = [];
  bool _isLoadingSearch = false;
  bool _isCreating = false;
  Timer? _debounce;

  @override
  void dispose() {
    _groupNameController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoadingSearch = true);

    try {
      final currentUserId = ref.read(currentUserProvider)?.id ?? '';
      final client = ref.read(supabaseClientProvider);
      final q = query.trim().toLowerCase();

      final data = await client
          .from('profiles')
          .select('id, username, display_name, avatar_url')
          .or('username.ilike.%$q%,display_name.ilike.%$q%')
          .neq('id', currentUserId)
          .limit(20);

      if (!mounted) return;

      final results = (data as List<dynamic>).map((row) {
        final map = row as Map<String, dynamic>;
        return _UserResult(
          id: map['id'] as String,
          displayName: (map['display_name'] as String?) ??
              (map['username'] as String?) ??
              'User',
          username: map['username'] as String? ?? '',
          avatarUrl: map['avatar_url'] as String?,
        );
      }).toList();

      setState(() {
        _searchResults = results
            .where((r) => !_selectedUsers.any((s) => s.id == r.id))
            .toList();
        _isLoadingSearch = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingSearch = false);
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  void _selectUser(_UserResult user) {
    setState(() {
      _selectedUsers.add(user);
      _searchResults.removeWhere((r) => r.id == user.id);
    });
  }

  void _removeUser(_UserResult user) {
    setState(() {
      _selectedUsers.removeWhere((u) => u.id == user.id);
      if (_searchController.text.isNotEmpty) {
        _searchResults.insert(0, user);
      }
    });
  }

  Future<void> _createGroup() async {
    if (_selectedUsers.isEmpty) return;
    setState(() => _isCreating = true);

    try {
      final groupName = _groupNameController.text.trim().isNotEmpty
          ? _groupNameController.text.trim()
          : _selectedUsers.map((u) => u.displayName).join(', ');

      final conversation = await ref.read(chatRepositoryProvider).createChannel(
        name: groupName,
        userIds: _selectedUsers.map((u) => u.id).toList(),
        isPublic: false,
        isDistinct: false,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(conversation: conversation),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create group: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canCreate = _selectedUsers.isNotEmpty && !_isCreating;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text('New Group Chat'),
        actions: [
          if (_isCreating)
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: TextButton(
                onPressed: canCreate ? _createGroup : null,
                child: Text(
                  'Create',
                  style: TextStyle(
                    color: canCreate
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Group name ────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              Spacing.md.w,
              Spacing.sm.h,
              Spacing.md.w,
              0,
            ),
            child: TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                hintText: 'Group name (optional)',
                prefixIcon: const Icon(Icons.group_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _searchFocus.requestFocus(),
            ),
          ),

          // ── Selected users chips ──────────────────────────────────
          if (_selectedUsers.isNotEmpty) ...[
            SizedBox(height: Spacing.sm.h),
            SizedBox(
              height: 48.h,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
                scrollDirection: Axis.horizontal,
                itemCount: _selectedUsers.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final user = _selectedUsers[index];
                  return InputChip(
                    avatar: _buildAvatar(user, radius: 14),
                    label: Text(user.displayName),
                    onDeleted: () => _removeUser(user),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                },
              ),
            ),
          ],

          SizedBox(height: Spacing.sm.h),

          // ── Search field ─────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name or username...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        },
                      )
                    : null,
              ),
            ),
          ),

          SizedBox(height: Spacing.sm.h),

          // ── Results ───────────────────────────────────────────────
          Expanded(child: _buildResults(colorScheme)),
        ],
      ),
    );
  }

  Widget _buildResults(ColorScheme colorScheme) {
    if (_isLoadingSearch) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search,
              size: 56.h,
              color: colorScheme.onSurface.withValues(alpha: 0.25),
            ),
            SizedBox(height: Spacing.sm.h),
            Text(
              'Search for people to add',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'No users found',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: Spacing.md.h),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return ListTile(
          leading: _buildAvatar(user, radius: 22),
          title: Text(user.displayName),
          subtitle: user.username.isNotEmpty
              ? Text(
                  '@${user.username}',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                )
              : null,
          trailing: Icon(Icons.add_circle_outline, color: colorScheme.primary),
          onTap: () => _selectUser(user),
        );
      },
    );
  }

  Widget _buildAvatar(_UserResult user, {required double radius}) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius.h,
      backgroundImage:
          user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
      backgroundColor: colorScheme.primaryContainer,
      child: user.avatarUrl == null
          ? Text(
              user.displayName.isNotEmpty
                  ? user.displayName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontSize: (radius * 0.75).sp,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
  }
}

class _UserResult {
  final String id;
  final String displayName;
  final String username;
  final String? avatarUrl;

  const _UserResult({
    required this.id,
    required this.displayName,
    required this.username,
    this.avatarUrl,
  });
}
