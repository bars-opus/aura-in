import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nano_embryo/app/app.dart';
import 'package:nano_embryo/app/routing/routing_notifier.dart';
import 'package:nano_embryo/core/account_lifecycle/config/account_lifecycle_config.dart';
import 'package:nano_embryo/core/account_lifecycle/config/feature/account_lifecycle_config.dart';
import 'package:nano_embryo/core/config/env.dart';
import 'package:nano_embryo/core/link/config/aurain_link_config.dart';
import 'package:nano_embryo/core/link/providers/link_providers.dart';
import 'package:nano_embryo/core/map/config/feature/map_config.dart'
    show mapConfigProvider;
import 'package:nano_embryo/core/map/config/map_config.dart'
    show buildNanoEmbryoMapConfig;
import 'package:nano_embryo/core/moderation/config/feature/moderation_config.dart';
import 'package:nano_embryo/core/moderation/config/moderation_config.dart';
import 'package:nano_embryo/core/network/timeout_http_client.dart';
import 'package:nano_embryo/core/notifications/config/feature/notification_config.dart';
import 'package:nano_embryo/core/notifications/config/notification_config.dart';
import 'package:nano_embryo/presentation/features/chat/config/chat_config.dart';
import 'package:nano_embryo/presentation/features/chat/data/cache/chat_cache_service.dart';
import 'package:nano_embryo/payment/config/payment_config.dart';
import 'package:nano_embryo/payment/presentation/screens/payment_failure_screen.dart';
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

    // 3. Initialize Supabase with a hard per-request timeout so a stalled
    // network (cell handover, captive-portal) cannot hang requests
    // indefinitely. Checklist v3.1 P1 1.2.
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
      debug: Environment.isDebug,
      httpClient: TimeoutHttpClient(total: const Duration(seconds: 20)),
    );

    // ============================================
    // 4. Initialize OneSignal (NEW)
    // ============================================
    await _initializeOneSignal();

    // 5. Create the routing notifier with persistent recovery flag so a
    //    mid-flow force-quit still re-prompts for the new password.
    final routingNotifier = RoutingNotifier(prefs: sharedPreferences);

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

          // Map engine config — data source + filter schema + marker style + copy
          mapConfigProvider.overrideWithValue(buildNanoEmbryoMapConfig()),

          // Notification engine config — navigation callbacks + setting toggles
          notificationConfigProvider.overrideWithValue(
            buildNanoEmbryoNotificationConfig(),
          ),

          // Account lifecycle engine config — routes, localized copy, cleanup
          accountLifecycleConfigProvider.overrideWithValue(
            buildNanoEmbryoAccountLifecycleConfig(),
          ),

          moderationConfigProvider.overrideWithValue(
            buildNanoEmbryoModerationConfig(),
          ),

          // Chat engine config — Sendbird app ID + optional UI customisation
          chatConfigProvider.overrideWithValue(
            ChatConfig(appId: Environment.sendbirdAppId),
          ),

          // Payment engine config — app scheme + currency + retry/poll knobs
          paymentConfigProvider.overrideWithValue(
            PaymentConfig(
              appScheme: 'aurain',
              brandName: 'NanoEmbryo',
              defaultCurrency: 'GHS',
              paymentErrorBuilder:
                  (context, info) => PaymentFailureScreen(info: info),
            ),
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
    final reportDate = additionalData?['report_date'] as String?;

    _handleNotificationNavigation(
      type,
      bookingId,
      shopId,
      channelUrl: channelUrl,
      reportDate: reportDate,
    );
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
  String? reportDate,
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

    case 'daily_report':
      if (shopId != null &&
          shopId.isNotEmpty &&
          reportDate != null &&
          reportDate.isNotEmpty) {
        router.push(
          RouteNames.dailyReportScreen,
          extra: {'shopId': shopId, 'reportDate': reportDate},
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

/// Strip query parameters and sensitive path segments from a URI before logging.
/// Auth callback URLs carry single-use OAuth codes, recovery token hashes, and
/// access tokens as query params — never log them, even in debug builds, since
/// they end up in crash-reporting pipelines once added.
String _redactUri(Uri uri) {
  final base = '${uri.scheme}://${uri.host}${uri.path}';
  return uri.hasQuery ? '$base?[redacted]' : base;
}

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
    debugPrint('Error getting initial deep link: ${e.runtimeType}');
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
///
/// Supabase now sends password-reset links with ?token_hash=XXX&type=recovery
/// (email OTP format). Older PKCE (?code=) and implicit (#access_token=) forms
/// are also supported as fallbacks.
///
/// On cold start this runs before runApp(), so the router is created with
/// isRecoveryMode already true and redirects immediately to UpdatePasswordScreen.
Future<void> _handleOAuthCallback(
  Uri uri,
  RoutingNotifier routingNotifier,
) async {
  final params = uri.queryParameters;
  final isRecoveryUrl = params['type'] == 'recovery';
  final tokenHash = params['token_hash'];

  if (isRecoveryUrl) routingNotifier.setRecoveryMode(true);

  // Subscribe BEFORE exchanging credentials so we never miss the event.
  // Supabase fires signedIn first then passwordRecovery — keep the sub alive
  // until passwordRecovery is confirmed.
  //
  // Safety net: a non-recovery OAuth flow (Google/Apple sign-in via this
  // callback) will never fire passwordRecovery, so without an explicit
  // timer the subscription would leak forever.
  late final StreamSubscription<AuthState> sub;
  late final Timer safetyCancel;
  void cancelAll() {
    sub.cancel();
    safetyCancel.cancel();
  }

  sub = Supabase.instance.client.auth.onAuthStateChange.listen((state) {
    if (state.event == AuthChangeEvent.passwordRecovery) {
      routingNotifier.setRecoveryMode(true);
      cancelAll();
    }
  });
  safetyCancel = Timer(const Duration(seconds: 15), cancelAll);

  try {
    if (tokenHash != null && isRecoveryUrl) {
      // Supabase email OTP format: ?token_hash=XXX&type=recovery
      // getSessionFromUrl only handles ?code= (PKCE) and #access_token=
      // (implicit) — it would throw "No code detected" for token_hash URLs.
      await Supabase.instance.client.auth
          .verifyOTP(tokenHash: tokenHash, type: OtpType.recovery)
          .timeout(const Duration(seconds: 30));
      debugPrint('✅ Recovery OTP verified from deep link');
    } else {
      // PKCE (?code=) or implicit (#access_token=) — standard exchange.
      await Supabase.instance.client.auth
          .getSessionFromUrl(uri)
          .timeout(const Duration(seconds: 30));
      debugPrint('✅ OAuth session established from deep link');
    }
  } catch (e) {
    // Log only the exception type — the message may include the full URL with tokens.
    debugPrint(
      '❌ Failed to establish OAuth session from deep link: ${e.runtimeType}',
    );
    cancelAll();
    if (isRecoveryUrl) routingNotifier.setRecoveryMode(false);
  }
}

/// Handle incoming deep links while app is running
void _handleIncomingDeepLink(Uri uri, RoutingNotifier routingNotifier) {
  debugPrint('🔗 Deep link received: ${_redactUri(uri)}');
  _processDeepLink(uri.toString(), routingNotifier);
}

/// Process a deep link and store it in RoutingNotifier
void _processDeepLink(String link, RoutingNotifier routingNotifier) {
  final uri = Uri.parse(link);
  String? slug;
  String? linkType;

  debugPrint('🔍 Parsing link: ${_redactUri(uri)}');

  if (uri.scheme == 'aurain') {
    // Custom scheme: host is the link type (shop/worker/booking)
    // Path segments contain the slug
    linkType = uri.host; // 'shop', 'worker', 'booking'
    slug = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;

    if (slug != null) {
      debugPrint('📱 Extracted type: $linkType from custom scheme');
    }
  } else if (uri.scheme == 'https' &&
      (uri.host == 'aurain.barsopus.com' || uri.host.contains('localhost'))) {
    // HTTPS universal/web links: path segments contain ['l', 'slug']
    final segments = uri.pathSegments;
    if (segments.isNotEmpty && segments[0] == 'l' && segments.length >= 2) {
      slug = segments[1];
      debugPrint('🌐 Extracted slug from web URL');
    }
  }

  // Universal Links from aurain.barsopus.com/book/<slug>
  // (and the legacy /l/<slug> alias). When the app is already running and the
  // OS hands a Universal Link to app_links.uriLinkStream, navigate directly via
  // the GoRouter so the deep-link resolver screen fires. This bypasses the
  // setPendingDeepLink plumbing (which has no consumer) entirely.
  final productionDomain = AuraInLinkConfig.production.baseDomain;
  final isProductionHost = uri.host == productionDomain;
  final isBookPath =
      uri.pathSegments.length >= 2 &&
      (uri.pathSegments[0] == 'book' || uri.pathSegments[0] == 'l');
  if (uri.scheme == 'https' && isProductionHost && isBookPath) {
    final webSlug = uri.pathSegments[1];
    if (webSlug.isNotEmpty) {
      debugPrint('[deep-link] aura-in-web booking link: $webSlug');
      // Warm-start path: router exists, go directly.
      if (_appRouter != null) {
        _appRouter!.go('/book/$webSlug');
        return;
      }
      // Cold-start fallback: stash in routing notifier (consumer is vestigial
      // today but keeps behavioural parity with the other deep link schemes).
      routingNotifier.setPendingDeepLink(webSlug);
      debugPrint('📌 Deep link stored (cold start), waiting for router');
      return;
    }
  }

  if (slug != null && slug.isNotEmpty) {
    routingNotifier.setPendingDeepLink(slug);
    debugPrint('📌 Deep link stored, waiting for auth');
  } else {
    debugPrint('⚠️ Could not extract slug from link');
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
