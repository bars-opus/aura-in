import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:nano_embryo/app/routing/app_router.dart';
import 'package:nano_embryo/core/account_lifecycle/config/account_lifecycle_texts.dart';
import 'package:nano_embryo/core/account_lifecycle/config/feature/account_lifecycle_config.dart';
import 'package:nano_embryo/core/providers/profile_providers/profile_provider.dart';
import 'package:nano_embryo/core/providers/routing_providers.dart';
import 'package:nano_embryo/core/providers/shared_prefs_provider.dart';
import 'package:nano_embryo/core/widgets/feedback/export_extensions.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// NanoEmbryo-specific account lifecycle configuration.
///
/// When copying this engine to a new app, replace this file with your own
/// routes, localization bridge, profile refresh callback, and sign-out cleanup.
/// Everything else in `core/account_lifecycle/` is designed to be reusable.
AccountLifecycleConfig buildNanoEmbryoAccountLifecycleConfig() {
  return AccountLifecycleConfig(
    appName: 'Aura In',
    restoreRoute: RouteNames.restoreAccount,
    homeRoute: RouteNames.home,
    introRoute: RouteNames.intro,
    supabaseClient: Supabase.instance.client,
    // 30-day grace window — kept in sync with
    // app.account_lifecycle.pending_delete_window GUC.
    pendingDeleteWindow: const Duration(days: 30),
    reasonMaxLength: 1000,
    logger: (
      message, {
      String? correlationId,
      Map<String, Object?>? context,
      Object? error,
      StackTrace? stackTrace,
    }) {
      if (!kDebugMode) return;
      final tag = correlationId == null ? '' : ' [$correlationId]';
      debugPrint('account_lifecycle$tag: $message ${context ?? ''}');
      if (error != null) {
        debugPrint('  error: $error');
        if (stackTrace != null) debugPrint('$stackTrace');
      }
    },
    textsBuilder: (context) {
      return NanoEmbryoAccountLifecycleTexts(AppLocalizations.of(context)!);
    },
    refreshProfile: (ref) {
      ref.invalidate(currentUserProfileProvider);
    },
    signOut: (context, ref) async {
      await ref.read(authOperationsProvider).signOut();
      await ref.read(preferencesServiceProvider).clearUserData();
      ref.read(routingNotifierProvider).clearUser();
      if (context.mounted) context.go(RouteNames.intro);
    },
    showSuccess: (context, message) => context.showSuccessSnackbar(message),
    showError: (context, message) => context.showErrorSnackbar(message),
  );
}

class NanoEmbryoAccountLifecycleTexts extends AccountLifecycleTexts {
  final AppLocalizations loc;

  const NanoEmbryoAccountLifecycleTexts(this.loc);

  @override
  String get deactivateTitle => loc.accountDeactivateTitle;
  @override
  String get deleteTitle => loc.accountDeleteTitle;
  @override
  String get restoreTitle => loc.accountRestoreTitle;
  @override
  String get deactivateWarningTitle => loc.accountDeactivateWarningTitle;
  @override
  String get deactivateWarningBody => loc.accountDeactivateWarningBody;
  @override
  String get deleteWarningTitle => loc.accountDeleteWarningTitle;
  @override
  String get deleteWarningBody => loc.accountDeleteWarningBody;
  @override
  String get passwordConfirmLabel => loc.accountPasswordConfirmLabel;
  @override
  String get passwordConfirmHint => loc.accountPasswordConfirmHint;
  @override
  String phraseConfirmLabel(String phrase) =>
      loc.accountPhraseConfirmLabel(phrase);
  @override
  String phraseMismatch(String phrase) => loc.accountPhraseMismatch(phrase);
  @override
  String get reasonLabel => loc.accountReasonLabel;
  @override
  String get reasonHint => loc.accountReasonHint;
  @override
  String get passwordRequired => loc.authPasswordRequired;
  @override
  String get reasonTooLong => _reasonTooLong;
  @override
  String get deactivateButton => loc.accountDeactivateButton;
  @override
  String get deleteButton => loc.accountDeleteButton;
  @override
  String get restoreButton => loc.accountRestoreButton;
  @override
  String get logoutButton => loc.commonLogout;
  @override
  String get deactivatedSuccess => loc.accountDeactivatedSuccess;
  @override
  String get deletionRequestedSuccess => loc.accountDeletionRequestedSuccess;
  @override
  String get restoredSuccess => loc.accountRestoredSuccess;
  @override
  String get restoreFailed => loc.accountRestoreFailed;
  @override
  String get actionBlocked => loc.accountActionBlocked;
  @override
  String get blockersTitle => loc.accountBlockersTitle;
  @override
  String blockerActiveBookings(int count) =>
      loc.accountBlockerActiveBookings(count);
  @override
  String blockerOwnedShopActiveBookings(int count) =>
      loc.accountBlockerOwnedShopActiveBookings(count);
  @override
  String blockerActiveOrders(int count) =>
      loc.accountBlockerActiveOrders(count);
  @override
  String blockerOwnedShopActiveOrders(int count) =>
      loc.accountBlockerOwnedShopActiveOrders(count);
  @override
  String blockerActiveWithdrawals(int count) =>
      loc.accountBlockerActiveWithdrawals(count);
  @override
  String get somethingWentWrong => loc.commonSomethingWentWrong;
  @override
  String get loadFailed => _loadFailed;
  @override
  String get genericError => _genericError;
  @override
  String get recentAuthRequired => _recentAuthRequired;
  @override
  String get missingProfile => loc.accountRestoreMissingProfile;
  @override
  String get deactivatedTitle => loc.accountDeactivatedTitle;
  @override
  String get deactivatedBody => loc.accountDeactivatedBody;
  @override
  String get pendingDeleteTitle => loc.accountPendingDeleteTitle;
  @override
  String pendingDeleteBody(DateTime? scheduledFor) {
    final dateText = scheduledFor == null ? '' : scheduledFor.toLocal();
    return loc.accountPendingDeleteBody(dateText.toString().split(' ').first);
  }

  @override
  String get deletedTitle => loc.accountDeletedTitle;
  @override
  String get deletedBody => loc.accountDeletedBody;

  String get _loadFailed {
    return switch (loc.localeName) {
      'es' =>
        'No pudimos cargar los requisitos de la cuenta. Inténtalo de nuevo.',
      'fr' => 'Nous n’avons pas pu charger les exigences du compte. Réessayez.',
      'de' =>
        'Die Kontoanforderungen konnten nicht geladen werden. Bitte versuchen Sie es erneut.',
      'it' =>
        'Non siamo riusciti a caricare i requisiti dell\'account. Riprova.',
      'pt' =>
        'Não foi possível carregar os requisitos da conta. Tente novamente.',
      _ => 'We could not load account requirements. Please try again.',
    };
  }

  String get _genericError {
    return switch (loc.localeName) {
      'es' => 'No pudimos completar esta acción de cuenta. Inténtalo de nuevo.',
      'fr' => 'Nous n’avons pas pu terminer cette action de compte. Réessayez.',
      'de' =>
        'Diese Kontoaktion konnte nicht abgeschlossen werden. Bitte versuchen Sie es erneut.',
      'it' =>
        'Non siamo riusciti a completare questa azione dell\'account. Riprova.',
      'pt' => 'Não foi possível concluir esta ação da conta. Tente novamente.',
      _ => 'We could not complete this account action. Please try again.',
    };
  }

  @override
  String get rateLimited => _rateLimited;

  String get _rateLimited {
    return switch (loc.localeName) {
      'es' => 'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.',
      'fr' =>
        'Trop de tentatives. Veuillez attendre quelques minutes et réessayer.',
      'de' =>
        'Zu viele Versuche. Bitte warten Sie einige Minuten und versuchen Sie es erneut.',
      'it' => 'Troppi tentativi. Attendi qualche minuto e riprova.',
      'pt' => 'Muitas tentativas. Aguarde alguns minutos e tente novamente.',
      _ => 'Too many attempts. Please wait a few minutes and try again.',
    };
  }

  String get _recentAuthRequired {
    return switch (loc.localeName) {
      'es' => 'Inicia sesión de nuevo antes de continuar.',
      'fr' => 'Veuillez vous reconnecter avant de continuer.',
      'de' => 'Bitte melden Sie sich erneut an, bevor Sie fortfahren.',
      'it' => 'Accedi di nuovo prima di continuare.',
      'pt' => 'Entre novamente antes de continuar.',
      _ => 'Please sign in again before continuing.',
    };
  }

  String get _reasonTooLong {
    return switch (loc.localeName) {
      'es' => 'El motivo debe tener 1000 caracteres o menos.',
      'fr' => 'La raison doit contenir 1000 caractères ou moins.',
      'de' => 'Der Grund darf höchstens 1000 Zeichen enthalten.',
      'it' => 'Il motivo deve contenere al massimo 1000 caratteri.',
      'pt' => 'O motivo deve ter 1000 caracteres ou menos.',
      _ => 'Reason must be 1000 characters or fewer.',
    };
  }
}
