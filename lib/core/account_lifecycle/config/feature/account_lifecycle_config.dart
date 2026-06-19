import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/account_lifecycle/config/account_lifecycle_texts.dart';
import 'package:nano_embryo/core/account_lifecycle/data/account_lifecycle_models.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef AccountLifecycleTextsBuilder =
    AccountLifecycleTexts Function(BuildContext context);

typedef AccountLifecycleProfileRefresh = void Function(Ref ref);

typedef AccountLifecycleSignOut =
    Future<void> Function(BuildContext context, WidgetRef ref);

typedef AccountLifecycleActionHook =
    Future<void> Function(
      BuildContext context,
      WidgetRef ref,
      AccountLifecycleActionResult result,
    );

typedef AccountLifecycleCorrelationIdGenerator = String Function();

typedef AccountLifecycleLogger =
    void Function(
      String message, {
      String? correlationId,
      Map<String, Object?>? context,
      Object? error,
      StackTrace? stackTrace,
    });

/// Plug-and-play configuration for the account lifecycle engine.
///
/// Drop the `core/account_lifecycle/` folder into any Flutter + Supabase app,
/// then build one of these in your root `ProviderScope` to wire it up.
/// See `ACCOUNT_LIFECYCLE_ENGINE.md` for the full integration guide.
class AccountLifecycleConfig {
  /// Used in default copy and audit context.
  final String appName;

  /// Route inactive users are forced to.
  final String restoreRoute;

  /// Route after a successful restore.
  final String homeRoute;

  /// Route after logout from the restore screen.
  final String introRoute;

  /// App localization bridge. Default returns the built-in English strings.
  final AccountLifecycleTextsBuilder textsBuilder;

  /// Invoked after every successful state change so the app can refresh its
  /// own profile cache (e.g., invalidating `currentUserProfileProvider`).
  final AccountLifecycleProfileRefresh? refreshProfile;

  /// App-specific sign-out (clears prefs, auth, routing state). The engine
  /// falls back to `SupabaseClient.auth.signOut()` if null.
  final AccountLifecycleSignOut? signOut;

  /// Optional post-action hooks for analytics or chained navigation.
  final AccountLifecycleActionHook? onDeactivated;
  final AccountLifecycleActionHook? onDeletionRequested;
  final AccountLifecycleActionHook? onRestored;

  /// Use the app's snackbar/toast system rather than the engine's default.
  final void Function(BuildContext context, String message)? showSuccess;
  final void Function(BuildContext context, String message)? showError;

  /// Explicit client override (useful for tests). Defaults to
  /// `Supabase.instance.client`.
  final SupabaseClient? supabaseClient;

  /// Maximum chars accepted for the optional reason free-text. Matches the
  /// server `app.account_lifecycle.reason_max` GUC (default 1000).
  final int reasonMaxLength;

  /// Recovery window length, only used to format copy on the restore screen.
  /// The server controls the actual deletion date via the
  /// `app.account_lifecycle.pending_delete_window` GUC.
  final Duration pendingDeleteWindow;

  /// Producer for per-action correlation IDs. Propagated to the server and
  /// recorded in `account_lifecycle_audit_log.context.correlation_id`.
  final AccountLifecycleCorrelationIdGenerator correlationIdGenerator;

  /// Sink for engine-level diagnostic logs (entry, exit, errors). Hook your
  /// app's logger (e.g., `logger.i`) to surface them in dev/observability.
  final AccountLifecycleLogger? logger;

  const AccountLifecycleConfig({
    required this.appName,
    this.restoreRoute = '/restoreAccount',
    this.homeRoute = '/',
    this.introRoute = '/',
    this.textsBuilder = _defaultTextsBuilder,
    this.refreshProfile,
    this.signOut,
    this.onDeactivated,
    this.onDeletionRequested,
    this.onRestored,
    this.showSuccess,
    this.showError,
    this.supabaseClient,
    this.reasonMaxLength = 1000,
    this.pendingDeleteWindow = const Duration(days: 30),
    this.correlationIdGenerator = _defaultCorrelationId,
    this.logger,
  });

  factory AccountLifecycleConfig.defaults() {
    return const AccountLifecycleConfig(appName: 'App');
  }

  AccountLifecycleTexts texts(BuildContext context) => textsBuilder(context);

  void success(BuildContext context, String message) {
    if (showSuccess != null) {
      showSuccess!(context, message);
      return;
    }
    context.showSuccessSnackbar(message);
  }

  void error(BuildContext context, String message) {
    if (showError != null) {
      showError!(context, message);
      return;
    }
    context.showErrorSnackbar(message);
  }

  void log(
    String message, {
    String? correlationId,
    Map<String, Object?>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger?.call(
      message,
      correlationId: correlationId,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static AccountLifecycleTexts _defaultTextsBuilder(BuildContext context) {
    return const AccountLifecycleTexts();
  }

  static String _defaultCorrelationId() {
    final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final rand = (ts.hashCode & 0x7fffffff).toRadixString(36);
    return 'alc_${ts}_$rand';
  }
}

final accountLifecycleConfigProvider = Provider<AccountLifecycleConfig>((ref) {
  return AccountLifecycleConfig.defaults();
});

final accountLifecycleSupabaseClientProvider = Provider<SupabaseClient>((ref) {
  final configured = ref.watch(accountLifecycleConfigProvider).supabaseClient;
  return configured ?? Supabase.instance.client;
});
