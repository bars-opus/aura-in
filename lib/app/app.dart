import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/feedback/review/app_lifecycle_launch_counter.dart';
import 'package:nano_embryo/core/feedback/review/review_providers.dart';
import 'package:nano_embryo/core/localization/app_language.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/core/providers/locale_provider.dart';
import 'package:nano_embryo/core/providers/profile_providers/profile_provider.dart';
import 'package:nano_embryo/core/providers/routing_providers.dart';
import 'package:nano_embryo/core/providers/shared_prefs_provider.dart';
import 'package:nano_embryo/core/providers/theme_provider.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nano_embryo/core/widgets/app_initialization_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Main Application Widget
///
/// Wraps the entire app with Riverpod providers and
/// configures the MaterialApp with proper localization.

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  bool _isInitializing = true;
  AppLanguage? _initialLanguage;

  @override
  void initState() {
    super.initState();
    _initializeApp();

    // ✅ REMOVE the router creation from here
    // ❌ Don't create _router in initState

    ref.listenManual(authStateProvider, (previous, next) {
      final prevUser = previous?.value;
      final newUser = next.value;

      if (prevUser == null && newUser != null) {
        _handleNewUser(newUser);
      }
    });

    // When a password-reset deep link is opened while the app is running,
    // set recovery mode — the router redirect handles navigation to UpdatePasswordScreen.
    ref.listenManual(authEventProvider, (_, next) {
      if (next.valueOrNull?.event == AuthChangeEvent.passwordRecovery) {
        ref.read(routingNotifierProvider).setRecoveryMode(true);
      }
    });
  }

  Future<void> _handleNewUser(User user) async {
    // Best-effort warm-up: create the profile row so the user lands on the
    // username screen with a row already present. createProfile is an
    // idempotent UPSERT so racing with UsernameCreationScreen is safe.
    //
    // Failure here is non-fatal — UsernameCreationScreen retries the same
    // call and surfaces a friendly error to the user if it persists.
    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      await profileRepo.createProfile(user.id);
    } catch (e) {
      debugPrint('⚠️ _handleNewUser: profile warm-up failed (${e.runtimeType}) — UsernameCreationScreen will retry');
    }
  }

  Future<void> _initializeApp() async {
    try {
      final notifier = ref.read(localeNotifierProvider.notifier);
      await notifier.initialize();
      _initialLanguage = ref.read(localeNotifierProvider);
    } catch (e) {
      _initialLanguage = defaultLanguage;
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
        // Cold-start: recovery mode may have been set in main() before runApp.
        // Check after the first real frame so the navigator key is valid.
        // Cold-start recovery mode is already set — the router redirect
        // will navigate to UpdatePasswordScreen on the next frame.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Get router and notifier from providers (created in main)
    final router = ref.watch(appRouterProvider);
    final routingNotifier = ref.watch(routingNotifierProvider);

    // Keep routingNotifier in sync with auth/profile/first-launch state.
    ref.listen(authStateProvider, (_, next) {
      final user = next.valueOrNull;
      if (user != null) {
        routingNotifier.setUser(user);
      } else {
        routingNotifier.clearUser();
      }
    });
    ref.listen(currentUserProfileProvider, (_, next) {
      routingNotifier.update(profile: next.valueOrNull);
    });
    ref.listen(isFirstLaunchProvider, (_, next) {
      routingNotifier.update(isFirstLaunch: next);
    });

    // Track current location — attached once; GoRouter is stable.
    router.routeInformationProvider.addListener(() {
      final location = router.routeInformationProvider.value.uri.toString();
      routingNotifier.updateLocation(location);
    });

    if (_isInitializing) {
      return MaterialApp(
        home:AppInitializationWidget()
      );
    }

    final themeMode = ref.watch(themeModeProvider);
    final currentLanguage = ref.watch(localeNotifierProvider);
    final currentLocale = currentLanguage.locale;

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp.router(
        locale: currentLocale,
        routerConfig: router, // ✅ Use the provider router, not _router
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
          Locale('fr'),
          Locale('de'),
          Locale('it'),
          Locale('pt'),
        ],
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          return currentLocale;
        },
        builder: (context, child) {
          return AppLifecycleLaunchCounter(
            storeProvider: reviewStatsStoreProvider,
            child: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: child,
            ),
          );
        },
      ),
    );
  }
}
