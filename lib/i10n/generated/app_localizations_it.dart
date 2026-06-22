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
  String get editProfileScreenCreateFreelancerTitle => 'Create freelancer profile';

  @override
  String get editProfileScreenCreateFreelancerSubtitle => 'Set up your work profile so clients can find and book you.';

  @override
  String get editProfileScreenCreateShopTitle => 'Create shop';

  @override
  String get editProfileScreenCreateShopSubtitle => 'Set up your shop so clients can find and book your services.';

  @override
  String get editProfileScreenSellProductTitle => 'Sell a product';

  @override
  String get editProfileScreenSellProductSubtitle => 'Sell your beauty products like pomades, shampoos, hairbrushes and more.';

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

  @override
  String get pricingChipDiscount => 'Discount';

  @override
  String get pricingChipSurcharge => 'Surcharge';

  @override
  String get pricingOverridesTitle => 'Pricing rules';

  @override
  String get pricingOverridesEmptyTitle => 'No rules yet';

  @override
  String pricingOverridesEmptyBody(String serviceName) {
    return 'Add a time-based discount or surcharge for $serviceName.';
  }

  @override
  String get pricingOverridesEmptyCta => 'Create rule';

  @override
  String get pricingOverridesNewCta => 'New rule';

  @override
  String get pricingOverridesRefresh => 'Refresh';

  @override
  String get pricingOverridesLoadFailed => 'Could not load pricing rules.';

  @override
  String get pricingOverridesRetry => 'Retry';

  @override
  String get pricingOverrideArchiveConfirmTitle => 'Archive rule?';

  @override
  String pricingOverrideArchiveConfirmBody(String name) {
    return '\"$name\" will stop applying to new bookings. Existing bookings keep the price they were confirmed at.';
  }

  @override
  String get pricingOverrideArchiveConfirmCancel => 'Cancel';

  @override
  String get pricingOverrideArchiveConfirmArchive => 'Archive';

  @override
  String get pricingOverrideArchiveSuccess => 'Rule archived';

  @override
  String get pricingOverrideArchiveFailed => 'Could not archive the rule. Please try again.';

  @override
  String get pricingOverrideRowActionsTooltip => 'Actions';

  @override
  String get pricingOverrideRowEdit => 'Edit';

  @override
  String get pricingOverrideRowArchive => 'Archive';

  @override
  String get pricingOverrideAllWeek => 'All week';

  @override
  String get pricingOverrideFormTitleNew => 'New rule';

  @override
  String get pricingOverrideFormTitleEdit => 'Edit rule';

  @override
  String get pricingOverrideFormName => 'Name';

  @override
  String get pricingOverrideFormNameHint => 'e.g. Off-peak Tuesday morning';

  @override
  String get pricingOverrideFormNameRequired => 'Required';

  @override
  String get pricingOverrideFormNameTooLong => 'Max 80 characters';

  @override
  String get pricingOverrideFormDayOfWeek => 'Day of week';

  @override
  String get pricingOverrideFormTimeWindow => 'Time window';

  @override
  String get pricingOverrideFormStart => 'Start';

  @override
  String get pricingOverrideFormEnd => 'End';

  @override
  String get pricingOverrideFormWindowError => 'End time must be after start time';

  @override
  String get pricingOverrideFormAdjustment => 'Adjustment';

  @override
  String get pricingOverrideFormKindPercentDiscount => '% off';

  @override
  String get pricingOverrideFormKindPercentSurcharge => '% up';

  @override
  String get pricingOverrideFormKindFixedDiscount => '\$ off';

  @override
  String get pricingOverrideFormKindFixedSurcharge => '\$ up';

  @override
  String get pricingOverrideFormValueRequired => 'Required';

  @override
  String get pricingOverrideFormValueMustBePositive => 'Must be greater than 0';

  @override
  String get pricingOverrideFormValuePercentRange => 'Percent must be 0.01–100';

  @override
  String get pricingOverrideFormValidity => 'Validity (optional)';

  @override
  String get pricingOverrideFormValidityStarts => 'Starts';

  @override
  String get pricingOverrideFormValidityEnds => 'Ends';

  @override
  String get pricingOverrideFormValidityNoExpiry => 'No expiry';

  @override
  String get pricingOverrideFormValidityToday => 'Today';

  @override
  String get pricingOverrideFormValidityError => 'End date must be after start date';

  @override
  String get pricingOverrideFormClearDayHint => 'To clear the day filter, archive this rule and create a new one.';

  @override
  String get pricingOverrideFormClearValidUntilHint => 'To clear the end date, archive this rule and create a new one.';

  @override
  String get pricingOverrideFormPreviewLabel => 'Preview';

  @override
  String pricingOverrideFormPreviewPrompt(String base) {
    return 'Base $base · enter a value to see the effective price.';
  }

  @override
  String pricingOverrideFormPreviewDiscount(String delta, String base) {
    return '(saved $delta vs $base base)';
  }

  @override
  String pricingOverrideFormPreviewSurcharge(String delta, String base) {
    return '(+$delta vs $base base)';
  }

  @override
  String pricingOverrideFormSoftWarnPercent(String value) {
    return 'This is a +$value% surcharge. Double-check before saving.';
  }

  @override
  String get pricingOverrideFormSoftWarnFixed => 'This surcharge is more than 5× the base price. Double-check before saving.';

  @override
  String get pricingOverrideFormSaveNew => 'Create rule';

  @override
  String get pricingOverrideFormSaveEdit => 'Save changes';

  @override
  String get pricingOverrideFormDiscardTitle => 'Discard changes?';

  @override
  String get pricingOverrideFormDiscardBody => 'Your edits will be lost.';

  @override
  String get pricingOverrideFormDiscardKeep => 'Keep editing';

  @override
  String get pricingOverrideFormDiscardConfirm => 'Discard';

  @override
  String get pricingOverrideCreatedToast => 'Rule created';

  @override
  String get pricingOverrideUpdatedToast => 'Rule updated';

  @override
  String get pricingOverrideErrorWindow => 'The end time must be after the start time.';

  @override
  String get pricingOverrideErrorDay => 'Please pick a valid day of the week.';

  @override
  String get pricingOverrideErrorAdjustment => 'Please re-check the discount amount.';

  @override
  String get pricingOverrideErrorValidity => 'The end date must be after the start date.';

  @override
  String get pricingOverrideErrorCap => 'You\'ve reached the 50-rule limit on this service. Archive an old rule to free a slot.';

  @override
  String get pricingOverrideErrorNotFound => 'We couldn\'t find that pricing rule.';

  @override
  String get pricingOverrideErrorSaveFailed => 'We couldn\'t save the rule. Please try again.';

  @override
  String get pricingOverrideDayMonday => 'Monday';

  @override
  String get pricingOverrideDayTuesday => 'Tuesday';

  @override
  String get pricingOverrideDayWednesday => 'Wednesday';

  @override
  String get pricingOverrideDayThursday => 'Thursday';

  @override
  String get pricingOverrideDayFriday => 'Friday';

  @override
  String get pricingOverrideDaySaturday => 'Saturday';

  @override
  String get pricingOverrideDaySunday => 'Sunday';

  @override
  String get pricingOverrideDayShortMon => 'Mon';

  @override
  String get pricingOverrideDayShortTue => 'Tue';

  @override
  String get pricingOverrideDayShortWed => 'Wed';

  @override
  String get pricingOverrideDayShortThu => 'Thu';

  @override
  String get pricingOverrideDayShortFri => 'Fri';

  @override
  String get pricingOverrideDayShortSat => 'Sat';

  @override
  String get pricingOverrideDayShortSun => 'Sun';

  @override
  String get dailyReportTitle => 'Today\'s report';

  @override
  String get dailyReportHistoryTitle => 'Past reports';

  @override
  String get dailyReportNotificationTitle => 'Today\'s report is ready';

  @override
  String get dailyReportRefresh => 'Refresh';

  @override
  String get dailyReportRetry => 'Retry';

  @override
  String get dailyReportLoadFailed => 'We couldn\'t load the report.';

  @override
  String get dailyReportHistoryLoadFailed => 'We couldn\'t load history.';

  @override
  String get dailyReportRevenueLabel => 'Revenue';

  @override
  String get dailyReportBookingsCompleted => 'Completed';

  @override
  String get dailyReportBookingsNoShow => 'No-show';

  @override
  String get dailyReportBookingsCancelled => 'Cancelled';

  @override
  String get dailyReportBookingsConfirmedPastEnd => 'Confirmed past end';

  @override
  String get dailyReportComparisonTitle => 'Comparison';

  @override
  String get dailyReportComparisonYesterday => 'vs yesterday';

  @override
  String get dailyReportComparisonLastWeek => 'vs same day last week';

  @override
  String get dailyReportComparisonNoData => '—';

  @override
  String get dailyReportPerWorkerTitle => 'By staff';

  @override
  String get dailyReportPerServiceTitle => 'By service';

  @override
  String get dailyReportWorkerUnassigned => 'Unassigned';

  @override
  String get dailyReportTomorrowTitle => 'Tomorrow';

  @override
  String dailyReportTomorrowFirstBookingAt(String time) {
    return 'First booking at $time';
  }

  @override
  String dailyReportTomorrowCount(int count) {
    return '$count bookings';
  }

  @override
  String get dailyReportTomorrowGroupFlag => 'Includes group bookings';

  @override
  String get dailyReportTomorrowEmpty => 'No bookings tomorrow.';

  @override
  String get dailyReportFollowUpsTitle => 'Needs your attention';

  @override
  String get dailyReportFollowUpConfirmedPastEnd => 'Confirmed but never closed out';

  @override
  String get dailyReportFollowUpUnpaidBalance => 'Unpaid balance';

  @override
  String get dailyReportFollowUpNoShowNoAction => 'No-show — no note logged';

  @override
  String get dailyReportRegenerate => 'Re-generate';

  @override
  String get dailyReportRegenerateConfirmTitle => 'Re-generate this report?';

  @override
  String get dailyReportRegenerateConfirmBody => 'This rebuilds the report from the current data. The previous version is overwritten.';

  @override
  String get dailyReportRegenerateConfirmCancel => 'Cancel';

  @override
  String get dailyReportRegenerateConfirmAction => 'Re-generate';

  @override
  String get dailyReportRegenerated => 'Report updated.';

  @override
  String get dailyReportEmptyTitle => 'No report yet';

  @override
  String get dailyReportEmptyBody => 'No bookings recorded for this date. Tap Re-generate to build an empty report.';

  @override
  String get dailyReportHistoryEmpty => 'No past reports yet.';

  @override
  String get dailyReportErrorGeneric => 'We couldn\'t build the report. Please try again.';

  @override
  String get docsGettingStartedTitle => 'Iniziare';

  @override
  String get docsGettingStartedSubtitle => 'Impara le basi';

  @override
  String get docsGettingStartedWhatIsTitle => 'Cos\'è Aura In?';

  @override
  String get docsGettingStartedWhatIsSubtitle => 'Comprendi la piattaforma';

  @override
  String get docsGettingStartedWelcomeIntroContent => 'Aura In è un mercato mobile che connette professionisti dei servizi con i clienti. Che tu offra tagli di capelli, massaggi, servizi freelance o venda prodotti, questa piattaforma ti aiuta a far crescere la tua attività.';

  @override
  String get docsGettingStartedWhoUsesTitle => 'Chi usa Aura In?';

  @override
  String get docsGettingStartedWhoUsesContent => 'Due tipi di utenti alimentano la piattaforma:';

  @override
  String get docsGettingStartedWhoUsesProviders => 'Fornitori di servizi - Saloni, spa, barbieri, freelancer che offrono servizi';

  @override
  String get docsGettingStartedWhoUsesCustomers => 'Clienti - Persone che cercano e prenotano servizi nella loro zona';

  @override
  String get docsGettingStartedWhoUsesSellers => 'Venditori di prodotti - Negozi che vendono prodotti al dettaglio o articoli fatti a mano';

  @override
  String get docsGettingStartedHowItWorksTitle => 'Come funziona';

  @override
  String get docsGettingStartedHowItWorksContent => 'I fornitori di servizi creano un profilo, elencano i loro servizi con i prezzi e accettano prenotazioni dai clienti. I clienti cercano per posizione, navigano tra i servizi e prenotano gli appuntamenti. Tutto è gestito tramite l\'app.';

  @override
  String get docsGettingStartedThreeWaysTitle => 'Tre modi per usare Aura In';

  @override
  String get docsGettingStartedThreeWaysSubtitle => 'Scegli il tuo ruolo';

  @override
  String get docsGettingStartedOption1Title => 'Opzione 1: Sfoglia e prenota servizi (Cliente)';

  @override
  String get docsGettingStartedOption1Content => 'Cerca saloni, massoterapisti, barbieri o freelancer vicino a te. Visualizza i loro servizi, prezzi e disponibilità. Prenota gli appuntamenti direttamente tramite l\'app e paga in sicurezza.';

  @override
  String get docsGettingStartedGuestBookingTitle => 'Prenotazione ospite (nessun download dell\'app richiesto)';

  @override
  String get docsGettingStartedGuestBookingContent => 'Non vuoi scaricare l\'app? I fornitori di servizi possono condividere un link di prenotazione - puoi prenotare e pagare direttamente tramite quel link senza creare un account. I dettagli della tua prenotazione e la ricevuta saranno inviati a WhatsApp.';

  @override
  String get docsGettingStartedOption2Title => 'Opzione 2: Offri servizi (Proprietario negozio o Freelancer)';

  @override
  String get docsGettingStartedOption2Content => 'Crea un profilo di negozio o freelancer, elenca i tuoi servizi con prezzi e durata, imposta i tuoi orari di lavoro e gestisci le prenotazioni. Guadagna con ogni servizio prenotato.';

  @override
  String get docsGettingStartedOption3Title => 'Opzione 3: Vendi prodotti (Venditore di prodotti)';

  @override
  String get docsGettingStartedOption3Content => 'Se fabbrichi articoli fatti a mano o vendi prodotti al dettaglio, puoi metterli in vendita. I clienti navigano e acquistano direttamente dal tuo negozio.';

  @override
  String get docsGettingStartedBookingPaymentTitle => 'Sistema di prenotazione e pagamento';

  @override
  String get docsGettingStartedBookingPaymentSubtitle => 'Come funzionano le prenotazioni di servizi e i pagamenti';

  @override
  String get docsGettingStartedBookingOverviewContent => 'I clienti prenotano appuntamenti con i fornitori di servizi. I pagamenti vengono elaborati in modo sicuro tramite l\'app utilizzando Paystack (Africa) o Stripe (Global).';

  @override
  String get docsGettingStartedDepositPaymentTitle => 'Deposito (30%)';

  @override
  String get docsGettingStartedDepositPaymentContent => 'Al prenotare un servizio, i clienti pagano il 30% in anticipo come deposito per garantire lo slot orario. Questo conferma che la prenotazione è reale e riservata.';

  @override
  String get docsGettingStartedPlatformFeeTitle => 'Commissione della piattaforma';

  @override
  String get docsGettingStartedPlatformFeeContent => 'Una piccola commissione della piattaforma (2%) viene aggiunta per aiutarci a mantenere la piattaforma e fornire supporto. Viene calcolata sull\'importo totale della prenotazione.';

  @override
  String get docsGettingStartedRemainingPaymentTitle => 'Pagamento residuo (70%)';

  @override
  String get docsGettingStartedRemainingPaymentContent => 'Il restante 70% può essere pagato in uno di due modi: (1) in contanti al termine del servizio, oppure (2) online tramite l\'app prima dell\'appuntamento.';

  @override
  String get docsGettingStartedGuestBookingPaymentTitle => 'Pagamento prenotazione ospite';

  @override
  String get docsGettingStartedGuestBookingPaymentContent => 'Nessun download dell\'app richiesto! I clienti ricevono un link di prenotazione dal fornitore di servizi. Pagano il 30% per garantire lo slot e la loro ricevuta viene inviata a WhatsApp.';

  @override
  String get docsGettingStartedProductOrderingTitle => 'Ordinazione e consegna di prodotti';

  @override
  String get docsGettingStartedProductOrderingSubtitle => 'Come funziona la vendita di prodotti';

  @override
  String get docsGettingStartedProductOverviewContent => 'I clienti navigano tra i prodotti, aggiungono articoli al carrello e completano il checkout. I prodotti vengono consegnati alla posizione del cliente.';

  @override
  String get docsGettingStartedCODPaymentTitle => 'Pagamento alla consegna (COD)';

  @override
  String get docsGettingStartedCODPaymentContent => 'Per gli ordini di prodotti, il pagamento viene gestito come pagamento alla consegna. I clienti pagano il venditore al ricevimento degli articoli - nessun pagamento anticipato richiesto.';

  @override
  String get docsGettingStartedShareYourProfileTitle => 'Condividi il tuo profilo';

  @override
  String get docsGettingStartedShareYourProfileSubtitle => 'Facilita la ricerca da parte dei clienti';

  @override
  String get docsGettingStartedShareLinkContent => 'Come fornitore di servizi, ricevi un link di prenotazione unico. Condividilo su WhatsApp, social media o email. I clienti possono prenotare servizi senza scaricare l\'app.';

  @override
  String get docsGettingStartedCustomURLTitle => 'URL personalizzato (opzionale)';

  @override
  String get docsGettingStartedCustomURLContent => 'Puoi personalizzare il tuo slug di link di prenotazione (ad es. aura.in/glamour-salon invece di aura.in/abc123). Facilita la condivisione e il ricordo.';

  @override
  String get docsGettingStartedGetHelpTitle => 'Ottieni aiuto';

  @override
  String get docsGettingStartedGetHelpSubtitle => 'Dove trovare risposte';

  @override
  String get docsGettingStartedHelpDocumentationContent => 'Questa app ha documentazione completa per ogni funzione. Quando hai bisogno di aiuto, consulta la guida pertinente - ce n\'è una per il tuo ruolo e la funzione che stai utilizzando.';

  @override
  String get docsGettingStartedFAQ1Question => 'Cos\'è Aura In?';

  @override
  String get docsGettingStartedFAQ1Answer => 'Aura In è un mercato mobile per aziende basate su servizi. I clienti trovano e prenotano servizi (tagli di capelli, massaggi, ecc.), i fornitori di servizi gestiscono prenotazioni e ricavi, e i venditori di prodotti elencano articoli in vendita.';

  @override
  String get docsGettingStartedFAQ2Question => 'Devo pagare per usare l\'app?';

  @override
  String get docsGettingStartedFAQ2Answer => 'L\'app è gratuita da scaricare e usare. I fornitori di servizi pagano solo una piccola commissione quando i clienti pagano per i servizi. I processori di pagamento (Paystack/Stripe) applicano una commissione.';

  @override
  String get docsGettingStartedFAQ3Question => 'Qual è la differenza tra proprietario di negozio e freelancer?';

  @override
  String get docsGettingStartedFAQ3Answer => 'I proprietari di negozi hanno una posizione fissa con un team di lavoratori. I freelancer lavorano in modo indipendente e possono recarsi dai clienti. Scegli in base al tuo modello di business.';

  @override
  String get docsGettingStartedFAQ4Question => 'Come vengo pagato?';

  @override
  String get docsGettingStartedFAQ4Answer => 'Quando i clienti pagano per i servizi, il denaro va al tuo portafoglio. Puoi prelevare sul tuo conto bancario utilizzando Paystack (Africa) o Stripe (Global).';

  @override
  String get docsGettingStartedFAQ5Question => 'Le mie informazioni di pagamento sono sicure?';

  @override
  String get docsGettingStartedFAQ5Answer => 'Sì. Aura In utilizza Paystack e Stripe, processori di pagamento leader con sicurezza a livello bancario. Non vediamo mai i tuoi dettagli di pagamento.';

  @override
  String get docsGettingStartedFAQ6Question => 'Come faccio a sapere se i fornitori di servizi vicino a me sono affidabili?';

  @override
  String get docsGettingStartedFAQ6Answer => 'Ogni fornitore di servizi ha valutazioni e recensioni di clienti che hanno prenotato con loro. Leggi le recensioni prima di prenotare. Valutazioni alte significano servizio coerente e di qualità.';

  @override
  String get docsGettingStartedFAQ7Question => 'Posso prenotare senza scaricare l\'app?';

  @override
  String get docsGettingStartedFAQ7Answer => 'Sì! I fornitori di servizi condividono un link di prenotazione unico. Puoi prenotare direttamente tramite quel link senza scaricare l\'app. La tua ricevuta sarà inviata a WhatsApp.';

  @override
  String get docsGettingStartedFAQ8Question => 'Quanto pago in anticipo per le prenotazioni?';

  @override
  String get docsGettingStartedFAQ8Answer => 'Paghi il 30% dell\'importo totale del servizio in anticipo per garantire lo slot di prenotazione (più una commissione della piattaforma del 2%). Il restante 70% può essere pagato in contanti o online prima/al momento del servizio.';

  @override
  String get docsGettingStartedFAQ9Question => 'Come pago per i prodotti?';

  @override
  String get docsGettingStartedFAQ9Answer => 'I prodotti utilizzano il pagamento alla consegna (COD). Paghi il venditore al ricevimento degli articoli. Questo ti permette di verificare la qualità prima di pagare e funziona bene per le consegne locali.';

  @override
  String get docsGettingStartedFAQ10Question => 'Perché la commissione della piattaforma del 2%?';

  @override
  String get docsGettingStartedFAQ10Answer => 'La commissione della piattaforma ci aiuta a mantenere Aura In, elaborare i pagamenti, fornire supporto ai clienti e migliorare continuamente le funzioni per clienti e fornitori di servizi.';

  @override
  String get docsBookingStartedTitle => 'Primi passi con le prenotazioni';

  @override
  String get docsBookingStartedSubtitle => 'Una guida semplice per capire come funzionano le prenotazioni';

  @override
  String get docsBookingIntroTitle => 'Benvenuto al sistema di prenotazione';

  @override
  String get docsBookingIntroSubtitle => 'Tutto quello che devi sapere sulla prenotazione di servizi, che tu sia un cliente o un proprietario di negozio.';

  @override
  String get docsBookingWhatIsTitle => 'Cos\'è il sistema di prenotazione?';

  @override
  String get docsBookingWhatIsContent => 'Il sistema di prenotazione è la tua porta d\'accesso alla programmazione di servizi nei tuoi negozi preferiti. Che tu abbia bisogno di un taglio di capelli, una rasatura, trecce o qualsiasi altro servizio, il sistema rende facile prenotare appuntamenti a tua convenienza.';

  @override
  String get docsBookingWhoIsForTitle => 'Per chi è questa guida?';

  @override
  String get docsBookingWhoIsForContent => 'Questa guida è progettata per due tipi di utenti:';

  @override
  String get docsBookingWhoIsForClients => 'Clienti: Persone che desiderano prenotare servizi nei negozi';

  @override
  String get docsBookingWhoIsForGuests => 'Prenotatori ospiti: Persone che desiderano prenotare tramite un link senza creare un account';

  @override
  String get docsBookingWhoIsForOwners => 'Proprietari di negozi: Persone che gestiscono negozi, servizi e lavoratori';

  @override
  String get docsBookingGuestIntroTitle => 'Nuovo: Prenota senza scaricare l\'app';

  @override
  String get docsBookingGuestIntroContent => 'Nessun account? Nessun problema! Se un proprietario di negozio condivide un link di prenotazione con te, puoi prenotare direttamente senza scaricare l\'app. La tua ricevuta viene inviata a WhatsApp.';

  @override
  String get docsBookingWelcomeTip => 'Nessuna conoscenza tecnica richiesta! Questa guida utilizza un linguaggio semplice ed esempi reali per aiutarti a capire tutto.';

  @override
  String get docsBookingAccountTitle => 'Crea il tuo account (O prenota come ospite)';

  @override
  String get docsBookingAccountSubtitle => 'Inizia in pochi minuti - con o senza account';

  @override
  String get docsBookingTwoWaysTitle => 'Due modi per prenotare';

  @override
  String get docsBookingTwoWaysContent => 'Puoi prenotare in due modi:';

  @override
  String get docsBookingTwoWaysAccount => 'Con account: Scarica app, crea account, prenota in qualsiasi momento';

  @override
  String get docsBookingTwoWaysGuest => 'Come ospite: Usa link di prenotazione, nessuna app richiesta, ricevuta tramite WhatsApp';

  @override
  String get docsBookingAccountStepsTitle => 'Come creare un account';

  @override
  String get docsBookingAccountStepsContent => 'Segui questi semplici passaggi per creare il tuo account:';

  @override
  String get docsBookingAccountTypesTitle => 'Tipi di account';

  @override
  String get docsBookingAccountTypesContent => 'Esistono due tipi di account:';

  @override
  String get docsBookingAccountTypesClient => 'Account cliente: Per prenotare servizi nei negozi';

  @override
  String get docsBookingAccountTypesShop => 'Account proprietario di negozio: Per gestire il tuo negozio (richiede approvazione)';

  @override
  String get docsBookingGuestOptionTitle => 'Prenota come ospite (senza account)';

  @override
  String get docsBookingGuestOptionContent => 'Se qualcuno condivide un link di prenotazione con te, puoi prenotare direttamente senza creare un account. Fai semplicemente clic sul link e segui i passaggi. La tua ricevuta viene inviata al tuo WhatsApp.';

  @override
  String get docsBookingVerificationNote => 'Puoi sfogliare e prenotare senza un account utilizzando un link di prenotazione. La creazione di un account ti dà accesso alla cronologia delle prenotazioni, ai pagamenti salvati e ai premi fedeltà.';

  @override
  String get docsBookingFirstBookingTitle => 'La tua prima prenotazione';

  @override
  String get docsBookingFirstBookingSubtitle => 'Una rapida panoramica';

  @override
  String get docsBookingPaymentTitle => 'Come funziona il pagamento';

  @override
  String get docsBookingPaymentContent => 'Quando prenoti un servizio, ecco come funziona il pagamento:';

  @override
  String get docsBookingPaymentDeposit => 'Deposito del 30% richiesto: Per garantire la tua prenotazione, paghi il 30% del costo totale del servizio in anticipo';

  @override
  String get docsBookingPaymentNonRefundable => 'Non rimborsabile: Questo deposito non viene rimborsato se annulli o non ti presenti';

  @override
  String get docsBookingPaymentRemaining => 'Saldo rimanente: Il 70% rimanente viene pagato dopo il completamento del tuo servizio';

  @override
  String get docsBookingPaymentSecure => 'Pagamento sicuro: Tutti i pagamenti vengono elaborati in modo sicuro dai nostri partner di pagamento';

  @override
  String get docsBookingDepositNote => 'Il deposito del 30% ti protegge e protegge il negozio. Garantisce che il tuo slot sia riservato esclusivamente per te e compensa il lavoratore se annulli all\'ultimo minuto.';

  @override
  String get docsBookingBookingTip => 'Consiglio professionale: Prenota almeno 24 ore prima per ottenere la migliore selezione di fasce orarie, soprattutto per servizi popolari.';

  @override
  String get docsBookingAfterTitle => 'Dopo la tua prenotazione';

  @override
  String get docsBookingAfterSubtitle => 'Cosa succede dopo';

  @override
  String get docsBookingWhatsNextTitle => 'La tua prenotazione è confermata!';

  @override
  String get docsBookingWhatsNextContent => 'Ecco cosa puoi fare dopo la prenotazione:';

  @override
  String get docsBookingRemindersTitle => 'Promemoria di prenotazione';

  @override
  String get docsBookingRemindersContent => 'Riceverai promemoria presso:';

  @override
  String get docsBookingAfterServiceTitle => 'Dopo il tuo servizio';

  @override
  String get docsBookingAfterServiceContent => 'Una volta completato il tuo servizio:';

  @override
  String get docsPaymentTitle => 'Pagamento e commissioni spiegati';

  @override
  String get docsPaymentSubtitle => 'Come funzionano i depositi del 30%, le commissioni della piattaforma e le prenotazioni per ospiti';

  @override
  String get docsPaymentOverviewTitle => 'Come funziona il pagamento';

  @override
  String get docsPaymentOverviewSubtitle => 'Semplice, trasparente, sicuro';

  @override
  String get docsPaymentSummaryTitle => 'Pagamento a colpo d\'occhio';

  @override
  String get docsPaymentSummaryContent => 'Il nostro sistema di pagamento è progettato per essere equo per clienti e proprietari di negozi. Ecco la scomposizione semplice:';

  @override
  String get docsPaymentDeposit30 => 'Deposito del 30%: Pagato al momento della prenotazione per garantire il tuo appuntamento';

  @override
  String get docsPaymentPlatformFee => 'Commissione della piattaforma: Piccola commissione fissa (ad es. GHS 2) addebitata dall\'app';

  @override
  String get docsPaymentRemaining70 => 'Restante 70%: Pagato dopo il completamento del tuo servizio';

  @override
  String get docsPaymentTwoWays => 'Due modi per pagare il resto: Contanti o tramite app';

  @override
  String get docsPaymentQuickExampleTitle => 'Esempio veloce';

  @override
  String get docsPaymentQuickExampleContent => 'Costo del servizio: GHS 100\nAl momento della prenotazione: Paga GHS 30 (deposito) + GHS 2 (commissione) = GHS 32\nDopo il servizio: Paga GHS 70 (contanti o app)\nTotale al negozio: GHS 100\nCommissione della piattaforma: GHS 2';

  @override
  String get docsPaymentImportantNote => 'La commissione della piattaforma viene addebitata dall\'app, non dal negozio. Ci aiuta a mantenere la piattaforma e a offrirti una fantastica esperienza di prenotazione.';

  @override
  String get docsPaymentGuestBookingTitle => 'Prenotazione ospite (nessun download dell\'app)';

  @override
  String get docsPaymentGuestBookingContent => 'Non hai l\'app? Nessun problema! Puoi comunque prenotare tramite il link di prenotazione del tuo provider senza creare un account. Paghi lo stesso deposito del 30% + commissione della piattaforma, e la tua ricevuta viene inviata a WhatsApp.';

  @override
  String get docsDepositTitle => 'Il deposito del 30%';

  @override
  String get docsDepositSubtitle => 'Perché è necessario e come funziona';

  @override
  String get docsDepositWhyTitle => 'Perché richiediamo un deposito?';

  @override
  String get docsDepositWhyContent => 'Il deposito del 30% ti protegge e protegge il negozio:';

  @override
  String get docsDepositProtectsYou => 'Per te: Il tuo slot è garantito – nessun altro può prenotarlo';

  @override
  String get docsDepositProtectsShop => 'Per il negozio: I lavoratori vengono compensati se annulli all\'ultimo minuto';

  @override
  String get docsDepositProtectsEveryone => 'Per tutti: Riduce le assenze, mantenendo i prezzi equi';

  @override
  String get docsDepositCalcTitle => 'Come viene calcolato il deposito';

  @override
  String get docsDepositCalcContent => 'Il deposito è sempre il 30% del costo totale del servizio. Questo include:';

  @override
  String get docsDepositCalcSingle => 'Servizio singolo: 30% di quel prezzo di servizio';

  @override
  String get docsDepositCalcMultiple => 'Più servizi: 30% di tutti i servizi combinati';

  @override
  String get docsDepositCalcGroup => 'Prenotazioni di gruppo: 30% del totale per tutte le persone';

  @override
  String get docsDepositExamplesTitle => 'Esempi di deposito';

  @override
  String get docsDepositExamplesSingle => 'Servizio singolo:\nTaglio di capelli (GHS 45) → Deposito GHS 13,50';

  @override
  String get docsDepositExamplesMultiple => 'Più servizi:\nTaglio di capelli (GHS 45) + Rifinitore da barba (GHS 25) = GHS 70 totale\nDeposito: GHS 21';

  @override
  String get docsDepositExamplesGroup => 'Prenotazione di gruppo (3 persone):\n3 × Taglio di capelli (GHS 45 l\'uno) = GHS 135 totale\nDeposito: GHS 40,50';

  @override
  String get docsDepositRefundTitle => 'Politica di rimborso del deposito';

  @override
  String get docsDepositRefundContent => 'Il deposito del 30% non è rimborsabile. Questo significa:';

  @override
  String get docsDepositRefundCancel => 'Se annulli: Il deposito non viene restituito';

  @override
  String get docsDepositRefundNoShow => 'Se non ti presenti: Il deposito non viene restituito';

  @override
  String get docsDepositRefundReschedule => 'Se riprogrammi: Il deposito viene trasferito al nuovo orario';

  @override
  String get docsDepositRefundShop => 'Se il negozio annulla: Deposito completo rimborsato';

  @override
  String get docsDepositWarning => 'Assicurati di essere sicuro della tua prenotazione prima di pagare il deposito. Sebbene tu possa riprogrammare, il deposito non può essere rimborsato se annulli.';

  @override
  String get docsFeeTitle => 'Commissione della piattaforma';

  @override
  String get docsFeeSubtitle => 'La piccola commissione che mantiene l\'app in esecuzione';

  @override
  String get docsFeeWhatTitle => 'Qual è la commissione della piattaforma?';

  @override
  String get docsFeeWhatContent => 'La commissione della piattaforma è una piccola commissione fissa (ad es. GHS 2) che va all\'app, non al negozio. Copre:';

  @override
  String get docsFeeAppDev => 'Sviluppo e manutenzione dell\'app';

  @override
  String get docsFeeSupport => 'Supporto clienti e risoluzione delle controversie';

  @override
  String get docsFeeProcessing => 'Costi di elaborazione dei pagamenti';

  @override
  String get docsFeeFeatures => 'Nuove funzionalità e miglioramenti';

  @override
  String get docsFeeHowTitle => 'Come viene addebitata la commissione';

  @override
  String get docsFeeHowContent => 'Cose importanti da sapere sulla commissione della piattaforma:';

  @override
  String get docsFeeFixed => 'Importo fisso (non una percentuale) – ad es. GHS 2 per prenotazione';

  @override
  String get docsFeePerbooking => 'Addebitato una volta per prenotazione – non per servizio o persona';

  @override
  String get docsFeeNonRefundable => 'Non rimborsabile – anche se annulli';

  @override
  String get docsFeeShown => 'Chiaramente visualizzato prima di confermare il pagamento';

  @override
  String get docsFeeExamplesTitle => 'Esempi di commissione della piattaforma';

  @override
  String get docsFeeExamplesSingle => 'Una persona, un servizio: Commissione GHS 2';

  @override
  String get docsFeeExamplesMultiple => 'Una persona, più servizi: Commissione GHS 2 (ancora una prenotazione!)';

  @override
  String get docsFeeExamplesGroup => 'Famiglia di 4 che prenota insieme: Commissione GHS 2 (intero gruppo)';

  @override
  String get docsFeeExamplesSeparate => 'Confrontare con prenotazioni separate:\n4 prenotazioni separate = 4 × GHS 2 = GHS 8 in commissioni\n1 prenotazione di gruppo = Commissione GHS 2 – risparmi GHS 6!';

  @override
  String get docsFeeGroupTip => 'La prenotazione come gruppo ti fa risparmiare sulle commissioni! Invece di pagare la commissione della piattaforma per ogni persona, paghi solo una commissione per l\'intera prenotazione di gruppo.';

  @override
  String get docsPaymentRemainingTitle => 'Pagamento dei restanti 70%';

  @override
  String get docsPaymentRemainingSubtitle => 'Contanti o online - la tua scelta';

  @override
  String get docsPaymentRemainingOptionsTitle => 'Due opzioni di pagamento';

  @override
  String get docsPaymentRemainingOptionsContent => 'Dopo il completamento del tuo servizio, hai due modi per pagare il restante 70%:';

  @override
  String get docsPaymentCashOption => 'Contanti: Paga direttamente al negozio o al lavoratore';

  @override
  String get docsPaymentAppOption => 'Tramite app: Paga tramite l\'app utilizzando il tuo metodo di pagamento salvato';

  @override
  String get docsPaymentRemainingTip => 'Entrambi i metodi di pagamento sono ugualmente validi. Scegli quello più conveniente per te al momento del servizio.';

  @override
  String get docsCancellationTitle => 'Annullamenti e rimborsi';

  @override
  String get docsCancellationSubtitle => 'Cosa succede se devi annullare';

  @override
  String get docsCancellationInfoTitle => 'Politica di annullamento';

  @override
  String get docsCancellationInfoContent => 'Comprendi cosa succede quando annulli:';

  @override
  String get docsCancellationUpTo24 => 'Annulla fino a 24 ore prima: Il deposito e la commissione non sono rimborsabili';

  @override
  String get docsCancellationLessThan24 => 'Annulla meno di 24 ore prima: Stessa politica – deposito e commissione non rimborsabili';

  @override
  String get docsCancellationReschedule => 'Riprogramma invece: Il tuo deposito viene trasferito al nuovo orario (gratuito da riprogrammare)';

  @override
  String get docsCancellationNoShow => 'Non presentarsi: Deposito e commissione persi, e può influire sullo stato del tuo account';

  @override
  String get docsHowToBookTitle => 'Come prenotare servizi';

  @override
  String get docsHowToBookSubtitle => 'Una guida passo dopo passo per prenotare i tuoi appuntamenti';

  @override
  String get docsHowToBookOverviewTitle => 'Prenotazione a colpo d\'occhio';

  @override
  String get docsHowToBookOverviewSubtitle => 'Il processo di prenotazione in passaggi semplici';

  @override
  String get docsHowToBookTwoWaysTitle => 'Due modi per prenotare';

  @override
  String get docsHowToBookTwoWaysContent => 'Puoi prenotare in due modi:';

  @override
  String get docsHowToBookTwoWaysWithApp => 'Con account app: Scarica app, crea account, prenota in qualsiasi momento';

  @override
  String get docsHowToBookTwoWaysGuest => 'Come ospite: Usa link di prenotazione, nessuna app, ricevuta via WhatsApp';

  @override
  String get docsHowToBookStepsTitle => 'Il tuo percorso di prenotazione (Con account)';

  @override
  String get docsHowToBookStepsContent => 'Prenotare un servizio richiede solo pochi minuti. Ecco cosa farai:';

  @override
  String get docsHowToBookStep1 => 'Passaggio 1: Trova un negozio e sfoglia i servizi';

  @override
  String get docsHowToBookStep2 => 'Passaggio 2: Seleziona i tuoi servizi e quantità';

  @override
  String get docsHowToBookStep3 => 'Passaggio 3: Scegli il tuo lavoratore preferito (se disponibile)';

  @override
  String get docsHowToBookStep4 => 'Passaggio 4: Scegli una data e un\'ora';

  @override
  String get docsHowToBookStep5 => 'Passaggio 5: Paga deposito del 30% + piccola commissione per confermare';

  @override
  String get docsHowToBookStep6 => 'Passaggio 6: Dopo il servizio, paga il restante 70% in contanti o tramite app';

  @override
  String get docsHowToBookGuestTitle => 'Prenotazione ospite (nessuna app)';

  @override
  String get docsHowToBookGuestContent => 'Non hai l\'app? Se un negozio condivide un link di prenotazione con te, segui i passaggi sopra ma senza la necessità di creare un account. La tua conferma e ricevuta vanno al tuo WhatsApp.';

  @override
  String get docsHowToBookTimeTip => 'L\'intero processo di solito richiede meno di 2 minuti. Il tuo progresso viene salvato man mano che procedi, quindi puoi prenderti il tuo tempo.';

  @override
  String get docsBookingStep1Title => 'Passaggio 1: Trova il tuo negozio e servizi';

  @override
  String get docsBookingStep1Subtitle => 'Scopri il posto perfetto per le tue esigenze';

  @override
  String get docsBookingFindShopTitle => 'Come trovare un negozio';

  @override
  String get docsBookingFindShopContent => 'Puoi trovare negozi in diversi modi:';

  @override
  String get docsBookingFindShopHome => 'Schermata home: Sfoglia negozi consigliati vicino a te';

  @override
  String get docsBookingFindShopSearch => 'Ricerca: Cerca negozi o servizi specifici per nome';

  @override
  String get docsBookingFindShopCategories => 'Categorie: Filtra per tipo di servizio (Taglio, Trecce, Barba, ecc.)';

  @override
  String get docsBookingFindShopFavorites => 'Preferiti: Accesso rapido ai negozi che hai salvato';

  @override
  String get docsBookingBrowseServicesTitle => 'Sfoglia servizi';

  @override
  String get docsBookingBrowseServicesContent => 'Una volta selezionato un negozio, vedrai tutti i loro servizi disponibili. Ogni servizio mostra:';

  @override
  String get docsBookingServiceName => 'Nome del servizio (ad es., Taglio Afro, Trecce Box)';

  @override
  String get docsBookingServiceDuration => 'Durata (quanto tempo impiega)';

  @override
  String get docsBookingServicePrice => 'Prezzo (costo del servizio - va al negozio)';

  @override
  String get docsBookingServiceDescription => 'Descrizione (cosa è incluso)';

  @override
  String get docsBookingServiceWorker => 'Requisito del lavoratore (se puoi scegliere chi lo fa)';

  @override
  String get docsBookingServiceExampleTitle => 'Esempio';

  @override
  String get docsBookingServiceExampleContent => 'Servizio di taglio di capelli:\n• Nome: Taglio Afro\n• Durata: 1 ora\n• Prezzo: GHS 45 (pagato al negozio)\n• Descrizione: Taglio afro professionale con styling\n• Lavoratore: Puoi scegliere il tuo parrucchiere preferito';

  @override
  String get docsBookingStep2Title => 'Passaggio 2: Seleziona i tuoi servizi';

  @override
  String get docsBookingStep2Subtitle => 'Scegli cosa vuoi e quante persone';

  @override
  String get docsBookingSelectServicesTitle => 'Selezione dei servizi';

  @override
  String get docsBookingSelectServicesContent => 'Per selezionare un servizio, semplicemente toccalo. Lo vedrai evidenziato. Puoi selezionare più servizi contemporaneamente:';

  @override
  String get docsBookingSelectServicesTap => 'Tocca un servizio per selezionarlo';

  @override
  String get docsBookingSelectServicesCheckmark => 'I servizi selezionati mostrano un segno di spunta';

  @override
  String get docsBookingSelectServicesMultiple => 'Puoi selezionare più servizi (ad es., Taglio + Rifinitore da barba)';

  @override
  String get docsBookingSelectServicesDeselect => 'Tocca di nuovo per deselezionare';

  @override
  String get docsBookingGroupBookingTitle => 'Prenotazione per più persone';

  @override
  String get docsBookingGroupBookingContent => 'Se stai prenotando per un gruppo (come te e i tuoi figli), puoi aumentare la quantità:';

  @override
  String get docsBookingGroupBookingQuantity => 'Dopo aver selezionato un servizio, vedrai un pulsante + e -';

  @override
  String get docsBookingGroupBookingIncrease => 'Tocca + per aumentare il numero di persone';

  @override
  String get docsBookingGroupBookingPrice => 'Il prezzo si aggiorna automaticamente';

  @override
  String get docsBookingGroupBookingLimit => 'Viene mostrata la quantità massima (alcuni servizi hanno limiti)';

  @override
  String get docsBookingGroupExampleTitle => 'Esempio: Prenotazione familiare';

  @override
  String get docsBookingGroupExampleContent => 'Dad vuole tagli di capelli per se stesso e i suoi due figli:\n• Seleziona il servizio \"Taglio di capelli\"\n• Tocca + finché la quantità non mostra 3\n• Il prezzo totale mostra 3 × GHS 45 = GHS 135 (per il negozio)\n• Sceglierai i lavoratori per ogni persona in seguito';

  @override
  String get docsBookingQuantityTip => 'La funzione quantità è perfetta per famiglie, gruppi di amici o chiunque prenoti per più persone contemporaneamente.';

  @override
  String get docsGroupBookingsTitle => 'Prenotazioni di gruppo';

  @override
  String get docsGroupBookingsSubtitle => 'Come prenotare servizi per te e altri';

  @override
  String get docsGroupIntroTitle => 'Che cosa sono le prenotazioni di gruppo?';

  @override
  String get docsGroupIntroSubtitle => 'Prenotazione per famiglia, amici o gruppi resa semplice';

  @override
  String get docsGroupExplainedTitle => 'Prenotazione per più persone';

  @override
  String get docsGroupExplainedContent => 'Le prenotazioni di gruppo ti consentono di prenotare servizi per più di una persona alla volta. È perfetto per:';

  @override
  String get docsGroupExplainedFamilies => 'Famiglie: Genitori che prenotano tagli di capelli per se stessi e i loro figli';

  @override
  String get docsGroupExplainedFriends => 'Amici: Gruppo di amici che ottengono servizi insieme';

  @override
  String get docsGroupExplainedEvents => 'Eventi: Feste nuziali, compleanni o occasioni speciali';

  @override
  String get docsGroupExplainedColleagues => 'Colleghi: Team building o uscite di lavoro';

  @override
  String get docsGroupRealExampleTitle => 'Esempio della vita reale';

  @override
  String get docsGroupRealExampleContent => 'La famiglia Mensah ha bisogno di tagli di capelli:\n• Padre: Vuole un taglio fade\n• Madre: Vuole un ritaglio\n• Figlio (10): Vuole un taglio da bambino\n• Figlia (8): Vuole trecce\n\nInvece di fare 4 prenotazioni separate, possono prenotare tutto insieme in una sola volta!';

  @override
  String get docsGroupBenefitsTitle => 'Vantaggi della prenotazione di gruppo';

  @override
  String get docsGroupBenefitsContent => 'La prenotazione come gruppo ti offre:';

  @override
  String get docsGroupBenefitsTransaction => 'Una transazione: Pagare i depositi per tutti contemporaneamente';

  @override
  String get docsGroupBenefitsTiming => 'Orario coordinato: Tutti vengono serviti più o meno nello stesso momento';

  @override
  String get docsGroupBenefitsWorkers => 'Diversi lavoratori: Ogni persona può scegliere il proprio lavoratore preferito';

  @override
  String get docsGroupBenefitsManagement => 'Gestione semplificata: Visualizzare e gestire tutte le prenotazioni insieme';

  @override
  String get docsGroupBenefitsPlanning => 'Pianificazione migliore: Il negozio può prepararsi per il tuo gruppo';

  @override
  String get docsGroupTip => 'Le prenotazioni di gruppo sono perfette per le famiglie! Puoi prenotare per te e i tuoi figli in una sola volta, scegliendo diversi lavoratori per ogni persona. Nessun account? Usa un link di prenotazione condiviso dal negozio!';

  @override
  String get docsGroupHowTitle => 'Come effettuare una prenotazione di gruppo';

  @override
  String get docsGroupHowSubtitle => 'Guida passo dopo passo';

  @override
  String get docsGroupStep1Title => 'Passaggio 1: Seleziona il tuo servizio';

  @override
  String get docsGroupStep1Content => 'Inizia trovando un negozio e selezionando il servizio che desideri. Ad esempio, tocca \"Taglio di capelli\".';

  @override
  String get docsGroupStep2Title => 'Passaggio 2: Scegli la quantità';

  @override
  String get docsGroupStep2Content => 'Dopo aver selezionato un servizio, vedrai i pulsanti + e -. Usali per impostare quante persone hanno bisogno di questo servizio:';

  @override
  String get docsGroupStep2Plus => 'Tocca + per aumentare il numero';

  @override
  String get docsGroupStep2Minus => 'Tocca - per diminuire';

  @override
  String get docsGroupStep2Price => 'Il prezzo si aggiorna automaticamente';

  @override
  String get docsGroupStep2Max => 'Non puoi superare la quantità massima mostrata';

  @override
  String get docsGroupStep2ExampleTitle => 'Esempio';

  @override
  String get docsGroupStep2ExampleContent => 'Per una famiglia di 3 che ha bisogno di tagli di capelli:\n• Seleziona il servizio \"Taglio di capelli\"\n• Tocca + due volte (o fino a quando la quantità non mostra 3)\n• Il prezzo totale mostra: 3 × GHS 45 = GHS 135';

  @override
  String get docsGroupStep3Title => 'Passaggio 3: Ripeti per ogni servizio';

  @override
  String get docsGroupStep3Content => 'Se il tuo gruppo ha bisogno di servizi diversi (ad es. alcuni vogliono tagli, altri vogliono trecce), seleziona ogni servizio e imposta la quantità per ogni:';

  @override
  String get docsGroupStep3Haircut => 'Seleziona \"Taglio di capelli\" → imposta quantità 2';

  @override
  String get docsGroupStep3Braids => 'Seleziona \"Trecce\" → imposta quantità 1';

  @override
  String get docsGroupStep3Track => 'Il sistema tiene traccia di tutte le selezioni';

  @override
  String get docsGroupStep3ExampleTitle => 'Esempio: Servizi misti';

  @override
  String get docsGroupStep3ExampleContent => 'Famiglia di 4 con esigenze diverse:\n• Papà: Taglio di capelli (quantità 1)\n• Mamma: Ritaglio (quantità 1)\n• Figlio: Taglio da bambino (quantità 1)\n• Figlia: Trecce (quantità 1)\n\nTotale: 4 servizi, ma li hai prenotati tutti in una sola volta!';

  @override
  String get docsGroupStep4Title => 'Passaggio 4: Scegli i lavoratori per ogni persona';

  @override
  String get docsGroupStep4Content => 'Per i servizi che ti permettono di scegliere i lavoratori, vedrai un elenco di persone. Tocca ogni persona per assegnare il suo lavoratore:';

  @override
  String get docsGroupStep4Person1 => 'Persona 1: Scegli John (specialista del fade)';

  @override
  String get docsGroupStep4Person2 => 'Persona 2: Scegli Sarah (esperta di trecce)';

  @override
  String get docsGroupStep4Person3 => 'Persona 3: Scegli Michael (tagli da bambino)';

  @override
  String get docsGroupStep4Person4 => 'Persona 4: Scegli John (stesso lavoratore per più persone)';

  @override
  String get docsGroupStep4ExampleTitle => 'Esempio: Diversi lavoratori per diverse persone';

  @override
  String get docsGroupStep4ExampleContent => 'Famiglia di 3 che prenota tagli di capelli:\n• Persona 1 (Papà): Scegli John (specialista del fade)\n• Persona 2 (Figlio): Scegli Michael (bravissimo con i bambini)\n• Persona 3 (Figlia): Scegli Sarah (esperta di trecce)\n\nTutti e tre verranno serviti durante il tuo blocco di appuntamenti.';

  @override
  String get docsGroupStep5Title => 'Passaggio 5: Scegli la tua ora';

  @override
  String get docsGroupStep5Content => 'Quando selezioni una data e un\'ora, il sistema mostra slot che possono accogliere TUTTE le persone nel tuo gruppo:';

  @override
  String get docsGroupStep5Regular => 'Vista regolare: Mostra slot per ogni servizio separatamente';

  @override
  String get docsGroupStep5Combined => 'Vista combinata: Mostra solo slot in cui tutti possono essere serviti insieme';

  @override
  String get docsGroupStep5Duration => 'Durata: L\'ora mostrata include tutti i servizi per tutte le persone';

  @override
  String get docsGroupStep5ExampleTitle => 'Esempio: Calcolo del tempo';

  @override
  String get docsGroupStep5ExampleContent => 'Prenotazione familiare:\n• Taglio di capelli (45 min) × 2 persone = 90 min\n• Trecce (2 ore) × 1 persona = 120 min\n• Tempo buffer tra i servizi = 15 min\n• Tempo totale dell\'appuntamento: 3 ore 45 minuti\n\nIl sistema gestisce tutto questo automaticamente!';

  @override
  String get docsGroupStep6Title => 'Passaggio 6: Pagamento';

  @override
  String get docsGroupStep6Content => 'Per le prenotazioni di gruppo, paghi:';

  @override
  String get docsGroupStep6Deposit => 'Deposito del 30%: Calcolato sul TOTALE di tutti i servizi';

  @override
  String get docsGroupStep6Fee => 'Commissione della piattaforma: Piccola commissione fissa (ad es. GHS 2) - addebitata UNA SOLA VOLTA per l\'intero gruppo';

  @override
  String get docsGroupStep6Remaining => '70% rimanente: Pagato dopo il completamento di tutti i servizi';

  @override
  String get docsGroupStep6Options => 'Opzioni di pagamento: Contanti, carta, denaro mobile o pagamento tramite app';

  @override
  String get docsGroupStep6ExampleTitle => 'Esempio di pagamento';

  @override
  String get docsGroupStep6ExampleContent => 'Totale prenotazione familiare: GHS 400\n• Deposito alla prenotazione: GHS 120 (30% di GHS 400)\n• Commissione della piattaforma: GHS 2 (addebitata UNA SOLA VOLTA per l\'intero gruppo)\n• Totale da pagare ora: GHS 122\n• Rimanente dopo il servizio: GHS 280\n• Pagamento dopo: Contanti a lavoratore/negozio O tramite app (la tua scelta)';

  @override
  String get docsGroupPaymentFlexibility => 'Più opzioni di pagamento';

  @override
  String get docsGroupPaymentFlexibilityContent => 'Per il restante 70%, hai opzioni:';

  @override
  String get docsGroupPaymentFlexibilityAllCash => 'Tutto contanti: Tutti pagano in contanti quando il servizio è terminato';

  @override
  String get docsGroupPaymentFlexibilitySplit => 'Pagamenti divisi: Alcuni pagano in contanti, altri pagano tramite app';

  @override
  String get docsGroupPaymentFlexibilityMixed => 'Misto contanti e app: Pagare parte in contanti, parte tramite app';

  @override
  String get docsGroupPaymentFlexibilityIndividual => 'Pagamenti individuali tramite app: Ogni persona paga tramite app';

  @override
  String get docsGroupPaymentFlexibilityTip => 'Scegli cosa funziona meglio per il tuo gruppo!';

  @override
  String get docsGroupImportant => 'Il deposito e la commissione della piattaforma vengono calcolati sulla prenotazione di gruppo TOTALE, non per persona. Paghi una sola volta per l\'intero gruppo.';

  @override
  String get docsCreateShopTitle => 'Crea il Tuo Negozio';

  @override
  String get docsCreateShopSubtitle => 'Configura il tuo business';

  @override
  String get docsShopOverviewTitle => 'Primi passi con il tuo negozio';

  @override
  String get docsShopOverviewSubtitle => 'Scopri le basi della creazione del tuo profilo aziendale';

  @override
  String get docsWelcomeIntroTitle => 'Benvenuto nella tua dashboard negozio';

  @override
  String get docsWelcomeIntroContent => 'La creazione di un negozio su Aura In richiede solo pochi minuti. Aggiungerai le tue informazioni aziendali, fisserai i tuoi servizi e orari di lavoro, e sarai pronto ad accettare prenotazioni dai clienti.';

  @override
  String get docsSetupStepsTitle => 'Quello che configurerai';

  @override
  String get docsSetupStepsContent => 'Ecco cosa farai quando crei il tuo negozio:';

  @override
  String get docsSetupStepsShopName => 'Aggiungi il nome e il logo del tuo negozio';

  @override
  String get docsSetupStepsDescription => 'Scrivi una breve descrizione della tua azienda';

  @override
  String get docsSetupStepsType => 'Scegli il tipo di negozio (salone, barbiere, spa, ecc.)';

  @override
  String get docsSetupStepsLocation => 'Imposta la tua ubicazione e l\'indirizzo del servizio';

  @override
  String get docsSetupStepsHours => 'Aggiungi i tuoi orari di lavoro';

  @override
  String get docsSetupStepsServices => 'Crea i servizi che offri con i prezzi';

  @override
  String get docsSetupStepsContact => 'Aggiungi informazioni di contatto';

  @override
  String get docsSetupStepsPhotos => 'Carica foto e documenti';

  @override
  String get docsSetupTip => 'Il tuo lavoro viene salvato automaticamente mentre compili il modulo. Puoi tornare indietro in qualsiasi momento per continuare la modifica o pubblicare quando sei pronto.';

  @override
  String get docsBasicInfoTitle => 'Informazioni di base del negozio';

  @override
  String get docsBasicInfoSubtitle => 'Dì ai clienti chi sei';

  @override
  String get docsLogoTitle => 'Aggiungi il logo del tuo negozio';

  @override
  String get docsLogoContent => 'Il tuo logo è la prima cosa che vedono i clienti. Dovrebbe rappresentare chiaramente la tua azienda. Usa un\'immagine quadrata (ad es. 500x500 pixel) per i migliori risultati.';

  @override
  String get docsShopNameTitle => 'Nome negozio';

  @override
  String get docsShopNameContent => 'Inserisci il nome della tua azienda esattamente come desideri che i clienti lo vedano. Sii chiaro e professionale. Esempio: \"Studio acconciature di Maria\" o \"Barbiere della città\"';

  @override
  String get docsShopTypeTitle => 'Scegli il tipo di negozio';

  @override
  String get docsShopTypeContent => 'Seleziona il tipo di attività che gestisci. Questo aiuta i clienti a trovarti nella ricerca. I tipi disponibili includono:';

  @override
  String get docsShopTypeSalon => 'Salone di acconciature - per tagli di capelli, colorazione, styling';

  @override
  String get docsShopTypeBarber => 'Barbiere - per tagli di capelli e grooming da uomo';

  @override
  String get docsShopTypeSpa => 'Spa - per massaggi, trattamenti viso, servizi benessere';

  @override
  String get docsShopTypeBeauty => 'Servizi di bellezza - trucco, unghie e altri trattamenti di bellezza';

  @override
  String get docsShopTypeOther => 'Altri servizi - per attività non elencate sopra';

  @override
  String get docsDescriptionTitle => 'Descrizione negozio';

  @override
  String get docsDescriptionContent => 'Scrivi una breve descrizione del tuo negozio (100-200 parole). Dì ai clienti cosa ti rende speciale. Esempio: \"Siamo specializzati nella cura naturale dei capelli e nello styling moderno per tutti i tipi di capelli. Ambiente adatto alle famiglie con stilisti professionisti.\"';

  @override
  String get docsTermsTitle => 'Termini e Condizioni';

  @override
  String get docsTermsContent => 'Aggiungi le regole importanti che i clienti dovrebbero conoscere. Esempi: politica di cancellazione, restrizioni di età, requisiti di deposito, codice di abbigliamento o restrizioni sanitarie.';

  @override
  String get docsLocationTitle => 'Posizione e orari';

  @override
  String get docsLocationSubtitle => 'Dove i clienti possono trovarti e quando lavori';

  @override
  String get docsLocationIntroTitle => 'Imposta la tua ubicazione';

  @override
  String get docsLocationIntroContent => 'I clienti devono sapere dove trovarti. Puoi:';

  @override
  String get docsLocationPin => 'Fissa la tua posizione sulla mappa (trascina il marcatore)';

  @override
  String get docsLocationSearch => 'Cerca il tuo indirizzo nella casella di ricerca';

  @override
  String get docsLocationManual => 'Inserisci il tuo indirizzo manualmente';

  @override
  String get docsLocationAccuracy => 'Assicurati che la tua posizione sia accurata. I clienti la usano per trovarti e calcolare il tempo di viaggio.';

  @override
  String get docsWorkingHoursTitle => 'Imposta i tuoi orari di lavoro';

  @override
  String get docsWorkingHoursContent => 'I clienti possono prenotare solo quando sei aperto. Imposta i tuoi orari per ogni giorno della settimana.';

  @override
  String get docsHoursExampleTitle => 'Orario di esempio';

  @override
  String get docsHoursExampleContent => 'Lunedì - Venerdì: 9:00 - 18:00\nSabato: 10:00 - 16:00\nDomenica: Chiuso';

  @override
  String get docsHoursTip => 'Puoi impostare orari diversi per giorni diversi, oppure contrassegnare qualsiasi giorno come chiuso quando non lavori.';

  @override
  String get docsServicesTitle => 'Servizi e prezzi';

  @override
  String get docsServicesSubtitle => 'Dì ai clienti cosa offri e quanto costa';

  @override
  String get docsServicesIntroTitle => 'Aggiungi i tuoi servizi';

  @override
  String get docsServicesIntroContent => 'Ogni servizio è qualcosa che i clienti possono prenotare e pagare. Esempi: \"Taglio di capelli\", \"Colorazione capelli\", \"Massaggio\", \"Trattamento viso\".';

  @override
  String get docsServiceDetailsTitle => 'Per ogni servizio, aggiungi:';

  @override
  String get docsServiceDetailsContent => 'Quando crei un servizio, devi fornire:';

  @override
  String get docsServiceName => 'Nome servizio - quello che offri (ad es. \"Taglio di capelli\")';

  @override
  String get docsServiceDescription => 'Descrizione - brevi dettagli su cosa è incluso';

  @override
  String get docsServicePrice => 'Prezzo - quanto costa il servizio';

  @override
  String get docsServiceDuration => 'Durata - quanto tempo impiega (ad es. 30 minuti, 1 ora)';

  @override
  String get docsServiceCategory => 'Categoria - che tipo di servizio è';

  @override
  String get docsPricingTipTitle => 'Suggerimento sulla tariffazione';

  @override
  String get docsPricingTipContent => 'Sii chiaro con i tuoi prezzi. Puoi offrire diversi livelli di servizio (ad es. \"Taglio base\" vs \"Taglio premium\") a prezzi diversi.';

  @override
  String get docsDurationImportant => 'Imposta la durata con precisione. I clienti prenotano in base a questo tempo, e il personale deve sapere quanto tempo prenotare.';

  @override
  String get docsTeamTitle => 'Gestisci il tuo team';

  @override
  String get docsTeamSubtitle => 'Aggiungi i membri del personale e assegnali ai servizi';

  @override
  String get docsWorkersIntroTitle => 'Aggiungi il tuo personale';

  @override
  String get docsWorkersIntroContent => 'Se hai compagni di squadra che lavorano nel tuo negozio, puoi aggiungerli qui. Questo ti aiuta a gestire chi è disponibile per le prenotazioni.';

  @override
  String get docsAddWorkerTitle => 'Come aggiungere un membro del personale';

  @override
  String get docsAddWorkerContent => 'Quando aggiungi un lavoratore, hai bisogno:';

  @override
  String get docsFreelancerTitle => 'Diventa un Freelancer';

  @override
  String get docsFreelancerSubtitle => 'Lavora in modo indipendente';

  @override
  String get docsFreelancerOverviewTitle => 'Primi passi come freelancer';

  @override
  String get docsFreelancerOverviewSubtitle => 'Scopri come configurare il tuo profilo e iniziare ad accettare client';

  @override
  String get docsFreelancerWelcomeTitle => 'Benvenuto nel lavoro autonomo';

  @override
  String get docsFreelancerWelcomeContent => 'Come freelancer su Aura In, offri servizi direttamente ai clienti della tua zona. A differenza di un negozio tradizionale, lavori dalla tua posizione e puoi viaggiare per incontrare i clienti. Configura il tuo profilo in pochi minuti e inizia ad accettare prenotazioni.';

  @override
  String get docsFreelancerVsShopTitle => 'Freelancer vs Negozio: Qual è la differenza?';

  @override
  String get docsFreelancerVsShopContent => 'Ecco come funziona il lavoro autonomo:';

  @override
  String get docsFreelancerIndependent => 'Lavori in modo indipendente - non è richiesto un negozio fisso';

  @override
  String get docsFreelancerTravel => 'Puoi viaggiare verso i clienti nel tuo raggio prescelto';

  @override
  String get docsFreelancerHours => 'Stabilisci i tuoi orari e la tua disponibilità';

  @override
  String get docsFreelancerManage => 'Gestisci il tuo programma e i tuoi clienti';

  @override
  String get docsFreelancerBooking => 'I clienti ti prenotano direttamente per i servizi';

  @override
  String get docsFreelancerRequirementsTitle => 'Quello che ti serve';

  @override
  String get docsFreelancerRequirementsContent => 'Per iniziare come freelancer, hai bisogno di: il tuo nome, un tipo di professione (parrucchiere, terapeuta massaggi, ecc.), posizione, raggio di viaggio, servizi e i tuoi orari di lavoro. Una foto professionale aiuta i clienti a fidarsi di te.';

  @override
  String get docsProfileSetupTitle => 'Crea il tuo profilo';

  @override
  String get docsProfileSetupSubtitle => 'Dì ai clienti chi sei';

  @override
  String get docsProfilePhotoTitle => 'Aggiungi la tua foto profilo';

  @override
  String get docsProfilePhotoContent => 'Un ritratto professionale crea fiducia con i clienti. Usa una foto chiara e ben illuminata di te stesso. I clienti vogliono sapere con chi stanno prenotando.';

  @override
  String get docsYourNameTitle => 'Il tuo nome';

  @override
  String get docsYourNameContent => 'Inserisci il tuo nome completo esattamente come vuoi che i clienti lo vedano. Sii professionale e chiaro.';

  @override
  String get docsProfessionTypeTitle => 'Scegli la tua professione';

  @override
  String get docsProfessionTypeContent => 'Seleziona cosa fai. Esempi: Parrucchiere, Terapeuta del massaggio, Artista del trucco, Barbiere, Estetista o altri servizi specializzati.';

  @override
  String get docsBioDescriptionTitle => 'Scrivi la tua biografia';

  @override
  String get docsBioDescriptionContent => 'Scrivi una breve descrizione su di te e la tua esperienza (50-150 parole). Dì ai clienti cosa ti rende speciale. Esempio: \"Mi specializo nella cura naturale dei capelli con 5 anni di esperienza. Certificato in colorazione e styling.\"';

  @override
  String get docsTermsGuidelinesTitle => 'Aggiungi le tue linee guida';

  @override
  String get docsTermsGuidelinesContent => 'Condividi regole o politiche importanti. Esempi: restrizioni di età, politica di cancellazione, requisiti sanitari o istruzioni di preparazione.';

  @override
  String get docsServiceAreaTitle => 'Imposta la tua area di servizio';

  @override
  String get docsServiceAreaSubtitle => 'Definisci dove lavori';

  @override
  String get docsBaseLocationTitle => 'Imposta la tua posizione di base';

  @override
  String get docsBaseLocationContent => 'Questo è dove normalmente lavori. I clienti nel tuo raggio di viaggio possono prenotarti. Puoi fissare sulla mappa o cercare il tuo indirizzo.';

  @override
  String get docsTravelRadiusTitle => 'Raggio di viaggio';

  @override
  String get docsTravelRadiusContent => 'Fino a che punto sei disposto a viaggiare per incontrare i clienti? Impostalo in chilometri. Esempio: \"raggio di 5 km\" significa che i clienti fino a 5 km dalla tua posizione possono prenotarti.';

  @override
  String get docsMobileVsFixedTitle => 'Mobile o posizione fissa?';

  @override
  String get docsMobileVsFixedContent => 'Scegli se viaggiare verso i clienti o incontrarli in un\'unica posizione. Se sei mobile, i clienti possono richiederti a casa o in ufficio.';

  @override
  String get docsServiceAddressTip => 'I clienti vedranno il tuo raggio di viaggio durante la ricerca. Sii accurato in modo che sappiano se puoi servire la loro area.';

  @override
  String get docsToolsSetupTitle => 'Elenca i tuoi strumenti e attrezzature';

  @override
  String get docsToolsSetupSubtitle => 'Mostra ai clienti cosa porti';

  @override
  String get docsToolsIntroTitle => 'Che cosa sono gli strumenti?';

  @override
  String get docsToolsIntroContent => 'Gli strumenti sono l\'attrezzatura o le abilità che possiedi. Aiutano i clienti a capire cosa puoi fare e cosa aspettarsi.';

  @override
  String get docsToolExamplesTitle => 'Strumenti di esempio';

  @override
  String get docsToolExamplesContent => 'Per diverse professioni:';

  @override
  String get docsToolHairdresser => 'Parrucchiere: Asciugacapelli, piastra lisciante, arricciacapelli, forbici';

  @override
  String get docsToolMassage => 'Terapeuta del massaggio: Lettino da massaggio, pietre calde, oli aromaterapici';

  @override
  String get docsToolMakeup => 'Artista del trucco: Pennelli per trucco, aerografo, luce LED';

  @override
  String get docsToolBarber => 'Barbiere: Tosatrici elettriche, rasoio diritto, crema per la pettinatura';

  @override
  String get docsToolSelectionTitle => 'Selezione di strumenti';

  @override
  String get docsToolSelectionContent => 'Scegli tutti gli strumenti e le attrezzature che usi professionalmente. I clienti vogliono sapere che hai l\'equipaggiamento giusto per il loro servizio.';

  @override
  String get docsServicesSetupTitle => 'Servizi e prezzi';

  @override
  String get docsServicesSetupSubtitle => 'Dì ai clienti cosa offri';

  @override
  String get docsServiceBasicsTitle => 'Aggiungi i tuoi servizi';

  @override
  String get docsServiceBasicsContent => 'Ogni servizio è qualcosa che i clienti possono prenotare. Esempi: \"Taglio di capelli\", \"Massaggio corpo completo\", \"Applicazione trucco\".';

  @override
  String get docsServiceInfoTitle => 'Per ogni servizio, aggiungi:';

  @override
  String get docsServiceInfoContent => 'Tu hai bisogno:';

  @override
  String get docsServiceInfoName => 'Nome servizio - quello che stai offrendo';

  @override
  String get docsServiceInfoDescription => 'Descrizione - cosa è incluso';

  @override
  String get docsServiceInfoPrice => 'Prezzo - quanto costa';

  @override
  String get docsServiceInfoDuration => 'Durata - quanto tempo impiega (30 min, 1 ora, ecc.)';

  @override
  String get docsPricingStrategyTitle => 'Suggerimenti sulla tariffazione';

  @override
  String get docsPricingStrategyContent => 'Ricerca cosa altri addebitano per servizi simili nella tua zona. Prezzi in modo competitivo ma equo per il tuo livello di esperienza.';

  @override
  String get docsDurationImportanceFreelancer => 'Imposta la durata con precisione. È così che blocchi il tempo per ogni prenotazione. I clienti si basano su questo tempo.';

  @override
  String get docsHoursSetupTitle => 'Imposta la tua disponibilità';

  @override
  String get docsHoursSetupSubtitle => 'Quando sei disponibile a lavorare';

  @override
  String get docsHoursIntroTitle => 'Orari di lavoro';

  @override
  String get docsHoursIntroContent => 'I clienti possono prenotare solo durante i tempi che contrassegni come disponibili. Imposta i tuoi orari per ogni giorno della settimana.';

  @override
  String get docsFlexibleHoursTitle => 'Flessibile o rigido?';

  @override
  String get docsFlexibleHoursContent => 'Decidi tu. Se desideri orari coerenti, impostali. Se preferisci flessibilità, puoi regolare quotidianamente secondo necessità.';

  @override
  String get docsBlockTimeTip => 'Quando un cliente ti prenota, quel tempo viene bloccato nel tuo calendario. Imposta gli orari con saggezza per evitare conflitti.';

  @override
  String get docsContactCredentialsTitle => 'Informazioni di contatto e credenziali';

  @override
  String get docsContactCredentialsSubtitle => 'Aiuta i clienti a raggiungerti e genera fiducia';

  @override
  String get docsCreateProductTitle => 'Vendi prodotti online';

  @override
  String get docsCreateProductSubtitle => 'Elenca gli articoli in vendita e raggiungi i clienti nella tua area';

  @override
  String get docsProductOverviewTitle => 'Primi passi nella vendita di prodotti';

  @override
  String get docsProductOverviewSubtitle => 'Scopri come elencare e vendere articoli';

  @override
  String get docsProductWelcomeTitle => 'Benvenuto alla vendita di prodotti';

  @override
  String get docsProductWelcomeContent => 'Vendi prodotti fisici direttamente ai clienti della tua zona. Dagli articoli fatti a mano ai beni al dettaglio, puoi raggiungere i clienti che cercano quello che offri.';

  @override
  String get docsPhoneRequirementTitle => 'Ti serve un numero di telefono verificato';

  @override
  String get docsPhoneRequirementContent => 'Prima di poter iniziare a vendere prodotti, devi verificare il tuo numero di telefono. Questo è per la comunicazione con i clienti e per convalidare la tua identità.';

  @override
  String get docsAddPhoneNumberTitle => 'Come aggiungere il tuo numero di telefono';

  @override
  String get docsAddPhoneNumberContent => 'Vai alle impostazioni del tuo profilo e aggiungi il tuo numero di telefono. Riceverai un codice di verifica via SMS per confermame che è davvero il tuo numero. Questo richiede solo un minuto.';

  @override
  String get docsWhyPhoneVerifiedTitle => 'Perché la verifica del telefono?';

  @override
  String get docsWhyPhoneVerifiedContent => 'Un numero di telefono verificato crea fiducia nei clienti e ci consente di contattarti se ci sono problemi. Aiuta anche a prevenire le frodi.';

  @override
  String get docsPhoneImportant => 'Non puoi elencare prodotti finché non hai un numero di telefono verificato. Questo è obbligatorio per tutti i venditori.';

  @override
  String get docsProductBasicsTitle => 'Informazioni di base sul prodotto';

  @override
  String get docsProductBasicsSubtitle => 'Cosa dire ai clienti sul tuo prodotto';

  @override
  String get docsProductNameTitle => 'Nome del prodotto';

  @override
  String get docsProductNameContent => 'Inserisci il nome del tuo prodotto chiaramente. I clienti cercano per nome di prodotto, quindi sii specifico. Esempio: \"Portafoglio in pelle fatto a mano - Marrone\" invece di solo \"Portafoglio\".';

  @override
  String get docsProductDescriptionTitle => 'Descrizione del prodotto';

  @override
  String get docsProductDescriptionContent => 'Scrivi una descrizione dettagliata. Dì ai clienti cos\'è, di cosa è fatto, come usarlo e perché è buono. Sii onesto sulle condizioni (nuovo, usato, ricondizionato).';

  @override
  String get docsCategorySelectionTitle => 'Scegli una categoria';

  @override
  String get docsCategorySelectionContent => 'Seleziona la categoria giusta. I clienti sfogliano per categoria per trovare articoli, quindi l\'accuratezza è importante. Scegli la categoria più specifica disponibile.';

  @override
  String get docsProductConditionTitle => 'Condizione del prodotto';

  @override
  String get docsProductConditionContent => 'Sii chiaro sulle condizioni: Nuovo (mai usato), Come nuovo (usato una volta), Buono (leggero usura), Accettabile (usura visibile) o Come visto. L\'onestà crea fiducia.';

  @override
  String get docsPricingStockTitle => 'Prezzo e disponibilità';

  @override
  String get docsPricingStockSubtitle => 'Imposta il tuo prezzo e gestisci l\'inventario';

  @override
  String get docsPricingTitle => 'Imposta il tuo prezzo';

  @override
  String get docsPricingContent => 'Imposta un prezzo equo in base alle condizioni, al valore di mercato e alla domanda locale. I clienti possono vedere articoli simili, quindi i prezzi competitivi aiutano.';

  @override
  String get docsCurrencyTitle => 'Valuta';

  @override
  String get docsCurrencyContent => 'I prezzi sono visualizzati nella valuta del tuo negozio. Assicurati che la valuta del tuo negozio sia impostata correttamente prima di aggiungere prodotti.';

  @override
  String get docsStockQuantityTitle => 'Quantità in stock';

  @override
  String get docsStockQuantityContent => 'Inserisci quanti articoli hai. Quando il stock si esaurisce, il prodotto viene visualizzato come non disponibile. Aggiorna questo mentre vendi articoli.';

  @override
  String get docsStockTip => 'Mantieni lo stock accurato. I clienti si frustrano se ordinano qualcosa che è esaurito. Aggiorna regolarmente mentre vendi.';

  @override
  String get docsProductPhotosTitle => 'Foto del prodotto';

  @override
  String get docsProductPhotosSubtitle => 'Mostra ai clienti cosa stanno comprando';

  @override
  String get docsPhotosImportanceTitle => 'Le foto contano di più';

  @override
  String get docsPhotosImportanceContent => 'Le foto di buona qualità sono critiche. I clienti decidono se acquistare in base alle foto. Foto scadenti = meno vendite.';

  @override
  String get docsWhatPhotosTitle => 'Cosa fotografare';

  @override
  String get docsWhatPhotosContent => 'Scatta foto che mostrino il prodotto reale:';

  @override
  String get docsPhotoFull => 'Prodotto completo da più angoli';

  @override
  String get docsPhotoCloseups => 'Dettagli ravvicinati e qualità';

  @override
  String get docsPhotoCondition => 'Foto che mostrano le condizioni (se usate)';

  @override
  String get docsPhotoScale => 'Foto accanto a qualcosa per scala (come una moneta o una mano)';

  @override
  String get docsPhotoDamage => 'Foto di danni o usura (l\'onestà crea fiducia)';

  @override
  String get docsPhotoTipsTitle => 'Suggerimenti per la qualità delle foto';

  @override
  String get docsPhotoTipsContent => 'Usa la luce naturale. Scatta foto su uno sfondo pulito. Mostra i colori con precisione. Non utilizzare filtri che cambiano l\'aspetto del prodotto.';

  @override
  String get docsPhotoCountTitle => 'Quante foto?';

  @override
  String get docsPhotoCountContent => 'Carica almeno 3 foto chiare. Più foto aiutano i clienti a comprendere meglio il prodotto. Limitato a 10 foto per prodotto.';

  @override
  String get docsToolsTitle => 'Strumenti aziendali';

  @override
  String get docsToolsSubtitle => 'Funzionalità potenti per automatizzare, promuovere e gestire il tuo business';

  @override
  String get docsToolsOverviewTitle => 'Panoramica degli strumenti';

  @override
  String get docsToolsOverviewSubtitle => 'Cosa fa ogni strumento e come usarlo';

  @override
  String get docsToolsWelcomeTitle => 'Benvenuto negli strumenti aziendali';

  @override
  String get docsToolsWelcomeContent => 'La scheda Strumenti dispone di 8 funzionalità potenti per aiutarti ad automatizzare, promuovere e gestire il tuo business in modo più efficace. Ogni strumento risolve un problema commerciale specifico.';

  @override
  String get docsToolsListTitle => 'Strumenti disponibili';

  @override
  String get docsToolsListContent => 'Hai accesso a questi 8 strumenti:';

  @override
  String get docsToolsReminders => 'Promemoria automatici - Invia promemoria ai clienti';

  @override
  String get docsToolsPromotions => 'Gestione promozioni - Crea e gestisci gli sconti';

  @override
  String get docsToolsExport => 'Esporta report - Scarica i dati aziendali';

  @override
  String get docsToolsPayment => 'Impostazioni di pagamento - Configura come ricevi i pagamenti';

  @override
  String get docsToolsHours => 'Orari di apertura - Imposta il tuo orario di lavoro';

  @override
  String get docsToolsServices => 'Gestione servizi - Aggiungi e modifica i tuoi servizi';

  @override
  String get docsToolsLoyalty => 'Programma fedeltà - Premia i clienti fedeli';

  @override
  String get docsToolsBroadcasts => 'Trasmissioni - Invia messaggi ai tuoi clienti';

  @override
  String get docsRemindersTitle => '1. Promemoria automatici';

  @override
  String get docsRemindersSubtitle => 'Invia promemoria automatici ai clienti';

  @override
  String get docsReminderPurposeTitle => 'Cosa fa';

  @override
  String get docsReminderPurposeContent => 'Invia automaticamente messaggi di promemoria ai clienti prima delle loro prenotazioni. Riduce le mancate presentazioni e mantiene i clienti informati.';

  @override
  String get docsReminderBenefitsTitle => 'Vantaggi';

  @override
  String get docsReminderBenefitsContent => 'I promemoria automatici ti aiutano a:';

  @override
  String get docsReminderBenefitNoShow => 'Riduci le mancate presentazioni - i clienti hanno meno probabilità di dimenticare';

  @override
  String get docsReminderBenefitExperience => 'Migliora l\'esperienza del cliente - sanno quando arrivare';

  @override
  String get docsReminderBenefitTime => 'Risparmia tempo - nessuna necessità di chiamare o inviare messaggi manualmente';

  @override
  String get docsReminderBenefitReliability => 'Aumenta l\'affidabilità - i promemoria vengono inviati automaticamente';

  @override
  String get docsReminderSetupTitle => 'Come configurarlo';

  @override
  String get docsReminderSetupContent => 'Fai clic su \"Configura promemoria automatici\" per impostare l\'orario: invia promemoria 24 ore prima, 2 ore prima o il mattino dell\'appuntamento.';

  @override
  String get docsReminderImpact => 'I negozi che utilizzano promemoria automatici vedono il 20-30% meno di mancate presentazioni. Questo impatta direttamente le tue entrate.';

  @override
  String get docsPromosTitle => '2. Gestione promozioni';

  @override
  String get docsPromosSubtitle => 'Crea offerte speciali e sconti';

  @override
  String get docsPromosPurposeTitle => 'Cosa fa';

  @override
  String get docsPromosPurposeContent => 'Crea promozioni e sconti a tempo limitato. Offri percentuali di sconto, importi fissi di sconto o componenti aggiuntivi gratuiti per attirare più clienti.';

  @override
  String get docsPromosExamplesTitle => 'Idee promozionali';

  @override
  String get docsPromosExamplesContent => 'Puoi creare promozioni come:';

  @override
  String get docsPromosExample1 => '20% di sconto sui tagli di capelli lunedì';

  @override
  String get docsPromosExample2 => 'Olio da massaggio gratuito con qualsiasi prenotazione di massaggio';

  @override
  String get docsPromosExample3 => '50 di sconto su un pacchetto di servizio completo';

  @override
  String get docsPromosExample4 => 'Cliente per la prima volta: 30% di sconto';

  @override
  String get docsPromosExample5 => 'Bonus fedeltà: 5o servizio a metà prezzo';

  @override
  String get docsPromosStrategyTitle => 'Strategia promozionale';

  @override
  String get docsPromosStrategyContent => 'Usa le promozioni durante i periodi lenti per aumentare le prenotazioni. Tieni traccia di quali promozioni funzionano meglio attraverso la tua analisi.';

  @override
  String get docsExportTitle => '3. Esporta report';

  @override
  String get docsExportSubtitle => 'Scarica i tuoi dati per l\'analisi';

  @override
  String get docsExportPurposeTitle => 'Cosa fa';

  @override
  String get docsExportPurposeContent => 'Scarica report dettagliati dei dati aziendali in formato foglio di calcolo. Analizza prenotazioni, entrate, clienti e altro.';

  @override
  String get docsExportTypesTitle => 'Report disponibili';

  @override
  String get docsExportTypesContent => 'Puoi esportare:';

  @override
  String get docsExportBookings => 'Report di prenotazione - tutte le prenotazioni con dettagli';

  @override
  String get docsExportRevenue => 'Report sulle entrate - guadagni per intervallo di date';

  @override
  String get docsExportCustomers => 'Report clienti - il tuo elenco di clienti';

  @override
  String get docsExportServices => 'Report sui servizi - prestazioni per servizio';

  @override
  String get docsExportWorkers => 'Report dei lavoratori - metriche di performance del personale';

  @override
  String get docsExportUsesTitle => 'Perché esportare i dati?';

  @override
  String get docsExportUsesContent => 'Usa i dati esportati in Excel per analisi personalizzate, conservazione dei registri, scopi fiscali o per condividere con il tuo contabile.';

  @override
  String get docsTimeSlotsTitle => 'Slot temporali spiegati';

  @override
  String get docsTimeSlotsSubtitle => 'Comprendi come funzionano gli orari di prenotazione';

  @override
  String get docsTimeSlotsOverviewTitle => 'Quali sono gli slot temporali?';

  @override
  String get docsTimeSlotsOverviewSubtitle => 'Scopri come funziona il sistema di programmazione';

  @override
  String get docsTimeSlotsWelcomeTitle => 'Benvenuto negli slot temporali';

  @override
  String get docsTimeSlotsWelcomeContent => 'Gli slot temporali sono gli orari disponibili in cui i clienti possono prenotare i tuoi servizi. Comprendere come funzionano ti aiuta a gestire il tuo programma in modo efficiente.';

  @override
  String get docsTimeSlotsBasicsTitle => 'Nozioni di base sugli slot temporali';

  @override
  String get docsTimeSlotsBasicsContent => 'Ecco come funzionano gli slot temporali:';

  @override
  String get docsTimeSlotsPoint1 => 'Ogni servizio ha una durata (quanto tempo ci vuole)';

  @override
  String get docsTimeSlotsPoint2 => 'Imposti le tue ore disponibili (quando lavori)';

  @override
  String get docsTimeSlotsPoint3 => 'Il sistema crea slot temporali in base alla durata del servizio';

  @override
  String get docsTimeSlotsPoint4 => 'I clienti possono prenotare solo slot disponibili';

  @override
  String get docsTimeSlotsExampleTitle => 'Esempio: Creazione di slot temporali';

  @override
  String get docsTimeSlotsExampleContent => 'Se offri un taglio di capelli di 30 minuti e lavori dalle 9:00 alle 17:00:\n• 9:00 - 9:30 (Slot 1)\n• 9:30 - 10:00 (Slot 2)\n• 10:00 - 10:30 (Slot 3)\n...e così per tutto il giorno';

  @override
  String get docsTimeSlotsOverlapTitle => 'E se i servizi si sovrappongono?';

  @override
  String get docsTimeSlotsOverlapContent => 'Se hai più staff, ogni persona ha il proprio programma. Se lavori da solo, può prenotare solo un cliente alla volta — il sistema blocca automaticamente i tempi in conflitto.';

  @override
  String get docsTimeSlotsGapTitle => 'Impostazione di spazi tra i servizi';

  @override
  String get docsTimeSlotsGapContent => 'Puoi impostare il tempo buffer tra le prenotazioni. Esempio: 15 minuti di spazio dopo ogni taglio di capelli per la pulizia. Questo riduce gli slot disponibili ma ti dà lo spazio di respirare.';

  @override
  String get docsTimeSlotsGroupTitle => 'Prenotazioni di gruppo e slot temporali';

  @override
  String get docsTimeSlotsGroupContent => 'Per le prenotazioni di gruppo, il sistema trova orari che funzionano per TUTTE le persone del gruppo. Questo rende più difficile trovare slot disponibili, ma garantisce che tutti siano serviti insieme.';

  @override
  String get docsTimeSlotsBlockingTitle => 'Orario di blocco';

  @override
  String get docsTimeSlotsBlockingContent => 'Puoi bloccare manualmente il tempo per pranzo, pause o appuntamenti personali. Il tempo bloccato non verrà visualizzato come disponibile ai clienti.';

  @override
  String get docsTimeSlotsUtilizationTitle => 'Massimizzazione dei tuoi slot temporali';

  @override
  String get docsTimeSlotsUtilizationContent => 'Suggerimenti per utilizzare i tuoi slot in modo efficiente:\n• Abbina la durata del servizio alla realtà (non sottostimare)\n• Imposta spazi realistici tra i servizi\n• Usa il tempo buffer in modo strategico\n• Rivedi e regola in base al feedback dei clienti';

  @override
  String get docsGettingStartedWhatIsNanoembryo_title => 'What is Aura In?';

  @override
  String get docsGettingStartedWhatIsNanoembryo_subtitle => 'Understand the platform';

  @override
  String get docsGettingStartedWhatIsNanoembryo_welcomeIntroTitle => 'Welcome to Aura In';

  @override
  String get docsGettingStartedWhatIsNanoembryo_welcomeIntroContent => 'Aura In is a mobile marketplace connecting service professionals with customers. Whether you offer haircuts, massages, freelance services, or sell products, this platform helps you grow your business.';

  @override
  String get docsGettingStartedWhatIsNanoembryo_whoUsesAppTitle => 'Who Uses Aura In?';

  @override
  String get docsGettingStartedWhatIsNanoembryo_whoUsesAppContent => 'Two types of users power the platform:';

  @override
  String get docsGettingStartedWhatIsNanoembryo_whoUsesAppBullet1 => 'Service Providers - Salons, spas, barbers, freelancers who offer services';

  @override
  String get docsGettingStartedWhatIsNanoembryo_whoUsesAppBullet2 => 'Customers - People searching for and booking services in their area';

  @override
  String get docsGettingStartedWhatIsNanoembryo_whoUsesAppBullet3 => 'Product Sellers - Shops selling retail products or handmade items';

  @override
  String get docsGettingStartedWhatIsNanoembryo_howItWorksTitle => 'How It Works';

  @override
  String get docsGettingStartedWhatIsNanoembryo_howItWorksContent => 'Service providers create a profile, list their services with pricing, and accept bookings from customers. Customers search by location, browse services, and book appointments. Everything is managed through the app.';

  @override
  String get docsGettingStartedThreeUserTypes_title => 'Three Ways to Use Aura In';

  @override
  String get docsGettingStartedThreeUserTypes_subtitle => 'Choose your role';

  @override
  String get docsGettingStartedThreeUserTypes_optionCustomerTitle => 'Option 1: Browse & Book Services (Customer)';

  @override
  String get docsGettingStartedThreeUserTypes_optionCustomerContent => 'Search for salons, massage therapists, barbers, or freelancers near you. View their services, pricing, and availability. Book appointments directly through the app and pay securely.';

  @override
  String get docsGettingStartedThreeUserTypes_guestBookingTitle => 'Guest Booking (No App Download Needed)';

  @override
  String get docsGettingStartedThreeUserTypes_guestBookingContent => 'Don\'t want to download the app? Service providers can share a booking link - you can book and pay directly through that link without creating an account. Your booking details and receipt will be sent to your WhatsApp.';

  @override
  String get docsGettingStartedThreeUserTypes_optionProviderTitle => 'Option 2: Offer Services (Shop Owner or Freelancer)';

  @override
  String get docsGettingStartedThreeUserTypes_optionProviderContent => 'Create a shop or freelancer profile, list your services with pricing and duration, set your working hours, and manage bookings. Get paid for every service booked.';

  @override
  String get docsGettingStartedThreeUserTypes_optionSellerTitle => 'Option 3: Sell Products (Product Seller)';

  @override
  String get docsGettingStartedThreeUserTypes_optionSellerContent => 'If you make handmade items or sell products, you can list them for sale. Customers browse and purchase directly from your shop.';

  @override
  String get docsGettingStartedKeyFeatures_title => 'Platform Features';

  @override
  String get docsGettingStartedKeyFeatures_subtitle => 'What you can do';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewTitle => 'Core Platform Features';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewContent => 'Aura In includes everything you need to run a service business:';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet1 => 'Booking System - Customers book services, you manage calendar';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet2 => 'Secure Payments - Accept payments via Paystack or Stripe';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet3 => 'Real-time Chat - Communicate with customers before/after bookings';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet4 => 'Location-based Search - Customers find you by location using Google Maps';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet5 => 'Business Dashboard - Analytics, revenue tracking, client management';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet6 => 'Team Management - Add staff members and assign them to services';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet7 => 'Automated Reminders - Send appointment reminders to reduce no-shows';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet8 => 'Promotions & Loyalty - Run discounts and reward repeat customers';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet9 => 'Product Selling - List items for sale if you offer products';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet10 => 'Reviews & Ratings - Build trust through customer feedback';

  @override
  String get docsGettingStartedForCustomers_title => 'For Customers';

  @override
  String get docsGettingStartedForCustomers_subtitle => 'How to find and book services';

  @override
  String get docsGettingStartedForCustomers_customerStartTitle => 'Getting Started as a Customer';

  @override
  String get docsGettingStartedForCustomers_customerStartContent => 'Create an account, set your location, and start searching for services. You can view service providers near you, read reviews, check pricing, and book appointments.';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesTitle => 'Customer Capabilities';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesContent => 'As a customer, you can:';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesBullet1 => 'Search services by location (using Google Maps)';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesBullet2 => 'Filter by type of service, price range, or ratings';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesBullet3 => 'View detailed service provider profiles and reviews';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesBullet4 => 'Book appointments and select preferred staff member';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesBullet5 => 'Chat with providers before booking';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesBullet6 => 'Pay securely through the app';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesBullet7 => 'Receive appointment reminders';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesBullet8 => 'Rate and review services after completion';

  @override
  String get docsGettingStartedFaq1Q => 'What is Aura In?';

  @override
  String get docsGettingStartedFaq1A => 'Aura In is a mobile marketplace for service-based businesses. Customers find and book services (haircuts, massages, etc.), service providers manage bookings and revenue, and product sellers list items for sale.';

  @override
  String get docsGettingStartedFaq2Q => 'Do I need to pay to use the app?';

  @override
  String get docsGettingStartedFaq2A => 'The app is free to download and use. Service providers only pay a small commission when customers pay for services. Payment processors (Paystack/Stripe) take a fee.';

  @override
  String get docsGettingStartedFaq3Q => 'What is the difference between Shop Owner and Freelancer?';

  @override
  String get docsGettingStartedFaq3A => 'Shop owners have a fixed location with a team of workers. Freelancers work independently and can travel to clients. Choose based on your business model.';

  @override
  String get docsGettingStartedFaq4Q => 'How do I get paid?';

  @override
  String get docsGettingStartedFaq4A => 'When customers pay for services, money goes to your wallet. You can withdraw to your bank account using Paystack (Africa) or Stripe (Global).';

  @override
  String get docsGettingStartedFaq5Q => 'Is my payment information secure?';

  @override
  String get docsGettingStartedFaq5A => 'Yes. Aura In uses Paystack and Stripe, industry-leading payment processors with bank-level security. We never see your payment details.';

  @override
  String get docsCreateShopShopOverview_title => 'Getting Started with Your Shop';

  @override
  String get docsCreateShopShopOverview_subtitle => 'Learn the basics of creating your business profile';

  @override
  String get docsCreateShopShopOverview_welcomeIntroTitle => 'Welcome to Your Shop Dashboard';

  @override
  String get docsCreateShopShopOverview_welcomeIntroContent => 'Creating a shop on Aura In takes just a few minutes. You\'ll add your business information, set your services and working hours, and you\'re ready to accept bookings from customers.';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewTitle => 'What You\'ll Set Up';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewContent => 'Here\'s what you\'ll do when creating your shop:';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewBullet1 => 'Add your shop name and logo';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewBullet2 => 'Write a brief description of your business';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewBullet3 => 'Choose your shop type (salon, barber, spa, etc.)';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewBullet4 => 'Set your location and service address';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewBullet5 => 'Add your working hours';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewBullet6 => 'Create services you offer with pricing';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewBullet7 => 'Add contact information';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewBullet8 => 'Upload photos and documents';

  @override
  String get docsCreateShopShopOverview_saveProgressTipContent => 'Your work is saved automatically as you fill in the form. You can come back anytime to continue editing or publish when ready.';

  @override
  String get docsCreateShopBasicInfo_title => 'Basic Shop Information';

  @override
  String get docsCreateShopBasicInfo_subtitle => 'Tell customers who you are';

  @override
  String get docsCreateShopBasicInfo_logoSectionTitle => 'Add Your Shop Logo';

  @override
  String get docsCreateShopBasicInfo_logoSectionContent => 'Your logo is the first thing customers see. It should clearly represent your business. Use a square image (e.g., 500x500 pixels) for best results.';

  @override
  String get docsCreateShopBasicInfo_shopNameTitle => 'Shop Name';

  @override
  String get docsCreateShopBasicInfo_shopNameContent => 'Enter your business name exactly as you want customers to see it. Be clear and professional. Example: \"Marie\'s Hair Studio\" or \"City Barbershop\"';

  @override
  String get docsCreateShopBasicInfo_shopTypeTitle => 'Choose Your Shop Type';

  @override
  String get docsCreateShopBasicInfo_shopTypeContent => 'Select the type of business you run. This helps customers find you in search. Available types include:';

  @override
  String get docsCreateShopBasicInfo_shopTypeBullet1 => 'Hair Salon - for haircuts, coloring, styling';

  @override
  String get docsCreateShopBasicInfo_shopTypeBullet2 => 'Barber Shop - for men\'s haircuts and grooming';

  @override
  String get docsCreateShopBasicInfo_shopTypeBullet3 => 'Spa - for massages, facials, wellness services';

  @override
  String get docsCreateShopBasicInfo_shopTypeBullet4 => 'Beauty Services - makeup, nails, and other beauty treatments';

  @override
  String get docsCreateShopBasicInfo_shopTypeBullet5 => 'Other Services - for businesses not listed above';

  @override
  String get docsCreateShopBasicInfo_descriptionTitle => 'Shop Description';

  @override
  String get docsCreateShopBasicInfo_descriptionContent => 'Write a short description about your shop (100-200 words). Tell customers what makes you special. Example: \"We specialize in natural hair care and modern styling for all hair types. Family-friendly environment with professional stylists.\"';

  @override
  String get docsCreateShopBasicInfo_termsInfoTitle => 'Terms & Conditions';

  @override
  String get docsCreateShopBasicInfo_termsInfoContent => 'Add any important rules customers should know. Examples: cancellation policy, age restrictions, deposit requirements, dress code, or health restrictions.';

  @override
  String get docsCreateShopLocationSetup_title => 'Location & Hours';

  @override
  String get docsCreateShopLocationSetup_subtitle => 'Where customers can find you and when you work';

  @override
  String get docsCreateShopLocationSetup_locationIntroTitle => 'Set Your Location';

  @override
  String get docsCreateShopLocationSetup_locationIntroContent => 'Customers need to know where to find you. You can either:';

  @override
  String get docsCreateShopLocationSetup_locationIntroBullet1 => 'Pin your location on the map (drag the marker)';

  @override
  String get docsCreateShopLocationSetup_locationIntroBullet2 => 'Search for your address in the search box';

  @override
  String get docsCreateShopLocationSetup_locationIntroBullet3 => 'Enter your street address manually';

  @override
  String get docsCreateShopLocationSetup_locationAccuracyContent => 'Make sure your location is accurate. Customers use it to find you and calculate travel time.';

  @override
  String get docsCreateShopLocationSetup_workingHoursTitle => 'Set Your Working Hours';

  @override
  String get docsCreateShopLocationSetup_workingHoursContent => 'Customers can only book times when you\'re open. Set your hours for each day of the week.';

  @override
  String get docsCreateShopLocationSetup_hoursExampleTitle => 'Example Hours';

  @override
  String get docsCreateShopLocationSetup_hoursExampleContent => 'Monday - Friday: 9:00 AM to 6:00 PM\nSaturday: 9:00 AM to 5:00 PM\nSunday: Closed';

  @override
  String get docsCreateShopLocationSetup_hoursTipContent => 'You can set different hours for different days, or mark any day as closed when you\'re not working.';

  @override
  String get docsCreateShopServicesSetup_title => 'Services & Pricing';

  @override
  String get docsCreateShopServicesSetup_subtitle => 'Tell customers what you offer and how much it costs';

  @override
  String get docsCreateShopServicesSetup_servicesIntroTitle => 'Add Your Services';

  @override
  String get docsCreateShopServicesSetup_servicesIntroContent => 'Each service is something customers can book and pay for. Examples: \"Haircut\", \"Hair Color\", \"Massage\", \"Facial Treatment\".';

  @override
  String get docsCreateShopServicesSetup_serviceDetailsTitle => 'For Each Service, Add:';

  @override
  String get docsCreateShopServicesSetup_serviceDetailsContent => 'When you create a service, you need to provide:';

  @override
  String get docsCreateShopServicesSetup_serviceDetailsBullet1 => 'Service name - what you\'re offering (e.g., \"Haircut\")';

  @override
  String get docsCreateShopServicesSetup_serviceDetailsBullet2 => 'Description - brief details about what\'s included';

  @override
  String get docsCreateShopServicesSetup_serviceDetailsBullet3 => 'Price - how much the service costs';

  @override
  String get docsCreateShopServicesSetup_serviceDetailsBullet4 => 'Duration - how long it takes (e.g., 30 minutes, 1 hour)';

  @override
  String get docsCreateShopServicesSetup_serviceDetailsBullet5 => 'Category - what type of service it is';

  @override
  String get docsCreateShopServicesSetup_pricingTipTitle => 'Pricing Tip';

  @override
  String get docsCreateShopServicesSetup_pricingTipContent => 'Be clear with your prices. You can offer different service tiers (e.g., \"Basic Haircut\" vs \"Premium Haircut\") at different prices.';

  @override
  String get docsCreateShopServicesSetup_durationImportantContent => 'Set the duration accurately. Customers book based on this time, and staff need to know how long to reserve.';

  @override
  String get docsCreateShopFaq1Q => 'How long does it take to create a shop?';

  @override
  String get docsCreateShopFaq1A => 'Most businesses can set up a shop in 5-15 minutes. You just need your business name, location, at least one service, and working hours.';

  @override
  String get docsCreateShopFaq2Q => 'What do I need to start?';

  @override
  String get docsCreateShopFaq2A => 'You need: your business name, location address, shop type, at least one service with pricing, and your working hours. A logo and photos are optional but recommended.';

  @override
  String get docsCreateShopFaq3Q => 'Can I change things after publishing?';

  @override
  String get docsCreateShopFaq3A => 'Yes! You can edit everything after your shop is live. Go to \"My Shops\", click on your shop, and click \"Edit\". All changes take effect immediately.';

  @override
  String get docsCreateShopFaq4Q => 'Do I need team members to start?';

  @override
  String get docsCreateShopFaq4A => 'No. If you\'re a solo business, you can start immediately. You can add team members anytime from your shop settings.';

  @override
  String get docsFreelancerFreelancerOverview_title => 'Getting Started as a Freelancer';

  @override
  String get docsFreelancerFreelancerOverview_subtitle => 'Learn how to set up your profile and start taking clients';

  @override
  String get docsFreelancerFreelancerOverview_freelancerWelcomeTitle => 'Welcome to Freelancing';

  @override
  String get docsFreelancerFreelancerOverview_freelancerWelcomeContent => 'As a freelancer on Aura In, you offer services directly to customers in your area. Unlike a traditional shop, you work from your own location and can travel to meet clients. Set up your profile in just a few minutes and start accepting bookings.';

  @override
  String get docsFreelancerFreelancerOverview_freelancerVsShopTitle => 'Freelancer vs Shop: What\'s the Difference?';

  @override
  String get docsFreelancerFreelancerOverview_freelancerVsShopContent => 'Here\'s how freelancing works:';

  @override
  String get docsFreelancerFreelancerOverview_freelancerVsShopBullet1 => 'You work independently - no fixed storefront required';

  @override
  String get docsFreelancerFreelancerOverview_freelancerVsShopBullet2 => 'You can travel to clients within your chosen radius';

  @override
  String get docsFreelancerFreelancerOverview_freelancerVsShopBullet3 => 'You set your own hours and availability';

  @override
  String get docsFreelancerFreelancerOverview_freelancerVsShopBullet4 => 'You manage your own schedule and clients';

  @override
  String get docsFreelancerFreelancerOverview_freelancerVsShopBullet5 => 'Customers book you directly for services';

  @override
  String get docsFreelancerFreelancerOverview_freelancerRequirementsTitle => 'What You\'ll Need';

  @override
  String get docsFreelancerFreelancerOverview_freelancerRequirementsContent => 'To start as a freelancer, you need: your name, a profession type (hairdresser, massage therapist, etc.), location, travel radius, services, and your working hours. A professional photo helps customers trust you.';

  @override
  String get docsFreelancerProfileSetup_title => 'Create Your Profile';

  @override
  String get docsFreelancerProfileSetup_subtitle => 'Tell customers who you are';

  @override
  String get docsFreelancerProfileSetup_profilePhotoTitle => 'Add Your Profile Photo';

  @override
  String get docsFreelancerProfileSetup_profilePhotoContent => 'A professional headshot or portrait builds trust with customers. Use a clear, well-lit photo of yourself. Customers want to know who they\'re booking with.';

  @override
  String get docsFreelancerProfileSetup_yourNameTitle => 'Your Name';

  @override
  String get docsFreelancerProfileSetup_yourNameContent => 'Enter your full name exactly as you want customers to see it. Be professional and clear.';

  @override
  String get docsFreelancerProfileSetup_professionTypeTitle => 'Choose Your Profession';

  @override
  String get docsFreelancerProfileSetup_professionTypeContent => 'Select what you do. Examples: Hairdresser, Massage Therapist, Makeup Artist, Barber, Esthetician, or other specialized services.';

  @override
  String get docsFreelancerProfileSetup_bioDescriptionTitle => 'Write Your Bio';

  @override
  String get docsFreelancerProfileSetup_bioDescriptionContent => 'Write a short description about yourself and your experience (50-150 words). Tell customers what makes you unique. Example: \"I specialize in natural hair care with 5 years of experience. Certified in color and styling.\"';

  @override
  String get docsFreelancerProfileSetup_termsGuidelinesTitle => 'Add Your Guidelines';

  @override
  String get docsFreelancerProfileSetup_termsGuidelinesContent => 'Share any important rules or policies. Examples: age restrictions, cancellation policy, health requirements, or preparation instructions.';

  @override
  String get docsFreelancerServiceArea_title => 'Set Your Service Area';

  @override
  String get docsFreelancerServiceArea_subtitle => 'Define where you work';

  @override
  String get docsFreelancerServiceArea_baseLocationTitle => 'Set Your Base Location';

  @override
  String get docsFreelancerServiceArea_baseLocationContent => 'This is where you normally work from. Customers within your travel radius can book you. You can either pin on the map or search for your address.';

  @override
  String get docsFreelancerServiceArea_travelRadiusTitle => 'Travel Radius';

  @override
  String get docsFreelancerServiceArea_travelRadiusContent => 'How far are you willing to travel to meet clients? Set this in kilometers. Example: \"5 km radius\" means clients up to 5 km from your location can book you.';

  @override
  String get docsFreelancerServiceArea_mobileVsFixedTitle => 'Mobile or Fixed Location?';

  @override
  String get docsFreelancerServiceArea_mobileVsFixedContent => 'Choose whether you travel to clients or meet them at one location. If you\'re mobile, customers can request you at their home or office.';

  @override
  String get docsFreelancerServiceArea_serviceAddressTipContent => 'Customers will see your travel radius when searching. Be accurate so they know if you can serve their area.';

  @override
  String get docsFreelancerFaq1Q => 'What\'s the difference between a freelancer and a shop owner?';

  @override
  String get docsFreelancerFaq1A => 'A freelancer works independently, often traveling to clients. A shop owner has a fixed location. Freelancers are more flexible, shops are more established.';

  @override
  String get docsFreelancerFaq2Q => 'How do customers find me?';

  @override
  String get docsFreelancerFaq2A => 'Your profile appears in customer searches based on your location, profession, and services. A good photo and portfolio help you get found more.';

  @override
  String get docsFreelancerFaq3Q => 'Can I work for multiple platforms?';

  @override
  String get docsFreelancerFaq3A => 'Yes! You can set up profiles on multiple platforms. Just make sure your availability matches across all platforms.';

  @override
  String get docsFreelancerFaq4Q => 'How do payments work?';

  @override
  String get docsFreelancerFaq4A => 'Customers pay through the app. You receive payment to your account after the service is completed.';

  @override
  String get docsFreelancerFaq5Q => 'What if I need to cancel a booking?';

  @override
  String get docsFreelancerFaq5A => 'You can cancel before the booking time. Contact support if you need to reschedule. Be fair to customers - frequent cancellations hurt your rating.';
}
