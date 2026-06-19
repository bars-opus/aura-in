import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/moderation/config/moderation_texts.dart';
import 'package:nano_embryo/core/moderation/data/moderation_models.dart';
import 'package:nano_embryo/core/moderation/data/moderation_repository.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef ModerationTextsBuilder = ModerationTexts Function(BuildContext context);
typedef ModerationRefreshHook = void Function(Ref ref);
typedef ModerationTargetFormatter =
    String Function(BuildContext context, ModerationTarget target);

/// The single configuration object for the moderation engine.
///
/// Drop this into any Flutter + Supabase app. Override
/// [moderationConfigProvider] in your root [ProviderScope] with an instance
/// customised for your app — see `architecture/MODERATION_ENGINE.md` for the
/// full integration guide.
class ModerationConfig {
  /// Your app's display name (used in log messages).
  final String appName;

  /// Route name pushed when a user opens the "Blocked Accounts" screen from
  /// settings. The engine itself does not push these routes — your app does —
  /// but the engine exposes them so you can wire navigation uniformly.
  final String blockedAccountsRoute;
  final String blockAccountRoute;
  final String reportTargetRoute;

  /// Builds the text bundle used by every engine screen. Default returns the
  /// English fallback bundle.
  final ModerationTextsBuilder textsBuilder;

  /// Optional hooks invoked after a successful moderation mutation so the host
  /// app can refresh its own profile / search / map state.
  final ModerationRefreshHook? refreshProfile;
  final ModerationRefreshHook? refreshSearch;

  /// Optional feedback callbacks. If omitted the engine falls back to
  /// [ScaffoldMessenger] snack bars.
  final void Function(BuildContext context, String message)? showSuccess;
  final void Function(BuildContext context, String message)? showError;

  /// Optional override for the Supabase client (defaults to
  /// `Supabase.instance.client`). Tests pass a mock here.
  final SupabaseClient? supabaseClient;

  /// Per-request timeout applied to every RPC call (default 15s).
  final Duration rpcTimeout;

  /// Optional observability hook. Fired for every RPC with elapsed time and
  /// either `success: true` or the stable error code.
  final ModerationLogger? logger;

  /// Maximum lengths enforced on the client. Must match the SQL CHECK
  /// constraints in the migration.
  final int maxReportDetailsLength;
  final int maxBlockReasonLength;

  /// Optional override that turns a [ModerationTarget] into the display name
  /// shown in screen copy. Defaults to [ModerationTarget.displayName].
  final ModerationTargetFormatter? targetFormatter;

  const ModerationConfig({
    required this.appName,
    this.blockedAccountsRoute = '/blocked',
    this.blockAccountRoute = '/blockAccount',
    this.reportTargetRoute = '/reportTarget',
    this.textsBuilder = _defaultTextsBuilder,
    this.refreshProfile,
    this.refreshSearch,
    this.showSuccess,
    this.showError,
    this.supabaseClient,
    this.rpcTimeout = const Duration(seconds: 15),
    this.logger,
    this.maxReportDetailsLength = 1000,
    this.maxBlockReasonLength = 300,
    this.targetFormatter,
  });

  factory ModerationConfig.defaults() {
    return const ModerationConfig(appName: 'App');
  }

  ModerationTexts texts(BuildContext context) => textsBuilder(context);

  String formatTarget(BuildContext context, ModerationTarget target) {
    return targetFormatter?.call(context, target) ?? target.displayName;
  }

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

  static ModerationTexts _defaultTextsBuilder(BuildContext context) {
    return const ModerationTexts();
  }
}

/// Override this in your root [ProviderScope] with your app's
/// [ModerationConfig].
final moderationConfigProvider = Provider<ModerationConfig>((ref) {
  return ModerationConfig.defaults();
});

final moderationSupabaseClientProvider = Provider<SupabaseClient>((ref) {
  final configured = ref.watch(moderationConfigProvider).supabaseClient;
  return configured ?? Supabase.instance.client;
});
