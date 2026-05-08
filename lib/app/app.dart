import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/localization/app_language.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/core/providers/locale_provider.dart';
import 'package:nano_embryo/core/providers/profile_providers/profile_provider.dart';
import 'package:nano_embryo/core/providers/routing_providers.dart';
import 'package:nano_embryo/core/providers/shared_prefs_provider.dart';
import 'package:nano_embryo/core/providers/theme_provider.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';
import 'package:nano_embryo/core/widgets/app_initialization_widget.dart';
import 'package:nano_embryo/presentation/features/auth/log_in/presentation/screens/update_password_screen.dart';
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
  bool _updatePasswordSheetShown = false;

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
    // show the UpdatePasswordScreen as a bottom sheet.
    ref.listenManual(authEventProvider, (_, next) {
      if (next.valueOrNull?.event == AuthChangeEvent.passwordRecovery) {
        ref.read(routingNotifierProvider).setRecoveryMode(true);
        _showUpdatePasswordSheet();
      }
    });
  }

  void _showUpdatePasswordSheet() {
    if (_updatePasswordSheetShown) return;
    _updatePasswordSheetShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final navKey =
          ref.read(appRouterProvider).routerDelegate.navigatorKey;
      final navContext = navKey.currentContext;
      if (navContext == null || !navContext.mounted) return;
      BottomSheetUtils.showDocumentationBottomSheet(
        context: navContext,
        widget: const UpdatePasswordScreen(),
      ).then((_) => _updatePasswordSheetShown = false);
    });
  }

  Future<void> _handleNewUser(User user) async {
    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final existing = await profileRepo.fetchProfile(user.id);

      if (existing == null) {
        await profileRepo.createProfile(user.id);
      }
    } catch (e) {
      debugPrint('Error creating profile: $e');
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && ref.read(routingNotifierProvider).isRecoveryMode) {
            _showUpdatePasswordSheet();
          }
        });
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
      routingNotifier.update(user: next.valueOrNull);
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
          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: child,
          );
        },
      ),
    );
  }
}
