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
  String get commonConfirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get commonConfirmPasswordHint => 'Veuillez confirmer votre mot de passe';

  @override
  String get commonPasswordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get commonPasswordConfirmRequired => 'Veuillez confirmer votre mot de passe';

  @override
  String commonFieldIsValid(String field) {
    return '$field est valide';
  }

  @override
  String get commonPleaseWait => 'Veuillez patienter jusqu\'à la fin de l\'opération en cours';

  @override
  String get commonUnexpectedError => 'Une erreur inattendue s\'est produite. Veuillez réessayer.';

  @override
  String get commonSomethingWentWrong => 'Quelque chose s\'est mal passé. Veuillez réessayer.';

  @override
  String get commonEnterEmailAndRetry => 'Veuillez entrer votre adresse e-mail et réessayer';

  @override
  String get commonLearnMore => 'En savoir plus';

  @override
  String get authSignUpVerificationSent => 'E-mail de vérification envoyé ! Veuillez vérifier votre boîte de réception.';

  @override
  String authSignUpFailed(String error) {
    return 'Inscription échouée : $error';
  }

  @override
  String get authForgotPasswordTitle => 'Mot de passe oublié ?';

  @override
  String get authForgotPasswordSubtitle => 'Entrez votre e-mail et nous vous enverrons un lien pour réinitialiser votre mot de passe.';

  @override
  String get authSendResetLink => 'Envoyer le lien de réinitialisation';

  @override
  String get authBackToSignIn => 'Retour à la connexion';

  @override
  String get authUsernameScreenTitle => 'Choisissez votre nom d\'utilisateur';

  @override
  String get authUsernameScreenSubtitle => 'C\'est ainsi que les autres vous voient. Vous pouvez le changer plus tard.';

  @override
  String get authUsernameLabel => 'Nom d\'utilisateur';

  @override
  String get authUsernameHint => 'Entrez un nom d\'utilisateur';

  @override
  String authUsernameMinLength(int min) {
    return 'Le nom d\'utilisateur doit comporter au moins $min caractères';
  }

  @override
  String authUsernameMaxLength(int max) {
    return 'Le nom d\'utilisateur doit comporter au maximum $max caractères';
  }

  @override
  String get authUsernameFormatError => 'Seules les lettres, les chiffres et les traits de soulignement sont autorisés';

  @override
  String get authUsernameTaken => 'Ce nom d\'utilisateur est déjà pris';

  @override
  String get authUsernameCheckError => 'Impossible de vérifier la disponibilité. Veuillez réessayer.';

  @override
  String get authUsernameSaveError => 'Impossible d\'enregistrer votre nom d\'utilisateur. Veuillez réessayer.';

  @override
  String get authUsernameSavedSuccess => 'Nom d\'utilisateur enregistré avec succès !';

  @override
  String get authUpdatePasswordTitle => 'Créer un nouveau mot de passe';

  @override
  String get authUpdatePasswordButton => 'Mettre à jour le mot de passe';

  @override
  String get authUpdatePasswordSuccess => 'Mot de passe mis à jour avec succès. Veuillez vous reconnecter.';

  @override
  String get authPasswordResetSentTitle => 'Vérifiez votre e-mail';

  @override
  String get authPasswordResetSentBody => 'Nous avons envoyé un lien de réinitialisation de mot de passe à';

  @override
  String get authPasswordResetSentNote => 'Appuyez sur le lien dans l\'e-mail pour définir un nouveau mot de passe. Le lien expire dans 1 heure.';

  @override
  String get authGuestHello => 'Bonjour !';

  @override
  String authGuestOverview(String appName) {
    return 'Vous naviguez $appName en tant qu\'invité. Connectez-vous ou créez un compte pour commencer à gérer votre boutique – cela prend moins de 5 secondes. Nous avons une variété d\'outils pour vous aider à développer votre entreprise, tous gratuits.';
  }

  @override
  String authIntroTitle(String appName) {
    return 'Bienvenue sur\n$appName';
  }

  @override
  String get authIntroSubtitle => 'Bienvenue sur la plateforme que nous avons créée pour vous. Profitez et amusez-vous – le meilleur vous attend.';

  @override
  String get authReadLegalities => 'Lire les mentions légales';

  @override
  String get authPasswordRequired => 'Veuillez entrer votre mot de passe';

  @override
  String get authCreatingAccount => 'Création du compte...';

  @override
  String get authAccountCreatedSuccess => 'Compte créé avec succès !';

  @override
  String get authCheckEmailToConfirm => 'Veuillez vérifier votre e-mail pour confirmer votre compte';

  @override
  String get authSigningInWithGoogle => 'Connexion avec Google...';

  @override
  String authGoogleSignInFailed(String error) {
    return 'Échec de la connexion Google : $error';
  }

  @override
  String get authAuthenticatingWithApple => 'Authentification avec Apple...';

  @override
  String authAppleSignInFailed(String error) {
    return 'Échec de la connexion Apple : $error';
  }

  @override
  String get authSendingResetEmail => 'Envoi de l\'e-mail de réinitialisation...';

  @override
  String get authResetEmailSent => 'E-mail de réinitialisation envoyé. Vérifiez votre boîte de réception.';

  @override
  String authPasswordResetFailed(String error) {
    return 'Échec de la réinitialisation du mot de passe : $error';
  }

  @override
  String get authVerifyEmailTitle => 'Vérifiez votre e-mail';

  @override
  String get authVerifyEmailSubtitle => 'Nous avons envoyé un lien de confirmation à';

  @override
  String get authVerifyEmailNote => 'Appuyez sur le lien dans l\'e-mail pour vérifier votre compte et continuer.';

  @override
  String get authConfirmationResent => 'E-mail de confirmation renvoyé. Vérifiez votre boîte de réception.';

  @override
  String get authResendFailed => 'Échec de l\'envoi de l\'e-mail. Veuillez réessayer.';

  @override
  String get authResendEmailButton => 'Renvoyer l\'e-mail de confirmation';

  @override
  String authResendEmailCooldown(int seconds) {
    return 'Renvoyer l\'e-mail (${seconds}s)';
  }

  @override
  String get currencySelectorPlaceholder => 'Sélectionner une devise';

  @override
  String get currencySelectorNoSelected => 'Aucune devise sélectionnée';

  @override
  String get currencySelectorTitle => 'Sélectionner une devise';

  @override
  String get currencySelectorSearchHint => 'Rechercher par devise, code ou drapeau...';

  @override
  String get currencySelectorNoResults => 'Aucune devise trouvée';

  @override
  String get discoverScreenTitle => 'Découvrir';

  @override
  String get discoverSearchHint => 'Rechercher...';

  @override
  String get discoverAllShopsRegion => 'Tous les magasins de votre région';

  @override
  String get discoverAllFreelancers => 'Tous les freelances près de vous';

  @override
  String get discoverMarketplaceTitle => 'Marché';

  @override
  String get discoverMarketplaceSubtitle => 'Achetez des produits de beauté à la livraison à la commande';

  @override
  String get discoverBrowseProducts => 'Parcourir les produits';

  @override
  String get discoverMyOrders => 'Mes commandes';

  @override
  String get discoverCartTooltip => 'Panier';

  @override
  String get homeScheduleTabLabel => 'Calendrier';

  @override
  String get homeDashboardTabLabel => 'Tableau de bord';

  @override
  String get homeMapTabLabel => 'Carte';

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
  String get languageScreenSubtitle => 'Choisissez votre langue préférée pour l\'interface de l\'application. Cela n\'affectera pas les paramètres de votre appareil.';

  @override
  String get languageScreeUseDeviceLang => 'Utiliser la langue de l\'appareil.';

  @override
  String get languageScreeUseDeviceLangNote => 'Cela sera réinitialisé pour correspondre à la langue du système de votre appareil.';

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
  String get updatePasswordItemTitle => 'Mettre à jour le mot de passe';

  @override
  String get updatePasswordItemSubtitle => 'Modifiez le mot de passe actuel de votre compte';

  @override
  String get deactivateItemTitle => 'Désactiver';

  @override
  String get deactivateItemSubtitle => 'Masquez et désactivez temporairement votre compte';

  @override
  String get deleteItemTitle => 'Supprimer le compte';

  @override
  String get deleteItemSubtitle => 'Demandez la suppression définitive de votre compte';

  @override
  String get logoutItemTitle => 'Déconnexion';

  @override
  String get logoutItemSubtitle => 'Déconnectez-vous de votre compte';

  @override
  String get logoutConfirmTitle => 'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get logoutConfirmMessage => 'Vous devrez vous reconnecter pour accéder à votre compte et à vos données.';

  @override
  String get logoutConfirmButton => 'Déconnexion';

  @override
  String get logoutSuccessMessage => 'Déconnexion réussie';

  @override
  String logoutFailedMessage(String error) {
    return 'Échec de la déconnexion : $error';
  }

  @override
  String get accountDeactivateTitle => 'Désactiver le compte';

  @override
  String get accountDeleteTitle => 'Supprimer le compte';

  @override
  String get accountRestoreTitle => 'Restaurer le compte';

  @override
  String get accountDeactivateWarningTitle => 'Votre compte sera masqué';

  @override
  String get accountDeactivateWarningBody => 'Votre profil, vos boutiques, produits, profil freelance et liens de réservation seront masqués. Vous pouvez restaurer l’accès en vous reconnectant.';

  @override
  String get accountDeleteWarningTitle => 'La suppression est programmée pendant 30 jours';

  @override
  String get accountDeleteWarningBody => 'Votre présence publique sera masquée maintenant. Vous pouvez restaurer votre compte dans les 30 jours; ensuite les données personnelles du profil seront supprimées.';

  @override
  String get accountPasswordConfirmLabel => 'Confirmer le mot de passe';

  @override
  String get accountPasswordConfirmHint => 'Entrez votre mot de passe';

  @override
  String accountPhraseConfirmLabel(String phrase) {
    return 'Tapez $phrase pour confirmer';
  }

  @override
  String get accountReasonLabel => 'Raison (facultatif)';

  @override
  String get accountReasonHint => 'Dites-nous pourquoi vous partez';

  @override
  String accountPhraseMismatch(String phrase) {
    return 'Tapez $phrase pour continuer';
  }

  @override
  String get accountActionBlocked => 'Résolvez les réservations, commandes ou retraits actifs avant de continuer.';

  @override
  String get accountActionLoadFailed => 'Nous n’avons pas pu charger les exigences du compte. Réessayez.';

  @override
  String get accountActionGenericError => 'Nous n’avons pas pu terminer cette action de compte. Réessayez.';

  @override
  String get accountRecentAuthRequired => 'Veuillez vous reconnecter avant de continuer.';

  @override
  String get accountReasonTooLong => 'La raison doit contenir 1000 caractères ou moins.';

  @override
  String get accountDeactivateButton => 'Désactiver le compte';

  @override
  String get accountDeleteButton => 'Demander la suppression';

  @override
  String get accountDeactivatedSuccess => 'Votre compte a été désactivé.';

  @override
  String get accountDeletionRequestedSuccess => 'La suppression du compte a été programmée.';

  @override
  String get accountRestoreButton => 'Restaurer le compte';

  @override
  String get accountRestoredSuccess => 'Votre compte a été restauré.';

  @override
  String get accountRestoreFailed => 'Nous n’avons pas pu restaurer ce compte.';

  @override
  String get accountRestoreMissingProfile => 'Nous n’avons pas pu charger votre profil.';

  @override
  String get accountDeactivatedTitle => 'Compte désactivé';

  @override
  String get accountDeactivatedBody => 'Votre compte est masqué. Restaurez-le pour continuer à utiliser l’application.';

  @override
  String get accountPendingDeleteTitle => 'Compte en attente de suppression';

  @override
  String accountPendingDeleteBody(String date) {
    return 'Votre compte est programmé pour suppression le $date. Restaurez-le avant cette date pour le conserver.';
  }

  @override
  String get accountDeletedTitle => 'Compte supprimé';

  @override
  String get accountDeletedBody => 'Ce compte a été supprimé et ne peut plus être restauré.';

  @override
  String get accountBlockersTitle => 'Résolvez d\'abord ces éléments';

  @override
  String accountBlockerActiveBookings(int count) {
    return '$count réservation(s) active(s)';
  }

  @override
  String accountBlockerOwnedShopActiveBookings(int count) {
    return '$count réservation(s) active(s) de boutique';
  }

  @override
  String accountBlockerActiveOrders(int count) {
    return '$count commande(s) active(s)';
  }

  @override
  String accountBlockerOwnedShopActiveOrders(int count) {
    return '$count commande(s) active(s) de boutique';
  }

  @override
  String accountBlockerActiveWithdrawals(int count) {
    return '$count retrait(s) en attente';
  }

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

  @override
  String get profileScreenCantChatWithYourself => 'Vous ne pouvez pas discuter avec vous-même';

  @override
  String get profileScreenStartingConversation => 'Démarrage de la conversation...';

  @override
  String get profileScreenNoActiveSession => 'Aucune session active — veuillez vous reconnecter.';

  @override
  String get profileScreenSignInToChatMessage => 'Vous devez vous connecter pour envoyer un message';

  @override
  String get profileScreenFollowFeatureComingSoon => 'La fonction de suivi arrive bientôt';

  @override
  String get profileScreenEnterBioPlaceholder => 'Entrez une biographie pour que les gens vous connaissent';

  @override
  String get profileScreenNoBioYet => 'Pas encore de biographie';

  @override
  String get profileScreenErrorLoadingProfileBody => 'Impossible de charger le profil. Vérifiez votre connexion Internet et réessayez.';

  @override
  String get profileScreenLoadingNotifications => 'Chargement...';

  @override
  String get profileHeaderBookingsStatLabel => 'Réservations';

  @override
  String get profileHeaderOrdersStatLabel => 'Commandes';

  @override
  String get profileHeaderEditProfileButton => 'Modifier le profil';

  @override
  String get profileHeaderMessageButton => 'Message';

  @override
  String get editableProfileAvatarTakePhoto => 'Prendre une photo';

  @override
  String get editableProfileAvatarChooseGallery => 'Choisir dans la galerie';

  @override
  String get editProfileScreenAccountTypeLabel => 'Type de compte';

  @override
  String get editProfileScreenAccountTypeSubtitle => 'Sélectionnez comment vous souhaitez utiliser cette application. Cela détermine les fonctionnalités disponibles pour vous.';

  @override
  String get editProfileScreenUpdatingAccountType => 'Mise à jour du type de compte...';

  @override
  String get editProfileScreenPleaseLogIn => 'Veuillez vous connecter';

  @override
  String get editProfileScreenNameLabel => 'Nom';

  @override
  String get editProfileScreenNameHint => 'Entrez votre nom';

  @override
  String get editProfileScreenUsernameLabel => 'Nom d\'utilisateur';

  @override
  String get editProfileScreenUsernameHint => 'Entrez le nom d\'utilisateur';

  @override
  String get editProfileScreenBioLabel => 'Biographie';

  @override
  String get editProfileScreenBioHint => 'Parlez-nous de vous';

  @override
  String get editProfileScreenEditWorkProfileTitle => 'Modifier le profil de travail';

  @override
  String get profileTabsAppointments => 'Rendez-vous';

  @override
  String get profileTabsBuys => 'Achats';

  @override
  String get profileTabsSaves => 'Enregistrements';

  @override
  String get searchScreenSearchHint => 'Rechercher des boutiques, des professionnels, des produits...';

  @override
  String get searchScreenNoResultsFound => 'Aucun résultat trouvé';

  @override
  String searchScreenNoResultsCategory(String category) {
    return 'Aucun $category trouvé';
  }

  @override
  String searchScreenSearchedFor(String query) {
    return 'Recherché: \"$query\"';
  }

  @override
  String get searchScreenSomethingWentWrong => 'Une erreur s\'est produite';

  @override
  String get searchAppBarSearchHint => 'Rechercher...';

  @override
  String get searchSuggestionsHint => 'Recherchez des boutiques, des professionnels de services à domicile ou des produits capillaires à acheter';

  @override
  String get searchSuggestionsRecentSearches => 'Recherches récentes';

  @override
  String get searchSuggestionsClearAll => 'Effacer tout';

  @override
  String get searchEmptyStateNoResults => 'Aucun résultat trouvé';

  @override
  String searchEmptyStateCouldNotFind(String query) {
    return 'Nous n\'avons rien trouvé pour \"$query\"';
  }

  @override
  String get searchEmptyStateTryThese => 'Essayez ceux-ci:';

  @override
  String get searchResultsShopsHeader => 'Boutiques';

  @override
  String get searchResultsSeeAll => 'Voir tout';

  @override
  String searchResultsTitle(String category) {
    return 'Résultats pour $category';
  }

  @override
  String searchResultsSearchingFor(String query) {
    return 'Recherche de \"$query\"';
  }

  @override
  String get searchResultsTryDifferent => 'Essayez des mots-clés différents ou supprimez les filtres';

  @override
  String get searchResultsSomethingWentWrong => 'Une erreur s\'est produite';

  @override
  String nearYouShopsTitle(int km) {
    return 'Près de vous\nà ${km}km';
  }

  @override
  String nearYouShopsBody(int km) {
    return 'Magasins situés à $km km de votre localisation actuelle, affichés du plus proche au plus éloigné. Définissez simplement votre localisation une fois, et nous vous montrerons ce qui est à proximité—que ce soit à la maison, au travail ou en explorant un nouveau quartier. Pratique pour les réservations de dernière minute ou si vous préférez marcher.';
  }

  @override
  String get nearYouShopsEmptyNoFilter => 'Aucun magasin trouvé à proximité';

  @override
  String nearYouShopsEmptyWithFilter(String luxury) {
    return 'Aucun magasin $luxury trouvé à proximité';
  }

  @override
  String nearYouShopsEmptySubtitle(String location) {
    return 'Les magasins à $location s\'afficheraient ici une fois qu\'ils seront disponibles';
  }

  @override
  String get premiumShopsScreenTitle => 'Magasins Premium';

  @override
  String get premiumShopsEmpty => 'Aucun magasin premium trouvé';

  @override
  String get premiumShopsHorizontalTitle => 'Magasins premium\npour des looks premium';

  @override
  String get premiumShopsHorizontalBody => 'Salons et spas haut de gamme sélectionnés offrant des expériences luxueuses. Ces magasins sont classés comme Luxe ou Ultra-Luxe en fonction de leurs services, tarifs et avis clients. Parfait quand vous recherchez cette touche supplémentaire d\'élégance.';

  @override
  String get premiumShopsHorizontalEmptyNoFilter => 'Aucun magasin premium disponible';

  @override
  String premiumShopsHorizontalEmptyWithFilter(String luxury) {
    return 'Aucun magasin premium $luxury disponible';
  }

  @override
  String get premiumShopsHorizontalEmptySubtitle => 'Les magasins s\'afficheraient ici une fois disponibles';

  @override
  String get topRatedShopsHorizontalTitle => 'Meilleure note';

  @override
  String topRatedShopsHorizontalTitleWithLocation(String location) {
    return 'Meilleure note \nà $location';
  }

  @override
  String get topRatedShopsHorizontalBody => 'Magasins avec les meilleures notes clients (4,5+ étoiles) et de nombreux avis. Ce sont les favoris de notre communauté—constamment félicités pour la qualité, le service et le professionnalisme. Un excellent point de départ si vous recherchez des options fiables et approuvées par la foule.';

  @override
  String get topRatedShopsHorizontalEmptyNoFilter => 'Aucun magasin mieux noté disponible';

  @override
  String topRatedShopsHorizontalEmptyWithFilter(String luxury) {
    return 'Aucun magasin premium $luxury disponible';
  }

  @override
  String get topRatedShopsHorizontalEmptySubtitle => 'Les magasins s\'afficheraient ici une fois disponibles';

  @override
  String get topRatedShopsScreenTitle => 'Magasins Mieux Notés';

  @override
  String get topRatedShopsEmpty => 'Aucun magasin mieux noté trouvé';

  @override
  String get nearYouFreelancersScreenTitle => 'Freelances près de vous';

  @override
  String get nearYouFreelancersEmpty => 'Aucun freelance trouvé à proximité';

  @override
  String get nearYouFreelancersEmptySubtitle => 'Essayez d\'étendre votre zone de recherche ou changez d\'emplacement';

  @override
  String get topRatedFreelancersScreenTitle => 'Freelances mieux notés';

  @override
  String get topRatedFreelancersEmpty => 'Aucun freelance mieux noté trouvé';

  @override
  String get topRatedFreelancersEmptySubtitle => 'Essayez d\'ajuster votre zone de recherche';

  @override
  String topRatedFreelancersHorizontalTitle(String location) {
    return 'Mieux notés \nà $location';
  }

  @override
  String get topRatedFreelancersHorizontalBody => 'Professionnels de haut niveau sélectionnés offrant des expériences luxueuses. Ces freelances sont classés comme mieux notés en fonction de la qualité de leur travail, de leurs tarifs et des avis clients. Parfait pour cette touche supplémentaire d\'excellence.';

  @override
  String nearYouFreelancersHorizontalTitle(String location) {
    return 'Freelances Près de Vous à $location';
  }

  @override
  String get nearYouFreelancersHorizontalBody => 'Professionnels qualifiés situés près de vous. Ces freelances sont disponibles pour des réservations rapides et offrent un service local pratique. Parfait quand vous recherchez la fiabilité et la proximité.';

  @override
  String get nearYouFreelancersHorizontalEmpty => 'Aucun freelance mieux noté disponible';

  @override
  String get nearYouFreelancersHorizontalEmptySubtitle => 'Les freelances s\'afficheraient ici une fois disponibles';

  @override
  String get shopNoLocationSetTitle => 'Définissez votre localisation pour découvrir';

  @override
  String get shopNoLocationSetContent => 'Définissez votre localisation pour découvrir des magasins premium et mieux notés près de vous.';

  @override
  String get providerTypeShops => 'Magasins';

  @override
  String get providerTypeFreelancers => 'Freelances';

  @override
  String get providerTypeBuy => 'Acheter';

  @override
  String get luxuryLevelChipsAll => 'Tous';

  @override
  String get searchRadiusSliderTitle => 'Rayon d\'exploration';

  @override
  String searchRadiusSliderSubtitle(int km) {
    return 'Affichage des résultats dans un rayon de ${km}km de votre localisation';
  }

  @override
  String validationPasswordMaxLength(int max) {
    return 'Le mot de passe ne doit pas dépasser $max caractères';
  }

  @override
  String get validationPasswordRepeatingChars => 'Le mot de passe contient trop de caractères répétés';

  @override
  String get validationPasswordSequential => 'Le mot de passe contient des caractères séquentiels';

  @override
  String validationPhoneDigits(int digits) {
    return 'Le numéro de téléphone doit contenir $digits chiffres';
  }

  @override
  String get validationPhoneUK => 'Numéro de téléphone britannique invalide';

  @override
  String validationUrlScheme(String schemes) {
    return 'L\'URL doit commencer par $schemes';
  }

  @override
  String get validationUrlDomain => 'Nom de domaine invalide';

  @override
  String get validationUrlPublicAddress => 'L\'URL doit pointer vers une adresse publique';

  @override
  String validationNameMaxLength(String field, int max) {
    return '$field ne doit pas dépasser $max caractères';
  }

  @override
  String validationNameConsecutiveChars(String field) {
    return '$field ne peut pas contenir de tirets ou d\'espaces consécutifs';
  }

  @override
  String get validationCreditCardFormat => 'Veuillez entrer un numéro de carte bancaire valide';

  @override
  String get validationCreditCardInvalid => 'Numéro de carte bancaire invalide';

  @override
  String get validationDatePastNotAllowed => 'La date ne peut pas être dans le passé';

  @override
  String get validationPostalCodeZip => 'Veuillez entrer un code postal valide (ex. 12345 ou 12345-6789)';

  @override
  String get validationPostalCodeCanadian => 'Veuillez entrer un code postal canadien valide (ex. A1A 1A1)';

  @override
  String get validationPostalCodeGeneric => 'Veuillez entrer un code postal valide';

  @override
  String get validationSSNFormat => 'Veuillez entrer un SSN valide (ex. 123-45-6789)';

  @override
  String get validationSSNInvalid => 'SSN invalide';

  @override
  String get validationEmailTooLong => 'L\'adresse e-mail est trop longue (max. 254 caractères)';

  @override
  String get validationEmailLocalPartTooLong => 'La partie locale de l\'adresse e-mail est trop longue';

  @override
  String get categoriesAll => 'Tous';

  @override
  String get categoriesSalon => 'Salons';

  @override
  String get categoriesBarbershop => 'Barbiers';

  @override
  String get categoriesSpa => 'Spas';

  @override
  String get categoriesNailSalon => 'Salons d\'Ongles';

  @override
  String get categoriesLashStudio => 'Studios de Cils';

  @override
  String get categoriesWaxing => 'Épilation';

  @override
  String get categoriesMassage => 'Massage';

  @override
  String get categoriesMakeup => 'Maquillage';

  @override
  String get categoriesSkincare => 'Soins de la Peau';

  @override
  String get luxuryLevelModerate => 'Modéré';

  @override
  String get luxuryLevelLuxury => 'Luxe';

  @override
  String get luxuryLevelUltraLuxury => 'Ultra Luxe';

  @override
  String get dashboardTabRevenue => 'Revenus';

  @override
  String get dashboardTabAnalytics => 'Analyse';

  @override
  String get dashboardTabInsights => 'Aperçus';

  @override
  String get dashboardTabTools => 'Outils';

  @override
  String get dashboardTabClients => 'Clients';

  @override
  String get dashboardTabStaff => 'Personnel';

  @override
  String get walletRecentTransactions => 'Transactions Récentes';

  @override
  String get walletLoadError => 'Nous ne pouvons pas charger votre portefeuille pour le moment.';

  @override
  String get walletTransactionLoadError => 'Impossible de charger les transactions récentes.';

  @override
  String get walletPaymentProcessing => 'Veuillez attendre que le paiement soit traité et revenir à votre application pour terminer votre réservation.';

  @override
  String get analyticsRevenue => 'Revenus';

  @override
  String get analyticsServices => 'Services';

  @override
  String get analyticsWorkers => 'Travailleurs';

  @override
  String get analyticsLoadError => 'Impossible de charger l\'analyse';

  @override
  String get analyticsEmpty => 'Aucune donnée disponible pour l\'analyse.';

  @override
  String get analyticsEmptySubtitle => 'Les statistiques de réservation et de revenus apparaîtraient ici';

  @override
  String get insightsReports => 'Rapports';

  @override
  String get insightsSeeAll => 'Voir Tout';

  @override
  String get insightsLoadError => 'Impossible de charger les rapports. Tirez pour actualiser.';

  @override
  String get insightsNoAlerts => 'Tout va bien ! Aucune alerte';

  @override
  String get insightsHeatmapError => 'Impossible de charger la carte thermique des réservations.';

  @override
  String get insightsNoHeatmapData => 'Aucune donnée de carte thermique disponible';

  @override
  String get toolsAdminTools => 'Outils d\'Administration';

  @override
  String get toolsConfigure => 'Configurer →';

  @override
  String get toolsManage => 'Gérer →';

  @override
  String get toolsExport => 'Exporter →';

  @override
  String get toolsAutomatedReminders => 'Rappels Automatisés';

  @override
  String get toolsPromotionsManager => 'Gestionnaire de Promotions';

  @override
  String get toolsExportReports => 'Exporter les Rapports';

  @override
  String get toolsPaymentSettings => 'Paramètres de Paiement';

  @override
  String get toolsLoadingDetails => 'Chargement des détails du magasin…';

  @override
  String get toolsBusinessHours => 'Heures d\'Ouverture';

  @override
  String get toolsServiceManagement => 'Gestion des Services';

  @override
  String get clientsSearchHint => 'Rechercher par nom...';

  @override
  String get clientsLoadError => 'Impossible de charger les clients';

  @override
  String get clientsNotFound => 'Aucun Client Trouvé';

  @override
  String get clientsEmpty => 'Aucun Client pour le Moment';

  @override
  String clientsSearchEmpty(String query) {
    return 'Aucun client ne correspond à \"$query\"';
  }

  @override
  String get clientsEmptySubtitle => 'Les clients apparaîtront ici lorsqu\'ils effectueront leur première réservation.';

  @override
  String get walletLabel => 'Portefeuille';

  @override
  String get walletAvailableBalance => 'Solde Disponible';

  @override
  String get walletWithdrawFunds => 'Retirer des Fonds';

  @override
  String get walletTotalEarned => 'Total Gagné';

  @override
  String get walletTotalWithdrawn => 'Total Retiré';

  @override
  String get transactionDepositReceived => 'Dépôt Reçu';

  @override
  String get transactionServicePayment => 'Paiement de Service';

  @override
  String get transactionWithdrawal => 'Retrait';

  @override
  String get transactionRefund => 'Remboursement';

  @override
  String get transactionPlatformFee => 'Frais de Plateforme';

  @override
  String get transactionAdjustment => 'Ajustement';

  @override
  String get transactionToday => 'Aujourd\'hui';

  @override
  String get transactionYesterday => 'Hier';

  @override
  String get withdrawalTitle => 'Retirer';

  @override
  String withdrawalInfo(double fee, String currency, double minFee) {
    return 'Les retraits sont traités immédiatement et envoyés à votre compte connecté. Des frais de $fee% (min $currency $minFee) s\'appliquent.';
  }

  @override
  String withdrawalAvailableBalance(String currency, String amount) {
    return 'Solde disponible: $currency $amount';
  }

  @override
  String withdrawalAmountInputLabel(String currency) {
    return 'Montant ($currency)';
  }

  @override
  String get withdrawalAmountHint => 'Entrez le montant à retirer';

  @override
  String get withdrawalAmountRequired => 'Veuillez entrer un montant';

  @override
  String get withdrawalAmountInvalid => 'Veuillez entrer un montant valide';

  @override
  String withdrawalMinimum(String currency, double min) {
    return 'Le retrait minimum est $currency $min';
  }

  @override
  String withdrawalMaximum(String currency, double max) {
    return 'Le retrait maximum par transaction est $currency $max';
  }

  @override
  String withdrawalInsufficientBalance(String currency, String available) {
    return 'Solde insuffisant. Disponible: $currency $available';
  }

  @override
  String get withdrawalBreakdownAmount => 'Montant à retirer:';

  @override
  String withdrawalFeeLabel(Object fee) {
    return 'Frais ($fee%):';
  }

  @override
  String get withdrawalNetAmount => 'Vous recevrez:';

  @override
  String get withdrawalProcessing => 'Traitement en cours...';

  @override
  String get withdrawalRequestButton => 'Demander un Retrait';

  @override
  String get withdrawalNoPaymentMethod => 'Aucune méthode de paiement connectée';

  @override
  String get withdrawalSuccess => 'Demande de retrait soumise avec succès!';

  @override
  String get deadLetterTitle => 'Le retrait nécessite un examen';

  @override
  String deadLetterSingle(String currency, String amount) {
    return '$currency $amount bloqué — appuyez pour les détails';
  }

  @override
  String deadLetterMultiple(String currency, String amount, int count) {
    return '$currency $amount bloqué sur $count retraits — appuyez pour les détails';
  }

  @override
  String get deadLetterReason => 'Raison:';

  @override
  String get deadLetterContactSupport => 'Contacter le support';

  @override
  String get paymentSetupTitle => 'Terminer la configuration des paiements';

  @override
  String get paymentSetupContent => 'Connectez votre compte de paiement pour commencer à retirer de l\'argent de votre portefeuille. Il peut s\'agir de votre numéro de téléphone mobile ou de votre compte bancaire.';

  @override
  String get calendarErrorLoading => 'Erreur lors du chargement du calendrier';

  @override
  String get calendarErrorLoadingBookings => 'Erreur lors du chargement des réservations';

  @override
  String get calendarNoAppointmentsDay => 'Aucun rendez-vous pour ce jour';

  @override
  String get calendarNoBookingsDay => 'Aucune réservation pour ce jour';

  @override
  String calendarAppointmentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'rendez-vous',
      one: 'rendez-vous',
    );
    return '$count $_temp0';
  }

  @override
  String get monthJanuary => 'Jan';

  @override
  String get monthFebruary => 'Fév';

  @override
  String get monthMarch => 'Mar';

  @override
  String get monthApril => 'Avr';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJune => 'Jun';

  @override
  String get monthJuly => 'Jul';

  @override
  String get monthAugust => 'Aoû';

  @override
  String get monthSeptember => 'Sep';

  @override
  String get monthOctober => 'Oct';

  @override
  String get monthNovember => 'Nov';

  @override
  String get monthDecember => 'Déc';

  @override
  String get dayMonday => 'Lun';

  @override
  String get dayTuesday => 'Mar';

  @override
  String get dayWednesday => 'Mer';

  @override
  String get dayThursday => 'Jeu';

  @override
  String get dayFriday => 'Ven';

  @override
  String get daySaturday => 'Sam';

  @override
  String get daySunday => 'Dim';

  @override
  String calendarNoAppointmentsSnackbar(String date) {
    return 'Aucun rendez-vous ce jour-là\n$date';
  }

  @override
  String reviewsScreenTitle(String shopName) {
    return 'Avis pour $shopName';
  }

  @override
  String get reviewsLoadError => 'Impossible de charger les avis';

  @override
  String get reviewsNoReviews => 'Pas d\'avis pour le moment';

  @override
  String get reviewsRateProduct => 'Évaluer le produit';

  @override
  String get reviewsYourReview => 'Votre avis';

  @override
  String get reviewsReviewHint => 'Partagez votre expérience avec ce produit...';

  @override
  String get reviewsSubmitButton => 'Envoyer l\'avis';

  @override
  String get reviewsThankYou => 'Merci pour votre avis !';

  @override
  String reviewsSubmitError(String error) {
    return 'Impossible d\'envoyer l\'avis : $error';
  }

  @override
  String get bookingServiceAddress => 'Adresse du service';

  @override
  String get bookingFindingAvailableTimes => 'Recherche des créneaux disponibles...';

  @override
  String bookingErrorLoadingWorkers(String error) {
    return 'Erreur lors du chargement des travailleurs : $error';
  }

  @override
  String bookingErrorValidatingDistance(String error) {
    return 'Erreur lors de la validation de la distance : $error';
  }

  @override
  String get bookingAddSpecialRequirements => 'Ajouter';

  @override
  String get bookingCancelSpecialRequirements => 'Annuler';

  @override
  String get bookingSaveSpecialRequirements => 'Enregistrer';

  @override
  String bookingFailedSaveRequirements(String error) {
    return 'Erreur lors de l\'enregistrement : $error';
  }

  @override
  String get bookingInvitationSent => 'Invitation envoyée avec succès';

  @override
  String get bookingSavingAssignments => 'Enregistrement des affectations...';

  @override
  String get bookingAssignmentsSaved => 'Affectations enregistrées avec succès';

  @override
  String bookingAssignmentsError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get scheduleTitle => 'Calendrier';

  @override
  String get scheduleTabDaily => 'Quotidien';

  @override
  String get scheduleTabMonthly => 'Mensuel';

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
