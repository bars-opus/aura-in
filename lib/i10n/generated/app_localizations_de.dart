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
}
