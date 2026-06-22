// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Nano Embryo';

  @override
  String get appDescription => 'Your innovative app';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonLogin => 'Login';

  @override
  String get commonLogout => 'Logout';

  @override
  String get commonDone => 'Done';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonAccept => 'Accept';

  @override
  String get commonReject => 'Reject';

  @override
  String get introGetStarted => 'Get Started';

  @override
  String get actionsBlock => 'Block user';

  @override
  String get actionsReport => 'Report user';

  @override
  String get actionsSend => 'Send to chat';

  @override
  String get actionsShare => 'Share';

  @override
  String get actionsCopy => 'Copy link';

  @override
  String get appInfoVersion => 'Version';

  @override
  String get appInfoReleased => 'Released';

  @override
  String get appInfoPackageName => 'Package Name';

  @override
  String get appInfoDeveloper => 'Developer Name';

  @override
  String get appInfoSupportEmail => 'Support Email';

  @override
  String get appInfoTechnicalDetails => 'Technical Details';

  @override
  String get appInfoBundleID => 'Bundle ID';

  @override
  String get appInfoBuildVersion => 'Build Version';

  @override
  String get appInfoBuildNumber => 'Build Number';

  @override
  String get appInfoReleaseDate => 'Release Date';

  @override
  String get appInfoAppSize => 'App Size';

  @override
  String appInfoOverview(String appName) {
    return '$appName is a modern mobile application built with robust security and functionality, designed to provide an exceptional user experience with clean architecture and performance optimization.';
  }

  @override
  String introTitle(String appName) {
    return 'Welcome to $appName';
  }

  @override
  String get introFeature1Title => 'See Your Progress';

  @override
  String get introFeature1Description => 'Track your development milestones with detailed analytics and insights';

  @override
  String get introFeature2Title => 'Explore Templates';

  @override
  String get introFeature2Description => 'Discover pre-built components and screens for rapid development';

  @override
  String get introFeature3Title => 'Get Started Quickly';

  @override
  String get introFeature3Description => 'Jumpstart your project with zero-config setup and best practices';

  @override
  String get appleSignIn => 'Sign in with Apple';

  @override
  String get googleSignIn => 'Sign in with Google';

  @override
  String get appleRegister => 'Continue with Apple';

  @override
  String get googleRegister => 'Continue with Google';

  @override
  String get emailAndPassword => 'Enter email and password';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get legalConsentPart1 => 'Kindly read the ';

  @override
  String get legalConsentPart2 => 'terms and conditions';

  @override
  String legalConsentPart3(String appName) {
    return ' and other legal documents that govern your use of $appName.';
  }

  @override
  String get emailTitle => 'Email';

  @override
  String get passwordTitle => 'Password';

  @override
  String get loginEmailLabel => 'Email address';

  @override
  String get loginEmailHint => 'Enter your email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => 'Enter your password';

  @override
  String get loginForgotPasswordPart1 => 'Have you forgotten your password? ';

  @override
  String get loginForgotPasswordPart2 => 'Tap here';

  @override
  String get loginForgotPasswordPart3 => ' to reset your password?';

  @override
  String get commonConfirmPasswordLabel => 'Confirm Password';

  @override
  String get commonConfirmPasswordHint => 'Please confirm your password';

  @override
  String get commonPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get commonPasswordConfirmRequired => 'Please confirm your password';

  @override
  String commonFieldIsValid(String field) {
    return '$field is valid';
  }

  @override
  String get commonPleaseWait => 'Please wait for the current operation to complete';

  @override
  String get commonUnexpectedError => 'An unexpected error occurred. Please try again.';

  @override
  String get commonSomethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get commonEnterEmailAndRetry => 'Please enter your email address and try again';

  @override
  String get commonLearnMore => 'Learn more';

  @override
  String get authSignUpVerificationSent => 'Verification email sent! Please check your inbox.';

  @override
  String authSignUpFailed(String error) {
    return 'Sign-up failed: $error';
  }

  @override
  String get authForgotPasswordTitle => 'Forgot your password?';

  @override
  String get authForgotPasswordSubtitle => 'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get authSendResetLink => 'Send reset link';

  @override
  String get authBackToSignIn => 'Back to sign in';

  @override
  String get authUsernameScreenTitle => 'Choose your username';

  @override
  String get authUsernameScreenSubtitle => 'This is how others will see you. You can change it later.';

  @override
  String get authUsernameLabel => 'Username';

  @override
  String get authUsernameHint => 'Enter a username';

  @override
  String authUsernameMinLength(int min) {
    return 'Username must be at least $min characters';
  }

  @override
  String authUsernameMaxLength(int max) {
    return 'Username must be at most $max characters';
  }

  @override
  String get authUsernameFormatError => 'Only letters, numbers, and underscores are allowed';

  @override
  String get authUsernameTaken => 'This username is already taken';

  @override
  String get authUsernameCheckError => 'Unable to check username availability. Please try again.';

  @override
  String get authUsernameSaveError => 'Could not save your username. Please try again.';

  @override
  String get authUsernameSavedSuccess => 'Username saved successfully!';

  @override
  String get authUpdatePasswordTitle => 'Create new password';

  @override
  String get authUpdatePasswordButton => 'Update password';

  @override
  String get authUpdatePasswordSuccess => 'Password updated successfully. Please sign in again.';

  @override
  String get authPasswordResetSentTitle => 'Check your email';

  @override
  String get authPasswordResetSentBody => 'We sent a password reset link to';

  @override
  String get authPasswordResetSentNote => 'Tap the link in the email to set a new password. The link expires in 1 hour.';

  @override
  String get authGuestHello => 'Hello!';

  @override
  String authGuestOverview(String appName) {
    return 'You are browsing $appName as a guest. Log in or create an account to start managing your shop — it takes less than 5 seconds. We have a variety of tools to help grow your business, all free of charge.';
  }

  @override
  String authIntroTitle(String appName) {
    return 'Welcome to\n$appName';
  }

  @override
  String get authIntroSubtitle => 'Welcome to the platform we built for you. Enjoy and have fun — the best is waiting.';

  @override
  String get authReadLegalities => 'Read legalities';

  @override
  String get authPasswordRequired => 'Please enter your password';

  @override
  String get authCreatingAccount => 'Creating account...';

  @override
  String get authAccountCreatedSuccess => 'Account created successfully!';

  @override
  String get authCheckEmailToConfirm => 'Please check your email to confirm your account';

  @override
  String get authSigningInWithGoogle => 'Signing in with Google...';

  @override
  String authGoogleSignInFailed(String error) {
    return 'Google sign-in failed: $error';
  }

  @override
  String get authAuthenticatingWithApple => 'Authenticating with Apple...';

  @override
  String authAppleSignInFailed(String error) {
    return 'Apple sign-in failed: $error';
  }

  @override
  String get authSendingResetEmail => 'Sending reset email...';

  @override
  String get authResetEmailSent => 'Reset email sent. Check your inbox.';

  @override
  String authPasswordResetFailed(String error) {
    return 'Password reset failed: $error';
  }

  @override
  String get authVerifyEmailTitle => 'Check your email';

  @override
  String get authVerifyEmailSubtitle => 'We sent a confirmation link to';

  @override
  String get authVerifyEmailNote => 'Tap the link in the email to verify your account and continue.';

  @override
  String get authConfirmationResent => 'Confirmation email resent. Check your inbox.';

  @override
  String get authResendFailed => 'Failed to resend email. Please try again.';

  @override
  String get authResendEmailButton => 'Resend confirmation email';

  @override
  String authResendEmailCooldown(int seconds) {
    return 'Resend email (${seconds}s)';
  }

  @override
  String get currencySelectorPlaceholder => 'Select currency';

  @override
  String get currencySelectorNoSelected => 'No currency selected';

  @override
  String get currencySelectorTitle => 'Select Currency';

  @override
  String get currencySelectorSearchHint => 'Search by currency, code, or flag...';

  @override
  String get currencySelectorNoResults => 'No currencies found';

  @override
  String get discoverScreenTitle => 'Discover';

  @override
  String get discoverSearchHint => 'Search...';

  @override
  String get discoverAllShopsRegion => 'All shops in your region';

  @override
  String get discoverAllFreelancers => 'All freelancers near you';

  @override
  String get discoverMarketplaceTitle => 'Marketplace';

  @override
  String get discoverMarketplaceSubtitle => 'Shop beauty products with cash on delivery';

  @override
  String get discoverBrowseProducts => 'Browse products';

  @override
  String get discoverMyOrders => 'My orders';

  @override
  String get discoverCartTooltip => 'Cart';

  @override
  String get homeScheduleTabLabel => 'Schedule';

  @override
  String get homeDashboardTabLabel => 'Dashboard';

  @override
  String get homeMapTabLabel => 'Map';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationEmailInvalid => 'Please enter a valid email address';

  @override
  String validationPasswordLength(int minLength) {
    return 'Password must be at least $minLength characters';
  }

  @override
  String get validationPasswordUppercase => 'Password must include at least one uppercase letter';

  @override
  String get loggingInIndicatorText => 'Logging in...';

  @override
  String get loginSuccessful => 'Login successful!\nWelcome back';

  @override
  String get errorLoginFailed => 'Login failed. Please check your credentials';

  @override
  String get errorNetwork => 'Network error. Please check your connection';

  @override
  String get homeTitle => 'Home';

  @override
  String get profileTitle => 'Profile';

  @override
  String get chatTitle => 'Chat';

  @override
  String get editProfileNameFieldTitle => 'Name';

  @override
  String get editProfileNameFieldLabel => 'Full name';

  @override
  String get editProfileUserFieldNameTitle => 'Username';

  @override
  String get editProfileUsernameFieldLabel => '@username';

  @override
  String get editProfileBioFieldTitle => 'Bio';

  @override
  String get editProfileBioFieldLabel => 'Tell us about yourself';

  @override
  String get editProfileScreenTitle => 'Edit profile';

  @override
  String get editProfileSettingTitle => 'Account Settings';

  @override
  String get editProfileSettingSubtitle => 'Manage your account';

  @override
  String get editProfileScreenEditShopTitle => 'Edit Shop';

  @override
  String get editProfileScreenEditShopSubtitle => 'Change your shop information';

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
  String get languageScreenSubtitle => 'Choose your preferred language for the app interface.\nThis will not affect your device settings.';

  @override
  String get languageScreeUseDeviceLang => 'Use Device Language.';

  @override
  String get languageScreeUseDeviceLangNote => 'This will reset to match your device system language.';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get accountSectionTitle => 'Account';

  @override
  String get accountSectionSubtitle => '';

  @override
  String get profileItemTitle => 'Profile';

  @override
  String get profileItemSubtitle => 'Manage your personal data';

  @override
  String get locationItemTitle => 'Change Location';

  @override
  String get locationItemSubtitle => 'Change your current city';

  @override
  String get saveItemTitle => 'Saved Contents';

  @override
  String get saveItemSubtitle => 'Contents you have saved';

  @override
  String get notificationsItemTitle => 'Notifications';

  @override
  String get notificationsItemSubtitle => 'Manage push and email notifications';

  @override
  String get blockedItemTitle => 'Blocked Accounts';

  @override
  String get blockedItemSubtitle => 'Accounts you have blocked';

  @override
  String get qrCodeItemTitle => 'Share QR Code';

  @override
  String get qrCodeItemSubtitle => 'Share your account QR code';

  @override
  String get shareProfileItemTitle => 'Share Profile';

  @override
  String get shareProfileItemSubtitle => 'Share your profile with friends';

  @override
  String get appSettingsSectionTitle => 'App Settings';

  @override
  String get appSettingsSectionSubtitle => 'Customize your experience';

  @override
  String get themeItemTitle => 'Theme';

  @override
  String get themeItemSubtitle => 'Light, Dark, or System';

  @override
  String get languageItemTitle => 'Language';

  @override
  String get languageItemSubtitle => 'Change app language';

  @override
  String get biometricItemTitle => 'Biometric Login';

  @override
  String get biometricItemSubtitle => 'Use Face ID or Touch ID';

  @override
  String get supportSectionTitle => 'Support';

  @override
  String get supportSectionSubtitle => '';

  @override
  String get guideItemTitle => 'User Guide';

  @override
  String get guideItemSubtitle => 'Documentation and tutorials';

  @override
  String get helpItemTitle => 'Contact Support';

  @override
  String get helpItemSubtitle => 'Get help with the app';

  @override
  String get feedbackItemTitle => 'Send Feedback';

  @override
  String get feedbackItemSubtitle => 'Share your thoughts';

  @override
  String get rateItemTitle => 'Rate the App';

  @override
  String get rateItemSubtitle => 'Leave a review';

  @override
  String appInfoItemTitle(String appName) {
    return 'About $appName';
  }

  @override
  String get appInfoItemSubtitle => 'Technical information';

  @override
  String get legalSectionTitle => 'Legal';

  @override
  String get legalSectionSubtitle => '';

  @override
  String get termsItemTitle => 'Terms, Privacy & Policies';

  @override
  String get termsItemSubtitle => 'Read our terms';

  @override
  String get licensesItemTitle => 'Open Source Licenses';

  @override
  String get licensesItemSubtitle => 'Third-party libraries and licenses';

  @override
  String get accountActionsSectionTitle => 'Account Actions';

  @override
  String get accountActionsSectionSubtitle => '';

  @override
  String get updatePasswordItemTitle => 'Update password';

  @override
  String get updatePasswordItemSubtitle => 'Change your current account password';

  @override
  String get deactivateItemTitle => 'Deactivate';

  @override
  String get deactivateItemSubtitle => 'Temporarily hide and deactivate your account';

  @override
  String get deleteItemTitle => 'Delete Account';

  @override
  String get deleteItemSubtitle => 'Request permanent account deletion';

  @override
  String get logoutItemTitle => 'Log Out';

  @override
  String get logoutItemSubtitle => 'Sign out of your account';

  @override
  String get logoutConfirmTitle => 'Are you sure you want to log out?';

  @override
  String get logoutConfirmMessage => 'You will need to log in again to access your account and data.';

  @override
  String get logoutConfirmButton => 'Log out';

  @override
  String get logoutSuccessMessage => 'Signed out successfully';

  @override
  String logoutFailedMessage(String error) {
    return 'Sign out failed: $error';
  }

  @override
  String get accountDeactivateTitle => 'Deactivate account';

  @override
  String get accountDeleteTitle => 'Delete account';

  @override
  String get accountRestoreTitle => 'Restore account';

  @override
  String get accountDeactivateWarningTitle => 'Your account will be hidden';

  @override
  String get accountDeactivateWarningBody => 'Your profile, shops, products, freelancer listing, and booking links will be hidden. You can restore access by signing in again.';

  @override
  String get accountDeleteWarningTitle => 'Deletion is scheduled for 30 days';

  @override
  String get accountDeleteWarningBody => 'Your public presence will be hidden now. You can restore your account within 30 days; after that, personal profile data is removed.';

  @override
  String get accountPasswordConfirmLabel => 'Confirm password';

  @override
  String get accountPasswordConfirmHint => 'Enter your password';

  @override
  String accountPhraseConfirmLabel(String phrase) {
    return 'Type $phrase to confirm';
  }

  @override
  String get accountReasonLabel => 'Reason (optional)';

  @override
  String get accountReasonHint => 'Tell us why you are leaving';

  @override
  String accountPhraseMismatch(String phrase) {
    return 'Type $phrase to continue';
  }

  @override
  String get accountActionBlocked => 'Resolve active bookings, orders, or withdrawals before continuing.';

  @override
  String get accountActionLoadFailed => 'We could not load account requirements. Please try again.';

  @override
  String get accountActionGenericError => 'We could not complete this account action. Please try again.';

  @override
  String get accountRecentAuthRequired => 'Please sign in again before continuing.';

  @override
  String get accountReasonTooLong => 'Reason must be 1000 characters or fewer.';

  @override
  String get accountDeactivateButton => 'Deactivate account';

  @override
  String get accountDeleteButton => 'Request deletion';

  @override
  String get accountDeactivatedSuccess => 'Your account has been deactivated.';

  @override
  String get accountDeletionRequestedSuccess => 'Account deletion has been scheduled.';

  @override
  String get accountRestoreButton => 'Restore account';

  @override
  String get accountRestoredSuccess => 'Your account has been restored.';

  @override
  String get accountRestoreFailed => 'We could not restore this account.';

  @override
  String get accountRestoreMissingProfile => 'We could not load your profile.';

  @override
  String get accountDeactivatedTitle => 'Account deactivated';

  @override
  String get accountDeactivatedBody => 'Your account is hidden. Restore it to continue using the app.';

  @override
  String get accountPendingDeleteTitle => 'Account pending deletion';

  @override
  String accountPendingDeleteBody(String date) {
    return 'Your account is scheduled for deletion on $date. Restore it before then to keep your account.';
  }

  @override
  String get accountDeletedTitle => 'Account deleted';

  @override
  String get accountDeletedBody => 'This account has been deleted and can no longer be restored.';

  @override
  String get accountBlockersTitle => 'Resolve these first';

  @override
  String accountBlockerActiveBookings(int count) {
    return '$count active booking(s)';
  }

  @override
  String accountBlockerOwnedShopActiveBookings(int count) {
    return '$count active shop booking(s)';
  }

  @override
  String accountBlockerActiveOrders(int count) {
    return '$count active order(s)';
  }

  @override
  String accountBlockerOwnedShopActiveOrders(int count) {
    return '$count active shop order(s)';
  }

  @override
  String accountBlockerActiveWithdrawals(int count) {
    return '$count pending withdrawal(s)';
  }

  @override
  String get loadingDefaultMessage => 'Loading...';

  @override
  String emptyStateNoDataTitle(String dataType) {
    return 'No $dataType yet';
  }

  @override
  String emptyStateNoDataSubtitle(String dataType) {
    return 'When $dataType becomes available, they will appear here.';
  }

  @override
  String get emptyStateNoResultsTitle => 'No results found';

  @override
  String emptyStateNoResultsSubtitle(String dataType) {
    return 'Try adjusting your search or filters to find $dataType.';
  }

  @override
  String get emptyStateNoInternetTitle => 'No internet connection';

  @override
  String get emptyStateNoInternetSubtitle => 'Check your connection and try again.';

  @override
  String get emptyStateNoFavoritesTitle => 'No favorites yet';

  @override
  String get emptyStateNoFavoritesSubtitle => 'Start adding items to your favorites list.';

  @override
  String get emptyStateNoMessagesTitle => 'No messages';

  @override
  String get emptyStateNoMessagesSubtitle => 'Start a conversation to see messages here.';

  @override
  String get emptyStateRefresh => 'Refresh';

  @override
  String get emptyStateClearFilters => 'Clear filters';

  @override
  String get emptyStateRetry => 'Try again';

  @override
  String get emptyStateExplore => 'Explore';

  @override
  String get emptyStateStartChat => 'Start chat';

  @override
  String get errorNetworkTitle => 'Connection Error';

  @override
  String get errorNetworkSubtitle => 'Unable to connect to the server. Check your internet connection.';

  @override
  String get errorServerTitle => 'Server Error';

  @override
  String get errorServerSubtitle => 'Something went wrong on our end. Please try again later.';

  @override
  String get errorClientTitle => 'Request Error';

  @override
  String get errorClientSubtitle => 'There was a problem with your request. Please check and try again.';

  @override
  String get errorParsingTitle => 'Data Error';

  @override
  String errorParsingSubtitle(String dataType) {
    return 'Unable to process the $dataType. This might be a temporary issue.';
  }

  @override
  String get errorPermissionTitle => 'Access Denied';

  @override
  String errorPermissionSubtitle(String dataType) {
    return 'You don\'t have permission to access this $dataType.';
  }

  @override
  String get errorGenericTitle => 'Something went wrong';

  @override
  String errorGenericSubtitle(String dataType) {
    return 'An unexpected error occurred while loading $dataType. Please try again.';
  }

  @override
  String get errorRetry => 'Try again';

  @override
  String get errorCheckSettings => 'Check settings';

  @override
  String get errorReport => 'Report issue';

  @override
  String get errorGoBack => 'Go back';

  @override
  String get errorRefresh => 'Refresh';

  @override
  String get errorRequestAccess => 'Request access';

  @override
  String get errorContactSupport => 'Contact support';

  @override
  String get dataTypeUsers => 'users';

  @override
  String get dataTypeUser => 'user';

  @override
  String get dataTypeProducts => 'products';

  @override
  String get dataTypeProduct => 'product';

  @override
  String get dataTypeOrders => 'orders';

  @override
  String get dataTypeOrder => 'order';

  @override
  String get dataTypeMessages => 'messages';

  @override
  String get dataTypeMessage => 'message';

  @override
  String get dataTypeFavorites => 'favorites';

  @override
  String get dataTypeFavorite => 'favorite';

  @override
  String get dataTypeData => 'data';

  @override
  String get dataTypeContent => 'content';

  @override
  String get dataTypeItems => 'items';

  @override
  String get dataTypeItem => 'item';

  @override
  String get eulaTitle => 'End User License Agreement';

  @override
  String eulaContent(String appName, String supportEmail) {
    return 'This End User License Agreement (\"EULA\") is a legal agreement between you and Bars Opus, Ltd. for $appName.\n\nBy installing, accessing, or using $appName, you agree to be bound by the terms of this EULA. $appName is licensed, not sold, to you for use only under the terms of this license. Bars Opus, Ltd. reserves all rights not expressly granted to you in this EULA.\n\nYou may not modify, reverse engineer, decompile, or disassemble $appName. This license is valid until terminated by you or Bars Opus, Ltd. Your rights under this license will terminate automatically without notice if you fail to comply with any term(s).\n\nAll intellectual property rights in and to $appName are owned by Bars Opus, Ltd. This EULA is governed by the laws of England and Wales.\n\nFor questions about this EULA, please contact: $supportEmail.';
  }

  @override
  String get eulaFooter => 'By agreeing, you acknowledge that you have read and understood this End User License Agreement.';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String privacyPolicyContent(String appName) {
    return 'This Privacy Policy explains how Bars Opus, Ltd. (\"we\", \"us\", \"our\") collects, uses, and protects your information when you use $appName.\n\nWe collect information you provide directly, such as when you create an account, complete your profile, or contact support. We automatically collect certain information about your device and how you use $appName. We use cookies and similar tracking technologies to track activity and hold certain information.\n\nWe use the information we collect to provide, maintain, and improve $appName. We may share your information with third-party service providers who perform services on our behalf. We may disclose your information if required by law or to protect our rights and safety.\n\nYou have the right to access, correct, or delete your personal information. We implement appropriate technical and organizational measures to protect your information. We may update this Privacy Policy from time to time. We will notify you of any changes.';
  }

  @override
  String privacyPolicyFooter(String appName, DateTime currentDate) {
    final intl.DateFormat currentDateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String currentDateString = currentDateDateFormat.format(currentDate);

    return '$appName Privacy Policy - Last updated: $currentDateString';
  }

  @override
  String get termsTitle => 'Terms of Service';

  @override
  String termsContent(String appName, String supportEmail) {
    return 'These Terms of Service (\"Terms\") govern your access to and use of $appName. By accessing or using $appName, you agree to be bound by these Terms.\n\nYou must be at least 13 years old to use $appName. You are responsible for safeguarding your account credentials and for all activities under your account. You may not use $appName for any illegal or unauthorized purpose.\n\nWe reserve the right to modify, suspend, or discontinue $appName at any time. All content included in $appName is the property of Bars Opus, Ltd. or its licensors.\n\nWe may terminate or suspend your access to $appName immediately if you violate these Terms. These Terms shall be governed by and construed in accordance with the laws of England and Wales.\n\nFor any questions about these Terms, please contact us at $supportEmail.';
  }

  @override
  String get dataSharingTitle => 'Data Sharing Agreement';

  @override
  String dataSharingContent(String appName) {
    return 'This Data Sharing Agreement outlines how your information may be shared when you use $appName social features.\n\nWhen you connect with friends on $appName, certain activity data may be visible to them. Shared activity data may include workout duration, calories burned, exercise minutes, and achievement badges. Your profile information (display name and profile picture) is visible to friends you connect with.\n\nYour email address and contact information remain private and are never shared with other users. You control what data is shared through your $appName privacy settings. You can revoke sharing permissions at any time in the app settings.\n\nData shared with friends is encrypted during transmission and storage. We retain shared data only as long as necessary to provide the sharing functionality. Third-party integrations may have their own data sharing practices, which we recommend reviewing.';
  }

  @override
  String dataSharingFooter(String appName) {
    return 'Data sharing in $appName helps create a supportive community while respecting your privacy choices.';
  }

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardSubtitle => 'Manage your shop activities efficiently';

  @override
  String get dashboardSectionTitle => 'Dashboard';

  @override
  String get dashboardSectionSubtitle => 'Overview of your shop\'s performance and key metrics';

  @override
  String get dashboardPayoutTitle => 'Request Payout';

  @override
  String get dashboardPayoutContent => 'Shop owners can request weekly payouts. Navigate to the Earnings section, review your balance, and submit a payout request. Funds typically process within 3-5 business days.';

  @override
  String get dashboardAnalyticsTitle => 'Analytics Dashboard';

  @override
  String get dashboardAnalyticsContent => 'Track your shop\'s performance with real-time analytics. Monitor sales trends, customer engagement, and inventory levels through interactive charts and reports.';

  @override
  String get dashboardScreenshotTitle => 'Dashboard Overview';

  @override
  String get dashboardScreenshotContent => 'The main dashboard provides a comprehensive view of your shop\'s key metrics, recent activities, and quick access to essential features.';

  @override
  String get categoryFeatures => 'Features';

  @override
  String get categoryDashboard => 'Dashboard';

  @override
  String get faqDashboard1Question => 'When can I request a payout?';

  @override
  String get faqDashboard1Answer => 'You can request your payout once a week, every Saturday. The weekly cutoff is Friday at 11:59 PM. Payouts are processed within 3-5 business days.';

  @override
  String get faqDashboard2Question => 'Where do I request my payout?';

  @override
  String get faqDashboard2Answer => 'Navigate to your dashboard and click on the \'Earnings\' section. From there, you\'ll see your current balance and a \'Request Payout\' button. Follow the prompts to complete your request.';

  @override
  String get profileScreenCantChatWithYourself => 'You can\'t chat with yourself';

  @override
  String get profileScreenStartingConversation => 'Starting conversation...';

  @override
  String get profileScreenNoActiveSession => 'No active session — please log in again.';

  @override
  String get profileScreenSignInToChatMessage => 'You have to sign in to send a message';

  @override
  String get profileScreenFollowFeatureComingSoon => 'Follow feature coming soon';

  @override
  String get profileScreenEnterBioPlaceholder => 'Enter a bio so people can know you';

  @override
  String get profileScreenNoBioYet => 'No bio yet';

  @override
  String get profileScreenErrorLoadingProfileBody => 'Unable to load profile. Check your internet and try again.';

  @override
  String get profileScreenLoadingNotifications => 'Loading...';

  @override
  String get profileHeaderBookingsStatLabel => 'Bookings';

  @override
  String get profileHeaderOrdersStatLabel => 'Orders';

  @override
  String get profileHeaderEditProfileButton => 'Edit profile';

  @override
  String get profileHeaderMessageButton => 'Message';

  @override
  String get editableProfileAvatarTakePhoto => 'Take a photo';

  @override
  String get editableProfileAvatarChooseGallery => 'Choose from gallery';

  @override
  String get editProfileScreenAccountTypeLabel => 'Account Type';

  @override
  String get editProfileScreenAccountTypeSubtitle => 'Select how you want to use this app. This determines what features are available to you.';

  @override
  String get editProfileScreenUpdatingAccountType => 'Updating account type...';

  @override
  String get editProfileScreenPleaseLogIn => 'Please log in';

  @override
  String get editProfileScreenNameLabel => 'Name';

  @override
  String get editProfileScreenNameHint => 'Enter your name';

  @override
  String get editProfileScreenUsernameLabel => 'Username';

  @override
  String get editProfileScreenUsernameHint => 'Enter username';

  @override
  String get editProfileScreenBioLabel => 'Bio';

  @override
  String get editProfileScreenBioHint => 'Tell something about yourself';

  @override
  String get editProfileScreenEditWorkProfileTitle => 'Edit work profile';

  @override
  String get profileTabsAppointments => 'Appointments';

  @override
  String get profileTabsBuys => 'Buys';

  @override
  String get profileTabsSaves => 'Saves';

  @override
  String get searchScreenSearchHint => 'Search shops, professionals, products...';

  @override
  String get searchScreenNoResultsFound => 'No results found';

  @override
  String searchScreenNoResultsCategory(String category) {
    return 'No $category found';
  }

  @override
  String searchScreenSearchedFor(String query) {
    return 'Searched for: \"$query\"';
  }

  @override
  String get searchScreenSomethingWentWrong => 'Something went wrong';

  @override
  String get searchAppBarSearchHint => 'Search...';

  @override
  String get searchSuggestionsHint => 'Search for shops, professionals for home service, or hair products to buy';

  @override
  String get searchSuggestionsRecentSearches => 'Recent Searches';

  @override
  String get searchSuggestionsClearAll => 'Clear All';

  @override
  String get searchEmptyStateNoResults => 'No results found';

  @override
  String searchEmptyStateCouldNotFind(String query) {
    return 'We couldn\'t find anything for \"$query\"';
  }

  @override
  String get searchEmptyStateTryThese => 'Try these instead:';

  @override
  String get searchResultsShopsHeader => 'Shops';

  @override
  String get searchResultsSeeAll => 'See all';

  @override
  String searchResultsTitle(String category) {
    return '$category Results';
  }

  @override
  String searchResultsSearchingFor(String query) {
    return 'Searching for \"$query\"';
  }

  @override
  String get searchResultsTryDifferent => 'Try different keywords or remove filters';

  @override
  String get searchResultsSomethingWentWrong => 'Something went wrong';

  @override
  String nearYouShopsTitle(int km) {
    return 'Near You\nwithin ${km}km';
  }

  @override
  String nearYouShopsBody(int km) {
    return 'Shops located within $km km of your current location, shown from closest to farthest. Simply set your location once, and we\'ll show you what\'s nearby—whether you\'re at home, work, or exploring a new neighborhood. Handy for last‑minute bookings or when you prefer to walk.';
  }

  @override
  String get nearYouShopsEmptyNoFilter => 'No shops found nearby';

  @override
  String nearYouShopsEmptyWithFilter(String luxury) {
    return 'No $luxury shops found nearby';
  }

  @override
  String nearYouShopsEmptySubtitle(String location) {
    return 'Shops in $location would be shown here once they become available';
  }

  @override
  String get premiumShopsScreenTitle => 'Premium Shops';

  @override
  String get premiumShopsEmpty => 'No premium shops found';

  @override
  String get premiumShopsHorizontalTitle => 'Premium shops\nfor premium looks';

  @override
  String get premiumShopsHorizontalBody => 'Handpicked high‑end salons and spas offering luxury experiences. These shops are classified as Luxury or Ultra‑Luxury based on their services, pricing, and customer reviews. Perfect when you\'re looking for that extra touch of elegance.';

  @override
  String get premiumShopsHorizontalEmptyNoFilter => 'No premium shops available';

  @override
  String premiumShopsHorizontalEmptyWithFilter(String luxury) {
    return 'No $luxury premium shops available';
  }

  @override
  String get premiumShopsHorizontalEmptySubtitle => 'Shops would be shown here once they become available';

  @override
  String get topRatedShopsHorizontalTitle => 'Top Rated';

  @override
  String topRatedShopsHorizontalTitleWithLocation(String location) {
    return 'Top Rated \nin $location';
  }

  @override
  String get topRatedShopsHorizontalBody => 'Shops with the highest customer ratings (4.5+ stars) and a solid number of reviews. These are the favorites among our community—consistently praised for quality, service, and professionalism. A great place to start if you want reliable, crowd‑approved options.';

  @override
  String get topRatedShopsHorizontalEmptyNoFilter => 'No top rated shops available';

  @override
  String topRatedShopsHorizontalEmptyWithFilter(String luxury) {
    return 'No $luxury premium shops available';
  }

  @override
  String get topRatedShopsHorizontalEmptySubtitle => 'Shops would be shown here once they become available';

  @override
  String get topRatedShopsScreenTitle => 'Top Rated Shops';

  @override
  String get topRatedShopsEmpty => 'No top rated shops found';

  @override
  String get nearYouFreelancersScreenTitle => 'Freelancers near you';

  @override
  String get nearYouFreelancersEmpty => 'No freelancers found nearby';

  @override
  String get nearYouFreelancersEmptySubtitle => 'Try expanding your search area or change location';

  @override
  String get topRatedFreelancersScreenTitle => 'Top rated freelancers';

  @override
  String get topRatedFreelancersEmpty => 'No top rated freelancers found';

  @override
  String get topRatedFreelancersEmptySubtitle => 'Try adjusting your search area';

  @override
  String topRatedFreelancersHorizontalTitle(String location) {
    return 'Top Rated \nin $location';
  }

  @override
  String get topRatedFreelancersHorizontalBody => 'Handpicked high‑end professionals offering luxury experiences. These freelancers are classified as top rated based on their work quality, pricing, and customer reviews. Perfect when you\'re looking for that extra touch of excellence.';

  @override
  String nearYouFreelancersHorizontalTitle(String location) {
    return 'Freelancers Near You in $location';
  }

  @override
  String get nearYouFreelancersHorizontalBody => 'Skilled professionals located near you. These freelancers are available for quick bookings and offer convenient, local service. Perfect when you\'re looking for reliability and proximity.';

  @override
  String get nearYouFreelancersHorizontalEmpty => 'No top rated freelancers available';

  @override
  String get nearYouFreelancersHorizontalEmptySubtitle => 'Freelancers would be shown here once they become available';

  @override
  String get shopNoLocationSetTitle => 'Set your location to discover';

  @override
  String get shopNoLocationSetContent => 'Set your location to discover premium and top rated shops near you.';

  @override
  String get providerTypeShops => 'Shops';

  @override
  String get providerTypeFreelancers => 'Freelancers';

  @override
  String get providerTypeBuy => 'Buy';

  @override
  String get luxuryLevelChipsAll => 'All';

  @override
  String get searchRadiusSliderTitle => 'Explore radius';

  @override
  String searchRadiusSliderSubtitle(int km) {
    return 'Showing results within ${km}km of your location';
  }

  @override
  String validationPasswordMaxLength(int max) {
    return 'Password must be at most $max characters';
  }

  @override
  String get validationPasswordRepeatingChars => 'Password contains too many repeating characters';

  @override
  String get validationPasswordSequential => 'Password contains sequential characters';

  @override
  String validationPhoneDigits(int digits) {
    return 'Phone number must be $digits digits';
  }

  @override
  String get validationPhoneUK => 'Invalid UK phone number';

  @override
  String validationUrlScheme(String schemes) {
    return 'URL must start with $schemes';
  }

  @override
  String get validationUrlDomain => 'Invalid domain name';

  @override
  String get validationUrlPublicAddress => 'URL must point to a public address';

  @override
  String validationNameMaxLength(String field, int max) {
    return '$field must be at most $max characters';
  }

  @override
  String validationNameConsecutiveChars(String field) {
    return '$field cannot contain consecutive hyphens or spaces';
  }

  @override
  String get validationCreditCardFormat => 'Please enter a valid credit card number';

  @override
  String get validationCreditCardInvalid => 'Invalid credit card number';

  @override
  String get validationDatePastNotAllowed => 'Date cannot be in the past';

  @override
  String get validationPostalCodeZip => 'Please enter a valid ZIP code (e.g., 12345 or 12345-6789)';

  @override
  String get validationPostalCodeCanadian => 'Please enter a valid Canadian postal code (e.g., A1A 1A1)';

  @override
  String get validationPostalCodeGeneric => 'Please enter a valid postal code';

  @override
  String get validationSSNFormat => 'Please enter a valid SSN (e.g., 123-45-6789)';

  @override
  String get validationSSNInvalid => 'Invalid SSN';

  @override
  String get validationEmailTooLong => 'Email is too long (max 254 characters)';

  @override
  String get validationEmailLocalPartTooLong => 'Local part of email is too long';

  @override
  String get categoriesAll => 'All';

  @override
  String get categoriesSalon => 'Salons';

  @override
  String get categoriesBarbershop => 'Barbershops';

  @override
  String get categoriesSpa => 'Spas';

  @override
  String get categoriesNailSalon => 'Nail Salons';

  @override
  String get categoriesLashStudio => 'Lash Studios';

  @override
  String get categoriesWaxing => 'Waxing';

  @override
  String get categoriesMassage => 'Massage';

  @override
  String get categoriesMakeup => 'Makeup';

  @override
  String get categoriesSkincare => 'Skincare';

  @override
  String get luxuryLevelModerate => 'Moderate';

  @override
  String get luxuryLevelLuxury => 'Luxury';

  @override
  String get luxuryLevelUltraLuxury => 'Ultra Luxury';

  @override
  String get dashboardTabRevenue => 'Revenue';

  @override
  String get dashboardTabAnalytics => 'Analytics';

  @override
  String get dashboardTabInsights => 'Insights';

  @override
  String get dashboardTabTools => 'Tools';

  @override
  String get dashboardTabClients => 'Clients';

  @override
  String get dashboardTabStaff => 'Staff';

  @override
  String get walletRecentTransactions => 'Recent Transactions';

  @override
  String get walletLoadError => 'We couldn\'t load your wallet right now.';

  @override
  String get walletTransactionLoadError => 'Couldn\'t load recent transactions.';

  @override
  String get walletPaymentProcessing => 'Kindly wait for the payment to finish processing and return to your app to complete your booking.';

  @override
  String get analyticsRevenue => 'Revenue';

  @override
  String get analyticsServices => 'Services';

  @override
  String get analyticsWorkers => 'Workers';

  @override
  String get analyticsLoadError => 'Failed to load analytics';

  @override
  String get analyticsEmpty => 'No data available for analytics.';

  @override
  String get analyticsEmptySubtitle => 'Booking and revenue statistics would appear here';

  @override
  String get insightsReports => 'Reports';

  @override
  String get insightsSeeAll => 'See All';

  @override
  String get insightsLoadError => 'Couldn\'t load reports. Pull to refresh.';

  @override
  String get insightsNoAlerts => 'All good! No alerts';

  @override
  String get insightsHeatmapError => 'Couldn\'t load the booking heatmap right now.';

  @override
  String get insightsNoHeatmapData => 'No heatmap data available';

  @override
  String get toolsAdminTools => 'Admin Tools';

  @override
  String get toolsConfigure => 'Configure →';

  @override
  String get toolsManage => 'Manage →';

  @override
  String get toolsExport => 'Export →';

  @override
  String get toolsAutomatedReminders => 'Automated Reminders';

  @override
  String get toolsPromotionsManager => 'Promotions Manager';

  @override
  String get toolsExportReports => 'Export Reports';

  @override
  String get toolsPaymentSettings => 'Payment Settings';

  @override
  String get toolsLoadingDetails => 'Loading shop details…';

  @override
  String get toolsBusinessHours => 'Business Hours';

  @override
  String get toolsServiceManagement => 'Service Management';

  @override
  String get clientsSearchHint => 'Search by name...';

  @override
  String get clientsLoadError => 'Failed to load clients';

  @override
  String get clientsNotFound => 'No Clients Match';

  @override
  String get clientsEmpty => 'No Clients Yet';

  @override
  String clientsSearchEmpty(String query) {
    return 'No clients match \"$query\"';
  }

  @override
  String get clientsEmptySubtitle => 'Clients will appear here when they make their first booking.';

  @override
  String get walletLabel => 'Wallet';

  @override
  String get walletAvailableBalance => 'Available Balance';

  @override
  String get walletWithdrawFunds => 'Withdraw Funds';

  @override
  String get walletTotalEarned => 'Total Earned';

  @override
  String get walletTotalWithdrawn => 'Total Withdrawn';

  @override
  String get transactionDepositReceived => 'Deposit Received';

  @override
  String get transactionServicePayment => 'Service Payment';

  @override
  String get transactionWithdrawal => 'Withdrawal';

  @override
  String get transactionRefund => 'Refund';

  @override
  String get transactionPlatformFee => 'Platform Fee';

  @override
  String get transactionAdjustment => 'Adjustment';

  @override
  String get transactionToday => 'Today';

  @override
  String get transactionYesterday => 'Yesterday';

  @override
  String get withdrawalTitle => 'Withdraw';

  @override
  String withdrawalInfo(double fee, String currency, double minFee) {
    return 'Withdrawals are processed immediately and sent to your connected account. A $fee% fee (min $currency $minFee) applies.';
  }

  @override
  String withdrawalAvailableBalance(String currency, String amount) {
    return 'Available balance: $currency $amount';
  }

  @override
  String withdrawalAmountInputLabel(String currency) {
    return 'Amount ($currency)';
  }

  @override
  String get withdrawalAmountHint => 'Enter amount to withdraw';

  @override
  String get withdrawalAmountRequired => 'Please enter an amount';

  @override
  String get withdrawalAmountInvalid => 'Please enter a valid amount';

  @override
  String withdrawalMinimum(String currency, double min) {
    return 'Minimum withdrawal is $currency $min';
  }

  @override
  String withdrawalMaximum(String currency, double max) {
    return 'Maximum withdrawal per transaction is $currency $max';
  }

  @override
  String withdrawalInsufficientBalance(String currency, String available) {
    return 'Insufficient balance. Available: $currency $available';
  }

  @override
  String get withdrawalBreakdownAmount => 'Withdrawal amount:';

  @override
  String withdrawalFeeLabel(Object fee) {
    return 'Fee ($fee%):';
  }

  @override
  String get withdrawalNetAmount => 'You will receive:';

  @override
  String get withdrawalProcessing => 'Processing...';

  @override
  String get withdrawalRequestButton => 'Request Withdrawal';

  @override
  String get withdrawalNoPaymentMethod => 'No payment method connected';

  @override
  String get withdrawalSuccess => 'Withdrawal request submitted successfully!';

  @override
  String get deadLetterTitle => 'Withdrawal needs review';

  @override
  String deadLetterSingle(String currency, String amount) {
    return '$currency $amount stuck — tap for details';
  }

  @override
  String deadLetterMultiple(String currency, String amount, int count) {
    return '$currency $amount stuck across $count withdrawals — tap for details';
  }

  @override
  String get deadLetterReason => 'Reason:';

  @override
  String get deadLetterContactSupport => 'Contact support';

  @override
  String get paymentSetupTitle => 'Complete payout setup';

  @override
  String get paymentSetupContent => 'Connect your payout account to start withdrawing money from your wallet. This could be your mobile money number or your bank account.';

  @override
  String get calendarErrorLoading => 'Error loading calendar';

  @override
  String get calendarErrorLoadingBookings => 'Error loading bookings';

  @override
  String get calendarNoAppointmentsDay => 'No appointments for this day';

  @override
  String get calendarNoBookingsDay => 'No bookings for this day';

  @override
  String calendarAppointmentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'appointments',
      one: 'appointment',
    );
    return '$count $_temp0';
  }

  @override
  String get monthJanuary => 'Jan';

  @override
  String get monthFebruary => 'Feb';

  @override
  String get monthMarch => 'Mar';

  @override
  String get monthApril => 'Apr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'Jun';

  @override
  String get monthJuly => 'Jul';

  @override
  String get monthAugust => 'Aug';

  @override
  String get monthSeptember => 'Sep';

  @override
  String get monthOctober => 'Oct';

  @override
  String get monthNovember => 'Nov';

  @override
  String get monthDecember => 'Dec';

  @override
  String get dayMonday => 'Mon';

  @override
  String get dayTuesday => 'Tue';

  @override
  String get dayWednesday => 'Wed';

  @override
  String get dayThursday => 'Thu';

  @override
  String get dayFriday => 'Fri';

  @override
  String get daySaturday => 'Sat';

  @override
  String get daySunday => 'Sun';

  @override
  String calendarNoAppointmentsSnackbar(String date) {
    return 'No appointments on this day\n$date';
  }

  @override
  String reviewsScreenTitle(String shopName) {
    return 'Reviews for $shopName';
  }

  @override
  String get reviewsLoadError => 'Failed to load reviews';

  @override
  String get reviewsNoReviews => 'No reviews yet';

  @override
  String get reviewsRateProduct => 'Rate Your Product';

  @override
  String get reviewsYourReview => 'Your Review';

  @override
  String get reviewsReviewHint => 'Share your experience with this product...';

  @override
  String get reviewsSubmitButton => 'Submit Review';

  @override
  String get reviewsThankYou => 'Thank you for your review!';

  @override
  String reviewsSubmitError(String error) {
    return 'Failed to submit review: $error';
  }

  @override
  String get bookingServiceAddress => 'Service Address';

  @override
  String get bookingFindingAvailableTimes => 'Finding available times...';

  @override
  String bookingErrorLoadingWorkers(String error) {
    return 'Error loading workers: $error';
  }

  @override
  String bookingErrorValidatingDistance(String error) {
    return 'Error validating distance: $error';
  }

  @override
  String get bookingAddSpecialRequirements => 'Add';

  @override
  String get bookingCancelSpecialRequirements => 'Cancel';

  @override
  String get bookingSaveSpecialRequirements => 'Save';

  @override
  String bookingFailedSaveRequirements(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get bookingInvitationSent => 'Invitation sent successfully';

  @override
  String get bookingSavingAssignments => 'Saving assignments...';

  @override
  String get bookingAssignmentsSaved => 'Assignments saved successfully';

  @override
  String bookingAssignmentsError(String error) {
    return 'Error: $error';
  }

  @override
  String get scheduleTitle => 'Schedule';

  @override
  String get scheduleTabDaily => 'Daily';

  @override
  String get scheduleTabMonthly => 'Monthly';

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
  String get docsGettingStartedTitle => 'Getting Started';

  @override
  String get docsGettingStartedSubtitle => 'Learn the basics';

  @override
  String get docsGettingStartedWhatIsTitle => 'What is Aura In?';

  @override
  String get docsGettingStartedWhatIsSubtitle => 'Understand the platform';

  @override
  String get docsGettingStartedWelcomeIntroContent => 'Aura In is a mobile marketplace connecting service professionals with customers. Whether you offer haircuts, massages, freelance services, or sell products, this platform helps you grow your business.';

  @override
  String get docsGettingStartedWhoUsesTitle => 'Who Uses Aura In?';

  @override
  String get docsGettingStartedWhoUsesContent => 'Two types of users power the platform:';

  @override
  String get docsGettingStartedWhoUsesProviders => 'Service Providers - Salons, spas, barbers, freelancers who offer services';

  @override
  String get docsGettingStartedWhoUsesCustomers => 'Customers - People searching for and booking services in their area';

  @override
  String get docsGettingStartedWhoUsesSellers => 'Product Sellers - Shops selling retail products or handmade items';

  @override
  String get docsGettingStartedHowItWorksTitle => 'How It Works';

  @override
  String get docsGettingStartedHowItWorksContent => 'Service providers create a profile, list their services with pricing, and accept bookings from customers. Customers search by location, browse services, and book appointments. Everything is managed through the app.';

  @override
  String get docsGettingStartedThreeWaysTitle => 'Three Ways to Use Aura In';

  @override
  String get docsGettingStartedThreeWaysSubtitle => 'Choose your role';

  @override
  String get docsGettingStartedOption1Title => 'Option 1: Browse & Book Services (Customer)';

  @override
  String get docsGettingStartedOption1Content => 'Search for salons, massage therapists, barbers, or freelancers near you. View their services, pricing, and availability. Book appointments directly through the app and pay securely.';

  @override
  String get docsGettingStartedGuestBookingTitle => 'Guest Booking (No App Download Needed)';

  @override
  String get docsGettingStartedGuestBookingContent => 'Don\'t want to download the app? Service providers can share a booking link - you can book and pay directly through that link without creating an account. Your booking details and receipt will be sent to your WhatsApp.';

  @override
  String get docsGettingStartedOption2Title => 'Option 2: Offer Services (Shop Owner or Freelancer)';

  @override
  String get docsGettingStartedOption2Content => 'Create a shop or freelancer profile, list your services with pricing and duration, set your working hours, and manage bookings. Get paid for every service booked.';

  @override
  String get docsGettingStartedOption3Title => 'Option 3: Sell Products (Product Seller)';

  @override
  String get docsGettingStartedOption3Content => 'If you make handmade items or retail products, you can list them for sale. Customers browse and purchase directly from your shop.';

  @override
  String get docsGettingStartedBookingPaymentTitle => 'Booking & Payment System';

  @override
  String get docsGettingStartedBookingPaymentSubtitle => 'How service booking and payment work';

  @override
  String get docsGettingStartedBookingOverviewContent => 'Customers book appointments with service providers. Payments are handled securely through the app using Paystack (Africa) or Stripe (Global).';

  @override
  String get docsGettingStartedDepositPaymentTitle => 'Deposit Payment (30%)';

  @override
  String get docsGettingStartedDepositPaymentContent => 'When booking a service, customers pay 30% upfront as a deposit to secure the time slot. This confirms the booking is real and reserved.';

  @override
  String get docsGettingStartedPlatformFeeTitle => 'Platform Fee';

  @override
  String get docsGettingStartedPlatformFeeContent => 'A small platform fee (2%) is added to help us maintain the platform and provide support. This is calculated on the total booking amount.';

  @override
  String get docsGettingStartedRemainingPaymentTitle => 'Remaining Payment (70%)';

  @override
  String get docsGettingStartedRemainingPaymentContent => 'The remaining 70% can be paid either: (1) in cash when the service is completed, or (2) online through the app before the appointment.';

  @override
  String get docsGettingStartedGuestBookingPaymentTitle => 'Guest Booking Payment';

  @override
  String get docsGettingStartedGuestBookingPaymentContent => 'No app download needed! Customers receive a booking link from the service provider. They pay 30% to secure the slot, and their receipt is sent to WhatsApp.';

  @override
  String get docsGettingStartedProductOrderingTitle => 'Product Ordering & Delivery';

  @override
  String get docsGettingStartedProductOrderingSubtitle => 'How product sales work';

  @override
  String get docsGettingStartedProductOverviewContent => 'Customers browse products, add items to cart, and checkout. Products are delivered to the customer\'s location.';

  @override
  String get docsGettingStartedCODPaymentTitle => 'Cash on Delivery (COD)';

  @override
  String get docsGettingStartedCODPaymentContent => 'For product orders, payment is handled as Cash on Delivery. Customers pay the seller when they receive the items - no upfront payment needed.';

  @override
  String get docsGettingStartedShareYourProfileTitle => 'Share Your Profile';

  @override
  String get docsGettingStartedShareYourProfileSubtitle => 'Make it easy for customers to find you';

  @override
  String get docsGettingStartedShareLinkContent => 'As a service provider, you get a unique booking link. Share it on WhatsApp, social media, or email. Customers can book services without downloading the app.';

  @override
  String get docsGettingStartedCustomURLTitle => 'Custom URL (Optional)';

  @override
  String get docsGettingStartedCustomURLContent => 'You can customize your booking link slug (e.g., aura.in/glamour-salon instead of aura.in/abc123). Makes it easier to share and remember.';

  @override
  String get docsGettingStartedGetHelpTitle => 'Get Help';

  @override
  String get docsGettingStartedGetHelpSubtitle => 'Where to find answers';

  @override
  String get docsGettingStartedHelpDocumentationContent => 'This app has comprehensive documentation for every feature. When you need help, check the relevant guide - there\'s one for your role and the feature you\'re using.';

  @override
  String get docsGettingStartedFAQ1Question => 'What is Aura In?';

  @override
  String get docsGettingStartedFAQ1Answer => 'Aura In is a mobile marketplace for service-based businesses. Customers find and book services (haircuts, massages, etc.), service providers manage bookings and revenue, and product sellers list items for sale.';

  @override
  String get docsGettingStartedFAQ2Question => 'Do I need to pay to use the app?';

  @override
  String get docsGettingStartedFAQ2Answer => 'The app is free to download and use. Service providers only pay a small commission when customers pay for services. Payment processors (Paystack/Stripe) take a fee.';

  @override
  String get docsGettingStartedFAQ3Question => 'What is the difference between Shop Owner and Freelancer?';

  @override
  String get docsGettingStartedFAQ3Answer => 'Shop owners have a fixed location with a team of workers. Freelancers work independently and can travel to clients. Choose based on your business model.';

  @override
  String get docsGettingStartedFAQ4Question => 'How do I get paid?';

  @override
  String get docsGettingStartedFAQ4Answer => 'When customers pay for services, money goes to your wallet. You can withdraw to your bank account using Paystack (Africa) or Stripe (Global).';

  @override
  String get docsGettingStartedFAQ5Question => 'Is my payment information secure?';

  @override
  String get docsGettingStartedFAQ5Answer => 'Yes. Aura In uses Paystack and Stripe, industry-leading payment processors with bank-level security. We never see your payment details.';

  @override
  String get docsGettingStartedFAQ6Question => 'How do I know if service providers near me are trustworthy?';

  @override
  String get docsGettingStartedFAQ6Answer => 'Every service provider has ratings and reviews from customers who have booked with them. Read reviews before booking. High ratings mean consistent, quality service.';

  @override
  String get docsGettingStartedFAQ7Question => 'Can I book without downloading the app?';

  @override
  String get docsGettingStartedFAQ7Answer => 'Yes! Service providers share a unique booking link. You can book directly through that link without downloading the app. Your receipt will be sent to WhatsApp.';

  @override
  String get docsGettingStartedFAQ8Question => 'How much do I pay upfront for bookings?';

  @override
  String get docsGettingStartedFAQ8Answer => 'You pay 30% of the service total upfront to secure the booking slot (plus a 2% platform fee). The remaining 70% can be paid in cash or online before/at the service.';

  @override
  String get docsGettingStartedFAQ9Question => 'How do I pay for products?';

  @override
  String get docsGettingStartedFAQ9Answer => 'Products use Cash on Delivery (COD). You pay the seller when you receive the items. This lets you check quality before paying and works well for local deliveries.';

  @override
  String get docsGettingStartedFAQ10Question => 'Why the 2% platform fee?';

  @override
  String get docsGettingStartedFAQ10Answer => 'The platform fee helps us maintain Aura In, provide payment processing, customer support, and continuously improve features for both customers and service providers.';

  @override
  String get docsBookingStartedTitle => 'Getting Started with Bookings';

  @override
  String get docsBookingStartedSubtitle => 'A simple guide to understanding how bookings work';

  @override
  String get docsBookingIntroTitle => 'Welcome to the Booking System';

  @override
  String get docsBookingIntroSubtitle => 'Everything you need to know about booking services, whether you\'re a client or a shop owner.';

  @override
  String get docsBookingWhatIsTitle => 'What is the Booking System?';

  @override
  String get docsBookingWhatIsContent => 'The booking system is your gateway to scheduling services at your favorite shops. Whether you need a haircut, beard trim, braiding, or any other service, the system makes it easy to book appointments at your convenience.';

  @override
  String get docsBookingWhoIsForTitle => 'Who is this guide for?';

  @override
  String get docsBookingWhoIsForContent => 'This guide is designed for two types of users:';

  @override
  String get docsBookingWhoIsForClients => 'Clients: People who want to book services at shops';

  @override
  String get docsBookingWhoIsForGuests => 'Guest Bookers: People who want to book via a link without creating an account';

  @override
  String get docsBookingWhoIsForOwners => 'Shop Owners: People who manage shops, services, and workers';

  @override
  String get docsBookingGuestIntroTitle => 'New: Book Without Downloading the App';

  @override
  String get docsBookingGuestIntroContent => 'No account? No problem! If a shop owner shares a booking link with you, you can book directly without downloading the app. Your receipt is sent to WhatsApp.';

  @override
  String get docsBookingWelcomeTip => 'No technical knowledge needed! This guide uses simple language and real examples to help you understand everything.';

  @override
  String get docsBookingAccountTitle => 'Creating Your Account (Or Booking as Guest)';

  @override
  String get docsBookingAccountSubtitle => 'Get started in minutes - with or without an account';

  @override
  String get docsBookingTwoWaysTitle => 'Two Ways to Book';

  @override
  String get docsBookingTwoWaysContent => 'You can book in two ways:';

  @override
  String get docsBookingTwoWaysAccount => 'With Account: Download app, create account, book anytime';

  @override
  String get docsBookingTwoWaysGuest => 'As Guest: Use booking link, no app needed, receipt via WhatsApp';

  @override
  String get docsBookingAccountStepsTitle => 'How to Create an Account';

  @override
  String get docsBookingAccountStepsContent => 'Follow these simple steps to create your account:';

  @override
  String get docsBookingAccountTypesTitle => 'Account Types';

  @override
  String get docsBookingAccountTypesContent => 'There are two types of accounts:';

  @override
  String get docsBookingAccountTypesClient => 'Client Account: For booking services at shops';

  @override
  String get docsBookingAccountTypesShop => 'Shop Owner Account: For managing your own shop (requires approval)';

  @override
  String get docsBookingGuestOptionTitle => 'Booking as a Guest (No Account)';

  @override
  String get docsBookingGuestOptionContent => 'If someone shares a booking link with you, you can book directly without creating an account. Just click the link and follow the steps. Your receipt is sent to your WhatsApp.';

  @override
  String get docsBookingVerificationNote => 'You can browse and book without an account using a booking link. Creating an account gives you access to booking history, saved payments, and loyalty rewards.';

  @override
  String get docsBookingFirstBookingTitle => 'Your First Booking';

  @override
  String get docsBookingFirstBookingSubtitle => 'A quick walkthrough';

  @override
  String get docsBookingPaymentTitle => 'How Payment Works';

  @override
  String get docsBookingPaymentContent => 'When you book a service, here\'s how payment works:';

  @override
  String get docsBookingPaymentDeposit => '30% Deposit Required: To secure your booking, you pay 30% of the total service cost upfront';

  @override
  String get docsBookingPaymentNonRefundable => 'Non-Refundable: This deposit is non-refundable if you cancel or don\'t show up';

  @override
  String get docsBookingPaymentRemaining => 'Remaining Balance: The remaining 70% is paid after your service is completed';

  @override
  String get docsBookingPaymentSecure => 'Secure Payment: All payments are processed securely through our payment partners';

  @override
  String get docsBookingDepositNote => 'The 30% deposit protects both you and the shop. It ensures your slot is reserved exclusively for you, and compensates the worker if you cancel last minute.';

  @override
  String get docsBookingBookingTip => 'Pro tip: Book at least 24 hours in advance for the best selection of time slots, especially for popular services.';

  @override
  String get docsBookingAfterTitle => 'After You Book';

  @override
  String get docsBookingAfterSubtitle => 'What happens next';

  @override
  String get docsBookingWhatsNextTitle => 'Your Booking is Confirmed!';

  @override
  String get docsBookingWhatsNextContent => 'Here\'s what you can do after booking:';

  @override
  String get docsBookingRemindersTitle => 'Booking Reminders';

  @override
  String get docsBookingRemindersContent => 'You\'ll receive reminders at:';

  @override
  String get docsBookingAfterServiceTitle => 'After Your Service';

  @override
  String get docsBookingAfterServiceContent => 'Once your service is complete:';

  @override
  String get docsPaymentTitle => 'Payment & Fees Explained';

  @override
  String get docsPaymentSubtitle => 'How 30% deposits, platform fees, and guest bookings work';

  @override
  String get docsPaymentOverviewTitle => 'How Payment Works';

  @override
  String get docsPaymentOverviewSubtitle => 'Simple, transparent, secure';

  @override
  String get docsPaymentSummaryTitle => 'Payment at a Glance';

  @override
  String get docsPaymentSummaryContent => 'Our payment system is designed to be fair for both clients and shop owners. Here\'s the simple breakdown:';

  @override
  String get docsPaymentDeposit30 => '30% Deposit: Paid at booking to secure your appointment';

  @override
  String get docsPaymentPlatformFee => 'Platform Fee: Small fixed fee (e.g., GHS 2) charged by the app';

  @override
  String get docsPaymentRemaining70 => 'Remaining 70%: Paid after your service is complete';

  @override
  String get docsPaymentTwoWays => 'Two Ways to Pay Remaining: Cash or via app';

  @override
  String get docsPaymentQuickExampleTitle => 'Quick Example';

  @override
  String get docsPaymentQuickExampleContent => 'Service cost: GHS 100\nAt booking: Pay GHS 30 (deposit) + GHS 2 (fee) = GHS 32\nAfter service: Pay GHS 70 (cash or app)\nTotal to shop: GHS 100\nPlatform fee: GHS 2';

  @override
  String get docsPaymentImportantNote => 'The platform fee is charged by the app, not the shop. It helps us maintain the platform and provide you with a great booking experience.';

  @override
  String get docsPaymentGuestBookingTitle => 'Guest Booking (No App Download)';

  @override
  String get docsPaymentGuestBookingContent => 'Don\'t have the app? No problem! You can still book through your provider\'s booking link without creating an account. You pay the same 30% deposit + platform fee, and your receipt is sent to WhatsApp.';

  @override
  String get docsDepositTitle => 'The 30% Deposit';

  @override
  String get docsDepositSubtitle => 'Why it\'s needed and how it works';

  @override
  String get docsDepositWhyTitle => 'Why Do We Require a Deposit?';

  @override
  String get docsDepositWhyContent => 'The 30% deposit protects both you and the shop:';

  @override
  String get docsDepositProtectsYou => 'For you: Your slot is guaranteed – no one else can book it';

  @override
  String get docsDepositProtectsShop => 'For the shop: Workers are compensated if you cancel last minute';

  @override
  String get docsDepositProtectsEveryone => 'For everyone: Reduces no-shows, keeping prices fair';

  @override
  String get docsDepositCalcTitle => 'How the Deposit is Calculated';

  @override
  String get docsDepositCalcContent => 'The deposit is always 30% of the total service cost. This includes:';

  @override
  String get docsDepositCalcSingle => 'Single service: 30% of that service price';

  @override
  String get docsDepositCalcMultiple => 'Multiple services: 30% of all services combined';

  @override
  String get docsDepositCalcGroup => 'Group bookings: 30% of total for all people';

  @override
  String get docsDepositExamplesTitle => 'Deposit Examples';

  @override
  String get docsDepositExamplesSingle => 'Single Service:\nHaircut (GHS 45) → Deposit GHS 13.50';

  @override
  String get docsDepositExamplesMultiple => 'Multiple Services:\nHaircut (GHS 45) + Beard Trim (GHS 25) = GHS 70 total\nDeposit: GHS 21';

  @override
  String get docsDepositExamplesGroup => 'Group Booking (3 people):\n3 × Haircut (GHS 45 each) = GHS 135 total\nDeposit: GHS 40.50';

  @override
  String get docsDepositRefundTitle => 'Deposit Refund Policy';

  @override
  String get docsDepositRefundContent => 'The 30% deposit is non-refundable. This means:';

  @override
  String get docsDepositRefundCancel => 'If you cancel: Deposit is not returned';

  @override
  String get docsDepositRefundNoShow => 'If you don\'t show up: Deposit is not returned';

  @override
  String get docsDepositRefundReschedule => 'If you reschedule: Deposit transfers to new time';

  @override
  String get docsDepositRefundShop => 'If shop cancels: Full deposit refunded';

  @override
  String get docsDepositWarning => 'Please be sure about your booking before paying the deposit. While you can reschedule, the deposit cannot be refunded if you cancel.';

  @override
  String get docsFeeTitle => 'Platform Fee';

  @override
  String get docsFeeSubtitle => 'The small fee that keeps the app running';

  @override
  String get docsFeeWhatTitle => 'What is the Platform Fee?';

  @override
  String get docsFeeWhatContent => 'The platform fee is a small fixed charge (e.g., GHS 2) that goes to the app, not the shop. It covers:';

  @override
  String get docsFeeAppDev => 'App development and maintenance';

  @override
  String get docsFeeSupport => 'Customer support and dispute resolution';

  @override
  String get docsFeeProcessing => 'Payment processing costs';

  @override
  String get docsFeeFeatures => 'New features and improvements';

  @override
  String get docsFeeHowTitle => 'How the Fee is Charged';

  @override
  String get docsFeeHowContent => 'Important things to know about the platform fee:';

  @override
  String get docsFeeFixed => 'Fixed amount (not a percentage) – e.g., GHS 2 per booking';

  @override
  String get docsFeePerbooking => 'Charged once per booking – not per service or per person';

  @override
  String get docsFeeNonRefundable => 'Non-refundable – even if you cancel';

  @override
  String get docsFeeShown => 'Clearly shown before you confirm payment';

  @override
  String get docsFeeExamplesTitle => 'Platform Fee Examples';

  @override
  String get docsFeeExamplesSingle => 'Single person, one service: GHS 2 fee';

  @override
  String get docsFeeExamplesMultiple => 'Single person, multiple services: GHS 2 fee (still one booking!)';

  @override
  String get docsFeeExamplesGroup => 'Family of 4 booking together: GHS 2 fee (entire group)';

  @override
  String get docsFeeExamplesSeparate => 'Compare to booking separately:\n4 separate bookings = 4 × GHS 2 = GHS 8 in fees\n1 group booking = GHS 2 fee – you save GHS 6!';

  @override
  String get docsFeeGroupTip => 'Booking as a group saves you money on fees! Instead of paying the platform fee for each person, you pay just one fee for the entire group booking.';

  @override
  String get docsPaymentRemainingTitle => 'Paying the Remaining 70%';

  @override
  String get docsPaymentRemainingSubtitle => 'Cash or online - your choice';

  @override
  String get docsPaymentRemainingOptionsTitle => 'Two Payment Options';

  @override
  String get docsPaymentRemainingOptionsContent => 'After your service is complete, you have two ways to pay the remaining 70%:';

  @override
  String get docsPaymentCashOption => 'Cash: Pay directly to the shop or worker';

  @override
  String get docsPaymentAppOption => 'Via app: Pay through the app using your saved payment method';

  @override
  String get docsPaymentRemainingTip => 'Both payment methods are equally valid. Choose what\'s most convenient for you at the time of service.';

  @override
  String get docsCancellationTitle => 'Cancellations & Refunds';

  @override
  String get docsCancellationSubtitle => 'What happens if you need to cancel';

  @override
  String get docsCancellationInfoTitle => 'Cancellation Policy';

  @override
  String get docsCancellationInfoContent => 'Understanding what happens when you cancel:';

  @override
  String get docsCancellationUpTo24 => 'Cancel up to 24 hours before: Deposit and fee are non-refundable';

  @override
  String get docsCancellationLessThan24 => 'Cancel less than 24 hours before: Same policy – deposit and fee not refunded';

  @override
  String get docsCancellationReschedule => 'Reschedule instead: Your deposit transfers to the new time (free to reschedule)';

  @override
  String get docsCancellationNoShow => 'No-show: Deposit and fee lost, and may affect your account status';

  @override
  String get docsHowToBookTitle => 'How to Book Services';

  @override
  String get docsHowToBookSubtitle => 'A step-by-step guide to booking your appointments';

  @override
  String get docsHowToBookOverviewTitle => 'Booking at a Glance';

  @override
  String get docsHowToBookOverviewSubtitle => 'The booking process in simple steps';

  @override
  String get docsHowToBookTwoWaysTitle => 'Two Ways to Book';

  @override
  String get docsHowToBookTwoWaysContent => 'You can book in two ways:';

  @override
  String get docsHowToBookTwoWaysWithApp => 'With App Account: Download app, create account, book anytime';

  @override
  String get docsHowToBookTwoWaysGuest => 'As Guest: Use booking link, no app needed, receipt via WhatsApp';

  @override
  String get docsHowToBookStepsTitle => 'Your Booking Journey (With Account)';

  @override
  String get docsHowToBookStepsContent => 'Booking a service takes just a few minutes. Here\'s what you\'ll do:';

  @override
  String get docsHowToBookStep1 => 'Step 1: Find a shop and browse services';

  @override
  String get docsHowToBookStep2 => 'Step 2: Select your services and quantities';

  @override
  String get docsHowToBookStep3 => 'Step 3: Choose your preferred worker (if available)';

  @override
  String get docsHowToBookStep4 => 'Step 4: Pick a date and time';

  @override
  String get docsHowToBookStep5 => 'Step 5: Pay 30% deposit + small fee to confirm';

  @override
  String get docsHowToBookStep6 => 'Step 6: After service, pay remaining 70% in cash or via app';

  @override
  String get docsHowToBookGuestTitle => 'Guest Booking (No App)';

  @override
  String get docsHowToBookGuestContent => 'Don\'t have the app? If a shop shares a booking link with you, follow the same steps above but without needing to create an account. Your confirmation and receipt go to your WhatsApp.';

  @override
  String get docsHowToBookTimeTip => 'The entire process usually takes less than 2 minutes. Your progress is saved as you go, so you can take your time.';

  @override
  String get docsBookingStep1Title => 'Step 1: Find Your Shop & Services';

  @override
  String get docsBookingStep1Subtitle => 'Discover the perfect place for your needs';

  @override
  String get docsBookingFindShopTitle => 'How to find a shop';

  @override
  String get docsBookingFindShopContent => 'You can find shops in several ways:';

  @override
  String get docsBookingFindShopHome => 'Home Screen: Browse recommended shops near you';

  @override
  String get docsBookingFindShopSearch => 'Search: Look for specific shops or services by name';

  @override
  String get docsBookingFindShopCategories => 'Categories: Filter by service type (Haircut, Braiding, Beard, etc.)';

  @override
  String get docsBookingFindShopFavorites => 'Favorites: Quick access to shops you\'ve saved';

  @override
  String get docsBookingBrowseServicesTitle => 'Browsing Services';

  @override
  String get docsBookingBrowseServicesContent => 'Once you select a shop, you\'ll see all their available services. Each service shows:';

  @override
  String get docsBookingServiceName => 'Service name (e.g., Afro Haircut, Box Braids)';

  @override
  String get docsBookingServiceDuration => 'Duration (how long it takes)';

  @override
  String get docsBookingServicePrice => 'Price (cost of the service - this goes to the shop)';

  @override
  String get docsBookingServiceDescription => 'Description (what\'s included)';

  @override
  String get docsBookingServiceWorker => 'Worker requirement (whether you can choose who does it)';

  @override
  String get docsBookingServiceExampleTitle => 'Example';

  @override
  String get docsBookingServiceExampleContent => 'Haircut Service:\n• Name: Afro Haircut\n• Duration: 1 hour\n• Price: GHS 45 (paid to shop)\n• Description: Professional afro haircut with styling\n• Worker: You can choose your preferred barber';

  @override
  String get docsBookingStep2Title => 'Step 2: Select Your Services';

  @override
  String get docsBookingStep2Subtitle => 'Choose what you want and how many people';

  @override
  String get docsBookingSelectServicesTitle => 'Selecting Services';

  @override
  String get docsBookingSelectServicesContent => 'To select a service, simply tap on it. You\'ll see it become highlighted. You can select multiple services at once:';

  @override
  String get docsBookingSelectServicesTap => 'Tap a service to select it';

  @override
  String get docsBookingSelectServicesCheckmark => 'Selected services show a checkmark';

  @override
  String get docsBookingSelectServicesMultiple => 'You can select multiple services (e.g., Haircut + Beard Trim)';

  @override
  String get docsBookingSelectServicesDeselect => 'Tap again to deselect';

  @override
  String get docsBookingGroupBookingTitle => 'Booking for Multiple People';

  @override
  String get docsBookingGroupBookingContent => 'If you\'re booking for a group (like yourself and your children), you can increase the quantity:';

  @override
  String get docsBookingGroupBookingQuantity => 'After selecting a service, you\'ll see a + and - button';

  @override
  String get docsBookingGroupBookingIncrease => 'Tap + to increase the number of people';

  @override
  String get docsBookingGroupBookingPrice => 'The price updates automatically';

  @override
  String get docsBookingGroupBookingLimit => 'Maximum quantity is shown (some services have limits)';

  @override
  String get docsBookingGroupExampleTitle => 'Example: Family Booking';

  @override
  String get docsBookingGroupExampleContent => 'Dad wants haircuts for himself and his two sons:\n• Select \"Haircut\" service\n• Tap + until quantity shows 3\n• Total price shows 3 × GHS 45 = GHS 135 (for the shop)\n• You\'ll choose workers for each person later';

  @override
  String get docsBookingQuantityTip => 'The quantity feature is perfect for families, groups of friends, or anyone booking for multiple people at once.';

  @override
  String get docsGroupBookingsTitle => 'Group Bookings';

  @override
  String get docsGroupBookingsSubtitle => 'How to book services for yourself and others';

  @override
  String get docsGroupIntroTitle => 'What Are Group Bookings?';

  @override
  String get docsGroupIntroSubtitle => 'Booking for family, friends, or groups made simple';

  @override
  String get docsGroupExplainedTitle => 'Booking for Multiple People';

  @override
  String get docsGroupExplainedContent => 'Group bookings allow you to book services for more than one person at a time. This is perfect for:';

  @override
  String get docsGroupExplainedFamilies => 'Families: Parents booking haircuts for themselves and their children';

  @override
  String get docsGroupExplainedFriends => 'Friends: Group of friends getting services together';

  @override
  String get docsGroupExplainedEvents => 'Events: Bridal parties, birthdays, or special occasions';

  @override
  String get docsGroupExplainedColleagues => 'Colleagues: Team building or work outings';

  @override
  String get docsGroupRealExampleTitle => 'Real-Life Example';

  @override
  String get docsGroupRealExampleContent => 'The Mensah Family needs haircuts:\n• Father: Wants a fade haircut\n• Mother: Wants a trim\n• Son (10): Wants a kids haircut\n• Daughter (8): Wants braids\n\nInstead of making 4 separate bookings, they can book everything together in one go!';

  @override
  String get docsGroupBenefitsTitle => 'Benefits of Group Booking';

  @override
  String get docsGroupBenefitsContent => 'Booking as a group gives you:';

  @override
  String get docsGroupBenefitsTransaction => 'One transaction: Pay deposits for everyone at once';

  @override
  String get docsGroupBenefitsTiming => 'Coordinated timing: Everyone gets served around the same time';

  @override
  String get docsGroupBenefitsWorkers => 'Different workers: Each person can choose their preferred worker';

  @override
  String get docsGroupBenefitsManagement => 'Simplified management: View and manage all bookings together';

  @override
  String get docsGroupBenefitsPlanning => 'Better planning: Shop can prepare for your group';

  @override
  String get docsGroupTip => 'Group bookings are perfect for families! You can book for yourself and your children in one go, choosing different workers for each person. No account needed? Use a booking link shared by the shop!';

  @override
  String get docsGroupHowTitle => 'How to Make a Group Booking';

  @override
  String get docsGroupHowSubtitle => 'Step-by-step guide';

  @override
  String get docsGroupStep1Title => 'Step 1: Select Your Service';

  @override
  String get docsGroupStep1Content => 'Start by finding a shop and selecting the service you want. For example, tap on \"Haircut\".';

  @override
  String get docsGroupStep2Title => 'Step 2: Choose the Quantity';

  @override
  String get docsGroupStep2Content => 'After selecting a service, you\'ll see + and - buttons. Use these to set how many people need this service:';

  @override
  String get docsGroupStep2Plus => 'Tap + to increase the number';

  @override
  String get docsGroupStep2Minus => 'Tap - to decrease';

  @override
  String get docsGroupStep2Price => 'The price updates automatically';

  @override
  String get docsGroupStep2Max => 'You cannot exceed the maximum quantity shown';

  @override
  String get docsGroupStep2ExampleTitle => 'Example';

  @override
  String get docsGroupStep2ExampleContent => 'For a family of 3 needing haircuts:\n• Select \"Haircut\" service\n• Tap + twice (or until quantity shows 3)\n• Total price shows: 3 × GHS 45 = GHS 135';

  @override
  String get docsGroupStep3Title => 'Step 3: Repeat for Each Service';

  @override
  String get docsGroupStep3Content => 'If your group needs different services (e.g., some want haircuts, others want braids), select each service and set the quantity for each:';

  @override
  String get docsGroupStep3Haircut => 'Select \"Haircut\" → set quantity 2';

  @override
  String get docsGroupStep3Braids => 'Select \"Braids\" → set quantity 1';

  @override
  String get docsGroupStep3Track => 'The system keeps track of all selections';

  @override
  String get docsGroupStep3ExampleTitle => 'Example: Mixed Services';

  @override
  String get docsGroupStep3ExampleContent => 'Family of 4 with different needs:\n• Dad: Haircut (quantity 1)\n• Mom: Trim (quantity 1)\n• Son: Kids Haircut (quantity 1)\n• Daughter: Braids (quantity 1)\n\nTotal: 4 services, but you booked them all in one go!';

  @override
  String get docsGroupStep4Title => 'Step 4: Choose Workers for Each Person';

  @override
  String get docsGroupStep4Content => 'For services that let you choose workers, you\'ll see a list of people. Tap on each person to assign their worker:';

  @override
  String get docsGroupStep4Person1 => 'Person 1: Choose John (fade specialist)';

  @override
  String get docsGroupStep4Person2 => 'Person 2: Choose Sarah (braiding expert)';

  @override
  String get docsGroupStep4Person3 => 'Person 3: Choose Michael (kids cuts)';

  @override
  String get docsGroupStep4Person4 => 'Person 4: Choose John (same worker for multiple people)';

  @override
  String get docsGroupStep4ExampleTitle => 'Example: Different Workers for Different People';

  @override
  String get docsGroupStep4ExampleContent => 'Family of 3 booking haircuts:\n• Person 1 (Dad): Choose John (fade specialist)\n• Person 2 (Son): Choose Michael (great with kids)\n• Person 3 (Daughter): Choose Sarah (braiding expert)\n\nAll three will be served during your appointment block.';

  @override
  String get docsGroupStep5Title => 'Step 5: Pick Your Time';

  @override
  String get docsGroupStep5Content => 'When you select a date and time, the system will show slots that can accommodate ALL people in your group:';

  @override
  String get docsGroupStep5Regular => 'Regular View: Shows slots for each service separately';

  @override
  String get docsGroupStep5Combined => 'Combined View: Shows only slots where everyone can be served together';

  @override
  String get docsGroupStep5Duration => 'Duration: The time shown includes all services for all people';

  @override
  String get docsGroupStep5ExampleTitle => 'Example: Time Calculation';

  @override
  String get docsGroupStep5ExampleContent => 'Family booking:\n• Haircut (45 min) × 2 people = 90 min\n• Braids (2 hours) × 1 person = 120 min\n• Buffer time between services = 15 min\n• Total appointment time: 3 hours 45 min\n\nThe system handles all this automatically!';

  @override
  String get docsGroupStep6Title => 'Step 6: Payment';

  @override
  String get docsGroupStep6Content => 'For group bookings, you pay:';

  @override
  String get docsGroupStep6Deposit => '30% deposit: Calculated on the TOTAL cost of all services';

  @override
  String get docsGroupStep6Fee => 'Platform fee: Small fixed fee (e.g., GHS 2) - charged ONCE for entire group';

  @override
  String get docsGroupStep6Remaining => 'Remaining 70%: Paid after all services are complete';

  @override
  String get docsGroupStep6Options => 'Payment options: Cash, card, mobile money, or app payment';

  @override
  String get docsGroupStep6ExampleTitle => 'Payment Example';

  @override
  String get docsGroupStep6ExampleContent => 'Family booking total: GHS 400\n• Deposit at booking: GHS 120 (30% of GHS 400)\n• Platform fee: GHS 2 (charged once for entire group)\n• Total to pay now: GHS 122\n• Remaining after service: GHS 280\n• Payment after: Cash to worker/shop OR via app (your choice)';

  @override
  String get docsGroupPaymentFlexibility => 'Multiple Payment Options';

  @override
  String get docsGroupPaymentFlexibilityContent => 'For the remaining 70%, you have options:';

  @override
  String get docsGroupPaymentFlexibilityAllCash => 'All Cash: Everyone pays in cash when service is done';

  @override
  String get docsGroupPaymentFlexibilitySplit => 'Split Payments: Some people pay cash, others pay via app';

  @override
  String get docsGroupPaymentFlexibilityMixed => 'Mix of Cash & App: Pay part in cash, part via app';

  @override
  String get docsGroupPaymentFlexibilityIndividual => 'Individual App Payments: Each person pays via app';

  @override
  String get docsGroupPaymentFlexibilityTip => 'Choose what works best for your group!';

  @override
  String get docsGroupImportant => 'The deposit and platform fee are calculated on the TOTAL group booking, not per person. You pay once for the whole group.';

  @override
  String get docsCreateShopTitle => 'Create Your Shop';

  @override
  String get docsCreateShopSubtitle => 'Set up your business';

  @override
  String get docsShopOverviewTitle => 'Getting Started with Your Shop';

  @override
  String get docsShopOverviewSubtitle => 'Learn the basics of creating your business profile';

  @override
  String get docsWelcomeIntroTitle => 'Welcome to Your Shop Dashboard';

  @override
  String get docsWelcomeIntroContent => 'Creating a shop on Aura In takes just a few minutes. You\'ll add your business information, set your services and working hours, and you\'re ready to accept bookings from customers.';

  @override
  String get docsSetupStepsTitle => 'What You\'ll Set Up';

  @override
  String get docsSetupStepsContent => 'Here\'s what you\'ll do when creating your shop:';

  @override
  String get docsSetupStepsShopName => 'Add your shop name and logo';

  @override
  String get docsSetupStepsDescription => 'Write a brief description of your business';

  @override
  String get docsSetupStepsType => 'Choose your shop type (salon, barber, spa, etc.)';

  @override
  String get docsSetupStepsLocation => 'Set your location and service address';

  @override
  String get docsSetupStepsHours => 'Add your working hours';

  @override
  String get docsSetupStepsServices => 'Create services you offer with pricing';

  @override
  String get docsSetupStepsContact => 'Add contact information';

  @override
  String get docsSetupStepsPhotos => 'Upload photos and documents';

  @override
  String get docsSetupTip => 'Your work is saved automatically as you fill in the form. You can come back anytime to continue editing or publish when ready.';

  @override
  String get docsBasicInfoTitle => 'Basic Shop Information';

  @override
  String get docsBasicInfoSubtitle => 'Tell customers who you are';

  @override
  String get docsLogoTitle => 'Add Your Shop Logo';

  @override
  String get docsLogoContent => 'Your logo is the first thing customers see. It should clearly represent your business. Use a square image (e.g., 500x500 pixels) for best results.';

  @override
  String get docsShopNameTitle => 'Shop Name';

  @override
  String get docsShopNameContent => 'Enter your business name exactly as you want customers to see it. Be clear and professional. Example: \"Marie\'s Hair Studio\" or \"City Barbershop\"';

  @override
  String get docsShopTypeTitle => 'Choose Your Shop Type';

  @override
  String get docsShopTypeContent => 'Select the type of business you run. This helps customers find you in search. Available types include:';

  @override
  String get docsShopTypeSalon => 'Hair Salon - for haircuts, coloring, styling';

  @override
  String get docsShopTypeBarber => 'Barber Shop - for men\'s haircuts and grooming';

  @override
  String get docsShopTypeSpa => 'Spa - for massages, facials, wellness services';

  @override
  String get docsShopTypeBeauty => 'Beauty Services - makeup, nails, and other beauty treatments';

  @override
  String get docsShopTypeOther => 'Other Services - for businesses not listed above';

  @override
  String get docsDescriptionTitle => 'Shop Description';

  @override
  String get docsDescriptionContent => 'Write a short description about your shop (100-200 words). Tell customers what makes you special. Example: \"We specialize in natural hair care and modern styling for all hair types. Family-friendly environment with professional stylists.\"';

  @override
  String get docsTermsTitle => 'Terms & Conditions';

  @override
  String get docsTermsContent => 'Add any important rules customers should know. Examples: cancellation policy, age restrictions, deposit requirements, dress code, or health restrictions.';

  @override
  String get docsLocationTitle => 'Location & Hours';

  @override
  String get docsLocationSubtitle => 'Where customers can find you and when you work';

  @override
  String get docsLocationIntroTitle => 'Set Your Location';

  @override
  String get docsLocationIntroContent => 'Customers need to know where to find you. You can either:';

  @override
  String get docsLocationPin => 'Pin your location on the map (drag the marker)';

  @override
  String get docsLocationSearch => 'Search for your address in the search box';

  @override
  String get docsLocationManual => 'Enter your street address manually';

  @override
  String get docsLocationAccuracy => 'Make sure your location is accurate. Customers use it to find you and calculate travel time.';

  @override
  String get docsWorkingHoursTitle => 'Set Your Working Hours';

  @override
  String get docsWorkingHoursContent => 'Customers can only book times when you\'re open. Set your hours for each day of the week.';

  @override
  String get docsHoursExampleTitle => 'Example Schedule';

  @override
  String get docsHoursExampleContent => 'Monday - Friday: 9:00 AM to 6:00 PM\nSaturday: 10:00 AM to 4:00 PM\nSunday: Closed';

  @override
  String get docsHoursTip => 'You can set different hours for different days, or mark any day as closed when you\'re not working.';

  @override
  String get docsServicesTitle => 'Services & Pricing';

  @override
  String get docsServicesSubtitle => 'Tell customers what you offer and how much it costs';

  @override
  String get docsServicesIntroTitle => 'Add Your Services';

  @override
  String get docsServicesIntroContent => 'Each service is something customers can book and pay for. Examples: \"Haircut\", \"Hair Color\", \"Massage\", \"Facial Treatment\".';

  @override
  String get docsServiceDetailsTitle => 'For Each Service, Add:';

  @override
  String get docsServiceDetailsContent => 'When you create a service, you need to provide:';

  @override
  String get docsServiceName => 'Service name - what you\'re offering (e.g., \"Haircut\")';

  @override
  String get docsServiceDescription => 'Description - brief details about what\'s included';

  @override
  String get docsServicePrice => 'Price - how much the service costs';

  @override
  String get docsServiceDuration => 'Duration - how long it takes (e.g., 30 minutes, 1 hour)';

  @override
  String get docsServiceCategory => 'Category - what type of service it is';

  @override
  String get docsPricingTipTitle => 'Pricing Tip';

  @override
  String get docsPricingTipContent => 'Be clear with your prices. You can offer different service tiers (e.g., \"Basic Haircut\" vs \"Premium Haircut\") at different prices.';

  @override
  String get docsDurationImportant => 'Set the duration accurately. Customers book based on this time, and staff need to know how long to reserve.';

  @override
  String get docsTeamTitle => 'Manage Your Team';

  @override
  String get docsTeamSubtitle => 'Add staff members and assign them to services';

  @override
  String get docsWorkersIntroTitle => 'Add Your Staff';

  @override
  String get docsWorkersIntroContent => 'If you have team members working at your shop, you can add them here. This helps you manage who is available for bookings.';

  @override
  String get docsAddWorkerTitle => 'How to Add a Staff Member';

  @override
  String get docsAddWorkerContent => 'When you add a worker, you need:';

  @override
  String get docsFreelancerTitle => 'Become a Freelancer';

  @override
  String get docsFreelancerSubtitle => 'Work independently';

  @override
  String get docsFreelancerOverviewTitle => 'Getting Started as a Freelancer';

  @override
  String get docsFreelancerOverviewSubtitle => 'Learn how to set up your profile and start taking clients';

  @override
  String get docsFreelancerWelcomeTitle => 'Welcome to Freelancing';

  @override
  String get docsFreelancerWelcomeContent => 'As a freelancer on Aura In, you offer services directly to customers in your area. Unlike a traditional shop, you work from your own location and can travel to meet clients. Set up your profile in just a few minutes and start accepting bookings.';

  @override
  String get docsFreelancerVsShopTitle => 'Freelancer vs Shop: What\'s the Difference?';

  @override
  String get docsFreelancerVsShopContent => 'Here\'s how freelancing works:';

  @override
  String get docsFreelancerIndependent => 'You work independently - no fixed storefront required';

  @override
  String get docsFreelancerTravel => 'You can travel to clients within your chosen radius';

  @override
  String get docsFreelancerHours => 'You set your own hours and availability';

  @override
  String get docsFreelancerManage => 'You manage your own schedule and clients';

  @override
  String get docsFreelancerBooking => 'Customers book you directly for services';

  @override
  String get docsFreelancerRequirementsTitle => 'What You\'ll Need';

  @override
  String get docsFreelancerRequirementsContent => 'To start as a freelancer, you need: your name, a profession type (hairdresser, massage therapist, etc.), location, travel radius, services, and your working hours. A professional photo helps customers trust you.';

  @override
  String get docsProfileSetupTitle => 'Create Your Profile';

  @override
  String get docsProfileSetupSubtitle => 'Tell customers who you are';

  @override
  String get docsProfilePhotoTitle => 'Add Your Profile Photo';

  @override
  String get docsProfilePhotoContent => 'A professional headshot or portrait builds trust with customers. Use a clear, well-lit photo of yourself. Customers want to know who they\'re booking with.';

  @override
  String get docsYourNameTitle => 'Your Name';

  @override
  String get docsYourNameContent => 'Enter your full name exactly as you want customers to see it. Be professional and clear.';

  @override
  String get docsProfessionTypeTitle => 'Choose Your Profession';

  @override
  String get docsProfessionTypeContent => 'Select what you do. Examples: Hairdresser, Massage Therapist, Makeup Artist, Barber, Esthetician, or other specialized services.';

  @override
  String get docsBioDescriptionTitle => 'Write Your Bio';

  @override
  String get docsBioDescriptionContent => 'Write a short description about yourself and your experience (50-150 words). Tell customers what makes you unique. Example: \"I specialize in natural hair care with 5 years of experience. Certified in color and styling.\"';

  @override
  String get docsTermsGuidelinesTitle => 'Add Your Guidelines';

  @override
  String get docsTermsGuidelinesContent => 'Share any important rules or policies. Examples: age restrictions, cancellation policy, health requirements, or preparation instructions.';

  @override
  String get docsServiceAreaTitle => 'Set Your Service Area';

  @override
  String get docsServiceAreaSubtitle => 'Define where you work';

  @override
  String get docsBaseLocationTitle => 'Set Your Base Location';

  @override
  String get docsBaseLocationContent => 'This is where you normally work from. Customers within your travel radius can book you. You can either pin on the map or search for your address.';

  @override
  String get docsTravelRadiusTitle => 'Travel Radius';

  @override
  String get docsTravelRadiusContent => 'How far are you willing to travel to meet clients? Set this in kilometers. Example: \"5 km radius\" means clients up to 5 km from your location can book you.';

  @override
  String get docsMobileVsFixedTitle => 'Mobile or Fixed Location?';

  @override
  String get docsMobileVsFixedContent => 'Choose whether you travel to clients or meet them at one location. If you\'re mobile, customers can request you at their home or office.';

  @override
  String get docsServiceAddressTip => 'Customers will see your travel radius when searching. Be accurate so they know if you can serve their area.';

  @override
  String get docsToolsSetupTitle => 'List Your Tools & Equipment';

  @override
  String get docsToolsSetupSubtitle => 'Show customers what you bring';

  @override
  String get docsToolsIntroTitle => 'What Are Tools?';

  @override
  String get docsToolsIntroContent => 'Tools are the equipment or skills you have. They help customers understand what you can do and what to expect.';

  @override
  String get docsToolExamplesTitle => 'Example Tools';

  @override
  String get docsToolExamplesContent => 'For different professions:';

  @override
  String get docsToolHairdresser => 'Hairdresser: Blow dryer, flat iron, curling iron, scissors';

  @override
  String get docsToolMassage => 'Massage Therapist: Massage table, hot stones, aromatherapy oils';

  @override
  String get docsToolMakeup => 'Makeup Artist: Makeup brushes, airbrush, LED light';

  @override
  String get docsToolBarber => 'Barber: Electric clippers, straight razor, styling cream';

  @override
  String get docsToolSelectionTitle => 'Selecting Tools';

  @override
  String get docsToolSelectionContent => 'Choose all the tools and equipment you use professionally. Customers want to know you have the right equipment for their service.';

  @override
  String get docsServicesSetupTitle => 'Services & Pricing';

  @override
  String get docsServicesSetupSubtitle => 'Tell customers what you offer';

  @override
  String get docsServiceBasicsTitle => 'Add Your Services';

  @override
  String get docsServiceBasicsContent => 'Each service is something customers can book. Examples: \"Haircut\", \"Full Body Massage\", \"Makeup Application\".';

  @override
  String get docsServiceInfoTitle => 'For Each Service, Add:';

  @override
  String get docsServiceInfoContent => 'You need:';

  @override
  String get docsServiceInfoName => 'Service name - what you\'re offering';

  @override
  String get docsServiceInfoDescription => 'Description - what it includes';

  @override
  String get docsServiceInfoPrice => 'Price - how much it costs';

  @override
  String get docsServiceInfoDuration => 'Duration - how long it takes (30 min, 1 hour, etc.)';

  @override
  String get docsPricingStrategyTitle => 'Pricing Tips';

  @override
  String get docsPricingStrategyContent => 'Research what others charge for similar services in your area. Price competitively but fairly for your experience level.';

  @override
  String get docsDurationImportanceFreelancer => 'Set duration accurately. This is how long you block out for each booking. Customers rely on this time.';

  @override
  String get docsHoursSetupTitle => 'Set Your Availability';

  @override
  String get docsHoursSetupSubtitle => 'When you\'re available to work';

  @override
  String get docsHoursIntroTitle => 'Working Hours';

  @override
  String get docsHoursIntroContent => 'Customers can only book during times you mark as available. Set your hours for each day of the week.';

  @override
  String get docsFlexibleHoursTitle => 'Be Flexible or Strict?';

  @override
  String get docsFlexibleHoursContent => 'You decide. If you want consistent hours, set them. If you prefer flexibility, you can adjust daily as needed.';

  @override
  String get docsBlockTimeTip => 'When a customer books you, that time is blocked on your calendar. Set hours wisely to avoid conflicts.';

  @override
  String get docsContactCredentialsTitle => 'Contact Info & Credentials';

  @override
  String get docsContactCredentialsSubtitle => 'Help customers reach you and build trust';

  @override
  String get docsCreateProductTitle => 'Sell Products Online';

  @override
  String get docsCreateProductSubtitle => 'List items for sale and reach customers in your area';

  @override
  String get docsProductOverviewTitle => 'Getting Started Selling Products';

  @override
  String get docsProductOverviewSubtitle => 'Learn how to list and sell items';

  @override
  String get docsProductWelcomeTitle => 'Welcome to Product Selling';

  @override
  String get docsProductWelcomeContent => 'Sell physical products directly to customers in your area. From handmade items to retail goods, you can reach customers looking for what you offer.';

  @override
  String get docsPhoneRequirementTitle => 'You Need a Verified Phone Number';

  @override
  String get docsPhoneRequirementContent => 'Before you can start selling products, you must verify your phone number. This is for customer communication and to validate your identity.';

  @override
  String get docsAddPhoneNumberTitle => 'How to Add Your Phone Number';

  @override
  String get docsAddPhoneNumberContent => 'Go to your profile settings and add your phone number. You\'ll receive a verification code via SMS to confirm it\'s really your number. This takes just a minute.';

  @override
  String get docsWhyPhoneVerifiedTitle => 'Why Phone Verification?';

  @override
  String get docsWhyPhoneVerifiedContent => 'A verified phone number builds customer trust and allows us to contact you if there are issues. It also helps prevent fraud.';

  @override
  String get docsPhoneImportant => 'You cannot list products until you have a verified phone number. This is required for all sellers.';

  @override
  String get docsProductBasicsTitle => 'Basic Product Information';

  @override
  String get docsProductBasicsSubtitle => 'What to tell customers about your product';

  @override
  String get docsProductNameTitle => 'Product Name';

  @override
  String get docsProductNameContent => 'Enter your product name clearly. Customers search by product name, so be specific. Example: \"Handmade Leather Wallet - Brown\" instead of just \"Wallet\".';

  @override
  String get docsProductDescriptionTitle => 'Product Description';

  @override
  String get docsProductDescriptionContent => 'Write a detailed description. Tell customers what it is, what it\'s made of, how to use it, and why it\'s good. Be honest about condition (new, used, refurbished).';

  @override
  String get docsCategorySelectionTitle => 'Choose a Category';

  @override
  String get docsCategorySelectionContent => 'Select the right category. Customers browse by category to find items, so accuracy matters. Pick the most specific category available.';

  @override
  String get docsProductConditionTitle => 'Product Condition';

  @override
  String get docsProductConditionContent => 'Be clear about condition: New (never used), Like New (used once), Good (light wear), Fair (visible wear), or As-Is. Honesty builds trust.';

  @override
  String get docsPricingStockTitle => 'Price & Availability';

  @override
  String get docsPricingStockSubtitle => 'Set your price and manage inventory';

  @override
  String get docsPricingTitle => 'Set Your Price';

  @override
  String get docsPricingContent => 'Set a fair price based on condition, market value, and local demand. Customers can see similar items, so competitive pricing helps.';

  @override
  String get docsCurrencyTitle => 'Currency';

  @override
  String get docsCurrencyContent => 'Prices are shown in your shop\'s currency. Make sure your shop currency is set correctly before adding products.';

  @override
  String get docsStockQuantityTitle => 'Stock Quantity';

  @override
  String get docsStockQuantityContent => 'Enter how many items you have. When stock runs out, the product shows as unavailable. Update this as you sell items.';

  @override
  String get docsStockTip => 'Keep stock accurate. Customers get frustrated if they order something out of stock. Update regularly as you sell.';

  @override
  String get docsProductPhotosTitle => 'Product Photos';

  @override
  String get docsProductPhotosSubtitle => 'Show customers what they\'re buying';

  @override
  String get docsPhotosImportanceTitle => 'Photos Matter Most';

  @override
  String get docsPhotosImportanceContent => 'Good photos are critical. Customers decide whether to buy based on photos. Poor photos = fewer sales.';

  @override
  String get docsWhatPhotosTitle => 'What to Photograph';

  @override
  String get docsWhatPhotosContent => 'Take photos that show the real product:';

  @override
  String get docsPhotoFull => 'Full product from multiple angles';

  @override
  String get docsPhotoCloseups => 'Close-ups of details and quality';

  @override
  String get docsPhotoCondition => 'Photos showing condition (if used)';

  @override
  String get docsPhotoScale => 'Photos next to something for scale (like a coin or hand)';

  @override
  String get docsPhotoDamage => 'Photos of any damage or wear (honesty builds trust)';

  @override
  String get docsPhotoTipsTitle => 'Photo Quality Tips';

  @override
  String get docsPhotoTipsContent => 'Use natural light. Take photos on a clean background. Show colors accurately. Don\'t use filters that change how the product looks.';

  @override
  String get docsPhotoCountTitle => 'How Many Photos?';

  @override
  String get docsPhotoCountContent => 'Upload at least 3 clear photos. More photos help customers understand the product better. Limit to 10 photos per product.';

  @override
  String get docsToolsTitle => 'Business Tools';

  @override
  String get docsToolsSubtitle => 'Powerful features to automate, promote, and manage your business';

  @override
  String get docsToolsOverviewTitle => 'Tools Overview';

  @override
  String get docsToolsOverviewSubtitle => 'What each tool does and how to use it';

  @override
  String get docsToolsWelcomeTitle => 'Welcome to Business Tools';

  @override
  String get docsToolsWelcomeContent => 'The Tools tab has 8 powerful features to help you automate, promote, and manage your business more effectively. Each tool solves a specific business problem.';

  @override
  String get docsToolsListTitle => 'Available Tools';

  @override
  String get docsToolsListContent => 'You have access to these 8 tools:';

  @override
  String get docsToolsReminders => 'Automated Reminders - Send reminders to customers';

  @override
  String get docsToolsPromotions => 'Promotions Manager - Create and manage discounts';

  @override
  String get docsToolsExport => 'Export Reports - Download your business data';

  @override
  String get docsToolsPayment => 'Payment Settings - Configure how you receive payments';

  @override
  String get docsToolsHours => 'Business Hours - Set your working schedule';

  @override
  String get docsToolsServices => 'Service Management - Add and edit your services';

  @override
  String get docsToolsLoyalty => 'Loyalty Program - Reward repeat customers';

  @override
  String get docsToolsBroadcasts => 'Broadcasts - Send messages to your customers';

  @override
  String get docsRemindersTitle => '1. Automated Reminders';

  @override
  String get docsRemindersSubtitle => 'Send automatic reminders to customers';

  @override
  String get docsReminderPurposeTitle => 'What It Does';

  @override
  String get docsReminderPurposeContent => 'Automatically send reminder messages to customers before their bookings. Reduces no-shows and keeps customers informed.';

  @override
  String get docsReminderBenefitsTitle => 'Benefits';

  @override
  String get docsReminderBenefitsContent => 'Automated reminders help you:';

  @override
  String get docsReminderBenefitNoShow => 'Reduce no-shows - customers are less likely to forget';

  @override
  String get docsReminderBenefitExperience => 'Improve customer experience - they know when to arrive';

  @override
  String get docsReminderBenefitTime => 'Save time - no need to manually call or message';

  @override
  String get docsReminderBenefitReliability => 'Increase reliability - reminders go out automatically';

  @override
  String get docsReminderSetupTitle => 'How to Set It Up';

  @override
  String get docsReminderSetupContent => 'Click \"Configure Automated Reminders\" to set timing: send reminders 24 hours before, 2 hours before, or on the morning of the appointment.';

  @override
  String get docsReminderImpact => 'Shops using automated reminders see 20-30% fewer no-shows. This directly impacts your revenue.';

  @override
  String get docsPromosTitle => '2. Promotions Manager';

  @override
  String get docsPromosSubtitle => 'Create special offers and discounts';

  @override
  String get docsPromosPurposeTitle => 'What It Does';

  @override
  String get docsPromosPurposeContent => 'Create time-limited promotions and discounts. Offer percentage off, fixed amount off, or free add-ons to attract more customers.';

  @override
  String get docsPromosExamplesTitle => 'Promotion Ideas';

  @override
  String get docsPromosExamplesContent => 'You can create promotions like:';

  @override
  String get docsPromosExample1 => '20% off haircuts on Mondays';

  @override
  String get docsPromosExample2 => 'Free massage oil with any massage booking';

  @override
  String get docsPromosExample3 => '50 off a full-service package';

  @override
  String get docsPromosExample4 => 'First-time customer: 30% discount';

  @override
  String get docsPromosExample5 => 'Loyalty bonus: 5th service is half price';

  @override
  String get docsPromosStrategyTitle => 'Promotion Strategy';

  @override
  String get docsPromosStrategyContent => 'Use promotions during slow periods to boost bookings. Track which promotions work best through your analytics.';

  @override
  String get docsExportTitle => '3. Export Reports';

  @override
  String get docsExportSubtitle => 'Download your data for analysis';

  @override
  String get docsExportPurposeTitle => 'What It Does';

  @override
  String get docsExportPurposeContent => 'Download detailed reports of your business data in spreadsheet format. Analyze bookings, revenue, customers, and more.';

  @override
  String get docsExportTypesTitle => 'Available Reports';

  @override
  String get docsExportTypesContent => 'You can export:';

  @override
  String get docsExportBookings => 'Booking reports - all bookings with details';

  @override
  String get docsExportRevenue => 'Revenue reports - earnings by date range';

  @override
  String get docsExportCustomers => 'Customer reports - your client list';

  @override
  String get docsExportServices => 'Service reports - performance by service';

  @override
  String get docsExportWorkers => 'Worker reports - staff performance metrics';

  @override
  String get docsExportUsesTitle => 'Why Export Data?';

  @override
  String get docsExportUsesContent => 'Use exported data in Excel for custom analysis, record-keeping, tax purposes, or sharing with accountant.';

  @override
  String get docsTimeSlotsTitle => 'Time Slots Explained';

  @override
  String get docsTimeSlotsSubtitle => 'Understanding how booking times work';

  @override
  String get docsTimeSlotsOverviewTitle => 'What Are Time Slots?';

  @override
  String get docsTimeSlotsOverviewSubtitle => 'Learn how the scheduling system works';

  @override
  String get docsTimeSlotsWelcomeTitle => 'Welcome to Time Slots';

  @override
  String get docsTimeSlotsWelcomeContent => 'Time slots are the available times when customers can book your services. Understanding how they work helps you manage your schedule efficiently.';

  @override
  String get docsTimeSlotsBasicsTitle => 'Time Slot Basics';

  @override
  String get docsTimeSlotsBasicsContent => 'Here\'s how time slots work:';

  @override
  String get docsTimeSlotsPoint1 => 'Each service has a duration (how long it takes)';

  @override
  String get docsTimeSlotsPoint2 => 'You set your available hours (when you work)';

  @override
  String get docsTimeSlotsPoint3 => 'The system creates time slots based on service duration';

  @override
  String get docsTimeSlotsPoint4 => 'Customers can only book available slots';

  @override
  String get docsTimeSlotsExampleTitle => 'Example: Creating Time Slots';

  @override
  String get docsTimeSlotsExampleContent => 'If you offer a 30-minute haircut and work 9 AM to 5 PM:\n• 9:00 AM - 9:30 AM (Slot 1)\n• 9:30 AM - 10:00 AM (Slot 2)\n• 10:00 AM - 10:30 AM (Slot 3)\n...and so on throughout the day';

  @override
  String get docsTimeSlotsOverlapTitle => 'What If Services Overlap?';

  @override
  String get docsTimeSlotsOverlapContent => 'If you have multiple staff, each person has their own schedule. If you work alone, only one customer can book at a time — the system blocks conflicting times automatically.';

  @override
  String get docsTimeSlotsGapTitle => 'Setting Gaps Between Services';

  @override
  String get docsTimeSlotsGapContent => 'You can set buffer time between bookings. Example: 15-minute gap after each haircut for cleanup. This reduces the available slots but gives you breathing room.';

  @override
  String get docsTimeSlotsGroupTitle => 'Group Bookings and Time Slots';

  @override
  String get docsTimeSlotsGroupContent => 'For group bookings, the system finds times that work for ALL people in the group. This makes it harder to find available slots, but ensures everyone gets served together.';

  @override
  String get docsTimeSlotsBlockingTitle => 'Blocking Time';

  @override
  String get docsTimeSlotsBlockingContent => 'You can manually block time for lunch, breaks, or personal appointments. Blocked time won\'t show as available to customers.';

  @override
  String get docsTimeSlotsUtilizationTitle => 'Maximizing Your Time Slots';

  @override
  String get docsTimeSlotsUtilizationContent => 'Tips to use your slots efficiently:\n• Match service duration to reality (don\'t underestimate)\n• Set realistic gaps between services\n• Use buffer time strategically\n• Review and adjust based on customer feedback';

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
}
