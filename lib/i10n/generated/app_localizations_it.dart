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

  @override
  String get docsBookingStartedBookingIntro_title => 'Welcome to the Booking System';

  @override
  String get docsBookingStartedBookingIntro_subtitle => 'Everything you need to know about booking services, whether you\'re a client or a shop owner.';

  @override
  String get docsBookingStartedBookingIntro_whatIsBooking_title => 'What is the Booking System?';

  @override
  String get docsBookingStartedBookingIntro_whatIsBooking_content => 'The booking system is your gateway to scheduling services at your favorite shops. Whether you need a haircut, beard trim, braiding, or any other service, the system makes it easy to book appointments at your convenience.';

  @override
  String get docsBookingStartedBookingIntro_whoItsFor_title => 'Who is this guide for?';

  @override
  String get docsBookingStartedBookingIntro_whoItsFor_content => 'This guide is designed for two types of users:';

  @override
  String get docsBookingStartedBookingIntro_whoItsFor_bullet1 => 'Clients: People who want to book services at shops';

  @override
  String get docsBookingStartedBookingIntro_whoItsFor_bullet2 => 'Guest Bookers: People who want to book via a link without creating an account';

  @override
  String get docsBookingStartedBookingIntro_whoItsFor_bullet3 => 'Shop Owners: People who manage shops, services, and workers';

  @override
  String get docsBookingStartedBookingIntro_guestBookingIntro_title => 'New: Book Without Downloading the App';

  @override
  String get docsBookingStartedBookingIntro_guestBookingIntro_content => 'No account? No problem! If a shop owner shares a booking link with you, you can book directly without downloading the app. Your receipt is sent to WhatsApp.';

  @override
  String get docsBookingStartedBookingIntro_welcomeNote_content => 'No technical knowledge needed! This guide uses simple language and real examples to help you understand everything.';

  @override
  String get docsBookingStartedCreatingAccount_title => 'Creating Your Account (Or Booking as Guest)';

  @override
  String get docsBookingStartedCreatingAccount_subtitle => 'Get started in minutes - with or without an account';

  @override
  String get docsBookingStartedCreatingAccount_twoWaysToBook_title => 'Two Ways to Book';

  @override
  String get docsBookingStartedCreatingAccount_twoWaysToBook_content => 'You can book in two ways:';

  @override
  String get docsBookingStartedCreatingAccount_twoWaysToBook_bullet1 => 'With Account: Download app, create account, book anytime';

  @override
  String get docsBookingStartedCreatingAccount_twoWaysToBook_bullet2 => 'As Guest: Use booking link, no app needed, receipt via WhatsApp';

  @override
  String get docsBookingStartedCreatingAccount_accountSteps_title => 'How to Create an Account';

  @override
  String get docsBookingStartedCreatingAccount_accountSteps_content => 'Follow these simple steps to create your account:';

  @override
  String get docsBookingStartedCreatingAccount_accountSteps_bullet1 => 'Download the app from App Store or Google Play';

  @override
  String get docsBookingStartedCreatingAccount_accountSteps_bullet2 => 'Tap \"Sign Up\" on the welcome screen';

  @override
  String get docsBookingStartedCreatingAccount_accountSteps_bullet3 => 'Enter your email address and create a password';

  @override
  String get docsBookingStartedCreatingAccount_accountSteps_bullet4 => 'Add your name and profile picture (optional)';

  @override
  String get docsBookingStartedCreatingAccount_accountSteps_bullet5 => 'Verify your email address';

  @override
  String get docsBookingStartedCreatingAccount_accountSteps_bullet6 => 'You\'re ready to start booking!';

  @override
  String get docsBookingStartedCreatingAccount_accountTypes_title => 'Account Types';

  @override
  String get docsBookingStartedCreatingAccount_accountTypes_content => 'There are two types of accounts:';

  @override
  String get docsBookingStartedCreatingAccount_accountTypes_bullet1 => 'Client Account: For booking services at shops';

  @override
  String get docsBookingStartedCreatingAccount_accountTypes_bullet2 => 'Shop Owner Account: For managing your own shop (requires approval)';

  @override
  String get docsBookingStartedCreatingAccount_guestBookingOption_title => 'Booking as a Guest (No Account)';

  @override
  String get docsBookingStartedCreatingAccount_guestBookingOption_content => 'If someone shares a booking link with you, you can book directly without creating an account. Just click the link and follow the steps. Your receipt is sent to your WhatsApp.';

  @override
  String get docsBookingStartedCreatingAccount_verificationNote_content => 'You can browse and book without an account using a booking link. Creating an account gives you access to booking history, saved payments, and loyalty rewards.';

  @override
  String get docsBookingStartedFirstBooking_title => 'Your First Booking';

  @override
  String get docsBookingStartedFirstBooking_subtitle => 'A quick walkthrough';

  @override
  String get docsBookingStartedFirstBooking_bookingSteps_title => 'How to make your first booking';

  @override
  String get docsBookingStartedFirstBooking_bookingSteps_content => 'Here\'s what you\'ll do:';

  @override
  String get docsBookingStartedFirstBooking_bookingSteps_bullet1 => 'Find a shop you like';

  @override
  String get docsBookingStartedFirstBooking_bookingSteps_bullet2 => 'Browse their services';

  @override
  String get docsBookingStartedFirstBooking_bookingSteps_bullet3 => 'Select the services you want';

  @override
  String get docsBookingStartedFirstBooking_bookingSteps_bullet4 => 'Choose your preferred worker (if available)';

  @override
  String get docsBookingStartedFirstBooking_bookingSteps_bullet5 => 'Pick a date and time';

  @override
  String get docsBookingStartedFirstBooking_bookingSteps_bullet6 => 'Review and confirm your booking';

  @override
  String get docsBookingStartedFirstBooking_whatHappensNext_title => 'What happens after you book?';

  @override
  String get docsBookingStartedFirstBooking_whatHappensNext_content => 'Once you confirm your booking:';

  @override
  String get docsBookingStartedFirstBooking_whatHappensNext_bullet1 => 'You\'ll get an instant confirmation';

  @override
  String get docsBookingStartedFirstBooking_whatHappensNext_bullet2 => 'The booking appears in \"My Bookings\"';

  @override
  String get docsBookingStartedFirstBooking_whatHappensNext_bullet3 => 'You\'ll receive a reminder before your appointment';

  @override
  String get docsBookingStartedFirstBooking_whatHappensNext_bullet4 => 'The shop gets notified of your booking';

  @override
  String get docsBookingStartedFirstBooking_whatHappensNext_bullet5 => 'You can reschedule or cancel if plans change';

  @override
  String get docsBookingStartedFirstBooking_paymentProcess_title => 'How Payment Works';

  @override
  String get docsBookingStartedFirstBooking_paymentProcess_content => 'When you book a service, here\'s how payment works:';

  @override
  String get docsBookingStartedFirstBooking_paymentProcess_bullet1 => '30% Deposit Required: To secure your booking, you pay 30% of the total service cost upfront';

  @override
  String get docsBookingStartedFirstBooking_paymentProcess_bullet2 => 'Platform Fee: A small fixed fee (e.g., GHS 2) is added to help maintain the platform';

  @override
  String get docsBookingStartedFirstBooking_paymentProcess_bullet3 => 'Non-Refundable: Deposit and fee are non-refundable if you cancel or don\'t show up';

  @override
  String get docsBookingStartedFirstBooking_paymentProcess_bullet4 => 'Remaining 70%: Paid after service - either in cash or via app';

  @override
  String get docsBookingStartedFirstBooking_paymentProcess_bullet5 => 'Secure Payment: All payments are processed securely through our payment partners';

  @override
  String get docsBookingStartedFirstBooking_remainingPaymentOptions_title => 'Flexible Payment for Remaining Balance';

  @override
  String get docsBookingStartedFirstBooking_remainingPaymentOptions_content => 'After your service, you have options for paying the remaining 70%:';

  @override
  String get docsBookingStartedFirstBooking_remainingPaymentOptions_bullet1 => 'Pay in Cash: Hand cash directly to worker or shop counter';

  @override
  String get docsBookingStartedFirstBooking_remainingPaymentOptions_bullet2 => 'Pay via App: Use card, mobile money, or digital payment through the app';

  @override
  String get docsBookingStartedFirstBooking_remainingPaymentOptions_bullet3 => 'You choose: Either option is available at the time of service';

  @override
  String get docsBookingStartedFirstBooking_depositNote_content => 'The 30% deposit protects both you and the shop. It ensures your slot is reserved exclusively for you, and compensates the worker if you cancel last minute. The platform fee helps us maintain secure payments and customer support.';

  @override
  String get docsBookingStartedFirstBooking_bookingTip_content => 'Pro tip: Book at least 24 hours in advance for the best selection of time slots, especially for popular services.';

  @override
  String get docsBookingStartedNavigation_title => 'Finding Your Way Around';

  @override
  String get docsBookingStartedNavigation_subtitle => 'Key screens and what they do';

  @override
  String get docsBookingStartedNavigation_mainScreens_title => 'Main Screens';

  @override
  String get docsBookingStartedNavigation_mainScreens_content => 'The app has several key screens to help you navigate:';

  @override
  String get docsBookingStartedNavigation_mainScreens_bullet1 => 'Home: Discover shops and services near you';

  @override
  String get docsBookingStartedNavigation_mainScreens_bullet2 => 'Search: Find specific shops or services';

  @override
  String get docsBookingStartedNavigation_mainScreens_bullet3 => 'My Bookings: View and manage your appointments';

  @override
  String get docsBookingStartedNavigation_mainScreens_bullet4 => 'Profile: Your account settings and preferences';

  @override
  String get docsBookingStartedNavigation_mainScreens_bullet5 => 'Favorites: Save shops you love for quick access';

  @override
  String get docsBookingStartedNavigation_bookingFlow_title => 'The Booking Flow';

  @override
  String get docsBookingStartedNavigation_bookingFlow_content => 'When you start booking, you\'ll go through these steps:';

  @override
  String get docsBookingStartedNavigation_bookingFlow_bullet1 => 'Services: Choose what you want';

  @override
  String get docsBookingStartedNavigation_bookingFlow_bullet2 => 'Workers: Pick who you want (if applicable)';

  @override
  String get docsBookingStartedNavigation_bookingFlow_bullet3 => 'Time: Select your preferred date and time';

  @override
  String get docsBookingStartedNavigation_bookingFlow_bullet4 => 'Confirm: Review and finalize your booking';

  @override
  String get docsBookingStartedNavigation_navigationTip_content => 'You can always go back to previous steps using the back button. Your selections are saved as you move through the flow.';

  @override
  String get docsBookingStartedBasics_title => 'Booking Basics';

  @override
  String get docsBookingStartedBasics_subtitle => 'Key concepts explained simply';

  @override
  String get docsBookingStartedBasics_keyTerms_title => 'Important Terms to Know';

  @override
  String get docsBookingStartedBasics_keyTerms_content => 'Here are some terms you\'ll encounter:';

  @override
  String get docsBookingStartedBasics_keyTerms_bullet1 => 'Service: What you want done (haircut, braids, etc.)';

  @override
  String get docsBookingStartedBasics_keyTerms_bullet2 => 'Worker: The person who performs the service';

  @override
  String get docsBookingStartedBasics_keyTerms_bullet3 => 'Slot: A specific date and time for your appointment';

  @override
  String get docsBookingStartedBasics_keyTerms_bullet4 => 'Group Booking: Booking for multiple people at once';

  @override
  String get docsBookingStartedBasics_keyTerms_bullet5 => 'Buffer Time: Clean-up time between appointments (you won\'t see this)';

  @override
  String get docsBookingStartedBasics_whatYouNeed_title => 'What You Need Before Booking';

  @override
  String get docsBookingStartedBasics_whatYouNeed_content => 'Before you start, have this information ready:';

  @override
  String get docsBookingStartedBasics_whatYouNeed_bullet1 => 'The service you want';

  @override
  String get docsBookingStartedBasics_whatYouNeed_bullet2 => 'Preferred date and time (flexibility helps!)';

  @override
  String get docsBookingStartedBasics_whatYouNeed_bullet3 => 'Number of people (if booking for a group)';

  @override
  String get docsBookingStartedBasics_whatYouNeed_bullet4 => 'Worker preference (if you have one)';

  @override
  String get docsBookingStartedBasics_depositExplained_title => 'Understanding the Deposit';

  @override
  String get docsBookingStartedBasics_depositExplained_content => 'Here\'s a real example of how the deposit works:';

  @override
  String get docsBookingStartedBasics_depositExample_title => 'Example';

  @override
  String get docsBookingStartedBasics_depositExample_content => 'Sarah books a haircut that costs GHS 100.\n• At booking: She pays GHS 30 (30% deposit)\n• After service: She pays GHS 70 (remaining balance)\n• Total paid: GHS 100\n\nIf Sarah cancels: She loses the GHS 30 deposit, but isn\'t charged the remaining GHS 70.\n\nIf Sarah doesn\'t show up: Same as cancellation - the GHS 30 deposit is kept.';

  @override
  String get docsBookingStartedBasics_depositTip_content => 'The deposit is applied toward your total bill. You\'re not paying extra - you\'re just paying part of it upfront to secure your spot.';

  @override
  String get docsBookingStartedBasics_basicsImportant_content => 'All times shown in the app are in your local timezone. No need to worry about timezone conversions!';

  @override
  String get docsBookingStartedFaq1Q => 'Can I book without an account?';

  @override
  String get docsBookingStartedFaq1A => 'You can browse shops and services without an account, but you\'ll need to sign up to actually book appointments. This helps us keep track of your bookings and send you reminders.';

  @override
  String get docsBookingStartedFaq2Q => 'Does it cost anything to use the booking system?';

  @override
  String get docsBookingStartedFaq2A => 'The booking system is completely free for clients. You only pay for the services you book. Shop owners pay a small commission on each booking.';

  @override
  String get docsBookingStartedFaq3Q => 'Can I book at multiple shops at the same time?';

  @override
  String get docsBookingStartedFaq3A => 'Yes! You can book appointments at different shops. Just make sure the times don\'t overlap if you\'re planning to attend them all yourself.';

  @override
  String get docsBookingStartedFaq4Q => 'Is the deposit refundable if I cancel?';

  @override
  String get docsBookingStartedFaq4A => 'No, the 30% deposit is non-refundable. This policy helps shops protect their time in case of last-minute cancellations or no-shows. You can cancel up to 24 hours before your appointment to avoid being charged the remaining 70%, but the deposit will not be refunded.';

  @override
  String get docsBookingStartedFaq5Q => 'Why 30%? Why not a fixed amount?';

  @override
  String get docsBookingStartedFaq5A => 'The 30% deposit scales with the cost of your service. For expensive services, the deposit is higher (protecting the shop more), and for cheaper services, it\'s lower (fairer for you). This percentage was chosen as a balanced approach that works for both clients and shops.';

  @override
  String get docsBookingStartedFaq6Q => 'If I book multiple services, do I pay 30% of the total?';

  @override
  String get docsBookingStartedFaq6A => 'Yes! The 30% deposit is calculated based on the total cost of all services you\'re booking. So if your total is GHS 200, you\'ll pay GHS 60 upfront, and the remaining GHS 140 after your appointment.';

  @override
  String get docsBookingStartedFaq7Q => 'What if I have a genuine emergency?';

  @override
  String get docsBookingStartedFaq7A => 'We understand that emergencies happen. While the deposit is officially non-refundable, you can contact the shop directly through the app to explain your situation. Some shops may offer credit toward a future booking at their discretion.';

  @override
  String get docsBookingStartedFaq8Q => 'Will I get reminders about my booking?';

  @override
  String get docsBookingStartedFaq8A => 'Yes! You\'ll receive reminders 24 hours before your appointment and again 1 hour before. You can adjust reminder settings in your profile.';

  @override
  String get docsBookingStartedFaq9Q => 'When do I pay for my booking?';

  @override
  String get docsBookingStartedFaq9A => 'Payment is handled at the time of booking. You can pay using credit card, debit card, or other payment methods available in your region.';

  @override
  String get docsBookingStartedFaq10Q => 'I own a shop. How do I get started?';

  @override
  String get docsBookingStartedFaq10A => 'Great! Create an account and select \"Shop Owner\" during signup. You\'ll need to provide some information about your shop and wait for approval. Once approved, you can start adding services and workers.';

  @override
  String get docsBookingStartedFaq11Q => 'Can I book without creating an account?';

  @override
  String get docsBookingStartedFaq11A => 'Yes! If a shop owner shares a booking link with you, you can book directly without an account. Just click the link and follow the booking steps. Your receipt is sent to your WhatsApp. You can create an account later if you want to track all your bookings in one place.';

  @override
  String get docsBookingStartedFaq12Q => 'What is the platform fee and why do I pay it?';

  @override
  String get docsBookingStartedFaq12A => 'The platform fee is a small fixed charge (e.g., GHS 2) added to your booking. It helps us maintain the app, process payments securely, provide customer support, and develop new features. Only one platform fee per booking, even for multiple services or people.';

  @override
  String get docsBookingStartedFaq13Q => 'Can I pay the remaining 70% in cash?';

  @override
  String get docsBookingStartedFaq13A => 'Yes! You have flexibility. You can pay the remaining 70% either in cash directly to the shop/worker, or through the app using your preferred payment method. The choice is yours at the time of service.';

  @override
  String get docsBookingStartedFaq14Q => 'As a guest, how do I get my booking details?';

  @override
  String get docsBookingStartedFaq14A => 'Your booking confirmation and receipt are sent to your WhatsApp number. You\'ll receive appointment reminders and can track everything through WhatsApp without downloading the app.';

  @override
  String get docsHowBooktitle => 'How to Book Services';

  @override
  String get docsHowBooksubtitle => 'How to Book Services';

  @override
  String get docsHowBookBookingOverview_title => 'Booking at a Glance';

  @override
  String get docsHowBookBookingOverview_subtitle => 'The booking process in simple steps';

  @override
  String get docsHowBookBookingOverview_twoBookingWays_title => 'Two Ways to Book';

  @override
  String get docsHowBookBookingOverview_twoBookingWays_content => 'You can book in two ways:';

  @override
  String get docsHowBookBookingOverview_twoBookingWays_bullet1 => '**With App Account:** Download app, create account, book anytime';

  @override
  String get docsHowBookBookingOverview_twoBookingWays_bullet2 => '**As Guest:** Use booking link, no app needed, receipt via WhatsApp';

  @override
  String get docsHowBookBookingOverview_bookingStepsOverview_title => 'Your Booking Journey (With Account)';

  @override
  String get docsHowBookBookingOverview_bookingStepsOverview_content => 'Booking a service takes just a few minutes. Here\'s what you\'ll do:';

  @override
  String get docsHowBookBookingOverview_bookingStepsOverview_bullet1 => '**Step 1:** Find a shop and browse services';

  @override
  String get docsHowBookBookingOverview_bookingStepsOverview_bullet2 => '**Step 2:** Select your services and quantities';

  @override
  String get docsHowBookBookingOverview_bookingStepsOverview_bullet3 => '**Step 3:** Choose your preferred worker (if available)';

  @override
  String get docsHowBookBookingOverview_bookingStepsOverview_bullet4 => '**Step 4:** Pick a date and time';

  @override
  String get docsHowBookBookingOverview_bookingStepsOverview_bullet5 => '**Step 5:** Pay 30% deposit + small fee to confirm';

  @override
  String get docsHowBookBookingOverview_bookingStepsOverview_bullet6 => '**Step 6:** After service, pay remaining 70% in cash or via app';

  @override
  String get docsHowBookBookingOverview_guestBookingNote_title => 'Guest Booking (No App)';

  @override
  String get docsHowBookBookingOverview_guestBookingNote_content => 'Don\'t have the app? If a shop shares a booking link with you, follow the same steps above but without needing to create an account. Your confirmation and receipt go to your WhatsApp.';

  @override
  String get docsHowBookBookingOverview_bookingTimeNote_content => 'The entire process usually takes less than 2 minutes. Your progress is saved as you go, so you can take your time.';

  @override
  String get docsHowBookStepOne_title => 'Step 1: Find Your Shop & Services';

  @override
  String get docsHowBookStepOne_subtitle => 'Discover the perfect place for your needs';

  @override
  String get docsHowBookStepOne_findShop_title => 'How to find a shop';

  @override
  String get docsHowBookStepOne_findShop_content => 'You can find shops in several ways:';

  @override
  String get docsHowBookStepOne_findShop_bullet1 => '**Home Screen:** Browse recommended shops near you';

  @override
  String get docsHowBookStepOne_findShop_bullet2 => '**Search:** Look for specific shops or services by name';

  @override
  String get docsHowBookStepOne_findShop_bullet3 => '**Categories:** Filter by service type (Haircut, Braiding, Beard, etc.)';

  @override
  String get docsHowBookStepOne_findShop_bullet4 => '**Favorites:** Quick access to shops you\'ve saved';

  @override
  String get docsHowBookStepOne_browseServices_title => 'Browsing Services';

  @override
  String get docsHowBookStepOne_browseServices_content => 'Once you select a shop, you\'ll see all their available services. Each service shows:';

  @override
  String get docsHowBookStepOne_browseServices_bullet1 => '**Service name** (e.g., \"Afro Haircut\", \"Box Braids\")';

  @override
  String get docsHowBookStepOne_browseServices_bullet2 => '**Duration** (how long it takes)';

  @override
  String get docsHowBookStepOne_browseServices_bullet3 => '**Price** (cost of the service - this goes to the shop)';

  @override
  String get docsHowBookStepOne_browseServices_bullet4 => '**Description** (what\'s included)';

  @override
  String get docsHowBookStepOne_browseServices_bullet5 => '**Worker requirement** (whether you can choose who does it)';

  @override
  String get docsHowBookStepOne_serviceExample_title => 'Example';

  @override
  String get docsHowBookStepOne_serviceExample_content => '**Haircut Service:**\n• Name: Afro Haircut\n• Duration: 1 hour\n• Price: GHS 45 (paid to shop)\n• Description: Professional afro haircut with styling\n• Worker: You can choose your preferred barber';

  @override
  String get docsHowBookStepTwo_title => 'Step 2: Select Your Services';

  @override
  String get docsHowBookStepTwo_subtitle => 'Choose what you want and how many people';

  @override
  String get docsHowBookStepTwo_selectServices_title => 'Selecting Services';

  @override
  String get docsHowBookStepTwo_selectServices_content => 'To select a service, simply tap on it. You\'ll see it become highlighted. You can select multiple services at once:';

  @override
  String get docsHowBookStepTwo_selectServices_bullet1 => 'Tap a service to select it';

  @override
  String get docsHowBookStepTwo_selectServices_bullet2 => 'Selected services show a checkmark';

  @override
  String get docsHowBookStepTwo_selectServices_bullet3 => 'You can select multiple services (e.g., Haircut + Beard Trim)';

  @override
  String get docsHowBookStepTwo_selectServices_bullet4 => 'Tap again to deselect';

  @override
  String get docsHowBookStepTwo_groupBooking_title => 'Booking for Multiple People';

  @override
  String get docsHowBookStepTwo_groupBooking_content => 'If you\'re booking for a group (like yourself and your children), you can increase the quantity:';

  @override
  String get docsHowBookStepTwo_groupBooking_bullet1 => 'After selecting a service, you\'ll see a **+** and **-** button';

  @override
  String get docsHowBookStepTwo_groupBooking_bullet2 => 'Tap **+** to increase the number of people';

  @override
  String get docsHowBookStepTwo_groupBooking_bullet3 => 'The price updates automatically';

  @override
  String get docsHowBookStepTwo_groupBooking_bullet4 => 'Maximum quantity is shown (some services have limits)';

  @override
  String get docsHowBookStepTwo_groupExample_title => 'Example: Family Booking';

  @override
  String get docsHowBookStepTwo_groupExample_content => '**Dad wants haircuts for himself and his two sons:**\n• Select \"Haircut\" service\n• Tap **+** until quantity shows 3\n• Total price shows 3 × GHS 45 = GHS 135 (for the shop)\n• You\'ll choose workers for each person later';

  @override
  String get docsHowBookStepTwo_quantityTip_content => 'The quantity feature is perfect for families, groups of friends, or anyone booking for multiple people at once.';

  @override
  String get docsHowBookStepThree_title => 'Step 3: Choose Your Workers';

  @override
  String get docsHowBookStepThree_subtitle => 'Pick who will perform your services';

  @override
  String get docsHowBookStepThree_workerSelection_title => 'When You Can Choose a Worker';

  @override
  String get docsHowBookStepThree_workerSelection_content => 'Some services let you choose your preferred worker, while others assign whoever is available:';

  @override
  String get docsHowBookStepThree_workerSelection_bullet1 => '**Services with worker choice:** You\'ll see a \"Choose Worker\" button';

  @override
  String get docsHowBookStepThree_workerSelection_bullet2 => '**Services without worker choice:** The system will assign an available worker';

  @override
  String get docsHowBookStepThree_workerSelection_bullet3 => '**Group bookings:** You can choose different workers for each person';

  @override
  String get docsHowBookStepThree_choosingWorker_title => 'How to Choose a Worker';

  @override
  String get docsHowBookStepThree_choosingWorker_content => 'If a service lets you choose a worker:';

  @override
  String get docsHowBookStepThree_choosingWorker_bullet1 => 'Tap \"Choose Worker\" for that service';

  @override
  String get docsHowBookStepThree_choosingWorker_bullet2 => 'You\'ll see a list of available workers';

  @override
  String get docsHowBookStepThree_choosingWorker_bullet3 => 'Each worker shows their name, photo, specialties, and rating';

  @override
  String get docsHowBookStepThree_choosingWorker_bullet4 => 'Tap on a worker to select them';

  @override
  String get docsHowBookStepThree_choosingWorker_bullet5 => 'For group bookings, you\'ll choose a worker for each person';

  @override
  String get docsHowBookStepThree_workerExample_title => 'Example: Group with Different Workers';

  @override
  String get docsHowBookStepThree_workerExample_content => '**Family of 3 booking haircuts:**\n• Person 1 (Dad): Choose John (fade specialist)\n• Person 2 (Son 1): Choose Michael (kids cuts)\n• Person 3 (Son 2): Choose Michael (same worker)\n• All three will be served during your appointment time';

  @override
  String get docsHowBookStepThree_workerTip_content => 'You can see each worker\'s availability in real-time. If your preferred worker isn\'t available at your desired time, you\'ll need to choose a different time or worker.';

  @override
  String get docsHowBookStepFour_title => 'Step 4: Pick Your Date & Time';

  @override
  String get docsHowBookStepFour_subtitle => 'Select when you want your appointment';

  @override
  String get docsHowBookStepFour_dateSelection_title => 'Choosing a Date';

  @override
  String get docsHowBookStepFour_dateSelection_content => 'First, pick your preferred date from the calendar:';

  @override
  String get docsHowBookStepFour_dateSelection_bullet1 => 'Dates with available slots are highlighted';

  @override
  String get docsHowBookStepFour_dateSelection_bullet2 => 'Past dates are greyed out';

  @override
  String get docsHowBookStepFour_dateSelection_bullet3 => 'Today is marked with \"Today\"';

  @override
  String get docsHowBookStepFour_dateSelection_bullet4 => 'You can scroll forward up to 30 days';

  @override
  String get docsHowBookStepFour_timeSelection_title => 'Two Ways to View Time Slots';

  @override
  String get docsHowBookStepFour_timeSelection_content => 'Once you pick a date, you\'ll see available time slots. You can switch between two views:';

  @override
  String get docsHowBookStepFour_timeSelection_bullet1 => '**Regular View:** Shows slots for each service separately';

  @override
  String get docsHowBookStepFour_timeSelection_bullet2 => '**Combined View:** Shows only slots where ALL your services can be booked together';

  @override
  String get docsHowBookStepFour_regularVsCombined_title => 'Regular vs Combined View';

  @override
  String get docsHowBookStepFour_regularVsCombined_content => '**Regular View Example (2 services):**\n• Haircut: 9:00 AM, 9:30 AM, 10:00 AM...\n• Beard Trim: 9:00 AM, 9:30 AM, 10:00 AM...\n\n**Combined View Example (same 2 services):**\n• 9:00 AM - 10:30 AM (both services together)\n• 9:30 AM - 11:00 AM\n• 10:00 AM - 11:30 AM';

  @override
  String get docsHowBookStepFour_viewSwitch_content => 'Use the toggle switch to switch between Regular and Combined view. Combined view is especially useful when booking multiple services.';

  @override
  String get docsHowBookStepFive_title => 'Step 5: Payment & Confirmation';

  @override
  String get docsHowBookStepFive_subtitle => 'Secure your booking with a 30% deposit';

  @override
  String get docsHowBookStepFive_paymentOverview_title => 'How Payment Works';

  @override
  String get docsHowBookStepFive_paymentOverview_content => 'To secure your booking, you\'ll pay a 30% deposit plus a small processing fee. Here\'s what you need to know:';

  @override
  String get docsHowBookStepFive_paymentOverview_bullet1 => '**30% Deposit:** Required at the time of booking (goes to the shop)';

  @override
  String get docsHowBookStepFive_paymentOverview_bullet2 => '**Processing Fee:** Small fixed fee charged by the platform (e.g., GHS 2 per booking)';

  @override
  String get docsHowBookStepFive_paymentOverview_bullet3 => '**Non-Refundable Deposit:** The 30% deposit is not refunded if you cancel or don\'t show up';

  @override
  String get docsHowBookStepFive_paymentOverview_bullet4 => '**Processing Fee Non-Refundable:** The platform fee is also non-refundable';

  @override
  String get docsHowBookStepFive_paymentOverview_bullet5 => '**Secure Processing:** All payments are encrypted and secure';

  @override
  String get docsHowBookStepFive_paymentExample_title => 'Payment Example';

  @override
  String get docsHowBookStepFive_paymentExample_content => '**Sarah books services totaling GHS 200:**\n• At booking: Pays GHS 60 (30% deposit for shop) + GHS 2 (platform fee) = GHS 62\n• After service: Pays remaining GHS 140 to the shop (in cash or via app)\n• Total paid: GHS 200 to shop + GHS 2 platform fee\n\n**If Sarah cancels:** She loses the GHS 60 deposit and GHS 2 fee\n**If Sarah doesn\'t show up:** Same as cancellation';

  @override
  String get docsHowBookStepFive_paymentStep_title => 'The Payment Screen';

  @override
  String get docsHowBookStepFive_paymentStep_content => 'On the confirmation screen, you\'ll see:';

  @override
  String get docsHowBookStepFive_paymentStep_bullet1 => '**Summary:** All services, quantities, and workers';

  @override
  String get docsHowBookStepFive_paymentStep_bullet2 => '**Total Price:** Full cost of all services (for the shop)';

  @override
  String get docsHowBookStepFive_paymentStep_bullet3 => '**Deposit Amount:** 30% payable now';

  @override
  String get docsHowBookStepFive_paymentStep_bullet4 => '**Platform Fee:** Small processing fee (e.g., GHS 2)';

  @override
  String get docsHowBookStepFive_paymentStep_bullet5 => '**Total Due Now:** Deposit + platform fee';

  @override
  String get docsHowBookStepFive_paymentStep_bullet6 => '**Remaining Balance:** 70% to pay after service (cash or app)';

  @override
  String get docsHowBookStepFive_paymentStep_bullet7 => '**Payment Methods:** Choose how to pay the deposit';

  @override
  String get docsHowBookStepFive_feeExplanation_title => 'Understanding the Platform Fee';

  @override
  String get docsHowBookStepFive_feeExplanation_content => 'The processing fee (e.g., GHS 2 per booking) is charged by the platform, not the shop. This fee helps us maintain the app and provide you with a great booking experience. The fee is:';

  @override
  String get docsHowBookStepFive_feeExplanation_bullet1 => '**Fixed amount** (not a percentage)';

  @override
  String get docsHowBookStepFive_feeExplanation_bullet2 => '**Charged once per booking** (not per service)';

  @override
  String get docsHowBookStepFive_feeExplanation_bullet3 => '**Non-refundable** even if you cancel';

  @override
  String get docsHowBookStepFive_feeExplanation_bullet4 => '**Clearly shown** before you confirm';

  @override
  String get docsHowBookStepFive_paymentImportant_content => 'The 30% deposit goes to the shop and is applied toward your total bill. The platform fee is separate and helps keep the app running. You\'re not paying extra to the shop - just paying part of your bill upfront.';

  @override
  String get docsHowBookStepFive_remainingPayment_title => 'Paying the Remaining 70%';

  @override
  String get docsHowBookStepFive_remainingPayment_content => 'After your service is complete, you have two options to pay the remaining balance:';

  @override
  String get docsHowBookStepFive_remainingPayment_bullet1 => '**Cash:** Pay the worker or shop directly';

  @override
  String get docsHowBookStepFive_remainingPayment_bullet2 => '**Via App:** Pay through the app using your preferred payment method';

  @override
  String get docsHowBookStepFive_remainingPayment_bullet3 => '**Receipt:** You\'ll get a receipt regardless of how you pay';

  @override
  String get docsHowBookStepFive_confirmation_title => 'After Payment';

  @override
  String get docsHowBookStepFive_confirmation_content => 'Once your deposit payment is successful:';

  @override
  String get docsHowBookStepFive_confirmation_bullet1 => 'You\'ll see a confirmation screen';

  @override
  String get docsHowBookStepFive_confirmation_bullet2 => 'The booking appears in \"My Bookings\"';

  @override
  String get docsHowBookStepFive_confirmation_bullet3 => 'You\'ll receive an email confirmation';

  @override
  String get docsHowBookStepFive_confirmation_bullet4 => 'The shop is notified of your booking';

  @override
  String get docsHowBookStepFive_confirmation_bullet5 => 'You\'ll get a reminder before your appointment';

  @override
  String get docsHowBookStepFive_paymentWarning_content => 'The 30% deposit and platform fee are non-refundable. Please be sure about your booking before confirming. You can reschedule up to 24 hours before, but the deposit and fee remain non-refundable.';

  @override
  String get docsHowBookAfterBooking_title => 'After You Book';

  @override
  String get docsHowBookAfterBooking_subtitle => 'What happens next';

  @override
  String get docsHowBookAfterBooking_whatsNext_title => 'Your Booking is Confirmed!';

  @override
  String get docsHowBookAfterBooking_whatsNext_content => 'Here\'s what you can do after booking:';

  @override
  String get docsHowBookAfterBooking_whatsNext_bullet1 => '**View Booking:** Check details in \"My Bookings\"';

  @override
  String get docsHowBookAfterBooking_whatsNext_bullet2 => '**Reschedule:** Change the time (up to 24 hours before)';

  @override
  String get docsHowBookAfterBooking_whatsNext_bullet3 => '**Cancel:** Cancel if needed (deposit and fee are non-refundable)';

  @override
  String get docsHowBookAfterBooking_whatsNext_bullet4 => '**Contact Shop:** Message the shop directly';

  @override
  String get docsHowBookAfterBooking_whatsNext_bullet5 => '**Add to Calendar:** Export to your phone\'s calendar';

  @override
  String get docsHowBookAfterBooking_reminders_title => 'Booking Reminders';

  @override
  String get docsHowBookAfterBooking_reminders_content => 'You\'ll receive reminders at:';

  @override
  String get docsHowBookAfterBooking_reminders_bullet1 => '**24 hours before:** Check you\'re still coming';

  @override
  String get docsHowBookAfterBooking_reminders_bullet2 => '**1 hour before:** Time to head to the shop';

  @override
  String get docsHowBookAfterBooking_reminders_bullet3 => '**After appointment:** Option to leave a review and pay remaining balance';

  @override
  String get docsHowBookAfterBooking_afterService_title => 'After Your Service';

  @override
  String get docsHowBookAfterBooking_afterService_content => 'Once your service is complete:';

  @override
  String get docsHowBookAfterBooking_afterService_bullet1 => '**Pay Remaining 70%:** In cash or through the app';

  @override
  String get docsHowBookAfterBooking_afterService_bullet2 => '**Rate Your Experience:** Leave a review for the shop and worker';

  @override
  String get docsHowBookAfterBooking_afterService_bullet3 => '**Tip Your Worker:** Optional tip can be added';

  @override
  String get docsHowBookAfterBooking_afterService_bullet4 => '**Book Again:** Easily rebook with the same shop or worker';

  @override
  String get docsHowBookAfterBooking_afterTip_content => 'Arrive 5-10 minutes before your appointment time to check in. This gives you time to settle in before your service starts.';

  @override
  String get docsHowBookFaq11 => 'How do I cancel a booking?';

  @override
  String get docsHowBookFaq21 => 'Go to \"My Bookings\", find the booking, and tap \"Cancel\". You can cancel up to 24 hours before the appointment. The 30% deposit and platform fee are non-refundable, but you won\'t be charged the remaining 70%.';

  @override
  String get docsHowBookFaq32 => 'Can I change my appointment time?';

  @override
  String get docsHowBookFaq42 => 'Yes! Go to \"My Bookings\", find your booking, and tap \"Reschedule\". You can choose a new time if available. The deposit and fee remain applied to your new booking.';

  @override
  String get docsHowBookFaq53 => 'Why do I need to pay a deposit?';

  @override
  String get docsHowBookFaq63 => 'The 30% deposit protects both you and the shop. It ensures your slot is reserved exclusively for you, and compensates the worker if you cancel last minute. The deposit goes toward your total bill.';

  @override
  String get docsHowBookFaq74 => 'What is the platform fee?';

  @override
  String get docsHowBookFaq84 => 'The platform fee (e.g., GHS 2 per booking) is a small fixed charge by the app, not the shop. It helps us maintain the platform and provide you with a smooth booking experience. The fee is clearly shown before you confirm.';

  @override
  String get docsHowBookFaq95 => 'Is the deposit ever refundable?';

  @override
  String get docsHowBookFaq105 => 'The deposit and platform fee are non-refundable by policy. However, in genuine emergency situations, you can contact the shop directly through the app. Some shops may offer credit toward a future booking at their discretion, but the platform fee cannot be refunded.';

  @override
  String get docsHowBookFaq116 => 'How do I pay the remaining 70%?';

  @override
  String get docsHowBookFaq126 => 'After your service, you have two options: pay in cash directly to the shop, or pay through the app using your preferred payment method. Both options are accepted at participating shops.';

  @override
  String get docsHowBookFaq137 => 'Can I book multiple services at once?';

  @override
  String get docsHowBookFaq147 => 'Absolutely! You can select multiple services (like haircut + beard trim) and book them together. The system will find time slots where all services can be done.';

  @override
  String get docsHowBookFaq158 => 'How do I book for multiple people?';

  @override
  String get docsHowBookFaq168 => 'After selecting a service, use the **+** button to increase the quantity. For example, if you\'re booking haircuts for yourself and two children, set quantity to 3. You can then choose different workers for each person.';

  @override
  String get docsHowBookFaq179 => 'Can I change my chosen worker after booking?';

  @override
  String get docsHowBookFaq189 => 'Yes, you can change your worker up to 24 hours before the appointment. Go to \"My Bookings\", find your booking, and look for the option to change worker. The new worker must be available at your booked time.';

  @override
  String get docsHowBookFaq191 => 'What payment methods are accepted for the deposit?';

  @override
  String get docsHowBookFaq201 => 'We accept various payment methods depending on your region, including credit/debit cards, mobile money, and bank transfers. Available options will be shown during checkout.';

  @override
  String get docsHowBookFaq211 => 'When should I use Combined View?';

  @override
  String get docsHowBookFaq221 => 'Use Combined View when you\'ve selected multiple services. It shows only time slots where all your services can be done together, saving you from trying to coordinate separate times.';

  @override
  String get docsHowBookFaq231 => 'What happens if I don\'t show up?';

  @override
  String get docsHowBookFaq241 => 'If you don\'t show up for your appointment, the 30% deposit and platform fee are kept. You may also be marked as a \"no-show\". Repeated no-shows may result in restrictions on your account.';

  @override
  String get docsHowBookFaq251 => 'Can I really pay the remaining amount in cash?';

  @override
  String get docsHowBookFaq261 => 'Yes! Many shops accept cash for the remaining 70%. You can also choose to pay through the app if you prefer. The choice is yours at the time of service.';

  @override
  String get docsHowBookFaq271 => 'Is the platform fee charged per service or per booking?';

  @override
  String get docsHowBookFaq281 => 'The platform fee is charged **per booking**, not per service. So whether you book one service or multiple services together, you pay the platform fee only once.';

  @override
  String get docsHowBookFaq291 => 'Can I book without creating an account?';

  @override
  String get docsHowBookFaq301 => 'Yes! If a shop shares a booking link with you, you can book directly without an account or downloading the app. Follow the same booking steps, and your confirmation and receipt are sent to your WhatsApp.';

  @override
  String get docsHowBookFaq1Q => 'How do I cancel a booking?';

  @override
  String get docsHowBookFaq1A => 'Go to \"My Bookings\", find the booking, and tap \"Cancel\". You can cancel up to 24 hours before the appointment. The 30% deposit and platform fee are non-refundable, but you won\'t be charged the remaining 70%.';

  @override
  String get docsHowBookFaq2Q => 'Can I change my appointment time?';

  @override
  String get docsHowBookFaq2A => 'Yes! Go to \"My Bookings\", find your booking, and tap \"Reschedule\". You can choose a new time if available. The deposit and fee remain applied to your new booking.';

  @override
  String get docsHowBookFaq3Q => 'Why do I need to pay a deposit?';

  @override
  String get docsHowBookFaq3A => 'The 30% deposit protects both you and the shop. It ensures your slot is reserved exclusively for you, and compensates the worker if you cancel last minute. The deposit goes toward your total bill.';

  @override
  String get docsHowBookFaq4Q => 'What is the platform fee?';

  @override
  String get docsHowBookFaq4A => 'The platform fee (e.g., GHS 2 per booking) is a small fixed charge by the app, not the shop. It helps us maintain the platform and provide you with a smooth booking experience. The fee is clearly shown before you confirm.';

  @override
  String get docsHowBookFaq5Q => 'Is the deposit ever refundable?';

  @override
  String get docsHowBookFaq5A => 'The deposit and platform fee are non-refundable by policy. However, in genuine emergency situations, you can contact the shop directly through the app. Some shops may offer credit toward a future booking at their discretion, but the platform fee cannot be refunded.';

  @override
  String get docsHowBookFaq6Q => 'How do I pay the remaining 70%?';

  @override
  String get docsHowBookFaq6A => 'After your service, you have two options: pay in cash directly to the shop, or pay through the app using your preferred payment method. Both options are accepted at participating shops.';

  @override
  String get docsHowBookFaq7Q => 'Can I book multiple services at once?';

  @override
  String get docsHowBookFaq7A => 'Absolutely! You can select multiple services (like haircut + beard trim) and book them together. The system will find time slots where all services can be done.';

  @override
  String get docsHowBookFaq8Q => 'How do I book for multiple people?';

  @override
  String get docsHowBookFaq8A => 'After selecting a service, use the **+** button to increase the quantity. For example, if you\'re booking haircuts for yourself and two children, set quantity to 3. You can then choose different workers for each person.';

  @override
  String get docsHowBookFaq9Q => 'Can I change my chosen worker after booking?';

  @override
  String get docsHowBookFaq9A => 'Yes, you can change your worker up to 24 hours before the appointment. Go to \"My Bookings\", find your booking, and look for the option to change worker. The new worker must be available at your booked time.';

  @override
  String get docsHowBookFaq10Q => 'What payment methods are accepted for the deposit?';

  @override
  String get docsHowBookFaq10A => 'We accept various payment methods depending on your region, including credit/debit cards, mobile money, and bank transfers. Available options will be shown during checkout.';

  @override
  String get docsHowBookFaq11Q => 'When should I use Combined View?';

  @override
  String get docsHowBookFaq11A => 'Use Combined View when you\'ve selected multiple services. It shows only time slots where all your services can be done together, saving you from trying to coordinate separate times.';

  @override
  String get docsHowBookFaq12Q => 'What happens if I don\'t show up?';

  @override
  String get docsHowBookFaq12A => 'If you don\'t show up for your appointment, the 30% deposit and platform fee are kept. You may also be marked as a \"no-show\". Repeated no-shows may result in restrictions on your account.';

  @override
  String get docsHowBookFaq13Q => 'Can I really pay the remaining amount in cash?';

  @override
  String get docsHowBookFaq13A => 'Yes! Many shops accept cash for the remaining 70%. You can also choose to pay through the app if you prefer. The choice is yours at the time of service.';

  @override
  String get docsHowBookFaq14Q => 'Is the platform fee charged per service or per booking?';

  @override
  String get docsHowBookFaq14A => 'The platform fee is charged **per booking**, not per service. So whether you book one service or multiple services together, you pay the platform fee only once.';

  @override
  String get docsHowBookFaq15Q => 'Can I book without creating an account?';

  @override
  String get docsHowBookFaq15A => 'Yes! If a shop shares a booking link with you, you can book directly without an account or downloading the app. Follow the same booking steps, and your confirmation and receipt are sent to your WhatsApp.';

  @override
  String get docsGroupBookingsIntro_title => 'What Are Group Bookings?';

  @override
  String get docsGroupBookingsIntro_subtitle => 'Booking for family, friends, or groups made simple';

  @override
  String get docsGroupBookingsHowTo_title => 'How to Make a Group Booking';

  @override
  String get docsGroupBookingsHowTo_subtitle => 'Step-by-step guide';

  @override
  String get docsGroupBookingsWorker_title => 'Worker Selection for Groups';

  @override
  String get docsGroupBookingsWorker_subtitle => 'How workers are assigned';

  @override
  String get docsGroupBookingsTime_title => 'Time Slots for Groups';

  @override
  String get docsGroupBookingsTime_subtitle => 'How appointment times work for groups';

  @override
  String get docsGroupBookingsPayment_title => 'Payment for Group Bookings';

  @override
  String get docsGroupBookingsPayment_subtitle => 'How deposits and fees work';

  @override
  String get docsGroupBookingsScenarios_title => 'Common Group Scenarios';

  @override
  String get docsGroupBookingsScenarios_subtitle => 'Real examples to help you understand';

  @override
  String get docsGroupBookingsIntro_explained_title => 'Booking for Multiple People';

  @override
  String get docsGroupBookingsIntro_explained_content => 'Group bookings allow you to book services for more than one person at a time. This is perfect for:';

  @override
  String get docsGroupBookingsIntro_explained_bullet1 => '**Families:** Parents booking haircuts for themselves and their children';

  @override
  String get docsGroupBookingsIntro_explained_bullet2 => '**Friends:** Group of friends getting services together';

  @override
  String get docsGroupBookingsIntro_explained_bullet3 => '**Events:** Bridal parties, birthdays, or special occasions';

  @override
  String get docsGroupBookingsIntro_explained_bullet4 => '**Colleagues:** Team building or work outings';

  @override
  String get docsGroupBookingsIntro_example_title => 'Real-Life Example';

  @override
  String get docsGroupBookingsIntro_example_content => '**The Mensah Family needs haircuts:**\n• Father: Wants a fade haircut\n• Mother: Wants a trim\n• Son (10): Wants a kids haircut\n• Daughter (8): Wants braids\n\nInstead of making 4 separate bookings, they can book everything together in one go!';

  @override
  String get docsGroupBookingsIntro_benefits_title => 'Benefits of Group Booking';

  @override
  String get docsGroupBookingsIntro_benefits_content => 'Booking as a group gives you:';

  @override
  String get docsGroupBookingsIntro_benefits_bullet1 => '**One transaction:** Pay deposits for everyone at once';

  @override
  String get docsGroupBookingsIntro_benefits_bullet2 => '**Coordinated timing:** Everyone gets served around the same time';

  @override
  String get docsGroupBookingsIntro_benefits_bullet3 => '**Different workers:** Each person can choose their preferred worker';

  @override
  String get docsGroupBookingsIntro_benefits_bullet4 => '**Simplified management:** View and manage all bookings together';

  @override
  String get docsGroupBookingsIntro_benefits_bullet5 => '**Better planning:** Shop can prepare for your group';

  @override
  String get docsGroupBookingsIntro_tip_content => 'Group bookings are perfect for families! You can book for yourself and your children in one go, choosing different workers for each person. No account needed? Use a booking link shared by the shop!';

  @override
  String get docsGroupBookingsHowTo_step1_title => 'Step 1: Select Your Service';

  @override
  String get docsGroupBookingsHowTo_step1_content => 'Start by finding a shop and selecting the service you want. For example, tap on \"Haircut\".';

  @override
  String get docsGroupBookingsHowTo_step2_title => 'Step 2: Choose the Quantity';

  @override
  String get docsGroupBookingsHowTo_step2_content => 'After selecting a service, you\'ll see **+** and **-** buttons. Use these to set how many people need this service:';

  @override
  String get docsGroupBookingsHowTo_step2_bullet1 => 'Tap **+** to increase the number';

  @override
  String get docsGroupBookingsHowTo_step2_bullet2 => 'Tap **-** to decrease';

  @override
  String get docsGroupBookingsHowTo_step2_bullet3 => 'The price updates automatically';

  @override
  String get docsGroupBookingsHowTo_step2_bullet4 => 'You cannot exceed the maximum quantity shown';

  @override
  String get docsGroupBookingsHowTo_step2Example_title => 'Example';

  @override
  String get docsGroupBookingsHowTo_step2Example_content => '**For a family of 3 needing haircuts:**\n• Select \"Haircut\" service\n• Tap **+** twice (or until quantity shows 3)\n• Total price shows: 3 × GHS 45 = GHS 135';

  @override
  String get docsGroupBookingsHowTo_step3_title => 'Step 3: Repeat for Each Service';

  @override
  String get docsGroupBookingsHowTo_step3_content => 'If your group needs different services (e.g., some want haircuts, others want braids), select each service and set the quantity for each:';

  @override
  String get docsGroupBookingsHowTo_step3_bullet1 => 'Select \"Haircut\" → set quantity 2';

  @override
  String get docsGroupBookingsHowTo_step3_bullet2 => 'Select \"Braids\" → set quantity 1';

  @override
  String get docsGroupBookingsHowTo_step3_bullet3 => 'The system keeps track of all selections';

  @override
  String get docsGroupBookingsHowTo_step3Example_title => 'Example: Mixed Services';

  @override
  String get docsGroupBookingsHowTo_step3Example_content => '**Family of 4 with different needs:**\n• Dad: Haircut (quantity 1)\n• Mom: Trim (quantity 1)\n• Son: Kids Haircut (quantity 1)\n• Daughter: Braids (quantity 1)\n\nTotal: 4 services, but you booked them all in one go!';

  @override
  String get docsGroupBookingsHowTo_step4_title => 'Step 4: Choose Workers for Each Person';

  @override
  String get docsGroupBookingsHowTo_step4_content => 'For services that let you choose workers, you\'ll see a list of people. Tap on each person to assign their worker:';

  @override
  String get docsGroupBookingsHowTo_step4_bullet1 => '**Person 1:** Choose John (fade specialist)';

  @override
  String get docsGroupBookingsHowTo_step4_bullet2 => '**Person 2:** Choose Sarah (braiding expert)';

  @override
  String get docsGroupBookingsHowTo_step4_bullet3 => '**Person 3:** Choose Michael (kids cuts)';

  @override
  String get docsGroupBookingsHowTo_step4_bullet4 => '**Person 4:** Choose John (same worker for multiple people)';

  @override
  String get docsGroupBookingsHowTo_step4Example_title => 'Example: Different Workers for Different People';

  @override
  String get docsGroupBookingsHowTo_step4Example_content => '**Family of 3 booking haircuts:**\n• Person 1 (Dad): Choose John (fade specialist)\n• Person 2 (Son): Choose Michael (great with kids)\n• Person 3 (Daughter): Choose Sarah (braiding expert)\n\nAll three will be served during your appointment block.';

  @override
  String get docsGroupBookingsHowTo_step5_title => 'Step 5: Pick Your Time';

  @override
  String get docsGroupBookingsHowTo_step5_content => 'When you select a date and time, the system will show slots that can accommodate ALL people in your group:';

  @override
  String get docsGroupBookingsHowTo_step5_bullet1 => '**Regular View:** Shows slots for each service separately';

  @override
  String get docsGroupBookingsHowTo_step5_bullet2 => '**Combined View:** Shows only slots where everyone can be served together';

  @override
  String get docsGroupBookingsHowTo_step5_bullet3 => '**Duration:** The time shown includes all services for all people';

  @override
  String get docsGroupBookingsHowTo_step5Example_title => 'Example: Time Calculation';

  @override
  String get docsGroupBookingsHowTo_step5Example_content => '**Family booking:**\n• Haircut (45 min) × 2 people = 90 min\n• Braids (2 hours) × 1 person = 120 min\n• Buffer time between services = 15 min\n• **Total appointment time: 3 hours 45 min**\n\nThe system handles all this automatically!';

  @override
  String get docsGroupBookingsHowTo_step6_title => 'Step 6: Payment';

  @override
  String get docsGroupBookingsHowTo_step6_content => 'For group bookings, you pay:';

  @override
  String get docsGroupBookingsHowTo_step6_bullet1 => '**30% deposit:** Calculated on the TOTAL cost of all services';

  @override
  String get docsGroupBookingsHowTo_step6_bullet2 => '**Platform fee:** Small fixed fee (e.g., GHS 2) - charged ONCE for entire group';

  @override
  String get docsGroupBookingsHowTo_step6_bullet3 => '**Remaining 70%:** Paid after all services are complete';

  @override
  String get docsGroupBookingsHowTo_step6_bullet4 => '**Payment options:** Cash, card, mobile money, or app payment';

  @override
  String get docsGroupBookingsHowTo_step6Example_title => 'Payment Example';

  @override
  String get docsGroupBookingsHowTo_step6Example_content => '**Family booking total: GHS 400**\n• Deposit at booking: GHS 120 (30% of GHS 400)\n• Platform fee: GHS 2 (charged once for entire group)\n• **Total to pay now: GHS 122**\n• Remaining after service: GHS 280\n• **Payment after:** Cash to worker/shop OR via app (your choice)';

  @override
  String get docsGroupBookingsHowTo_important_content => 'The deposit and platform fee are calculated on the TOTAL group booking, not per person. You pay once for the whole group.';

  @override
  String get docsGroupBookingsWorker_intro_title => 'One Worker or Multiple Workers?';

  @override
  String get docsGroupBookingsWorker_intro_content => 'When booking for a group, you have flexibility in how workers are assigned:';

  @override
  String get docsGroupBookingsWorker_intro_bullet1 => '**Same worker for everyone:** If one worker can handle everyone (sequentially)';

  @override
  String get docsGroupBookingsWorker_intro_bullet2 => '**Different workers:** Each person can have their preferred worker';

  @override
  String get docsGroupBookingsWorker_intro_bullet3 => '**Mix and match:** Some people share a worker, others have different ones';

  @override
  String get docsGroupBookingsWorker_same_title => 'Same Worker for Everyone';

  @override
  String get docsGroupBookingsWorker_same_content => 'If you choose the same worker for everyone, they will serve each person one after another. The total time is the sum of all services plus buffers.';

  @override
  String get docsGroupBookingsWorker_different_title => 'Different Workers for Different People';

  @override
  String get docsGroupBookingsWorker_different_content => 'When you choose different workers, they can work in parallel. This might reduce the total time needed. Example:';

  @override
  String get docsGroupBookingsWorker_different_bullet1 => '**Worker A:** Serves Person 1 (haircut)';

  @override
  String get docsGroupBookingsWorker_different_bullet2 => '**Worker B:** Serves Person 2 (braids) at the same time';

  @override
  String get docsGroupBookingsWorker_different_bullet3 => '**Worker A:** Then serves Person 3 (beard trim)';

  @override
  String get docsGroupBookingsWorker_different_bullet4 => '**Result:** Everyone finishes faster!';

  @override
  String get docsGroupBookingsWorker_interface_title => 'How to Assign Workers';

  @override
  String get docsGroupBookingsWorker_interface_content => 'In the worker selection screen, you\'ll see each person listed separately:';

  @override
  String get docsGroupBookingsWorker_example_title => 'What You\'ll See';

  @override
  String get docsGroupBookingsWorker_example_content => '**For a group of 3 booking haircuts:**\n• **Person 1:** [Choose Worker] → John\n• **Person 2:** [Choose Worker] → Michael\n• **Person 3:** [Choose Worker] → John (again)\n\nTap each person to select their worker from the available list.';

  @override
  String get docsGroupBookingsWorker_tip_content => 'If a worker is already chosen for one person, they remain available for others unless fully booked. The system shows real-time availability.';

  @override
  String get docsGroupBookingsTime_calculation_title => 'How Duration is Calculated';

  @override
  String get docsGroupBookingsTime_calculation_content => 'For group bookings, the total appointment time is calculated based on:';

  @override
  String get docsGroupBookingsTime_calculation_bullet1 => '**Service duration × quantity** for each service type';

  @override
  String get docsGroupBookingsTime_calculation_bullet2 => '**Buffer time** between services (for cleanup)';

  @override
  String get docsGroupBookingsTime_calculation_bullet3 => '**Parallel work** if multiple workers are assigned';

  @override
  String get docsGroupBookingsTime_sequential_title => 'Example: Sequential (Same Worker)';

  @override
  String get docsGroupBookingsTime_sequential_content => '**One worker doing 3 haircuts (45 min each):**\n• Haircut 1: 9:00 - 9:45\n• Buffer: 9:45 - 9:50 (5 min)\n• Haircut 2: 9:50 - 10:35\n• Buffer: 10:35 - 10:40\n• Haircut 3: 10:40 - 11:25\n• **Total: 2 hours 25 min**';

  @override
  String get docsGroupBookingsTime_parallel_title => 'Example: Parallel (Different Workers)';

  @override
  String get docsGroupBookingsTime_parallel_content => '**Three workers each doing one haircut (45 min each):**\n• Worker A: Person 1 (9:00 - 9:45)\n• Worker B: Person 2 (9:00 - 9:45) at same time\n• Worker C: Person 3 (9:00 - 9:45) at same time\n• **Total: 45 min**';

  @override
  String get docsGroupBookingsTime_combined_title => 'Combined View for Groups';

  @override
  String get docsGroupBookingsTime_combined_content => 'When booking for a group, Combined View is especially useful. It shows only time slots where ALL people in your group can be accommodated together, with the correct total duration.';

  @override
  String get docsGroupBookingsTime_tip_content => 'If your group is large or has many services, consider booking earlier in the day to ensure enough time before the shop closes.';

  @override
  String get docsGroupBookingsPayment_deposit_title => 'Deposit Calculation';

  @override
  String get docsGroupBookingsPayment_deposit_content => 'For group bookings, the 30% deposit is calculated on the **total cost of all services for all people**.';

  @override
  String get docsGroupBookingsPayment_deposit_bullet1 => '**Total cost:** Sum of all services × quantities';

  @override
  String get docsGroupBookingsPayment_deposit_bullet2 => '**Deposit:** 30% of total cost';

  @override
  String get docsGroupBookingsPayment_deposit_bullet3 => '**Platform fee:** One fixed fee for the entire group booking';

  @override
  String get docsGroupBookingsPayment_deposit_bullet4 => '**Total due now:** Deposit + platform fee';

  @override
  String get docsGroupBookingsPayment_example_title => 'Payment Example';

  @override
  String get docsGroupBookingsPayment_example_content => '**Family of 4 with total GHS 500:**\n• Deposit (30%): GHS 150\n• Platform fee: GHS 2\n• **Pay now: GHS 152**\n• Pay after: GHS 350 (cash or app)';

  @override
  String get docsGroupBookingsPayment_cancellation_title => 'Cancellation for Groups';

  @override
  String get docsGroupBookingsPayment_cancellation_content => 'If you cancel a group booking:';

  @override
  String get docsGroupBookingsPayment_cancellation_bullet1 => '**Full group cancellation:** Entire deposit and fee are non-refundable';

  @override
  String get docsGroupBookingsPayment_cancellation_bullet2 => '**Partial cancellation:** If some people can\'t make it, you may lose their portion of the deposit';

  @override
  String get docsGroupBookingsPayment_cancellation_bullet3 => '**Rescheduling:** You can reschedule the whole group (deposit transfers)';

  @override
  String get docsGroupBookingsPayment_important_content => 'The platform fee is charged once per group booking, not per person. You save on fees by booking as a group! For example: 4 separate bookings = GHS 8 in fees, but 1 group booking = GHS 2 fee. You save GHS 6!';

  @override
  String get docsGroupBookingsPayment_flexibility_title => 'Flexible Payment After Service';

  @override
  String get docsGroupBookingsPayment_flexibility_content => 'After your group service, paying the remaining 70% is flexible:';

  @override
  String get docsGroupBookingsPayment_flexibility_bullet1 => '**One person pays all:** Pay total in cash or via app';

  @override
  String get docsGroupBookingsPayment_flexibility_bullet2 => '**Split the payment:** Each person pays their share in cash';

  @override
  String get docsGroupBookingsPayment_flexibility_bullet3 => '**Mix methods:** Some people use cash, others use app';

  @override
  String get docsGroupBookingsPayment_flexibility_bullet4 => '**Individual app payments:** Each person can pay their portion through the app';

  @override
  String get docsGroupBookingsScenarios_family_title => 'Scenario 1: Family Haircut Day';

  @override
  String get docsGroupBookingsScenarios_family_content => '**The Mensah family (4 people) needs haircuts:**\n• Dad: Fade haircut (45 min, GHS 40)\n• Mom: Trim (30 min, GHS 35)\n• Son (10): Kids haircut (30 min, GHS 25)\n• Daughter (8): Braids (2 hours, GHS 80)\n\n**What they do:**\n1. Select \"Haircut\" → set quantity 3\n2. Select \"Braids\" → set quantity 1\n3. Choose workers: Dad → John, Son → Michael, Daughter → Sarah\n4. Pick a time that works for everyone\n5. Pay deposit: GHS 54 (30% of GHS 180) + GHS 2 fee = GHS 56\n6. After service, pay remaining GHS 126';

  @override
  String get docsGroupBookingsScenarios_friends_title => 'Scenario 2: Friends Day Out';

  @override
  String get docsGroupBookingsScenarios_friends_content => '**Three friends want different services:**\n• Friend 1: Beard trim (30 min, GHS 25)\n• Friend 2: Haircut + Beard (75 min, GHS 65)\n• Friend 3: Full color (2 hours, GHS 120)\n\n**What they do:**\n1. Select each service with quantity 1\n2. Choose their preferred workers\n3. System finds a time that works for all\n4. Pay deposit: GHS 63 (30% of GHS 210) + GHS 2 fee = GHS 65';

  @override
  String get docsGroupBookingsScenarios_bridal_title => 'Scenario 3: Bridal Party';

  @override
  String get docsGroupBookingsScenarios_bridal_content => '**Bride + 3 bridesmaids getting ready:**\n• Bride: Hair + Makeup (3 hours, GHS 300)\n• Each bridesmaid: Hair styling (1 hour, GHS 80 each)\n\n**What they do:**\n1. Select Bride services with quantity 1\n2. Select Hair styling with quantity 3\n3. Assign different workers to each person\n4. Book a morning slot to have enough time\n5. Pay deposit: GHS 162 (30% of GHS 540) + GHS 2 fee = GHS 164';

  @override
  String get docsGroupBookingsFaq1Q => 'What is a group booking?';

  @override
  String get docsGroupBookingsFaq1A => 'A group booking allows you to book services for multiple people at once. Instead of making separate bookings for each person, you can book everything together in one go. This is perfect for families, friends, or any group wanting services together.';

  @override
  String get docsGroupBookingsFaq2Q => 'How do I increase the number of people?';

  @override
  String get docsGroupBookingsFaq2A => 'After selecting a service, look for the **+** and **-** buttons. Tap **+** to increase the quantity (number of people) for that service. The price updates automatically. You cannot exceed the maximum quantity shown for that service.';

  @override
  String get docsGroupBookingsFaq3Q => 'Can we book different services for different people?';

  @override
  String get docsGroupBookingsFaq3A => 'Absolutely! You can select multiple services and set different quantities for each. For example, you can book 2 haircuts and 1 braid service all in the same booking. The system handles everything together.';

  @override
  String get docsGroupBookingsFaq4Q => 'Can different people have different workers?';

  @override
  String get docsGroupBookingsFaq4A => 'Yes! When you book for a group, you\'ll see each person listed separately. You can tap on each person to choose their preferred worker. This is great when different people have different preferences.';

  @override
  String get docsGroupBookingsFaq5Q => 'How is payment calculated for groups?';

  @override
  String get docsGroupBookingsFaq5A => 'The 30% deposit is calculated on the TOTAL cost of all services for all people. The platform fee is charged once for the entire group booking (not per person). After service, you pay the remaining 70% total (cash or app).';

  @override
  String get docsGroupBookingsFaq6Q => 'What if one person cancels?';

  @override
  String get docsGroupBookingsFaq6A => 'If someone in your group cancels, the deposit for their portion is non-refundable. The rest of the group can still proceed. Contact the shop through the app to adjust the booking.';

  @override
  String get docsGroupBookingsFaq7Q => 'How is the total appointment time calculated?';

  @override
  String get docsGroupBookingsFaq7A => 'The system calculates total time based on: service durations × quantities, plus buffer times between services. If you choose different workers who can work in parallel, the total time may be shorter.';

  @override
  String get docsGroupBookingsFaq8Q => 'Is there a maximum group size?';

  @override
  String get docsGroupBookingsFaq8A => 'Each service has a maximum quantity limit shown when booking. If you need to book for a very large group, you may need to make multiple bookings or contact the shop directly.';

  @override
  String get docsGroupBookingsFaq9Q => 'Can I book for my children?';

  @override
  String get docsGroupBookingsFaq9A => 'Yes! Group bookings are perfect for families. You can book for yourself and your children together. Just set the quantity to include everyone. For kids services, look for \"Kids\" options.';

  @override
  String get docsGroupBookingsFaq10Q => 'How does check-in work for groups?';

  @override
  String get docsGroupBookingsFaq10A => 'When you arrive, let the shop know you have a group booking. They\'ll check the main booking and direct everyone to their assigned workers. Arrive 10-15 minutes early for large groups.';

  @override
  String get docsGroupBookingsFaq11Q => 'Can we split the payment?';

  @override
  String get docsGroupBookingsFaq11A => 'The deposit is paid by the person making the booking. After service, you can split the remaining 70% however you like - cash, individual app payments, or one person paying for all.';

  @override
  String get docsGroupBookingsFaq12Q => 'Can we reschedule a group booking?';

  @override
  String get docsGroupBookingsFaq12A => 'Yes, you can reschedule the entire group booking up to 24 hours before the appointment. The deposit transfers to the new time. If only some people need to reschedule, contact the shop.';

  @override
  String get docsGroupBookingsFaq13Q => 'Can we book as a group without an account?';

  @override
  String get docsGroupBookingsFaq13A => 'Yes! If the shop shares a group booking link, everyone can use it without downloading the app or creating accounts. The booking confirmation and receipt details are sent to your WhatsApp.';

  @override
  String get docsGroupBookingsFaq14Q => 'Do we all have to pay in cash or can we use the app?';

  @override
  String get docsGroupBookingsFaq14A => 'You have full flexibility! You can pay the remaining 70% in cash (to the shop/worker), via the app individually, or any combination. Some people can pay cash while others use the app for their portion.';

  @override
  String get docsPaymentFeesExplainedPaymentOverview_title => 'How Payment Works';

  @override
  String get docsPaymentFeesExplainedPaymentOverview_subtitle => 'Simple, transparent, secure';

  @override
  String get docsPaymentFeesExplainedPaymentSummary_title => 'Payment at a Glance';

  @override
  String get docsPaymentFeesExplainedPaymentSummary_content => 'Our payment system is designed to be fair for both clients and shop owners. Here\'s the simple breakdown:';

  @override
  String get docsPaymentFeesExplainedPaymentSummary_bullet1 => '**30% Deposit:** Paid at booking to secure your appointment';

  @override
  String get docsPaymentFeesExplainedPaymentSummary_bullet2 => '**Platform Fee:** Small fixed fee (e.g., GHS 2) charged by the app';

  @override
  String get docsPaymentFeesExplainedPaymentSummary_bullet3 => '**Remaining 70%:** Paid after your service is complete';

  @override
  String get docsPaymentFeesExplainedPaymentSummary_bullet4 => '**Two Ways to Pay Remaining:** Cash or via app';

  @override
  String get docsPaymentFeesExplainedPaymentExampleQuick_title => 'Quick Example';

  @override
  String get docsPaymentFeesExplainedPaymentExampleQuick_content => '**Service cost: GHS 100**\n• At booking: Pay GHS 30 (deposit) + GHS 2 (fee) = GHS 32\n• After service: Pay GHS 70 (cash or app)\n• Total to shop: GHS 100\n• Platform fee: GHS 2';

  @override
  String get docsPaymentFeesExplainedPaymentImportant_content => 'The platform fee is charged by the app, not the shop. It helps us maintain the platform and provide you with a great booking experience.';

  @override
  String get docsPaymentFeesExplainedGuestBookingNote_title => 'Guest Booking (No App Download)';

  @override
  String get docsPaymentFeesExplainedGuestBookingNote_content => 'Don\'t have the app? No problem! You can still book through your provider\'s booking link without creating an account. You pay the same 30% deposit + platform fee, and your receipt is sent to WhatsApp.';

  @override
  String get docsPaymentFeesExplainedDepositExplained_title => 'The 30% Deposit';

  @override
  String get docsPaymentFeesExplainedDepositExplained_subtitle => 'Why it\'s needed and how it works';

  @override
  String get docsPaymentFeesExplainedDepositWhy_title => 'Why Do We Require a Deposit?';

  @override
  String get docsPaymentFeesExplainedDepositWhy_content => 'The 30% deposit protects both you and the shop:';

  @override
  String get docsPaymentFeesExplainedDepositWhy_bullet1 => '**For you:** Your slot is guaranteed – no one else can book it';

  @override
  String get docsPaymentFeesExplainedDepositWhy_bullet2 => '**For the shop:** Workers are compensated if you cancel last minute';

  @override
  String get docsPaymentFeesExplainedDepositWhy_bullet3 => '**For everyone:** Reduces no-shows, keeping prices fair';

  @override
  String get docsPaymentFeesExplainedDepositCalculation_title => 'How the Deposit is Calculated';

  @override
  String get docsPaymentFeesExplainedDepositCalculation_content => 'The deposit is always **30% of the total service cost**. This includes:';

  @override
  String get docsPaymentFeesExplainedDepositCalculation_bullet1 => '**Single service:** 30% of that service price';

  @override
  String get docsPaymentFeesExplainedDepositCalculation_bullet2 => '**Multiple services:** 30% of all services combined';

  @override
  String get docsPaymentFeesExplainedDepositCalculation_bullet3 => '**Group bookings:** 30% of total for all people';

  @override
  String get docsPaymentFeesExplainedDepositExamples_title => 'Deposit Examples';

  @override
  String get docsPaymentFeesExplainedDepositExamples_content => '**Single Service:**\n• Haircut (GHS 45) → Deposit GHS 13.50\n\n**Multiple Services:**\n• Haircut (GHS 45) + Beard Trim (GHS 25) = GHS 70 total\n• Deposit: GHS 21\n\n**Group Booking (3 people):**\n• 3 × Haircut (GHS 45 each) = GHS 135 total\n• Deposit: GHS 40.50';

  @override
  String get docsPaymentFeesExplainedDepositNonRefundable_title => 'Deposit Refund Policy';

  @override
  String get docsPaymentFeesExplainedDepositNonRefundable_content => 'The 30% deposit is **non-refundable**. This means:';

  @override
  String get docsPaymentFeesExplainedDepositNonRefundable_bullet1 => '**If you cancel:** Deposit is not returned';

  @override
  String get docsPaymentFeesExplainedDepositNonRefundable_bullet2 => '**If you don\'t show up:** Deposit is not returned';

  @override
  String get docsPaymentFeesExplainedDepositNonRefundable_bullet3 => '**If you reschedule:** Deposit transfers to new time';

  @override
  String get docsPaymentFeesExplainedDepositNonRefundable_bullet4 => '**If shop cancels:** Full deposit refunded';

  @override
  String get docsPaymentFeesExplainedDepositWarning_content => 'Please be sure about your booking before paying the deposit. While you can reschedule, the deposit cannot be refunded if you cancel.';

  @override
  String get docsPaymentFeesExplainedPlatformFee_title => 'Platform Fee';

  @override
  String get docsPaymentFeesExplainedPlatformFee_subtitle => 'The small fee that keeps the app running';

  @override
  String get docsPaymentFeesExplainedFeeWhat_title => 'What is the Platform Fee?';

  @override
  String get docsPaymentFeesExplainedFeeWhat_content => 'The platform fee is a small fixed charge (e.g., GHS 2) that goes to the app, not the shop. It covers:';

  @override
  String get docsPaymentFeesExplainedFeeWhat_bullet1 => '**App development** and maintenance';

  @override
  String get docsPaymentFeesExplainedFeeWhat_bullet2 => '**Customer support** and dispute resolution';

  @override
  String get docsPaymentFeesExplainedFeeWhat_bullet3 => '**Payment processing** costs';

  @override
  String get docsPaymentFeesExplainedFeeWhat_bullet4 => '**New features** and improvements';

  @override
  String get docsPaymentFeesExplainedFeeHow_title => 'How the Fee is Charged';

  @override
  String get docsPaymentFeesExplainedFeeHow_content => 'Important things to know about the platform fee:';

  @override
  String get docsPaymentFeesExplainedFeeHow_bullet1 => '**Fixed amount** (not a percentage) – e.g., GHS 2 per booking';

  @override
  String get docsPaymentFeesExplainedFeeHow_bullet2 => '**Charged once per booking** – not per service or per person';

  @override
  String get docsPaymentFeesExplainedFeeHow_bullet3 => '**Non-refundable** – even if you cancel';

  @override
  String get docsPaymentFeesExplainedFeeHow_bullet4 => '**Clearly shown** before you confirm payment';

  @override
  String get docsPaymentFeesExplainedFeeExamples_title => 'Platform Fee Examples';

  @override
  String get docsPaymentFeesExplainedFeeExamples_content => '**Single person, one service:** GHS 2 fee\n**Single person, multiple services:** GHS 2 fee (still one booking!)\n**Family of 4 booking together:** GHS 2 fee (entire group)\n\n**Compare to booking separately:**\n• 4 separate bookings = 4 × GHS 2 = GHS 8 in fees\n• 1 group booking = GHS 2 fee – **you save GHS 6!**';

  @override
  String get docsPaymentFeesExplainedFeeTip_content => 'Booking as a group saves you money on fees! Instead of paying the platform fee for each person, you pay just one fee for the entire group booking.';

  @override
  String get docsPaymentFeesExplainedRemainingPayment_title => 'Paying the Remaining 70%';

  @override
  String get docsPaymentFeesExplainedRemainingPayment_subtitle => 'Two convenient options';

  @override
  String get docsPaymentFeesExplainedRemainingOverview_title => 'After Your Service';

  @override
  String get docsPaymentFeesExplainedRemainingOverview_content => 'Once your service is complete, you have two ways to pay the remaining 70%:';

  @override
  String get docsPaymentFeesExplainedRemainingOverview_bullet1 => '**Option 1: Cash** – Pay the worker or shop directly';

  @override
  String get docsPaymentFeesExplainedRemainingOverview_bullet2 => '**Option 2: Via App** – Pay through the app using your preferred method';

  @override
  String get docsPaymentFeesExplainedRemainingCash_title => 'Paying with Cash';

  @override
  String get docsPaymentFeesExplainedRemainingCash_content => 'If you choose to pay the remaining balance in cash:';

  @override
  String get docsPaymentFeesExplainedRemainingCash_bullet1 => 'Simply hand the cash to your worker or at the counter';

  @override
  String get docsPaymentFeesExplainedRemainingCash_bullet2 => 'You\'ll still receive a receipt through the app';

  @override
  String get docsPaymentFeesExplainedRemainingCash_bullet3 => 'The shop will mark the payment as received';

  @override
  String get docsPaymentFeesExplainedRemainingCash_bullet4 => 'No additional fees';

  @override
  String get docsPaymentFeesExplainedRemainingApp_title => 'Paying Through the App';

  @override
  String get docsPaymentFeesExplainedRemainingApp_content => 'If you prefer to pay via the app:';

  @override
  String get docsPaymentFeesExplainedRemainingApp_bullet1 => 'Open your booking in \"My Bookings\"';

  @override
  String get docsPaymentFeesExplainedRemainingApp_bullet2 => 'Tap \"Pay Remaining Balance\"';

  @override
  String get docsPaymentFeesExplainedRemainingApp_bullet3 => 'Choose your payment method (card, mobile money, etc.)';

  @override
  String get docsPaymentFeesExplainedRemainingApp_bullet4 => 'Complete payment – instant confirmation';

  @override
  String get docsPaymentFeesExplainedRemainingApp_bullet5 => 'Receipt saved in the app';

  @override
  String get docsPaymentFeesExplainedRemainingChoice_title => 'Which Option Should You Choose?';

  @override
  String get docsPaymentFeesExplainedRemainingChoice_content => '**Choose cash if:** You prefer physical payment, have cash on hand, or want to tip in cash\n\n**Choose app if:** You want a digital record, don\'t carry cash, or prefer using mobile money/cards';

  @override
  String get docsPaymentFeesExplainedRemainingImportant_content => 'The remaining 70% is paid to the shop, not the platform. No additional platform fee is charged at this stage.';

  @override
  String get docsPaymentFeesExplainedPaymentTiming_title => 'When Payments Happen';

  @override
  String get docsPaymentFeesExplainedPaymentTiming_subtitle => 'A timeline of when you pay';

  @override
  String get docsPaymentFeesExplainedTimelineAtBooking_title => 'At Booking Time';

  @override
  String get docsPaymentFeesExplainedTimelineAtBooking_content => '**What you pay:**\n• 30% deposit\n• Platform fee (e.g., GHS 2)\n\n**What happens:** Your slot is secured immediately';

  @override
  String get docsPaymentFeesExplainedTimelineBefore_title => 'Before Appointment';

  @override
  String get docsPaymentFeesExplainedTimelineBefore_content => '**Nothing to pay** – just show up at your scheduled time!\n\nYou\'ll receive reminders 24 hours and 1 hour before.';

  @override
  String get docsPaymentFeesExplainedTimelineAfter_title => 'After Service';

  @override
  String get docsPaymentFeesExplainedTimelineAfter_content => '**What you pay:**\n• Remaining 70% of total cost\n\n**How to pay:**\n• Cash (to worker or shop)\n• Via app (digital payment)';

  @override
  String get docsPaymentFeesExplainedTimelineSummary_title => 'Payment Summary Example';

  @override
  String get docsPaymentFeesExplainedTimelineSummary_content => '**Total bill: GHS 200**\n━━━━━━━━━━━━━━━━━━━━━━━━━━\n**At booking:** GHS 60 (deposit) + GHS 2 (fee) = GHS 62\n**After service:** GHS 140 (remaining)\n**Total to shop:** GHS 200\n**Platform fee:** GHS 2';

  @override
  String get docsPaymentFeesExplainedCancellationRefunds_title => 'Cancellation & Refunds';

  @override
  String get docsPaymentFeesExplainedCancellationRefunds_subtitle => 'What happens when plans change';

  @override
  String get docsPaymentFeesExplainedCancelClient_title => 'If You Cancel';

  @override
  String get docsPaymentFeesExplainedCancelClient_content => '**You cancel more than 24 hours before:**\n• Deposit: ❌ Non-refundable\n• Platform fee: ❌ Non-refundable\n• Remaining 70%: Not charged\n\n**You cancel within 24 hours:**\n• Deposit: ❌ Non-refundable\n• Platform fee: ❌ Non-refundable\n• Remaining 70%: Not charged\n• Note: Last-minute cancellations may affect your account standing';

  @override
  String get docsPaymentFeesExplainedCancelNoShow_title => 'If You Don\'t Show Up';

  @override
  String get docsPaymentFeesExplainedCancelNoShow_content => '**No-show policy:**\n• Deposit: ❌ Forfeited\n• Platform fee: ❌ Forfeited\n• Remaining 70%: Not charged\n• Account: Marked as no-show\n• Repeated no-shows may result in account restrictions';

  @override
  String get docsPaymentFeesExplainedCancelShop_title => 'If the Shop Cancels';

  @override
  String get docsPaymentFeesExplainedCancelShop_content => '**Shop cancels for any reason:**\n• Deposit: ✅ Full refund\n• Platform fee: ✅ Full refund\n• Remaining 70%: Not applicable\n• You\'ll receive notification and refund automatically';

  @override
  String get docsPaymentFeesExplainedCancelReschedule_title => 'Rescheduling vs Cancelling';

  @override
  String get docsPaymentFeesExplainedCancelReschedule_content => '**Rescheduling** (changing time/date):\n• Deposit transfers to new booking\n• Platform fee transfers (no additional fee)\n• Available up to 24 hours before\n\n**Cancelling** (completely):\n• Deposit and fee are forfeited\n• Must rebook and pay deposit again';

  @override
  String get docsPaymentFeesExplainedCancelTip_content => 'If you can\'t make it, try to reschedule instead of cancelling. Your deposit transfers and you won\'t lose your money!';

  @override
  String get docsPaymentFeesExplainedGroupPayment_title => 'Payment for Group Bookings';

  @override
  String get docsPaymentFeesExplainedGroupPayment_subtitle => 'How it works when booking for multiple people';

  @override
  String get docsPaymentFeesExplainedGroupDeposit_title => 'Deposit for Groups';

  @override
  String get docsPaymentFeesExplainedGroupDeposit_content => 'For group bookings, the 30% deposit is calculated on the **total cost for everyone**.';

  @override
  String get docsPaymentFeesExplainedGroupDeposit_bullet1 => '**Example:** 4 people × GHS 50 each = GHS 200 total';

  @override
  String get docsPaymentFeesExplainedGroupDeposit_bullet2 => '**Deposit:** 30% of GHS 200 = GHS 60';

  @override
  String get docsPaymentFeesExplainedGroupDeposit_bullet3 => '**Paid by:** One person (the booker)';

  @override
  String get docsPaymentFeesExplainedGroupFee_title => 'Platform Fee for Groups';

  @override
  String get docsPaymentFeesExplainedGroupFee_content => '**Great news!** The platform fee is charged **once per booking**, not per person.';

  @override
  String get docsPaymentFeesExplainedGroupFee_bullet1 => '**Example:** Family of 4 booking together';

  @override
  String get docsPaymentFeesExplainedGroupFee_bullet2 => '**Fee:** GHS 2 total (not GHS 8)';

  @override
  String get docsPaymentFeesExplainedGroupFee_bullet3 => '**Savings:** GHS 6 compared to booking separately';

  @override
  String get docsPaymentFeesExplainedGroupRemaining_title => 'Paying the Remaining 70% for Groups';

  @override
  String get docsPaymentFeesExplainedGroupRemaining_content => 'After the service, you have flexibility:';

  @override
  String get docsPaymentFeesExplainedGroupRemaining_bullet1 => '**One person pays all:** Pay total remaining in cash or app';

  @override
  String get docsPaymentFeesExplainedGroupRemaining_bullet2 => '**Split the bill:** Each person pays their share (cash to shop or individual app payments)';

  @override
  String get docsPaymentFeesExplainedGroupRemaining_bullet3 => '**Mix and match:** Some pay cash, others use app';

  @override
  String get docsPaymentFeesExplainedGroupCancellation_title => 'Group Cancellations';

  @override
  String get docsPaymentFeesExplainedGroupCancellation_content => '**If one person cancels:**\n• Their portion of the deposit is forfeited\n• The rest of the group can proceed\n• Contact shop to adjust\n\n**If entire group cancels:**\n• Full deposit and fee forfeited (standard policy)';

  @override
  String get docsPaymentFeesExplainedGroupSaving_title => 'Group Savings Example';

  @override
  String get docsPaymentFeesExplainedGroupSaving_content => '**Family of 4 booking separately vs together:**\n\n**Separate bookings:**\n• 4 × GHS 2 platform fee = GHS 8 in fees\n\n**Group booking:**\n• 1 × GHS 2 platform fee = GHS 2\n• **You save GHS 6!**';

  @override
  String get docsPaymentFeesExplainedPaymentMethods_title => 'Accepted Payment Methods';

  @override
  String get docsPaymentFeesExplainedPaymentMethods_subtitle => 'How you can pay';

  @override
  String get docsPaymentFeesExplainedMethodsDeposit_title => 'For Deposits (at booking)';

  @override
  String get docsPaymentFeesExplainedMethodsDeposit_content => 'You can pay your deposit using:';

  @override
  String get docsPaymentFeesExplainedMethodsDeposit_bullet1 => '**Credit/Debit Cards** (Visa, Mastercard, etc.)';

  @override
  String get docsPaymentFeesExplainedMethodsDeposit_bullet2 => '**Mobile Money** (MTN, Vodafone, AirtelTigo)';

  @override
  String get docsPaymentFeesExplainedMethodsDeposit_bullet3 => '**Bank Transfers** (instant payment)';

  @override
  String get docsPaymentFeesExplainedMethodsDeposit_bullet4 => '**Apple Pay / Google Pay** (where available)';

  @override
  String get docsPaymentFeesExplainedMethodsRemaining_title => 'For Remaining Balance (after service)';

  @override
  String get docsPaymentFeesExplainedMethodsRemaining_content => 'After your service, you can pay the remaining 70% via:';

  @override
  String get docsPaymentFeesExplainedMethodsRemaining_bullet1 => '**Cash** (pay directly to worker or shop)';

  @override
  String get docsPaymentFeesExplainedMethodsRemaining_bullet2 => '**Mobile Money** (send to shop number)';

  @override
  String get docsPaymentFeesExplainedMethodsRemaining_bullet3 => '**Card** (if shop has card reader)';

  @override
  String get docsPaymentFeesExplainedMethodsRemaining_bullet4 => '**App Payment** (through the app)';

  @override
  String get docsPaymentFeesExplainedMethodsSecurity_title => 'Payment Security';

  @override
  String get docsPaymentFeesExplainedMethodsSecurity_content => 'All payments through the app are:';

  @override
  String get docsPaymentFeesExplainedMethodsSecurity_bullet1 => '**Encrypted** – your information is safe';

  @override
  String get docsPaymentFeesExplainedMethodsSecurity_bullet2 => '**PCI compliant** – meets security standards';

  @override
  String get docsPaymentFeesExplainedMethodsSecurity_bullet3 => '**Protected** – fraud monitoring in place';

  @override
  String get docsPaymentFeesExplainedMethodsSecurity_bullet4 => '**Receipt provided** – digital record of every payment';

  @override
  String get docsPaymentFeesExplainedMethodsTip_content => 'Save your payment details in the app for faster checkout next time!';

  @override
  String get docsPaymentFeesExplainedGuestBookings_title => 'Guest Bookings (No App Download)';

  @override
  String get docsPaymentFeesExplainedGuestBookings_subtitle => 'Book without creating an account';

  @override
  String get docsPaymentFeesExplainedGuestWhat_title => 'What is a Guest Booking?';

  @override
  String get docsPaymentFeesExplainedGuestWhat_content => 'A guest booking lets you reserve an appointment without downloading the app or creating an account. Your provider shares a link – you click it and book directly.';

  @override
  String get docsPaymentFeesExplainedGuestPayment_title => 'How Guest Booking Payment Works';

  @override
  String get docsPaymentFeesExplainedGuestPayment_content => 'Guest bookings follow the same payment model as app bookings:';

  @override
  String get docsPaymentFeesExplainedGuestPayment_bullet1 => '**30% Deposit** – Pay upfront to secure your slot';

  @override
  String get docsPaymentFeesExplainedGuestPayment_bullet2 => '**Platform Fee** – Small fixed fee added to deposit';

  @override
  String get docsPaymentFeesExplainedGuestPayment_bullet3 => '**70% Balance** – Pay cash or online after service';

  @override
  String get docsPaymentFeesExplainedGuestWhatsapp_title => 'Booking Details via WhatsApp';

  @override
  String get docsPaymentFeesExplainedGuestWhatsapp_content => 'Once you complete your guest booking, your appointment details and payment receipt are sent to your WhatsApp. This way you can track everything without the app.';

  @override
  String get docsPaymentFeesExplainedGuestBenefits_title => 'Why Book as a Guest?';

  @override
  String get docsPaymentFeesExplainedGuestBenefits_content => 'Guest bookings are perfect if:';

  @override
  String get docsPaymentFeesExplainedGuestBenefits_bullet1 => 'You don\'t want to download another app';

  @override
  String get docsPaymentFeesExplainedGuestBenefits_bullet2 => 'You\'re booking for a one-time appointment';

  @override
  String get docsPaymentFeesExplainedGuestBenefits_bullet3 => 'You prefer simple, hassle-free booking';

  @override
  String get docsPaymentFeesExplainedGuestBenefits_bullet4 => 'Your provider shared a direct link with you';

  @override
  String get docsPaymentFeesExplainedGuestConvert_title => 'Convert Guest to Account';

  @override
  String get docsPaymentFeesExplainedGuestConvert_content => 'If you make multiple bookings, you can create a full account anytime to access your booking history, saved payments, and loyalty benefits.';

  @override
  String get docsPaymentFeesExplainedReceipts_title => 'Receipts & Records';

  @override
  String get docsPaymentFeesExplainedReceipts_subtitle => 'Keeping track of your payments';

  @override
  String get docsPaymentFeesExplainedReceiptWhat_title => 'What You\'ll Receive';

  @override
  String get docsPaymentFeesExplainedReceiptWhat_content => 'For every payment, you\'ll get:';

  @override
  String get docsPaymentFeesExplainedReceiptWhat_bullet1 => '**Booking confirmation receipt** (at booking)';

  @override
  String get docsPaymentFeesExplainedReceiptWhat_bullet2 => '**Deposit payment receipt** (immediate)';

  @override
  String get docsPaymentFeesExplainedReceiptWhat_bullet3 => '**Final payment receipt** (after service)';

  @override
  String get docsPaymentFeesExplainedReceiptWhat_bullet4 => '**Email copy** sent to your registered email';

  @override
  String get docsPaymentFeesExplainedReceiptWhat_bullet5 => '**In-app record** in \"My Bookings\"';

  @override
  String get docsPaymentFeesExplainedReceiptInfo_title => 'What\'s on Your Receipt';

  @override
  String get docsPaymentFeesExplainedReceiptInfo_content => 'Each receipt shows:';

  @override
  String get docsPaymentFeesExplainedReceiptInfo_bullet1 => '**Shop name** and location';

  @override
  String get docsPaymentFeesExplainedReceiptInfo_bullet2 => '**Services booked** with quantities';

  @override
  String get docsPaymentFeesExplainedReceiptInfo_bullet3 => '**Workers assigned**';

  @override
  String get docsPaymentFeesExplainedReceiptInfo_bullet4 => '**Date and time** of appointment';

  @override
  String get docsPaymentFeesExplainedReceiptInfo_bullet5 => '**Amount paid** (deposit/fee/remaining)';

  @override
  String get docsPaymentFeesExplainedReceiptInfo_bullet6 => '**Payment method** used';

  @override
  String get docsPaymentFeesExplainedReceiptInfo_bullet7 => '**Transaction reference** number';

  @override
  String get docsPaymentFeesExplainedReceiptAccess_title => 'How to Access Receipts';

  @override
  String get docsPaymentFeesExplainedReceiptAccess_content => 'To view your payment history:';

  @override
  String get docsPaymentFeesExplainedReceiptAccess_bullet1 => 'Go to **Profile** tab';

  @override
  String get docsPaymentFeesExplainedReceiptAccess_bullet2 => 'Tap **Payment History**';

  @override
  String get docsPaymentFeesExplainedReceiptAccess_bullet3 => 'See all transactions';

  @override
  String get docsPaymentFeesExplainedReceiptAccess_bullet4 => 'Tap any receipt to view details';

  @override
  String get docsPaymentFeesExplainedReceiptAccess_bullet5 => 'Share or download as PDF';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ_title => 'Common Payment Questions';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ_subtitle => 'Quick answers';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ1_title => 'Is the deposit really non-refundable?';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ1_content => 'Yes, the 30% deposit is non-refundable by policy. This protects workers\' time and discourages last-minute cancellations. The only exception is if the shop cancels on you.';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ2_title => 'Why a deposit instead of full payment?';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ2_content => 'The deposit system is designed to be fair to everyone:\n• **You:** Only pay 30% upfront, not the full amount\n• **Shop:** Gets some compensation if you cancel\n• **Workers:** Time is valued and protected';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ3_title => 'Can I pay the full amount upfront?';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ3_content => 'Currently, we only collect the 30% deposit at booking. The remaining 70% is paid after service to ensure you\'re happy with the result before paying in full.';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ4_title => 'What if I want to add a tip?';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ4_content => 'Great question! Tips can be added when paying the remaining 70% via the app, or you can tip in cash directly to your worker. 100% of tips go to the worker.';

  @override
  String get docsPaymentFeesExplainedFaq1Q => 'Why is the deposit non-refundable?';

  @override
  String get docsPaymentFeesExplainedFaq1A => 'The deposit compensates workers for holding time exclusively for you. When you book a slot, that time can\'t be sold to someone else. The deposit policy discourages last-minute cancellations and no-shows, which helps keep prices fair for everyone.';

  @override
  String get docsPaymentFeesExplainedFaq2Q => 'What exactly is the platform fee for?';

  @override
  String get docsPaymentFeesExplainedFaq2A => 'The platform fee (e.g., GHS 2) helps us maintain the app, provide customer support, process payments securely, and develop new features. It\'s a small fixed fee that keeps the platform running smoothly for both clients and shops.';

  @override
  String get docsPaymentFeesExplainedFaq3Q => 'Can I really pay the remaining amount in cash?';

  @override
  String get docsPaymentFeesExplainedFaq3A => 'Yes! Many shops accept cash for the remaining 70%. You can also choose to pay through the app if you prefer digital payments. The choice is yours at the time of service.';

  @override
  String get docsPaymentFeesExplainedFaq4Q => 'How is the platform fee calculated for groups?';

  @override
  String get docsPaymentFeesExplainedFaq4A => 'The platform fee is charged **once per booking**, not per person. So if you book for a family of 4, you pay just one GHS 2 fee instead of four separate fees. This makes group bookings more economical!';

  @override
  String get docsPaymentFeesExplainedFaq5Q => 'When would I get a refund?';

  @override
  String get docsPaymentFeesExplainedFaq5A => 'Refunds are issued only if the shop cancels your booking. In that case, both your deposit and platform fee are fully refunded. If you cancel, the deposit and fee are non-refundable by policy.';

  @override
  String get docsPaymentFeesExplainedFaq6Q => 'What payment methods are accepted?';

  @override
  String get docsPaymentFeesExplainedFaq6A => 'For deposits: Credit/debit cards, mobile money, bank transfers, and digital wallets. For remaining balance: Cash or any of the digital methods through the app. Available options may vary by region.';

  @override
  String get docsPaymentFeesExplainedFaq7Q => 'How do I tip my worker?';

  @override
  String get docsPaymentFeesExplainedFaq7A => 'You can tip your worker in two ways:\n1. **Cash:** Give directly to your worker after service\n2. **Via App:** Add a tip when paying the remaining 70%\n\n100% of tips go directly to your worker!';

  @override
  String get docsPaymentFeesExplainedFaq8Q => 'How do I get a receipt?';

  @override
  String get docsPaymentFeesExplainedFaq8A => 'Receipts are automatically generated and sent to your email. You can also access all receipts in the app under Profile → Payment History. Each receipt shows full details of your transaction.';

  @override
  String get docsPaymentFeesExplainedFaq9Q => 'Can we split the bill for group bookings?';

  @override
  String get docsPaymentFeesExplainedFaq9A => 'Yes! For group bookings, you can split the remaining 70% however you like:\n• One person pays all (cash or app)\n• Each person pays their share (cash to shop)\n• Mix of cash and app payments\n\nThe deposit is paid by the person making the booking.';

  @override
  String get docsPaymentFeesExplainedFaq10Q => 'What if I have an emergency and can\'t make it?';

  @override
  String get docsPaymentFeesExplainedFaq10A => 'We understand emergencies happen. While the deposit is officially non-refundable, you can contact the shop directly through the app. Some shops may offer credit toward a future booking at their discretion. The platform fee cannot be refunded.';

  @override
  String get docsPaymentFeesExplainedFaq11Q => 'Can I save my payment details for faster booking?';

  @override
  String get docsPaymentFeesExplainedFaq11A => 'Yes! In your Profile settings, you can save payment methods securely. This makes future bookings faster – just confirm and pay with one tap. Your information is encrypted and stored securely.';

  @override
  String get docsPaymentFeesExplainedFaq12Q => 'Is my payment information secure?';

  @override
  String get docsPaymentFeesExplainedFaq12A => 'Absolutely. All payments are processed through secure, PCI-compliant gateways. Your payment details are encrypted and never stored in plain text. We use industry-standard security measures to protect your information.';

  @override
  String get docsPaymentFeesExplainedFaq13Q => 'What is a guest booking and do I need an account?';

  @override
  String get docsPaymentFeesExplainedFaq13A => 'A guest booking lets you reserve through a provider\'s shared link without downloading the app or creating an account. You pay the same 30% deposit + platform fee, and your receipt is sent to WhatsApp.';

  @override
  String get docsPaymentFeesExplainedFaq14Q => 'How do I get my booking details if I book as a guest?';

  @override
  String get docsPaymentFeesExplainedFaq14A => 'Your appointment details, payment receipt, and reminders are sent to your WhatsApp. You can access everything there without downloading the app.';

  @override
  String get docsPaymentFeesExplainedFaq15Q => 'Can I convert my guest booking to a full account?';

  @override
  String get docsPaymentFeesExplainedFaq15A => 'Yes! After booking as a guest, you can create a full account anytime to access your booking history, saved payments, and other features like loyalty rewards.';

  @override
  String get docsTimeSlotsExplainedTimeIntro_title => 'Why Two Views?';

  @override
  String get docsTimeSlotsExplainedTimeIntro_subtitle => 'Giving you more control over your booking';

  @override
  String get docsTimeSlotsExplainedTimeIntro_timeIntroText_title => 'Two Ways to See Available Times';

  @override
  String get docsTimeSlotsExplainedTimeIntro_timeIntroText_content => 'When you select a date for your booking, you\'ll see available time slots. But did you notice you can switch between two different views? Regular View and Combined View show you the same slots in different ways, each useful for different situations.';

  @override
  String get docsTimeSlotsExplainedTimeIntro_timeSwitch_title => 'How to Switch Views';

  @override
  String get docsTimeSlotsExplainedTimeIntro_timeSwitch_content => 'Look for the toggle switch at the top of the time slot screen. It usually says \"Show Combined Slots\". Tap it to switch between views. The toggle only appears when you have multiple services selected.';

  @override
  String get docsTimeSlotsExplainedTimeIntro_timeImportant_content => 'The toggle switch only appears when you have selected more than one service. For single services, both views would show the same thing, so we keep it simple!';

  @override
  String get docsTimeSlotsExplainedRegularView_title => 'Regular View';

  @override
  String get docsTimeSlotsExplainedRegularView_subtitle => 'See slots for each service separately';

  @override
  String get docsTimeSlotsExplainedRegularView_regularExplained_title => 'What is Regular View?';

  @override
  String get docsTimeSlotsExplainedRegularView_regularExplained_content => 'Regular View shows you available time slots for each service **independently**. You\'ll see separate lists of slots for each service you\'ve selected.';

  @override
  String get docsTimeSlotsExplainedRegularView_regularExample_title => 'Example: Regular View with 2 Services';

  @override
  String get docsTimeSlotsExplainedRegularView_regularExample_content => '**You\'ve selected:**\n• Haircut (1 hour)\n• Beard Trim (30 minutes)\n\n**Regular View shows:**\n━━━━━━━━━━━━━━━━━━━━━━━\n**HAIRCUT SLOTS**\n• 9:00 AM - 10:00 AM\n• 9:30 AM - 10:30 AM\n• 10:00 AM - 11:00 AM\n• 10:30 AM - 11:30 AM\n\n**BEARD TRIM SLOTS**\n• 9:00 AM - 9:30 AM\n• 9:30 AM - 10:00 AM\n• 10:00 AM - 10:30 AM\n• 10:30 AM - 11:00 AM';

  @override
  String get docsTimeSlotsExplainedRegularView_regularWhen_title => 'When to Use Regular View';

  @override
  String get docsTimeSlotsExplainedRegularView_regularWhen_content => 'Regular View is most useful when:';

  @override
  String get docsTimeSlotsExplainedRegularView_regularWhen_bullet1 => '**You haven\'t decided on timing yet** – See all possibilities';

  @override
  String get docsTimeSlotsExplainedRegularView_regularWhen_bullet2 => '**You want flexibility** – Mix and match different times';

  @override
  String get docsTimeSlotsExplainedRegularView_regularWhen_bullet3 => '**You\'re still choosing workers** – See availability per service';

  @override
  String get docsTimeSlotsExplainedRegularView_regularWhen_bullet4 => '**Services have very different durations** – Compare options';

  @override
  String get docsTimeSlotsExplainedRegularView_regularChallenge_title => 'The Challenge with Regular View';

  @override
  String get docsTimeSlotsExplainedRegularView_regularChallenge_content => 'The challenge with Regular View is that you have to find a time that works for ALL your services. For example, you might pick:\n• Haircut at 9:00 AM\n• Beard Trim at 9:30 AM\n\n**Problem:** These overlap! You can\'t be in two places at once.';

  @override
  String get docsTimeSlotsExplainedRegularView_regularTip_content => 'Use Regular View to explore possibilities, then switch to Combined View to find times that actually work together.';

  @override
  String get docsTimeSlotsExplainedCombinedView_title => 'Combined View';

  @override
  String get docsTimeSlotsExplainedCombinedView_subtitle => 'See only slots where ALL services fit together';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedExplained_title => 'What is Combined View?';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedExplained_content => 'Combined View does the hard work for you. It shows only time slots where **ALL your selected services can be booked together** in one continuous appointment.';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedExample_title => 'Example: Combined View with 2 Services';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedExample_content => '**Same services:** Haircut (1 hour) + Beard Trim (30 min)\n\n**Combined View shows:**\n━━━━━━━━━━━━━━━━━━━━━━━\n• 9:00 AM - 10:30 AM (both services)\n• 9:30 AM - 11:00 AM (both services)\n• 10:00 AM - 11:30 AM (both services)\n• 10:30 AM - 12:00 PM (both services)\n\n**Notice:** Each slot is LONGER because it includes BOTH services back-to-back.';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedCalculation_title => 'How Combined Duration is Calculated';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedCalculation_content => 'The system adds up:';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedCalculation_bullet1 => '**Service 1 duration** (e.g., 60 min)';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedCalculation_bullet2 => '**+ Service 2 duration** (e.g., 30 min)';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedCalculation_bullet3 => '**+ Buffer time** between services (5-10 min for cleanup)';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedCalculation_bullet4 => '**= Total appointment time** (e.g., 95-100 min)';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedExampleCalc_title => 'Example Calculation';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedExampleCalc_content => '**Haircut (60 min) + Beard Trim (30 min) + Buffer (5 min):**\n• Start: 9:00 AM\n• Haircut: 9:00 - 10:00\n• Buffer: 10:00 - 10:05 (cleanup)\n• Beard Trim: 10:05 - 10:35\n• **End: 10:35 AM**\n• Slot shown: 9:00 AM - 10:35 AM';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedWhen_title => 'When to Use Combined View';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedWhen_content => 'Combined View is perfect when:';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedWhen_bullet1 => '**You\'re ready to book** – See only realistic options';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedWhen_bullet2 => '**You have multiple services** – Let the system coordinate';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedWhen_bullet3 => '**You want simplicity** – One slot, one time, all services';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedWhen_bullet4 => '**You\'re booking for a group** – Ensure everyone is accommodated';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedBenefit_content => 'With Combined View, you **cannot** accidentally pick overlapping times. Every slot shown guarantees that all your services can be done in that block without conflicts.';

  @override
  String get docsTimeSlotsExplainedComparison_title => 'Regular vs Combined – Side by Side';

  @override
  String get docsTimeSlotsExplainedComparison_subtitle => 'See the difference clearly';

  @override
  String get docsTimeSlotsExplainedComparison_comparisonTable_title => 'Quick Comparison';

  @override
  String get docsTimeSlotsExplainedComparison_comparisonTable_content => '| Feature | Regular View | Combined View |\n|---------|--------------|---------------|\n| **Shows** | Slots per service | Slots for all services together |\n| **Duration** | Individual service time | Total time for all services |\n| **Risk of overlap** | High – you must check | None – guaranteed to work |\n| **Best for** | Exploring options | Confirming booking |\n| **When to use** | Early in planning | Ready to book |';

  @override
  String get docsTimeSlotsExplainedComparison_comparisonVisual_title => 'Visual Example – 2 Services';

  @override
  String get docsTimeSlotsExplainedComparison_comparisonVisual_content => '**REGULAR VIEW:**\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\nHaircut:    9:00┄┄10:00   9:30┄┄10:30   10:00┄┄11:00\nBeard Trim: 9:00┄┄9:30    9:30┄┄10:00   10:00┄┄10:30\n\n**COMBINED VIEW:**\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\nBoth:       9:00┄┄┄┄┄┄┄┄┄┄10:30\n            9:30┄┄┄┄┄┄┄┄┄┄11:00\n            10:00┄┄┄┄┄┄┄┄┄11:30';

  @override
  String get docsTimeSlotsExplainedComparison_comparisonExample_title => 'Real Booking Example';

  @override
  String get docsTimeSlotsExplainedComparison_comparisonExample_content => '**Sarah wants to book Haircut + Beard Trim for her son.**\n\nUsing **Regular View**, she might pick:\n• Haircut at 9:30 AM\n• Beard Trim at 10:00 AM\n❌ These overlap! The worker can\'t do both.\n\nUsing **Combined View**, she sees:\n• 9:30 AM - 10:35 AM ✅ Works perfectly\n• 10:00 AM - 11:05 AM ✅ Also works\n\nCombined View saves her from making a mistake!';

  @override
  String get docsTimeSlotsExplainedGroupTime_title => 'Time Slots for Group Bookings';

  @override
  String get docsTimeSlotsExplainedGroupTime_subtitle => 'How it works with multiple people';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeIntro_title => 'Groups Make It More Complex';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeIntro_content => 'When you\'re booking for multiple people, time slot calculation becomes more interesting. The system considers:';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeIntro_bullet1 => '**Number of people** (quantity)';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeIntro_bullet2 => '**Service duration × quantity**';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeIntro_bullet3 => '**Worker assignments** (same or different workers)';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeIntro_bullet4 => '**Buffer times** between each person\'s service';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeSameWorker_title => 'Example: Same Worker for Everyone';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeSameWorker_content => '**Family of 3 booking haircuts (45 min each) with the same worker:**\n• Person 1: 9:00 - 9:45\n• Buffer: 9:45 - 9:50\n• Person 2: 9:50 - 10:35\n• Buffer: 10:35 - 10:40\n• Person 3: 10:40 - 11:25\n• **Combined slot: 9:00 AM - 11:25 AM**';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeDiffWorkers_title => 'Example: Different Workers';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeDiffWorkers_content => '**Same family, but with 3 different workers:**\n• Worker A: Person 1 (9:00 - 9:45)\n• Worker B: Person 2 (9:00 - 9:45) at same time\n• Worker C: Person 3 (9:00 - 9:45) at same time\n• **Combined slot: 9:00 AM - 9:45 AM** (much shorter!)';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeCombined_title => 'Combined View for Groups';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeCombined_content => 'When booking for groups, Combined View is **especially valuable**. It shows only time blocks where ALL people can be served, with the correct total duration based on your worker choices.';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeTip_content => 'For large groups, choosing different workers can significantly reduce the total time needed. The system shows you the duration based on your worker selections.';

  @override
  String get docsTimeSlotsExplainedBufferTime_title => 'Understanding Buffer Time';

  @override
  String get docsTimeSlotsExplainedBufferTime_subtitle => 'Why there are gaps between appointments';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferExplained_title => 'What is Buffer Time?';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferExplained_content => 'Buffer time is a short gap (usually 5-15 minutes) between appointments. You won\'t see it in the slot times, but it\'s there behind the scenes.';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferPurpose_title => 'Why Buffer Time Matters';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferPurpose_content => 'Buffer time gives workers a moment to:';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferPurpose_bullet1 => '**Clean and sanitize** their workspace';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferPurpose_bullet2 => '**Prepare tools** for the next client';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferPurpose_bullet3 => '**Take a quick break** between appointments';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferPurpose_bullet4 => '**Handle any unexpected delays**';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferVisibility_title => 'Do You See Buffer Time?';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferVisibility_content => '**No!** Buffer time is invisible to you. The slot you see (e.g., 9:00 - 10:30) is the time you\'ll be at the shop. The system adds buffer automatically behind the scenes to ensure realistic scheduling.';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferExample_title => 'How Buffer Affects Availability';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferExample_content => '**Without buffer:**\n• 9:00 - 10:00 (Service A)\n• 10:00 - 11:00 (Service B) – No time to clean!\n\n**With 5-min buffer (invisible to you):**\n• 9:00 - 10:00 (Service A) – actually ends at 10:05\n• 10:05 - 11:05 (Service B) – starts after cleanup\n\nYou still see \"9:00 - 10:00\" and \"10:05 - 11:05\" as your appointment times.';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferFairness_content => 'Buffer time ensures workers aren\'t rushed and you get their full attention. It\'s a win-win for everyone!';

  @override
  String get docsTimeSlotsExplainedTimeFaq_title => 'Common Time Slot Questions';

  @override
  String get docsTimeSlotsExplainedTimeFaq_subtitle => 'Quick answers to frequent questions';

  @override
  String get docsTimeSlotsExplainedTimeFaq_timeFaq1_title => 'Why are some times not available?';

  @override
  String get docsTimeSlotsExplainedTimeFaq_timeFaq1_content => 'Times may be unavailable because:\n• The worker is already booked\n• The shop is closed (check opening hours)\n• There\'s not enough time before closing\n• The worker has marked themselves unavailable (vacation, break)';

  @override
  String get docsTimeSlotsExplainedTimeFaq_timeFaq2_title => 'Why do slots start at odd times like 9:05?';

  @override
  String get docsTimeSlotsExplainedTimeFaq_timeFaq2_content => 'Slots may start at unusual times because of buffer periods. For example, if a 9:00 appointment ends at 10:05 (including buffer), the next slot starts at 10:05.';

  @override
  String get docsTimeSlotsExplainedTimeFaq_timeFaq3_title => 'Can I book a slot that\'s shorter than shown?';

  @override
  String get docsTimeSlotsExplainedTimeFaq_timeFaq3_content => 'No, the slot duration shown is the minimum time needed for your services. You cannot book a shorter slot because there wouldn\'t be enough time.';

  @override
  String get docsTimeSlotsExplainedTimeFaq_timeFaq4_title => 'What if I need more time than the slot shows?';

  @override
  String get docsTimeSlotsExplainedTimeFaq_timeFaq4_content => 'If you need extra time (e.g., for a more complex service), contact the shop directly. They may have special arrangements.';

  @override
  String get docsTimeSlotsExplainedFaq_regularVsCombined_Q => 'When should I use Regular vs Combined View?';

  @override
  String get docsTimeSlotsExplainedFaq_regularVsCombined_A => 'Use **Regular View** when you\'re exploring options and want to see all possibilities. Switch to **Combined View** when you\'re ready to book and want to see only slots where all your services can be done together without conflicts.';

  @override
  String get docsTimeSlotsExplainedFaq_combinedNotShowing_Q => 'Why is Combined View not showing any slots?';

  @override
  String get docsTimeSlotsExplainedFaq_combinedNotShowing_A => 'If Combined View shows no slots, it means there\'s no single time block where all your selected services can be done together. Try:\n• Selecting a different date\n• Reducing the number of services\n• Choosing different workers\n• Being flexible with morning/afternoon times';

  @override
  String get docsTimeSlotsExplainedFaq_buffer_Q => 'What is buffer time and why is it needed?';

  @override
  String get docsTimeSlotsExplainedFaq_buffer_A => 'Buffer time is a short gap (5-15 minutes) between appointments that allows workers to clean their workspace, prepare tools, and take brief breaks. It ensures quality service and a clean environment for every client. You won\'t see it in your appointment time, but it\'s built into the schedule.';

  @override
  String get docsTimeSlotsExplainedFaq_duration_Q => 'How is the total duration calculated?';

  @override
  String get docsTimeSlotsExplainedFaq_duration_A => 'For multiple services, the system adds:\n• Duration of Service A\n• Duration of Service B (and so on)\n• Buffer time between each service\nThe result is your total appointment time.';

  @override
  String get docsTimeSlotsExplainedFaq_group_Q => 'How does time work for group bookings?';

  @override
  String get docsTimeSlotsExplainedFaq_group_A => 'For groups, total time = (service duration × number of people) + buffer times between people. If you choose different workers who can work in parallel, the total time may be much shorter.';

  @override
  String get docsTimeSlotsExplainedFaq_amPm_Q => 'Are times shown in my local time?';

  @override
  String get docsTimeSlotsExplainedFaq_amPm_A => 'Yes! All times shown in the app are automatically converted to your device\'s local timezone. You don\'t need to worry about timezone conversions.';

  @override
  String get docsTimeSlotsExplainedFaq_lastSlot_Q => 'Why can\'t I book the last slot of the day?';

  @override
  String get docsTimeSlotsExplainedFaq_lastSlot_A => 'The last slot must end before the shop closes, including buffer time. If a service takes 1 hour with 5 min buffer, the last possible start time is 55 minutes before closing.';

  @override
  String get docsTimeSlotsExplainedFaq_change_Q => 'Can I change my time after booking?';

  @override
  String get docsTimeSlotsExplainedFaq_change_A => 'Yes, you can reschedule up to 24 hours before your appointment. Go to \"My Bookings\", find your booking, and tap \"Reschedule\". Available times will be shown.';

  @override
  String get docsTimeSlotsExplainedFaq_slotDisappeared_Q => 'A slot I wanted disappeared – what happened?';

  @override
  String get docsTimeSlotsExplainedFaq_slotDisappeared_A => 'Someone else may have booked it while you were deciding. Slots are reserved only after payment is complete. Try a different time or date.';

  @override
  String get docsTimeSlotsExplainedFaq_workers_Q => 'Does the time change if I choose a different worker?';

  @override
  String get docsTimeSlotsExplainedFaq_workers_A => 'Yes, different workers may have different availability. If you change workers, the system will show times when that worker is free. You may need to adjust your time.';

  @override
  String get docsCreateProductOverview_title => 'Getting Started Selling Products';

  @override
  String get docsCreateProductOverview_subtitle => 'Learn how to list and sell items';

  @override
  String get docsCreateProductOverview_productWelcomeTitle => 'Welcome to Product Selling';

  @override
  String get docsCreateProductOverview_productWelcomeContent => 'Sell physical products directly to customers in your area. From handmade items to retail goods, you can reach customers looking for what you offer.';

  @override
  String get docsCreateProductOverview_phoneRequirementTitle => 'You Need a Verified Phone Number';

  @override
  String get docsCreateProductOverview_phoneRequirementContent => 'Before you can start selling products, you must verify your phone number. This is for customer communication and to validate your identity.';

  @override
  String get docsCreateProductOverview_addPhoneNumberTitle => 'How to Add Your Phone Number';

  @override
  String get docsCreateProductOverview_addPhoneNumberContent => 'Go to your profile settings and add your phone number. You\'ll receive a verification code via SMS to confirm it\'s really your number. This takes just a minute.';

  @override
  String get docsCreateProductOverview_whyPhoneVerifiedTitle => 'Why Phone Verification?';

  @override
  String get docsCreateProductOverview_whyPhoneVerifiedContent => 'A verified phone number builds customer trust and allows us to contact you if there are issues. It also helps prevent fraud.';

  @override
  String get docsCreateProductOverview_phoneImportantContent => 'You cannot list products until you have a verified phone number. This is required for all sellers.';

  @override
  String get docsCreateProductBasics_title => 'Basic Product Information';

  @override
  String get docsCreateProductBasics_subtitle => 'What to tell customers about your product';

  @override
  String get docsCreateProductBasics_productNameTitle => 'Product Name';

  @override
  String get docsCreateProductBasics_productNameContent => 'Enter your product name clearly. Customers search by product name, so be specific. Example: \"Handmade Leather Wallet - Brown\" instead of just \"Wallet\".';

  @override
  String get docsCreateProductBasics_productDescriptionTitle => 'Product Description';

  @override
  String get docsCreateProductBasics_productDescriptionContent => 'Write a detailed description. Tell customers what it is, what it\'s made of, how to use it, and why it\'s good. Be honest about condition (new, used, refurbished).';

  @override
  String get docsCreateProductBasics_categorySelectionTitle => 'Choose a Category';

  @override
  String get docsCreateProductBasics_categorySelectionContent => 'Select the right category. Customers browse by category to find items, so accuracy matters. Pick the most specific category available.';

  @override
  String get docsCreateProductBasics_productConditionTitle => 'Product Condition';

  @override
  String get docsCreateProductBasics_productConditionContent => 'Be clear about condition: New (never used), Like New (used once), Good (light wear), Fair (visible wear), or As-Is. Honesty builds trust.';

  @override
  String get docsCreateProductPricingStock_title => 'Price & Availability';

  @override
  String get docsCreateProductPricingStock_subtitle => 'Set your price and manage inventory';

  @override
  String get docsCreateProductPricingStock_pricingTitle => 'Set Your Price';

  @override
  String get docsCreateProductPricingStock_pricingContent => 'Set a fair price based on condition, market value, and local demand. Customers can see similar items, so competitive pricing helps.';

  @override
  String get docsCreateProductPricingStock_currencyTitle => 'Currency';

  @override
  String get docsCreateProductPricingStock_currencyContent => 'Prices are shown in your shop\'s currency. Make sure your shop currency is set correctly before adding products.';

  @override
  String get docsCreateProductPricingStock_stockQuantityTitle => 'Stock Quantity';

  @override
  String get docsCreateProductPricingStock_stockQuantityContent => 'Enter how many items you have. When stock runs out, the product shows as unavailable. Update this as you sell items.';

  @override
  String get docsCreateProductPricingStock_stockTipContent => 'Keep stock accurate. Customers get frustrated if they order something out of stock. Update regularly as you sell.';

  @override
  String get docsCreateProductPhotos_title => 'Product Photos';

  @override
  String get docsCreateProductPhotos_subtitle => 'Show customers what they\'re buying';

  @override
  String get docsCreateProductPhotos_photosImportanceTitle => 'Photos Matter Most';

  @override
  String get docsCreateProductPhotos_photosImportanceContent => 'Good photos are critical. Customers decide whether to buy based on photos. Poor photos = fewer sales.';

  @override
  String get docsCreateProductPhotos_whatPhotosTitle => 'What to Photograph';

  @override
  String get docsCreateProductPhotos_whatPhotosContent => 'Take photos that show the real product:';

  @override
  String get docsCreateProductPhotos_whatPhotosBullet1 => 'Full product from multiple angles';

  @override
  String get docsCreateProductPhotos_whatPhotosBullet2 => 'Close-ups of details and quality';

  @override
  String get docsCreateProductPhotos_whatPhotosBullet3 => 'Photos showing condition (if used)';

  @override
  String get docsCreateProductPhotos_whatPhotosBullet4 => 'Photos next to something for scale (like a coin or hand)';

  @override
  String get docsCreateProductPhotos_whatPhotosBullet5 => 'Photos of any damage or wear (honesty builds trust)';

  @override
  String get docsCreateProductPhotos_photoTipsTitle => 'Photo Quality Tips';

  @override
  String get docsCreateProductPhotos_photoTipsContent => 'Use natural light. Take photos on a clean background. Show colors accurately. Don\'t use filters that change how the product looks.';

  @override
  String get docsCreateProductPhotos_photoCountTitle => 'Upload Multiple Photos';

  @override
  String get docsCreateProductPhotos_photoCountContent => 'Upload at least 3-5 photos. The first photo is most important - make it clear and appealing. Customers scroll through all photos.';

  @override
  String get docsCreateProductPhotos_photoHonestyContent => 'Honest photos = happy customers. Show exactly what customers will receive, including any flaws.';

  @override
  String get docsCreateProductStatus_title => 'List Your Product';

  @override
  String get docsCreateProductStatus_subtitle => 'Make your product visible to customers';

  @override
  String get docsCreateProductStatus_activeProductTitle => 'Make Your Product Active';

  @override
  String get docsCreateProductStatus_activeProductContent => 'Before customers can see your product, you must mark it as \"Active\". Inactive products are hidden from search.';

  @override
  String get docsCreateProductStatus_whenToActivateTitle => 'When to Activate';

  @override
  String get docsCreateProductStatus_whenToActivateContent => 'Only activate when you have: product name, description, price, photos, and correct stock. If you\'re not ready to sell, keep it inactive.';

  @override
  String get docsCreateProductStatus_pauseListingTitle => 'Pause a Listing';

  @override
  String get docsCreateProductStatus_pauseListingContent => 'If stock runs out or you need to pause, mark it inactive. Customers won\'t see it, but you can reactivate it anytime.';

  @override
  String get docsCreateProductStatus_activeTipContent => 'Only active products with photos and good descriptions get bookmarks and purchases. Make your listings complete before activating.';

  @override
  String get docsCreateProductFaq_title => 'Common Questions';

  @override
  String get docsCreateProductFaq_subtitle => 'Get help with selling products';

  @override
  String get docsCreateProductFaq_howLongTitle => 'How long until my product sells?';

  @override
  String get docsCreateProductFaq_howLongContent => 'It depends on your price, photos, and demand. Good photos + competitive price = faster sales.';

  @override
  String get docsCreateProductFaq_paymentTitle => 'How do I get paid?';

  @override
  String get docsCreateProductFaq_paymentContent => 'When a customer buys, payment goes to your account. You\'ll receive the amount (minus any platform fees) after the transaction completes.';

  @override
  String get docsCreateProductFaq_shippingTitle => 'Do I have to ship?';

  @override
  String get docsCreateProductFaq_shippingContent => 'That depends on your shop settings. You can choose local delivery or shipping. Customers see shipping options before buying.';

  @override
  String get docsCreateProductFaq_editAfterTitle => 'Can I edit after listing?';

  @override
  String get docsCreateProductFaq_editAfterContent => 'Yes! You can edit price, description, photos, and stock anytime. Changes take effect immediately.';

  @override
  String get docsCreateProductFaq_reviewsTitle => 'Do products get reviews?';

  @override
  String get docsCreateProductFaq_reviewsContent => 'Yes. Customers rate products and leave reviews after purchase. Good reviews help future customers trust you.';

  @override
  String get docsCreateProductFaqModel_question1 => 'Do I need a phone number to sell products?';

  @override
  String get docsCreateProductFaqModel_answer1 => 'Yes. You must verify a phone number before you can list products. This is for customer communication and security.';

  @override
  String get docsCreateProductFaqModel_category1 => 'Getting Started';

  @override
  String get docsCreateProductFaqModel_question2 => 'What makes a good product listing?';

  @override
  String get docsCreateProductFaqModel_answer2 => 'Good photos, accurate description, honest condition info, fair pricing, and correct stock quantity. Great photos are the most important.';

  @override
  String get docsCreateProductFaqModel_category2 => 'Setup';

  @override
  String get docsCreateProductFaqModel_question3 => 'Can I sell both products and services?';

  @override
  String get docsCreateProductFaqModel_answer3 => 'Yes! You can run a shop with services, a shop with products, or both. Set up your shop to offer what you want.';

  @override
  String get docsCreateProductFaqModel_category3 => 'Setup';

  @override
  String get docsCreateProductFaqModel_question4 => 'How do I remove a product?';

  @override
  String get docsCreateProductFaqModel_answer4 => 'Mark it as inactive to hide it from customers. If you want to delete it completely, contact support.';

  @override
  String get docsCreateProductFaqModel_category4 => 'Management';

  @override
  String get docsCreateProductFaqModel_question5 => 'What if someone buys but I\'m out of stock?';

  @override
  String get docsCreateProductFaqModel_answer5 => 'Keep your stock accurate to prevent this. If it happens, contact the customer immediately to cancel or offer alternatives.';

  @override
  String get docsCreateProductFaqModel_category5 => 'Management';

  @override
  String get docsCreateProductFaqModel_question6 => 'Can customers return products?';

  @override
  String get docsCreateProductFaqModel_answer6 => 'That\'s up to your shop policy. You can set return policies in your shop settings. Be clear so customers know before buying.';

  @override
  String get docsCreateProductFaqModel_category6 => 'Management';
}
