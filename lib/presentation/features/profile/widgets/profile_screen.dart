import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/moderation/config/moderation_config.dart';
import 'package:nano_embryo/core/moderation/data/moderation_models.dart';
import 'package:nano_embryo/core/moderation/presentation/providers/moderation_provider.dart';
import 'package:nano_embryo/core/moderation/presentation/widgets/moderation_unavailable_widget.dart';
import 'package:nano_embryo/core/notifications/presentation/widgets/notification_bell_icon.dart';
import 'package:nano_embryo/core/providers/profile_providers/profile_provider.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/screens/chat_screen.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/state/chat_state.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/account_products_provider.dart';
import 'package:nano_embryo/presentation/features/profile/models/profile.dart';
import 'package:nano_embryo/presentation/features/profile/models/profile_search_result.dart';
import 'package:nano_embryo/presentation/features/admin/providers/admin_provider.dart';
import 'package:nano_embryo/presentation/features/profile/widgets/tab_bar_delegate.dart';
import 'package:nano_embryo/presentation/features/profile/providers/user_activity_counts_provider.dart';

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
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController? _tabController;
  int _tabCount = 0;

  @override
  void initState() {
    super.initState();
    _tabCount =
        buildProfileTabs(
          widget.profileUserId,
          widget.currentUserId == widget.profileUserId,
          false,
        ).length;
    _tabController = TabController(length: _tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildLoadingShimmer(bool isLoading) {
    final loc = AppLocalizations.of(context)!;
    return _buildBody(
      username: '...',
      displayName: 'Loading...',
      bio: '-',
      avatarUrl: '',
      isAuthor: widget.profileUserId == widget.currentUserId,
      bookingCount: 0,
      shopingCount: 0,
      isLoading: isLoading,
      loc: loc,
    );
  }

  Future<void> _startPrivateChat() async {
    final loc = AppLocalizations.of(context)!;
    if (widget.profileUserId == widget.currentUserId) {
      context.showErrorSnackbar(loc.profileScreenCantChatWithYourself);
      return;
    }

    try {
      debugPrint(
        '💬 [START-CHAT] currentUserId=${widget.currentUserId} | profileUserId=${widget.profileUserId}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const Gap(Spacing.sm),
              Text(loc.profileScreenStartingConversation),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      // Resolve display name from search result (already in memory) or profile fetch.
      final String displayName;
      if (widget.profileSearchResult != null) {
        displayName =
            widget.profileSearchResult!.displayName ??
            widget.profileSearchResult!.username ??
            'User';
      } else {
        final profile = await ref.read(
          profileProvider(userId: widget.profileUserId).future,
        );
        displayName = profile?.displayName ?? profile?.username ?? 'User';
      }

      // ── Server-side channel creation ──────────────────────────────────────
      // The Edge Function upserts both users in Sendbird (creating their accounts
      // if they don't exist yet) and then creates a distinct 1:1 channel.
      // This is necessary because the Flutter SDK cannot add users that have
      // never connected to Sendbird.
      final supabase = ref.read(supabaseClientProvider);
      final session = supabase.auth.currentSession;
      if (session == null) {
        throw Exception(loc.profileScreenNoActiveSession);
      }

      final moderation = await ref.read(
        moderationBlockStatusProvider(widget.profileUserId).future,
      );
      if (moderation.isBlocked) {
        if (mounted) {
          context.showErrorSnackbar(
            ref
                .read(moderationConfigProvider)
                .texts(context)
                .blockedUnavailableBody,
          );
        }
        return;
      }

      debugPrint(
        '💬 [START-CHAT] calling create-sendbird-channel for target=${widget.profileUserId} | token=${session.accessToken.substring(0, 20)}...',
      );

      final fnResult = await supabase.functions.invoke(
        'create-sendbird-channel',
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
        body: {
          'target_user_id': widget.profileUserId,
          'channel_name': displayName,
        },
      );

      final channelUrl =
          (fnResult.data as Map<String, dynamic>?)?['channel_url'] as String?;
      if (channelUrl == null || channelUrl.isEmpty) {
        throw Exception(
          '${loc.profileScreenStartingConversation} ${fnResult.data}',
        );
      }
      debugPrint('💬 [START-CHAT] channel_url=$channelUrl');

      // Ensure the Sendbird SDK is connected before loading the channel.
      final isConnected = ref.read(connectionProvider);
      if (!isConnected && widget.currentUserId.isNotEmpty) {
        await ref
            .read(connectionProvider.notifier)
            .connect(widget.currentUserId);
      }

      // Load the conversation object via the SDK using the server-provided URL.
      final chatRepository = ref.read(chatRepositoryProvider);
      final conversation = await chatRepository.getChannel(channelUrl);

      // Enrich with Supabase avatar since Sendbird's coverUrl may be empty.
      final profileAvatarUrl =
          widget.profileSearchResult?.avatarUrl ??
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

      debugPrint(
        '💬 [START-CHAT] navigating: name="${enrichedConversation.name}" | members=${enrichedConversation.participants}',
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ChatScreen(conversation: enrichedConversation),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ [START-CHAT] error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        context.showErrorSnackbar('${loc.commonSomethingWentWrong}: $e');
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
    required int bookingCount,
    required int shopingCount,
    required AppLocalizations loc,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final productsState = ref.watch(
      accountProductsProvider(widget.profileUserId),
    );
    // Real activity counts (public, via SECURITY DEFINER RPC). Falls back to
    // zero while loading / on error so the header never blocks or shows stale
    // placeholder numbers. Supersedes the bookingCount/shopingCount params,
    // which were hardcoded placeholders.
    final activityCounts =
        ref.watch(userActivityCountsProvider(widget.profileUserId)).valueOrNull;
    final realBookingCount = activityCounts?.bookingCount ?? 0;
    final realOrderCount = activityCounts?.orderCount ?? 0;
    final showBuysTab =
        productsState.isInitialLoading || productsState.items.isNotEmpty;
    final tabs = buildProfileTabs(
      // The tabs reflect the profile being VIEWED, so the first arg is
      // profileUserId (matches the init call above). Passing currentUserId
      // here showed the viewer's own data on other people's profiles.
      widget.profileUserId,
      isAuthor,
      false,
      loc: loc,
      showBuysTab: showBuysTab,
    );
    _syncTabController(tabs.length);
    final tabController = _tabController!;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: SafeArea(
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
                            Text(
                              '@$username',
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(Spacing.sm),
                            if (isAuthor) const NotificationBellIcon(),
                            if (isAuthor)
                              AppIconButton(
                                icon: Icons.menu,
                                onPressed:
                                    () => context.push(
                                      '/settings',
                                      extra: widget.currentUserId,
                                    ),
                              ),
                            if (!isAuthor)
                              AppIconButton(
                                icon: Icons.more_vert_outlined,
                                onPressed: () {
                                  BottomSheetUtils.showDocumentationBottomSheet(
                                    padding: Spacing.md,
                                    maxHeight: 570.h,
                                    context: context,
                                    widget: MoreScreen(
                                      moderationTarget: ModerationTarget(
                                        targetType:
                                            ModerationTargetType.profile,
                                        targetId: widget.profileUserId,
                                        targetOwnerId: widget.profileUserId,
                                        displayName: displayName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                    ProfileHeader(
                      mode: ProfileHeaderMode.detailed,
                      displayName: displayName,
                      userId: widget.profileUserId,
                      bio: bio,
                      isCurrentUser: isAuthor,
                      avatarUrl: avatarUrl,
                      bookingCount: realBookingCount,
                      isLoading: isLoading,
                      shopingCount: realOrderCount,
                      onMessagePressed:
                          widget.currentUserId.isEmpty
                              ? () {
                                context.showErrorSnackbar(
                                  loc.profileScreenSignInToChatMessage,
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
                                  loc.profileScreenFollowFeatureComingSoon,
                                );
                              }
                              : null,
                      showStats: true,
                      showActions: true,
                    ),
                    if (isAuthor)
                      ref
                          .watch(isCurrentUserAdminProvider)
                          .maybeWhen(
                            data:
                                (isAdmin) =>
                                    isAdmin
                                        ? CardInkWell(
                                          margin: EdgeInsets.only(bottom: 10.h),
                                          child: InfoRowWidget(
                                            title: 'Verification queue',
                                            subtitle:
                                                'Review pending producer documents',
                                            icon: Icons.verified_user_outlined,
                                            avatarRadius: 25.h,
                                            onTap:
                                                () => context.push(
                                                  '/adminVerificationQueue',
                                                ),
                                            showAvatar: false,
                                            showTrailingArrow: true,
                                            showDivider: false,
                                          ),
                                        )
                                        : const SizedBox.shrink(),
                            orElse: () => const SizedBox.shrink(),
                          ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: TabBarDelegate(
                tabs: tabs,
                tabController: tabController,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: tabController,
          children:
              tabs
                  .map((tab) => tab.content ?? const SizedBox.shrink())
                  .toList(),
        ),
      ),
    );
  }

  void _syncTabController(int length) {
    if (_tabController != null && _tabCount == length) return;
    final previousIndex = _tabController?.index ?? 0;
    _tabController?.dispose();
    _tabCount = length;
    _tabController = TabController(
      length: length,
      vsync: this,
      initialIndex:
          length == 0 ? 0 : previousIndex.clamp(0, length - 1).toInt(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final loc = AppLocalizations.of(context)!;
    final isAuthor = widget.profileUserId == widget.currentUserId;
    final moderationTexts = ref.watch(moderationConfigProvider).texts(context);
    final blockStatusAsync =
        isAuthor || widget.currentUserId.isEmpty
            ? const AsyncData(
              ModerationCheckResult(
                isBlocked: false,
                isBlockedByCurrentUser: false,
                isBlockingCurrentUser: false,
              ),
            )
            : ref.watch(moderationBlockStatusProvider(widget.profileUserId));

    if (!isAuthor && blockStatusAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!isAuthor && blockStatusAsync.hasError) {
      return Scaffold(
        appBar: AppBar(),
        body: ModerationUnavailableWidget(texts: moderationTexts),
      );
    }

    final blockStatus = blockStatusAsync.valueOrNull;
    if (blockStatus?.isBlocked == true) {
      return Scaffold(
        appBar: AppBar(),
        body: ModerationUnavailableWidget(texts: moderationTexts),
      );
    }

    // ✅ Direct data from search result (no need to fetch again)
    if (widget.profileSearchResult != null) {
      final profile = widget.profileSearchResult!;
      return _buildBody(
        username: profile.username ?? '',
        displayName: profile.displayName ?? profile.username ?? '',
        bio: profile.bio ?? '',
        avatarUrl: profile.avatarUrl ?? '',
        isAuthor: isAuthor,
        bookingCount: 1232,
        shopingCount: 5464,
        isLoading: false,
        loc: loc,
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
          showDetails: false,
          onPrimaryAction: () {
            if (isAuthor) {
              ref.invalidate(currentUserProfileProvider);
            } else {
              ref.invalidate(profileProvider(userId: widget.profileUserId));
            }
          },
          subtitle: loc.profileScreenErrorLoadingProfileBody,
          errorDetails: profileAsync.error?.toString(),
          type: ErrorStateType.networkError,
        ),
      );
    }

    final profile = profileAsync.value!;
    final username = profile.username ?? 'anonymous';
    final displayName = profile.displayName ?? username;
    final bio =
        profile.bio ??
        (isAuthor
            ? loc.profileScreenEnterBioPlaceholder
            : loc.profileScreenNoBioYet);
    final avatarUrl = profile.avatarUrl;

    return _buildBody(
      username: username,
      displayName: displayName,
      bio: bio,
      avatarUrl: avatarUrl ?? '',
      isAuthor: isAuthor,
      bookingCount: 3452,
      shopingCount: 24325,
      isLoading: false,
      loc: loc,
    );
  }
}
