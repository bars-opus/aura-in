import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nano_embryo/app/app.dart';
import 'package:nano_embryo/app/routing/routing_notifier.dart';
import 'package:nano_embryo/core/config/env.dart';
import 'package:nano_embryo/core/link/models/aurain_link_config.dart';
import 'package:nano_embryo/core/link/providers/link_providers.dart';
import 'package:nano_embryo/core/notifications/config/feature/notification_config.dart';
import 'package:nano_embryo/core/notifications/config/notification_config.dart';
import 'package:nano_embryo/presentation/features/chat/config/chat_config.dart';
import 'package:nano_embryo/presentation/features/chat/data/cache/chat_cache_service.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/core/providers/routing_providers.dart';
import 'package:nano_embryo/core/providers/shared_prefs_provider.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/data/local_freelancer_storage.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/local_draft_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Global variables
GoRouter? _appRouter;

final appLinksProvider = Provider<AppLinks>((ref) {
  return AppLinks();
});

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {

    // 2. Initialize SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();

    await Hive.initFlutter();

    // 2b. Initialize encrypted chat cache (must follow Hive.initFlutter)
    final chatCache = ChatCacheService();
    await chatCache.init();

    // 3. Initialize Supabase
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
      debug: Environment.isDebug,
    );

    // ============================================
    // 4. Initialize OneSignal (NEW)
    // ============================================
    await _initializeOneSignal();

    // 5. Create the routing notifier
    final routingNotifier = RoutingNotifier();

    // 6. Initialize deep link handling
    final appLinks = AppLinks();

    // Handle initial deep link (app opened from cold start)
    await _handleInitialDeepLink(appLinks, routingNotifier);

    // Listen for deep links while app is running
    appLinks.uriLinkStream.listen((Uri uri) async {
      if (_isOAuthCallback(uri)) {
        await _handleOAuthCallback(uri, routingNotifier);
      } else {
        _handleIncomingDeepLink(uri, routingNotifier);
      }
    });

    // Create both storages
    final draftStorage = await LocalDraftStorage.create();
    final freelancerStorage = await LocalFreelancerStorage.create();

    // Set both storages
    setLocalDraftStorage(draftStorage);
    setLocalFreelancerStorage(freelancerStorage);

    // Create the router ONCE and store globally
    _appRouter = createAppRouter(routingNotifier);

    // Get link config
    final linkConfig = AuraInLinkConfig.getConfig();

    // Get OneSignal App ID from environment
    final oneSignalAppId = Environment.oneSignalAppId ?? '';

    // 7. Run the app
    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          localDraftStorageProvider.overrideWith((ref) => draftStorage),
          localFreelancerStorageProvider.overrideWith(
            (ref) => freelancerStorage,
          ),
          linkConfigProvider.overrideWithValue(linkConfig),
          routingNotifierProvider.overrideWith((ref) => routingNotifier),
          appRouterProvider.overrideWithValue(_appRouter!),
          appLinksProvider.overrideWithValue(appLinks),

          // Add these commonly used providers
          supabaseClientProvider.overrideWithValue(Supabase.instance.client),

          // Add OneSignal App ID provider
          oneSignalAppIdProvider.overrideWithValue(oneSignalAppId),

          // Notification engine config — navigation callbacks + setting toggles
          notificationConfigProvider.overrideWithValue(
            buildNanoEmbryoNotificationConfig(),
          ),

          // Chat engine config — Sendbird app ID + optional UI customisation
          chatConfigProvider.overrideWithValue(
            ChatConfig(appId: Environment.sendbirdAppId),
          ),

          // Encrypted chat cache — initialized before runApp
          chatCacheServiceProvider.overrideWithValue(chatCache),
        ],
        child: const App(),
      ),
    );
  } catch (e, stackTrace) {
    // Professional error handling with stack trace
    debugPrint('Main initialization error: $e');
    debugPrint('Stack trace: $stackTrace');

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          child: Scaffold(
            body: ErrorStateWidget(
              showDetails: true,
              title: 'Initialization Error',
              compact: true,
              subtitle:
                  'Unable to initialize app.\nThis might be a temporary issue',
              errorDetails: e.toString(),
              type: ErrorStateType.genericError,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// ONESIGNAL INITIALIZATION
// ============================================

/// Initialize OneSignal push notifications
Future<void> _initializeOneSignal() async {
  try {
    // Get OneSignal App ID from environment
    final oneSignalAppId = Environment.oneSignalAppId;

    if (oneSignalAppId == null || oneSignalAppId.isEmpty) {
      debugPrint('⚠️ OneSignal App ID not configured, skipping initialization');
      return;
    }

    // Initialize OneSignal
    OneSignal.initialize(oneSignalAppId);

    // Request permission for iOS
    if (Platform.isIOS) {
      await OneSignal.Notifications.requestPermission(true);
    }

    // Set up notification handlers
    _setupOneSignalHandlers();

    debugPrint('✅ OneSignal initialized successfully');
  } catch (e) {
    debugPrint('❌ Failed to initialize OneSignal: $e');
  }
}

/// Setup OneSignal notification handlers
void _setupOneSignalHandlers() {
  // Handle when a notification is clicked/tapped
  OneSignal.Notifications.addClickListener((event) {
    debugPrint('🔔 OneSignal notification clicked');

    final additionalData = event.notification.additionalData;
    final type = additionalData?['type'] as String?;
    final bookingId = additionalData?['booking_id'] as String?;
    final shopId = additionalData?['shop_id'] as String?;
    final channelUrl = additionalData?['channel_url'] as String?;

    _handleNotificationNavigation(type, bookingId, shopId, channelUrl: channelUrl);
  });

  // Handle when a notification is received while app is in foreground
  // This is a void callback - do NOT return anything
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    debugPrint(
      '📨 Foreground notification received: ${event.notification.title}',
    );
    // The notification will display automatically
    // To prevent displaying: event.preventDefault();
  });

  // Handle permission changes
  OneSignal.Notifications.addPermissionObserver((state) {
    // debugPrint('🔔 Notification permission changed: ${state.hasPermission}');
  });
}

/// Handle navigation from notification tap.
/// Uses the global [_appRouter] which is available as soon as [main] runs.
void _handleNotificationNavigation(
  String? type,
  String? bookingId,
  String? shopId, {
  String? channelUrl,
}) {
  final router = _appRouter;
  if (router == null) return;

  switch (type) {
    case 'booking_reminder':
    case 'booking_created':
    case 'booking_confirmed':
    case 'booking_cancelled':
      // Navigate to the calendar which shows bookings.
      router.go(RouteNames.calendar);

    case 'new_shop_nearby':
      if (shopId != null && shopId.isNotEmpty) {
        router.push(
          RouteNames.shopDetailsScreen,
          extra: {'shopId': shopId, 'coverImageUrl': ''},
        );
      } else {
        router.go(RouteNames.home);
      }

    case 'review_request':
      router.go(RouteNames.home);

    case 'new_message':
      if (channelUrl != null && channelUrl.isNotEmpty) {
        router.push(
          '${RouteNames.chatChannel}?url=${Uri.encodeComponent(channelUrl)}',
        );
      } else {
        router.go(RouteNames.home);
      }

    default:
      router.go(RouteNames.home);
  }
}

// ============================================
// DEEP LINK HANDLERS
// ============================================

/// Handle initial deep link when app is opened from cold start
Future<void> _handleInitialDeepLink(
  AppLinks appLinks,
  RoutingNotifier routingNotifier,
) async {
  try {
    final initialLink = await appLinks.getInitialLink();
    if (initialLink == null) return;
    if (_isOAuthCallback(initialLink)) {
      await _handleOAuthCallback(initialLink, routingNotifier);
    } else {
      _processDeepLink(initialLink.toString(), routingNotifier);
    }
  } catch (e) {
    debugPrint('Error getting initial deep link: $e');
  }
}

/// Returns true when the URI is a Supabase OAuth callback.
/// Handles both the custom scheme (aurain://) and the HTTPS Universal Link
/// (https://aurain.barsopus.com/auth/callback) used for password reset emails so
/// they open correctly from Gmail's in-app WebView.
bool _isOAuthCallback(Uri uri) {
  if (uri.scheme == 'aurain' && uri.host == 'login-callback') {
    return true;
  }
  if (uri.scheme == 'https' &&
      uri.host == 'aurain.barsopus.com' &&
      uri.path == '/auth/callback') {
    return true;
  }
  return false;
}

/// Exchange the OAuth authorization code / tokens for a Supabase session.
/// Supabase Flutter handles both PKCE (?code=) and implicit (#access_token=) forms.
///
/// For password-recovery links (?type=recovery), sets isRecoveryMode on the
/// RoutingNotifier BEFORE calling getSessionFromUrl. On cold start this runs
/// before runApp(), so the router is created with the flag already true and
/// immediately redirects to UpdatePasswordScreen.
Future<void> _handleOAuthCallback(Uri uri, RoutingNotifier routingNotifier) async {
  // aurain:// redirect carries ?type=recovery directly in the URL.
  // HTTPS Universal Link redirect (aurain.barsopus.com/auth/callback) carries ?code=
  // only — we must detect recovery from the auth stream event instead.
  final isRecoveryUrl = uri.queryParameters['type'] == 'recovery';
  if (isRecoveryUrl) routingNotifier.setRecoveryMode(true);

  // Subscribe BEFORE calling getSessionFromUrl so we don't miss the event.
  // Only cancel once we see passwordRecovery — Supabase fires signedIn first,
  // and cancelling on the first event would miss the recovery event entirely.
  late final StreamSubscription<AuthState> sub;
  sub = Supabase.instance.client.auth.onAuthStateChange.listen((state) {
    if (state.event == AuthChangeEvent.passwordRecovery) {
      routingNotifier.setRecoveryMode(true);
      sub.cancel();
    }
  });

  try {
    await Supabase.instance.client.auth.getSessionFromUrl(uri);
    debugPrint('✅ OAuth session established from deep link');
  } catch (e) {
    debugPrint('❌ Failed to establish OAuth session from deep link: $e');
    sub.cancel();
    if (isRecoveryUrl) routingNotifier.setRecoveryMode(false);
  }
}

/// Handle incoming deep links while app is running
void _handleIncomingDeepLink(Uri uri, RoutingNotifier routingNotifier) {
  debugPrint('🔗 Deep link received: $uri');
  _processDeepLink(uri.toString(), routingNotifier);
}

/// Process a deep link and store it in RoutingNotifier
void _processDeepLink(String link, RoutingNotifier routingNotifier) {
  final uri = Uri.parse(link);
  String? slug;
  String? linkType;

  debugPrint('🔍 Parsing link: $link');
  debugPrint('   Scheme: ${uri.scheme}');
  debugPrint('   Host: ${uri.host}');
  debugPrint('   Path: ${uri.path}');
  debugPrint('   Path segments: ${uri.pathSegments}');

  if (uri.scheme == 'aurain') {
    // Custom scheme: host is the link type (shop/worker/booking)
    // Path segments contain the slug
    linkType = uri.host; // 'shop', 'worker', 'booking'
    slug = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;

    if (slug != null) {
      debugPrint(
        '📱 Extracted type: $linkType, slug: $slug from custom scheme',
      );
    }
  } else if (uri.scheme == 'https' &&
      (uri.host == 'aurain.barsopus.com' ||
          uri.host.contains('localhost'))) {
    // HTTPS universal/web links: path segments contain ['l', 'slug']
    final segments = uri.pathSegments;
    if (segments.isNotEmpty && segments[0] == 'l' && segments.length >= 2) {
      slug = segments[1];
      debugPrint('🌐 Extracted slug from web URL: $slug');
    }
  }

  if (slug != null && slug.isNotEmpty) {
    routingNotifier.setPendingDeepLink(slug);
    debugPrint('📌 Deep link stored for Aura-In, waiting for auth: $slug');
  } else {
    debugPrint('⚠️ Could not extract slug from link: $link');
  }
}

// ============================================
// PROVIDERS
// ============================================

/// Provider for OneSignal App ID
final oneSignalAppIdProvider = Provider<String?>((ref) => null);

// ============================================
// SETTER FUNCTIONS
// ============================================

void setLocalDraftStorage(LocalDraftStorage storage) {
  // Your implementation - set global or pass through provider
}

void setLocalFreelancerStorage(LocalFreelancerStorage storage) {
  // Your implementation - set global or pass through provider
}
