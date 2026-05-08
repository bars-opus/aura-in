import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/core/utils/network_status.dart';
import 'package:nano_embryo/presentation/features/auth/log_in/presentation/screens/login_profile.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/screens/chat_home_screen.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/state/chat_state.dart';
import 'package:nano_embryo/presentation/features/discover/screens/discover_screen.dart';
import 'package:nano_embryo/presentation/features/map/presentation/screens/map_screen.dart';
import 'package:nano_embryo/presentation/features/profile/widgets/profile_screen.dart';
import 'package:nano_embryo/presentation/home/widgets/home_tab.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/home/widgets/home_widget_responsive.dart';

class HomeScreen extends ConsumerWidget {
  // Change to ConsumerWidget
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add WidgetRef
    final loc = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final unreadCount = ref.watch(unreadCountProvider).valueOrNull ?? 0;

    final tabs = [
      HomeTab(
        id: 'home',
        label: loc.homeTitle,
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        screen: const DiscoverScreen(),
      ),
      HomeTab(
        id: 'map',
        label: 'Map',
        icon: Icons.map_outlined,
        activeIcon: Icons.map,
        screen:
            //  const CalendarScreen(isFromProfile: false),
            MapScreen(),
      ),
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
        screen:
            user != null
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
