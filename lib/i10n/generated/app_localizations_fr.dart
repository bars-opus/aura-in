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

  @override
  String get docsGettingStartedTitle => 'Commencer';

  @override
  String get docsGettingStartedSubtitle => 'Apprenez les bases';

  @override
  String get docsGettingStartedWhatIsTitle => 'Qu\'est-ce qu\'Aura In?';

  @override
  String get docsGettingStartedWhatIsSubtitle => 'Comprendre la plateforme';

  @override
  String get docsGettingStartedWelcomeIntroContent => 'Aura In est un marché mobile qui connecte les professionnels des services avec les clients. Que vous offriez des coupes de cheveux, des massages, des services indépendants ou que vous vendiez des produits, cette plateforme aide votre entreprise à se développer.';

  @override
  String get docsGettingStartedWhoUsesTitle => 'Qui utilise Aura In?';

  @override
  String get docsGettingStartedWhoUsesContent => 'Deux types d\'utilisateurs alimentent la plateforme:';

  @override
  String get docsGettingStartedWhoUsesProviders => 'Prestataires de services - Salons, spas, barbiers, indépendants qui offrent des services';

  @override
  String get docsGettingStartedWhoUsesCustomers => 'Clients - Personnes qui recherchent et réservent des services dans leur région';

  @override
  String get docsGettingStartedWhoUsesSellers => 'Vendeurs de produits - Magasins vendant des produits de détail ou des articles faits à la main';

  @override
  String get docsGettingStartedHowItWorksTitle => 'Comment ça fonctionne';

  @override
  String get docsGettingStartedHowItWorksContent => 'Les prestataires de services créent un profil, énumèrent leurs services avec les prix et acceptent les réservations des clients. Les clients recherchent par localisation, parcourent les services et réservent des rendez-vous. Tout est géré via l\'application.';

  @override
  String get docsGettingStartedThreeWaysTitle => 'Trois façons d\'utiliser Aura In';

  @override
  String get docsGettingStartedThreeWaysSubtitle => 'Choisissez votre rôle';

  @override
  String get docsGettingStartedOption1Title => 'Option 1: Parcourir et réserver des services (Client)';

  @override
  String get docsGettingStartedOption1Content => 'Recherchez les salons, massothérapeutes, barbiers ou indépendants près de vous. Consultez leurs services, tarifs et disponibilités. Réservez des rendez-vous directement via l\'application et payez en toute sécurité.';

  @override
  String get docsGettingStartedGuestBookingTitle => 'Réservation d\'invité (aucun téléchargement d\'application requis)';

  @override
  String get docsGettingStartedGuestBookingContent => 'Vous ne voulez pas télécharger l\'application? Les prestataires de services peuvent partager un lien de réservation - vous pouvez réserver et payer directement via ce lien sans créer de compte. Vos détails de réservation et votre reçu seront envoyés à WhatsApp.';

  @override
  String get docsGettingStartedOption2Title => 'Option 2: Offrir des services (Propriétaire de magasin ou Indépendant)';

  @override
  String get docsGettingStartedOption2Content => 'Créez un profil de magasin ou d\'indépendant, énumérez vos services avec les tarifs et la durée, définissez vos heures de travail et gérez les réservations. Gagnez de l\'argent avec chaque service réservé.';

  @override
  String get docsGettingStartedOption3Title => 'Option 3: Vendre des produits (Vendeur de produits)';

  @override
  String get docsGettingStartedOption3Content => 'Si vous fabriquez des articles faits à la main ou vendez des produits de détail, vous pouvez les mettre en vente. Les clients parcourent et achètent directement dans votre magasin.';

  @override
  String get docsGettingStartedBookingPaymentTitle => 'Système de réservation et de paiement';

  @override
  String get docsGettingStartedBookingPaymentSubtitle => 'Comment fonctionnent les réservations de services et les paiements';

  @override
  String get docsGettingStartedBookingOverviewContent => 'Les clients réservent des rendez-vous avec les prestataires de services. Les paiements sont traités de manière sécurisée via l\'application en utilisant Paystack (Afrique) ou Stripe (Global).';

  @override
  String get docsGettingStartedDepositPaymentTitle => 'Dépôt (30%)';

  @override
  String get docsGettingStartedDepositPaymentContent => 'Lors de la réservation d\'un service, les clients versent 30% à l\'avance comme dépôt pour sécuriser le créneau horaire. Cela confirme que la réservation est réelle et réservée.';

  @override
  String get docsGettingStartedPlatformFeeTitle => 'Frais de plateforme';

  @override
  String get docsGettingStartedPlatformFeeContent => 'Des frais de plateforme minimes (2%) sont ajoutés pour nous aider à maintenir la plateforme et à fournir un support. Ces frais sont calculés sur le montant total de la réservation.';

  @override
  String get docsGettingStartedRemainingPaymentTitle => 'Paiement restant (70%)';

  @override
  String get docsGettingStartedRemainingPaymentContent => 'Les 70% restants peuvent être payés de deux façons: (1) en espèces lorsque le service est terminé, ou (2) en ligne via l\'application avant le rendez-vous.';

  @override
  String get docsGettingStartedGuestBookingPaymentTitle => 'Paiement de réservation d\'invité';

  @override
  String get docsGettingStartedGuestBookingPaymentContent => 'Aucun téléchargement d\'application requis! Les clients reçoivent un lien de réservation du prestataire de services. Ils versent 30% pour sécuriser le créneau, et leur reçu est envoyé à WhatsApp.';

  @override
  String get docsGettingStartedProductOrderingTitle => 'Commande et livraison de produits';

  @override
  String get docsGettingStartedProductOrderingSubtitle => 'Comment fonctionne la vente de produits';

  @override
  String get docsGettingStartedProductOverviewContent => 'Les clients parcourent les produits, ajoutent des articles au panier et effectuent le paiement. Les produits sont livrés à l\'emplacement du client.';

  @override
  String get docsGettingStartedCODPaymentTitle => 'Paiement à la livraison (COD)';

  @override
  String get docsGettingStartedCODPaymentContent => 'Pour les commandes de produits, le paiement est géré à la livraison. Les clients paient le vendeur à la réception des articles - aucun paiement initial requis.';

  @override
  String get docsGettingStartedShareYourProfileTitle => 'Partager votre profil';

  @override
  String get docsGettingStartedShareYourProfileSubtitle => 'Facilitez la recherche de vos clients';

  @override
  String get docsGettingStartedShareLinkContent => 'En tant que prestataire de services, vous obtenez un lien de réservation unique. Partagez-le sur WhatsApp, les réseaux sociaux ou par email. Les clients peuvent réserver des services sans télécharger l\'application.';

  @override
  String get docsGettingStartedCustomURLTitle => 'URL personnalisée (optionnel)';

  @override
  String get docsGettingStartedCustomURLContent => 'Vous pouvez personnaliser votre slug de lien de réservation (par exemple, aura.in/glamour-salon au lieu de aura.in/abc123). Cela facilite le partage et la mémorisation.';

  @override
  String get docsGettingStartedGetHelpTitle => 'Obtenir de l\'aide';

  @override
  String get docsGettingStartedGetHelpSubtitle => 'Où trouver des réponses';

  @override
  String get docsGettingStartedHelpDocumentationContent => 'Cette application a une documentation complète pour chaque fonction. Lorsque vous avez besoin d\'aide, consultez le guide pertinent - il y en a un pour votre rôle et la fonction que vous utilisez.';

  @override
  String get docsGettingStartedFAQ1Question => 'Qu\'est-ce qu\'Aura In?';

  @override
  String get docsGettingStartedFAQ1Answer => 'Aura In est un marché mobile pour les entreprises basées sur les services. Les clients trouvent et réservent des services (coupes de cheveux, massages, etc.), les prestataires de services gèrent les réservations et les revenus, et les vendeurs de produits listent les articles à vendre.';

  @override
  String get docsGettingStartedFAQ2Question => 'Dois-je payer pour utiliser l\'application?';

  @override
  String get docsGettingStartedFAQ2Answer => 'L\'application est gratuite à télécharger et à utiliser. Les prestataires de services ne paient qu\'une petite commission lorsque les clients paient pour les services. Les processeurs de paiement (Paystack/Stripe) facturent des frais.';

  @override
  String get docsGettingStartedFAQ3Question => 'Quelle est la différence entre propriétaire de magasin et indépendant?';

  @override
  String get docsGettingStartedFAQ3Answer => 'Les propriétaires de magasins ont un emplacement fixe avec une équipe de travailleurs. Les indépendants travaillent de manière autonome et peuvent se déplacer chez les clients. Choisissez en fonction de votre modèle commercial.';

  @override
  String get docsGettingStartedFAQ4Question => 'Comment suis-je payé?';

  @override
  String get docsGettingStartedFAQ4Answer => 'Lorsque les clients paient pour les services, l\'argent va à votre portefeuille. Vous pouvez retirer de l\'argent sur votre compte bancaire en utilisant Paystack (Afrique) ou Stripe (Global).';

  @override
  String get docsGettingStartedFAQ5Question => 'Mes informations de paiement sont-elles sécurisées?';

  @override
  String get docsGettingStartedFAQ5Answer => 'Oui. Aura In utilise Paystack et Stripe, des processeurs de paiement leaders avec une sécurité au niveau bancaire. Nous ne voyons jamais vos détails de paiement.';

  @override
  String get docsGettingStartedFAQ6Question => 'Comment savoir si les prestataires de services près de moi sont dignes de confiance?';

  @override
  String get docsGettingStartedFAQ6Answer => 'Chaque prestataire de services a des cotes et des avis de clients qui ont réservé avec lui. Lisez les avis avant de réserver. Les cotes élevées signifient un service cohérent et de qualité.';

  @override
  String get docsGettingStartedFAQ7Question => 'Puis-je réserver sans télécharger l\'application?';

  @override
  String get docsGettingStartedFAQ7Answer => 'Oui! Les prestataires de services partagent un lien de réservation unique. Vous pouvez réserver directement via ce lien sans télécharger l\'application. Votre reçu sera envoyé à WhatsApp.';

  @override
  String get docsGettingStartedFAQ8Question => 'Combien dois-je payer à l\'avance pour les réservations?';

  @override
  String get docsGettingStartedFAQ8Answer => 'Vous versez 30% du total du service à l\'avance pour sécuriser le créneau de réservation (plus une commission de plateforme de 2%). Les 70% restants peuvent être payés en espèces ou en ligne avant/au moment du service.';

  @override
  String get docsGettingStartedFAQ9Question => 'Comment payer pour les produits?';

  @override
  String get docsGettingStartedFAQ9Answer => 'Les produits utilisent le paiement à la livraison (COD). Vous payez le vendeur à la réception des articles. Cela vous permet de vérifier la qualité avant de payer et fonctionne bien pour les livraisons locales.';

  @override
  String get docsGettingStartedFAQ10Question => 'Pourquoi les frais de plateforme de 2%?';

  @override
  String get docsGettingStartedFAQ10Answer => 'Les frais de plateforme nous aident à maintenir Aura In, à traiter les paiements, à fournir un support client et à améliorer continuellement les fonctionnalités pour les clients et les prestataires de services.';

  @override
  String get docsBookingStartedTitle => 'Premiers pas avec les réservations';

  @override
  String get docsBookingStartedSubtitle => 'Un guide simple pour comprendre le fonctionnement des réservations';

  @override
  String get docsBookingIntroTitle => 'Bienvenue dans le système de réservation';

  @override
  String get docsBookingIntroSubtitle => 'Tout ce que vous devez savoir sur la réservation de services, que vous soyez un client ou un propriétaire de magasin.';

  @override
  String get docsBookingWhatIsTitle => 'Qu\'est-ce que le système de réservation?';

  @override
  String get docsBookingWhatIsContent => 'Le système de réservation est votre portail d\'accès à la programmation de services dans vos magasins préférés. Que vous ayez besoin d\'une coupe de cheveux, d\'une taille de barbe, de nattes ou d\'un autre service, le système facilite la réservation de rendez-vous à votre convenance.';

  @override
  String get docsBookingWhoIsForTitle => 'Pour qui est ce guide?';

  @override
  String get docsBookingWhoIsForContent => 'Ce guide est conçu pour deux types d\'utilisateurs:';

  @override
  String get docsBookingWhoIsForClients => 'Clients: Personnes qui souhaitent réserver des services dans des magasins';

  @override
  String get docsBookingWhoIsForGuests => 'Réservations d\'invités: Personnes qui souhaitent réserver via un lien sans créer de compte';

  @override
  String get docsBookingWhoIsForOwners => 'Propriétaires de magasins: Personnes qui gèrent des magasins, des services et des travailleurs';

  @override
  String get docsBookingGuestIntroTitle => 'Nouveau: Réserver sans télécharger l\'application';

  @override
  String get docsBookingGuestIntroContent => 'Pas de compte? Pas de problème! Si un propriétaire de magasin partage un lien de réservation avec vous, vous pouvez réserver directement sans télécharger l\'application. Votre reçu est envoyé à WhatsApp.';

  @override
  String get docsBookingWelcomeTip => 'Aucune connaissance technique requise! Ce guide utilise un langage simple et des exemples réels pour vous aider à comprendre tout.';

  @override
  String get docsBookingAccountTitle => 'Créer votre compte (ou réserver en tant qu\'invité)';

  @override
  String get docsBookingAccountSubtitle => 'Commencez en quelques minutes - avec ou sans compte';

  @override
  String get docsBookingTwoWaysTitle => 'Deux façons de réserver';

  @override
  String get docsBookingTwoWaysContent => 'Vous pouvez réserver de deux façons:';

  @override
  String get docsBookingTwoWaysAccount => 'Avec compte: Télécharger l\'application, créer un compte, réserver à tout moment';

  @override
  String get docsBookingTwoWaysGuest => 'En tant qu\'invité: Utiliser le lien de réservation, aucune application nécessaire, reçu via WhatsApp';

  @override
  String get docsBookingAccountStepsTitle => 'Comment créer un compte';

  @override
  String get docsBookingAccountStepsContent => 'Suivez ces étapes simples pour créer votre compte:';

  @override
  String get docsBookingAccountTypesTitle => 'Types de comptes';

  @override
  String get docsBookingAccountTypesContent => 'Il existe deux types de comptes:';

  @override
  String get docsBookingAccountTypesClient => 'Compte client: Pour réserver des services dans des magasins';

  @override
  String get docsBookingAccountTypesShop => 'Compte propriétaire de magasin: Pour gérer votre propre magasin (nécessite une approbation)';

  @override
  String get docsBookingGuestOptionTitle => 'Réserver en tant qu\'invité (sans compte)';

  @override
  String get docsBookingGuestOptionContent => 'Si quelqu\'un partage un lien de réservation avec vous, vous pouvez réserver directement sans créer de compte. Cliquez simplement sur le lien et suivez les étapes. Votre reçu est envoyé à votre WhatsApp.';

  @override
  String get docsBookingVerificationNote => 'Vous pouvez parcourir et réserver sans compte en utilisant un lien de réservation. La création d\'un compte vous donne accès à l\'historique des réservations, aux paiements enregistrés et aux récompenses de fidélité.';

  @override
  String get docsBookingFirstBookingTitle => 'Votre première réservation';

  @override
  String get docsBookingFirstBookingSubtitle => 'Un rapide aperçu';

  @override
  String get docsBookingPaymentTitle => 'Comment fonctionne le paiement';

  @override
  String get docsBookingPaymentContent => 'Lorsque vous réservez un service, voici comment le paiement fonctionne:';

  @override
  String get docsBookingPaymentDeposit => 'Dépôt de 30% requis: Pour sécuriser votre réservation, vous payez 30% du coût total du service à l\'avance';

  @override
  String get docsBookingPaymentNonRefundable => 'Non remboursable: Ce dépôt n\'est pas remboursable si vous annulez ou ne vous présentez pas';

  @override
  String get docsBookingPaymentRemaining => 'Solde restant: Les 70% restants sont payés après la fin de votre service';

  @override
  String get docsBookingPaymentSecure => 'Paiement sécurisé: Tous les paiements sont traités de manière sécurisée par nos partenaires de paiement';

  @override
  String get docsBookingDepositNote => 'Le dépôt de 30% vous protège, vous et le magasin. Il garantit que votre créneau est réservé exclusivement pour vous et indemnise le travailleur si vous annulez à la dernière minute.';

  @override
  String get docsBookingBookingTip => 'Conseil d\'expert: Réservez au moins 24 heures à l\'avance pour obtenir la meilleure sélection de créneaux horaires, en particulier pour les services populaires.';

  @override
  String get docsBookingAfterTitle => 'Après votre réservation';

  @override
  String get docsBookingAfterSubtitle => 'Ce qui se passe ensuite';

  @override
  String get docsBookingWhatsNextTitle => 'Votre réservation est confirmée!';

  @override
  String get docsBookingWhatsNextContent => 'Voici ce que vous pouvez faire après réservation:';

  @override
  String get docsBookingRemindersTitle => 'Rappels de réservation';

  @override
  String get docsBookingRemindersContent => 'Vous recevrez des rappels à:';

  @override
  String get docsBookingAfterServiceTitle => 'Après votre service';

  @override
  String get docsBookingAfterServiceContent => 'Une fois votre service terminé:';

  @override
  String get docsPaymentTitle => 'Paiement et frais expliqués';

  @override
  String get docsPaymentSubtitle => 'Comment fonctionnent les dépôts de 30%, les frais de plateforme et les réservations d\'invités';

  @override
  String get docsPaymentOverviewTitle => 'Comment fonctionne le paiement';

  @override
  String get docsPaymentOverviewSubtitle => 'Simple, transparent, sécurisé';

  @override
  String get docsPaymentSummaryTitle => 'Paiement en un coup d\'œil';

  @override
  String get docsPaymentSummaryContent => 'Notre système de paiement est conçu pour être équitable pour les clients et les propriétaires de magasins. Voici la ventilation simple:';

  @override
  String get docsPaymentDeposit30 => 'Dépôt de 30%: Payé à la réservation pour sécuriser votre rendez-vous';

  @override
  String get docsPaymentPlatformFee => 'Frais de plateforme: Petits frais fixes (p. ex., GHS 2) facturés par l\'application';

  @override
  String get docsPaymentRemaining70 => '70% restants: Payés après la fin de votre service';

  @override
  String get docsPaymentTwoWays => 'Deux façons de payer le reste: En espèces ou via l\'application';

  @override
  String get docsPaymentQuickExampleTitle => 'Exemple rapide';

  @override
  String get docsPaymentQuickExampleContent => 'Coût du service: GHS 100\nÀ la réservation: Payer GHS 30 (dépôt) + GHS 2 (frais) = GHS 32\nAprès le service: Payer GHS 70 (espèces ou application)\nTotal au magasin: GHS 100\nFrais de plateforme: GHS 2';

  @override
  String get docsPaymentImportantNote => 'Les frais de plateforme sont facturés par l\'application, pas par le magasin. Cela nous aide à maintenir la plateforme et à vous offrir une excellente expérience de réservation.';

  @override
  String get docsPaymentGuestBookingTitle => 'Réservation d\'invité (sans télécharger l\'application)';

  @override
  String get docsPaymentGuestBookingContent => 'Vous n\'avez pas l\'application? Pas de problème! Vous pouvez toujours réserver via le lien de réservation de votre fournisseur sans créer de compte. Vous payez le même dépôt de 30% + frais de plateforme, et votre reçu est envoyé via WhatsApp.';

  @override
  String get docsDepositTitle => 'Le dépôt de 30%';

  @override
  String get docsDepositSubtitle => 'Pourquoi c\'est nécessaire et comment ça fonctionne';

  @override
  String get docsDepositWhyTitle => 'Pourquoi exigeons-nous un dépôt?';

  @override
  String get docsDepositWhyContent => 'Le dépôt de 30% vous protège, vous et le magasin:';

  @override
  String get docsDepositProtectsYou => 'Pour vous: Votre créneau est garanti – personne d\'autre ne peut le réserver';

  @override
  String get docsDepositProtectsShop => 'Pour le magasin: Les travailleurs sont compensés si vous annulez à la dernière minute';

  @override
  String get docsDepositProtectsEveryone => 'Pour tout le monde: Réduit les absences, maintient les prix justes';

  @override
  String get docsDepositCalcTitle => 'Comment le dépôt est calculé';

  @override
  String get docsDepositCalcContent => 'Le dépôt représente toujours 30% du coût total du service. Ceci comprend:';

  @override
  String get docsDepositCalcSingle => 'Service unique: 30% de ce prix de service';

  @override
  String get docsDepositCalcMultiple => 'Plusieurs services: 30% de tous les services combinés';

  @override
  String get docsDepositCalcGroup => 'Réservations de groupe: 30% du total pour toutes les personnes';

  @override
  String get docsDepositExamplesTitle => 'Exemples de dépôt';

  @override
  String get docsDepositExamplesSingle => 'Service unique:\nCoupe de cheveux (GHS 45) → Dépôt GHS 13,50';

  @override
  String get docsDepositExamplesMultiple => 'Plusieurs services:\nCoupe de cheveux (GHS 45) + Taille de barbe (GHS 25) = GHS 70 total\nDépôt: GHS 21';

  @override
  String get docsDepositExamplesGroup => 'Réservation de groupe (3 personnes):\n3 × Coupe de cheveux (GHS 45 ch) = GHS 135 total\nDépôt: GHS 40,50';

  @override
  String get docsDepositRefundTitle => 'Politique de remboursement du dépôt';

  @override
  String get docsDepositRefundContent => 'Le dépôt de 30% n\'est pas remboursable. Cela signifie:';

  @override
  String get docsDepositRefundCancel => 'Si vous annulez: Le dépôt n\'est pas remboursé';

  @override
  String get docsDepositRefundNoShow => 'Si vous ne vous présentez pas: Le dépôt n\'est pas remboursé';

  @override
  String get docsDepositRefundReschedule => 'Si vous reprogrammez: Le dépôt est transféré au nouveau créneau';

  @override
  String get docsDepositRefundShop => 'Si le magasin annule: Dépôt complet remboursé';

  @override
  String get docsDepositWarning => 'Assurez-vous d\'être certain de votre réservation avant de payer le dépôt. Bien que vous puissiez reprogrammer, le dépôt ne peut pas être remboursé si vous annulez.';

  @override
  String get docsFeeTitle => 'Frais de plateforme';

  @override
  String get docsFeeSubtitle => 'Les petits frais qui maintiennent l\'application en marche';

  @override
  String get docsFeeWhatTitle => 'Quels sont les frais de plateforme?';

  @override
  String get docsFeeWhatContent => 'Les frais de plateforme sont un petit montant fixe (p. ex., GHS 2) qui va à l\'application, pas au magasin. Il couvre:';

  @override
  String get docsFeeAppDev => 'Développement et maintenance des applications';

  @override
  String get docsFeeSupport => 'Support client et résolution des différends';

  @override
  String get docsFeeProcessing => 'Frais de traitement des paiements';

  @override
  String get docsFeeFeatures => 'Nouvelles fonctionnalités et améliorations';

  @override
  String get docsFeeHowTitle => 'Comment les frais sont facturés';

  @override
  String get docsFeeHowContent => 'Points importants à savoir sur les frais de plateforme:';

  @override
  String get docsFeeFixed => 'Montant fixe (pas un pourcentage) – p. ex., GHS 2 par réservation';

  @override
  String get docsFeePerbooking => 'Facturé une fois par réservation – pas par service ou par personne';

  @override
  String get docsFeeNonRefundable => 'Non remboursable – même si vous annulez';

  @override
  String get docsFeeShown => 'Clairement indiqué avant de confirmer le paiement';

  @override
  String get docsFeeExamplesTitle => 'Exemples de frais de plateforme';

  @override
  String get docsFeeExamplesSingle => 'Une personne, un service: Frais GHS 2';

  @override
  String get docsFeeExamplesMultiple => 'Une personne, plusieurs services: Frais GHS 2 (toujours une réservation!)';

  @override
  String get docsFeeExamplesGroup => 'Famille de 4 réservant ensemble: Frais GHS 2 (groupe entier)';

  @override
  String get docsFeeExamplesSeparate => 'Comparer avec les réservations séparées:\n4 réservations séparées = 4 × GHS 2 = GHS 8 en frais\n1 réservation de groupe = Frais GHS 2 – vous économisez GHS 6!';

  @override
  String get docsFeeGroupTip => 'La réservation en groupe vous fait économiser des frais! Au lieu de payer les frais de plateforme pour chaque personne, vous ne payez qu\'un seul frais pour toute la réservation de groupe.';

  @override
  String get docsPaymentRemainingTitle => 'Paiement des 70% restants';

  @override
  String get docsPaymentRemainingSubtitle => 'Espèces ou en ligne - à vous de choisir';

  @override
  String get docsPaymentRemainingOptionsTitle => 'Deux options de paiement';

  @override
  String get docsPaymentRemainingOptionsContent => 'Après la fin de votre service, vous avez deux façons de payer les 70% restants:';

  @override
  String get docsPaymentCashOption => 'Espèces: Payez directement au magasin ou au travailleur';

  @override
  String get docsPaymentAppOption => 'Via l\'application: Payez via l\'application avec votre méthode de paiement enregistrée';

  @override
  String get docsPaymentRemainingTip => 'Les deux méthodes de paiement sont equally valides. Choisissez ce qui est le plus pratique pour vous au moment du service.';

  @override
  String get docsCancellationTitle => 'Annulations et remboursements';

  @override
  String get docsCancellationSubtitle => 'Ce qui se passe si vous devez annuler';

  @override
  String get docsCancellationInfoTitle => 'Politique d\'annulation';

  @override
  String get docsCancellationInfoContent => 'Comprendre ce qui se passe quand vous annulez:';

  @override
  String get docsCancellationUpTo24 => 'Annuler jusqu\'à 24 heures avant: Le dépôt et les frais ne sont pas remboursables';

  @override
  String get docsCancellationLessThan24 => 'Annuler moins de 24 heures avant: Même politique – dépôt et frais non remboursables';

  @override
  String get docsCancellationReschedule => 'Reprogrammer à la place: Votre dépôt est transféré au nouveau créneau (gratuit pour reprogrammer)';

  @override
  String get docsCancellationNoShow => 'Ne pas vous présenter: Dépôt et frais perdus, et peut affecter le statut de votre compte';

  @override
  String get docsHowToBookTitle => 'Comment réserver des services';

  @override
  String get docsHowToBookSubtitle => 'Un guide étape par étape pour réserver vos rendez-vous';

  @override
  String get docsHowToBookOverviewTitle => 'Réservation en un coup d\'œil';

  @override
  String get docsHowToBookOverviewSubtitle => 'Le processus de réservation en étapes simples';

  @override
  String get docsHowToBookTwoWaysTitle => 'Deux façons de réserver';

  @override
  String get docsHowToBookTwoWaysContent => 'Vous pouvez réserver de deux façons:';

  @override
  String get docsHowToBookTwoWaysWithApp => 'Avec compte app: Télécharger l\'application, créer un compte, réserver à tout moment';

  @override
  String get docsHowToBookTwoWaysGuest => 'En tant qu\'invité: Utiliser le lien de réservation, aucune app, reçu via WhatsApp';

  @override
  String get docsHowToBookStepsTitle => 'Votre parcours de réservation (Avec compte)';

  @override
  String get docsHowToBookStepsContent => 'Réserver un service ne prend que quelques minutes. Voici ce que vous ferez:';

  @override
  String get docsHowToBookStep1 => 'Étape 1: Trouvez un magasin et explorez les services';

  @override
  String get docsHowToBookStep2 => 'Étape 2: Sélectionnez vos services et quantités';

  @override
  String get docsHowToBookStep3 => 'Étape 3: Choisissez votre travailleur préféré (s\'il est disponible)';

  @override
  String get docsHowToBookStep4 => 'Étape 4: Choisissez une date et une heure';

  @override
  String get docsHowToBookStep5 => 'Étape 5: Payez un dépôt de 30% + petits frais pour confirmer';

  @override
  String get docsHowToBookStep6 => 'Étape 6: Après le service, payez les 70% restants en espèces ou via l\'application';

  @override
  String get docsHowToBookGuestTitle => 'Réservation d\'invité (pas d\'app)';

  @override
  String get docsHowToBookGuestContent => 'Vous n\'avez pas l\'application? Si un magasin partage un lien de réservation avec vous, suivez les étapes ci-dessus mais sans créer de compte. Votre confirmation et reçu vont à votre WhatsApp.';

  @override
  String get docsHowToBookTimeTip => 'L\'ensemble du processus prend généralement moins de 2 minutes. Votre progression est enregistrée au fur et à mesure, vous pouvez donc prendre votre temps.';

  @override
  String get docsBookingStep1Title => 'Étape 1: Trouvez votre magasin et services';

  @override
  String get docsBookingStep1Subtitle => 'Découvrez l\'endroit parfait pour vos besoins';

  @override
  String get docsBookingFindShopTitle => 'Comment trouver un magasin';

  @override
  String get docsBookingFindShopContent => 'Vous pouvez trouver des magasins de plusieurs façons:';

  @override
  String get docsBookingFindShopHome => 'Écran d\'accueil: Parcourez les magasins recommandés près de vous';

  @override
  String get docsBookingFindShopSearch => 'Recherche: Recherchez des magasins ou services spécifiques par nom';

  @override
  String get docsBookingFindShopCategories => 'Catégories: Filtrer par type de service (Coupe, Tresses, Barbe, etc.)';

  @override
  String get docsBookingFindShopFavorites => 'Favoris: Accès rapide aux magasins que vous avez enregistrés';

  @override
  String get docsBookingBrowseServicesTitle => 'Parcourir les services';

  @override
  String get docsBookingBrowseServicesContent => 'Une fois que vous sélectionnez un magasin, vous verrez tous ses services disponibles. Chaque service montre:';

  @override
  String get docsBookingServiceName => 'Nom du service (p. ex., Coupe Afro, Tresses Box)';

  @override
  String get docsBookingServiceDuration => 'Durée (combien de temps cela prend)';

  @override
  String get docsBookingServicePrice => 'Prix (coût du service - va au magasin)';

  @override
  String get docsBookingServiceDescription => 'Description (ce qui est inclus)';

  @override
  String get docsBookingServiceWorker => 'Exigence du travailleur (si vous pouvez choisir qui le fait)';

  @override
  String get docsBookingServiceExampleTitle => 'Exemple';

  @override
  String get docsBookingServiceExampleContent => 'Service de coupe de cheveux:\n• Nom: Coupe Afro\n• Durée: 1 heure\n• Prix: GHS 45 (payé au magasin)\n• Description: Coupe afro professionnelle avec coiffure\n• Travailleur: Vous pouvez choisir votre coiffeur préféré';

  @override
  String get docsBookingStep2Title => 'Étape 2: Sélectionnez vos services';

  @override
  String get docsBookingStep2Subtitle => 'Choisissez ce que vous voulez et combien de personnes';

  @override
  String get docsBookingSelectServicesTitle => 'Sélection des services';

  @override
  String get docsBookingSelectServicesContent => 'Pour sélectionner un service, appuyez simplement dessus. Vous le verrez mis en surbrillance. Vous pouvez sélectionner plusieurs services à la fois:';

  @override
  String get docsBookingSelectServicesTap => 'Appuyez sur un service pour le sélectionner';

  @override
  String get docsBookingSelectServicesCheckmark => 'Les services sélectionnés affichent une coche';

  @override
  String get docsBookingSelectServicesMultiple => 'Vous pouvez sélectionner plusieurs services (p. ex., Coupe + Taille de barbe)';

  @override
  String get docsBookingSelectServicesDeselect => 'Appuyez à nouveau pour désélectionner';

  @override
  String get docsBookingGroupBookingTitle => 'Réservation pour plusieurs personnes';

  @override
  String get docsBookingGroupBookingContent => 'Si vous réservez pour un groupe (comme vous et vos enfants), vous pouvez augmenter la quantité:';

  @override
  String get docsBookingGroupBookingQuantity => 'Après avoir sélectionné un service, vous verrez un bouton + et -';

  @override
  String get docsBookingGroupBookingIncrease => 'Appuyez sur + pour augmenter le nombre de personnes';

  @override
  String get docsBookingGroupBookingPrice => 'Le prix se met à jour automatiquement';

  @override
  String get docsBookingGroupBookingLimit => 'La quantité maximale est affichée (certains services ont des limites)';

  @override
  String get docsBookingGroupExampleTitle => 'Exemple: Réservation familiale';

  @override
  String get docsBookingGroupExampleContent => 'Dad veut des coupes de cheveux pour lui et ses deux fils:\n• Sélectionnez le service \"Coupe de cheveux\"\n• Appuyez sur + jusqu\'à ce que la quantité affiche 3\n• Le prix total affiche 3 × GHS 45 = GHS 135 (pour le magasin)\n• Vous choisirez des travailleurs pour chaque personne plus tard';

  @override
  String get docsBookingQuantityTip => 'La fonction de quantité est parfaite pour les familles, les groupes d\'amis ou pour quiconque réserve pour plusieurs personnes à la fois.';

  @override
  String get docsGroupBookingsTitle => 'Réservations de groupe';

  @override
  String get docsGroupBookingsSubtitle => 'Comment réserver des services pour vous et d\'autres';

  @override
  String get docsGroupIntroTitle => 'Quelles sont les réservations de groupe?';

  @override
  String get docsGroupIntroSubtitle => 'Réservation pour famille, amis ou groupes simplifiée';

  @override
  String get docsGroupExplainedTitle => 'Réservation pour plusieurs personnes';

  @override
  String get docsGroupExplainedContent => 'Les réservations de groupe vous permettent de réserver des services pour plus d\'une personne à la fois. C\'est parfait pour:';

  @override
  String get docsGroupExplainedFamilies => 'Familles: Parents réservant des coupes de cheveux pour eux-mêmes et leurs enfants';

  @override
  String get docsGroupExplainedFriends => 'Amis: Groupe d\'amis obtenant des services ensemble';

  @override
  String get docsGroupExplainedEvents => 'Événements: Fêtes nuptiales, anniversaires ou occasions spéciales';

  @override
  String get docsGroupExplainedColleagues => 'Collègues: Renforcement d\'équipe ou sorties de travail';

  @override
  String get docsGroupRealExampleTitle => 'Exemple du monde réel';

  @override
  String get docsGroupRealExampleContent => 'La famille Mensah a besoin de coupes de cheveux:\n• Père: Veut une coupe fade\n• Mère: Veut une taille\n• Fils (10): Veut une coupe enfant\n• Fille (8): Veut des tresses\n\nAu lieu de faire 4 réservations séparées, ils peuvent tout réserver ensemble en une seule fois!';

  @override
  String get docsGroupBenefitsTitle => 'Avantages de la réservation de groupe';

  @override
  String get docsGroupBenefitsContent => 'La réservation en groupe vous offre:';

  @override
  String get docsGroupBenefitsTransaction => 'Une transaction: Payer les dépôts pour tout le monde à la fois';

  @override
  String get docsGroupBenefitsTiming => 'Horaire coordonné: Tout le monde est servi à peu près à la même heure';

  @override
  String get docsGroupBenefitsWorkers => 'Différents travailleurs: Chaque personne peut choisir son travailleur préféré';

  @override
  String get docsGroupBenefitsManagement => 'Gestion simplifiée: Afficher et gérer toutes les réservations ensemble';

  @override
  String get docsGroupBenefitsPlanning => 'Meilleure planification: Le magasin peut se préparer pour votre groupe';

  @override
  String get docsGroupTip => 'Les réservations de groupe sont parfaites pour les familles! Vous pouvez réserver pour vous et vos enfants d\'un seul coup, en choisissant différents travailleurs pour chaque personne. Pas de compte? Utilisez un lien de réservation partagé par le magasin!';

  @override
  String get docsGroupHowTitle => 'Comment faire une réservation de groupe';

  @override
  String get docsGroupHowSubtitle => 'Guide étape par étape';

  @override
  String get docsGroupStep1Title => 'Étape 1: Sélectionnez votre service';

  @override
  String get docsGroupStep1Content => 'Commencez par trouver un magasin et sélectionnez le service que vous souhaitez. Par exemple, appuyez sur \"Coupe de cheveux\".';

  @override
  String get docsGroupStep2Title => 'Étape 2: Choisissez la quantité';

  @override
  String get docsGroupStep2Content => 'Après avoir sélectionné un service, vous verrez les boutons + et -. Utilisez-les pour définir combien de personnes ont besoin de ce service:';

  @override
  String get docsGroupStep2Plus => 'Appuyez sur + pour augmenter le nombre';

  @override
  String get docsGroupStep2Minus => 'Appuyez sur - pour diminuer';

  @override
  String get docsGroupStep2Price => 'Le prix se met à jour automatiquement';

  @override
  String get docsGroupStep2Max => 'Vous ne pouvez pas dépasser la quantité maximale affichée';

  @override
  String get docsGroupStep2ExampleTitle => 'Exemple';

  @override
  String get docsGroupStep2ExampleContent => 'Pour une famille de 3 ayant besoin de coupes de cheveux:\n• Sélectionnez le service \"Coupe de cheveux\"\n• Appuyez deux fois sur + (ou jusqu\'à ce que la quantité affiche 3)\n• Le prix total affiche: 3 × GHS 45 = GHS 135';

  @override
  String get docsGroupStep3Title => 'Étape 3: Répétez pour chaque service';

  @override
  String get docsGroupStep3Content => 'Si votre groupe a besoin de services différents (p. ex., certains veulent des coupes, d\'autres veulent des tresses), sélectionnez chaque service et définissez la quantité pour chacun:';

  @override
  String get docsGroupStep3Haircut => 'Sélectionnez \"Coupe de cheveux\" → définissez la quantité 2';

  @override
  String get docsGroupStep3Braids => 'Sélectionnez \"Tresses\" → définissez la quantité 1';

  @override
  String get docsGroupStep3Track => 'Le système suit toutes les sélections';

  @override
  String get docsGroupStep3ExampleTitle => 'Exemple: Services mixtes';

  @override
  String get docsGroupStep3ExampleContent => 'Famille de 4 avec besoins différents:\n• Papa: Coupe de cheveux (quantité 1)\n• Maman: Taille (quantité 1)\n• Fils: Coupe enfant (quantité 1)\n• Fille: Tresses (quantité 1)\n\nTotal: 4 services, mais vous les avez tous réservés en une seule fois!';

  @override
  String get docsGroupStep4Title => 'Étape 4: Choisissez les travailleurs pour chaque personne';

  @override
  String get docsGroupStep4Content => 'Pour les services qui vous permettent de choisir les travailleurs, vous verrez une liste de personnes. Appuyez sur chaque personne pour attribuer son travailleur:';

  @override
  String get docsGroupStep4Person1 => 'Personne 1: Choisir John (spécialiste du fade)';

  @override
  String get docsGroupStep4Person2 => 'Personne 2: Choisir Sarah (experte en tresses)';

  @override
  String get docsGroupStep4Person3 => 'Personne 3: Choisir Michael (coupes enfants)';

  @override
  String get docsGroupStep4Person4 => 'Personne 4: Choisir John (même travailleur pour plusieurs personnes)';

  @override
  String get docsGroupStep4ExampleTitle => 'Exemple: Différents travailleurs pour différentes personnes';

  @override
  String get docsGroupStep4ExampleContent => 'Famille de 3 réservant des coupes de cheveux:\n• Personne 1 (Papa): Choisir John (spécialiste du fade)\n• Personne 2 (Fils): Choisir Michael (excellent avec les enfants)\n• Personne 3 (Fille): Choisir Sarah (experte en tresses)\n\nLes trois seront servis pendant votre bloc de rendez-vous.';

  @override
  String get docsGroupStep5Title => 'Étape 5: Choisissez votre heure';

  @override
  String get docsGroupStep5Content => 'Lorsque vous sélectionnez une date et une heure, le système affichera les créneaux qui peuvent accueillir TOUTES les personnes de votre groupe:';

  @override
  String get docsGroupStep5Regular => 'Vue normale: Affiche les créneaux pour chaque service séparément';

  @override
  String get docsGroupStep5Combined => 'Vue combinée: Affiche uniquement les créneaux où tout le monde peut être servi ensemble';

  @override
  String get docsGroupStep5Duration => 'Durée: L\'heure affichée inclut tous les services pour toutes les personnes';

  @override
  String get docsGroupStep5ExampleTitle => 'Exemple: Calcul de temps';

  @override
  String get docsGroupStep5ExampleContent => 'Réservation familiale:\n• Coupe de cheveux (45 min) × 2 personnes = 90 min\n• Tresses (2 heures) × 1 personne = 120 min\n• Temps tampon entre services = 15 min\n• Temps de rendez-vous total: 3 heures 45 minutes\n\n Le système gère tout cela automatiquement!';

  @override
  String get docsGroupStep6Title => 'Étape 6: Paiement';

  @override
  String get docsGroupStep6Content => 'Pour les réservations de groupe, vous payez:';

  @override
  String get docsGroupStep6Deposit => 'Dépôt de 30%: Calculé sur le TOTAL de tous les services';

  @override
  String get docsGroupStep6Fee => 'Frais de plateforme: Petits frais fixes (p. ex., GHS 2) - facturés UNE SEULE FOIS pour tout le groupe';

  @override
  String get docsGroupStep6Remaining => '70% restants: Payés après la fin de tous les services';

  @override
  String get docsGroupStep6Options => 'Options de paiement: Espèces, carte, argent mobile ou paiement par application';

  @override
  String get docsGroupStep6ExampleTitle => 'Exemple de paiement';

  @override
  String get docsGroupStep6ExampleContent => 'Total de réservation familiale: GHS 400\n• Dépôt à la réservation: GHS 120 (30% de GHS 400)\n• Frais de plateforme: GHS 2 (facturés UNE SEULE FOIS pour tout le groupe)\n• Total à payer maintenant: GHS 122\n• Restant après le service: GHS 280\n• Paiement après: Espèces au travailleur/magasin OU via l\'application (votre choix)';

  @override
  String get docsGroupPaymentFlexibility => 'Plusieurs options de paiement';

  @override
  String get docsGroupPaymentFlexibilityContent => 'Pour les 70% restants, vous avez des options:';

  @override
  String get docsGroupPaymentFlexibilityAllCash => 'Tout en espèces: Tout le monde paie en espèces quand le service est terminé';

  @override
  String get docsGroupPaymentFlexibilitySplit => 'Paiements divisés: Certains paient en espèces, d\'autres paient par application';

  @override
  String get docsGroupPaymentFlexibilityMixed => 'Mélange d\'espèces et d\'application: Payez en partie en espèces, en partie par application';

  @override
  String get docsGroupPaymentFlexibilityIndividual => 'Paiements individuels par application: Chaque personne paie par application';

  @override
  String get docsGroupPaymentFlexibilityTip => 'Choisissez ce qui fonctionne le mieux pour votre groupe!';

  @override
  String get docsGroupImportant => 'Le dépôt et les frais de plateforme sont calculés sur la réservation de groupe TOTAL, pas par personne. Vous payez une seule fois pour tout le groupe.';

  @override
  String get docsCreateShopTitle => 'Créez Votre Boutique';

  @override
  String get docsCreateShopSubtitle => 'Configurez votre entreprise';

  @override
  String get docsShopOverviewTitle => 'Premiers pas avec votre magasin';

  @override
  String get docsShopOverviewSubtitle => 'Apprenez les bases de la création de votre profil professionnel';

  @override
  String get docsWelcomeIntroTitle => 'Bienvenue dans votre tableau de bord magasin';

  @override
  String get docsWelcomeIntroContent => 'La création d\'un magasin sur Aura In ne prend que quelques minutes. Vous ajouterez vos informations commerciales, définirez vos services et heures de travail, et serez prêt à accepter les réservations des clients.';

  @override
  String get docsSetupStepsTitle => 'Ce que vous allez configurer';

  @override
  String get docsSetupStepsContent => 'Voici ce que vous ferez lors de la création de votre magasin:';

  @override
  String get docsSetupStepsShopName => 'Ajoutez le nom et le logo de votre magasin';

  @override
  String get docsSetupStepsDescription => 'Écrivez une brève description de votre entreprise';

  @override
  String get docsSetupStepsType => 'Choisissez votre type de magasin (salon, barbier, spa, etc.)';

  @override
  String get docsSetupStepsLocation => 'Définissez votre emplacement et votre adresse de service';

  @override
  String get docsSetupStepsHours => 'Ajoutez vos heures de travail';

  @override
  String get docsSetupStepsServices => 'Créez les services que vous proposez avec les prix';

  @override
  String get docsSetupStepsContact => 'Ajoutez les informations de contact';

  @override
  String get docsSetupStepsPhotos => 'Téléchargez des photos et des documents';

  @override
  String get docsSetupTip => 'Votre travail est enregistré automatiquement au fur et à mesure que vous remplissez le formulaire. Vous pouvez revenir à tout moment pour continuer l\'édition ou publier quand vous êtes prêt.';

  @override
  String get docsBasicInfoTitle => 'Informations de base du magasin';

  @override
  String get docsBasicInfoSubtitle => 'Dites aux clients qui vous êtes';

  @override
  String get docsLogoTitle => 'Ajoutez le logo de votre magasin';

  @override
  String get docsLogoContent => 'Votre logo est la première chose que voient les clients. Il devrait clairement représenter votre entreprise. Utilisez une image carrée (par exemple, 500x500 pixels) pour de meilleurs résultats.';

  @override
  String get docsShopNameTitle => 'Nom du magasin';

  @override
  String get docsShopNameContent => 'Entrez le nom de votre entreprise exactement comme vous voulez que les clients le voient. Soyez clair et professionnel. Exemple: \"Salon de coiffure de Marie\" ou \"Barberie en ville\"';

  @override
  String get docsShopTypeTitle => 'Choisissez votre type de magasin';

  @override
  String get docsShopTypeContent => 'Sélectionnez le type d\'entreprise que vous exploitez. Cela aide les clients à vous trouver dans la recherche. Les types disponibles incluent:';

  @override
  String get docsShopTypeSalon => 'Salon de coiffure - pour coupes de cheveux, coloration, coiffage';

  @override
  String get docsShopTypeBarber => 'Barberie - pour coupes de cheveux et soins des hommes';

  @override
  String get docsShopTypeSpa => 'Spa - pour massages, soins du visage, services de bien-être';

  @override
  String get docsShopTypeBeauty => 'Services de beauté - maquillage, ongles et autres traitements de beauté';

  @override
  String get docsShopTypeOther => 'Autres services - pour les entreprises non énumérées ci-dessus';

  @override
  String get docsDescriptionTitle => 'Description du magasin';

  @override
  String get docsDescriptionContent => 'Écrivez une brève description de votre magasin (100-200 mots). Dites aux clients ce qui vous rend spécial. Exemple: \"Nous nous spécialisons dans les soins naturels des cheveux et la coiffure moderne pour tous les types de cheveux. Environnement familial avec des coiffeurs professionnels.\"';

  @override
  String get docsTermsTitle => 'Conditions générales';

  @override
  String get docsTermsContent => 'Ajoutez les règles importantes que les clients doivent connaître. Exemples: politique d\'annulation, restrictions d\'âge, exigences de dépôt, code vestimentaire ou restrictions de santé.';

  @override
  String get docsLocationTitle => 'Emplacement et heures';

  @override
  String get docsLocationSubtitle => 'Où les clients peuvent vous trouver et quand vous travaillez';

  @override
  String get docsLocationIntroTitle => 'Définissez votre emplacement';

  @override
  String get docsLocationIntroContent => 'Les clients doivent savoir où vous trouver. Vous pouvez:';

  @override
  String get docsLocationPin => 'Épinglez votre emplacement sur la carte (glissez le marqueur)';

  @override
  String get docsLocationSearch => 'Recherchez votre adresse dans la zone de recherche';

  @override
  String get docsLocationManual => 'Entrez votre adresse de rue manuellement';

  @override
  String get docsLocationAccuracy => 'Assurez-vous que votre emplacement est exact. Les clients l\'utilisent pour vous trouver et calculer le temps de trajet.';

  @override
  String get docsWorkingHoursTitle => 'Définissez vos heures de travail';

  @override
  String get docsWorkingHoursContent => 'Les clients ne peuvent réserver que lorsque vous êtes ouvert. Définissez vos heures pour chaque jour de la semaine.';

  @override
  String get docsHoursExampleTitle => 'Horaire d\'exemple';

  @override
  String get docsHoursExampleContent => 'Lundi - Vendredi: 9h00 à 18h00\nSamedi: 10h00 à 16h00\nDimanche: Fermé';

  @override
  String get docsHoursTip => 'Vous pouvez définir différentes heures pour différents jours, ou marquer n\'importe quel jour comme fermé quand vous ne travaillez pas.';

  @override
  String get docsServicesTitle => 'Services et tarification';

  @override
  String get docsServicesSubtitle => 'Dites aux clients ce que vous proposez et combien ça coûte';

  @override
  String get docsServicesIntroTitle => 'Ajoutez vos services';

  @override
  String get docsServicesIntroContent => 'Chaque service est quelque chose que les clients peuvent réserver et payer. Exemples: \"Coupe de cheveux\", \"Coloration capillaire\", \"Massage\", \"Soin du visage\".';

  @override
  String get docsServiceDetailsTitle => 'Pour chaque service, ajoutez:';

  @override
  String get docsServiceDetailsContent => 'Lorsque vous créez un service, vous devez fournir:';

  @override
  String get docsServiceName => 'Nom du service - ce que vous proposez (par exemple, \"Coupe de cheveux\")';

  @override
  String get docsServiceDescription => 'Description - brefs détails sur ce qui est inclus';

  @override
  String get docsServicePrice => 'Prix - le coût du service';

  @override
  String get docsServiceDuration => 'Durée - combien de temps cela prend (par exemple, 30 minutes, 1 heure)';

  @override
  String get docsServiceCategory => 'Catégorie - le type de service';

  @override
  String get docsPricingTipTitle => 'Conseil de tarification';

  @override
  String get docsPricingTipContent => 'Soyez clair avec vos prix. Vous pouvez offrir différents niveaux de service (par exemple, \"Coupe basique\" vs \"Coupe premium\") à différents prix.';

  @override
  String get docsDurationImportant => 'Définissez la durée avec précision. Les clients réservent en fonction de cette durée, et le personnel doit savoir combien de temps réserver.';

  @override
  String get docsTeamTitle => 'Gérez votre équipe';

  @override
  String get docsTeamSubtitle => 'Ajoutez les membres du personnel et assignez-les aux services';

  @override
  String get docsWorkersIntroTitle => 'Ajoutez votre personnel';

  @override
  String get docsWorkersIntroContent => 'Si vous avez des coéquipiers travaillant dans votre magasin, vous pouvez les ajouter ici. Cela vous aide à gérer qui est disponible pour les réservations.';

  @override
  String get docsAddWorkerTitle => 'Comment ajouter un membre du personnel';

  @override
  String get docsAddWorkerContent => 'Lorsque vous ajoutez un travailleur, vous avez besoin:';

  @override
  String get docsFreelancerTitle => 'Devenir Freelancer';

  @override
  String get docsFreelancerSubtitle => 'Travailler indépendamment';

  @override
  String get docsFreelancerOverviewTitle => 'Premiers pas en tant que pigiste';

  @override
  String get docsFreelancerOverviewSubtitle => 'Apprenez comment configurer votre profil et commencer à accepter des clients';

  @override
  String get docsFreelancerWelcomeTitle => 'Bienvenue dans le travail indépendant';

  @override
  String get docsFreelancerWelcomeContent => 'En tant que pigiste sur Aura In, vous offrez des services directement aux clients de votre région. Contrairement à un magasin traditionnel, vous travaillez de votre propre emplacement et pouvez vous déplacer pour rencontrer les clients. Configurez votre profil en quelques minutes et commencez à accepter des réservations.';

  @override
  String get docsFreelancerVsShopTitle => 'Pigiste vs Magasin: Quelle est la différence?';

  @override
  String get docsFreelancerVsShopContent => 'Voici comment fonctionne le travail indépendant:';

  @override
  String get docsFreelancerIndependent => 'Vous travaillez de façon indépendante - aucun magasin fixe requis';

  @override
  String get docsFreelancerTravel => 'Vous pouvez vous déplacer vers les clients dans votre rayon choisi';

  @override
  String get docsFreelancerHours => 'Vous définissez vos propres heures et disponibilité';

  @override
  String get docsFreelancerManage => 'Vous gérez votre propre horaire et vos clients';

  @override
  String get docsFreelancerBooking => 'Les clients vous réservent directement pour les services';

  @override
  String get docsFreelancerRequirementsTitle => 'Ce dont vous aurez besoin';

  @override
  String get docsFreelancerRequirementsContent => 'Pour commencer en tant que pigiste, vous avez besoin de: votre nom, un type de profession (coiffeur, thérapeute de massage, etc.), emplacement, rayon de voyage, services et vos heures de travail. Une photo professionnelle aide les clients à vous faire confiance.';

  @override
  String get docsProfileSetupTitle => 'Créez votre profil';

  @override
  String get docsProfileSetupSubtitle => 'Dites aux clients qui vous êtes';

  @override
  String get docsProfilePhotoTitle => 'Ajoutez votre photo de profil';

  @override
  String get docsProfilePhotoContent => 'Un portrait professionnel crée la confiance chez les clients. Utilisez une photo claire et bien éclairée de vous. Les clients veulent savoir avec qui ils réservent.';

  @override
  String get docsYourNameTitle => 'Votre nom';

  @override
  String get docsYourNameContent => 'Entrez votre nom complet exactement comme vous voulez que les clients le voient. Soyez professionnel et clair.';

  @override
  String get docsProfessionTypeTitle => 'Choisissez votre profession';

  @override
  String get docsProfessionTypeContent => 'Sélectionnez ce que vous faites. Exemples: Coiffeur, Thérapeute de massage, Maquilleur, Barbier, Esthéticienne ou autres services spécialisés.';

  @override
  String get docsBioDescriptionTitle => 'Écrivez votre bio';

  @override
  String get docsBioDescriptionContent => 'Écrivez une brève description sur vous et votre expérience (50-150 mots). Dites aux clients ce qui vous rend spécial. Exemple: \"Je me spécialise dans les soins naturels des cheveux avec 5 ans d\'expérience. Certifié en coloration et coiffage.\"';

  @override
  String get docsTermsGuidelinesTitle => 'Ajoutez vos directives';

  @override
  String get docsTermsGuidelinesContent => 'Partagez les règles ou politiques importantes. Exemples: restrictions d\'âge, politique d\'annulation, exigences de santé ou instructions de préparation.';

  @override
  String get docsServiceAreaTitle => 'Définissez votre zone de service';

  @override
  String get docsServiceAreaSubtitle => 'Définissez où vous travaillez';

  @override
  String get docsBaseLocationTitle => 'Définissez votre emplacement de base';

  @override
  String get docsBaseLocationContent => 'C\'est où vous travaillez normalement. Les clients dans votre rayon de voyage peuvent vous réserver. Vous pouvez soit épingler sur la carte, soit rechercher votre adresse.';

  @override
  String get docsTravelRadiusTitle => 'Rayon de voyage';

  @override
  String get docsTravelRadiusContent => 'Jusqu\'où êtes-vous prêt à voyager pour rencontrer les clients? Définissez cela en kilomètres. Exemple: \"rayon de 5 km\" signifie que les clients jusqu\'à 5 km de votre emplacement peuvent vous réserver.';

  @override
  String get docsMobileVsFixedTitle => 'Mobile ou emplacement fixe?';

  @override
  String get docsMobileVsFixedContent => 'Choisissez si vous vous déplacez vers les clients ou les rencontrez à un endroit. Si vous êtes mobile, les clients peuvent vous demander à leur domicile ou au bureau.';

  @override
  String get docsServiceAddressTip => 'Les clients verront votre rayon de voyage lors de la recherche. Soyez précis pour qu\'ils sachent si vous pouvez servir leur région.';

  @override
  String get docsToolsSetupTitle => 'Énumérez vos outils et équipements';

  @override
  String get docsToolsSetupSubtitle => 'Montrez aux clients ce que vous apportez';

  @override
  String get docsToolsIntroTitle => 'Que sont les outils?';

  @override
  String get docsToolsIntroContent => 'Les outils sont l\'équipement ou les compétences que vous possédez. Ils aident les clients à comprendre ce que vous pouvez faire et à quoi s\'attendre.';

  @override
  String get docsToolExamplesTitle => 'Outils d\'exemple';

  @override
  String get docsToolExamplesContent => 'Pour différentes professions:';

  @override
  String get docsToolHairdresser => 'Coiffeur: Sèche-cheveux, lisseur, fer à friser, ciseaux';

  @override
  String get docsToolMassage => 'Thérapeute de massage: Table de massage, pierres chaudes, huiles d\'aromathérapie';

  @override
  String get docsToolMakeup => 'Maquilleur: Pinceaux à maquillage, aérographe, lumière LED';

  @override
  String get docsToolBarber => 'Barbier: Tondeuses électriques, rasoir droit, crème coiffante';

  @override
  String get docsToolSelectionTitle => 'Sélection d\'outils';

  @override
  String get docsToolSelectionContent => 'Choisissez tous les outils et équipements que vous utilisez professionnellement. Les clients veulent savoir que vous disposez du bon équipement pour leur service.';

  @override
  String get docsServicesSetupTitle => 'Services et tarification';

  @override
  String get docsServicesSetupSubtitle => 'Dites aux clients ce que vous proposez';

  @override
  String get docsServiceBasicsTitle => 'Ajoutez vos services';

  @override
  String get docsServiceBasicsContent => 'Chaque service est quelque chose que les clients peuvent réserver. Exemples: \"Coupe de cheveux\", \"Massage complet du corps\", \"Application de maquillage\".';

  @override
  String get docsServiceInfoTitle => 'Pour chaque service, ajoutez:';

  @override
  String get docsServiceInfoContent => 'Tu as besoin:';

  @override
  String get docsServiceInfoName => 'Nom du service - ce que vous proposez';

  @override
  String get docsServiceInfoDescription => 'Description - ce qui est inclus';

  @override
  String get docsServiceInfoPrice => 'Prix - combien ça coûte';

  @override
  String get docsServiceInfoDuration => 'Durée - combien de temps cela prend (30 min, 1 heure, etc.)';

  @override
  String get docsPricingStrategyTitle => 'Conseils de tarification';

  @override
  String get docsPricingStrategyContent => 'Recherchez ce que les autres facturent pour des services similaires dans votre région. Tarifiez de façon compétitive mais équitable pour votre niveau d\'expérience.';

  @override
  String get docsDurationImportanceFreelancer => 'Définissez la durée avec précision. C\'est ainsi que vous bloquez le temps pour chaque réservation. Les clients dépendent de ce temps.';

  @override
  String get docsHoursSetupTitle => 'Définissez votre disponibilité';

  @override
  String get docsHoursSetupSubtitle => 'Quand êtes-vous disponible pour travailler';

  @override
  String get docsHoursIntroTitle => 'Heures de travail';

  @override
  String get docsHoursIntroContent => 'Les clients ne peuvent réserver que pendant les heures que vous marquez comme disponibles. Définissez vos heures pour chaque jour de la semaine.';

  @override
  String get docsFlexibleHoursTitle => 'Flexible ou strict?';

  @override
  String get docsFlexibleHoursContent => 'Vous décidez. Si vous voulez des heures régulières, définissez-les. Si vous préférez la flexibilité, vous pouvez ajuster quotidiennement selon vos besoins.';

  @override
  String get docsBlockTimeTip => 'Quand un client vous réserve, ce temps est bloqué dans votre calendrier. Définissez les heures judicieusement pour éviter les conflits.';

  @override
  String get docsContactCredentialsTitle => 'Informations de contact et références d\'identification';

  @override
  String get docsContactCredentialsSubtitle => 'Aidez les clients à vous joindre et à générer de la confiance';

  @override
  String get docsCreateProductTitle => 'Vendre des produits en ligne';

  @override
  String get docsCreateProductSubtitle => 'Listez des articles à vendre et atteignez les clients de votre région';

  @override
  String get docsProductOverviewTitle => 'Premiers pas dans la vente de produits';

  @override
  String get docsProductOverviewSubtitle => 'Apprenez comment lister et vendre des articles';

  @override
  String get docsProductWelcomeTitle => 'Bienvenue à la vente de produits';

  @override
  String get docsProductWelcomeContent => 'Vendez des produits physiques directement aux clients de votre région. Des articles faits à la main aux biens de détail, vous pouvez atteindre les clients qui recherchent ce que vous offrez.';

  @override
  String get docsPhoneRequirementTitle => 'Vous avez besoin d\'un numéro de téléphone vérifié';

  @override
  String get docsPhoneRequirementContent => 'Avant de pouvoir commencer à vendre des produits, vous devez vérifier votre numéro de téléphone. Ceci est pour la communication avec les clients et pour valider votre identité.';

  @override
  String get docsAddPhoneNumberTitle => 'Comment ajouter votre numéro de téléphone';

  @override
  String get docsAddPhoneNumberContent => 'Allez à les paramètres de votre profil et ajoutez votre numéro de téléphone. Vous recevrez un code de vérification par SMS pour confirmer que c\'est vraiment votre numéro. Cela prend juste une minute.';

  @override
  String get docsWhyPhoneVerifiedTitle => 'Pourquoi la vérification du téléphone?';

  @override
  String get docsWhyPhoneVerifiedContent => 'Un numéro de téléphone vérifié crée la confiance des clients et nous permet de vous contacter s\'il y a des problèmes. Cela aide également à prévenir la fraude.';

  @override
  String get docsPhoneImportant => 'Vous ne pouvez pas lister des produits jusqu\'à ce que vous ayez un numéro de téléphone vérifié. Ceci est obligatoire pour tous les vendeurs.';

  @override
  String get docsProductBasicsTitle => 'Informations de base du produit';

  @override
  String get docsProductBasicsSubtitle => 'Ce que vous devez dire aux clients à propos de votre produit';

  @override
  String get docsProductNameTitle => 'Nom du produit';

  @override
  String get docsProductNameContent => 'Entrez le nom de votre produit clairement. Les clients recherchent par nom de produit, alors soyez précis. Exemple: \"Portefeuille en cuir fait à la main - Marron\" au lieu de simplement \"Portefeuille\".';

  @override
  String get docsProductDescriptionTitle => 'Description du produit';

  @override
  String get docsProductDescriptionContent => 'Écrivez une description détaillée. Dites aux clients ce que c\'est, de quoi c\'est fait, comment l\'utiliser et pourquoi c\'est bon. Soyez honnête sur l\'état (nouveau, utilisé, remis à neuf).';

  @override
  String get docsCategorySelectionTitle => 'Choisissez une catégorie';

  @override
  String get docsCategorySelectionContent => 'Sélectionnez la bonne catégorie. Les clients parcourent par catégorie pour trouver des articles, donc la précision est importante. Choisissez la catégorie la plus spécifique disponible.';

  @override
  String get docsProductConditionTitle => 'État du produit';

  @override
  String get docsProductConditionContent => 'Soyez clair sur l\'état: Neuf (jamais utilisé), Comme neuf (utilisé une fois), Bon (légère usure), Passable (usure visible) ou Tel quel. L\'honnêteté crée la confiance.';

  @override
  String get docsPricingStockTitle => 'Prix et disponibilité';

  @override
  String get docsPricingStockSubtitle => 'Définissez votre prix et gérez les stocks';

  @override
  String get docsPricingTitle => 'Définissez votre prix';

  @override
  String get docsPricingContent => 'Définissez un prix équitable en fonction de l\'état, de la valeur marchande et de la demande locale. Les clients peuvent voir des articles similaires, donc les prix compétitifs aident.';

  @override
  String get docsCurrencyTitle => 'Devise';

  @override
  String get docsCurrencyContent => 'Les prix sont affichés dans la devise de votre magasin. Assurez-vous que la devise de votre magasin est correctement définie avant d\'ajouter des produits.';

  @override
  String get docsStockQuantityTitle => 'Quantité en stock';

  @override
  String get docsStockQuantityContent => 'Entrez le nombre d\'articles que vous avez. Quand le stock s\'épuise, le produit s\'affiche comme indisponible. Mettez à jour ceci au fur et à mesure que vous vendez des articles.';

  @override
  String get docsStockTip => 'Gardez le stock exact. Les clients s\'énervent s\'ils commandent quelque chose qui est en rupture de stock. Mettez à jour régulièrement au fur et à mesure que vous vendez.';

  @override
  String get docsProductPhotosTitle => 'Photos de produit';

  @override
  String get docsProductPhotosSubtitle => 'Montrez aux clients ce qu\'ils achètent';

  @override
  String get docsPhotosImportanceTitle => 'Les photos comptent le plus';

  @override
  String get docsPhotosImportanceContent => 'De bonnes photos sont essentielles. Les clients décident d\'acheter en fonction des photos. Mauvaises photos = moins de ventes.';

  @override
  String get docsWhatPhotosTitle => 'Quoi photographier';

  @override
  String get docsWhatPhotosContent => 'Prenez des photos qui montrent le produit réel:';

  @override
  String get docsPhotoFull => 'Produit complet sous plusieurs angles';

  @override
  String get docsPhotoCloseups => 'Gros plans des détails et de la qualité';

  @override
  String get docsPhotoCondition => 'Photos montrant l\'état (s\'il est utilisé)';

  @override
  String get docsPhotoScale => 'Photos à côté de quelque chose pour l\'échelle (comme une pièce ou une main)';

  @override
  String get docsPhotoDamage => 'Photos de dommages ou usure (l\'honnêteté crée la confiance)';

  @override
  String get docsPhotoTipsTitle => 'Conseils de qualité photo';

  @override
  String get docsPhotoTipsContent => 'Utilisez la lumière naturelle. Prenez des photos sur fond propre. Montrez les couleurs avec précision. N\'utilisez pas de filtres qui changent l\'apparence du produit.';

  @override
  String get docsPhotoCountTitle => 'Combien de photos?';

  @override
  String get docsPhotoCountContent => 'Téléchargez au moins 3 photos claires. Plus de photos aident les clients à mieux comprendre le produit. Limitez à 10 photos par produit.';

  @override
  String get docsToolsTitle => 'Outils commerciaux';

  @override
  String get docsToolsSubtitle => 'Fonctionnalités puissantes pour automatiser, promouvoir et gérer votre entreprise';

  @override
  String get docsToolsOverviewTitle => 'Aperçu des outils';

  @override
  String get docsToolsOverviewSubtitle => 'Ce que chaque outil fait et comment l\'utiliser';

  @override
  String get docsToolsWelcomeTitle => 'Bienvenue aux outils commerciaux';

  @override
  String get docsToolsWelcomeContent => 'L\'onglet Outils dispose de 8 fonctionnalités puissantes pour vous aider à automatiser, promouvoir et gérer votre entreprise de manière plus efficace. Chaque outil résout un problème commercial spécifique.';

  @override
  String get docsToolsListTitle => 'Outils disponibles';

  @override
  String get docsToolsListContent => 'Vous avez accès à ces 8 outils:';

  @override
  String get docsToolsReminders => 'Rappels automatisés - Envoyer des rappels aux clients';

  @override
  String get docsToolsPromotions => 'Gestionnaire de promotions - Créer et gérer les remises';

  @override
  String get docsToolsExport => 'Rapports d\'exportation - Téléchargez vos données commerciales';

  @override
  String get docsToolsPayment => 'Paramètres de paiement - Configurez comment vous recevez les paiements';

  @override
  String get docsToolsHours => 'Heures commerciales - Définissez votre horaire de travail';

  @override
  String get docsToolsServices => 'Gestion des services - Ajouter et modifier vos services';

  @override
  String get docsToolsLoyalty => 'Programme de fidélité - Récompensez les clients réguliers';

  @override
  String get docsToolsBroadcasts => 'Diffusions - Envoyez des messages à vos clients';

  @override
  String get docsRemindersTitle => '1. Rappels automatisés';

  @override
  String get docsRemindersSubtitle => 'Envoyer des rappels automatiques aux clients';

  @override
  String get docsReminderPurposeTitle => 'Ce qu\'il fait';

  @override
  String get docsReminderPurposeContent => 'Envoyer automatiquement des messages de rappel aux clients avant leurs réservations. Réduit les absences et maintient les clients informés.';

  @override
  String get docsReminderBenefitsTitle => 'Avantages';

  @override
  String get docsReminderBenefitsContent => 'Les rappels automatisés vous aident à:';

  @override
  String get docsReminderBenefitNoShow => 'Réduire les absences - les clients oublient moins probablement';

  @override
  String get docsReminderBenefitExperience => 'Améliorer l\'expérience client - ils savent quand arriver';

  @override
  String get docsReminderBenefitTime => 'Économiser du temps - pas besoin d\'appeler ou d\'envoyer des messages manuellement';

  @override
  String get docsReminderBenefitReliability => 'Augmenter la fiabilité - les rappels sortent automatiquement';

  @override
  String get docsReminderSetupTitle => 'Comment le configurer';

  @override
  String get docsReminderSetupContent => 'Cliquez sur \"Configurer les rappels automatisés\" pour définir l\'heure: envoyer des rappels 24 heures avant, 2 heures avant ou le matin de la nomination.';

  @override
  String get docsReminderImpact => 'Les magasins utilisant des rappels automatisés voient 20-30% moins d\'absences. Cela affecte directement vos revenus.';

  @override
  String get docsPromosTitle => '2. Gestionnaire de promotions';

  @override
  String get docsPromosSubtitle => 'Créer des offres spéciales et des remises';

  @override
  String get docsPromosPurposeTitle => 'Ce qu\'il fait';

  @override
  String get docsPromosPurposeContent => 'Créez des promotions et des remises à temps limité. Offrir un pourcentage de réduction, un montant fixe de réduction ou des modules complémentaires gratuits pour attirer plus de clients.';

  @override
  String get docsPromosExamplesTitle => 'Idées de promotion';

  @override
  String get docsPromosExamplesContent => 'Vous pouvez créer des promotions comme:';

  @override
  String get docsPromosExample1 => '20% de réduction sur les coupes de cheveux le lundi';

  @override
  String get docsPromosExample2 => 'Huile de massage gratuite avec toute réservation de massage';

  @override
  String get docsPromosExample3 => '50 de réduction sur un forfait de service complet';

  @override
  String get docsPromosExample4 => 'Client pour la première fois: 30% de réduction';

  @override
  String get docsPromosExample5 => 'Bonus de fidélité: 5e service à moitié prix';

  @override
  String get docsPromosStrategyTitle => 'Stratégie de promotion';

  @override
  String get docsPromosStrategyContent => 'Utilisez les promotions pendant les périodes creuses pour augmenter les réservations. Suivez quelles promotions fonctionnent le mieux grâce à votre analyse.';

  @override
  String get docsExportTitle => '3. Rapports d\'exportation';

  @override
  String get docsExportSubtitle => 'Téléchargez vos données pour analyse';

  @override
  String get docsExportPurposeTitle => 'Ce qu\'il fait';

  @override
  String get docsExportPurposeContent => 'Téléchargez des rapports détaillés de vos données commerciales au format feuille de calcul. Analysez les réservations, les revenus, les clients, et plus.';

  @override
  String get docsExportTypesTitle => 'Rapports disponibles';

  @override
  String get docsExportTypesContent => 'Vous pouvez exporter:';

  @override
  String get docsExportBookings => 'Rapports de réservation - toutes les réservations avec détails';

  @override
  String get docsExportRevenue => 'Rapports de revenus - les bénéfices par plage de dates';

  @override
  String get docsExportCustomers => 'Rapports clients - votre liste de clients';

  @override
  String get docsExportServices => 'Rapports de services - performance par service';

  @override
  String get docsExportWorkers => 'Rapports de travailleurs - mesures de performance du personnel';

  @override
  String get docsExportUsesTitle => 'Pourquoi exporter les données?';

  @override
  String get docsExportUsesContent => 'Utilisez les données exportées dans Excel pour une analyse personnalisée, la tenue de registres, à des fins fiscales ou pour partager avec un comptable.';

  @override
  String get docsTimeSlotsTitle => 'Créneaux horaires expliqués';

  @override
  String get docsTimeSlotsSubtitle => 'Comprendre le fonctionnement des heures de réservation';

  @override
  String get docsTimeSlotsOverviewTitle => 'Que sont les créneaux horaires?';

  @override
  String get docsTimeSlotsOverviewSubtitle => 'Apprenez comment le système de programmation fonctionne';

  @override
  String get docsTimeSlotsWelcomeTitle => 'Bienvenue aux créneaux horaires';

  @override
  String get docsTimeSlotsWelcomeContent => 'Les créneaux horaires sont les heures disponibles où les clients peuvent réserver vos services. Comprendre leur fonctionnement vous aide à gérer votre horaire efficacement.';

  @override
  String get docsTimeSlotsBasicsTitle => 'Principes fondamentaux des créneaux horaires';

  @override
  String get docsTimeSlotsBasicsContent => 'Voici comment fonctionnent les créneaux horaires:';

  @override
  String get docsTimeSlotsPoint1 => 'Chaque service a une durée (combien de temps il faut)';

  @override
  String get docsTimeSlotsPoint2 => 'Vous définissez vos heures disponibles (quand vous travaillez)';

  @override
  String get docsTimeSlotsPoint3 => 'Le système crée des créneaux horaires basés sur la durée du service';

  @override
  String get docsTimeSlotsPoint4 => 'Les clients ne peuvent réserver que les créneaux disponibles';

  @override
  String get docsTimeSlotsExampleTitle => 'Exemple: Créer des créneaux horaires';

  @override
  String get docsTimeSlotsExampleContent => 'Si vous proposez une coupe de cheveux de 30 minutes et que vous travaillez de 9 h à 17 h:\n• 9h00 - 9h30 (Créneau 1)\n• 9h30 - 10h00 (Créneau 2)\n• 10h00 - 10h30 (Créneau 3)\n...et ainsi de suite toute la journée';

  @override
  String get docsTimeSlotsOverlapTitle => 'Et si les services se chevauchent?';

  @override
  String get docsTimeSlotsOverlapContent => 'Si vous avez plusieurs membres du personnel, chaque personne a son propre horaire. Si vous travaillez seul, un seul client peut réserver à la fois — le système bloque automatiquement les heures en conflit.';

  @override
  String get docsTimeSlotsGapTitle => 'Définir des écarts entre les services';

  @override
  String get docsTimeSlotsGapContent => 'Vous pouvez définir le temps tampon entre les réservations. Exemple: 15 minutes d\'écart après chaque coupe de cheveux pour le nettoyage. Cela réduit les créneaux disponibles mais vous donne de la respiration.';

  @override
  String get docsTimeSlotsGroupTitle => 'Réservations de groupe et créneaux horaires';

  @override
  String get docsTimeSlotsGroupContent => 'Pour les réservations de groupe, le système trouve des heures qui conviennent à TOUTES les personnes du groupe. Cela rend plus difficile la recherche de créneaux disponibles, mais garantit que tout le monde est servi ensemble.';

  @override
  String get docsTimeSlotsBlockingTitle => 'Temps de blocage';

  @override
  String get docsTimeSlotsBlockingContent => 'Vous pouvez bloquer manuellement le temps pour le déjeuner, les pauses ou les rendez-vous personnels. Le temps bloqué n\'apparaîtra pas comme disponible pour les clients.';

  @override
  String get docsTimeSlotsUtilizationTitle => 'Maximiser vos créneaux horaires';

  @override
  String get docsTimeSlotsUtilizationContent => 'Conseils pour utiliser vos créneaux efficacement:\n• Faites correspondre la durée du service à la réalité (ne sous-estimez pas)\n• Définissez des écarts réalistes entre les services\n• Utilisez le temps tampon de manière stratégique\n• Passez en revue et ajustez en fonction des commentaires des clients';

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
}
