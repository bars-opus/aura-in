// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Nano Embryo';

  @override
  String get appDescription => 'Ihre innovative App';

  @override
  String get commonContinue => 'Weiter';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonLogin => 'Anmelden';

  @override
  String get commonLogout => 'Abmelden';

  @override
  String get commonDone => 'Erledigt';

  @override
  String get commonRetry => 'Wiederholen';

  @override
  String get commonAccept => 'Akzeptieren';

  @override
  String get commonReject => 'Ablehnen';

  @override
  String get introGetStarted => 'Starten';

  @override
  String get actionsBlock => 'Benutzer blockieren';

  @override
  String get actionsReport => 'Benutzer melden';

  @override
  String get actionsSend => 'An Chat senden';

  @override
  String get actionsShare => 'Teilen';

  @override
  String get actionsCopy => 'Link kopieren';

  @override
  String get appInfoVersion => 'Version';

  @override
  String get appInfoReleased => 'Veröffentlicht';

  @override
  String get appInfoPackageName => 'Paketname';

  @override
  String get appInfoDeveloper => 'Entwicklername';

  @override
  String get appInfoSupportEmail => 'Support-E-Mail';

  @override
  String get appInfoTechnicalDetails => 'Technische Details';

  @override
  String get appInfoBundleID => 'Bundle-ID';

  @override
  String get appInfoBuildVersion => 'Build-Version';

  @override
  String get appInfoBuildNumber => 'Build-Nummer';

  @override
  String get appInfoReleaseDate => 'Veröffentlichungsdatum';

  @override
  String get appInfoAppSize => 'App-Größe';

  @override
  String appInfoOverview(String appName) {
    return '$appName ist eine moderne mobile Anwendung, die mit robuster Sicherheit und Funktionalität entwickelt wurde und darauf ausgelegt ist, eine außergewöhnliche Benutzererfahrung mit sauberer Architektur und Leistungsoptimierung zu bieten.';
  }

  @override
  String introTitle(String appName) {
    return 'Willkommen bei $appName';
  }

  @override
  String get introFeature1Title => 'Sehen Sie Ihren Fortschritt';

  @override
  String get introFeature1Description => 'Verfolgen Sie Ihre Entwicklungsmeilensteine mit detaillierten Analysen und Einblicken';

  @override
  String get introFeature2Title => 'Vorlagen erkunden';

  @override
  String get introFeature2Description => 'Entdecken Sie vorgefertigte Komponenten und Bildschirme für schnelle Entwicklung';

  @override
  String get introFeature3Title => 'Schnell starten';

  @override
  String get introFeature3Description => 'Starten Sie Ihr Projekt mit Null-Konfiguration und Best Practices';

  @override
  String get appleSignIn => 'Mit Apple anmelden';

  @override
  String get googleSignIn => 'Mit Google anmelden';

  @override
  String get appleRegister => 'Mit Apple registrieren';

  @override
  String get googleRegister => 'Mit Google registrieren';

  @override
  String get emailAndPassword => 'E-Mail und Passwort eingeben';

  @override
  String get signInTitle => 'Anmelden';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get legalConsentPart1 => 'Bitte lesen Sie die ';

  @override
  String get legalConsentPart2 => 'Allgemeinen Geschäftsbedingungen';

  @override
  String legalConsentPart3(String appName) {
    return ' und anderen rechtlichen Dokumente, die Ihre Nutzung von $appName regeln.';
  }

  @override
  String get emailTitle => 'E-Mail';

  @override
  String get passwordTitle => 'Passwort';

  @override
  String get loginEmailLabel => 'E-Mail-Adresse';

  @override
  String get loginEmailHint => 'Geben Sie Ihre E-Mail ein';

  @override
  String get loginPasswordLabel => 'Passwort';

  @override
  String get loginPasswordHint => 'Geben Sie Ihr Passwort ein';

  @override
  String get loginForgotPasswordPart1 => 'Haben Sie Ihr Passwort vergessen? ';

  @override
  String get loginForgotPasswordPart2 => 'Hier tippen';

  @override
  String get loginForgotPasswordPart3 => ' um Ihr Passwort zurückzusetzen?';

  @override
  String get commonConfirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get commonConfirmPasswordHint => 'Bitte bestätigen Sie Ihr Passwort';

  @override
  String get commonPasswordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get commonPasswordConfirmRequired => 'Bitte bestätigen Sie Ihr Passwort';

  @override
  String commonFieldIsValid(String field) {
    return '$field ist gültig';
  }

  @override
  String get commonPleaseWait => 'Bitte warten Sie, bis der aktuelle Vorgang abgeschlossen ist';

  @override
  String get commonUnexpectedError => 'Ein unerwarteter Fehler ist aufgetreten. Bitte versuchen Sie es erneut.';

  @override
  String get commonSomethingWentWrong => 'Etwas ist schief gelaufen. Bitte versuchen Sie es erneut.';

  @override
  String get commonEnterEmailAndRetry => 'Bitte geben Sie Ihre E-Mail-Adresse ein und versuchen Sie es erneut';

  @override
  String get commonLearnMore => 'Mehr erfahren';

  @override
  String get authSignUpVerificationSent => 'Bestätigungsmail gesendet! Bitte überprüfen Sie Ihren Posteingang.';

  @override
  String authSignUpFailed(String error) {
    return 'Registrierung fehlgeschlagen: $error';
  }

  @override
  String get authForgotPasswordTitle => 'Passwort vergessen?';

  @override
  String get authForgotPasswordSubtitle => 'Geben Sie Ihre E-Mail-Adresse ein und wir senden Ihnen einen Link zum Zurücksetzen Ihres Passworts.';

  @override
  String get authSendResetLink => 'Zurücksetzen-Link senden';

  @override
  String get authBackToSignIn => 'Zurück zur Anmeldung';

  @override
  String get authUsernameScreenTitle => 'Benutzernamen wählen';

  @override
  String get authUsernameScreenSubtitle => 'So sehen dich andere. Du kannst es später ändern.';

  @override
  String get authUsernameLabel => 'Benutzername';

  @override
  String get authUsernameHint => 'Geben Sie einen Benutzernamen ein';

  @override
  String authUsernameMinLength(int min) {
    return 'Benutzername muss mindestens $min Zeichen lang sein';
  }

  @override
  String authUsernameMaxLength(int max) {
    return 'Benutzername darf höchstens $max Zeichen lang sein';
  }

  @override
  String get authUsernameFormatError => 'Nur Buchstaben, Zahlen und Unterstriche sind erlaubt';

  @override
  String get authUsernameTaken => 'Dieser Benutzername ist bereits vergeben';

  @override
  String get authUsernameCheckError => 'Verfügbarkeit konnte nicht überprüft werden. Bitte versuchen Sie es erneut.';

  @override
  String get authUsernameSaveError => 'Konnte Ihren Benutzernamen nicht speichern. Bitte versuchen Sie es erneut.';

  @override
  String get authUsernameSavedSuccess => 'Benutzername erfolgreich gespeichert!';

  @override
  String get authUpdatePasswordTitle => 'Neues Passwort erstellen';

  @override
  String get authUpdatePasswordButton => 'Passwort aktualisieren';

  @override
  String get authUpdatePasswordSuccess => 'Passwort erfolgreich aktualisiert. Bitte melden Sie sich erneut an.';

  @override
  String get authPasswordResetSentTitle => 'Überprüfen Sie Ihre E-Mail';

  @override
  String get authPasswordResetSentBody => 'Wir haben einen Link zum Zurücksetzen des Passworts gesendet an';

  @override
  String get authPasswordResetSentNote => 'Tippen Sie auf den Link in der E-Mail, um ein neues Passwort festzulegen. Der Link verfällt in 1 Stunde.';

  @override
  String get authGuestHello => 'Hallo!';

  @override
  String authGuestOverview(String appName) {
    return 'Sie durchsuchen $appName als Gast. Melden Sie sich an oder erstellen Sie ein Konto, um Ihren Shop zu verwalten – es dauert weniger als 5 Sekunden. Wir haben eine Vielzahl von Tools, um Ihr Geschäft zu entwickeln, alle kostenlos.';
  }

  @override
  String authIntroTitle(String appName) {
    return 'Willkommen bei\n$appName';
  }

  @override
  String get authIntroSubtitle => 'Willkommen auf der Plattform, die wir für Sie gebaut haben. Genießen Sie und haben Sie Spaß – das Beste wartet auf Sie.';

  @override
  String get authReadLegalities => 'Rechtliche Bestimmungen lesen';

  @override
  String get authPasswordRequired => 'Bitte geben Sie Ihr Passwort ein';

  @override
  String get authCreatingAccount => 'Konto wird erstellt...';

  @override
  String get authAccountCreatedSuccess => 'Konto erfolgreich erstellt!';

  @override
  String get authCheckEmailToConfirm => 'Bitte überprüfen Sie Ihre E-Mail, um Ihr Konto zu bestätigen';

  @override
  String get authSigningInWithGoogle => 'Mit Google anmelden...';

  @override
  String authGoogleSignInFailed(String error) {
    return 'Google-Anmeldung fehlgeschlagen: $error';
  }

  @override
  String get authAuthenticatingWithApple => 'Mit Apple authentifizieren...';

  @override
  String authAppleSignInFailed(String error) {
    return 'Apple-Anmeldung fehlgeschlagen: $error';
  }

  @override
  String get authSendingResetEmail => 'Zurücksetzen-E-Mail wird gesendet...';

  @override
  String get authResetEmailSent => 'Zurücksetzen-E-Mail gesendet. Überprüfen Sie Ihren Posteingang.';

  @override
  String authPasswordResetFailed(String error) {
    return 'Passwort zurücksetzen fehlgeschlagen: $error';
  }

  @override
  String get authVerifyEmailTitle => 'Überprüfen Sie Ihre E-Mail';

  @override
  String get authVerifyEmailSubtitle => 'Wir haben einen Bestätigungslink gesendet an';

  @override
  String get authVerifyEmailNote => 'Tippen Sie auf den Link in der E-Mail, um Ihr Konto zu bestätigen und fortzufahren.';

  @override
  String get authConfirmationResent => 'Bestätigungsmail erneut gesendet. Überprüfen Sie Ihren Posteingang.';

  @override
  String get authResendFailed => 'Fehler beim erneuten Senden der E-Mail. Bitte versuchen Sie es erneut.';

  @override
  String get authResendEmailButton => 'Bestätigungsmail erneut senden';

  @override
  String authResendEmailCooldown(int seconds) {
    return 'E-Mail erneut senden (${seconds}s)';
  }

  @override
  String get currencySelectorPlaceholder => 'Währung wählen';

  @override
  String get currencySelectorNoSelected => 'Keine Währung ausgewählt';

  @override
  String get currencySelectorTitle => 'Währung wählen';

  @override
  String get currencySelectorSearchHint => 'Nach Währung, Code oder Flagge suchen...';

  @override
  String get currencySelectorNoResults => 'Keine Währungen gefunden';

  @override
  String get discoverScreenTitle => 'Entdecken';

  @override
  String get discoverSearchHint => 'Suchen...';

  @override
  String get discoverAllShopsRegion => 'Alle Shops in Ihrer Region';

  @override
  String get discoverAllFreelancers => 'Alle Freiberufler in Ihrer Nähe';

  @override
  String get discoverMarketplaceTitle => 'Marktplatz';

  @override
  String get discoverMarketplaceSubtitle => 'Kaufen Sie Schönheitsprodukte mit Nachnahme';

  @override
  String get discoverBrowseProducts => 'Produkte durchsuchen';

  @override
  String get discoverMyOrders => 'Meine Bestellungen';

  @override
  String get discoverCartTooltip => 'Einkaufskorb';

  @override
  String get homeScheduleTabLabel => 'Zeitplan';

  @override
  String get homeDashboardTabLabel => 'Dashboard';

  @override
  String get homeMapTabLabel => 'Karte';

  @override
  String get validationRequired => 'Dieses Feld ist erforderlich';

  @override
  String get validationEmailInvalid => 'Bitte geben Sie eine gültige E-Mail-Adresse ein';

  @override
  String validationPasswordLength(int minLength) {
    return 'Das Passwort muss mindestens $minLength Zeichen lang sein';
  }

  @override
  String get validationPasswordUppercase => 'Das Passwort muss mindestens einen Großbuchstaben enthalten';

  @override
  String get loggingInIndicatorText => 'Anmeldung läuft...';

  @override
  String get loginSuccessful => 'Anmeldung erfolgreich!\nWillkommen zurück';

  @override
  String get errorLoginFailed => 'Anmeldung fehlgeschlagen. Bitte überprüfen Sie Ihre Anmeldedaten';

  @override
  String get errorNetwork => 'Netzwerkfehler. Bitte überprüfen Sie Ihre Verbindung';

  @override
  String get homeTitle => 'Startseite';

  @override
  String get profileTitle => 'Profil';

  @override
  String get chatTitle => 'Chat';

  @override
  String get editProfileNameFieldTitle => 'Name';

  @override
  String get editProfileNameFieldLabel => 'Vollständiger Name';

  @override
  String get editProfileUserFieldNameTitle => 'Benutzername';

  @override
  String get editProfileUsernameFieldLabel => '@benutzername';

  @override
  String get editProfileBioFieldTitle => 'Biografie';

  @override
  String get editProfileBioFieldLabel => 'Erzählen Sie uns von sich';

  @override
  String get editProfileScreenTitle => 'Profil bearbeiten';

  @override
  String get editProfileSettingTitle => 'Kontoeinstellungen';

  @override
  String get editProfileSettingSubtitle => 'Verwalten Sie Ihr Konto';

  @override
  String get editProfileScreenEditShopTitle => 'Shop bearbeiten';

  @override
  String get editProfileScreenEditShopSubtitle => 'Ändern Sie Ihre Shop-Informationen';

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
  String get languageScreenSubtitle => 'Wählen Sie Ihre bevorzugte Sprache für die App-Oberfläche. Dies wirkt sich nicht auf die Geräteeinstellungen aus.';

  @override
  String get languageScreeUseDeviceLang => 'Gerätsprache verwenden.';

  @override
  String get languageScreeUseDeviceLangNote => 'Dies wird auf Ihre Gerätesystemsprache zurückgesetzt.';

  @override
  String get settingsScreenTitle => 'Einstellungen';

  @override
  String get accountSectionTitle => 'Konto';

  @override
  String get accountSectionSubtitle => '';

  @override
  String get profileItemTitle => 'Profil';

  @override
  String get profileItemSubtitle => 'Verwalten Sie Ihre persönlichen Daten';

  @override
  String get locationItemTitle => 'Standort ändern';

  @override
  String get locationItemSubtitle => 'Ändern Sie Ihre aktuelle Stadt';

  @override
  String get saveItemTitle => 'Gespeicherte Inhalte';

  @override
  String get saveItemSubtitle => 'Inhalte, die Sie gespeichert haben';

  @override
  String get notificationsItemTitle => 'Benachrichtigungen';

  @override
  String get notificationsItemSubtitle => 'Push- und E-Mail-Benachrichtigungen verwalten';

  @override
  String get blockedItemTitle => 'Blockierte Konten';

  @override
  String get blockedItemSubtitle => 'Konten, die Sie blockiert haben';

  @override
  String get qrCodeItemTitle => 'QR-Code teilen';

  @override
  String get qrCodeItemSubtitle => 'Teilen Sie Ihren Konto-QR-Code';

  @override
  String get shareProfileItemTitle => 'Profil teilen';

  @override
  String get shareProfileItemSubtitle => 'Teilen Sie Ihr Profil mit Freunden';

  @override
  String get appSettingsSectionTitle => 'App-Einstellungen';

  @override
  String get appSettingsSectionSubtitle => 'Passen Sie Ihre Erfahrung an';

  @override
  String get themeItemTitle => 'Design';

  @override
  String get themeItemSubtitle => 'Hell, Dunkel oder System';

  @override
  String get languageItemTitle => 'Sprache';

  @override
  String get languageItemSubtitle => 'App-Sprache ändern';

  @override
  String get biometricItemTitle => 'Biometrische Anmeldung';

  @override
  String get biometricItemSubtitle => 'Verwenden Sie Face ID oder Touch ID';

  @override
  String get supportSectionTitle => 'Support';

  @override
  String get supportSectionSubtitle => '';

  @override
  String get guideItemTitle => 'Benutzerhandbuch';

  @override
  String get guideItemSubtitle => 'Dokumentation und Tutorials';

  @override
  String get helpItemTitle => 'Support kontaktieren';

  @override
  String get helpItemSubtitle => 'Hilfe zur App erhalten';

  @override
  String get feedbackItemTitle => 'Feedback senden';

  @override
  String get feedbackItemSubtitle => 'Teilen Sie Ihre Gedanken mit';

  @override
  String get rateItemTitle => 'App bewerten';

  @override
  String get rateItemSubtitle => 'Eine Bewertung hinterlassen';

  @override
  String appInfoItemTitle(String appName) {
    return 'Über $appName';
  }

  @override
  String get appInfoItemSubtitle => 'Technische Informationen';

  @override
  String get legalSectionTitle => 'Rechtliches';

  @override
  String get legalSectionSubtitle => '';

  @override
  String get termsItemTitle => 'Bedingungen, Datenschutz & Richtlinien';

  @override
  String get termsItemSubtitle => 'Lesen Sie unsere Bedingungen';

  @override
  String get licensesItemTitle => 'Open-Source-Lizenzen';

  @override
  String get licensesItemSubtitle => 'Drittanbieter-Bibliotheken und Lizenzen';

  @override
  String get accountActionsSectionTitle => 'Kontoaktionen';

  @override
  String get accountActionsSectionSubtitle => '';

  @override
  String get updatePasswordItemTitle => 'Passwort aktualisieren';

  @override
  String get updatePasswordItemSubtitle => 'Ändern Sie Ihr aktuelles Kontopasswort';

  @override
  String get deactivateItemTitle => 'Deaktivieren';

  @override
  String get deactivateItemSubtitle => 'Ihr Konto vorübergehend ausblenden und deaktivieren';

  @override
  String get deleteItemTitle => 'Konto löschen';

  @override
  String get deleteItemSubtitle => 'Dauerhafte Kontolöschung anfordern';

  @override
  String get logoutItemTitle => 'Abmelden';

  @override
  String get logoutItemSubtitle => 'Von Ihrem Konto abmelden';

  @override
  String get logoutConfirmTitle => 'Möchten Sie sich wirklich abmelden?';

  @override
  String get logoutConfirmMessage => 'Sie müssen sich erneut anmelden, um auf Ihr Konto und Ihre Daten zuzugreifen.';

  @override
  String get logoutConfirmButton => 'Abmelden';

  @override
  String get logoutSuccessMessage => 'Erfolgreich abgemeldet';

  @override
  String logoutFailedMessage(String error) {
    return 'Abmelden fehlgeschlagen: $error';
  }

  @override
  String get accountDeactivateTitle => 'Konto deaktivieren';

  @override
  String get accountDeleteTitle => 'Konto löschen';

  @override
  String get accountRestoreTitle => 'Konto wiederherstellen';

  @override
  String get accountDeactivateWarningTitle => 'Ihr Konto wird ausgeblendet';

  @override
  String get accountDeactivateWarningBody => 'Ihr Profil, Ihre Shops, Produkte, Freelancer-Anzeige und Buchungslinks werden ausgeblendet. Sie können den Zugriff wiederherstellen, indem Sie sich erneut anmelden.';

  @override
  String get accountDeleteWarningTitle => 'Die Löschung wird für 30 Tage geplant';

  @override
  String get accountDeleteWarningBody => 'Ihre öffentliche Präsenz wird jetzt ausgeblendet. Sie können Ihr Konto innerhalb von 30 Tagen wiederherstellen; danach werden persönliche Profildaten entfernt.';

  @override
  String get accountPasswordConfirmLabel => 'Passwort bestätigen';

  @override
  String get accountPasswordConfirmHint => 'Geben Sie Ihr Passwort ein';

  @override
  String accountPhraseConfirmLabel(String phrase) {
    return 'Geben Sie $phrase zur Bestätigung ein';
  }

  @override
  String get accountReasonLabel => 'Grund (optional)';

  @override
  String get accountReasonHint => 'Sagen Sie uns, warum Sie gehen';

  @override
  String accountPhraseMismatch(String phrase) {
    return 'Geben Sie $phrase ein, um fortzufahren';
  }

  @override
  String get accountActionBlocked => 'Lösen Sie aktive Buchungen, Bestellungen oder Auszahlungen, bevor Sie fortfahren.';

  @override
  String get accountActionLoadFailed => 'Die Kontoanforderungen konnten nicht geladen werden. Bitte versuchen Sie es erneut.';

  @override
  String get accountActionGenericError => 'Diese Kontoaktion konnte nicht abgeschlossen werden. Bitte versuchen Sie es erneut.';

  @override
  String get accountRecentAuthRequired => 'Bitte melden Sie sich erneut an, bevor Sie fortfahren.';

  @override
  String get accountReasonTooLong => 'Der Grund darf höchstens 1000 Zeichen lang sein.';

  @override
  String get accountDeactivateButton => 'Konto deaktivieren';

  @override
  String get accountDeleteButton => 'Löschung anfordern';

  @override
  String get accountDeactivatedSuccess => 'Ihr Konto wurde deaktiviert.';

  @override
  String get accountDeletionRequestedSuccess => 'Die Kontolöschung wurde geplant.';

  @override
  String get accountRestoreButton => 'Konto wiederherstellen';

  @override
  String get accountRestoredSuccess => 'Ihr Konto wurde wiederhergestellt.';

  @override
  String get accountRestoreFailed => 'Dieses Konto konnte nicht wiederhergestellt werden.';

  @override
  String get accountRestoreMissingProfile => 'Ihr Profil konnte nicht geladen werden.';

  @override
  String get accountDeactivatedTitle => 'Konto deaktiviert';

  @override
  String get accountDeactivatedBody => 'Ihr Konto ist ausgeblendet. Stellen Sie es wieder her, um die App weiter zu verwenden.';

  @override
  String get accountPendingDeleteTitle => 'Konto zur Löschung vorgemerkt';

  @override
  String accountPendingDeleteBody(String date) {
    return 'Ihr Konto ist zur Löschung am $date geplant. Stellen Sie es vorher wieder her, um es zu behalten.';
  }

  @override
  String get accountDeletedTitle => 'Konto gelöscht';

  @override
  String get accountDeletedBody => 'Dieses Konto wurde gelöscht und kann nicht mehr wiederhergestellt werden.';

  @override
  String get accountBlockersTitle => 'Lösen Sie zuerst diese Punkte';

  @override
  String accountBlockerActiveBookings(int count) {
    return '$count aktive Buchung(en)';
  }

  @override
  String accountBlockerOwnedShopActiveBookings(int count) {
    return '$count aktive Shop-Buchung(en)';
  }

  @override
  String accountBlockerActiveOrders(int count) {
    return '$count aktive Bestellung(en)';
  }

  @override
  String accountBlockerOwnedShopActiveOrders(int count) {
    return '$count aktive Shop-Bestellung(en)';
  }

  @override
  String accountBlockerActiveWithdrawals(int count) {
    return '$count ausstehende Auszahlung(en)';
  }

  @override
  String get loadingDefaultMessage => 'Laden...';

  @override
  String emptyStateNoDataTitle(String dataType) {
    return 'Noch keine $dataType';
  }

  @override
  String emptyStateNoDataSubtitle(String dataType) {
    return 'Wenn $dataType verfügbar werden, erscheinen sie hier.';
  }

  @override
  String get emptyStateNoResultsTitle => 'Keine Ergebnisse gefunden';

  @override
  String emptyStateNoResultsSubtitle(String dataType) {
    return 'Versuchen Sie, Ihre Suche oder Filter anzupassen, um $dataType zu finden.';
  }

  @override
  String get emptyStateNoInternetTitle => 'Keine Internetverbindung';

  @override
  String get emptyStateNoInternetSubtitle => 'Überprüfen Sie Ihre Verbindung und versuchen Sie es erneut.';

  @override
  String get emptyStateNoFavoritesTitle => 'Noch keine Favoriten';

  @override
  String get emptyStateNoFavoritesSubtitle => 'Beginnen Sie mit dem Hinzufügen von Elementen zu Ihrer Favoritenliste.';

  @override
  String get emptyStateNoMessagesTitle => 'Keine Nachrichten';

  @override
  String get emptyStateNoMessagesSubtitle => 'Starten Sie eine Unterhaltung, um hier Nachrichten zu sehen.';

  @override
  String get emptyStateRefresh => 'Aktualisieren';

  @override
  String get emptyStateClearFilters => 'Filter löschen';

  @override
  String get emptyStateRetry => 'Erneut versuchen';

  @override
  String get emptyStateExplore => 'Entdecken';

  @override
  String get emptyStateStartChat => 'Chat starten';

  @override
  String get errorNetworkTitle => 'Verbindungsfehler';

  @override
  String get errorNetworkSubtitle => 'Verbindung zum Server nicht möglich. Überprüfen Sie Ihre Internetverbindung.';

  @override
  String get errorServerTitle => 'Serverfehler';

  @override
  String get errorServerSubtitle => 'Auf unserer Seite ist etwas schiefgelaufen. Bitte versuchen Sie es später erneut.';

  @override
  String get errorClientTitle => 'Anfragefehler';

  @override
  String get errorClientSubtitle => 'Es gab ein Problem mit Ihrer Anfrage. Bitte überprüfen und versuchen Sie es erneut.';

  @override
  String get errorParsingTitle => 'Datenfehler';

  @override
  String errorParsingSubtitle(String dataType) {
    return 'Die $dataType konnte nicht verarbeitet werden. Dies könnte ein vorübergehendes Problem sein.';
  }

  @override
  String get errorPermissionTitle => 'Zugriff verweigert';

  @override
  String errorPermissionSubtitle(String dataType) {
    return 'Sie haben keine Berechtigung, auf diese(n) $dataType zuzugreifen.';
  }

  @override
  String get errorGenericTitle => 'Etwas ist schiefgelaufen';

  @override
  String errorGenericSubtitle(String dataType) {
    return 'Ein unerwarteter Fehler ist beim Laden von $dataType aufgetreten. Bitte versuchen Sie es erneut.';
  }

  @override
  String get errorRetry => 'Erneut versuchen';

  @override
  String get errorCheckSettings => 'Einstellungen prüfen';

  @override
  String get errorReport => 'Problem melden';

  @override
  String get errorGoBack => 'Zurück';

  @override
  String get errorRefresh => 'Aktualisieren';

  @override
  String get errorRequestAccess => 'Zugriff anfordern';

  @override
  String get errorContactSupport => 'Support kontaktieren';

  @override
  String get dataTypeUsers => 'Benutzer';

  @override
  String get dataTypeUser => 'Benutzer';

  @override
  String get dataTypeProducts => 'Produkte';

  @override
  String get dataTypeProduct => 'Produkt';

  @override
  String get dataTypeOrders => 'Bestellungen';

  @override
  String get dataTypeOrder => 'Bestellung';

  @override
  String get dataTypeMessages => 'Nachrichten';

  @override
  String get dataTypeMessage => 'Nachricht';

  @override
  String get dataTypeFavorites => 'Favoriten';

  @override
  String get dataTypeFavorite => 'Favorit';

  @override
  String get dataTypeData => 'Daten';

  @override
  String get dataTypeContent => 'Inhalt';

  @override
  String get dataTypeItems => 'Elemente';

  @override
  String get dataTypeItem => 'Element';

  @override
  String get eulaTitle => 'Endbenutzer-Lizenzvereinbarung';

  @override
  String eulaContent(String appName, String supportEmail) {
    return 'Diese Endbenutzer-Lizenzvereinbarung (\"EULA\") ist eine rechtliche Vereinbarung zwischen Ihnen und der Bars Opus, Ltd. für $appName.\n\nDurch die Installation, den Zugriff oder die Verwendung von $appName erklären Sie sich mit den Bedingungen dieser EULA einverstanden. $appName wird Ihnen lizenziert, nicht verkauft, und darf nur unter den Bedingungen dieser Lizenz verwendet werden. Die Bars Opus, Ltd. behält sich alle nicht ausdrücklich in dieser EULA gewährten Rechte vor.\n\nSie dürfen $appName nicht modifizieren, reverse-engineern, dekompilieren oder disassemblieren. Diese Lizenz ist gültig, bis sie von Ihnen oder der Bars Opus, Ltd. gekündigt wird. Ihre Rechte unter dieser Lizenz erlöschen automatisch ohne Vorankündigung, wenn Sie gegen eine(n) der Bedingungen verstoßen.\n\nAlle geistigen Eigentumsrechte an $appName gehören der Bars Opus, Ltd. Diese EULA unterliegt den Gesetzen von England und Wales.\n\nBei Fragen zu dieser EULA wenden Sie sich bitte an: $supportEmail.';
  }

  @override
  String get eulaFooter => 'Durch Ihre Zustimmung bestätigen Sie, dass Sie diese Endbenutzer-Lizenzvereinbarung gelesen und verstanden haben.';

  @override
  String get privacyPolicyTitle => 'Datenschutzerklärung';

  @override
  String privacyPolicyContent(String appName) {
    return 'Diese Datenschutzerklärung erläutert, wie die Bars Opus, Ltd. (\"wir\", \"unser\") Ihre Informationen erhebt, verwendet und schützt, wenn Sie $appName verwenden.\n\nWir erheben Informationen, die Sie direkt bereitstellen, z.B. wenn Sie ein Konto erstellen, Ihr Profil vervollständigen oder den Support kontaktieren. Wir erheben automatisch bestimmte Informationen über Ihr Gerät und wie Sie $appName verwenden. Wir verwenden Cookies und ähnliche Tracking-Technologien, um Aktivitäten zu verfolgen und bestimmte Informationen zu speichern.\n\nWir verwenden die erhobenen Informationen, um $appName bereitzustellen, zu warten und zu verbessern. Wir können Ihre Informationen mit Drittanbieter-Dienstleistern teilen, die Dienstleistungen in unserem Namen erbringen. Wir können Ihre Informationen offenlegen, wenn dies gesetzlich vorgeschrieben ist oder um unsere Rechte und Sicherheit zu schützen.\n\nSie haben das Recht, auf Ihre persönlichen Informationen zuzugreifen, sie zu korrigieren oder zu löschen. Wir implementieren geeignete technische und organisatorische Maßnahmen, um Ihre Informationen zu schützen. Wir können diese Datenschutzerklärung von Zeit zu Zeit aktualisieren. Wir werden Sie über Änderungen informieren.';
  }

  @override
  String privacyPolicyFooter(String appName, DateTime currentDate) {
    final intl.DateFormat currentDateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String currentDateString = currentDateDateFormat.format(currentDate);

    return 'Datenschutzerklärung von $appName - Zuletzt aktualisiert: $currentDateString';
  }

  @override
  String get termsTitle => 'Nutzungsbedingungen';

  @override
  String termsContent(String appName, String supportEmail) {
    return 'Diese Nutzungsbedingungen (\"Bedingungen\") regeln Ihren Zugriff auf und die Nutzung von $appName. Durch den Zugriff auf oder die Nutzung von $appName erklären Sie sich mit diesen Bedingungen einverstanden.\n\nSie müssen mindestens 13 Jahre alt sein, um $appName zu verwenden. Sie sind für die Sicherung Ihrer Kontozugangsdaten und für alle Aktivitäten unter Ihrem Konto verantwortlich. Sie dürfen $appName nicht für illegale oder unbefugte Zwecke verwenden.\n\nWir behalten uns das Recht vor, $appName jederzeit zu ändern, auszusetzen oder einzustellen. Alle in $appName enthaltenen Inhalte sind Eigentum der Bars Opus, Ltd. oder ihrer Lizenzgeber.\n\nWir können Ihren Zugriff auf $appName sofort beenden oder aussetzen, wenn Sie gegen diese Bedingungen verstoßen. Diese Bedingungen unterliegen den Gesetzen von England und Wales.\n\nBei Fragen zu diesen Bedingungen wenden Sie sich bitte an $supportEmail.';
  }

  @override
  String get dataSharingTitle => 'Datenfreigabe-Vereinbarung';

  @override
  String dataSharingContent(String appName) {
    return 'Diese Datenfreigabe-Vereinbarung beschreibt, wie Ihre Informationen geteilt werden können, wenn Sie die sozialen Funktionen von $appName verwenden.\n\nWenn Sie sich mit Freunden auf $appName verbinden, können bestimmte Aktivitätsdaten für sie sichtbar sein. Gemeinsam genutzte Aktivitätsdaten können Trainingsdauer, verbrannte Kalorien, Übungsminuten und Erfolgsabzeichen umfassen. Ihre Profilinformationen (Anzeigename und Profilbild) sind für Freunde sichtbar, mit denen Sie sich verbinden.\n\nIhre E-Mail-Adresse und Kontaktinformationen bleiben privat und werden niemals mit anderen Nutzern geteilt. Sie kontrollieren, welche Daten über Ihre $appName-Datenschutzeinstellungen geteilt werden. Sie können Freigabeberechtigungen jederzeit in den App-Einstellungen widerrufen.\n\nMit Freunden geteilte Daten werden während der Übertragung und Speicherung verschlüsselt. Wir behalten gemeinsam genutzte Daten nur so lange, wie es zur Bereitstellung der Freigabefunktionalität erforderlich ist. Drittanbieter-Integrationen können eigene Datenfreigabe-Praktiken haben, die wir Ihnen zu überprüfen empfehlen.';
  }

  @override
  String dataSharingFooter(String appName) {
    return 'Die Datenfreigabe in $appName hilft dabei, eine unterstützende Community aufzubauen, während Ihre Privatsphäreneinstellungen respektiert werden.';
  }

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardSubtitle => 'Verwalten Sie Ihre Shop-Aktivitäten effizient';

  @override
  String get dashboardSectionTitle => 'Dashboard';

  @override
  String get dashboardSectionSubtitle => 'Übersicht über die Leistung und Schlüsselmetriken Ihres Shops';

  @override
  String get dashboardPayoutTitle => 'Auszahlung anfordern';

  @override
  String get dashboardPayoutContent => 'Shop-Besitzer können wöchentliche Auszahlungen anfordern. Navigieren Sie zum Abschnitt Einnahmen, überprüfen Sie Ihr Guthaben und senden Sie eine Auszahlungsanfrage. Gelder werden in der Regel innerhalb von 3-5 Werktagen bearbeitet.';

  @override
  String get dashboardAnalyticsTitle => 'Analytics-Dashboard';

  @override
  String get dashboardAnalyticsContent => 'Verfolgen Sie die Leistung Ihres Shops mit Echtzeit-Analysen. Überwachen Sie Verkaufstrends, Kundenengagement und Lagerbestände durch interaktive Diagramme und Berichte.';

  @override
  String get dashboardScreenshotTitle => 'Dashboard-Übersicht';

  @override
  String get dashboardScreenshotContent => 'Das Haupt-Dashboard bietet einen umfassenden Überblick über die Schlüsselmetriken Ihres Shops, aktuelle Aktivitäten und schnellen Zugriff auf wesentliche Funktionen.';

  @override
  String get categoryFeatures => 'Funktionen';

  @override
  String get categoryDashboard => 'Dashboard';

  @override
  String get faqDashboard1Question => 'Wann kann ich eine Auszahlung anfordern?';

  @override
  String get faqDashboard1Answer => 'Sie können Ihre Auszahlung einmal pro Woche, jeden Samstag, anfordern. Der wöchentliche Stichtag ist Freitag um 23:59 Uhr. Auszahlungen werden innerhalb von 3-5 Werktagen bearbeitet.';

  @override
  String get faqDashboard2Question => 'Wo kann ich meine Auszahlung anfordern?';

  @override
  String get faqDashboard2Answer => 'Navigieren Sie zu Ihrem Dashboard und klicken Sie auf den Abschnitt \'Einnahmen\'. Dort sehen Sie Ihr aktuelles Guthaben und eine Schaltfläche \'Auszahlung anfordern\'. Folgen Sie den Anweisungen, um Ihre Anfrage abzuschließen.';

  @override
  String get profileScreenCantChatWithYourself => 'Du kannst nicht mit dir selbst chatten';

  @override
  String get profileScreenStartingConversation => 'Unterhaltung wird gestartet...';

  @override
  String get profileScreenNoActiveSession => 'Keine aktive Sitzung — bitte melden Sie sich erneut an.';

  @override
  String get profileScreenSignInToChatMessage => 'Sie müssen sich anmelden, um eine Nachricht zu senden';

  @override
  String get profileScreenFollowFeatureComingSoon => 'Follow-Funktion kommt bald';

  @override
  String get profileScreenEnterBioPlaceholder => 'Geben Sie eine Biografie ein, damit die Leute Sie kennen';

  @override
  String get profileScreenNoBioYet => 'Noch keine Biografie';

  @override
  String get profileScreenErrorLoadingProfileBody => 'Profil konnte nicht geladen werden. Überprüfen Sie Ihre Internetverbindung und versuchen Sie es erneut.';

  @override
  String get profileScreenLoadingNotifications => 'Wird geladen...';

  @override
  String get profileHeaderBookingsStatLabel => 'Buchungen';

  @override
  String get profileHeaderOrdersStatLabel => 'Bestellungen';

  @override
  String get profileHeaderEditProfileButton => 'Profil bearbeiten';

  @override
  String get profileHeaderMessageButton => 'Nachricht';

  @override
  String get editableProfileAvatarTakePhoto => 'Ein Foto machen';

  @override
  String get editableProfileAvatarChooseGallery => 'Aus der Galerie auswählen';

  @override
  String get editProfileScreenAccountTypeLabel => 'Kontotyp';

  @override
  String get editProfileScreenAccountTypeSubtitle => 'Wählen Sie, wie Sie diese App nutzen möchten. Dies bestimmt, welche Funktionen für Sie verfügbar sind.';

  @override
  String get editProfileScreenUpdatingAccountType => 'Kontotyp wird aktualisiert...';

  @override
  String get editProfileScreenPleaseLogIn => 'Bitte melden Sie sich an';

  @override
  String get editProfileScreenNameLabel => 'Name';

  @override
  String get editProfileScreenNameHint => 'Geben Sie Ihren Namen ein';

  @override
  String get editProfileScreenUsernameLabel => 'Benutzername';

  @override
  String get editProfileScreenUsernameHint => 'Benutzername eingeben';

  @override
  String get editProfileScreenBioLabel => 'Biografie';

  @override
  String get editProfileScreenBioHint => 'Erzählen Sie etwas über sich selbst';

  @override
  String get editProfileScreenEditWorkProfileTitle => 'Arbeitsprofil bearbeiten';

  @override
  String get profileTabsAppointments => 'Termine';

  @override
  String get profileTabsBuys => 'Käufe';

  @override
  String get profileTabsSaves => 'Speichert';

  @override
  String get searchScreenSearchHint => 'Nach Geschäften, Profis, Produkten suchen...';

  @override
  String get searchScreenNoResultsFound => 'Keine Ergebnisse gefunden';

  @override
  String searchScreenNoResultsCategory(String category) {
    return 'Keine $category gefunden';
  }

  @override
  String searchScreenSearchedFor(String query) {
    return 'Gesucht nach: \"$query\"';
  }

  @override
  String get searchScreenSomethingWentWrong => 'Etwas ist schiefgelaufen';

  @override
  String get searchAppBarSearchHint => 'Suchen...';

  @override
  String get searchSuggestionsHint => 'Suchen Sie nach Geschäften, Profis für Heimservice oder Haarprodukten zum Kaufen';

  @override
  String get searchSuggestionsRecentSearches => 'Letzte Suchen';

  @override
  String get searchSuggestionsClearAll => 'Alles löschen';

  @override
  String get searchEmptyStateNoResults => 'Keine Ergebnisse gefunden';

  @override
  String searchEmptyStateCouldNotFind(String query) {
    return 'Wir konnten nichts für \"$query\" finden';
  }

  @override
  String get searchEmptyStateTryThese => 'Versuchen Sie stattdessen diese:';

  @override
  String get searchResultsShopsHeader => 'Geschäfte';

  @override
  String get searchResultsSeeAll => 'Alle anzeigen';

  @override
  String searchResultsTitle(String category) {
    return '$category Ergebnisse';
  }

  @override
  String searchResultsSearchingFor(String query) {
    return 'Suche nach \"$query\"';
  }

  @override
  String get searchResultsTryDifferent => 'Versuchen Sie andere Schlüsselwörter oder entfernen Sie Filter';

  @override
  String get searchResultsSomethingWentWrong => 'Etwas ist schiefgelaufen';

  @override
  String nearYouShopsTitle(int km) {
    return 'In Ihrer Nähe\ninnerhalb von ${km}km';
  }

  @override
  String nearYouShopsBody(int km) {
    return 'Geschäfte in einem Umkreis von $km km von Ihrem aktuellen Standort, sortiert von nächster zu ferner Entfernung. Stellen Sie Ihren Standort einfach einmal ein, und wir zeigen Ihnen, was in der Nähe ist – ob zu Hause, bei der Arbeit oder während Sie eine neue Gegend erkunden. Praktisch für kurzfristige Buchungen oder wenn Sie gerne zu Fuß gehen.';
  }

  @override
  String get nearYouShopsEmptyNoFilter => 'Keine Geschäfte in der Nähe gefunden';

  @override
  String nearYouShopsEmptyWithFilter(String luxury) {
    return 'Keine $luxury Geschäfte in der Nähe gefunden';
  }

  @override
  String nearYouShopsEmptySubtitle(String location) {
    return 'Geschäfte in $location würden hier angezeigt, sobald sie verfügbar sind';
  }

  @override
  String get premiumShopsScreenTitle => 'Premium Geschäfte';

  @override
  String get premiumShopsEmpty => 'Keine Premium Geschäfte gefunden';

  @override
  String get premiumShopsHorizontalTitle => 'Premium-Geschäfte\nfür Premium-Looks';

  @override
  String get premiumShopsHorizontalBody => 'Handverlesene High-End-Salons und Spas mit Luxuserfahrungen. Diese Geschäfte werden basierend auf ihren Dienstleistungen, Preisen und Kundenrezensionen als Luxus oder Ultra-Luxus klassifiziert. Perfekt für die extra Prise Eleganz.';

  @override
  String get premiumShopsHorizontalEmptyNoFilter => 'Keine Premium Geschäfte verfügbar';

  @override
  String premiumShopsHorizontalEmptyWithFilter(String luxury) {
    return 'Keine $luxury Premium Geschäfte verfügbar';
  }

  @override
  String get premiumShopsHorizontalEmptySubtitle => 'Geschäfte würden hier angezeigt, sobald sie verfügbar sind';

  @override
  String get topRatedShopsHorizontalTitle => 'Top bewertet';

  @override
  String topRatedShopsHorizontalTitleWithLocation(String location) {
    return 'Top bewertet \nin $location';
  }

  @override
  String get topRatedShopsHorizontalBody => 'Geschäfte mit den höchsten Kundenbewertungen (4,5+ Sterne) und einer großen Anzahl von Rezensionen. Das sind die Favoriten unserer Community—durchgehend für Qualität, Service und Professionalität gelobt. Ein großartiger Ort zum Starten, wenn Sie zuverlässige, von der Crowd bestätigte Optionen mögen.';

  @override
  String get topRatedShopsHorizontalEmptyNoFilter => 'Keine Top bewerteten Geschäfte verfügbar';

  @override
  String topRatedShopsHorizontalEmptyWithFilter(String luxury) {
    return 'Keine $luxury Premium Geschäfte verfügbar';
  }

  @override
  String get topRatedShopsHorizontalEmptySubtitle => 'Geschäfte würden hier angezeigt, sobald sie verfügbar sind';

  @override
  String get topRatedShopsScreenTitle => 'Top bewertete Geschäfte';

  @override
  String get topRatedShopsEmpty => 'Keine Top bewerteten Geschäfte gefunden';

  @override
  String get nearYouFreelancersScreenTitle => 'Freiberufler in Ihrer Nähe';

  @override
  String get nearYouFreelancersEmpty => 'Keine Freiberufler in der Nähe gefunden';

  @override
  String get nearYouFreelancersEmptySubtitle => 'Versuchen Sie, Ihren Suchbereich zu erweitern oder den Standort zu ändern';

  @override
  String get topRatedFreelancersScreenTitle => 'Top bewertete Freiberufler';

  @override
  String get topRatedFreelancersEmpty => 'Keine Top bewerteten Freiberufler gefunden';

  @override
  String get topRatedFreelancersEmptySubtitle => 'Versuchen Sie, Ihren Suchbereich anzupassen';

  @override
  String topRatedFreelancersHorizontalTitle(String location) {
    return 'Top bewertet \nin $location';
  }

  @override
  String get topRatedFreelancersHorizontalBody => 'Handverlesene hochwertige Fachleute mit Luxuserfahrungen. Diese Freiberufler werden basierend auf ihrer Arbeitsqualität, ihren Preisen und Kundenrezensionen als Top bewertet klassifiziert. Perfekt für die Extra-Prise Exzellenz.';

  @override
  String nearYouFreelancersHorizontalTitle(String location) {
    return 'Freiberufler in Ihrer Nähe in $location';
  }

  @override
  String get nearYouFreelancersHorizontalBody => 'Fachleute in Ihrer Nähe. Diese Freiberufler sind für schnelle Buchungen verfügbar und bieten bequemen, lokalen Service. Perfekt, wenn Sie Zuverlässigkeit und Nähe suchen.';

  @override
  String get nearYouFreelancersHorizontalEmpty => 'Keine Top bewerteten Freiberufler verfügbar';

  @override
  String get nearYouFreelancersHorizontalEmptySubtitle => 'Freiberufler würden hier angezeigt, sobald sie verfügbar sind';

  @override
  String get shopNoLocationSetTitle => 'Standort festlegen zum Entdecken';

  @override
  String get shopNoLocationSetContent => 'Legen Sie Ihren Standort fest, um Premium- und top bewertete Geschäfte in Ihrer Nähe zu entdecken.';

  @override
  String get providerTypeShops => 'Geschäfte';

  @override
  String get providerTypeFreelancers => 'Freiberufler';

  @override
  String get providerTypeBuy => 'Kaufen';

  @override
  String get luxuryLevelChipsAll => 'Alle';

  @override
  String get searchRadiusSliderTitle => 'Erkundungsradius';

  @override
  String searchRadiusSliderSubtitle(int km) {
    return 'Ergebnisse anzeigen innerhalb von ${km}km von Ihrem Standort';
  }

  @override
  String validationPasswordMaxLength(int max) {
    return 'Passwort darf maximal $max Zeichen lang sein';
  }

  @override
  String get validationPasswordRepeatingChars => 'Passwort enthält zu viele wiederholte Zeichen';

  @override
  String get validationPasswordSequential => 'Passwort enthält aufeinanderfolgende Zeichen';

  @override
  String validationPhoneDigits(int digits) {
    return 'Telefonnummer muss $digits Ziffern haben';
  }

  @override
  String get validationPhoneUK => 'Ungültige britische Telefonnummer';

  @override
  String validationUrlScheme(String schemes) {
    return 'URL muss mit $schemes beginnen';
  }

  @override
  String get validationUrlDomain => 'Ungültiger Domänenname';

  @override
  String get validationUrlPublicAddress => 'URL muss auf eine öffentliche Adresse verweisen';

  @override
  String validationNameMaxLength(String field, int max) {
    return '$field darf maximal $max Zeichen lang sein';
  }

  @override
  String validationNameConsecutiveChars(String field) {
    return '$field darf keine aufeinanderfolgenden Bindestriche oder Leerzeichen enthalten';
  }

  @override
  String get validationCreditCardFormat => 'Bitte geben Sie eine gültige Kreditkartennummer ein';

  @override
  String get validationCreditCardInvalid => 'Ungültige Kreditkartennummer';

  @override
  String get validationDatePastNotAllowed => 'Datum darf nicht in der Vergangenheit liegen';

  @override
  String get validationPostalCodeZip => 'Bitte geben Sie eine gültige Postleitzahl ein (z.B. 12345 oder 12345-6789)';

  @override
  String get validationPostalCodeCanadian => 'Bitte geben Sie eine gültige kanadische Postleitzahl ein (z.B. A1A 1A1)';

  @override
  String get validationPostalCodeGeneric => 'Bitte geben Sie eine gültige Postleitzahl ein';

  @override
  String get validationSSNFormat => 'Bitte geben Sie eine gültige Sozialversicherungsnummer ein (z.B. 123-45-6789)';

  @override
  String get validationSSNInvalid => 'Ungültige Sozialversicherungsnummer';

  @override
  String get validationEmailTooLong => 'E-Mail ist zu lang (max. 254 Zeichen)';

  @override
  String get validationEmailLocalPartTooLong => 'Lokaler Teil der E-Mail ist zu lang';

  @override
  String get categoriesAll => 'Alle';

  @override
  String get categoriesSalon => 'Salons';

  @override
  String get categoriesBarbershop => 'Friseursalons';

  @override
  String get categoriesSpa => 'Spas';

  @override
  String get categoriesNailSalon => 'Nagelstudios';

  @override
  String get categoriesLashStudio => 'Wimpernstudios';

  @override
  String get categoriesWaxing => 'Haarentfernung';

  @override
  String get categoriesMassage => 'Massage';

  @override
  String get categoriesMakeup => 'Make-up';

  @override
  String get categoriesSkincare => 'Hautpflege';

  @override
  String get luxuryLevelModerate => 'Moderat';

  @override
  String get luxuryLevelLuxury => 'Luxus';

  @override
  String get luxuryLevelUltraLuxury => 'Ultra Luxus';

  @override
  String get dashboardTabRevenue => 'Einnahmen';

  @override
  String get dashboardTabAnalytics => 'Analytik';

  @override
  String get dashboardTabInsights => 'Einblicke';

  @override
  String get dashboardTabTools => 'Werkzeuge';

  @override
  String get dashboardTabClients => 'Kunden';

  @override
  String get dashboardTabStaff => 'Personal';

  @override
  String get walletRecentTransactions => 'Letzte Transaktionen';

  @override
  String get walletLoadError => 'Wir konnten Ihr Wallet gerade nicht laden.';

  @override
  String get walletTransactionLoadError => 'Konnte letzte Transaktionen nicht laden.';

  @override
  String get walletPaymentProcessing => 'Bitte warten Sie, bis die Zahlung verarbeitet ist, und kehren Sie zu Ihrer App zurück, um Ihre Buchung abzuschließen.';

  @override
  String get analyticsRevenue => 'Einnahmen';

  @override
  String get analyticsServices => 'Dienstleistungen';

  @override
  String get analyticsWorkers => 'Mitarbeiter';

  @override
  String get analyticsLoadError => 'Analytik konnte nicht geladen werden';

  @override
  String get analyticsEmpty => 'Keine Daten für Analytik verfügbar.';

  @override
  String get analyticsEmptySubtitle => 'Buchungs- und Umsatzstatistiken würden hier angezeigt';

  @override
  String get insightsReports => 'Berichte';

  @override
  String get insightsSeeAll => 'Alles anzeigen';

  @override
  String get insightsLoadError => 'Berichte konnten nicht geladen werden. Zum Aktualisieren ziehen Sie nach unten.';

  @override
  String get insightsNoAlerts => 'Alles gut! Keine Benachrichtigungen';

  @override
  String get insightsHeatmapError => 'Buchungs-Heatmap konnte nicht geladen werden.';

  @override
  String get insightsNoHeatmapData => 'Keine Heatmap-Daten verfügbar';

  @override
  String get toolsAdminTools => 'Admin-Tools';

  @override
  String get toolsConfigure => 'Konfigurieren →';

  @override
  String get toolsManage => 'Verwalten →';

  @override
  String get toolsExport => 'Exportieren →';

  @override
  String get toolsAutomatedReminders => 'Automatisierte Erinnerungen';

  @override
  String get toolsPromotionsManager => 'Promotions-Manager';

  @override
  String get toolsExportReports => 'Berichte exportieren';

  @override
  String get toolsPaymentSettings => 'Zahlungseinstellungen';

  @override
  String get toolsLoadingDetails => 'Ladendetails werden geladen…';

  @override
  String get toolsBusinessHours => 'Öffnungszeiten';

  @override
  String get toolsServiceManagement => 'Serviceverwaltung';

  @override
  String get clientsSearchHint => 'Nach Name suchen...';

  @override
  String get clientsLoadError => 'Kunden konnten nicht geladen werden';

  @override
  String get clientsNotFound => 'Keine passenden Kunden';

  @override
  String get clientsEmpty => 'Noch keine Kunden';

  @override
  String clientsSearchEmpty(String query) {
    return 'Keine Kunden gefunden, die \"$query\" entsprechen';
  }

  @override
  String get clientsEmptySubtitle => 'Kunden werden angezeigt, sobald sie ihre erste Buchung vornehmen.';

  @override
  String get walletLabel => 'Geldbörse';

  @override
  String get walletAvailableBalance => 'Verfügbarer Saldo';

  @override
  String get walletWithdrawFunds => 'Geldmittel abheben';

  @override
  String get walletTotalEarned => 'Gesamtverdient';

  @override
  String get walletTotalWithdrawn => 'Gesamt abgehoben';

  @override
  String get transactionDepositReceived => 'Einzahlung erhalten';

  @override
  String get transactionServicePayment => 'Dienstleistungszahlung';

  @override
  String get transactionWithdrawal => 'Auszahlung';

  @override
  String get transactionRefund => 'Rückerstattung';

  @override
  String get transactionPlatformFee => 'Plattformgebühr';

  @override
  String get transactionAdjustment => 'Anpassung';

  @override
  String get transactionToday => 'Heute';

  @override
  String get transactionYesterday => 'Gestern';

  @override
  String get withdrawalTitle => 'Abheben';

  @override
  String withdrawalInfo(double fee, String currency, double minFee) {
    return 'Auszahlungen werden sofort bearbeitet und auf Ihr verbundenes Konto übertragen. Es fällt eine Gebühr von $fee% (min $currency $minFee) an.';
  }

  @override
  String withdrawalAvailableBalance(String currency, String amount) {
    return 'Verfügbarer Saldo: $currency $amount';
  }

  @override
  String withdrawalAmountInputLabel(String currency) {
    return 'Betrag ($currency)';
  }

  @override
  String get withdrawalAmountHint => 'Abhebungsbetrag eingeben';

  @override
  String get withdrawalAmountRequired => 'Bitte geben Sie einen Betrag ein';

  @override
  String get withdrawalAmountInvalid => 'Bitte geben Sie einen gültigen Betrag ein';

  @override
  String withdrawalMinimum(String currency, double min) {
    return 'Mindestabhebung ist $currency $min';
  }

  @override
  String withdrawalMaximum(String currency, double max) {
    return 'Maximale Abhebung pro Transaktion ist $currency $max';
  }

  @override
  String withdrawalInsufficientBalance(String currency, String available) {
    return 'Unzureichendes Guthaben. Verfügbar: $currency $available';
  }

  @override
  String get withdrawalBreakdownAmount => 'Abhebungsbetrag:';

  @override
  String withdrawalFeeLabel(Object fee) {
    return 'Gebühr ($fee%):';
  }

  @override
  String get withdrawalNetAmount => 'Sie erhalten:';

  @override
  String get withdrawalProcessing => 'Wird verarbeitet...';

  @override
  String get withdrawalRequestButton => 'Abhebung anfordern';

  @override
  String get withdrawalNoPaymentMethod => 'Keine Zahlungsmethode verbunden';

  @override
  String get withdrawalSuccess => 'Abhebungsanfrage erfolgreich eingereicht!';

  @override
  String get deadLetterTitle => 'Auszahlung benötigt Überprüfung';

  @override
  String deadLetterSingle(String currency, String amount) {
    return '$currency $amount hängen fest — zum Anzeigen tippen';
  }

  @override
  String deadLetterMultiple(String currency, String amount, int count) {
    return '$currency $amount hängen über $count Auszahlungen fest — zum Anzeigen tippen';
  }

  @override
  String get deadLetterReason => 'Grund:';

  @override
  String get deadLetterContactSupport => 'Support kontaktieren';

  @override
  String get paymentSetupTitle => 'Auszahlungseinrichtung abschließen';

  @override
  String get paymentSetupContent => 'Verbinden Sie Ihr Auszahlungskonto, um Geld aus Ihrem Geldbeutel abheben zu können. Dies könnte Ihre Mobilfunknummer oder Ihr Bankkonto sein.';

  @override
  String get calendarErrorLoading => 'Fehler beim Laden des Kalenders';

  @override
  String get calendarErrorLoadingBookings => 'Fehler beim Laden der Buchungen';

  @override
  String get calendarNoAppointmentsDay => 'Keine Termine für diesen Tag';

  @override
  String get calendarNoBookingsDay => 'Keine Buchungen für diesen Tag';

  @override
  String calendarAppointmentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Termine',
      one: 'Termin',
    );
    return '$count $_temp0';
  }

  @override
  String get monthJanuary => 'Jan';

  @override
  String get monthFebruary => 'Feb';

  @override
  String get monthMarch => 'Mär';

  @override
  String get monthApril => 'Apr';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJune => 'Jun';

  @override
  String get monthJuly => 'Jul';

  @override
  String get monthAugust => 'Aug';

  @override
  String get monthSeptember => 'Sep';

  @override
  String get monthOctober => 'Okt';

  @override
  String get monthNovember => 'Nov';

  @override
  String get monthDecember => 'Dez';

  @override
  String get dayMonday => 'Mo';

  @override
  String get dayTuesday => 'Di';

  @override
  String get dayWednesday => 'Mi';

  @override
  String get dayThursday => 'Do';

  @override
  String get dayFriday => 'Fr';

  @override
  String get daySaturday => 'Sa';

  @override
  String get daySunday => 'So';

  @override
  String calendarNoAppointmentsSnackbar(String date) {
    return 'Keine Termine an diesem Tag\n$date';
  }

  @override
  String reviewsScreenTitle(String shopName) {
    return 'Bewertungen für $shopName';
  }

  @override
  String get reviewsLoadError => 'Bewertungen konnten nicht geladen werden';

  @override
  String get reviewsNoReviews => 'Noch keine Bewertungen';

  @override
  String get reviewsRateProduct => 'Produkt bewerten';

  @override
  String get reviewsYourReview => 'Ihre Bewertung';

  @override
  String get reviewsReviewHint => 'Teilen Sie Ihre Erfahrung mit diesem Produkt...';

  @override
  String get reviewsSubmitButton => 'Bewertung senden';

  @override
  String get reviewsThankYou => 'Vielen Dank für Ihre Bewertung!';

  @override
  String reviewsSubmitError(String error) {
    return 'Bewertung konnte nicht eingereicht werden: $error';
  }

  @override
  String get bookingServiceAddress => 'Serviceadresse';

  @override
  String get bookingFindingAvailableTimes => 'Verfügbare Zeiten werden gesucht...';

  @override
  String bookingErrorLoadingWorkers(String error) {
    return 'Fehler beim Laden von Mitarbeitern: $error';
  }

  @override
  String bookingErrorValidatingDistance(String error) {
    return 'Fehler bei der Distanzvalidierung: $error';
  }

  @override
  String get bookingAddSpecialRequirements => 'Hinzufügen';

  @override
  String get bookingCancelSpecialRequirements => 'Abbrechen';

  @override
  String get bookingSaveSpecialRequirements => 'Speichern';

  @override
  String bookingFailedSaveRequirements(String error) {
    return 'Fehler beim Speichern: $error';
  }

  @override
  String get bookingInvitationSent => 'Einladung erfolgreich gesendet';

  @override
  String get bookingSavingAssignments => 'Zuweisungen werden gespeichert...';

  @override
  String get bookingAssignmentsSaved => 'Zuweisungen erfolgreich gespeichert';

  @override
  String bookingAssignmentsError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get scheduleTitle => 'Zeitplan';

  @override
  String get scheduleTabDaily => 'Täglich';

  @override
  String get scheduleTabMonthly => 'Monatlich';

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
  String get docsGettingStartedTitle => 'Erste Schritte';

  @override
  String get docsGettingStartedSubtitle => 'Grundlagen lernen';

  @override
  String get docsGettingStartedWhatIsTitle => 'Was ist Aura In?';

  @override
  String get docsGettingStartedWhatIsSubtitle => 'Die Plattform verstehen';

  @override
  String get docsGettingStartedWelcomeIntroContent => 'Aura In ist ein mobiler Marktplatz, der Servicefachleute mit Kunden verbindet. Egal ob Sie Haarschnitte, Massagen, freiberufliche Dienstleistungen anbieten oder Produkte verkaufen - diese Plattform hilft Ihrem Geschäft zu wachsen.';

  @override
  String get docsGettingStartedWhoUsesTitle => 'Wer nutzt Aura In?';

  @override
  String get docsGettingStartedWhoUsesContent => 'Zwei Arten von Benutzern nutzen die Plattform:';

  @override
  String get docsGettingStartedWhoUsesProviders => 'Serviceanbieter - Salons, Spas, Friseure, Freiberufler, die Services anbieten';

  @override
  String get docsGettingStartedWhoUsesCustomers => 'Kunden - Menschen, die Services in ihrer Nähe suchen und buchen';

  @override
  String get docsGettingStartedWhoUsesSellers => 'Produktverkäufer - Geschäfte, die Einzelhandelsprodukte oder handgefertigte Artikel verkaufen';

  @override
  String get docsGettingStartedHowItWorksTitle => 'So funktioniert es';

  @override
  String get docsGettingStartedHowItWorksContent => 'Serviceanbieter erstellen ein Profil, listen ihre Services mit Preisen auf und akzeptieren Buchungen von Kunden. Kunden suchen nach Standort, durchsuchen Services und buchen Termine. Alles wird über die App verwaltet.';

  @override
  String get docsGettingStartedThreeWaysTitle => 'Drei Wege, Aura In zu nutzen';

  @override
  String get docsGettingStartedThreeWaysSubtitle => 'Wählen Sie Ihre Rolle';

  @override
  String get docsGettingStartedOption1Title => 'Option 1: Services durchsuchen und buchen (Kunde)';

  @override
  String get docsGettingStartedOption1Content => 'Suchen Sie Salons, Massiertherapeuten, Friseure oder Freiberufler in Ihrer Nähe. Sehen Sie ihre Services, Preise und Verfügbarkeit. Buchen Sie Termine direkt über die App und zahlen Sie sicher.';

  @override
  String get docsGettingStartedGuestBookingTitle => 'Gastbuchung (kein App-Download erforderlich)';

  @override
  String get docsGettingStartedGuestBookingContent => 'Möchten Sie die App nicht herunterladen? Serviceanbieter können einen Buchungslink teilen - Sie können direkt über diesen Link buchen und zahlen, ohne ein Konto zu erstellen. Ihre Buchungsdetails und Quittung werden per WhatsApp gesendet.';

  @override
  String get docsGettingStartedOption2Title => 'Option 2: Services anbieten (Shop-Besitzer oder Freiberufler)';

  @override
  String get docsGettingStartedOption2Content => 'Erstellen Sie ein Shop- oder Freiberufler-Profil, listen Sie Ihre Services mit Preisen und Dauer auf, setzen Sie Ihre Arbeitszeiten und verwalten Sie Buchungen. Verdienen Sie Geld mit jedem gebuchten Service.';

  @override
  String get docsGettingStartedOption3Title => 'Option 3: Produkte verkaufen (Produktverkäufer)';

  @override
  String get docsGettingStartedOption3Content => 'Wenn Sie handgefertigte Artikel oder Einzelhandelsprodukte herstellen, können Sie diese zum Verkauf anbieten. Kunden durchsuchen und kaufen direkt von Ihrem Shop.';

  @override
  String get docsGettingStartedBookingPaymentTitle => 'Buchungs- und Zahlungssystem';

  @override
  String get docsGettingStartedBookingPaymentSubtitle => 'Wie Servicebuchung und Zahlung funktionieren';

  @override
  String get docsGettingStartedBookingOverviewContent => 'Kunden buchen Termine bei Serviceanbietern. Zahlungen werden sicher über die App mit Paystack (Afrika) oder Stripe (Global) bearbeitet.';

  @override
  String get docsGettingStartedDepositPaymentTitle => 'Anzahlung (30%)';

  @override
  String get docsGettingStartedDepositPaymentContent => 'Bei der Buchung eines Services zahlen Kunden 30% im Voraus als Anzahlung, um den Zeitslot zu sichern. Dies bestätigt, dass die Buchung echt und reserviert ist.';

  @override
  String get docsGettingStartedPlatformFeeTitle => 'Plattformgebühr';

  @override
  String get docsGettingStartedPlatformFeeContent => 'Eine kleine Plattformgebühr (2%) wird hinzugefügt, um uns dabei zu helfen, die Plattform zu warten und Support zu bieten. Diese wird auf den gesamten Buchungsbetrag berechnet.';

  @override
  String get docsGettingStartedRemainingPaymentTitle => 'Restliche Zahlung (70%)';

  @override
  String get docsGettingStartedRemainingPaymentContent => 'Die restlichen 70% können entweder: (1) in bar bezahlt werden, wenn der Service abgeschlossen ist, oder (2) online über die App vor dem Termin.';

  @override
  String get docsGettingStartedGuestBookingPaymentTitle => 'Gastbuchungszahlung';

  @override
  String get docsGettingStartedGuestBookingPaymentContent => 'Kein App-Download erforderlich! Kunden erhalten einen Buchungslink vom Serviceanbieter. Sie zahlen 30%, um den Slot zu sichern, und ihre Quittung wird per WhatsApp versendet.';

  @override
  String get docsGettingStartedProductOrderingTitle => 'Produktbestellung und Lieferung';

  @override
  String get docsGettingStartedProductOrderingSubtitle => 'So funktioniert der Produktverkauf';

  @override
  String get docsGettingStartedProductOverviewContent => 'Kunden durchsuchen Produkte, fügen Artikel zum Warenkorb hinzu und führen den Checkout durch. Produkte werden an den Standort des Kunden geliefert.';

  @override
  String get docsGettingStartedCODPaymentTitle => 'Nachnahme (COD)';

  @override
  String get docsGettingStartedCODPaymentContent => 'Für Produktbestellungen erfolgt die Zahlung per Nachnahme. Kunden zahlen den Verkäufer, wenn sie die Artikel erhalten - keine Vorauszahlung erforderlich.';

  @override
  String get docsGettingStartedShareYourProfileTitle => 'Teilen Sie Ihr Profil';

  @override
  String get docsGettingStartedShareYourProfileSubtitle => 'Machen Sie es Kunden leicht, Sie zu finden';

  @override
  String get docsGettingStartedShareLinkContent => 'Als Serviceanbieter erhalten Sie einen eindeutigen Buchungslink. Teilen Sie ihn auf WhatsApp, in sozialen Medien oder per E-Mail. Kunden können Services buchen, ohne die App herunterzuladen.';

  @override
  String get docsGettingStartedCustomURLTitle => 'Benutzerdefinierte URL (optional)';

  @override
  String get docsGettingStartedCustomURLContent => 'Sie können Ihren Buchungslink-Slug anpassen (z. B. aura.in/glamour-salon statt aura.in/abc123). Macht es einfacher zu teilen und zu merken.';

  @override
  String get docsGettingStartedGetHelpTitle => 'Hilfe erhalten';

  @override
  String get docsGettingStartedGetHelpSubtitle => 'Wo Sie Antworten finden';

  @override
  String get docsGettingStartedHelpDocumentationContent => 'Diese App hat umfassende Dokumentation für jede Funktion. Wenn Sie Hilfe benötigen, lesen Sie den relevanten Leitfaden - es gibt einen für Ihre Rolle und die Funktion, die Sie verwenden.';

  @override
  String get docsGettingStartedFAQ1Question => 'Was ist Aura In?';

  @override
  String get docsGettingStartedFAQ1Answer => 'Aura In ist ein mobiler Marktplatz für servicebasierte Unternehmen. Kunden finden und buchen Services (Haarschnitte, Massagen usw.), Serviceanbieter verwalten Buchungen und Einnahmen, und Produktverkäufer listen Artikel zum Verkauf auf.';

  @override
  String get docsGettingStartedFAQ2Question => 'Muss ich die App bezahlen?';

  @override
  String get docsGettingStartedFAQ2Answer => 'Die App ist kostenlos zum Herunterladen und Verwenden. Serviceanbieter zahlen nur eine kleine Provision, wenn Kunden für Services zahlen. Zahlungsanbieter (Paystack/Stripe) nehmen eine Gebühr.';

  @override
  String get docsGettingStartedFAQ3Question => 'Was ist der Unterschied zwischen Shop-Besitzer und Freiberufler?';

  @override
  String get docsGettingStartedFAQ3Answer => 'Shop-Besitzer haben einen festen Standort mit einem Team von Arbeitern. Freiberufler arbeiten unabhängig und können zu Kunden reisen. Wählen Sie basierend auf Ihrem Geschäftsmodell.';

  @override
  String get docsGettingStartedFAQ4Question => 'Wie bekomme ich bezahlt?';

  @override
  String get docsGettingStartedFAQ4Answer => 'Wenn Kunden für Services zahlen, geht das Geld zu Ihrer Brieftasche. Sie können Ihre Bank abheben mit Paystack (Afrika) oder Stripe (Global).';

  @override
  String get docsGettingStartedFAQ5Question => 'Sind meine Zahlungsinformationen sicher?';

  @override
  String get docsGettingStartedFAQ5Answer => 'Ja. Aura In verwendet Paystack und Stripe, führende Zahlungsanbieter mit Bankensicherheit. Wir sehen Ihre Zahlungsdetails nie.';

  @override
  String get docsGettingStartedFAQ6Question => 'Wie weiß ich, ob Serviceanbieter in meiner Nähe vertrauenswürdig sind?';

  @override
  String get docsGettingStartedFAQ6Answer => 'Jeder Serviceanbieter hat Bewertungen und Rezensionen von Kunden, die bei ihm gebucht haben. Lesen Sie Bewertungen vor der Buchung. Hohe Bewertungen bedeuten konsistenter, qualitativ hochwertiger Service.';

  @override
  String get docsGettingStartedFAQ7Question => 'Kann ich buchen, ohne die App herunterzuladen?';

  @override
  String get docsGettingStartedFAQ7Answer => 'Ja! Serviceanbieter teilen einen eindeutigen Buchungslink. Sie können direkt über diesen Link buchen, ohne die App herunterzuladen. Ihre Quittung wird per WhatsApp gesendet.';

  @override
  String get docsGettingStartedFAQ8Question => 'Wie viel zahle ich im Voraus für Buchungen?';

  @override
  String get docsGettingStartedFAQ8Answer => 'Sie zahlen 30% des Service-Gesamtbetrags im Voraus, um den Buchungsslot zu sichern (plus 2% Plattformgebühr). Die restlichen 70% können in bar oder online vor/bei dem Service bezahlt werden.';

  @override
  String get docsGettingStartedFAQ9Question => 'Wie bezahle ich für Produkte?';

  @override
  String get docsGettingStartedFAQ9Answer => 'Produkte verwenden Nachnahme (COD). Sie zahlen den Verkäufer, wenn Sie die Artikel erhalten. Dies ermöglicht es Ihnen, die Qualität zu überprüfen, bevor Sie zahlen, und funktioniert gut für lokale Lieferungen.';

  @override
  String get docsGettingStartedFAQ10Question => 'Warum 2% Plattformgebühr?';

  @override
  String get docsGettingStartedFAQ10Answer => 'Die Plattformgebühr hilft uns, Aura In zu pflegen, Zahlungsabwicklung, Kundensupport zu bieten und Funktionen für Kunden und Serviceanbieter ständig zu verbessern.';

  @override
  String get docsBookingStartedTitle => 'Erste Schritte mit Buchungen';

  @override
  String get docsBookingStartedSubtitle => 'Ein einfacher Leitfaden zum Verständnis der Funktionsweise von Buchungen';

  @override
  String get docsBookingIntroTitle => 'Willkommen zum Buchungssystem';

  @override
  String get docsBookingIntroSubtitle => 'Alles, was Sie über Dienstleistungsbuchungen wissen müssen, ob Sie ein Client oder ein Shop-Besitzer sind.';

  @override
  String get docsBookingWhatIsTitle => 'Was ist das Buchungssystem?';

  @override
  String get docsBookingWhatIsContent => 'Das Buchungssystem ist Ihr Zugang zur Planung von Dienstleistungen in Ihren Lieblingsladen. Ob Sie einen Haarschnitt, Bartpflege, Flechten oder einen anderen Service benötigen, das System macht es einfach, Termine in Ihrem eigenen Tempo zu buchen.';

  @override
  String get docsBookingWhoIsForTitle => 'Für wen ist dieser Leitfaden?';

  @override
  String get docsBookingWhoIsForContent => 'Dieser Leitfaden ist für zwei Benutzertypen konzipiert:';

  @override
  String get docsBookingWhoIsForClients => 'Kunden: Menschen, die Dienstleistungen in Läden buchen möchten';

  @override
  String get docsBookingWhoIsForGuests => 'Gastbucher: Menschen, die über einen Link buchen möchten, ohne ein Konto zu erstellen';

  @override
  String get docsBookingWhoIsForOwners => 'Shop-Besitzer: Menschen, die Läden, Dienstleistungen und Mitarbeiter verwalten';

  @override
  String get docsBookingGuestIntroTitle => 'Neu: Buchen Sie, ohne die App herunterzuladen';

  @override
  String get docsBookingGuestIntroContent => 'Kein Konto? Kein Problem! Wenn ein Shop-Besitzer einen Buchungslink mit Ihnen teilt, können Sie direkt buchen, ohne die App herunterzuladen. Ihre Quittung wird via WhatsApp versendet.';

  @override
  String get docsBookingWelcomeTip => 'Keine technischen Kenntnisse erforderlich! Dieser Leitfaden verwendet einfache Sprache und reale Beispiele, um Ihnen beim Verständnis zu helfen.';

  @override
  String get docsBookingAccountTitle => 'Ihr Konto erstellen (oder als Gast buchen)';

  @override
  String get docsBookingAccountSubtitle => 'Erste Schritte in wenigen Minuten - mit oder ohne Konto';

  @override
  String get docsBookingTwoWaysTitle => 'Zwei Buchungsarten';

  @override
  String get docsBookingTwoWaysContent => 'Sie können auf zwei Arten buchen:';

  @override
  String get docsBookingTwoWaysAccount => 'Mit Konto: App herunterladen, Konto erstellen, jederzeit buchen';

  @override
  String get docsBookingTwoWaysGuest => 'Als Gast: Buchungslink nutzen, keine App nötig, Quittung via WhatsApp';

  @override
  String get docsBookingAccountStepsTitle => 'So erstellen Sie ein Konto';

  @override
  String get docsBookingAccountStepsContent => 'Befolgen Sie diese einfachen Schritte, um Ihr Konto zu erstellen:';

  @override
  String get docsBookingAccountTypesTitle => 'Kontotypen';

  @override
  String get docsBookingAccountTypesContent => 'Es gibt zwei Kontotypen:';

  @override
  String get docsBookingAccountTypesClient => 'Kundenkonto: Zum Buchen von Dienstleistungen in Läden';

  @override
  String get docsBookingAccountTypesShop => 'Shop-Besitzerkonto: Zur Verwaltung Ihres eigenen Shops (erfordert Genehmigung)';

  @override
  String get docsBookingGuestOptionTitle => 'Als Gast buchen (kein Konto)';

  @override
  String get docsBookingGuestOptionContent => 'Wenn jemand einen Buchungslink mit Ihnen teilt, können Sie direkt buchen, ohne ein Konto zu erstellen. Klicken Sie einfach auf den Link und folgen Sie den Schritten. Ihre Quittung wird an Ihre WhatsApp versendet.';

  @override
  String get docsBookingVerificationNote => 'Sie können ohne Konto mit einem Buchungslink stöbern und buchen. Ein Konto bietet Ihnen Zugriff auf Buchungsverlauf, gespeicherte Zahlungen und Treueprogramme.';

  @override
  String get docsBookingFirstBookingTitle => 'Ihre erste Buchung';

  @override
  String get docsBookingFirstBookingSubtitle => 'Ein kurzer Überblick';

  @override
  String get docsBookingPaymentTitle => 'So funktioniert die Zahlung';

  @override
  String get docsBookingPaymentContent => 'Beim Buchen eines Dienstes funktioniert die Zahlung wie folgt:';

  @override
  String get docsBookingPaymentDeposit => '30% Anzahlung erforderlich: Um Ihre Buchung zu sichern, zahlen Sie 30% der Gesamtdienstleistungskosten im Voraus';

  @override
  String get docsBookingPaymentNonRefundable => 'Nicht rückerstattbar: Diese Anzahlung ist nicht rückerstattbar, wenn Sie stornieren oder nicht erscheinen';

  @override
  String get docsBookingPaymentRemaining => 'Restbetrag: Die restlichen 70% werden nach Abschluss Ihrer Dienstleistung bezahlt';

  @override
  String get docsBookingPaymentSecure => 'Sichere Zahlung: Alle Zahlungen werden sicher durch unsere Zahlungspartner verarbeitet';

  @override
  String get docsBookingDepositNote => 'Die 30% Anzahlung schützt sowohl Sie als auch den Laden. Sie stellt sicher, dass Ihr Platz ausschließlich für Sie reserviert ist, und entschädigt den Mitarbeiter, wenn Sie in letzter Minute stornieren.';

  @override
  String get docsBookingBookingTip => 'Pro-Tipp: Buchen Sie mindestens 24 Stunden im Voraus für die beste Auswahl an Zeitfenstern, besonders für beliebte Dienstleistungen.';

  @override
  String get docsBookingAfterTitle => 'Nach Ihrer Buchung';

  @override
  String get docsBookingAfterSubtitle => 'Was als Nächstes passiert';

  @override
  String get docsBookingWhatsNextTitle => 'Ihre Buchung ist bestätigt!';

  @override
  String get docsBookingWhatsNextContent => 'Hier ist, was Sie nach der Buchung tun können:';

  @override
  String get docsBookingRemindersTitle => 'Buchungserinnerungen';

  @override
  String get docsBookingRemindersContent => 'Sie erhalten Erinnerungen bei:';

  @override
  String get docsBookingAfterServiceTitle => 'Nach Ihrer Dienstleistung';

  @override
  String get docsBookingAfterServiceContent => 'Nachdem Ihre Dienstleistung abgeschlossen ist:';

  @override
  String get docsPaymentTitle => 'Zahlung & Gebühren erklärt';

  @override
  String get docsPaymentSubtitle => 'Wie 30% Anzahlung, Plattformgebühren und Gastbuchungen funktionieren';

  @override
  String get docsPaymentOverviewTitle => 'So funktioniert die Zahlung';

  @override
  String get docsPaymentOverviewSubtitle => 'Einfach, transparent, sicher';

  @override
  String get docsPaymentSummaryTitle => 'Zahlung auf einen Blick';

  @override
  String get docsPaymentSummaryContent => 'Unser Zahlungssystem soll fair für Kunden und Shop-Besitzer sein. Hier ist die einfache Aufschlüsselung:';

  @override
  String get docsPaymentDeposit30 => '30% Anzahlung: Bei der Buchung gezahlt, um Ihren Termin zu sichern';

  @override
  String get docsPaymentPlatformFee => 'Plattformgebühr: Kleine Pauschalgebühr (z.B. GHS 2) von der App';

  @override
  String get docsPaymentRemaining70 => 'Verbleibende 70%: Nach Abschluss Ihres Services bezahlt';

  @override
  String get docsPaymentTwoWays => 'Zwei Zahlungsarten für Verbleibendes: Bargeld oder per App';

  @override
  String get docsPaymentQuickExampleTitle => 'Schnelles Beispiel';

  @override
  String get docsPaymentQuickExampleContent => 'Servicekosten: GHS 100\nBei Buchung: Zahle GHS 30 (Anzahlung) + GHS 2 (Gebühr) = GHS 32\nNach Service: Zahle GHS 70 (Bargeld oder App)\nGesamt zum Shop: GHS 100\nPlattformgebühr: GHS 2';

  @override
  String get docsPaymentImportantNote => 'Die Plattformgebühr wird von der App berechnet, nicht vom Shop. Sie hilft uns, die Plattform zu pflegen und Ihnen ein großartiges Buchungserlebnis zu bieten.';

  @override
  String get docsPaymentGuestBookingTitle => 'Gastbuchung (kein App-Download)';

  @override
  String get docsPaymentGuestBookingContent => 'Sie haben die App nicht? Kein Problem! Sie können trotzdem über den Buchungslink Ihres Anbieters buchen, ohne ein Konto zu erstellen. Sie zahlen die gleiche 30% Anzahlung + Plattformgebühr, und Ihr Beleg wird per WhatsApp gesendet.';

  @override
  String get docsDepositTitle => 'Die 30% Anzahlung';

  @override
  String get docsDepositSubtitle => 'Warum es nötig ist und wie es funktioniert';

  @override
  String get docsDepositWhyTitle => 'Warum verlangen wir eine Anzahlung?';

  @override
  String get docsDepositWhyContent => 'Die 30% Anzahlung schützt sowohl Sie als auch den Shop:';

  @override
  String get docsDepositProtectsYou => 'Für Sie: Ihr Platz ist garantiert – niemand anderes kann ihn buchen';

  @override
  String get docsDepositProtectsShop => 'Für den Shop: Mitarbeiter werden entschädigt, wenn Sie in letzter Minute stornieren';

  @override
  String get docsDepositProtectsEveryone => 'Für alle: Reduziert Ausfallzahlen, hält die Preise fair';

  @override
  String get docsDepositCalcTitle => 'Wie die Anzahlung berechnet wird';

  @override
  String get docsDepositCalcContent => 'Die Anzahlung ist immer 30% der Gesamtservicekosten. Dies umfasst:';

  @override
  String get docsDepositCalcSingle => 'Einzelner Service: 30% dieses Servicepreises';

  @override
  String get docsDepositCalcMultiple => 'Mehrere Services: 30% aller Services zusammen';

  @override
  String get docsDepositCalcGroup => 'Gruppenbuchungen: 30% des Gesamtbetrags für alle Personen';

  @override
  String get docsDepositExamplesTitle => 'Anzahlungsbeispiele';

  @override
  String get docsDepositExamplesSingle => 'Einzelner Service:\nHaarschnitt (GHS 45) → Anzahlung GHS 13,50';

  @override
  String get docsDepositExamplesMultiple => 'Mehrere Services:\nHaarschnitt (GHS 45) + Bartpflege (GHS 25) = GHS 70 insgesamt\nAnzahlung: GHS 21';

  @override
  String get docsDepositExamplesGroup => 'Gruppenbuchung (3 Personen):\n3 × Haarschnitt (GHS 45 je) = GHS 135 insgesamt\nAnzahlung: GHS 40,50';

  @override
  String get docsDepositRefundTitle => 'Rückerstattungsrichtlinie für Anzahlung';

  @override
  String get docsDepositRefundContent => 'Die 30% Anzahlung ist nicht rückerstattbar. Das bedeutet:';

  @override
  String get docsDepositRefundCancel => 'Wenn Sie stornieren: Anzahlung wird nicht zurückgegeben';

  @override
  String get docsDepositRefundNoShow => 'Wenn Sie nicht erscheinen: Anzahlung wird nicht zurückgegeben';

  @override
  String get docsDepositRefundReschedule => 'Wenn Sie verschieben: Anzahlung wird auf neuen Termin übertragen';

  @override
  String get docsDepositRefundShop => 'Wenn Shop storniert: Volle Anzahlung erstattet';

  @override
  String get docsDepositWarning => 'Bitte stellen Sie sicher, dass Sie sich Ihrer Buchung vor der Anzahlungsleistung sicher sind. Sie können zwar verschieben, aber die Anzahlung kann nicht zurückgegeben werden, wenn Sie stornieren.';

  @override
  String get docsFeeTitle => 'Plattformgebühr';

  @override
  String get docsFeeSubtitle => 'Die kleine Gebühr, die die App am Laufen hält';

  @override
  String get docsFeeWhatTitle => 'Was ist die Plattformgebühr?';

  @override
  String get docsFeeWhatContent => 'Die Plattformgebühr ist eine kleine Pauschalgebühr (z.B. GHS 2), die an die App geht, nicht an den Shop. Sie deckt:';

  @override
  String get docsFeeAppDev => 'App-Entwicklung und Wartung';

  @override
  String get docsFeeSupport => 'Kundensupport und Streitbeilegung';

  @override
  String get docsFeeProcessing => 'Zahlungsabwicklungskosten';

  @override
  String get docsFeeFeatures => 'Neue Funktionen und Verbesserungen';

  @override
  String get docsFeeHowTitle => 'Wie die Gebühr berechnet wird';

  @override
  String get docsFeeHowContent => 'Wichtige Dinge, die Sie über die Plattformgebühr wissen sollten:';

  @override
  String get docsFeeFixed => 'Pauschalgebühr (nicht prozentual) – z.B. GHS 2 pro Buchung';

  @override
  String get docsFeePerbooking => 'Einmal pro Buchung berechnet – nicht pro Service oder Person';

  @override
  String get docsFeeNonRefundable => 'Nicht rückerstattbar – auch wenn Sie stornieren';

  @override
  String get docsFeeShown => 'Deutlich angezeigt, bevor Sie die Zahlung bestätigen';

  @override
  String get docsFeeExamplesTitle => 'Plattformgebühr-Beispiele';

  @override
  String get docsFeeExamplesSingle => 'Eine Person, ein Service: GHS 2 Gebühr';

  @override
  String get docsFeeExamplesMultiple => 'Eine Person, mehrere Services: GHS 2 Gebühr (immer noch eine Buchung!)';

  @override
  String get docsFeeExamplesGroup => 'Familie von 4 bucht zusammen: GHS 2 Gebühr (ganze Gruppe)';

  @override
  String get docsFeeExamplesSeparate => 'Vergleich zu separaten Buchungen:\n4 separate Buchungen = 4 × GHS 2 = GHS 8 Gebühren\n1 Gruppenbuchung = GHS 2 Gebühr – Sie sparen GHS 6!';

  @override
  String get docsFeeGroupTip => 'Gruppenbuchung spart Ihnen Gebühren! Statt für jede Person die Plattformgebühr zu zahlen, zahlen Sie nur eine Gebühr für die gesamte Gruppenbuchung.';

  @override
  String get docsPaymentRemainingTitle => 'Zahlung der verbleibenden 70%';

  @override
  String get docsPaymentRemainingSubtitle => 'Bargeld oder online - Ihre Wahl';

  @override
  String get docsPaymentRemainingOptionsTitle => 'Zwei Zahlungsoptionen';

  @override
  String get docsPaymentRemainingOptionsContent => 'Nach Abschluss Ihres Services haben Sie zwei Möglichkeiten, die verbleibenden 70% zu zahlen:';

  @override
  String get docsPaymentCashOption => 'Bargeld: Zahlen Sie direkt an den Shop oder Mitarbeiter';

  @override
  String get docsPaymentAppOption => 'Per App: Zahlen Sie über die App mit Ihrer gespeicherten Zahlungsmethode';

  @override
  String get docsPaymentRemainingTip => 'Beide Zahlungsmethoden sind gleich gültig. Wählen Sie zum Zeitpunkt des Services, was für Sie am bequemsten ist.';

  @override
  String get docsCancellationTitle => 'Stornierungen & Rückerstattungen';

  @override
  String get docsCancellationSubtitle => 'Was passiert, wenn Sie stornieren müssen';

  @override
  String get docsCancellationInfoTitle => 'Stornierungsrichtlinie';

  @override
  String get docsCancellationInfoContent => 'Verstehen Sie, was bei einer Stornierung passiert:';

  @override
  String get docsCancellationUpTo24 => 'Stornierung bis zu 24 Stunden vorher: Anzahlung und Gebühr sind nicht rückerstattbar';

  @override
  String get docsCancellationLessThan24 => 'Stornierung weniger als 24 Stunden vorher: Gleiche Richtlinie – Anzahlung und Gebühr nicht rückerstattbar';

  @override
  String get docsCancellationReschedule => 'Statt dessen verschieben: Ihre Anzahlung wird auf den neuen Termin übertragen (kostenlos zu verschieben)';

  @override
  String get docsCancellationNoShow => 'Nicht erscheinen: Anzahlung und Gebühr verloren, und kann Ihren Kontostatus beeinträchtigen';

  @override
  String get docsHowToBookTitle => 'So buchen Sie Services';

  @override
  String get docsHowToBookSubtitle => 'Ein Schritt-für-Schritt-Leitfaden zum Buchen Ihrer Termine';

  @override
  String get docsHowToBookOverviewTitle => 'Buchung auf einen Blick';

  @override
  String get docsHowToBookOverviewSubtitle => 'Der Buchungsprozess in einfachen Schritten';

  @override
  String get docsHowToBookTwoWaysTitle => 'Zwei Buchungsarten';

  @override
  String get docsHowToBookTwoWaysContent => 'Sie können auf zwei Arten buchen:';

  @override
  String get docsHowToBookTwoWaysWithApp => 'Mit App-Konto: App herunterladen, Konto erstellen, jederzeit buchen';

  @override
  String get docsHowToBookTwoWaysGuest => 'Als Gast: Buchungslink nutzen, keine App nötig, Quittung via WhatsApp';

  @override
  String get docsHowToBookStepsTitle => 'Ihre Buchungsreise (Mit Konto)';

  @override
  String get docsHowToBookStepsContent => 'Eine Dienstleistung zu buchen dauert nur wenige Minuten. Hier ist, was Sie tun:';

  @override
  String get docsHowToBookStep1 => 'Schritt 1: Finden Sie einen Laden und durchsuchen Sie Services';

  @override
  String get docsHowToBookStep2 => 'Schritt 2: Wählen Sie Ihre Services und Mengen';

  @override
  String get docsHowToBookStep3 => 'Schritt 3: Wählen Sie Ihren bevorzugten Mitarbeiter (falls verfügbar)';

  @override
  String get docsHowToBookStep4 => 'Schritt 4: Wählen Sie Datum und Zeit';

  @override
  String get docsHowToBookStep5 => 'Schritt 5: Zahlen Sie 30% Anzahlung + kleine Gebühr zur Bestätigung';

  @override
  String get docsHowToBookStep6 => 'Schritt 6: Nach dem Service zahlen Sie die restlichen 70% in bar oder per App';

  @override
  String get docsHowToBookGuestTitle => 'Gastbuchung (keine App)';

  @override
  String get docsHowToBookGuestContent => 'Sie haben keine App? Wenn ein Laden einen Buchungslink mit Ihnen teilt, folgen Sie den obigen Schritten, benötigen aber kein Konto. Ihre Bestätigung und Quittung gehen an Ihre WhatsApp.';

  @override
  String get docsHowToBookTimeTip => 'Der gesamte Prozess dauert normalerweise weniger als 2 Minuten. Ihr Fortschritt wird gespeichert, daher können Sie sich Zeit nehmen.';

  @override
  String get docsBookingStep1Title => 'Schritt 1: Finden Sie Ihren Laden & Services';

  @override
  String get docsBookingStep1Subtitle => 'Entdecken Sie den perfekten Ort für Ihre Bedürfnisse';

  @override
  String get docsBookingFindShopTitle => 'So finden Sie einen Laden';

  @override
  String get docsBookingFindShopContent => 'Sie können Läden auf verschiedene Arten finden:';

  @override
  String get docsBookingFindShopHome => 'Startbildschirm: Durchsuchen Sie empfohlene Läden in Ihrer Nähe';

  @override
  String get docsBookingFindShopSearch => 'Suche: Suchen Sie nach bestimmten Läden oder Services nach Name';

  @override
  String get docsBookingFindShopCategories => 'Kategorien: Nach Servicetyp filtern (Haarschnitt, Flechten, Bart usw.)';

  @override
  String get docsBookingFindShopFavorites => 'Favoriten: Schnellzugriff auf Läden, die Sie gespeichert haben';

  @override
  String get docsBookingBrowseServicesTitle => 'Dienstleistungen durchsuchen';

  @override
  String get docsBookingBrowseServicesContent => 'Nachdem Sie einen Laden ausgewählt haben, sehen Sie alle verfügbaren Services. Jeder Service zeigt:';

  @override
  String get docsBookingServiceName => 'Servicename (z.B. Afro-Haarschnitt, Boxzöpfe)';

  @override
  String get docsBookingServiceDuration => 'Dauer (wie lange es dauert)';

  @override
  String get docsBookingServicePrice => 'Preis (Kosten für den Service - geht an den Laden)';

  @override
  String get docsBookingServiceDescription => 'Beschreibung (was enthalten ist)';

  @override
  String get docsBookingServiceWorker => 'Mitarbeiteranforderung (ob Sie wählen können, wer es tut)';

  @override
  String get docsBookingServiceExampleTitle => 'Beispiel';

  @override
  String get docsBookingServiceExampleContent => 'Haarschnitt-Service:\n• Name: Afro-Haarschnitt\n• Dauer: 1 Stunde\n• Preis: GHS 45 (bezahlt an Laden)\n• Beschreibung: Professioneller Afro-Haarschnitt mit Styling\n• Mitarbeiter: Sie können Ihren bevorzugten Friseur wählen';

  @override
  String get docsBookingStep2Title => 'Schritt 2: Wählen Sie Ihre Services';

  @override
  String get docsBookingStep2Subtitle => 'Wählen Sie, was Sie wollen und wie viele Personen';

  @override
  String get docsBookingSelectServicesTitle => 'Services auswählen';

  @override
  String get docsBookingSelectServicesContent => 'Um einen Service auszuwählen, tippen Sie einfach darauf. Sie sehen, wie er hervorgehoben wird. Sie können mehrere Services auf einmal auswählen:';

  @override
  String get docsBookingSelectServicesTap => 'Tippen Sie auf einen Service, um ihn auszuwählen';

  @override
  String get docsBookingSelectServicesCheckmark => 'Ausgewählte Services zeigen ein Häkchen';

  @override
  String get docsBookingSelectServicesMultiple => 'Sie können mehrere Services auswählen (z.B. Haarschnitt + Bartpflege)';

  @override
  String get docsBookingSelectServicesDeselect => 'Tippen Sie erneut, um abzuwählen';

  @override
  String get docsBookingGroupBookingTitle => 'Buchung für mehrere Personen';

  @override
  String get docsBookingGroupBookingContent => 'Wenn Sie für eine Gruppe buchen (wie Sie selbst und Ihre Kinder), können Sie die Menge erhöhen:';

  @override
  String get docsBookingGroupBookingQuantity => 'Nach Auswahl eines Services sehen Sie ein + und - Schaltfläche';

  @override
  String get docsBookingGroupBookingIncrease => 'Tippen Sie auf +, um die Anzahl der Personen zu erhöhen';

  @override
  String get docsBookingGroupBookingPrice => 'Der Preis wird automatisch aktualisiert';

  @override
  String get docsBookingGroupBookingLimit => 'Maximale Menge ist angezeigt (einige Services haben Limits)';

  @override
  String get docsBookingGroupExampleTitle => 'Beispiel: Familienbuchung';

  @override
  String get docsBookingGroupExampleContent => 'Dad möchte Haarschnitte für sich und seine zwei Söhne:\n• Wählen Sie \"Haarschnitt\" Service\n• Tippen Sie auf +, bis die Menge 3 zeigt\n• Gesamtpreis zeigt 3 × GHS 45 = GHS 135 (für den Laden)\n• Sie wählen später Mitarbeiter für jede Person';

  @override
  String get docsBookingQuantityTip => 'Die Mengen-Funktion ist perfekt für Familien, Gruppen von Freunden oder jeden, der für mehrere Personen auf einmal bucht.';

  @override
  String get docsGroupBookingsTitle => 'Gruppenbuchungen';

  @override
  String get docsGroupBookingsSubtitle => 'So buchen Sie Services für sich und andere';

  @override
  String get docsGroupIntroTitle => 'Was sind Gruppenbuchungen?';

  @override
  String get docsGroupIntroSubtitle => 'Buchung für Familie, Freunde oder Gruppen leicht gemacht';

  @override
  String get docsGroupExplainedTitle => 'Buchung für mehrere Personen';

  @override
  String get docsGroupExplainedContent => 'Gruppenbuchungen ermöglichen es Ihnen, Services für mehr als eine Person gleichzeitig zu buchen. Dies ist perfekt für:';

  @override
  String get docsGroupExplainedFamilies => 'Familien: Eltern buchen Haarschnitte für sich und ihre Kinder';

  @override
  String get docsGroupExplainedFriends => 'Freunde: Gruppe von Freunden, die Services zusammen in Anspruch nehmen';

  @override
  String get docsGroupExplainedEvents => 'Veranstaltungen: Brautpartys, Geburtstage oder spezielle Anlässe';

  @override
  String get docsGroupExplainedColleagues => 'Kollegen: Teambuilding oder Firmenausflüge';

  @override
  String get docsGroupRealExampleTitle => 'Reales Beispiel';

  @override
  String get docsGroupRealExampleContent => 'Die Familie Mensah braucht Haarschnitte:\n• Vater: Möchte einen Fade-Haarschnitt\n• Mutter: Möchte einen Schnitt\n• Sohn (10): Möchte einen Kinder-Haarschnitt\n• Tochter (8): Möchte Zöpfe\n\nStatt 4 separate Buchungen zu machen, können sie alles auf einmal zusammen buchen!';

  @override
  String get docsGroupBenefitsTitle => 'Vorteile der Gruppenbuchung';

  @override
  String get docsGroupBenefitsContent => 'Eine Gruppenbuchung bietet Ihnen:';

  @override
  String get docsGroupBenefitsTransaction => 'Eine Transaktion: Zahlen Sie Anzahlungen für alle gleichzeitig';

  @override
  String get docsGroupBenefitsTiming => 'Abgestimmte Zeiten: Alle werden ungefähr zur gleichen Zeit bedient';

  @override
  String get docsGroupBenefitsWorkers => 'Verschiedene Mitarbeiter: Jede Person kann ihren bevorzugten Mitarbeiter wählen';

  @override
  String get docsGroupBenefitsManagement => 'Vereinfachte Verwaltung: Alle Buchungen zusammen anzeigen und verwalten';

  @override
  String get docsGroupBenefitsPlanning => 'Bessere Planung: Der Laden kann sich auf Ihre Gruppe vorbereiten';

  @override
  String get docsGroupTip => 'Gruppenbuchungen sind perfekt für Familien! Sie können für sich und Ihre Kinder auf einmal buchen und für jede Person verschiedene Mitarbeiter wählen. Kein Konto nötig? Nutzen Sie einen vom Laden geteilten Buchungslink!';

  @override
  String get docsGroupHowTitle => 'So tätigen Sie eine Gruppenbuchung';

  @override
  String get docsGroupHowSubtitle => 'Schritt-für-Schritt-Anleitung';

  @override
  String get docsGroupStep1Title => 'Schritt 1: Wählen Sie Ihren Service';

  @override
  String get docsGroupStep1Content => 'Beginnen Sie mit der Suche nach einem Laden und wählen Sie den gewünschten Service. Tippen Sie beispielsweise auf \"Haarschnitt\".';

  @override
  String get docsGroupStep2Title => 'Schritt 2: Wählen Sie die Menge';

  @override
  String get docsGroupStep2Content => 'Nachdem Sie einen Service ausgewählt haben, sehen Sie + und - Schaltflächen. Verwenden Sie diese, um festzulegen, wie viele Personen diesen Service benötigen:';

  @override
  String get docsGroupStep2Plus => 'Tippen Sie auf +, um die Anzahl zu erhöhen';

  @override
  String get docsGroupStep2Minus => 'Tippen Sie auf -, um zu verringern';

  @override
  String get docsGroupStep2Price => 'Der Preis wird automatisch aktualisiert';

  @override
  String get docsGroupStep2Max => 'Sie können die angegebene maximale Menge nicht überschreiten';

  @override
  String get docsGroupStep2ExampleTitle => 'Beispiel';

  @override
  String get docsGroupStep2ExampleContent => 'Für eine Familie von 3, die Haarschnitte benötigt:\n• Wählen Sie \"Haarschnitt\" Service\n• Tippen Sie zweimal auf + (oder bis die Menge 3 zeigt)\n• Gesamtpreis zeigt: 3 × GHS 45 = GHS 135';

  @override
  String get docsGroupStep3Title => 'Schritt 3: Wiederholen Sie für jeden Service';

  @override
  String get docsGroupStep3Content => 'Wenn Ihre Gruppe verschiedene Services benötigt (z.B. einige wollen Haarschnitte, andere Zöpfe), wählen Sie jeden Service aus und legen Sie die Menge fest:';

  @override
  String get docsGroupStep3Haircut => 'Wählen Sie \"Haarschnitt\" → legen Sie Menge 2 fest';

  @override
  String get docsGroupStep3Braids => 'Wählen Sie \"Zöpfe\" → legen Sie Menge 1 fest';

  @override
  String get docsGroupStep3Track => 'Das System verfolgt alle Auswahlen';

  @override
  String get docsGroupStep3ExampleTitle => 'Beispiel: Gemischte Services';

  @override
  String get docsGroupStep3ExampleContent => 'Familie von 4 mit unterschiedlichen Bedürfnissen:\n• Vater: Haarschnitt (Menge 1)\n• Mutter: Schnitt (Menge 1)\n• Sohn: Kinder-Haarschnitt (Menge 1)\n• Tochter: Zöpfe (Menge 1)\n\nGesamt: 4 Services, aber Sie haben alles auf einmal gebucht!';

  @override
  String get docsGroupStep4Title => 'Schritt 4: Wählen Sie Mitarbeiter für jede Person';

  @override
  String get docsGroupStep4Content => 'Für Services, bei denen Sie Mitarbeiter wählen können, sehen Sie eine Liste von Personen. Tippen Sie auf jede Person, um ihren Mitarbeiter zuzuweisen:';

  @override
  String get docsGroupStep4Person1 => 'Person 1: Wählen Sie John (Fade-Spezialist)';

  @override
  String get docsGroupStep4Person2 => 'Person 2: Wählen Sie Sarah (Flechten-Expertin)';

  @override
  String get docsGroupStep4Person3 => 'Person 3: Wählen Sie Michael (Kinder-Haarschnitte)';

  @override
  String get docsGroupStep4Person4 => 'Person 4: Wählen Sie John (gleicher Mitarbeiter für mehrere Personen)';

  @override
  String get docsGroupStep4ExampleTitle => 'Beispiel: Verschiedene Mitarbeiter für verschiedene Personen';

  @override
  String get docsGroupStep4ExampleContent => 'Familie von 3 bucht Haarschnitte:\n• Person 1 (Vater): Wählen Sie John (Fade-Spezialist)\n• Person 2 (Sohn): Wählen Sie Michael (großartig mit Kindern)\n• Person 3 (Tochter): Wählen Sie Sarah (Flechten-Expertin)\n\nAlle drei werden während Ihres Termins bedient.';

  @override
  String get docsGroupStep5Title => 'Schritt 5: Wählen Sie Ihre Zeit';

  @override
  String get docsGroupStep5Content => 'Wenn Sie ein Datum und eine Uhrzeit auswählen, zeigt das System Zeitfenster, die ALLE Personen in Ihrer Gruppe berücksichtigen können:';

  @override
  String get docsGroupStep5Regular => 'Normalansicht: Zeigt Zeitfenster für jeden Service separat';

  @override
  String get docsGroupStep5Combined => 'Kombinierte Ansicht: Zeigt nur Zeitfenster, in denen alle zusammen bedient werden können';

  @override
  String get docsGroupStep5Duration => 'Dauer: Die angezeigte Zeit umfasst alle Services für alle Personen';

  @override
  String get docsGroupStep5ExampleTitle => 'Beispiel: Zeitberechnung';

  @override
  String get docsGroupStep5ExampleContent => 'Familienbuchung:\n• Haarschnitt (45 min) × 2 Personen = 90 min\n• Zöpfe (2 Stunden) × 1 Person = 120 min\n• Pufferzeit zwischen Services = 15 min\n• Gesamte Terminzeit: 3 Stunden 45 Minuten\n\nDas System erledigt all dies automatisch!';

  @override
  String get docsGroupStep6Title => 'Schritt 6: Zahlung';

  @override
  String get docsGroupStep6Content => 'Bei Gruppenbuchungen zahlen Sie:';

  @override
  String get docsGroupStep6Deposit => '30% Anzahlung: Berechnet auf die GESAMTKOSTEN aller Services';

  @override
  String get docsGroupStep6Fee => 'Plattformgebühr: Kleine Pauschalgebühr (z.B. GHS 2) - NUR EINMAL für gesamte Gruppe berechnet';

  @override
  String get docsGroupStep6Remaining => 'Verbleibende 70%: Nach Abschluss aller Services bezahlt';

  @override
  String get docsGroupStep6Options => 'Zahlungsoptionen: Bargeld, Karte, Mobile Money oder App-Zahlung';

  @override
  String get docsGroupStep6ExampleTitle => 'Zahlungsbeispiel';

  @override
  String get docsGroupStep6ExampleContent => 'Familienbuchung insgesamt: GHS 400\n• Anzahlung bei Buchung: GHS 120 (30% von GHS 400)\n• Plattformgebühr: GHS 2 (NUR EINMAL für gesamte Gruppe berechnet)\n• Jetzt zu zahlen: GHS 122\n• Nach Service verbleibend: GHS 280\n• Zahlung nach: Bargeld an Mitarbeiter/Laden ODER per App (Ihre Wahl)';

  @override
  String get docsGroupPaymentFlexibility => 'Mehrere Zahlungsoptionen';

  @override
  String get docsGroupPaymentFlexibilityContent => 'Für die verbleibenden 70% haben Sie Optionen:';

  @override
  String get docsGroupPaymentFlexibilityAllCash => 'Alles Bargeld: Alle zahlen in bar, wenn der Service fertig ist';

  @override
  String get docsGroupPaymentFlexibilitySplit => 'Geteilte Zahlungen: Einige zahlen bar, andere zahlen per App';

  @override
  String get docsGroupPaymentFlexibilityMixed => 'Mischung aus Bargeld & App: Ein Teil in bar, ein Teil per App';

  @override
  String get docsGroupPaymentFlexibilityIndividual => 'Individuelle App-Zahlungen: Jede Person zahlt per App';

  @override
  String get docsGroupPaymentFlexibilityTip => 'Wählen Sie, was für Ihre Gruppe am besten funktioniert!';

  @override
  String get docsGroupImportant => 'Die Anzahlung und Plattformgebühr werden auf die GESAMTE Gruppenbuchung berechnet, nicht pro Person. Sie zahlen einmal für die ganze Gruppe.';

  @override
  String get docsCreateShopTitle => 'Shop erstellen';

  @override
  String get docsCreateShopSubtitle => 'Richten Sie Ihr Geschäft ein';

  @override
  String get docsShopOverviewTitle => 'Erste Schritte mit Ihrem Laden';

  @override
  String get docsShopOverviewSubtitle => 'Erfahren Sie die Grundlagen der Erstellung Ihres Geschäftsprofils';

  @override
  String get docsWelcomeIntroTitle => 'Willkommen in Ihrem Laden-Dashboard';

  @override
  String get docsWelcomeIntroContent => 'Die Erstellung eines Ladens auf Aura In dauert nur wenige Minuten. Sie fügen Ihre Geschäftsinformationen hinzu, legen Ihre Services und Arbeitszeiten fest, und Sie können Buchungen von Kunden entgegennehmen.';

  @override
  String get docsSetupStepsTitle => 'Was Sie einrichten werden';

  @override
  String get docsSetupStepsContent => 'Hier ist, was Sie bei der Erstellung Ihres Ladens tun:';

  @override
  String get docsSetupStepsShopName => 'Fügen Sie Ihren Ladennamen und Ihr Logo hinzu';

  @override
  String get docsSetupStepsDescription => 'Schreiben Sie eine kurze Beschreibung Ihres Geschäfts';

  @override
  String get docsSetupStepsType => 'Wählen Sie Ihren Ladentyp (Salon, Friseur, Spa, etc.)';

  @override
  String get docsSetupStepsLocation => 'Legen Sie Ihren Standort und Ihre Serviceadresse fest';

  @override
  String get docsSetupStepsHours => 'Fügen Sie Ihre Arbeitszeiten hinzu';

  @override
  String get docsSetupStepsServices => 'Erstellen Sie Services, die Sie anbieten, mit Preisen';

  @override
  String get docsSetupStepsContact => 'Fügen Sie Kontaktinformationen hinzu';

  @override
  String get docsSetupStepsPhotos => 'Laden Sie Fotos und Dokumente hoch';

  @override
  String get docsSetupTip => 'Ihre Arbeit wird automatisch gespeichert, während Sie das Formular ausfüllen. Sie können jederzeit zurückkehren, um die Bearbeitung fortzusetzen oder zu veröffentlichen.';

  @override
  String get docsBasicInfoTitle => 'Grundlegende Laden-Informationen';

  @override
  String get docsBasicInfoSubtitle => 'Sagen Sie Kunden, wer Sie sind';

  @override
  String get docsLogoTitle => 'Fügen Sie Ihr Laden-Logo hinzu';

  @override
  String get docsLogoContent => 'Ihr Logo ist das erste, das Kunden sehen. Es sollte Ihr Geschäft klar darstellen. Verwenden Sie ein quadratisches Bild (z.B. 500x500 Pixel) für beste Ergebnisse.';

  @override
  String get docsShopNameTitle => 'Laden-Name';

  @override
  String get docsShopNameContent => 'Geben Sie Ihren Geschäftsnamen genau so ein, wie Kunden ihn sehen sollen. Seien Sie klar und professionell. Beispiel: \"Marienś Frisursalon\" oder \"City Friseur\"';

  @override
  String get docsShopTypeTitle => 'Wählen Sie Ihren Ladentyp';

  @override
  String get docsShopTypeContent => 'Wählen Sie die Art des Geschäfts, das Sie betreiben. Dies hilft Kunden, Sie in der Suche zu finden. Verfügbare Typen sind:';

  @override
  String get docsShopTypeSalon => 'Frisursalon - für Haarschnitte, Färbungen, Styling';

  @override
  String get docsShopTypeBarber => 'Friseur - für Herrenhaarschnitte und Grooming';

  @override
  String get docsShopTypeSpa => 'Spa - für Massagen, Gesichtsbehandlungen, Wellnessservices';

  @override
  String get docsShopTypeBeauty => 'Schönheitsservices - Make-up, Nägel und andere Schönheitsbehandlungen';

  @override
  String get docsShopTypeOther => 'Andere Services - für Geschäfte, die oben nicht aufgeführt sind';

  @override
  String get docsDescriptionTitle => 'Laden-Beschreibung';

  @override
  String get docsDescriptionContent => 'Schreiben Sie eine kurze Beschreibung über Ihren Laden (100-200 Wörter). Sagen Sie Kunden, was Sie besonders macht. Beispiel: \"Wir spezialisieren uns auf natürliche Haarflege und modernes Styling für alle Haartypen. Familienfreundliche Umgebung mit professionellen Stylisten.\"';

  @override
  String get docsTermsTitle => 'Allgemeine Geschäftsbedingungen';

  @override
  String get docsTermsContent => 'Fügen Sie alle wichtigen Regeln hinzu, die Kunden kennen sollten. Beispiele: Stornierungsrichtlinie, Altersbeschränkungen, Anzahlungsanforderungen, Kleiderordnung oder Gesundheitsbeschränkungen.';

  @override
  String get docsLocationTitle => 'Standort & Öffnungszeiten';

  @override
  String get docsLocationSubtitle => 'Wo Kunden Sie finden können und wann Sie arbeiten';

  @override
  String get docsLocationIntroTitle => 'Legen Sie Ihren Standort fest';

  @override
  String get docsLocationIntroContent => 'Kunden müssen wissen, wo sie Sie finden können. Sie können entweder:';

  @override
  String get docsLocationPin => 'Markieren Sie Ihren Standort auf der Karte (ziehen Sie den Marker)';

  @override
  String get docsLocationSearch => 'Suchen Sie nach Ihrer Adresse in der Suchbox';

  @override
  String get docsLocationManual => 'Geben Sie Ihre Straßenadresse manuell ein';

  @override
  String get docsLocationAccuracy => 'Stellen Sie sicher, dass Ihr Standort genau ist. Kunden nutzen ihn, um Sie zu finden und die Fahrtzeit zu berechnen.';

  @override
  String get docsWorkingHoursTitle => 'Legen Sie Ihre Arbeitszeiten fest';

  @override
  String get docsWorkingHoursContent => 'Kunden können nur zu Zeiten buchen, wenn Sie geöffnet sind. Legen Sie Ihre Stunden für jeden Wochentag fest.';

  @override
  String get docsHoursExampleTitle => 'Beispielplan';

  @override
  String get docsHoursExampleContent => 'Montag - Freitag: 9:00 Uhr bis 18:00 Uhr\nSamstag: 10:00 Uhr bis 16:00 Uhr\nSonntag: Geschlossen';

  @override
  String get docsHoursTip => 'Sie können unterschiedliche Öffnungszeiten für verschiedene Tage festlegen oder jeden Tag als geschlossen markieren, wenn Sie nicht arbeiten.';

  @override
  String get docsServicesTitle => 'Services & Preisgestaltung';

  @override
  String get docsServicesSubtitle => 'Sagen Sie Kunden, was Sie anbieten und wie viel es kostet';

  @override
  String get docsServicesIntroTitle => 'Fügen Sie Ihre Services hinzu';

  @override
  String get docsServicesIntroContent => 'Jeder Service ist etwas, das Kunden buchen und bezahlen können. Beispiele: \"Haarschnitt\", \"Haarfärbung\", \"Massage\", \"Gesichtsbehandlung\".';

  @override
  String get docsServiceDetailsTitle => 'Für jeden Service hinzufügen:';

  @override
  String get docsServiceDetailsContent => 'Wenn Sie einen Service erstellen, müssen Sie folgendes bereitstellen:';

  @override
  String get docsServiceName => 'Service-Name - was Sie anbieten (z.B. \"Haarschnitt\")';

  @override
  String get docsServiceDescription => 'Beschreibung - kurze Details über das, was enthalten ist';

  @override
  String get docsServicePrice => 'Preis - wie viel der Service kostet';

  @override
  String get docsServiceDuration => 'Dauer - wie lange es dauert (z.B. 30 Minuten, 1 Stunde)';

  @override
  String get docsServiceCategory => 'Kategorie - welche Art von Service es ist';

  @override
  String get docsPricingTipTitle => 'Preisgestaltungs-Tipp';

  @override
  String get docsPricingTipContent => 'Seien Sie klar mit Ihren Preisen. Sie können verschiedene Service-Stufen anbieten (z.B. \"Basis-Haarschnitt\" vs \"Premium-Haarschnitt\") zu unterschiedlichen Preisen.';

  @override
  String get docsDurationImportant => 'Legen Sie die Dauer genau fest. Kunden buchen basierend auf dieser Zeit, und das Personal muss wissen, wie lange es reservieren soll.';

  @override
  String get docsTeamTitle => 'Verwalten Sie Ihr Team';

  @override
  String get docsTeamSubtitle => 'Fügen Sie Mitarbeiter hinzu und weisen Sie sie Services zu';

  @override
  String get docsWorkersIntroTitle => 'Fügen Sie Ihren Personalbestand hinzu';

  @override
  String get docsWorkersIntroContent => 'Wenn Sie Teammitglieder in Ihrem Laden haben, können Sie diese hier hinzufügen. Dies hilft Ihnen, zu verwalten, wer für Buchungen verfügbar ist.';

  @override
  String get docsAddWorkerTitle => 'So fügen Sie ein Teammitglied hinzu';

  @override
  String get docsAddWorkerContent => 'Wenn Sie einen Mitarbeiter hinzufügen, benötigen Sie:';

  @override
  String get docsFreelancerTitle => 'Werden Sie Freiberufler';

  @override
  String get docsFreelancerSubtitle => 'Arbeiten Sie unabhängig';

  @override
  String get docsFreelancerOverviewTitle => 'Erste Schritte als Freiberufler';

  @override
  String get docsFreelancerOverviewSubtitle => 'Erfahren Sie, wie Sie Ihr Profil einrichten und anfangen, Kunden entgegenzunehmen';

  @override
  String get docsFreelancerWelcomeTitle => 'Willkommen beim Freiberufertum';

  @override
  String get docsFreelancerWelcomeContent => 'Als Freiberufler auf Aura In bieten Sie Services direkt an Kunden in Ihrer Gegend an. Im Gegensatz zu einem traditionellen Laden arbeiten Sie von Ihrem eigenen Standort aus und können zu Kunden reisen. Richten Sie Ihr Profil in wenigen Minuten ein und beginnen Sie, Buchungen anzunehmen.';

  @override
  String get docsFreelancerVsShopTitle => 'Freiberufler vs. Laden: Was ist der Unterschied?';

  @override
  String get docsFreelancerVsShopContent => 'So funktioniert Freiberufertum:';

  @override
  String get docsFreelancerIndependent => 'Sie arbeiten unabhängig - kein fester Ladengeschäft erforderlich';

  @override
  String get docsFreelancerTravel => 'Sie können zu Kunden innerhalb Ihres gewählten Radius reisen';

  @override
  String get docsFreelancerHours => 'Sie legen Ihre eigenen Stunden und Verfügbarkeit fest';

  @override
  String get docsFreelancerManage => 'Sie verwalten Ihren eigenen Zeitplan und Ihre Kunden';

  @override
  String get docsFreelancerBooking => 'Kunden buchen Sie direkt für Services';

  @override
  String get docsFreelancerRequirementsTitle => 'Was Sie benötigen';

  @override
  String get docsFreelancerRequirementsContent => 'Um als Freiberufler zu beginnen, benötigen Sie: Ihren Namen, einen Berufstyp (Friseur, Massagetherapeut, etc.), Standort, Reiseradius, Services und Ihre Arbeitszeiten. Ein professionelles Foto hilft Kunden, Ihnen zu vertrauen.';

  @override
  String get docsProfileSetupTitle => 'Erstellen Sie Ihr Profil';

  @override
  String get docsProfileSetupSubtitle => 'Sagen Sie Kunden, wer Sie sind';

  @override
  String get docsProfilePhotoTitle => 'Fügen Sie Ihr Profilfoto hinzu';

  @override
  String get docsProfilePhotoContent => 'Ein professionelles Porträt schafft Vertrauen bei Kunden. Verwenden Sie ein klares, gut belichtetes Foto von sich selbst. Kunden möchten wissen, mit wem sie buchen.';

  @override
  String get docsYourNameTitle => 'Ihr Name';

  @override
  String get docsYourNameContent => 'Geben Sie Ihren vollständigen Namen genau so ein, wie Kunden ihn sehen sollen. Seien Sie professionell und klar.';

  @override
  String get docsProfessionTypeTitle => 'Wählen Sie Ihren Beruf';

  @override
  String get docsProfessionTypeContent => 'Wählen Sie, was Sie tun. Beispiele: Friseur, Massagetherapeut, Make-up-Künstler, Friseur, Kosmetikerin oder andere spezialisierte Services.';

  @override
  String get docsBioDescriptionTitle => 'Schreiben Sie Ihre Biografie';

  @override
  String get docsBioDescriptionContent => 'Schreiben Sie eine kurze Beschreibung über sich selbst und Ihre Erfahrung (50-150 Wörter). Sagen Sie Kunden, was Sie besonders macht. Beispiel: \"Ich spezialisiere mich auf natürliche Haarpflege mit 5 Jahren Erfahrung. Zertifiziert in Färben und Styling.\"';

  @override
  String get docsTermsGuidelinesTitle => 'Fügen Sie Ihre Richtlinien hinzu';

  @override
  String get docsTermsGuidelinesContent => 'Teilen Sie alle wichtigen Regeln oder Richtlinien mit. Beispiele: Altersbeschränkungen, Stornierungsrichtlinie, Gesundheitsanforderungen oder Vorbereitungsanweisungen.';

  @override
  String get docsServiceAreaTitle => 'Legen Sie Ihren Servicebereich fest';

  @override
  String get docsServiceAreaSubtitle => 'Definieren Sie, wo Sie arbeiten';

  @override
  String get docsBaseLocationTitle => 'Legen Sie Ihren Basisstandort fest';

  @override
  String get docsBaseLocationContent => 'Dies ist, wo Sie normalerweise arbeiten. Kunden innerhalb Ihres Reiseradius können Sie buchen. Sie können entweder auf der Karte markieren oder Ihre Adresse durchsuchen.';

  @override
  String get docsTravelRadiusTitle => 'Reiseradius';

  @override
  String get docsTravelRadiusContent => 'Wie weit sind Sie bereit, zu Kunden zu reisen? Legen Sie dies in Kilometern fest. Beispiel: \"5 km Radius\" bedeutet, dass Kunden bis zu 5 km von Ihrem Standort aus Sie buchen können.';

  @override
  String get docsMobileVsFixedTitle => 'Mobile oder fester Standort?';

  @override
  String get docsMobileVsFixedContent => 'Wählen Sie, ob Sie zu Kunden reisen oder sie an einem Ort treffen. Wenn Sie mobil sind, können Kunden Sie bei ihnen zu Hause oder im Büro anfordern.';

  @override
  String get docsServiceAddressTip => 'Kunden sehen Ihren Reiseradius bei der Suche. Seien Sie genau, damit sie wissen, ob Sie ihren Bereich bedienen können.';

  @override
  String get docsToolsSetupTitle => 'Listen Sie Ihre Werkzeuge und Ausrüstungen auf';

  @override
  String get docsToolsSetupSubtitle => 'Zeigen Sie Kunden, was Sie mitbringen';

  @override
  String get docsToolsIntroTitle => 'Was sind Werkzeuge?';

  @override
  String get docsToolsIntroContent => 'Werkzeuge sind die Ausrüstung oder Fähigkeiten, die Sie haben. Sie helfen Kunden zu verstehen, was Sie tun können und was sie erwarten können.';

  @override
  String get docsToolExamplesTitle => 'Beispiel-Werkzeuge';

  @override
  String get docsToolExamplesContent => 'Für verschiedene Berufe:';

  @override
  String get docsToolHairdresser => 'Friseur: Föhn, Glätteisen, Lockenstab, Schere';

  @override
  String get docsToolMassage => 'Massagetherapeut: Massagetisch, heiße Steine, Aromatherapieöle';

  @override
  String get docsToolMakeup => 'Make-up-Künstler: Make-up-Pinsel, Airbrush, LED-Licht';

  @override
  String get docsToolBarber => 'Friseur: Elektrorasierer, Rasiermesser, Styling-Creme';

  @override
  String get docsToolSelectionTitle => 'Werkzeuge auswählen';

  @override
  String get docsToolSelectionContent => 'Wählen Sie alle Werkzeuge und Ausrüstungen, die Sie beruflich verwenden. Kunden möchten wissen, dass Sie die richtige Ausrüstung für ihren Service haben.';

  @override
  String get docsServicesSetupTitle => 'Services & Preisgestaltung';

  @override
  String get docsServicesSetupSubtitle => 'Sagen Sie Kunden, was Sie anbieten';

  @override
  String get docsServiceBasicsTitle => 'Fügen Sie Ihre Services hinzu';

  @override
  String get docsServiceBasicsContent => 'Jeder Service ist etwas, das Kunden buchen können. Beispiele: \"Haarschnitt\", \"Ganzkörpermassage\", \"Make-up-Anwendung\".';

  @override
  String get docsServiceInfoTitle => 'Für jeden Service hinzufügen:';

  @override
  String get docsServiceInfoContent => 'Sie benötigen:';

  @override
  String get docsServiceInfoName => 'Service-Name - was Sie anbieten';

  @override
  String get docsServiceInfoDescription => 'Beschreibung - was enthalten ist';

  @override
  String get docsServiceInfoPrice => 'Preis - wie viel es kostet';

  @override
  String get docsServiceInfoDuration => 'Dauer - wie lange es dauert (30 Min, 1 Stunde, etc.)';

  @override
  String get docsPricingStrategyTitle => 'Preisgestaltungs-Tipps';

  @override
  String get docsPricingStrategyContent => 'Recherchieren Sie, was andere für ähnliche Services in Ihrer Gegend berechnen. Preisen Sie wettbewerbsfähig, aber fair für Ihren Erfahrungsstand.';

  @override
  String get docsDurationImportanceFreelancer => 'Legen Sie die Dauer genau fest. Dies ist die Zeit, die Sie für jede Buchung blocken. Kunden verlassen sich auf diese Zeit.';

  @override
  String get docsHoursSetupTitle => 'Legen Sie Ihre Verfügbarkeit fest';

  @override
  String get docsHoursSetupSubtitle => 'Wann Sie verfügbar sind zu arbeiten';

  @override
  String get docsHoursIntroTitle => 'Arbeitszeiten';

  @override
  String get docsHoursIntroContent => 'Kunden können nur zu Zeiten buchen, die Sie als verfügbar markieren. Legen Sie Ihre Stunden für jeden Wochentag fest.';

  @override
  String get docsFlexibleHoursTitle => 'Flexibel oder streng?';

  @override
  String get docsFlexibleHoursContent => 'Sie entscheiden. Wenn Sie konsistente Stunden mögen, legen Sie diese fest. Wenn Sie Flexibilität bevorzugen, können Sie täglich nach Bedarf anpassen.';

  @override
  String get docsBlockTimeTip => 'Wenn ein Kunde Sie bucht, ist diese Zeit in Ihrem Kalender blockiert. Legen Sie Ihre Stunden weise fest, um Konflikte zu vermeiden.';

  @override
  String get docsContactCredentialsTitle => 'Kontaktinformationen & Anmeldedaten';

  @override
  String get docsContactCredentialsSubtitle => 'Helfen Sie Kunden, Sie zu erreichen und Vertrauen aufzubauen';

  @override
  String get docsCreateProductTitle => 'Produkte online verkaufen';

  @override
  String get docsCreateProductSubtitle => 'Listen Sie Artikel zum Verkauf auf und erreichen Sie Kunden in Ihrer Nähe';

  @override
  String get docsProductOverviewTitle => 'Erste Schritte beim Verkauf von Produkten';

  @override
  String get docsProductOverviewSubtitle => 'Erfahren Sie, wie Sie Artikel auflisten und verkaufen';

  @override
  String get docsProductWelcomeTitle => 'Willkommen beim Produktverkauf';

  @override
  String get docsProductWelcomeContent => 'Verkaufen Sie physische Produkte direkt an Kunden in Ihrer Gegend. Von handgefertigten Artikeln bis zu Einzelhandelswaren können Sie Kunden erreichen, die das suchen, was Sie anbieten.';

  @override
  String get docsPhoneRequirementTitle => 'Sie benötigen eine verifizierte Telefonnummer';

  @override
  String get docsPhoneRequirementContent => 'Bevor Sie mit dem Verkauf von Produkten beginnen können, müssen Sie Ihre Telefonnummer verifizieren. Dies ist für die Kundenkommunikation und zur Überprüfung Ihrer Identität.';

  @override
  String get docsAddPhoneNumberTitle => 'So fügen Sie Ihre Telefonnummer hinzu';

  @override
  String get docsAddPhoneNumberContent => 'Gehen Sie zu Ihren Profileinstellungen und fügen Sie Ihre Telefonnummer hinzu. Sie erhalten einen Bestätigungscode per SMS, um zu bestätigen, dass dies wirklich Ihre Nummer ist. Dies dauert nur eine Minute.';

  @override
  String get docsWhyPhoneVerifiedTitle => 'Warum Telefonüberprüfung?';

  @override
  String get docsWhyPhoneVerifiedContent => 'Eine verifizierte Telefonnummer schafft Kundenvertrauen und ermöglicht es uns, Sie bei Problemen zu kontaktieren. Es hilft auch, Betrug zu verhindern.';

  @override
  String get docsPhoneImportant => 'Sie können Produkte nicht auflisten, bis Sie eine verifizierte Telefonnummer haben. Dies ist erforderlich für alle Verkäufer.';

  @override
  String get docsProductBasicsTitle => 'Grundlegende Produktinformationen';

  @override
  String get docsProductBasicsSubtitle => 'Was Sie Kunden über Ihr Produkt sagen sollten';

  @override
  String get docsProductNameTitle => 'Produktname';

  @override
  String get docsProductNameContent => 'Geben Sie Ihren Produktnamen deutlich ein. Kunden suchen nach Produktnamen, also seien Sie spezifisch. Beispiel: \"Handgefertigte Lederbrieftasche - Braun\" anstelle von nur \"Brieftasche\".';

  @override
  String get docsProductDescriptionTitle => 'Produktbeschreibung';

  @override
  String get docsProductDescriptionContent => 'Schreiben Sie eine ausführliche Beschreibung. Sagen Sie Kunden, was es ist, woraus es besteht, wie man es benutzt und warum es gut ist. Seien Sie ehrlich zum Zustand (neu, gebraucht, generalüberholt).';

  @override
  String get docsCategorySelectionTitle => 'Wählen Sie eine Kategorie';

  @override
  String get docsCategorySelectionContent => 'Wählen Sie die richtige Kategorie. Kunden stöbern nach Kategorien, um Artikel zu finden, daher ist Genauigkeit wichtig. Wählen Sie die spezifischste verfügbare Kategorie.';

  @override
  String get docsProductConditionTitle => 'Produktzustand';

  @override
  String get docsProductConditionContent => 'Seien Sie klar zum Zustand: Neu (nie benutzt), Wie neu (einmal benutzt), Gut (leichte Abnutzung), Gut (sichtbare Abnutzung) oder Wie gesehen. Ehrlichkeit schafft Vertrauen.';

  @override
  String get docsPricingStockTitle => 'Preis & Verfügbarkeit';

  @override
  String get docsPricingStockSubtitle => 'Legen Sie Ihren Preis fest und verwalten Sie Ihren Bestand';

  @override
  String get docsPricingTitle => 'Legen Sie Ihren Preis fest';

  @override
  String get docsPricingContent => 'Legen Sie einen fairen Preis basierend auf Zustand, Marktwert und lokaler Nachfrage fest. Kunden können ähnliche Artikel sehen, daher hilft wettbewerbsfähige Preisgestaltung.';

  @override
  String get docsCurrencyTitle => 'Währung';

  @override
  String get docsCurrencyContent => 'Preise werden in der Währung Ihres Ladens angezeigt. Stellen Sie sicher, dass Ihre Ladenwährung vor dem Hinzufügen von Produkten korrekt eingestellt ist.';

  @override
  String get docsStockQuantityTitle => 'Lagerbestand';

  @override
  String get docsStockQuantityContent => 'Geben Sie ein, wie viele Artikel Sie haben. Wenn der Bestand zu Ende geht, wird das Produkt als nicht verfügbar angezeigt. Aktualisieren Sie dies, wenn Sie Artikel verkaufen.';

  @override
  String get docsStockTip => 'Halten Sie den Bestand genau. Kunden sind frustriert, wenn sie etwas kaufen, das nicht auf Lager ist. Aktualisieren Sie regelmäßig, wenn Sie verkaufen.';

  @override
  String get docsProductPhotosTitle => 'Produktfotos';

  @override
  String get docsProductPhotosSubtitle => 'Zeigen Sie Kunden, was sie kaufen';

  @override
  String get docsPhotosImportanceTitle => 'Fotos sind am wichtigsten';

  @override
  String get docsPhotosImportanceContent => 'Gute Fotos sind entscheidend. Kunden entscheiden basierend auf Fotos, ob sie kaufen. Schlechte Fotos = weniger Verkäufe.';

  @override
  String get docsWhatPhotosTitle => 'Was fotografieren';

  @override
  String get docsWhatPhotosContent => 'Machen Sie Fotos, die das echte Produkt zeigen:';

  @override
  String get docsPhotoFull => 'Vollständiges Produkt aus mehreren Winkeln';

  @override
  String get docsPhotoCloseups => 'Nahaufnahmen von Details und Qualität';

  @override
  String get docsPhotoCondition => 'Fotos, die den Zustand zeigen (falls benutzt)';

  @override
  String get docsPhotoScale => 'Fotos neben etwas zur Größendarstellung (wie eine Münze oder Hand)';

  @override
  String get docsPhotoDamage => 'Fotos von Schäden oder Verschleiß (Ehrlichkeit schafft Vertrauen)';

  @override
  String get docsPhotoTipsTitle => 'Fototipps zur Qualität';

  @override
  String get docsPhotoTipsContent => 'Verwenden Sie Tageslicht. Machen Sie Fotos vor sauberen Hintergrund. Zeigen Sie Farben genau. Verwenden Sie keine Filter, die das Aussehen des Produkts verändern.';

  @override
  String get docsPhotoCountTitle => 'Wie viele Fotos?';

  @override
  String get docsPhotoCountContent => 'Laden Sie mindestens 3 klare Fotos hoch. Mehr Fotos helfen Kunden, das Produkt besser zu verstehen. Begrenzen Sie auf 10 Fotos pro Produkt.';

  @override
  String get docsToolsTitle => 'Geschäftswerkzeuge';

  @override
  String get docsToolsSubtitle => 'Leistungsstarke Funktionen zur Automatisierung, Förderung und Verwaltung Ihres Unternehmens';

  @override
  String get docsToolsOverviewTitle => 'Werkzeugübersicht';

  @override
  String get docsToolsOverviewSubtitle => 'Was jedes Werkzeug tut und wie man es verwendet';

  @override
  String get docsToolsWelcomeTitle => 'Willkommen bei Geschäftswerkzeugen';

  @override
  String get docsToolsWelcomeContent => 'Die Registerkarte \"Werkzeuge\" bietet 8 leistungsstarke Funktionen, um Ihr Geschäft effektiver zu automatisieren, zu fördern und zu verwalten. Jedes Werkzeug löst ein bestimmtes Geschäftsproblem.';

  @override
  String get docsToolsListTitle => 'Verfügbare Werkzeuge';

  @override
  String get docsToolsListContent => 'Sie haben Zugriff auf diese 8 Werkzeuge:';

  @override
  String get docsToolsReminders => 'Automatische Erinnerungen - Senden Sie Erinnerungen an Kunden';

  @override
  String get docsToolsPromotions => 'Promotions-Manager - Erstellen und verwalten Sie Rabatte';

  @override
  String get docsToolsExport => 'Berichte exportieren - Laden Sie Ihre Geschäftsdaten herunter';

  @override
  String get docsToolsPayment => 'Zahlungseinstellungen - Konfigurieren Sie Zahlungsempfang';

  @override
  String get docsToolsHours => 'Geschäftszeiten - Legen Sie Ihren Arbeitsplan fest';

  @override
  String get docsToolsServices => 'Service-Verwaltung - Fügen Sie Ihre Services hinzu und bearbeiten Sie sie';

  @override
  String get docsToolsLoyalty => 'Treueprogramm - Belohnen Sie treue Kunden';

  @override
  String get docsToolsBroadcasts => 'Broadcasts - Senden Sie Nachrichten an Ihre Kunden';

  @override
  String get docsRemindersTitle => '1. Automatische Erinnerungen';

  @override
  String get docsRemindersSubtitle => 'Senden Sie automatische Erinnerungen an Kunden';

  @override
  String get docsReminderPurposeTitle => 'Was es tut';

  @override
  String get docsReminderPurposeContent => 'Senden Sie automatisch Erinnerungsnachrichten an Kunden vor ihren Buchungen. Reduziert Ausfallquoten und hält Kunden informiert.';

  @override
  String get docsReminderBenefitsTitle => 'Vorteile';

  @override
  String get docsReminderBenefitsContent => 'Automatische Erinnerungen helfen Ihnen:';

  @override
  String get docsReminderBenefitNoShow => 'Reduzieren Sie Ausfallquoten - Kunden vergessen weniger wahrscheinlich';

  @override
  String get docsReminderBenefitExperience => 'Verbessern Sie das Kundenerlebnis - sie wissen, wann sie ankommen';

  @override
  String get docsReminderBenefitTime => 'Sparen Sie Zeit - kein manuelles Anrufen oder Nachrichtenverschluss erforderlich';

  @override
  String get docsReminderBenefitReliability => 'Erhöhen Sie die Zuverlässigkeit - Erinnerungen gehen automatisch raus';

  @override
  String get docsReminderSetupTitle => 'So richten Sie es ein';

  @override
  String get docsReminderSetupContent => 'Klicken Sie auf \"Automatische Erinnerungen konfigurieren\", um die Zeit einzustellen: Senden Sie Erinnerungen 24 Stunden vorher, 2 Stunden vorher oder am Morgen des Termins.';

  @override
  String get docsReminderImpact => 'Läden, die automatische Erinnerungen verwenden, sehen 20-30% weniger Ausfallquoten. Dies wirkt sich direkt auf Ihren Umsatz aus.';

  @override
  String get docsPromosTitle => '2. Promotions-Manager';

  @override
  String get docsPromosSubtitle => 'Erstellen Sie Spezialangebote und Rabatte';

  @override
  String get docsPromosPurposeTitle => 'Was es tut';

  @override
  String get docsPromosPurposeContent => 'Erstellen Sie zeitlich begrenzte Promotionen und Rabatte. Bieten Sie Prozentrabatte, Festbetragrabatte oder kostenlose Add-ons an, um mehr Kunden zu gewinnen.';

  @override
  String get docsPromosExamplesTitle => 'Promotion-Ideen';

  @override
  String get docsPromosExamplesContent => 'Sie können Promotionen wie diese erstellen:';

  @override
  String get docsPromosExample1 => '20% Rabatt auf Haarschnitte am Montag';

  @override
  String get docsPromosExample2 => 'Kostenloses Massageöl bei jeder Massagebuchung';

  @override
  String get docsPromosExample3 => '50 Rabatt auf ein vollständiges Servicepaket';

  @override
  String get docsPromosExample4 => 'Erstkundin: 30% Rabatt';

  @override
  String get docsPromosExample5 => 'Loyalitätsbonus: 5. Service zum halben Preis';

  @override
  String get docsPromosStrategyTitle => 'Promotionsstrategie';

  @override
  String get docsPromosStrategyContent => 'Verwenden Sie Promotionen in langsamen Zeiten, um Buchungen zu steigern. Verfolgen Sie, welche Promotionen am besten durch Ihre Analytik funktionieren.';

  @override
  String get docsExportTitle => '3. Berichte exportieren';

  @override
  String get docsExportSubtitle => 'Laden Sie Ihre Daten zur Analyse herunter';

  @override
  String get docsExportPurposeTitle => 'Was es tut';

  @override
  String get docsExportPurposeContent => 'Laden Sie detaillierte Berichte Ihrer Geschäftsdaten im Tabellenkalkulationsformat herunter. Analysieren Sie Buchungen, Umsätze, Kunden und mehr.';

  @override
  String get docsExportTypesTitle => 'Verfügbare Berichte';

  @override
  String get docsExportTypesContent => 'Sie können exportieren:';

  @override
  String get docsExportBookings => 'Buchungsberichte - alle Buchungen mit Details';

  @override
  String get docsExportRevenue => 'Umsatzberichte - Einnahmen nach Zeitraum';

  @override
  String get docsExportCustomers => 'Kundenberichte - Ihre Kundenliste';

  @override
  String get docsExportServices => 'Service-Berichte - Leistung nach Service';

  @override
  String get docsExportWorkers => 'Mitarbeiterberichte - Leistungsmetriken des Personals';

  @override
  String get docsExportUsesTitle => 'Warum Daten exportieren?';

  @override
  String get docsExportUsesContent => 'Verwenden Sie exportierte Daten in Excel für benutzerdefinierte Analysen, Aufzeichnungen, Steuerzwecke oder zum Austausch mit dem Buchhalter.';

  @override
  String get docsTimeSlotsTitle => 'Zeitfenster erklärt';

  @override
  String get docsTimeSlotsSubtitle => 'Verstehen Sie, wie Buchungszeiten funktionieren';

  @override
  String get docsTimeSlotsOverviewTitle => 'Was sind Zeitfenster?';

  @override
  String get docsTimeSlotsOverviewSubtitle => 'Erfahren Sie, wie das Planungssystem funktioniert';

  @override
  String get docsTimeSlotsWelcomeTitle => 'Willkommen bei Zeitfenstern';

  @override
  String get docsTimeSlotsWelcomeContent => 'Zeitfenster sind die verfügbaren Zeiten, in denen Kunden Ihre Services buchen können. Das Verständnis ihrer Funktionsweise hilft Ihnen, Ihren Zeitplan effizient zu verwalten.';

  @override
  String get docsTimeSlotsBasicsTitle => 'Grundlagen der Zeitfenster';

  @override
  String get docsTimeSlotsBasicsContent => 'So funktionieren Zeitfenster:';

  @override
  String get docsTimeSlotsPoint1 => 'Jeder Service hat eine Dauer (wie lange er dauert)';

  @override
  String get docsTimeSlotsPoint2 => 'Sie legen Ihre verfügbaren Stunden fest (wenn Sie arbeiten)';

  @override
  String get docsTimeSlotsPoint3 => 'Das System erstellt Zeitfenster basierend auf der Service-Dauer';

  @override
  String get docsTimeSlotsPoint4 => 'Kunden können nur verfügbare Slots buchen';

  @override
  String get docsTimeSlotsExampleTitle => 'Beispiel: Zeitfenster erstellen';

  @override
  String get docsTimeSlotsExampleContent => 'Wenn Sie einen 30-Minuten-Haarschnitt anbieten und von 9 Uhr bis 17 Uhr arbeiten:\n• 9:00 Uhr - 9:30 Uhr (Slot 1)\n• 9:30 Uhr - 10:00 Uhr (Slot 2)\n• 10:00 Uhr - 10:30 Uhr (Slot 3)\n...und so weiter den ganzen Tag';

  @override
  String get docsTimeSlotsOverlapTitle => 'Was ist, wenn sich Services überlappen?';

  @override
  String get docsTimeSlotsOverlapContent => 'Wenn Sie mehrere Mitarbeiter haben, hat jede Person ihren eigenen Zeitplan. Wenn Sie alleine arbeiten, kann jeweils nur ein Kunde buchen — das System blockiert automatisch in Konflikt stehende Zeiten.';

  @override
  String get docsTimeSlotsGapTitle => 'Lücken zwischen Services festlegen';

  @override
  String get docsTimeSlotsGapContent => 'Sie können Pufferzeit zwischen Buchungen festlegen. Beispiel: 15-Minuten-Lücke nach jedem Haarschnitt zum Aufräumen. Dies reduziert die verfügbaren Slots, gibt Ihnen aber Atemraum.';

  @override
  String get docsTimeSlotsGroupTitle => 'Gruppenbuchungen und Zeitfenster';

  @override
  String get docsTimeSlotsGroupContent => 'Bei Gruppenbuchungen findet das System Zeiten, die für ALLE Personen in der Gruppe funktionieren. Dies macht es schwieriger, verfügbare Slots zu finden, aber stellt sicher, dass jeder zusammen bedient wird.';

  @override
  String get docsTimeSlotsBlockingTitle => 'Zeit blockieren';

  @override
  String get docsTimeSlotsBlockingContent => 'Sie können Zeit manuell für Mittagessen, Pausen oder persönliche Termine blockieren. Blockierte Zeit wird Kunden nicht als verfügbar angezeigt.';

  @override
  String get docsTimeSlotsUtilizationTitle => 'Ihre Zeitfenster maximieren';

  @override
  String get docsTimeSlotsUtilizationContent => 'Tipps zur effizienten Nutzung Ihrer Slots:\n• Passen Sie die Service-Dauer der Realität an (unterschätzen Sie nicht)\n• Legen Sie realistische Lücken zwischen Services fest\n• Verwenden Sie Pufferzeit strategisch\n• Überprüfen und passen Sie basierend auf Kundenfeedback an';

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
}
