// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Nano Embryo';

  @override
  String get appDescription => 'Votre application innovante';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonLogin => 'Connexion';

  @override
  String get commonLogout => 'Déconnexion';

  @override
  String get commonDone => 'Terminé';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonAccept => 'Accepter';

  @override
  String get commonReject => 'Rejeter';

  @override
  String get introGetStarted => 'Commencer';

  @override
  String get actionsBlock => 'Bloquer l\'utilisateur';

  @override
  String get actionsReport => 'Signaler l\'utilisateur';

  @override
  String get actionsSend => 'Envoyer au chat';

  @override
  String get actionsShare => 'Partager';

  @override
  String get actionsCopy => 'Copier le lien';

  @override
  String get appInfoVersion => 'Version';

  @override
  String get appInfoReleased => 'Publié';

  @override
  String get appInfoPackageName => 'Nom du Paquet';

  @override
  String get appInfoDeveloper => 'Nom du Développeur';

  @override
  String get appInfoSupportEmail => 'Email de Support';

  @override
  String get appInfoTechnicalDetails => 'Détails Techniques';

  @override
  String get appInfoBundleID => 'ID du Paquet';

  @override
  String get appInfoBuildVersion => 'Version de Compilation';

  @override
  String get appInfoBuildNumber => 'Numéro de Compilation';

  @override
  String get appInfoReleaseDate => 'Date de Publication';

  @override
  String get appInfoAppSize => 'Taille de l\'Application';

  @override
  String appInfoOverview(String appName) {
    return '$appName est une application mobile moderne construite avec une sécurité robuste et une fonctionnalité, conçue pour fournir une expérience utilisateur exceptionnelle avec une architecture propre et une optimisation des performances.';
  }

  @override
  String introTitle(String appName) {
    return 'Bienvenue sur $appName';
  }

  @override
  String get introFeature1Title => 'Voir Votre Progrès';

  @override
  String get introFeature1Description => 'Suivez vos jalons de développement avec des analyses détaillées et des insights';

  @override
  String get introFeature2Title => 'Explorer les Modèles';

  @override
  String get introFeature2Description => 'Découvrez des composants et écrans pré-construits pour un développement rapide';

  @override
  String get introFeature3Title => 'Démarrez Rapidement';

  @override
  String get introFeature3Description => 'Lancez votre projet avec une configuration zéro et les meilleures pratiques';

  @override
  String get appleSignIn => 'Se connecter avec Apple';

  @override
  String get googleSignIn => 'Se connecter avec Google';

  @override
  String get appleRegister => 'S\'inscrire avec Apple';

  @override
  String get googleRegister => 'S\'inscrire avec Google';

  @override
  String get emailAndPassword => 'Entrer e-mail et mot de passe';

  @override
  String get signInTitle => 'Se connecter';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get legalConsentPart1 => 'Veuillez lire les ';

  @override
  String get legalConsentPart2 => 'conditions générales';

  @override
  String legalConsentPart3(String appName) {
    return ' et autres documents juridiques qui régissent votre utilisation de $appName.';
  }

  @override
  String get emailTitle => 'E-mail';

  @override
  String get passwordTitle => 'Mot de passe';

  @override
  String get loginEmailLabel => 'Adresse e-mail';

  @override
  String get loginEmailHint => 'Entrez votre e-mail';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginPasswordHint => 'Entrez votre mot de passe';

  @override
  String get loginForgotPasswordPart1 => 'Avez-vous oublié votre mot de passe? ';

  @override
  String get loginForgotPasswordPart2 => 'Appuyez ici';

  @override
  String get loginForgotPasswordPart3 => ' pour réinitialiser votre mot de passe?';

  @override
  String get validationRequired => 'Ce champ est obligatoire';

  @override
  String get validationEmailInvalid => 'Veuillez entrer une adresse e-mail valide';

  @override
  String validationPasswordLength(int minLength) {
    return 'Le mot de passe doit comporter au moins $minLength caractères';
  }

  @override
  String get validationPasswordUppercase => 'Le mot de passe doit inclure au moins une lettre majuscule';

  @override
  String get loggingInIndicatorText => 'Connexion en cours...';

  @override
  String get loginSuccessful => 'Connexion réussie !\nBienvenue de retour';

  @override
  String get errorLoginFailed => 'Échec de la connexion. Veuillez vérifier vos identifiants';

  @override
  String get errorNetwork => 'Erreur réseau. Veuillez vérifier votre connexion';

  @override
  String get homeTitle => 'Accueil';

  @override
  String get profileTitle => 'Profil';

  @override
  String get chatTitle => 'Chat';

  @override
  String get editProfileNameFieldTitle => 'Nom';

  @override
  String get editProfileNameFieldLabel => 'Nom complet';

  @override
  String get editProfileUserFieldNameTitle => 'Nom d\'utilisateur';

  @override
  String get editProfileUsernameFieldLabel => '@nomdutilisateur';

  @override
  String get editProfileBioFieldTitle => 'Biographie';

  @override
  String get editProfileBioFieldLabel => 'Parlez-nous de vous';

  @override
  String get editProfileScreenTitle => 'Modifier le profil';

  @override
  String get editProfileSettingTitle => 'Paramètres du compte';

  @override
  String get editProfileSettingSubtitle => 'Gérez votre compte';

  @override
  String get editProfileScreenEditShopTitle => 'Modifier la boutique';

  @override
  String get editProfileScreenEditShopSubtitle => 'Modifiez les informations de votre boutique';

  @override
  String get languageScreenSubtitle => 'Choisissez votre langue préférée pour l\'interface de l\'application. Cela n\'affectera pas les paramètres de votre appareil.';

  @override
  String get languageScreeUseDeviceLang => 'Use Device Language.';

  @override
  String get languageScreeUseDeviceLangNote => 'This will reset to match your device system language.';

  @override
  String get settingsScreenTitle => 'Paramètres';

  @override
  String get accountSectionTitle => 'Compte';

  @override
  String get accountSectionSubtitle => '';

  @override
  String get profileItemTitle => 'Profil';

  @override
  String get profileItemSubtitle => 'Gérez vos données personnelles';

  @override
  String get locationItemTitle => 'Changer l\'emplacement';

  @override
  String get locationItemSubtitle => 'Changez votre ville actuelle';

  @override
  String get saveItemTitle => 'Contenus sauvegardés';

  @override
  String get saveItemSubtitle => 'Contenus que vous avez sauvegardés';

  @override
  String get notificationsItemTitle => 'Notifications';

  @override
  String get notificationsItemSubtitle => 'Gérez les notifications push et email';

  @override
  String get blockedItemTitle => 'Comptes bloqués';

  @override
  String get blockedItemSubtitle => 'Comptes que vous avez bloqués';

  @override
  String get qrCodeItemTitle => 'Partager le code QR';

  @override
  String get qrCodeItemSubtitle => 'Partagez votre code QR de compte';

  @override
  String get shareProfileItemTitle => 'Partager le profil';

  @override
  String get shareProfileItemSubtitle => 'Partagez votre profil avec des amis';

  @override
  String get appSettingsSectionTitle => 'Paramètres de l\'application';

  @override
  String get appSettingsSectionSubtitle => 'Personnalisez votre expérience';

  @override
  String get themeItemTitle => 'Thème';

  @override
  String get themeItemSubtitle => 'Clair, Sombre ou Système';

  @override
  String get languageItemTitle => 'Langue';

  @override
  String get languageItemSubtitle => 'Changez la langue de l\'application';

  @override
  String get biometricItemTitle => 'Connexion biométrique';

  @override
  String get biometricItemSubtitle => 'Utilisez Face ID ou Touch ID';

  @override
  String get supportSectionTitle => 'Support';

  @override
  String get supportSectionSubtitle => '';

  @override
  String get guideItemTitle => 'Guide d\'utilisation';

  @override
  String get guideItemSubtitle => 'Documentation et tutoriels';

  @override
  String get helpItemTitle => 'Contacter le support';

  @override
  String get helpItemSubtitle => 'Obtenez de l\'aide avec l\'application';

  @override
  String get feedbackItemTitle => 'Envoyer des commentaires';

  @override
  String get feedbackItemSubtitle => 'Partagez vos réflexions';

  @override
  String get rateItemTitle => 'Noter l\'application';

  @override
  String get rateItemSubtitle => 'Laissez un avis';

  @override
  String appInfoItemTitle(String appName) {
    return 'À propos de $appName';
  }

  @override
  String get appInfoItemSubtitle => 'Informations techniques';

  @override
  String get legalSectionTitle => 'Juridique';

  @override
  String get legalSectionSubtitle => '';

  @override
  String get termsItemTitle => 'Conditions, confidentialité et politiques';

  @override
  String get termsItemSubtitle => 'Lisez nos conditions';

  @override
  String get licensesItemTitle => 'Licences open source';

  @override
  String get licensesItemSubtitle => 'Bibliothèques et licences tierces';

  @override
  String get accountActionsSectionTitle => 'Actions du compte';

  @override
  String get accountActionsSectionSubtitle => '';

  @override
  String get deactivateItemTitle => 'Désactiver';

  @override
  String get deactivateItemSubtitle => 'Désactivez votre compte';

  @override
  String get deleteItemTitle => 'Supprimer le compte';

  @override
  String get deleteItemSubtitle => 'Supprimez définitivement votre compte';

  @override
  String get logoutItemTitle => 'Déconnexion';

  @override
  String get logoutItemSubtitle => 'Déconnectez-vous de votre compte';

  @override
  String get loadingDefaultMessage => 'Chargement...';

  @override
  String emptyStateNoDataTitle(String dataType) {
    return 'Aucun(e) $dataType pour le moment';
  }

  @override
  String emptyStateNoDataSubtitle(String dataType) {
    return 'Lorsque $dataType sera disponible, ils/elles apparaîtront ici.';
  }

  @override
  String get emptyStateNoResultsTitle => 'Aucun résultat trouvé';

  @override
  String emptyStateNoResultsSubtitle(String dataType) {
    return 'Essayez d\'ajuster votre recherche ou vos filtres pour trouver $dataType.';
  }

  @override
  String get emptyStateNoInternetTitle => 'Pas de connexion internet';

  @override
  String get emptyStateNoInternetSubtitle => 'Vérifiez votre connexion et réessayez.';

  @override
  String get emptyStateNoFavoritesTitle => 'Aucun favori pour le moment';

  @override
  String get emptyStateNoFavoritesSubtitle => 'Commencez à ajouter des éléments à votre liste de favoris.';

  @override
  String get emptyStateNoMessagesTitle => 'Aucun message';

  @override
  String get emptyStateNoMessagesSubtitle => 'Démarrez une conversation pour voir des messages ici.';

  @override
  String get emptyStateRefresh => 'Actualiser';

  @override
  String get emptyStateClearFilters => 'Effacer les filtres';

  @override
  String get emptyStateRetry => 'Réessayer';

  @override
  String get emptyStateExplore => 'Explorer';

  @override
  String get emptyStateStartChat => 'Démarrer le chat';

  @override
  String get errorNetworkTitle => 'Erreur de connexion';

  @override
  String get errorNetworkSubtitle => 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';

  @override
  String get errorServerTitle => 'Erreur serveur';

  @override
  String get errorServerSubtitle => 'Quelque chose s\'est mal passé de notre côté. Veuillez réessayer plus tard.';

  @override
  String get errorClientTitle => 'Erreur de requête';

  @override
  String get errorClientSubtitle => 'Il y a eu un problème avec votre requête. Veuillez vérifier et réessayer.';

  @override
  String get errorParsingTitle => 'Erreur de données';

  @override
  String errorParsingSubtitle(String dataType) {
    return 'Impossible de traiter le/la $dataType. Cela pourrait être un problème temporaire.';
  }

  @override
  String get errorPermissionTitle => 'Accès refusé';

  @override
  String errorPermissionSubtitle(String dataType) {
    return 'Vous n\'avez pas l\'autorisation d\'accéder à ce/cette $dataType.';
  }

  @override
  String get errorGenericTitle => 'Quelque chose s\'est mal passé';

  @override
  String errorGenericSubtitle(String dataType) {
    return 'Une erreur inattendue s\'est produite lors du chargement de $dataType. Veuillez réessayer.';
  }

  @override
  String get errorRetry => 'Réessayer';

  @override
  String get errorCheckSettings => 'Vérifier les paramètres';

  @override
  String get errorReport => 'Signaler un problème';

  @override
  String get errorGoBack => 'Retour';

  @override
  String get errorRefresh => 'Actualiser';

  @override
  String get errorRequestAccess => 'Demander l\'accès';

  @override
  String get errorContactSupport => 'Contacter le support';

  @override
  String get dataTypeUsers => 'utilisateurs';

  @override
  String get dataTypeUser => 'utilisateur';

  @override
  String get dataTypeProducts => 'produits';

  @override
  String get dataTypeProduct => 'produit';

  @override
  String get dataTypeOrders => 'commandes';

  @override
  String get dataTypeOrder => 'commande';

  @override
  String get dataTypeMessages => 'messages';

  @override
  String get dataTypeMessage => 'message';

  @override
  String get dataTypeFavorites => 'favoris';

  @override
  String get dataTypeFavorite => 'favori';

  @override
  String get dataTypeData => 'données';

  @override
  String get dataTypeContent => 'contenu';

  @override
  String get dataTypeItems => 'éléments';

  @override
  String get dataTypeItem => 'élément';

  @override
  String get eulaTitle => 'Contrat de Licence Utilisateur Final';

  @override
  String eulaContent(String appName, String supportEmail) {
    return 'Ce Contrat de Licence Utilisateur Final (\"CLUF\") est un accord juridique entre vous et Bars Opus, Ltd. pour $appName.\n\nEn installant, accédant ou utilisant $appName, vous acceptez d\'être lié par les termes de ce CLUF. $appName est licencié, non vendu, à vous pour une utilisation uniquement sous les termes de cette licence. Bars Opus, Ltd. se réserve tous les droits non expressément accordés à vous dans ce CLUF.\n\nVous ne pouvez pas modifier, rétro-concevoir, décompiler ou désassembler $appName. Cette licence est valable jusqu\'à ce qu\'elle soit résiliée par vous ou Bars Opus, Ltd. Vos droits en vertu de cette licence cesseront automatiquement sans préavis si vous ne respectez aucun terme.\n\nTous les droits de propriété intellectuelle sur $appName appartiennent à Bars Opus, Ltd. Ce CLUF est régi par les lois de l\'Angleterre et du Pays de Galles.\n\nPour toute question concernant ce CLUF, veuillez contacter : $supportEmail.';
  }

  @override
  String get eulaFooter => 'En acceptant, vous reconnaissez avoir lu et compris ce Contrat de Licence Utilisateur Final.';

  @override
  String get privacyPolicyTitle => 'Politique de Confidentialité';

  @override
  String privacyPolicyContent(String appName) {
    return 'Cette Politique de Confidentialité explique comment Bars Opus, Ltd. (\"nous\", \"notre\") collecte, utilise et protège vos informations lorsque vous utilisez $appName.\n\nNous collectons les informations que vous fournissez directement, comme lorsque vous créez un compte, complétez votre profil ou contactez le support. Nous collectons automatiquement certaines informations sur votre appareil et la façon dont vous utilisez $appName. Nous utilisons des cookies et des technologies de suivi similaires pour suivre l\'activité et conserver certaines informations.\n\nNous utilisons les informations que nous collectons pour fournir, maintenir et améliorer $appName. Nous pouvons partager vos informations avec des prestataires de services tiers qui effectuent des services en notre nom. Nous pouvons divulguer vos informations si la loi l\'exige ou pour protéger nos droits et notre sécurité.\n\nVous avez le droit d\'accéder, de corriger ou de supprimer vos informations personnelles. Nous mettons en œuvre des mesures techniques et organisationnelles appropriées pour protéger vos informations. Nous pouvons mettre à jour cette Politique de Confidentialité de temps à autre. Nous vous informerons de tout changement.';
  }

  @override
  String privacyPolicyFooter(String appName, DateTime currentDate) {
    final intl.DateFormat currentDateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String currentDateString = currentDateDateFormat.format(currentDate);

    return 'Politique de Confidentialité de $appName - Dernière mise à jour : $currentDateString';
  }

  @override
  String get termsTitle => 'Conditions d\'Utilisation';

  @override
  String termsContent(String appName, String supportEmail) {
    return 'Ces Conditions d\'Utilisation (\"Conditions\") régissent votre accès et votre utilisation de $appName. En accédant ou en utilisant $appName, vous acceptez d\'être lié par ces Conditions.\n\nVous devez avoir au moins 13 ans pour utiliser $appName. Vous êtes responsable de la sécurité de vos identifiants de compte et de toutes les activités sous votre compte. Vous ne pouvez pas utiliser $appName à des fins illégales ou non autorisées.\n\nNous nous réservons le droit de modifier, suspendre ou interrompre $appName à tout moment. Tout le contenu inclus dans $appName est la propriété de Bars Opus, Ltd. ou de ses concédants de licence.\n\nNous pouvons résilier ou suspendre votre accès à $appName immédiatement si vous violez ces Conditions. Ces Conditions seront régies et interprétées conformément aux lois de l\'Angleterre et du Pays de Galles.\n\nPour toute question concernant ces Conditions, veuillez nous contacter à $supportEmail.';
  }

  @override
  String get dataSharingTitle => 'Accord de Partage des Données';

  @override
  String dataSharingContent(String appName) {
    return 'Cet Accord de Partage des Données décrit comment vos informations peuvent être partagées lorsque vous utilisez les fonctionnalités sociales de $appName.\n\nLorsque vous vous connectez avec des amis sur $appName, certaines données d\'activité peuvent leur être visibles. Les données d\'activité partagées peuvent inclure la durée de l\'entraînement, les calories brûlées, les minutes d\'exercice et les badges de réussite. Vos informations de profil (nom d\'affichage et photo de profil) sont visibles pour les amis avec lesquels vous vous connectez.\n\nVotre adresse e-mail et vos informations de contact restent privées et ne sont jamais partagées avec d\'autres utilisateurs. Vous contrôlez quelles données sont partagées via vos paramètres de confidentialité de $appName. Vous pouvez révoquer les autorisations de partage à tout moment dans les paramètres de l\'application.\n\nLes données partagées avec des amis sont chiffrées pendant la transmission et le stockage. Nous conservons les données partagées uniquement aussi longtemps que nécessaire pour fournir la fonctionnalité de partage. Les intégrations tierces peuvent avoir leurs propres pratiques de partage de données, que nous recommandons de consulter.';
  }

  @override
  String dataSharingFooter(String appName) {
    return 'Le partage de données dans $appName aide à créer une communauté de soutien tout en respectant vos choix de confidentialité.';
  }

  @override
  String get dashboardTitle => 'Tableau de Bord';

  @override
  String get dashboardSubtitle => 'Gérez les activités de votre boutique efficacement';

  @override
  String get dashboardSectionTitle => 'Tableau de Bord';

  @override
  String get dashboardSectionSubtitle => 'Aperçu des performances et des indicateurs clés de votre boutique';

  @override
  String get dashboardPayoutTitle => 'Demander un Paiement';

  @override
  String get dashboardPayoutContent => 'Les propriétaires de boutique peuvent demander des paiements hebdomadaires. Naviguez vers la section Gains, vérifiez votre solde et soumettez une demande de paiement. Les fonds sont généralement traités dans un délai de 3 à 5 jours ouvrables.';

  @override
  String get dashboardAnalyticsTitle => 'Tableau de Bord Analytique';

  @override
  String get dashboardAnalyticsContent => 'Suivez les performances de votre boutique avec des analyses en temps réel. Surveillez les tendances des ventes, l\'engagement des clients et les niveaux de stock grâce à des graphiques interactifs et des rapports.';

  @override
  String get dashboardScreenshotTitle => 'Vue d\'ensemble du Tableau de Bord';

  @override
  String get dashboardScreenshotContent => 'Le tableau de bord principal offre une vue complète des indicateurs clés de votre boutique, des activités récentes et un accès rapide aux fonctionnalités essentielles.';

  @override
  String get categoryFeatures => 'Fonctionnalités';

  @override
  String get categoryDashboard => 'Tableau de Bord';

  @override
  String get faqDashboard1Question => 'Quand puis-je demander un paiement?';

  @override
  String get faqDashboard1Answer => 'Vous pouvez demander votre paiement une fois par semaine, chaque samedi. La coupure hebdomadaire est le vendredi à 23h59. Les paiements sont traités dans un délai de 3 à 5 jours ouvrables.';

  @override
  String get faqDashboard2Question => 'Où puis-je demander mon paiement?';

  @override
  String get faqDashboard2Answer => 'Naviguez vers votre tableau de bord et cliquez sur la section \'Gains\'. De là, vous verrez votre solde actuel et un bouton \'Demander Paiement\'. Suivez les invites pour compléter votre demande.';
}
