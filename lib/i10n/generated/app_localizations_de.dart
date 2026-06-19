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
}
