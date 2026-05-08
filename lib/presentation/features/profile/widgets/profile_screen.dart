import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/profile_providers/profile_provider.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/chat/data/repositories/chat_repository.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/screens/chat_screen.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/state/chat_state.dart';
import 'package:nano_embryo/presentation/features/profile/models/profile.dart';
import 'package:nano_embryo/presentation/features/profile/models/profile_search_result.dart';
import 'package:nano_embryo/presentation/features/profile/widgets/tab_bar_delegate.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String currentUserId;
  final String profileUserId;
  final ProfileSearchResult? profileSearchResult;

  const ProfileScreen({
    super.key,
    required this.currentUserId,
    required this.profileUserId,
    this.profileSearchResult,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length:
          buildProfileTabs(
            widget.profileUserId,
            widget.currentUserId == widget.profileUserId,
          ).length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildLoadingShimmer(bool isLoading) {
    return _buildBody(
      username: '...',
      displayName: 'Loading...',
      bio: '-',
      avatarUrl: '',
      isAuthor: widget.profileUserId == widget.currentUserId,
      followersCount: 0,
      followingCount: 0,
      isLoading: isLoading,
    );
  }

  // Add this method to _ProfileScreenState class

  // Add this method to _ProfileScreenState

  // Complete implementation
  Future<void> _startPrivateChat() async {
    if (widget.profileUserId == widget.currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can't chat with yourself")),
      );
      return;
    }

    try {
      debugPrint('💬 [START-CHAT] currentUserId=${widget.currentUserId} | profileUserId=${widget.profileUserId}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 12),
              Text('Starting conversation...'),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );

      // Resolve display name from search result (already in memory) or profile fetch.
      final String displayName;
      if (widget.profileSearchResult != null) {
        displayName = widget.profileSearchResult!.displayName ??
            widget.profileSearchResult!.username ??
            'User';
      } else {
        final profile = await ref.read(profileProvider(userId: widget.profileUserId).future);
        displayName = profile?.displayName ?? profile?.username ?? 'User';
      }

      // ── Server-side channel creation ──────────────────────────────────────
      // The Edge Function upserts both users in Sendbird (creating their accounts
      // if they don't exist yet) and then creates a distinct 1:1 channel.
      // This is necessary because the Flutter SDK cannot add users that have
      // never connected to Sendbird.
      final supabase = ref.read(supabaseClientProvider);
      final session = supabase.auth.currentSession;
      if (session == null) throw Exception('No active session — please log in again.');

      debugPrint('💬 [START-CHAT] calling create-sendbird-channel for target=${widget.profileUserId} | token=${session.accessToken.substring(0, 20)}...');

      final fnResult = await supabase.functions.invoke(
        'create-sendbird-channel',
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
        body: {
          'target_user_id': widget.profileUserId,
          'channel_name': displayName,
        },
      );

      final channelUrl = (fnResult.data as Map<String, dynamic>?)?['channel_url'] as String?;
      if (channelUrl == null || channelUrl.isEmpty) {
        throw Exception('create-sendbird-channel returned no channel_url: ${fnResult.data}');
      }
      debugPrint('💬 [START-CHAT] channel_url=$channelUrl');

      // Ensure the Sendbird SDK is connected before loading the channel.
      final isConnected = ref.read(connectionProvider);
      if (!isConnected && widget.currentUserId.isNotEmpty) {
        await ref.read(connectionProvider.notifier).connect(widget.currentUserId);
      }

      // Load the conversation object via the SDK using the server-provided URL.
      final chatRepository = ref.read(chatRepositoryProvider);
      final conversation = await chatRepository.getChannel(channelUrl);

      // Enrich with Supabase avatar since Sendbird's coverUrl may be empty.
      final profileAvatarUrl = widget.profileSearchResult?.avatarUrl ??
          (widget.profileSearchResult == null
              ? await ref
                    .read(profileProvider(userId: widget.profileUserId).future)
                    .then((p) => p?.avatarUrl)
                    .catchError((_) => null)
              : null);

      final enrichedConversation = conversation.copyWith(
        name: displayName,
        avatarUrl: profileAvatarUrl ?? conversation.avatarUrl,
      );

      debugPrint('💬 [START-CHAT] navigating: name="${enrichedConversation.name}" | members=${enrichedConversation.participants}');

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(conversation: enrichedConversation),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ [START-CHAT] error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildBody({
    required String username,
    required String displayName,
    required String bio,
    required String avatarUrl,
    required bool isAuthor,
    required bool isLoading,
    required int followersCount,
    required int followingCount,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 300.h,
              collapsedHeight: 30.h,
              floating: false,
              toolbarHeight: 30.h,
              pinned: true,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: SafeArea(
                  child: Column(
                    children: [
                      // Header row with username and menu
                      Row(
                        mainAxisAlignment:
                            isAuthor
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.spaceBetween,
                        children: [
                          if (!isAuthor)
                            AppIconButton(
                              icon:
                                  Platform.isIOS
                                      ? Icons.arrow_back_ios
                                      : Icons.arrow_back,
                              onPressed: () => Navigator.pop(context),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AppIconButton(
                                icon: Icons.expand_more,
                                onPressed: () {},
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '@$username',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 15),
                              if (isAuthor)
                                AppIconButton(
                                  icon: Icons.notifications_active_outlined,
                                  onPressed:
                                      () => context.showLoadingSnackbar(
                                        'Loading...',
                                      ),
                                ),
                              if (isAuthor)
                                AppIconButton(
                                  icon: Icons.menu,
                                  onPressed:
                                      () => context.push(
                                        '/settings',
                                        extra: widget.currentUserId,
                                      ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      ProfileHeader(
                        mode: ProfileHeaderMode.detailed,
                        displayName: displayName,
                        userId: widget.currentUserId,
                        bio: bio,
                        isCurrentUser: isAuthor,
                        avatarUrl: avatarUrl,
                        followersCount: followersCount,
                        isLoading: isLoading,
                        followingCount: followingCount,
                        onMessagePressed:
                            widget.currentUserId.isEmpty
                                ? () {
                                  context.showErrorSnackbar(
                                    'You have to sign in to send a message',
                                  );
                                }
                                : isAuthor
                                ? null // Can't message yourself
                                : () => _startPrivateChat(),

                        onEditPressed:
                            isAuthor
                                ? () => context.push(
                                  '/editScreen',
                                  extra: widget.currentUserId,
                                )
                                : null,
                        onFollowPressed:
                            !isAuthor
                                ? () {
                                  context.showLoadingSnackbar(
                                    'Follow feature coming soon',
                                  );
                                }
                                : null,
                        showStats: true,
                        showActions: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: TabBarDelegate(
                tabs: buildProfileTabs(widget.currentUserId, isAuthor),
                tabController: _tabController,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children:
              buildProfileTabs(
                widget.currentUserId,
                isAuthor,
              ).map((tab) => tab.content ?? const SizedBox.shrink()).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isAuthor = widget.profileUserId == widget.currentUserId;

    // ✅ Direct data from search result (no need to fetch again)
    if (widget.profileSearchResult != null) {
      final profile = widget.profileSearchResult!;
      return _buildBody(
        username: profile.username ?? '',
        displayName: profile.displayName ?? profile.username ?? '',
        bio:
            profile.bio ??
            (isAuthor ? 'Enter a bio so people can know you' : 'No bio yet'),
        avatarUrl: profile.avatarUrl ?? '',
        isAuthor: isAuthor,
        followersCount: 1232,
        followingCount: 5464,
        isLoading: false,
      );
    }

    // ✅ IMPORTANT FIX: Use different providers for author vs other users
    AsyncValue<Profile?> profileAsync;

    if (isAuthor) {
      // For own profile - use currentUserProfileProvider (auto-refreshes after edit)
      profileAsync = ref.watch(currentUserProfileProvider);
    } else {
      // For other users - fetch directly
      profileAsync = ref.watch(profileProvider(userId: widget.profileUserId));
    }

    // Loading state
    if (profileAsync.isLoading) {
      return _buildLoadingShimmer(true);
    }

    // Error or missing state
    if (profileAsync.hasError || profileAsync.value == null) {
      return Scaffold(
        body: ErrorStateWidget(
          showDetails: true,
          onPrimaryAction: () {},
          title: '',
          subtitle:
              'Unable to load profile.\nThis might be a temporary issue. Check your internet and try again',
          errorDetails: '',
          type: ErrorStateType.genericError,
        ),
      );
    }

    final profile = profileAsync.value!;
    final username = profile.username ?? 'anonymous';
    final displayName = profile.displayName ?? username;
    final bio =
        profile.bio ??
        (isAuthor ? 'Enter a bio so people can know you' : 'No bio yet');
    final avatarUrl = profile.avatarUrl;

    return _buildBody(
      username: username,
      displayName: displayName,
      bio: bio,
      avatarUrl: avatarUrl ?? '',
      isAuthor: isAuthor,
      followersCount: 3452,
      followingCount: 24325,
      isLoading: false,
    );
  }
}
