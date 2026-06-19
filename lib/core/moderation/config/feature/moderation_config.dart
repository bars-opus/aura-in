import 'package:nano_embryo/app/routing/app_router.dart';
import 'package:nano_embryo/core/moderation/config/moderation_config.dart';
import 'package:nano_embryo/core/moderation/config/moderation_texts.dart';
import 'package:nano_embryo/core/moderation/data/moderation_models.dart';
import 'package:nano_embryo/core/providers/profile_providers/profile_provider.dart';
import 'package:nano_embryo/core/widgets/feedback/export_extensions.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

ModerationConfig buildNanoEmbryoModerationConfig() {
  return ModerationConfig(
    appName: 'Aura In',
    blockedAccountsRoute: RouteNames.blockedAccounts,
    blockAccountRoute: RouteNames.blockAccount,
    reportTargetRoute: RouteNames.reportTarget,
    supabaseClient: Supabase.instance.client,
    textsBuilder: (context) {
      return NanoEmbryoModerationTexts(AppLocalizations.of(context)!);
    },
    refreshProfile: (ref) {
      ref.invalidate(currentUserProfileProvider);
    },
    showSuccess: (context, message) => context.showSuccessSnackbar(message),
    showError: (context, message) => context.showErrorSnackbar(message),
  );
}

class NanoEmbryoModerationTexts extends ModerationTexts {
  final AppLocalizations loc;

  const NanoEmbryoModerationTexts(this.loc);

  @override
  String get blockActionLabel => loc.actionsBlock;

  @override
  String get reportActionLabel => loc.actionsReport;

  @override
  String get blockedAccountsTitle => loc.blockedItemTitle;

  @override
  String get blockedAccountsSubtitle => loc.blockedItemSubtitle;

  @override
  String get blockedAccountsEmptyTitle => _byLocale(
    en: 'No blocked accounts',
    es: 'No hay cuentas bloqueadas',
    fr: 'Aucun compte bloqué',
    de: 'Keine blockierten Konten',
    it: 'Nessun account bloccato',
    pt: 'Nenhuma conta bloqueada',
  );

  @override
  String get blockedAccountsEmptyBody => _byLocale(
    en: 'People you block will appear here.',
    es: 'Las personas que bloquees aparecerán aquí.',
    fr: 'Les personnes que vous bloquez apparaîtront ici.',
    de: 'Personen, die Sie blockieren, werden hier angezeigt.',
    it: 'Le persone che blocchi appariranno qui.',
    pt: 'As pessoas que você bloquear aparecerão aqui.',
  );

  @override
  String get blockScreenTitle => _byLocale(
    en: 'Block account',
    es: 'Bloquear cuenta',
    fr: 'Bloquer le compte',
    de: 'Konto blockieren',
    it: 'Blocca account',
    pt: 'Bloquear conta',
  );

  @override
  String blockScreenBody(String displayName) => _withName(
    en:
        'You will no longer see or contact {name}, and they will not be able to interact with you.',
    es:
        'Ya no verás ni podrás contactar a {name}, y esa persona tampoco podrá interactuar contigo.',
    fr:
        'Vous ne verrez plus {name} et ne pourrez plus le contacter, et cette personne ne pourra plus interagir avec vous.',
    de:
        'Sie werden {name} nicht mehr sehen oder kontaktieren, und diese Person kann nicht mehr mit Ihnen interagieren.',
    it:
        'Non vedrai più né potrai contattare {name}, e questa persona non potrà più interagire con te.',
    pt:
        'Você não verá nem poderá contatar {name}, e essa pessoa também não poderá interagir com você.',
    displayName: displayName,
  );

  @override
  String get reportScreenTitle => _byLocale(
    en: 'Report',
    es: 'Reportar',
    fr: 'Signaler',
    de: 'Melden',
    it: 'Segnala',
    pt: 'Denunciar',
  );

  @override
  String reportScreenBody(String displayName) => _withName(
    en: 'Tell us why you are reporting {name}.',
    es: 'Cuéntanos por qué estás reportando a {name}.',
    fr: 'Expliquez-nous pourquoi vous signalez {name}.',
    de: 'Sagen Sie uns, warum Sie {name} melden.',
    it: 'Dicci perché stai segnalando {name}.',
    pt: 'Conte por que você está denunciando {name}.',
    displayName: displayName,
  );

  @override
  String get blockReasonLabel => _byLocale(
    en: 'Reason (optional)',
    es: 'Motivo (opcional)',
    fr: 'Raison (facultatif)',
    de: 'Grund (optional)',
    it: 'Motivo (facoltativo)',
    pt: 'Motivo (opcional)',
  );

  @override
  String get blockReasonHint => _byLocale(
    en: 'Why are you blocking this account?',
    es: '¿Por qué estás bloqueando esta cuenta?',
    fr: 'Pourquoi bloquez-vous ce compte ?',
    de: 'Warum blockieren Sie dieses Konto?',
    it: 'Perché stai bloccando questo account?',
    pt: 'Por que você está bloqueando esta conta?',
  );

  @override
  String get reportDetailsLabel => _byLocale(
    en: 'Details (optional)',
    es: 'Detalles (opcional)',
    fr: 'Détails (facultatif)',
    de: 'Details (optional)',
    it: 'Dettagli (facoltativo)',
    pt: 'Detalhes (opcional)',
  );

  @override
  String get reportDetailsHint => _byLocale(
    en: 'Add context that will help review this report',
    es: 'Agrega contexto que ayude a revisar este reporte',
    fr: 'Ajoutez du contexte pour aider à examiner ce signalement',
    de: 'Fügen Sie Kontext hinzu, der bei der Prüfung dieses Berichts hilft',
    it: 'Aggiungi contesto utile per esaminare questa segnalazione',
    pt: 'Adicione contexto para ajudar na análise desta denúncia',
  );

  @override
  String get reportReasonLabel => _byLocale(
    en: 'Reason',
    es: 'Motivo',
    fr: 'Raison',
    de: 'Grund',
    it: 'Motivo',
    pt: 'Motivo',
  );

  @override
  String get blockButton => _byLocale(
    en: 'Block account',
    es: 'Bloquear cuenta',
    fr: 'Bloquer le compte',
    de: 'Konto blockieren',
    it: 'Blocca account',
    pt: 'Bloquear conta',
  );

  @override
  String get unblockButton => _byLocale(
    en: 'Unblock',
    es: 'Desbloquear',
    fr: 'Débloquer',
    de: 'Entsperren',
    it: 'Sblocca',
    pt: 'Desbloquear',
  );

  @override
  String get reportButton => _byLocale(
    en: 'Submit report',
    es: 'Enviar reporte',
    fr: 'Envoyer le signalement',
    de: 'Meldung senden',
    it: 'Invia segnalazione',
    pt: 'Enviar denúncia',
  );

  @override
  String get reasonRequired => _byLocale(
    en: 'Select a reason before continuing.',
    es: 'Selecciona un motivo antes de continuar.',
    fr: 'Sélectionnez une raison avant de continuer.',
    de: 'Wählen Sie einen Grund aus, bevor Sie fortfahren.',
    it: 'Seleziona un motivo prima di continuare.',
    pt: 'Selecione um motivo antes de continuar.',
  );

  @override
  String get detailsTooLong => _byLocale(
    en: 'Details must be 1000 characters or fewer.',
    es: 'Los detalles deben tener 1000 caracteres o menos.',
    fr: 'Les détails doivent contenir 1000 caractères ou moins.',
    de: 'Details dürfen höchstens 1000 Zeichen enthalten.',
    it: 'I dettagli devono contenere al massimo 1000 caratteri.',
    pt: 'Os detalhes devem ter 1000 caracteres ou menos.',
  );

  @override
  String get blockReasonTooLong => _byLocale(
    en: 'Reason must be 300 characters or fewer.',
    es: 'El motivo debe tener 300 caracteres o menos.',
    fr: 'La raison doit contenir 300 caractères ou moins.',
    de: 'Der Grund darf höchstens 300 Zeichen enthalten.',
    it: 'Il motivo deve contenere al massimo 300 caratteri.',
    pt: 'O motivo deve ter 300 caracteres ou menos.',
  );

  @override
  String get blockSuccess => _byLocale(
    en: 'Account blocked.',
    es: 'Cuenta bloqueada.',
    fr: 'Compte bloqué.',
    de: 'Konto blockiert.',
    it: 'Account bloccato.',
    pt: 'Conta bloqueada.',
  );

  @override
  String get unblockSuccess => _byLocale(
    en: 'Account unblocked.',
    es: 'Cuenta desbloqueada.',
    fr: 'Compte débloqué.',
    de: 'Konto entsperrt.',
    it: 'Account sbloccato.',
    pt: 'Conta desbloqueada.',
  );

  @override
  String get reportSuccess => _byLocale(
    en: 'Report submitted.',
    es: 'Reporte enviado.',
    fr: 'Signalement envoyé.',
    de: 'Meldung gesendet.',
    it: 'Segnalazione inviata.',
    pt: 'Denúncia enviada.',
  );

  @override
  String get actionFailed => _byLocale(
    en: 'We could not complete this moderation action.',
    es: 'No pudimos completar esta acción de moderación.',
    fr: 'Nous n’avons pas pu terminer cette action de modération.',
    de: 'Diese Moderationsaktion konnte nicht abgeschlossen werden.',
    it: 'Non siamo riusciti a completare questa azione di moderazione.',
    pt: 'Não foi possível concluir esta ação de moderação.',
  );

  @override
  String get loadFailed => _byLocale(
    en: 'We could not load moderation data.',
    es: 'No pudimos cargar los datos de moderación.',
    fr: 'Nous n’avons pas pu charger les données de modération.',
    de: 'Moderationsdaten konnten nicht geladen werden.',
    it: 'Non siamo riusciti a caricare i dati di moderazione.',
    pt: 'Não foi possível carregar os dados de moderação.',
  );

  @override
  String get blockedUnavailableTitle => _byLocale(
    en: 'This account is unavailable',
    es: 'Esta cuenta no está disponible',
    fr: 'Ce compte est indisponible',
    de: 'Dieses Konto ist nicht verfügbar',
    it: 'Questo account non è disponibile',
    pt: 'Esta conta não está disponível',
  );

  @override
  String get blockedUnavailableBody => _byLocale(
    en:
        'This profile or listing is not available because one of you has blocked the other.',
    es:
        'Este perfil o anuncio no está disponible porque una de las dos personas bloqueó a la otra.',
    fr:
        'Ce profil ou cette annonce n’est pas disponible parce que l’un de vous a bloqué l’autre.',
    de:
        'Dieses Profil oder Angebot ist nicht verfügbar, weil einer von Ihnen den anderen blockiert hat.',
    it:
        'Questo profilo o annuncio non è disponibile perché una delle due persone ha bloccato l’altra.',
    pt:
        'Este perfil ou anúncio não está disponível porque uma das pessoas bloqueou a outra.',
  );

  @override
  String get somethingWentWrong => loc.commonSomethingWentWrong;

  @override
  String get selfBlockNotAllowed => _byLocale(
    en: 'You cannot block your own account.',
    es: 'No puedes bloquear tu propia cuenta.',
    fr: 'Vous ne pouvez pas bloquer votre propre compte.',
    de: 'Sie können Ihr eigenes Konto nicht blockieren.',
    it: 'Non puoi bloccare il tuo stesso account.',
    pt: 'Você não pode bloquear a própria conta.',
  );

  @override
  String get selfReportNotAllowed => _byLocale(
    en: 'You cannot report your own account.',
    es: 'No puedes reportar tu propia cuenta.',
    fr: 'Vous ne pouvez pas signaler votre propre compte.',
    de: 'Sie können Ihr eigenes Konto nicht melden.',
    it: 'Non puoi segnalare il tuo stesso account.',
    pt: 'Você não pode denunciar a própria conta.',
  );

  @override
  String get targetNotFound => _byLocale(
    en: 'This profile or listing is no longer available.',
    es: 'Este perfil o anuncio ya no está disponible.',
    fr: 'Ce profil ou cette annonce n’est plus disponible.',
    de: 'Dieses Profil oder Angebot ist nicht mehr verfügbar.',
    it: 'Questo profilo o annuncio non è più disponibile.',
    pt: 'Este perfil ou anúncio não está mais disponível.',
  );

  @override
  String get invalidInput => _byLocale(
    en: 'Please check the information you entered.',
    es: 'Revisa la información que ingresaste.',
    fr: 'Veuillez vérifier les informations saisies.',
    de: 'Bitte überprüfen Sie Ihre Eingaben.',
    it: 'Controlla le informazioni inserite.',
    pt: 'Verifique as informações inseridas.',
  );

  @override
  String get authRequired => _byLocale(
    en: 'Please sign in to continue.',
    es: 'Inicia sesión para continuar.',
    fr: 'Veuillez vous connecter pour continuer.',
    de: 'Bitte melden Sie sich an, um fortzufahren.',
    it: 'Accedi per continuare.',
    pt: 'Entre para continuar.',
  );

  @override
  String get rateLimitedHour => _byLocale(
    en: 'You have submitted too many reports recently. Please try again later.',
    es: 'Has enviado demasiados reportes recientemente. Inténtalo más tarde.',
    fr: 'Vous avez envoyé trop de signalements récemment. Réessayez plus tard.',
    de: 'Sie haben kürzlich zu viele Meldungen gesendet. Bitte später erneut versuchen.',
    it: 'Hai inviato troppe segnalazioni di recente. Riprova più tardi.',
    pt: 'Você enviou denúncias demais recentemente. Tente novamente mais tarde.',
  );

  @override
  String get rateLimitedTarget => _byLocale(
    en: 'You have already reported this account multiple times today.',
    es: 'Ya has reportado esta cuenta varias veces hoy.',
    fr: 'Vous avez déjà signalé ce compte plusieurs fois aujourd’hui.',
    de: 'Sie haben dieses Konto heute bereits mehrfach gemeldet.',
    it: 'Hai già segnalato questo account più volte oggi.',
    pt: 'Você já denunciou esta conta várias vezes hoje.',
  );

  @override
  String get timeout => _byLocale(
    en: 'The request took too long. Please try again.',
    es: 'La solicitud tardó demasiado. Inténtalo de nuevo.',
    fr: 'La requête a pris trop de temps. Veuillez réessayer.',
    de: 'Die Anfrage hat zu lange gedauert. Bitte erneut versuchen.',
    it: 'La richiesta ha impiegato troppo tempo. Riprova.',
    pt: 'A solicitação demorou demais. Tente novamente.',
  );

  @override
  String get retryLabel => _byLocale(
    en: 'Try again',
    es: 'Reintentar',
    fr: 'Réessayer',
    de: 'Erneut versuchen',
    it: 'Riprova',
    pt: 'Tentar novamente',
  );

  @override
  List<ModerationReasonOption> reasonOptions() {
    return [
      ModerationReasonOption(
        key: 'spam',
        label: _byLocale(
          en: 'Spam',
          es: 'Spam',
          fr: 'Spam',
          de: 'Spam',
          it: 'Spam',
          pt: 'Spam',
        ),
      ),
      ModerationReasonOption(
        key: 'harassment',
        label: _byLocale(
          en: 'Harassment',
          es: 'Acoso',
          fr: 'Harcèlement',
          de: 'Belästigung',
          it: 'Molestie',
          pt: 'Assédio',
        ),
      ),
      ModerationReasonOption(
        key: 'impersonation',
        label: _byLocale(
          en: 'Impersonation',
          es: 'Suplantación',
          fr: 'Usurpation d’identité',
          de: 'Identitätsdiebstahl',
          it: 'Impersonificazione',
          pt: 'Imitação',
        ),
      ),
      ModerationReasonOption(
        key: 'inappropriate_content',
        label: _byLocale(
          en: 'Inappropriate content',
          es: 'Contenido inapropiado',
          fr: 'Contenu inapproprié',
          de: 'Unangemessene Inhalte',
          it: 'Contenuto inappropriato',
          pt: 'Conteúdo inadequado',
        ),
      ),
      ModerationReasonOption(
        key: 'scam_fraud',
        label: _byLocale(
          en: 'Scam or fraud',
          es: 'Estafa o fraude',
          fr: 'Arnaque ou fraude',
          de: 'Betrug',
          it: 'Truffa o frode',
          pt: 'Golpe ou fraude',
        ),
      ),
      ModerationReasonOption(
        key: 'safety_concern',
        label: _byLocale(
          en: 'Safety concern',
          es: 'Problema de seguridad',
          fr: 'Problème de sécurité',
          de: 'Sicherheitsbedenken',
          it: 'Problema di sicurezza',
          pt: 'Preocupação de segurança',
        ),
      ),
      ModerationReasonOption(
        key: 'other',
        label: _byLocale(
          en: 'Other',
          es: 'Otro',
          fr: 'Autre',
          de: 'Andere',
          it: 'Altro',
          pt: 'Outro',
        ),
      ),
    ];
  }

  String _byLocale({
    required String en,
    required String es,
    required String fr,
    required String de,
    required String it,
    required String pt,
  }) {
    return switch (loc.localeName) {
      'es' => es,
      'fr' => fr,
      'de' => de,
      'it' => it,
      'pt' => pt,
      _ => en,
    };
  }

  String _withName({
    required String en,
    required String es,
    required String fr,
    required String de,
    required String it,
    required String pt,
    required String displayName,
  }) {
    return _byLocale(
      en: en,
      es: es,
      fr: fr,
      de: de,
      it: it,
      pt: pt,
    ).replaceAll('{name}', displayName);
  }
}
