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
  String get languageScreenSubtitle => 'Wählen Sie Ihre bevorzugte Sprache für die App-Oberfläche. Dies wirkt sich nicht auf die Geräteeinstellungen aus.';

  @override
  String get languageScreeUseDeviceLang => 'Use Device Language.';

  @override
  String get languageScreeUseDeviceLangNote => 'This will reset to match your device system language.';

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
  String get deactivateItemTitle => 'Deaktivieren';

  @override
  String get deactivateItemSubtitle => 'Deaktivieren Sie Ihr Konto';

  @override
  String get deleteItemTitle => 'Konto löschen';

  @override
  String get deleteItemSubtitle => 'Ihr Konto dauerhaft entfernen';

  @override
  String get logoutItemTitle => 'Abmelden';

  @override
  String get logoutItemSubtitle => 'Von Ihrem Konto abmelden';

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
}
