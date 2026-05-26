import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/profile_providers/profile_provider.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/core/utils/network_status.dart';
import 'package:nano_embryo/presentation/features/auth/log_in/presentation/screens/login_profile.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/screens/chat_home_screen.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/state/chat_state.dart';
import 'package:nano_embryo/presentation/features/discover/screens/discover_screen.dart';
import 'package:nano_embryo/core/map/presentation/screens/map_screen.dart';
import 'package:nano_embryo/presentation/features/profile/models/profile_role.dart';
import 'package:nano_embryo/presentation/features/profile/widgets/profile_screen.dart';
import 'package:nano_embryo/presentation/home/widgets/home_tab.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/home/widgets/home_widget_responsive.dart';
import 'package:nano_embryo/presentation/home/widgets/owner_dashboard_tab.dart';
import 'package:nano_embryo/presentation/home/widgets/owner_schedule_tab.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final unreadCount = ref.watch(unreadCountProvider).valueOrNull ?? 0;

    // Default to client while the async role fetch is in flight — no flicker.
    final role = ref.watch(currentUserPrimaryRoleProvider).valueOrNull ??
        AccountType.client;

    final isOwner = role == AccountType.shop || role == AccountType.worker;

    final tabs = [
      // ── Tab 0: Discover (client) ↔ Schedule (owner) ──────────────────────
      if (isOwner)
        HomeTab(
          id: 'schedule',
          label: 'Schedule',
          icon: Icons.calendar_today_outlined,
          activeIcon: Icons.calendar_today,
          screen: OwnerScheduleTab(role: role),
        )
      else
        HomeTab(
          id: 'home',
          label: loc.homeTitle,
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          screen: const DiscoverScreen(),
        ),

      // ── Tab 1: Map (client) ↔ Dashboard (owner) ──────────────────────────
      if (isOwner)
        HomeTab(
          id: 'dashboard',
          label: 'Dashboard',
          icon: Icons.bar_chart_outlined,
          activeIcon: Icons.bar_chart,
          screen: OwnerDashboardTab(role: role),
        )
      else
        HomeTab(
          id: 'map',
          label: 'Map',
          icon: Icons.map_outlined,
          activeIcon: Icons.map,
          screen: MapEngineScreen(),
        ),

      // ── Tab 2 & 3: unchanged across all roles ────────────────────────────
      HomeTab(
        id: 'chat',
        label: loc.chatTitle,
        icon: Icons.chat_bubble_outline_outlined,
        activeIcon: Icons.chat,
        badgeCount: unreadCount,
        screen: ChatHomeScreen(currentUserId: user?.id ?? ''),
      ),
      HomeTab(
        id: 'profile',
        label: loc.profileTitle,
        icon: Icons.person_outlined,
        activeIcon: Icons.person,
        screen: user != null
            ? ProfileScreen(
                currentUserId: user.id,
                profileUserId: user.id,
                profileSearchResult: null,
              )
            : const LoginProfile(),
      ),
    ];

    return NetworkStatus(
      child: HomeWidgetResponsive.adaptive(context: context, tabs: tabs),
    );
  }
}
