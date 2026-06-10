// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Nano Embryo';

  @override
  String get appDescription => 'La tua app innovativa';

  @override
  String get commonContinue => 'Continua';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonSave => 'Salva';

  @override
  String get commonLogin => 'Accedi';

  @override
  String get commonLogout => 'Esci';

  @override
  String get commonDone => 'Fatto';

  @override
  String get commonRetry => 'Riprova';

  @override
  String get commonAccept => 'Accetta';

  @override
  String get commonReject => 'Rifiuta';

  @override
  String get introGetStarted => 'Inizia';

  @override
  String get actionsBlock => 'Blocca utente';

  @override
  String get actionsReport => 'Segnala utente';

  @override
  String get actionsSend => 'Invia alla chat';

  @override
  String get actionsShare => 'Condividi';

  @override
  String get actionsCopy => 'Copia link';

  @override
  String get appInfoVersion => 'Versione';

  @override
  String get appInfoReleased => 'Pubblicato';

  @override
  String get appInfoPackageName => 'Nome del Pacchetto';

  @override
  String get appInfoDeveloper => 'Nome dello Sviluppatore';

  @override
  String get appInfoSupportEmail => 'Email di Supporto';

  @override
  String get appInfoTechnicalDetails => 'Dettagli Tecnici';

  @override
  String get appInfoBundleID => 'ID del Pacchetto';

  @override
  String get appInfoBuildVersion => 'Versione di Compilazione';

  @override
  String get appInfoBuildNumber => 'Numero di Compilazione';

  @override
  String get appInfoReleaseDate => 'Data di Rilascio';

  @override
  String get appInfoAppSize => 'Dimensione dell\'App';

  @override
  String appInfoOverview(String appName) {
    return '$appName è un\'applicazione mobile moderna costruita con sicurezza robusta e funzionalità, progettata per fornire un\'esperienza utente eccezionale con un\'architettura pulita e ottimizzazione delle prestazioni.';
  }

  @override
  String introTitle(String appName) {
    return 'Benvenuto su $appName';
  }

  @override
  String get introFeature1Title => 'Vedi il Tuo Progresso';

  @override
  String get introFeature1Description => 'Traccia le tue pietre miliari di sviluppo con analisi dettagliate e approfondimenti';

  @override
  String get introFeature2Title => 'Esplora i Modelli';

  @override
  String get introFeature2Description => 'Scopri componenti e schermate pre-costruiti per uno sviluppo rapido';

  @override
  String get introFeature3Title => 'Inizia Rapidamente';

  @override
  String get introFeature3Description => 'Avvia il tuo progetto con configurazione zero e best practice';

  @override
  String get appleSignIn => 'Accedi con Apple';

  @override
  String get googleSignIn => 'Accedi con Google';

  @override
  String get appleRegister => 'Registrati con Apple';

  @override
  String get googleRegister => 'Registrati con Google';

  @override
  String get emailAndPassword => 'Inserisci email e password';

  @override
  String get signInTitle => 'Accedi';

  @override
  String get createAccount => 'Crea account';

  @override
  String get legalConsentPart1 => 'Si prega di leggere i ';

  @override
  String get legalConsentPart2 => 'termini e condizioni';

  @override
  String legalConsentPart3(String appName) {
    return ' e altri documenti legali che disciplinano il tuo utilizzo di $appName.';
  }

  @override
  String get emailTitle => 'Email';

  @override
  String get passwordTitle => 'Password';

  @override
  String get loginEmailLabel => 'Indirizzo email';

  @override
  String get loginEmailHint => 'Inserisci la tua email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => 'Inserisci la tua password';

  @override
  String get loginForgotPasswordPart1 => 'Hai dimenticato la tua password? ';

  @override
  String get loginForgotPasswordPart2 => 'Tocca qui';

  @override
  String get loginForgotPasswordPart3 => ' per reimpostare la tua password?';

  @override
  String get commonConfirmPasswordLabel => 'Conferma password';

  @override
  String get commonConfirmPasswordHint => 'Conferma la tua password';

  @override
  String get commonPasswordsDoNotMatch => 'Le password non coincidono';

  @override
  String get commonPasswordConfirmRequired => 'Conferma la tua password';

  @override
  String commonFieldIsValid(String field) {
    return '$field è valido';
  }

  @override
  String get commonPleaseWait => 'Attendi il completamento dell\'operazione corrente';

  @override
  String get commonUnexpectedError => 'Si è verificato un errore imprevisto. Per favore riprova.';

  @override
  String get commonSomethingWentWrong => 'Qualcosa è andato storto. Per favore riprova.';

  @override
  String get commonEnterEmailAndRetry => 'Inserisci il tuo indirizzo email e riprova';

  @override
  String get commonLearnMore => 'Scopri di più';

  @override
  String get authSignUpVerificationSent => 'Email di verifica inviata! Controlla la tua posta in arrivo.';

  @override
  String authSignUpFailed(String error) {
    return 'Registrazione fallita: $error';
  }

  @override
  String get authForgotPasswordTitle => 'Password dimenticata?';

  @override
  String get authForgotPasswordSubtitle => 'Inserisci la tua email e ti invieremo un collegamento per ripristinare la tua password.';

  @override
  String get authSendResetLink => 'Invia link di ripristino';

  @override
  String get authBackToSignIn => 'Torna all\'accesso';

  @override
  String get authUsernameScreenTitle => 'Scegli il tuo nome utente';

  @override
  String get authUsernameScreenSubtitle => 'Così è come ti vedono gli altri. Puoi cambiarlo in seguito.';

  @override
  String get authUsernameLabel => 'Nome utente';

  @override
  String get authUsernameHint => 'Inserisci un nome utente';

  @override
  String authUsernameMinLength(int min) {
    return 'Il nome utente deve contenere almeno $min caratteri';
  }

  @override
  String authUsernameMaxLength(int max) {
    return 'Il nome utente deve contenere al massimo $max caratteri';
  }

  @override
  String get authUsernameFormatError => 'Sono consentiti solo lettere, numeri e trattini bassi';

  @override
  String get authUsernameTaken => 'Questo nome utente è già stato preso';

  @override
  String get authUsernameCheckError => 'Impossibile controllare la disponibilità. Per favore riprova.';

  @override
  String get authUsernameSaveError => 'Impossibile salvare il tuo nome utente. Per favore riprova.';

  @override
  String get authUsernameSavedSuccess => 'Nome utente salvato con successo!';

  @override
  String get authUpdatePasswordTitle => 'Crea una nuova password';

  @override
  String get authUpdatePasswordButton => 'Aggiorna password';

  @override
  String get authUpdatePasswordSuccess => 'Password aggiornata con successo. Per favore accedi di nuovo.';

  @override
  String get authPasswordResetSentTitle => 'Controlla la tua email';

  @override
  String get authPasswordResetSentBody => 'Abbiamo inviato un collegamento di ripristino password a';

  @override
  String get authPasswordResetSentNote => 'Tocca il collegamento nell\'email per impostare una nuova password. Il collegamento scade in 1 ora.';

  @override
  String get authGuestHello => 'Ciao!';

  @override
  String authGuestOverview(String appName) {
    return 'Stai navigando $appName come ospite. Accedi o crea un account per iniziare a gestire il tuo negozio – ci vogliono meno di 5 secondi. Abbiamo una varietà di strumenti per aiutare la crescita della tua attività, il tutto gratuitamente.';
  }

  @override
  String authIntroTitle(String appName) {
    return 'Benvenuto in\n$appName';
  }

  @override
  String get authIntroSubtitle => 'Benvenuto sulla piattaforma che abbiamo creato per te. Divertiti – il meglio ti aspetta.';

  @override
  String get authReadLegalities => 'Leggi le informazioni legali';

  @override
  String get authPasswordRequired => 'Per favore inserisci la tua password';

  @override
  String get authCreatingAccount => 'Creazione dell\'account in corso...';

  @override
  String get authAccountCreatedSuccess => 'Account creato con successo!';

  @override
  String get authCheckEmailToConfirm => 'Controlla la tua email per confermare il tuo account';

  @override
  String get authSigningInWithGoogle => 'Accesso con Google...';

  @override
  String authGoogleSignInFailed(String error) {
    return 'Accesso Google non riuscito: $error';
  }

  @override
  String get authAuthenticatingWithApple => 'Autenticazione con Apple...';

  @override
  String authAppleSignInFailed(String error) {
    return 'Accesso Apple non riuscito: $error';
  }

  @override
  String get authSendingResetEmail => 'Invio dell\'email di ripristino...';

  @override
  String get authResetEmailSent => 'Email di ripristino inviata. Controlla la tua posta in arrivo.';

  @override
  String authPasswordResetFailed(String error) {
    return 'Ripristino password non riuscito: $error';
  }

  @override
  String get authVerifyEmailTitle => 'Controlla la tua email';

  @override
  String get authVerifyEmailSubtitle => 'Abbiamo inviato un collegamento di conferma a';

  @override
  String get authVerifyEmailNote => 'Tocca il collegamento nell\'email per verificare il tuo account e continuare.';

  @override
  String get authConfirmationResent => 'Email di conferma reinviata. Controlla la tua posta in arrivo.';

  @override
  String get authResendFailed => 'Impossibile inviare l\'email. Per favore riprova.';

  @override
  String get authResendEmailButton => 'Reinvia email di conferma';

  @override
  String authResendEmailCooldown(int seconds) {
    return 'Reinvia email (${seconds}s)';
  }

  @override
  String get currencySelectorPlaceholder => 'Seleziona valuta';

  @override
  String get currencySelectorNoSelected => 'Nessuna valuta selezionata';

  @override
  String get currencySelectorTitle => 'Seleziona valuta';

  @override
  String get currencySelectorSearchHint => 'Cerca per valuta, codice o bandiera...';

  @override
  String get currencySelectorNoResults => 'Nessuna valuta trovata';

  @override
  String get discoverScreenTitle => 'Scopri';

  @override
  String get discoverSearchHint => 'Cerca...';

  @override
  String get discoverAllShopsRegion => 'Tutti i negozi nella tua regione';

  @override
  String get discoverAllFreelancers => 'Tutti i freelance vicino a te';

  @override
  String get discoverMarketplaceTitle => 'Mercato';

  @override
  String get discoverMarketplaceSubtitle => 'Acquista prodotti di bellezza con consegna alla ricezione';

  @override
  String get discoverBrowseProducts => 'Sfoglia prodotti';

  @override
  String get discoverMyOrders => 'I miei ordini';

  @override
  String get discoverCartTooltip => 'Carrello';

  @override
  String get homeScheduleTabLabel => 'Calendario';

  @override
  String get homeDashboardTabLabel => 'Pannello di controllo';

  @override
  String get homeMapTabLabel => 'Mappa';

  @override
  String get validationRequired => 'Questo campo è obbligatorio';

  @override
  String get validationEmailInvalid => 'Inserisci un indirizzo email valido';

  @override
  String validationPasswordLength(int minLength) {
    return 'La password deve contenere almeno $minLength caratteri';
  }

  @override
  String get validationPasswordUppercase => 'La password deve includere almeno una lettera maiuscola';

  @override
  String get loggingInIndicatorText => 'Accesso in corso...';

  @override
  String get loginSuccessful => 'Accesso riuscito!\nBentornato';

  @override
  String get errorLoginFailed => 'Accesso fallito. Controlla le tue credenziali';

  @override
  String get errorNetwork => 'Errore di rete. Controlla la tua connessione';

  @override
  String get homeTitle => 'Home';

  @override
  String get profileTitle => 'Profilo';

  @override
  String get chatTitle => 'Chat';

  @override
  String get editProfileNameFieldTitle => 'Nome';

  @override
  String get editProfileNameFieldLabel => 'Nome completo';

  @override
  String get editProfileUserFieldNameTitle => 'Nome utente';

  @override
  String get editProfileUsernameFieldLabel => '@nomeutente';

  @override
  String get editProfileBioFieldTitle => 'Biografia';

  @override
  String get editProfileBioFieldLabel => 'Raccontaci di te';

  @override
  String get editProfileScreenTitle => 'Modifica profilo';

  @override
  String get editProfileSettingTitle => 'Impostazioni account';

  @override
  String get editProfileSettingSubtitle => 'Gestisci il tuo account';

  @override
  String get editProfileScreenEditShopTitle => 'Modifica Negozio';

  @override
  String get editProfileScreenEditShopSubtitle => 'Modifica le informazioni del tuo negozio';

  @override
  String get languageScreenSubtitle => 'Scegli la tua lingua preferita per l\'interfaccia dell\'app. Questo non influirà sulle impostazioni del tuo dispositivo.';

  @override
  String get languageScreeUseDeviceLang => 'Usa la lingua del dispositivo.';

  @override
  String get languageScreeUseDeviceLangNote => 'Questo verrà reimpostato per corrispondere alla lingua del sistema del tuo dispositivo.';

  @override
  String get settingsScreenTitle => 'Impostazioni';

  @override
  String get accountSectionTitle => 'Account';

  @override
  String get accountSectionSubtitle => '';

  @override
  String get profileItemTitle => 'Profilo';

  @override
  String get profileItemSubtitle => 'Gestisci i tuoi dati personali';

  @override
  String get locationItemTitle => 'Cambia Posizione';

  @override
  String get locationItemSubtitle => 'Cambia la tua città attuale';

  @override
  String get saveItemTitle => 'Contenuti Salvati';

  @override
  String get saveItemSubtitle => 'Contenuti che hai salvato';

  @override
  String get notificationsItemTitle => 'Notifiche';

  @override
  String get notificationsItemSubtitle => 'Gestisci notifiche push e email';

  @override
  String get blockedItemTitle => 'Account Bloccati';

  @override
  String get blockedItemSubtitle => 'Account che hai bloccato';

  @override
  String get qrCodeItemTitle => 'Condividi Codice QR';

  @override
  String get qrCodeItemSubtitle => 'Condividi il tuo codice QR dell\'account';

  @override
  String get shareProfileItemTitle => 'Condividi Profilo';

  @override
  String get shareProfileItemSubtitle => 'Condividi il tuo profilo con gli amici';

  @override
  String get appSettingsSectionTitle => 'Impostazioni App';

  @override
  String get appSettingsSectionSubtitle => 'Personalizza la tua esperienza';

  @override
  String get themeItemTitle => 'Tema';

  @override
  String get themeItemSubtitle => 'Chiaro, Scuro o Sistema';

  @override
  String get languageItemTitle => 'Lingua';

  @override
  String get languageItemSubtitle => 'Cambia la lingua dell\'app';

  @override
  String get biometricItemTitle => 'Accesso Biometrico';

  @override
  String get biometricItemSubtitle => 'Usa Face ID o Touch ID';

  @override
  String get supportSectionTitle => 'Supporto';

  @override
  String get supportSectionSubtitle => '';

  @override
  String get guideItemTitle => 'Guida Utente';

  @override
  String get guideItemSubtitle => 'Documentazione e tutorial';

  @override
  String get helpItemTitle => 'Contatta Supporto';

  @override
  String get helpItemSubtitle => 'Ottieni aiuto con l\'app';

  @override
  String get feedbackItemTitle => 'Invia Feedback';

  @override
  String get feedbackItemSubtitle => 'Condividi i tuoi pensieri';

  @override
  String get rateItemTitle => 'Valuta l\'App';

  @override
  String get rateItemSubtitle => 'Lascia una recensione';

  @override
  String appInfoItemTitle(String appName) {
    return 'Informazioni su $appName';
  }

  @override
  String get appInfoItemSubtitle => 'Informazioni tecniche';

  @override
  String get legalSectionTitle => 'Legale';

  @override
  String get legalSectionSubtitle => '';

  @override
  String get termsItemTitle => 'Termini, Privacy e Politiche';

  @override
  String get termsItemSubtitle => 'Leggi i nostri termini';

  @override
  String get licensesItemTitle => 'Licenze Open Source';

  @override
  String get licensesItemSubtitle => 'Librerie e licenze di terze parti';

  @override
  String get accountActionsSectionTitle => 'Azioni Account';

  @override
  String get accountActionsSectionSubtitle => '';

  @override
  String get updatePasswordItemTitle => 'Aggiorna password';

  @override
  String get updatePasswordItemSubtitle => 'Cambia la password attuale del tuo account';

  @override
  String get deactivateItemTitle => 'Disattiva';

  @override
  String get deactivateItemSubtitle => 'Nascondi e disattiva temporaneamente il tuo account';

  @override
  String get deleteItemTitle => 'Elimina Account';

  @override
  String get deleteItemSubtitle => 'Richiedi l\'eliminazione permanente dell\'account';

  @override
  String get logoutItemTitle => 'Esci';

  @override
  String get logoutItemSubtitle => 'Esci dal tuo account';

  @override
  String get logoutConfirmTitle => 'Vuoi davvero uscire?';

  @override
  String get logoutConfirmMessage => 'Dovrai accedere di nuovo per usare il tuo account e i tuoi dati.';

  @override
  String get logoutConfirmButton => 'Esci';

  @override
  String get logoutSuccessMessage => 'Disconnessione riuscita';

  @override
  String logoutFailedMessage(String error) {
    return 'Disconnessione non riuscita: $error';
  }

  @override
  String get accountDeactivateTitle => 'Disattiva account';

  @override
  String get accountDeleteTitle => 'Elimina account';

  @override
  String get accountRestoreTitle => 'Ripristina account';

  @override
  String get accountDeactivateWarningTitle => 'Il tuo account sarà nascosto';

  @override
  String get accountDeactivateWarningBody => 'Profilo, negozi, prodotti, profilo freelance e link di prenotazione saranno nascosti. Puoi ripristinare l’accesso effettuando di nuovo l’accesso.';

  @override
  String get accountDeleteWarningTitle => 'L\'eliminazione è programmata per 30 giorni';

  @override
  String get accountDeleteWarningBody => 'La tua presenza pubblica sarà nascosta ora. Puoi ripristinare l\'account entro 30 giorni; dopo verranno rimossi i dati personali del profilo.';

  @override
  String get accountPasswordConfirmLabel => 'Conferma password';

  @override
  String get accountPasswordConfirmHint => 'Inserisci la password';

  @override
  String accountPhraseConfirmLabel(String phrase) {
    return 'Digita $phrase per confermare';
  }

  @override
  String get accountReasonLabel => 'Motivo (opzionale)';

  @override
  String get accountReasonHint => 'Dicci perché te ne vai';

  @override
  String accountPhraseMismatch(String phrase) {
    return 'Digita $phrase per continuare';
  }

  @override
  String get accountActionBlocked => 'Risolvi prenotazioni, ordini o prelievi attivi prima di continuare.';

  @override
  String get accountActionLoadFailed => 'Non siamo riusciti a caricare i requisiti dell\'account. Riprova.';

  @override
  String get accountActionGenericError => 'Non siamo riusciti a completare questa azione dell\'account. Riprova.';

  @override
  String get accountRecentAuthRequired => 'Accedi di nuovo prima di continuare.';

  @override
  String get accountReasonTooLong => 'Il motivo deve contenere al massimo 1000 caratteri.';

  @override
  String get accountDeactivateButton => 'Disattiva account';

  @override
  String get accountDeleteButton => 'Richiedi eliminazione';

  @override
  String get accountDeactivatedSuccess => 'Il tuo account è stato disattivato.';

  @override
  String get accountDeletionRequestedSuccess => 'L\'eliminazione dell\'account è stata programmata.';

  @override
  String get accountRestoreButton => 'Ripristina account';

  @override
  String get accountRestoredSuccess => 'Il tuo account è stato ripristinato.';

  @override
  String get accountRestoreFailed => 'Non siamo riusciti a ripristinare questo account.';

  @override
  String get accountRestoreMissingProfile => 'Non siamo riusciti a caricare il tuo profilo.';

  @override
  String get accountDeactivatedTitle => 'Account disattivato';

  @override
  String get accountDeactivatedBody => 'Il tuo account è nascosto. Ripristinalo per continuare a usare l\'app.';

  @override
  String get accountPendingDeleteTitle => 'Account in attesa di eliminazione';

  @override
  String accountPendingDeleteBody(String date) {
    return 'Il tuo account è programmato per l\'eliminazione il $date. Ripristinalo prima di allora per conservarlo.';
  }

  @override
  String get accountDeletedTitle => 'Account eliminato';

  @override
  String get accountDeletedBody => 'Questo account è stato eliminato e non può più essere ripristinato.';

  @override
  String get accountBlockersTitle => 'Risolvi prima questi elementi';

  @override
  String accountBlockerActiveBookings(int count) {
    return '$count prenotazione/i attiva/e';
  }

  @override
  String accountBlockerOwnedShopActiveBookings(int count) {
    return '$count prenotazione/i attiva/e del negozio';
  }

  @override
  String accountBlockerActiveOrders(int count) {
    return '$count ordine/i attivo/i';
  }

  @override
  String accountBlockerOwnedShopActiveOrders(int count) {
    return '$count ordine/i attivo/i del negozio';
  }

  @override
  String accountBlockerActiveWithdrawals(int count) {
    return '$count prelievo/i in sospeso';
  }

  @override
  String get loadingDefaultMessage => 'Caricamento...';

  @override
  String emptyStateNoDataTitle(String dataType) {
    return 'Nessun $dataType ancora';
  }

  @override
  String emptyStateNoDataSubtitle(String dataType) {
    return 'Quando $dataType sarà disponibile, appariranno qui.';
  }

  @override
  String get emptyStateNoResultsTitle => 'Nessun risultato trovato';

  @override
  String emptyStateNoResultsSubtitle(String dataType) {
    return 'Prova ad aggiustare la tua ricerca o filtri per trovare $dataType.';
  }

  @override
  String get emptyStateNoInternetTitle => 'Nessuna connessione internet';

  @override
  String get emptyStateNoInternetSubtitle => 'Controlla la tua connessione e riprova.';

  @override
  String get emptyStateNoFavoritesTitle => 'Nessun preferito ancora';

  @override
  String get emptyStateNoFavoritesSubtitle => 'Inizia ad aggiungere elementi alla tua lista dei preferiti.';

  @override
  String get emptyStateNoMessagesTitle => 'Nessun messaggio';

  @override
  String get emptyStateNoMessagesSubtitle => 'Avvia una conversazione per vedere i messaggi qui.';

  @override
  String get emptyStateRefresh => 'Aggiorna';

  @override
  String get emptyStateClearFilters => 'Cancella filtri';

  @override
  String get emptyStateRetry => 'Riprova';

  @override
  String get emptyStateExplore => 'Esplora';

  @override
  String get emptyStateStartChat => 'Avvia chat';

  @override
  String get errorNetworkTitle => 'Errore di connessione';

  @override
  String get errorNetworkSubtitle => 'Impossibile connettersi al server. Controlla la tua connessione internet.';

  @override
  String get errorServerTitle => 'Errore del server';

  @override
  String get errorServerSubtitle => 'Qualcosa è andato storto dalla nostra parte. Per favore, riprova più tardi.';

  @override
  String get errorClientTitle => 'Errore della richiesta';

  @override
  String get errorClientSubtitle => 'C\'è stato un problema con la tua richiesta. Per favore, controlla e riprova.';

  @override
  String get errorParsingTitle => 'Errore dati';

  @override
  String errorParsingSubtitle(String dataType) {
    return 'Impossibile elaborare il/la $dataType. Potrebbe essere un problema temporaneo.';
  }

  @override
  String get errorPermissionTitle => 'Accesso negato';

  @override
  String errorPermissionSubtitle(String dataType) {
    return 'Non hai il permesso di accedere a questo/questa $dataType.';
  }

  @override
  String get errorGenericTitle => 'Qualcosa è andato storto';

  @override
  String errorGenericSubtitle(String dataType) {
    return 'Si è verificato un errore imprevisto durante il caricamento di $dataType. Per favore, riprova.';
  }

  @override
  String get errorRetry => 'Riprova';

  @override
  String get errorCheckSettings => 'Controlla impostazioni';

  @override
  String get errorReport => 'Segnala problema';

  @override
  String get errorGoBack => 'Indietro';

  @override
  String get errorRefresh => 'Aggiorna';

  @override
  String get errorRequestAccess => 'Richiedi accesso';

  @override
  String get errorContactSupport => 'Contatta supporto';

  @override
  String get dataTypeUsers => 'utenti';

  @override
  String get dataTypeUser => 'utente';

  @override
  String get dataTypeProducts => 'prodotti';

  @override
  String get dataTypeProduct => 'prodotto';

  @override
  String get dataTypeOrders => 'ordini';

  @override
  String get dataTypeOrder => 'ordine';

  @override
  String get dataTypeMessages => 'messaggi';

  @override
  String get dataTypeMessage => 'messaggio';

  @override
  String get dataTypeFavorites => 'preferiti';

  @override
  String get dataTypeFavorite => 'preferito';

  @override
  String get dataTypeData => 'dati';

  @override
  String get dataTypeContent => 'contenuto';

  @override
  String get dataTypeItems => 'elementi';

  @override
  String get dataTypeItem => 'elemento';

  @override
  String get eulaTitle => 'Contratto di Licenza per l\'Utente Finale';

  @override
  String eulaContent(String appName, String supportEmail) {
    return 'Questo Contratto di Licenza per l\'Utente Finale (\"EULA\") è un accordo legale tra te e Bars Opus, Ltd. per $appName.\n\nInstallando, accedendo o utilizzando $appName, accetti di essere vincolato dai termini di questo EULA. $appName è concesso in licenza, non venduto, per il tuo uso solo sotto i termini di questa licenza. Bars Opus, Ltd. si riserva tutti i diritti non espressamente concessi a te in questo EULA.\n\nNon puoi modificare, eseguire ingegneria inversa, decompilare o smontare $appName. Questa licenza è valida fino alla risoluzione da parte tua o di Bars Opus, Ltd. I tuoi diritti ai sensi di questa licenza termineranno automaticamente senza preavviso se non rispetti qualsiasi termine.\n\nTutti i diritti di proprietà intellettuale su $appName sono di proprietà di Bars Opus, Ltd. Questo EULA è regolato dalle leggi dell\'Inghilterra e del Galles.\n\nPer domande su questo EULA, si prega di contattare: $supportEmail.';
  }

  @override
  String get eulaFooter => 'Accettando, riconosci di aver letto e compreso questo Contratto di Licenza per l\'Utente Finale.';

  @override
  String get privacyPolicyTitle => 'Informativa sulla Privacy';

  @override
  String privacyPolicyContent(String appName) {
    return 'Questa Informativa sulla Privacy spiega come Bars Opus, Ltd. (\"noi\", \"nostro\") raccoglie, utilizza e protegge le tue informazioni quando utilizzi $appName.\n\nRaccogliamo le informazioni che fornisci direttamente, come quando crei un account, completi il tuo profilo o contatti il supporto. Raccogliamo automaticamente alcune informazioni sul tuo dispositivo e su come utilizzi $appName. Utilizziamo cookie e tecnologie di tracciamento simili per tracciare l\'attività e conservare determinate informazioni.\n\nUtilizziamo le informazioni che raccogliamo per fornire, mantenere e migliorare $appName. Possiamo condividere le tue informazioni con fornitori di servizi di terze parti che svolgono servizi per nostro conto. Possiamo divulgare le tue informazioni se richiesto dalla legge o per proteggere i nostri diritti e la nostra sicurezza.\n\nHai il diritto di accedere, correggere o cancellare le tue informazioni personali. Implementiamo misure tecniche e organizzative appropriate per proteggere le tue informazioni. Possiamo aggiornare questa Informativa sulla Privacy di volta in volta. Ti informeremo di eventuali modifiche.';
  }

  @override
  String privacyPolicyFooter(String appName, DateTime currentDate) {
    final intl.DateFormat currentDateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String currentDateString = currentDateDateFormat.format(currentDate);

    return 'Informativa sulla Privacy di $appName - Ultimo aggiornamento: $currentDateString';
  }

  @override
  String get termsTitle => 'Termini di Servizio';

  @override
  String termsContent(String appName, String supportEmail) {
    return 'Questi Termini di Servizio (\"Termini\") disciplinano il tuo accesso e utilizzo di $appName. Accedendo o utilizzando $appName, accetti di essere vincolato da questi Termini.\n\nDevi avere almeno 13 anni per utilizzare $appName. Sei responsabile della protezione delle tue credenziali dell\'account e di tutte le attività sotto il tuo account. Non puoi utilizzare $appName per scopi illegali o non autorizzati.\n\nCi riserviamo il diritto di modificare, sospendere o interrompere $appName in qualsiasi momento. Tutti i contenuti inclusi in $appName sono di proprietà di Bars Opus, Ltd. o dei suoi licenzianti.\n\nPossiamo terminare o sospendere il tuo accesso a $appName immediatamente se violi questi Termini. Questi Termini saranno regolati e interpretati in conformità con le leggi dell\'Inghilterra e del Galles.\n\nPer qualsiasi domanda su questi Termini, contattaci a $supportEmail.';
  }

  @override
  String get dataSharingTitle => 'Accordo di Condivisione Dati';

  @override
  String dataSharingContent(String appName) {
    return 'Questo Accordo di Condivisione Dati descrive come le tue informazioni possono essere condivise quando utilizzi le funzionalità social di $appName.\n\nQuando ti connetti con amici su $appName, alcuni dati di attività possono essere visibili a loro. I dati di attività condivisi possono includere durata dell\'allenamento, calorie bruciate, minuti di esercizio e badge di risultati. Le informazioni del tuo profilo (nome visualizzato e immagine del profilo) sono visibili agli amici con cui ti connetti.\n\nIl tuo indirizzo email e le informazioni di contatto rimangono private e non sono mai condivise con altri utenti. Controlli quali dati sono condivisi attraverso le impostazioni sulla privacy di $appName. Puoi revocare le autorizzazioni di condivisione in qualsiasi momento nelle impostazioni dell\'app.\n\nI dati condivisi con gli amici sono crittografati durante la trasmissione e lo storage. Conserviamo i dati condivisi solo per il tempo necessario per fornire la funzionalità di condivisione. Le integrazioni di terze parti possono avere le proprie pratiche di condivisione dei dati, che consigliamo di rivedere.';
  }

  @override
  String dataSharingFooter(String appName) {
    return 'La condivisione dei dati in $appName aiuta a creare una comunità di supporto rispettando le tue scelte sulla privacy.';
  }

  @override
  String get dashboardTitle => 'Pannello di Controllo';

  @override
  String get dashboardSubtitle => 'Gestisci le attività del tuo negozio in modo efficiente';

  @override
  String get dashboardSectionTitle => 'Dashboard';

  @override
  String get dashboardSectionSubtitle => 'Panoramica delle prestazioni e delle metriche chiave del tuo negozio';

  @override
  String get dashboardPayoutTitle => 'Richiedi Pagamento';

  @override
  String get dashboardPayoutContent => 'I proprietari di negozi possono richiedere pagamenti settimanali. Naviga alla sezione Guadagni, rivedi il tuo saldo e invia una richiesta di pagamento. I fondi vengono generalmente elaborati entro 3-5 giorni lavorativi.';

  @override
  String get dashboardAnalyticsTitle => 'Dashboard Analitica';

  @override
  String get dashboardAnalyticsContent => 'Traccia le prestazioni del tuo negozio con analisi in tempo reale. Monitora le tendenze delle vendite, l\'impegno dei clienti e i livelli di inventario tramite grafici interattivi e report.';

  @override
  String get dashboardScreenshotTitle => 'Panoramica Dashboard';

  @override
  String get dashboardScreenshotContent => 'La dashboard principale fornisce una visione completa delle metriche chiave del tuo negozio, delle attività recenti e di un accesso rapido alle funzionalità essenziali.';

  @override
  String get categoryFeatures => 'Caratteristiche';

  @override
  String get categoryDashboard => 'Dashboard';

  @override
  String get faqDashboard1Question => 'Quando posso richiedere un pagamento?';

  @override
  String get faqDashboard1Answer => 'Puoi richiedere il tuo pagamento una volta alla settimana, ogni sabato. Il taglio settimanale è venerdì alle 23:59. I pagamenti vengono elaborati entro 3-5 giorni lavorativi.';

  @override
  String get faqDashboard2Question => 'Dove posso richiedere il mio pagamento?';

  @override
  String get faqDashboard2Answer => 'Naviga nella tua dashboard e fai clic sulla sezione \'Guadagni\'. Da lì vedrai il tuo saldo attuale e un pulsante \'Richiedi Pagamento\'. Segui le istruzioni per completare la tua richiesta.';

  @override
  String get profileScreenCantChatWithYourself => 'Non puoi chattare con te stesso';

  @override
  String get profileScreenStartingConversation => 'Avvio della conversazione...';

  @override
  String get profileScreenNoActiveSession => 'Nessuna sessione attiva — accedi di nuovo.';

  @override
  String get profileScreenSignInToChatMessage => 'Devi accedere per inviare un messaggio';

  @override
  String get profileScreenFollowFeatureComingSoon => 'La funzione di follow arriva presto';

  @override
  String get profileScreenEnterBioPlaceholder => 'Inserisci una biografia in modo che le persone ti conoscano';

  @override
  String get profileScreenNoBioYet => 'Nessuna biografia ancora';

  @override
  String get profileScreenErrorLoadingProfileBody => 'Impossibile caricare il profilo. Controlla la tua connessione Internet e riprova.';

  @override
  String get profileScreenLoadingNotifications => 'Caricamento...';

  @override
  String get profileHeaderBookingsStatLabel => 'Prenotazioni';

  @override
  String get profileHeaderOrdersStatLabel => 'Ordini';

  @override
  String get profileHeaderEditProfileButton => 'Modifica profilo';

  @override
  String get profileHeaderMessageButton => 'Messaggio';

  @override
  String get editableProfileAvatarTakePhoto => 'Scatta una foto';

  @override
  String get editableProfileAvatarChooseGallery => 'Scegli dalla galleria';

  @override
  String get editProfileScreenAccountTypeLabel => 'Tipo di account';

  @override
  String get editProfileScreenAccountTypeSubtitle => 'Seleziona come desideri utilizzare questa app. Questo determina quali funzionalità sono disponibili per te.';

  @override
  String get editProfileScreenUpdatingAccountType => 'Aggiornamento del tipo di account...';

  @override
  String get editProfileScreenPleaseLogIn => 'Accedi per favore';

  @override
  String get editProfileScreenNameLabel => 'Nome';

  @override
  String get editProfileScreenNameHint => 'Inserisci il tuo nome';

  @override
  String get editProfileScreenUsernameLabel => 'Nome utente';

  @override
  String get editProfileScreenUsernameHint => 'Inserisci il nome utente';

  @override
  String get editProfileScreenBioLabel => 'Biografia';

  @override
  String get editProfileScreenBioHint => 'Raccontaci qualcosa su di te';

  @override
  String get editProfileScreenEditWorkProfileTitle => 'Modifica profilo di lavoro';

  @override
  String get profileTabsAppointments => 'Appuntamenti';

  @override
  String get profileTabsBuys => 'Acquisti';

  @override
  String get profileTabsSaves => 'Salvataggi';

  @override
  String get searchScreenSearchHint => 'Cerca negozi, professionisti, prodotti...';

  @override
  String get searchScreenNoResultsFound => 'Nessun risultato trovato';

  @override
  String searchScreenNoResultsCategory(String category) {
    return 'Nessun $category trovato';
  }

  @override
  String searchScreenSearchedFor(String query) {
    return 'Ricercato: \"$query\"';
  }

  @override
  String get searchScreenSomethingWentWrong => 'Qualcosa è andato storto';

  @override
  String get searchAppBarSearchHint => 'Cerca...';

  @override
  String get searchSuggestionsHint => 'Cerca negozi, professionisti di servizi a domicilio o prodotti per capelli da acquistare';

  @override
  String get searchSuggestionsRecentSearches => 'Ricerche recenti';

  @override
  String get searchSuggestionsClearAll => 'Cancella tutto';

  @override
  String get searchEmptyStateNoResults => 'Nessun risultato trovato';

  @override
  String searchEmptyStateCouldNotFind(String query) {
    return 'Non abbiamo trovato nulla per \"$query\"';
  }

  @override
  String get searchEmptyStateTryThese => 'Prova questi:';

  @override
  String get searchResultsShopsHeader => 'Negozi';

  @override
  String get searchResultsSeeAll => 'Vedi tutto';

  @override
  String searchResultsTitle(String category) {
    return 'Risultati di $category';
  }

  @override
  String searchResultsSearchingFor(String query) {
    return 'Ricerca di \"$query\"';
  }

  @override
  String get searchResultsTryDifferent => 'Prova parole chiave diverse o rimuovi i filtri';

  @override
  String get searchResultsSomethingWentWrong => 'Qualcosa è andato storto';

  @override
  String nearYouShopsTitle(int km) {
    return 'Vicino a te\nentro ${km}km';
  }

  @override
  String nearYouShopsBody(int km) {
    return 'Negozi situati entro $km km dalla tua posizione attuale, mostrati dal più vicino al più lontano. Semplicemente imposta la tua posizione una volta, e ti mostreremo cosa c\'è vicino—sia che tu sia a casa, al lavoro o che stia esplorando un nuovo quartiere. Utile per prenotazioni last-minute o quando preferisci camminare.';
  }

  @override
  String get nearYouShopsEmptyNoFilter => 'Nessun negozio trovato nelle vicinanze';

  @override
  String nearYouShopsEmptyWithFilter(String luxury) {
    return 'Nessun negozio $luxury trovato nelle vicinanze';
  }

  @override
  String nearYouShopsEmptySubtitle(String location) {
    return 'I negozi a $location verranno mostrati qui una volta che saranno disponibili';
  }

  @override
  String get premiumShopsScreenTitle => 'Negozi Premium';

  @override
  String get premiumShopsEmpty => 'Nessun negozio premium trovato';

  @override
  String get premiumShopsHorizontalTitle => 'Negozi premium\nper look premium';

  @override
  String get premiumShopsHorizontalBody => 'Saloni e spa di lusso selezionati che offrono esperienze lussuose. Questi negozi sono classificati come Lusso o Ultra-Lusso in base ai loro servizi, prezzi e recensioni dei clienti. Perfetto quando cerchi quel tocco extra di eleganza.';

  @override
  String get premiumShopsHorizontalEmptyNoFilter => 'Nessun negozio premium disponibile';

  @override
  String premiumShopsHorizontalEmptyWithFilter(String luxury) {
    return 'Nessun negozio premium $luxury disponibile';
  }

  @override
  String get premiumShopsHorizontalEmptySubtitle => 'I negozi verranno mostrati qui una volta disponibili';

  @override
  String get topRatedShopsHorizontalTitle => 'Meglio valutati';

  @override
  String topRatedShopsHorizontalTitleWithLocation(String location) {
    return 'Meglio valutati \na $location';
  }

  @override
  String get topRatedShopsHorizontalBody => 'Negozi con le valutazioni più alte dei clienti (4,5+ stelle) e molte recensioni. Questi sono i preferiti della nostra comunità—costantemente elogiati per qualità, servizio e professionalità. Un ottimo punto di partenza se cerchi opzioni affidabili e approvate dalla folla.';

  @override
  String get topRatedShopsHorizontalEmptyNoFilter => 'Nessun negozio meglio valutato disponibile';

  @override
  String topRatedShopsHorizontalEmptyWithFilter(String luxury) {
    return 'Nessun negozio premium $luxury disponibile';
  }

  @override
  String get topRatedShopsHorizontalEmptySubtitle => 'I negozi verranno mostrati qui una volta disponibili';

  @override
  String get topRatedShopsScreenTitle => 'Negozi Meglio Valutati';

  @override
  String get topRatedShopsEmpty => 'Nessun negozio meglio valutato trovato';

  @override
  String get nearYouFreelancersScreenTitle => 'Freelancer vicino a te';

  @override
  String get nearYouFreelancersEmpty => 'Nessun freelancer trovato nelle vicinanze';

  @override
  String get nearYouFreelancersEmptySubtitle => 'Prova ad espandere la tua area di ricerca o cambia posizione';

  @override
  String get topRatedFreelancersScreenTitle => 'Freelancer meglio valutati';

  @override
  String get topRatedFreelancersEmpty => 'Nessun freelancer meglio valutato trovato';

  @override
  String get topRatedFreelancersEmptySubtitle => 'Prova ad adattare la tua area di ricerca';

  @override
  String topRatedFreelancersHorizontalTitle(String location) {
    return 'Meglio valutati \na $location';
  }

  @override
  String get topRatedFreelancersHorizontalBody => 'Professionisti di alto livello selezionati che offrono esperienze lussuose. Questi freelancer sono classificati come meglio valutati in base alla qualità del loro lavoro, prezzi e recensioni dei clienti. Perfetto per quel tocco extra di eccellenza.';

  @override
  String nearYouFreelancersHorizontalTitle(String location) {
    return 'Freelancer Vicino a Te a $location';
  }

  @override
  String get nearYouFreelancersHorizontalBody => 'Professionisti qualificati ubicati vicino a te. Questi freelancer sono disponibili per prenotazioni rapide e offrono servizio locale conveniente. Perfetto quando cerchi affidabilità e prossimità.';

  @override
  String get nearYouFreelancersHorizontalEmpty => 'Nessun freelancer meglio valutato disponibile';

  @override
  String get nearYouFreelancersHorizontalEmptySubtitle => 'I freelancer verranno mostrati qui una volta disponibili';

  @override
  String get shopNoLocationSetTitle => 'Imposta la tua posizione per scoprire';

  @override
  String get shopNoLocationSetContent => 'Imposta la tua posizione per scoprire negozi premium e ben valutati vicino a te.';

  @override
  String get providerTypeShops => 'Negozi';

  @override
  String get providerTypeFreelancers => 'Freelancer';

  @override
  String get providerTypeBuy => 'Acquista';

  @override
  String get luxuryLevelChipsAll => 'Tutti';

  @override
  String get searchRadiusSliderTitle => 'Raggio di esplorazione';

  @override
  String searchRadiusSliderSubtitle(int km) {
    return 'Visualizzazione risultati entro ${km}km dalla tua posizione';
  }

  @override
  String validationPasswordMaxLength(int max) {
    return 'La password non deve superare $max caratteri';
  }

  @override
  String get validationPasswordRepeatingChars => 'La password contiene troppi caratteri ripetuti';

  @override
  String get validationPasswordSequential => 'La password contiene caratteri sequenziali';

  @override
  String validationPhoneDigits(int digits) {
    return 'Il numero di telefono deve contenere $digits cifre';
  }

  @override
  String get validationPhoneUK => 'Numero di telefono britannico non valido';

  @override
  String validationUrlScheme(String schemes) {
    return 'L\'URL deve iniziare con $schemes';
  }

  @override
  String get validationUrlDomain => 'Nome di dominio non valido';

  @override
  String get validationUrlPublicAddress => 'L\'URL deve puntare a un indirizzo pubblico';

  @override
  String validationNameMaxLength(String field, int max) {
    return '$field non deve superare $max caratteri';
  }

  @override
  String validationNameConsecutiveChars(String field) {
    return '$field non può contenere trattini o spazi consecutivi';
  }

  @override
  String get validationCreditCardFormat => 'Per favore inserisci un numero di carta di credito valido';

  @override
  String get validationCreditCardInvalid => 'Numero di carta di credito non valido';

  @override
  String get validationDatePastNotAllowed => 'La data non può essere nel passato';

  @override
  String get validationPostalCodeZip => 'Per favore inserisci un codice postale valido (es. 12345 o 12345-6789)';

  @override
  String get validationPostalCodeCanadian => 'Per favore inserisci un codice postale canadese valido (es. A1A 1A1)';

  @override
  String get validationPostalCodeGeneric => 'Per favore inserisci un codice postale valido';

  @override
  String get validationSSNFormat => 'Per favore inserisci un SSN valido (es. 123-45-6789)';

  @override
  String get validationSSNInvalid => 'SSN non valido';

  @override
  String get validationEmailTooLong => 'L\'indirizzo email è troppo lungo (max. 254 caratteri)';

  @override
  String get validationEmailLocalPartTooLong => 'La parte locale dell\'indirizzo email è troppo lunga';

  @override
  String get categoriesAll => 'Tutti';

  @override
  String get categoriesSalon => 'Saloni';

  @override
  String get categoriesBarbershop => 'Barberie';

  @override
  String get categoriesSpa => 'Spa';

  @override
  String get categoriesNailSalon => 'Saloni per Unghie';

  @override
  String get categoriesLashStudio => 'Studi di Ciglia';

  @override
  String get categoriesWaxing => 'Depilazione';

  @override
  String get categoriesMassage => 'Massaggio';

  @override
  String get categoriesMakeup => 'Trucco';

  @override
  String get categoriesSkincare => 'Cura della Pelle';

  @override
  String get luxuryLevelModerate => 'Moderato';

  @override
  String get luxuryLevelLuxury => 'Lusso';

  @override
  String get luxuryLevelUltraLuxury => 'Ultra Lusso';

  @override
  String get dashboardTabRevenue => 'Entrate';

  @override
  String get dashboardTabAnalytics => 'Analisi';

  @override
  String get dashboardTabInsights => 'Approfondimenti';

  @override
  String get dashboardTabTools => 'Strumenti';

  @override
  String get dashboardTabClients => 'Clienti';

  @override
  String get dashboardTabStaff => 'Personale';

  @override
  String get walletRecentTransactions => 'Transazioni Recenti';

  @override
  String get walletLoadError => 'Non siamo riusciti a caricare il tuo portafoglio in questo momento.';

  @override
  String get walletTransactionLoadError => 'Impossibile caricare le transazioni recenti.';

  @override
  String get walletPaymentProcessing => 'Attendi che il pagamento sia elaborato e torna all\'app per completare la tua prenotazione.';

  @override
  String get analyticsRevenue => 'Entrate';

  @override
  String get analyticsServices => 'Servizi';

  @override
  String get analyticsWorkers => 'Lavoratori';

  @override
  String get analyticsLoadError => 'Impossibile caricare le analisi';

  @override
  String get analyticsEmpty => 'Nessun dato disponibile per le analisi.';

  @override
  String get analyticsEmptySubtitle => 'Le statistiche di prenotazione e entrate apparirebbero qui';

  @override
  String get insightsReports => 'Report';

  @override
  String get insightsSeeAll => 'Visualizza Tutto';

  @override
  String get insightsLoadError => 'Impossibile caricare i report. Scorri per aggiornare.';

  @override
  String get insightsNoAlerts => 'Tutto bene! Nessun avviso';

  @override
  String get insightsHeatmapError => 'Impossibile caricare la mappa di calore delle prenotazioni.';

  @override
  String get insightsNoHeatmapData => 'Nessun dato della mappa di calore disponibile';

  @override
  String get toolsAdminTools => 'Strumenti di Amministrazione';

  @override
  String get toolsConfigure => 'Configura →';

  @override
  String get toolsManage => 'Gestisci →';

  @override
  String get toolsExport => 'Esporta →';

  @override
  String get toolsAutomatedReminders => 'Promemoria Automatici';

  @override
  String get toolsPromotionsManager => 'Gestore delle Promozioni';

  @override
  String get toolsExportReports => 'Esporta Report';

  @override
  String get toolsPaymentSettings => 'Impostazioni di Pagamento';

  @override
  String get toolsLoadingDetails => 'Caricamento dettagli negozio…';

  @override
  String get toolsBusinessHours => 'Orari di Apertura';

  @override
  String get toolsServiceManagement => 'Gestione dei Servizi';

  @override
  String get clientsSearchHint => 'Cerca per nome...';

  @override
  String get clientsLoadError => 'Impossibile caricare i clienti';

  @override
  String get clientsNotFound => 'Nessun Cliente Trovato';

  @override
  String get clientsEmpty => 'Nessun Cliente Ancora';

  @override
  String clientsSearchEmpty(String query) {
    return 'Nessun cliente corrisponde a \"$query\"';
  }

  @override
  String get clientsEmptySubtitle => 'I clienti appariranno qui quando effettuano la loro prima prenotazione.';

  @override
  String get walletLabel => 'Portafoglio';

  @override
  String get walletAvailableBalance => 'Saldo Disponibile';

  @override
  String get walletWithdrawFunds => 'Ritira Fondi';

  @override
  String get walletTotalEarned => 'Totale Guadagnato';

  @override
  String get walletTotalWithdrawn => 'Totale Prelevato';

  @override
  String get transactionDepositReceived => 'Deposito Ricevuto';

  @override
  String get transactionServicePayment => 'Pagamento del Servizio';

  @override
  String get transactionWithdrawal => 'Prelievo';

  @override
  String get transactionRefund => 'Rimborso';

  @override
  String get transactionPlatformFee => 'Commissione Piattaforma';

  @override
  String get transactionAdjustment => 'Rettifica';

  @override
  String get transactionToday => 'Oggi';

  @override
  String get transactionYesterday => 'Ieri';

  @override
  String get withdrawalTitle => 'Ritira';

  @override
  String withdrawalInfo(double fee, String currency, double minFee) {
    return 'I prelievi vengono elaborati immediatamente e inviati al tuo conto collegato. Si applica una commissione di $fee% (min $currency $minFee).';
  }

  @override
  String withdrawalAvailableBalance(String currency, String amount) {
    return 'Saldo disponibile: $currency $amount';
  }

  @override
  String withdrawalAmountInputLabel(String currency) {
    return 'Importo ($currency)';
  }

  @override
  String get withdrawalAmountHint => 'Inserisci l\'importo da prelevare';

  @override
  String get withdrawalAmountRequired => 'Inserisci un importo';

  @override
  String get withdrawalAmountInvalid => 'Inserisci un importo valido';

  @override
  String withdrawalMinimum(String currency, double min) {
    return 'Il prelievo minimo è $currency $min';
  }

  @override
  String withdrawalMaximum(String currency, double max) {
    return 'Il prelievo massimo per transazione è $currency $max';
  }

  @override
  String withdrawalInsufficientBalance(String currency, String available) {
    return 'Saldo insufficiente. Disponibile: $currency $available';
  }

  @override
  String get withdrawalBreakdownAmount => 'Importo da prelevare:';

  @override
  String withdrawalFeeLabel(Object fee) {
    return 'Commissione ($fee%):';
  }

  @override
  String get withdrawalNetAmount => 'Riceverai:';

  @override
  String get withdrawalProcessing => 'Elaborazione in corso...';

  @override
  String get withdrawalRequestButton => 'Richiedi Prelievo';

  @override
  String get withdrawalNoPaymentMethod => 'Nessun metodo di pagamento collegato';

  @override
  String get withdrawalSuccess => 'Richiesta di prelievo inviata con successo!';

  @override
  String get deadLetterTitle => 'Il prelievo necessita di revisione';

  @override
  String deadLetterSingle(String currency, String amount) {
    return '$currency $amount bloccato — tocca per i dettagli';
  }

  @override
  String deadLetterMultiple(String currency, String amount, int count) {
    return '$currency $amount bloccato su $count prelievi — tocca per i dettagli';
  }

  @override
  String get deadLetterReason => 'Motivo:';

  @override
  String get deadLetterContactSupport => 'Contatta il supporto';

  @override
  String get paymentSetupTitle => 'Completa la configurazione del pagamento';

  @override
  String get paymentSetupContent => 'Collega il tuo account di pagamento per iniziare a ritirare denaro dal tuo portafoglio. Potrebbe essere il tuo numero di cellulare o il tuo conto bancario.';

  @override
  String get calendarErrorLoading => 'Errore nel caricamento del calendario';

  @override
  String get calendarErrorLoadingBookings => 'Errore nel caricamento delle prenotazioni';

  @override
  String get calendarNoAppointmentsDay => 'Nessun appuntamento per questo giorno';

  @override
  String get calendarNoBookingsDay => 'Nessuna prenotazione per questo giorno';

  @override
  String calendarAppointmentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'appuntamenti',
      one: 'appuntamento',
    );
    return '$count $_temp0';
  }

  @override
  String get monthJanuary => 'Gen';

  @override
  String get monthFebruary => 'Feb';

  @override
  String get monthMarch => 'Mar';

  @override
  String get monthApril => 'Apr';

  @override
  String get monthMay => 'Mag';

  @override
  String get monthJune => 'Giu';

  @override
  String get monthJuly => 'Lug';

  @override
  String get monthAugust => 'Ago';

  @override
  String get monthSeptember => 'Set';

  @override
  String get monthOctober => 'Ott';

  @override
  String get monthNovember => 'Nov';

  @override
  String get monthDecember => 'Dic';

  @override
  String get dayMonday => 'Lun';

  @override
  String get dayTuesday => 'Mar';

  @override
  String get dayWednesday => 'Mer';

  @override
  String get dayThursday => 'Gio';

  @override
  String get dayFriday => 'Ven';

  @override
  String get daySaturday => 'Sab';

  @override
  String get daySunday => 'Dom';

  @override
  String calendarNoAppointmentsSnackbar(String date) {
    return 'Nessun appuntamento in questo giorno\n$date';
  }

  @override
  String reviewsScreenTitle(String shopName) {
    return 'Recensioni per $shopName';
  }

  @override
  String get reviewsLoadError => 'Impossibile caricare le recensioni';

  @override
  String get reviewsNoReviews => 'Nessuna recensione al momento';

  @override
  String get reviewsRateProduct => 'Valuta il prodotto';

  @override
  String get reviewsYourReview => 'La tua recensione';

  @override
  String get reviewsReviewHint => 'Condividi la tua esperienza con questo prodotto...';

  @override
  String get reviewsSubmitButton => 'Invia recensione';

  @override
  String get reviewsThankYou => 'Grazie per la tua recensione!';

  @override
  String reviewsSubmitError(String error) {
    return 'Impossibile inviare la recensione: $error';
  }

  @override
  String get bookingServiceAddress => 'Indirizzo del servizio';

  @override
  String get bookingFindingAvailableTimes => 'Ricerca degli orari disponibili...';

  @override
  String bookingErrorLoadingWorkers(String error) {
    return 'Errore nel caricamento dei lavoratori: $error';
  }

  @override
  String bookingErrorValidatingDistance(String error) {
    return 'Errore nella convalida della distanza: $error';
  }

  @override
  String get bookingAddSpecialRequirements => 'Aggiungi';

  @override
  String get bookingCancelSpecialRequirements => 'Annulla';

  @override
  String get bookingSaveSpecialRequirements => 'Salva';

  @override
  String bookingFailedSaveRequirements(String error) {
    return 'Errore nel salvataggio: $error';
  }

  @override
  String get bookingInvitationSent => 'Invito inviato con successo';

  @override
  String get bookingSavingAssignments => 'Salvataggio delle assegnazioni...';

  @override
  String get bookingAssignmentsSaved => 'Assegnazioni salvate con successo';

  @override
  String bookingAssignmentsError(String error) {
    return 'Errore: $error';
  }

  @override
  String get scheduleTitle => 'Orario';

  @override
  String get scheduleTabDaily => 'Giornaliero';

  @override
  String get scheduleTabMonthly => 'Mensile';

  @override
  String get toolsLoyaltyRule => 'Loyalty rule';

  @override
  String get loyaltyTitle => 'Loyalty rule';

  @override
  String get loyaltyRewardHeader => 'Reward every Nth completed booking';

  @override
  String get loyaltyRewardSubheader => 'Clients never see their progress. The discount auto-applies on the qualifying booking as a surprise reward.';

  @override
  String get loyaltyTriggerSectionTitle => 'Trigger every';

  @override
  String get loyaltyTriggerCompletedBookings => 'completed bookings';

  @override
  String get loyaltyDiscountTypeTitle => 'Discount type';

  @override
  String get loyaltyDiscountTypePercent => 'Percent';

  @override
  String get loyaltyDiscountTypeFixed => 'Fixed amount';

  @override
  String get loyaltyPercentOff => 'Percent off';

  @override
  String get loyaltyAmountOff => 'Amount off';

  @override
  String get loyaltyActiveTitle => 'Active';

  @override
  String get loyaltyActiveSubtitle => 'When off, no loyalty codes are generated for this shop.';

  @override
  String get loyaltyLoadFailed => 'We couldn\'t load the loyalty rule.';

  @override
  String get loyaltyRetry => 'Retry';

  @override
  String get loyaltySave => 'Save';

  @override
  String get loyaltySavedSnackbar => 'Loyalty rule saved';

  @override
  String get promoFieldPerClientMaxLabel => 'Per-client redemption limit';

  @override
  String get promoFieldPerClientMaxHint => 'Times one client can use this code';

  @override
  String get promoFieldMinAmountLabel => 'Minimum booking amount (Optional)';

  @override
  String get promoFieldMinAmountHint => 'Code only applies above this total';

  @override
  String get promoFieldServiceRestrictionTitle => 'Restrict to services (Optional)';

  @override
  String get promoFieldServiceRestrictionSubtitle => 'Leave empty to apply to any service. Pick one or more to restrict the discount to bookings that include them.';

  @override
  String get promoFieldServiceRestrictionLoadFailed => 'We couldn\'t load your services.';

  @override
  String get promoFieldServiceRestrictionEmpty => 'No services to restrict against yet.';

  @override
  String get promoFieldArchivedTitle => 'Archived';

  @override
  String get promoFieldArchivedSubtitle => 'Archived promotions are hidden from clients and frees up the code text for re-use.';

  @override
  String get promoValidationPerClientMin => 'Must be at least 1';

  @override
  String get promoValidationMinAmountNonNegative => 'Must be 0 or higher';

  @override
  String get promoListShowSystemCodes => 'Show system codes';

  @override
  String get promoListHideSystemCodes => 'Hide system codes';

  @override
  String get promoSourceOwner => 'Owner';

  @override
  String get promoSourceLoyalty => 'Loyalty';

  @override
  String get promoSourceRecovery => 'Recovery';

  @override
  String get promoSourceAutoGeneratedReadOnly => 'auto-generated · read-only';

  @override
  String get broadcastsTitle => 'Broadcasts';

  @override
  String get broadcastsToolsCardLabel => 'Broadcasts';

  @override
  String get broadcastsEmptyTitle => 'No broadcasts yet';

  @override
  String get broadcastsEmptyBody => 'Tap + to send your first. You can broadcast once per day to up to 1000 clients.';

  @override
  String get broadcastsFabTooltip => 'New broadcast';

  @override
  String get broadcastsLoadFailed => 'We couldn\'t load your broadcasts.';

  @override
  String get broadcastsRetry => 'Retry';

  @override
  String get broadcastCreateTitle => 'New broadcast';

  @override
  String get broadcastSubjectLabel => 'Subject';

  @override
  String get broadcastSubjectHelper => 'Shown as the push notification title.';

  @override
  String get broadcastSubjectRequired => 'Subject is required.';

  @override
  String get broadcastBodyLabel => 'Message';

  @override
  String get broadcastBodyHelper => 'Plain text only. WhatsApp recipients also see your shop name and an opt-out line.';

  @override
  String get broadcastBodyRequired => 'Message is required.';

  @override
  String get broadcastAudienceLabel => 'Audience';

  @override
  String get broadcastAudienceAllClients => 'All';

  @override
  String get broadcastAudienceRecent => 'Recent';

  @override
  String get broadcastAudienceLapsed => 'Lapsed';

  @override
  String get broadcastAudienceByService => 'Service';

  @override
  String get broadcastServiceLabel => 'Service';

  @override
  String get broadcastServicePickRequired => 'Pick a service.';

  @override
  String get broadcastServiceLoadFailed => 'We couldn\'t load your services.';

  @override
  String get broadcastServiceEmpty => 'No active services to pick from.';

  @override
  String get broadcastPromoLabel => 'Attach a promo code (optional)';

  @override
  String get broadcastPromoHelper => 'Only your own promo codes can be attached. Loyalty and recovery codes aren\'t shown.';

  @override
  String get broadcastPromoNone => 'None';

  @override
  String get broadcastPreviewResolving => 'Resolving audience…';

  @override
  String get broadcastPreviewPickAudience => 'Pick an audience to preview.';

  @override
  String get broadcastPreviewPickService => 'Pick a service to preview.';

  @override
  String broadcastPreviewCount(Object count) {
    return 'This will send to $count people.';
  }

  @override
  String get broadcastPreviewCapWarning => 'Audience exceeds the 1000-recipient cap. Try a narrower preset.';

  @override
  String get broadcastPreviewFailed => 'Couldn\'t preview audience.';

  @override
  String get broadcastSendButton => 'Send';

  @override
  String get broadcastConfirmTitle => 'Send broadcast?';

  @override
  String broadcastConfirmBodyAll(Object count) {
    return 'Send to $count all clients? This cannot be undone.';
  }

  @override
  String broadcastConfirmBodyRecent(Object count) {
    return 'Send to $count recent clients? This cannot be undone.';
  }

  @override
  String broadcastConfirmBodyLapsed(Object count) {
    return 'Send to $count lapsed clients? This cannot be undone.';
  }

  @override
  String broadcastConfirmBodyService(Object count) {
    return 'Send to $count clients of this service? This cannot be undone.';
  }

  @override
  String get broadcastConfirmBodyWithPromoSuffix => ' A promo code will be attached.';

  @override
  String get broadcastConfirmCancel => 'Cancel';

  @override
  String get broadcastConfirmSend => 'Send';

  @override
  String broadcastSentToast(Object count) {
    return 'Sent to $count people.';
  }

  @override
  String get broadcastStatusPending => 'Pending';

  @override
  String get broadcastStatusDelivering => 'Sending';

  @override
  String get broadcastStatusDelivered => 'Sent';

  @override
  String get broadcastStatusFailed => 'Failed';

  @override
  String get broadcastDeliveringTooltip => 'WhatsApp template approval is pending. This usually resolves within 24h.';

  @override
  String broadcastAudienceLabelShort(Object audience) {
    return 'Audience: $audience';
  }

  @override
  String broadcastPromoLabelShort(Object id) {
    return 'Promo attached: $id';
  }

  @override
  String broadcastRecipientsLabel(Object count) {
    return 'Recipients: $count';
  }

  @override
  String broadcastDeliveredLabel(Object when) {
    return 'Delivered: $when';
  }

  @override
  String broadcastStatusLabel(Object status) {
    return 'Status: $status';
  }

  @override
  String get broadcastDetailClose => 'Close';

  @override
  String get broadcastRateLimitMessage => 'You\'ve already sent a broadcast today. Try again tomorrow.';

  @override
  String get broadcastInFlightMessage => 'Another broadcast is being processed. Please wait a moment.';

  @override
  String get broadcastInvalidAudienceMessage => 'Please pick a valid audience and (if \'By service\') a service.';

  @override
  String get broadcastPromoInvalidMessage => 'This code is no longer valid. Pick another or remove the code.';

  @override
  String get broadcastCapExceededMessage => 'This audience is larger than the 1000-recipient cap. Try a narrower audience.';

  @override
  String get broadcastSaveFailedMessage => 'Could not send broadcast. Please try again.';
}
