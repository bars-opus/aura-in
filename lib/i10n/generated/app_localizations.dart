import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Nano Embryo'**
  String get appName;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Your innovative app'**
  String get appDescription;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get commonLogin;

  /// No description provided for @commonLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get commonLogout;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get commonAccept;

  /// No description provided for @commonReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get commonReject;

  /// No description provided for @introGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get introGetStarted;

  /// No description provided for @actionsBlock.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get actionsBlock;

  /// No description provided for @actionsReport.
  ///
  /// In en, this message translates to:
  /// **'Report user'**
  String get actionsReport;

  /// No description provided for @actionsSend.
  ///
  /// In en, this message translates to:
  /// **'Send to chat'**
  String get actionsSend;

  /// No description provided for @actionsShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionsShare;

  /// No description provided for @actionsCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get actionsCopy;

  /// No description provided for @appInfoVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get appInfoVersion;

  /// No description provided for @appInfoReleased.
  ///
  /// In en, this message translates to:
  /// **'Released'**
  String get appInfoReleased;

  /// No description provided for @appInfoPackageName.
  ///
  /// In en, this message translates to:
  /// **'Package Name'**
  String get appInfoPackageName;

  /// No description provided for @appInfoDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer Name'**
  String get appInfoDeveloper;

  /// No description provided for @appInfoSupportEmail.
  ///
  /// In en, this message translates to:
  /// **'Support Email'**
  String get appInfoSupportEmail;

  /// No description provided for @appInfoTechnicalDetails.
  ///
  /// In en, this message translates to:
  /// **'Technical Details'**
  String get appInfoTechnicalDetails;

  /// No description provided for @appInfoBundleID.
  ///
  /// In en, this message translates to:
  /// **'Bundle ID'**
  String get appInfoBundleID;

  /// No description provided for @appInfoBuildVersion.
  ///
  /// In en, this message translates to:
  /// **'Build Version'**
  String get appInfoBuildVersion;

  /// No description provided for @appInfoBuildNumber.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get appInfoBuildNumber;

  /// No description provided for @appInfoReleaseDate.
  ///
  /// In en, this message translates to:
  /// **'Release Date'**
  String get appInfoReleaseDate;

  /// No description provided for @appInfoAppSize.
  ///
  /// In en, this message translates to:
  /// **'App Size'**
  String get appInfoAppSize;

  /// App overview description with dynamic app name
  ///
  /// In en, this message translates to:
  /// **'{appName} is a modern mobile application built with robust security and functionality, designed to provide an exceptional user experience with clean architecture and performance optimization.'**
  String appInfoOverview(String appName);

  /// Intro screen title with app name placeholder
  ///
  /// In en, this message translates to:
  /// **'Welcome to {appName}'**
  String introTitle(String appName);

  /// No description provided for @introFeature1Title.
  ///
  /// In en, this message translates to:
  /// **'See Your Progress'**
  String get introFeature1Title;

  /// No description provided for @introFeature1Description.
  ///
  /// In en, this message translates to:
  /// **'Track your development milestones with detailed analytics and insights'**
  String get introFeature1Description;

  /// No description provided for @introFeature2Title.
  ///
  /// In en, this message translates to:
  /// **'Explore Templates'**
  String get introFeature2Title;

  /// No description provided for @introFeature2Description.
  ///
  /// In en, this message translates to:
  /// **'Discover pre-built components and screens for rapid development'**
  String get introFeature2Description;

  /// No description provided for @introFeature3Title.
  ///
  /// In en, this message translates to:
  /// **'Get Started Quickly'**
  String get introFeature3Title;

  /// No description provided for @introFeature3Description.
  ///
  /// In en, this message translates to:
  /// **'Jumpstart your project with zero-config setup and best practices'**
  String get introFeature3Description;

  /// No description provided for @appleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get appleSignIn;

  /// No description provided for @googleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get googleSignIn;

  /// No description provided for @appleRegister.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get appleRegister;

  /// No description provided for @googleRegister.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get googleRegister;

  /// No description provided for @emailAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter email and password'**
  String get emailAndPassword;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @legalConsentPart1.
  ///
  /// In en, this message translates to:
  /// **'Kindly read the '**
  String get legalConsentPart1;

  /// No description provided for @legalConsentPart2.
  ///
  /// In en, this message translates to:
  /// **'terms and conditions'**
  String get legalConsentPart2;

  /// Legal consent text with dynamic app name
  ///
  /// In en, this message translates to:
  /// **' and other legal documents that govern your use of {appName}.'**
  String legalConsentPart3(String appName);

  /// No description provided for @emailTitle.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailTitle;

  /// No description provided for @passwordTitle.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordTitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordHint;

  /// No description provided for @loginForgotPasswordPart1.
  ///
  /// In en, this message translates to:
  /// **'Have you forgotten your password? '**
  String get loginForgotPasswordPart1;

  /// No description provided for @loginForgotPasswordPart2.
  ///
  /// In en, this message translates to:
  /// **'Tap here'**
  String get loginForgotPasswordPart2;

  /// No description provided for @loginForgotPasswordPart3.
  ///
  /// In en, this message translates to:
  /// **' to reset your password?'**
  String get loginForgotPasswordPart3;

  /// No description provided for @commonConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get commonConfirmPasswordLabel;

  /// No description provided for @commonConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get commonConfirmPasswordHint;

  /// No description provided for @commonPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get commonPasswordsDoNotMatch;

  /// No description provided for @commonPasswordConfirmRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get commonPasswordConfirmRequired;

  /// Snackbar shown when a field passes validation
  ///
  /// In en, this message translates to:
  /// **'{field} is valid'**
  String commonFieldIsValid(String field);

  /// No description provided for @commonPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait for the current operation to complete'**
  String get commonPleaseWait;

  /// No description provided for @commonUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get commonUnexpectedError;

  /// No description provided for @commonSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonSomethingWentWrong;

  /// No description provided for @commonEnterEmailAndRetry.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address and try again'**
  String get commonEnterEmailAndRetry;

  /// No description provided for @commonLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get commonLearnMore;

  /// No description provided for @authSignUpVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent! Please check your inbox.'**
  String get authSignUpVerificationSent;

  /// Sign-up failure message with error details
  ///
  /// In en, this message translates to:
  /// **'Sign-up failed: {error}'**
  String authSignUpFailed(String error);

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password.'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authSendResetLink;

  /// No description provided for @authBackToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToSignIn;

  /// No description provided for @authUsernameScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your username'**
  String get authUsernameScreenTitle;

  /// No description provided for @authUsernameScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is how others will see you. You can change it later.'**
  String get authUsernameScreenSubtitle;

  /// No description provided for @authUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsernameLabel;

  /// No description provided for @authUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a username'**
  String get authUsernameHint;

  /// Validation error for minimum username length
  ///
  /// In en, this message translates to:
  /// **'Username must be at least {min} characters'**
  String authUsernameMinLength(int min);

  /// Validation error for maximum username length
  ///
  /// In en, this message translates to:
  /// **'Username must be at most {max} characters'**
  String authUsernameMaxLength(int max);

  /// No description provided for @authUsernameFormatError.
  ///
  /// In en, this message translates to:
  /// **'Only letters, numbers, and underscores are allowed'**
  String get authUsernameFormatError;

  /// No description provided for @authUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken'**
  String get authUsernameTaken;

  /// No description provided for @authUsernameCheckError.
  ///
  /// In en, this message translates to:
  /// **'Unable to check username availability. Please try again.'**
  String get authUsernameCheckError;

  /// No description provided for @authUsernameSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save your username. Please try again.'**
  String get authUsernameSaveError;

  /// No description provided for @authUsernameSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Username saved successfully!'**
  String get authUsernameSavedSuccess;

  /// No description provided for @authUpdatePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create new password'**
  String get authUpdatePasswordTitle;

  /// No description provided for @authUpdatePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get authUpdatePasswordButton;

  /// No description provided for @authUpdatePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully. Please sign in again.'**
  String get authUpdatePasswordSuccess;

  /// No description provided for @authPasswordResetSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get authPasswordResetSentTitle;

  /// No description provided for @authPasswordResetSentBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a password reset link to'**
  String get authPasswordResetSentBody;

  /// No description provided for @authPasswordResetSentNote.
  ///
  /// In en, this message translates to:
  /// **'Tap the link in the email to set a new password. The link expires in 1 hour.'**
  String get authPasswordResetSentNote;

  /// No description provided for @authGuestHello.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get authGuestHello;

  /// Welcome text for guest users on the login profile screen
  ///
  /// In en, this message translates to:
  /// **'You are browsing {appName} as a guest. Log in or create an account to start managing your shop — it takes less than 5 seconds. We have a variety of tools to help grow your business, all free of charge.'**
  String authGuestOverview(String appName);

  /// Main title on the intro screen with app name
  ///
  /// In en, this message translates to:
  /// **'Welcome to\n{appName}'**
  String authIntroTitle(String appName);

  /// No description provided for @authIntroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the platform we built for you. Enjoy and have fun — the best is waiting.'**
  String get authIntroSubtitle;

  /// No description provided for @authReadLegalities.
  ///
  /// In en, this message translates to:
  /// **'Read legalities'**
  String get authReadLegalities;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get authPasswordRequired;

  /// No description provided for @authCreatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get authCreatingAccount;

  /// No description provided for @authAccountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get authAccountCreatedSuccess;

  /// No description provided for @authCheckEmailToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Please check your email to confirm your account'**
  String get authCheckEmailToConfirm;

  /// No description provided for @authSigningInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Signing in with Google...'**
  String get authSigningInWithGoogle;

  /// No description provided for @authGoogleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed: {error}'**
  String authGoogleSignInFailed(String error);

  /// No description provided for @authAuthenticatingWithApple.
  ///
  /// In en, this message translates to:
  /// **'Authenticating with Apple...'**
  String get authAuthenticatingWithApple;

  /// No description provided for @authAppleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in failed: {error}'**
  String authAppleSignInFailed(String error);

  /// No description provided for @authSendingResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Sending reset email...'**
  String get authSendingResetEmail;

  /// No description provided for @authResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Reset email sent. Check your inbox.'**
  String get authResetEmailSent;

  /// No description provided for @authPasswordResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Password reset failed: {error}'**
  String authPasswordResetFailed(String error);

  /// No description provided for @authVerifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get authVerifyEmailTitle;

  /// No description provided for @authVerifyEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a confirmation link to'**
  String get authVerifyEmailSubtitle;

  /// No description provided for @authVerifyEmailNote.
  ///
  /// In en, this message translates to:
  /// **'Tap the link in the email to verify your account and continue.'**
  String get authVerifyEmailNote;

  /// No description provided for @authConfirmationResent.
  ///
  /// In en, this message translates to:
  /// **'Confirmation email resent. Check your inbox.'**
  String get authConfirmationResent;

  /// No description provided for @authResendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend email. Please try again.'**
  String get authResendFailed;

  /// No description provided for @authResendEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Resend confirmation email'**
  String get authResendEmailButton;

  /// Button label with seconds remaining for resend cooldown
  ///
  /// In en, this message translates to:
  /// **'Resend email ({seconds}s)'**
  String authResendEmailCooldown(int seconds);

  /// No description provided for @currencySelectorPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select currency'**
  String get currencySelectorPlaceholder;

  /// No description provided for @currencySelectorNoSelected.
  ///
  /// In en, this message translates to:
  /// **'No currency selected'**
  String get currencySelectorNoSelected;

  /// No description provided for @currencySelectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get currencySelectorTitle;

  /// No description provided for @currencySelectorSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by currency, code, or flag...'**
  String get currencySelectorSearchHint;

  /// No description provided for @currencySelectorNoResults.
  ///
  /// In en, this message translates to:
  /// **'No currencies found'**
  String get currencySelectorNoResults;

  /// No description provided for @discoverScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverScreenTitle;

  /// No description provided for @discoverSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get discoverSearchHint;

  /// No description provided for @discoverAllShopsRegion.
  ///
  /// In en, this message translates to:
  /// **'All shops in your region'**
  String get discoverAllShopsRegion;

  /// No description provided for @discoverAllFreelancers.
  ///
  /// In en, this message translates to:
  /// **'All freelancers near you'**
  String get discoverAllFreelancers;

  /// No description provided for @discoverMarketplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get discoverMarketplaceTitle;

  /// No description provided for @discoverMarketplaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shop beauty products with cash on delivery'**
  String get discoverMarketplaceSubtitle;

  /// No description provided for @discoverBrowseProducts.
  ///
  /// In en, this message translates to:
  /// **'Browse products'**
  String get discoverBrowseProducts;

  /// No description provided for @discoverMyOrders.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get discoverMyOrders;

  /// No description provided for @discoverCartTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get discoverCartTooltip;

  /// No description provided for @homeScheduleTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get homeScheduleTabLabel;

  /// No description provided for @homeDashboardTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get homeDashboardTabLabel;

  /// No description provided for @homeMapTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get homeMapTabLabel;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validationEmailInvalid;

  /// Password validation error with minimum length parameter
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {minLength} characters'**
  String validationPasswordLength(int minLength);

  /// No description provided for @validationPasswordUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must include at least one uppercase letter'**
  String get validationPasswordUppercase;

  /// No description provided for @loggingInIndicatorText.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingInIndicatorText;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful!\nWelcome back'**
  String get loginSuccessful;

  /// No description provided for @errorLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials'**
  String get errorLoginFailed;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection'**
  String get errorNetwork;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @editProfileNameFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get editProfileNameFieldTitle;

  /// No description provided for @editProfileNameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get editProfileNameFieldLabel;

  /// No description provided for @editProfileUserFieldNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get editProfileUserFieldNameTitle;

  /// No description provided for @editProfileUsernameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'@username'**
  String get editProfileUsernameFieldLabel;

  /// No description provided for @editProfileBioFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get editProfileBioFieldTitle;

  /// No description provided for @editProfileBioFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get editProfileBioFieldLabel;

  /// No description provided for @editProfileScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileScreenTitle;

  /// No description provided for @editProfileSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get editProfileSettingTitle;

  /// No description provided for @editProfileSettingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your account'**
  String get editProfileSettingSubtitle;

  /// No description provided for @editProfileScreenEditShopTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Shop'**
  String get editProfileScreenEditShopTitle;

  /// No description provided for @editProfileScreenEditShopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change your shop information'**
  String get editProfileScreenEditShopSubtitle;

  /// No description provided for @editProfileScreenCreateFreelancerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create freelancer profile'**
  String get editProfileScreenCreateFreelancerTitle;

  /// No description provided for @editProfileScreenCreateFreelancerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your work profile so clients can find and book you.'**
  String get editProfileScreenCreateFreelancerSubtitle;

  /// No description provided for @editProfileScreenCreateShopTitle.
  ///
  /// In en, this message translates to:
  /// **'Create shop'**
  String get editProfileScreenCreateShopTitle;

  /// No description provided for @editProfileScreenCreateShopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your shop so clients can find and book your services.'**
  String get editProfileScreenCreateShopSubtitle;

  /// No description provided for @editProfileScreenSellProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Sell a product'**
  String get editProfileScreenSellProductTitle;

  /// No description provided for @editProfileScreenSellProductSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sell your beauty products like pomades, shampoos, hairbrushes and more.'**
  String get editProfileScreenSellProductSubtitle;

  /// No description provided for @languageScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language for the app interface.\nThis will not affect your device settings.'**
  String get languageScreenSubtitle;

  /// No description provided for @languageScreeUseDeviceLang.
  ///
  /// In en, this message translates to:
  /// **'Use Device Language.'**
  String get languageScreeUseDeviceLang;

  /// No description provided for @languageScreeUseDeviceLangNote.
  ///
  /// In en, this message translates to:
  /// **'This will reset to match your device system language.'**
  String get languageScreeUseDeviceLangNote;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// No description provided for @accountSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSectionTitle;

  /// No description provided for @accountSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **''**
  String get accountSectionSubtitle;

  /// No description provided for @profileItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileItemTitle;

  /// No description provided for @profileItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your personal data'**
  String get profileItemSubtitle;

  /// No description provided for @locationItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Location'**
  String get locationItemTitle;

  /// No description provided for @locationItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change your current city'**
  String get locationItemSubtitle;

  /// No description provided for @saveItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Contents'**
  String get saveItemTitle;

  /// No description provided for @saveItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contents you have saved'**
  String get saveItemSubtitle;

  /// No description provided for @notificationsItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsItemTitle;

  /// No description provided for @notificationsItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage push and email notifications'**
  String get notificationsItemSubtitle;

  /// No description provided for @blockedItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Blocked Accounts'**
  String get blockedItemTitle;

  /// No description provided for @blockedItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts you have blocked'**
  String get blockedItemSubtitle;

  /// No description provided for @qrCodeItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Share QR Code'**
  String get qrCodeItemTitle;

  /// No description provided for @qrCodeItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your account QR code'**
  String get qrCodeItemSubtitle;

  /// No description provided for @shareProfileItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Profile'**
  String get shareProfileItemTitle;

  /// No description provided for @shareProfileItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your profile with friends'**
  String get shareProfileItemSubtitle;

  /// No description provided for @appSettingsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettingsSectionTitle;

  /// No description provided for @appSettingsSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your experience'**
  String get appSettingsSectionSubtitle;

  /// No description provided for @themeItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeItemTitle;

  /// No description provided for @themeItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light, Dark, or System'**
  String get themeItemSubtitle;

  /// No description provided for @languageItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageItemTitle;

  /// No description provided for @languageItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get languageItemSubtitle;

  /// No description provided for @biometricItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get biometricItemTitle;

  /// No description provided for @biometricItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID or Touch ID'**
  String get biometricItemSubtitle;

  /// No description provided for @supportSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportSectionTitle;

  /// No description provided for @supportSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **''**
  String get supportSectionSubtitle;

  /// No description provided for @guideItemTitle.
  ///
  /// In en, this message translates to:
  /// **'User Guide'**
  String get guideItemTitle;

  /// No description provided for @guideItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Documentation and tutorials'**
  String get guideItemSubtitle;

  /// No description provided for @helpItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get helpItemTitle;

  /// No description provided for @helpItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get help with the app'**
  String get helpItemSubtitle;

  /// No description provided for @feedbackItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get feedbackItemTitle;

  /// No description provided for @feedbackItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts'**
  String get feedbackItemSubtitle;

  /// No description provided for @rateItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get rateItemTitle;

  /// No description provided for @rateItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get rateItemSubtitle;

  /// About app title with dynamic app name
  ///
  /// In en, this message translates to:
  /// **'About {appName}'**
  String appInfoItemTitle(String appName);

  /// No description provided for @appInfoItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Technical information'**
  String get appInfoItemSubtitle;

  /// No description provided for @legalSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legalSectionTitle;

  /// No description provided for @legalSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **''**
  String get legalSectionSubtitle;

  /// No description provided for @termsItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms, Privacy & Policies'**
  String get termsItemTitle;

  /// No description provided for @termsItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read our terms'**
  String get termsItemSubtitle;

  /// No description provided for @licensesItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get licensesItemTitle;

  /// No description provided for @licensesItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Third-party libraries and licenses'**
  String get licensesItemSubtitle;

  /// No description provided for @accountActionsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Actions'**
  String get accountActionsSectionTitle;

  /// No description provided for @accountActionsSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **''**
  String get accountActionsSectionSubtitle;

  /// No description provided for @updatePasswordItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePasswordItemTitle;

  /// No description provided for @updatePasswordItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change your current account password'**
  String get updatePasswordItemSubtitle;

  /// No description provided for @deactivateItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivateItemTitle;

  /// No description provided for @deactivateItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Temporarily hide and deactivate your account'**
  String get deactivateItemSubtitle;

  /// No description provided for @deleteItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteItemTitle;

  /// No description provided for @deleteItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Request permanent account deletion'**
  String get deleteItemSubtitle;

  /// No description provided for @logoutItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutItemTitle;

  /// No description provided for @logoutItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get logoutItemSubtitle;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need to log in again to access your account and data.'**
  String get logoutConfirmMessage;

  /// No description provided for @logoutConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutConfirmButton;

  /// No description provided for @logoutSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully'**
  String get logoutSuccessMessage;

  /// No description provided for @logoutFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed: {error}'**
  String logoutFailedMessage(String error);

  /// No description provided for @accountDeactivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate account'**
  String get accountDeactivateTitle;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDeleteTitle;

  /// No description provided for @accountRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore account'**
  String get accountRestoreTitle;

  /// No description provided for @accountDeactivateWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account will be hidden'**
  String get accountDeactivateWarningTitle;

  /// No description provided for @accountDeactivateWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Your profile, shops, products, freelancer listing, and booking links will be hidden. You can restore access by signing in again.'**
  String get accountDeactivateWarningBody;

  /// No description provided for @accountDeleteWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Deletion is scheduled for 30 days'**
  String get accountDeleteWarningTitle;

  /// No description provided for @accountDeleteWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Your public presence will be hidden now. You can restore your account within 30 days; after that, personal profile data is removed.'**
  String get accountDeleteWarningBody;

  /// No description provided for @accountPasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get accountPasswordConfirmLabel;

  /// No description provided for @accountPasswordConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get accountPasswordConfirmHint;

  /// No description provided for @accountPhraseConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Type {phrase} to confirm'**
  String accountPhraseConfirmLabel(String phrase);

  /// No description provided for @accountReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get accountReasonLabel;

  /// No description provided for @accountReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us why you are leaving'**
  String get accountReasonHint;

  /// No description provided for @accountPhraseMismatch.
  ///
  /// In en, this message translates to:
  /// **'Type {phrase} to continue'**
  String accountPhraseMismatch(String phrase);

  /// No description provided for @accountActionBlocked.
  ///
  /// In en, this message translates to:
  /// **'Resolve active bookings, orders, or withdrawals before continuing.'**
  String get accountActionBlocked;

  /// No description provided for @accountActionLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not load account requirements. Please try again.'**
  String get accountActionLoadFailed;

  /// No description provided for @accountActionGenericError.
  ///
  /// In en, this message translates to:
  /// **'We could not complete this account action. Please try again.'**
  String get accountActionGenericError;

  /// No description provided for @accountRecentAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again before continuing.'**
  String get accountRecentAuthRequired;

  /// No description provided for @accountReasonTooLong.
  ///
  /// In en, this message translates to:
  /// **'Reason must be 1000 characters or fewer.'**
  String get accountReasonTooLong;

  /// No description provided for @accountDeactivateButton.
  ///
  /// In en, this message translates to:
  /// **'Deactivate account'**
  String get accountDeactivateButton;

  /// No description provided for @accountDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Request deletion'**
  String get accountDeleteButton;

  /// No description provided for @accountDeactivatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deactivated.'**
  String get accountDeactivatedSuccess;

  /// No description provided for @accountDeletionRequestedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deletion has been scheduled.'**
  String get accountDeletionRequestedSuccess;

  /// No description provided for @accountRestoreButton.
  ///
  /// In en, this message translates to:
  /// **'Restore account'**
  String get accountRestoreButton;

  /// No description provided for @accountRestoredSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been restored.'**
  String get accountRestoredSuccess;

  /// No description provided for @accountRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not restore this account.'**
  String get accountRestoreFailed;

  /// No description provided for @accountRestoreMissingProfile.
  ///
  /// In en, this message translates to:
  /// **'We could not load your profile.'**
  String get accountRestoreMissingProfile;

  /// No description provided for @accountDeactivatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account deactivated'**
  String get accountDeactivatedTitle;

  /// No description provided for @accountDeactivatedBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is hidden. Restore it to continue using the app.'**
  String get accountDeactivatedBody;

  /// No description provided for @accountPendingDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Account pending deletion'**
  String get accountPendingDeleteTitle;

  /// No description provided for @accountPendingDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is scheduled for deletion on {date}. Restore it before then to keep your account.'**
  String accountPendingDeleteBody(String date);

  /// No description provided for @accountDeletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeletedTitle;

  /// No description provided for @accountDeletedBody.
  ///
  /// In en, this message translates to:
  /// **'This account has been deleted and can no longer be restored.'**
  String get accountDeletedBody;

  /// No description provided for @accountBlockersTitle.
  ///
  /// In en, this message translates to:
  /// **'Resolve these first'**
  String get accountBlockersTitle;

  /// No description provided for @accountBlockerActiveBookings.
  ///
  /// In en, this message translates to:
  /// **'{count} active booking(s)'**
  String accountBlockerActiveBookings(int count);

  /// No description provided for @accountBlockerOwnedShopActiveBookings.
  ///
  /// In en, this message translates to:
  /// **'{count} active shop booking(s)'**
  String accountBlockerOwnedShopActiveBookings(int count);

  /// No description provided for @accountBlockerActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'{count} active order(s)'**
  String accountBlockerActiveOrders(int count);

  /// No description provided for @accountBlockerOwnedShopActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'{count} active shop order(s)'**
  String accountBlockerOwnedShopActiveOrders(int count);

  /// No description provided for @accountBlockerActiveWithdrawals.
  ///
  /// In en, this message translates to:
  /// **'{count} pending withdrawal(s)'**
  String accountBlockerActiveWithdrawals(int count);

  /// No description provided for @loadingDefaultMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingDefaultMessage;

  /// Title shown when no data of a specific type is available
  ///
  /// In en, this message translates to:
  /// **'No {dataType} yet'**
  String emptyStateNoDataTitle(String dataType);

  /// Subtitle explaining when data will appear
  ///
  /// In en, this message translates to:
  /// **'When {dataType} becomes available, they will appear here.'**
  String emptyStateNoDataSubtitle(String dataType);

  /// No description provided for @emptyStateNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get emptyStateNoResultsTitle;

  /// Hint for finding specific data type
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters to find {dataType}.'**
  String emptyStateNoResultsSubtitle(String dataType);

  /// No description provided for @emptyStateNoInternetTitle.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get emptyStateNoInternetTitle;

  /// No description provided for @emptyStateNoInternetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get emptyStateNoInternetSubtitle;

  /// No description provided for @emptyStateNoFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get emptyStateNoFavoritesTitle;

  /// No description provided for @emptyStateNoFavoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start adding items to your favorites list.'**
  String get emptyStateNoFavoritesSubtitle;

  /// No description provided for @emptyStateNoMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get emptyStateNoMessagesTitle;

  /// No description provided for @emptyStateNoMessagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation to see messages here.'**
  String get emptyStateNoMessagesSubtitle;

  /// No description provided for @emptyStateRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get emptyStateRefresh;

  /// No description provided for @emptyStateClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get emptyStateClearFilters;

  /// No description provided for @emptyStateRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get emptyStateRetry;

  /// No description provided for @emptyStateExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get emptyStateExplore;

  /// No description provided for @emptyStateStartChat.
  ///
  /// In en, this message translates to:
  /// **'Start chat'**
  String get emptyStateStartChat;

  /// No description provided for @errorNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get errorNetworkTitle;

  /// No description provided for @errorNetworkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to the server. Check your internet connection.'**
  String get errorNetworkSubtitle;

  /// No description provided for @errorServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get errorServerTitle;

  /// No description provided for @errorServerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our end. Please try again later.'**
  String get errorServerSubtitle;

  /// No description provided for @errorClientTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Error'**
  String get errorClientTitle;

  /// No description provided for @errorClientSubtitle.
  ///
  /// In en, this message translates to:
  /// **'There was a problem with your request. Please check and try again.'**
  String get errorClientSubtitle;

  /// No description provided for @errorParsingTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Error'**
  String get errorParsingTitle;

  /// Error when failing to parse specific data type
  ///
  /// In en, this message translates to:
  /// **'Unable to process the {dataType}. This might be a temporary issue.'**
  String errorParsingSubtitle(String dataType);

  /// No description provided for @errorPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get errorPermissionTitle;

  /// Error for permission denial on specific content
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to access this {dataType}.'**
  String errorPermissionSubtitle(String dataType);

  /// No description provided for @errorGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGenericTitle;

  /// Generic error message with data type context
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred while loading {dataType}. Please try again.'**
  String errorGenericSubtitle(String dataType);

  /// No description provided for @errorRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get errorRetry;

  /// No description provided for @errorCheckSettings.
  ///
  /// In en, this message translates to:
  /// **'Check settings'**
  String get errorCheckSettings;

  /// No description provided for @errorReport.
  ///
  /// In en, this message translates to:
  /// **'Report issue'**
  String get errorReport;

  /// No description provided for @errorGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get errorGoBack;

  /// No description provided for @errorRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get errorRefresh;

  /// No description provided for @errorRequestAccess.
  ///
  /// In en, this message translates to:
  /// **'Request access'**
  String get errorRequestAccess;

  /// No description provided for @errorContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get errorContactSupport;

  /// No description provided for @dataTypeUsers.
  ///
  /// In en, this message translates to:
  /// **'users'**
  String get dataTypeUsers;

  /// No description provided for @dataTypeUser.
  ///
  /// In en, this message translates to:
  /// **'user'**
  String get dataTypeUser;

  /// No description provided for @dataTypeProducts.
  ///
  /// In en, this message translates to:
  /// **'products'**
  String get dataTypeProducts;

  /// No description provided for @dataTypeProduct.
  ///
  /// In en, this message translates to:
  /// **'product'**
  String get dataTypeProduct;

  /// No description provided for @dataTypeOrders.
  ///
  /// In en, this message translates to:
  /// **'orders'**
  String get dataTypeOrders;

  /// No description provided for @dataTypeOrder.
  ///
  /// In en, this message translates to:
  /// **'order'**
  String get dataTypeOrder;

  /// No description provided for @dataTypeMessages.
  ///
  /// In en, this message translates to:
  /// **'messages'**
  String get dataTypeMessages;

  /// No description provided for @dataTypeMessage.
  ///
  /// In en, this message translates to:
  /// **'message'**
  String get dataTypeMessage;

  /// No description provided for @dataTypeFavorites.
  ///
  /// In en, this message translates to:
  /// **'favorites'**
  String get dataTypeFavorites;

  /// No description provided for @dataTypeFavorite.
  ///
  /// In en, this message translates to:
  /// **'favorite'**
  String get dataTypeFavorite;

  /// No description provided for @dataTypeData.
  ///
  /// In en, this message translates to:
  /// **'data'**
  String get dataTypeData;

  /// No description provided for @dataTypeContent.
  ///
  /// In en, this message translates to:
  /// **'content'**
  String get dataTypeContent;

  /// No description provided for @dataTypeItems.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get dataTypeItems;

  /// No description provided for @dataTypeItem.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get dataTypeItem;

  /// No description provided for @eulaTitle.
  ///
  /// In en, this message translates to:
  /// **'End User License Agreement'**
  String get eulaTitle;

  /// EULA content with app name and support email placeholders
  ///
  /// In en, this message translates to:
  /// **'This End User License Agreement (\"EULA\") is a legal agreement between you and Bars Opus, Ltd. for {appName}.\n\nBy installing, accessing, or using {appName}, you agree to be bound by the terms of this EULA. {appName} is licensed, not sold, to you for use only under the terms of this license. Bars Opus, Ltd. reserves all rights not expressly granted to you in this EULA.\n\nYou may not modify, reverse engineer, decompile, or disassemble {appName}. This license is valid until terminated by you or Bars Opus, Ltd. Your rights under this license will terminate automatically without notice if you fail to comply with any term(s).\n\nAll intellectual property rights in and to {appName} are owned by Bars Opus, Ltd. This EULA is governed by the laws of England and Wales.\n\nFor questions about this EULA, please contact: {supportEmail}.'**
  String eulaContent(String appName, String supportEmail);

  /// No description provided for @eulaFooter.
  ///
  /// In en, this message translates to:
  /// **'By agreeing, you acknowledge that you have read and understood this End User License Agreement.'**
  String get eulaFooter;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// Privacy policy content with app name placeholder
  ///
  /// In en, this message translates to:
  /// **'This Privacy Policy explains how Bars Opus, Ltd. (\"we\", \"us\", \"our\") collects, uses, and protects your information when you use {appName}.\n\nWe collect information you provide directly, such as when you create an account, complete your profile, or contact support. We automatically collect certain information about your device and how you use {appName}. We use cookies and similar tracking technologies to track activity and hold certain information.\n\nWe use the information we collect to provide, maintain, and improve {appName}. We may share your information with third-party service providers who perform services on our behalf. We may disclose your information if required by law or to protect our rights and safety.\n\nYou have the right to access, correct, or delete your personal information. We implement appropriate technical and organizational measures to protect your information. We may update this Privacy Policy from time to time. We will notify you of any changes.'**
  String privacyPolicyContent(String appName);

  /// Privacy policy footer with app name and current date
  ///
  /// In en, this message translates to:
  /// **'{appName} Privacy Policy - Last updated: {currentDate}'**
  String privacyPolicyFooter(String appName, DateTime currentDate);

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsTitle;

  /// Terms of service content with app name and support email
  ///
  /// In en, this message translates to:
  /// **'These Terms of Service (\"Terms\") govern your access to and use of {appName}. By accessing or using {appName}, you agree to be bound by these Terms.\n\nYou must be at least 13 years old to use {appName}. You are responsible for safeguarding your account credentials and for all activities under your account. You may not use {appName} for any illegal or unauthorized purpose.\n\nWe reserve the right to modify, suspend, or discontinue {appName} at any time. All content included in {appName} is the property of Bars Opus, Ltd. or its licensors.\n\nWe may terminate or suspend your access to {appName} immediately if you violate these Terms. These Terms shall be governed by and construed in accordance with the laws of England and Wales.\n\nFor any questions about these Terms, please contact us at {supportEmail}.'**
  String termsContent(String appName, String supportEmail);

  /// No description provided for @dataSharingTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Sharing Agreement'**
  String get dataSharingTitle;

  /// Data sharing content with app name placeholder
  ///
  /// In en, this message translates to:
  /// **'This Data Sharing Agreement outlines how your information may be shared when you use {appName} social features.\n\nWhen you connect with friends on {appName}, certain activity data may be visible to them. Shared activity data may include workout duration, calories burned, exercise minutes, and achievement badges. Your profile information (display name and profile picture) is visible to friends you connect with.\n\nYour email address and contact information remain private and are never shared with other users. You control what data is shared through your {appName} privacy settings. You can revoke sharing permissions at any time in the app settings.\n\nData shared with friends is encrypted during transmission and storage. We retain shared data only as long as necessary to provide the sharing functionality. Third-party integrations may have their own data sharing practices, which we recommend reviewing.'**
  String dataSharingContent(String appName);

  /// Data sharing footer with app name placeholder
  ///
  /// In en, this message translates to:
  /// **'Data sharing in {appName} helps create a supportive community while respecting your privacy choices.'**
  String dataSharingFooter(String appName);

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your shop activities efficiently'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardSectionTitle;

  /// No description provided for @dashboardSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Overview of your shop\'s performance and key metrics'**
  String get dashboardSectionSubtitle;

  /// No description provided for @dashboardPayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Payout'**
  String get dashboardPayoutTitle;

  /// No description provided for @dashboardPayoutContent.
  ///
  /// In en, this message translates to:
  /// **'Shop owners can request weekly payouts. Navigate to the Earnings section, review your balance, and submit a payout request. Funds typically process within 3-5 business days.'**
  String get dashboardPayoutContent;

  /// No description provided for @dashboardAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics Dashboard'**
  String get dashboardAnalyticsTitle;

  /// No description provided for @dashboardAnalyticsContent.
  ///
  /// In en, this message translates to:
  /// **'Track your shop\'s performance with real-time analytics. Monitor sales trends, customer engagement, and inventory levels through interactive charts and reports.'**
  String get dashboardAnalyticsContent;

  /// No description provided for @dashboardScreenshotTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Overview'**
  String get dashboardScreenshotTitle;

  /// No description provided for @dashboardScreenshotContent.
  ///
  /// In en, this message translates to:
  /// **'The main dashboard provides a comprehensive view of your shop\'s key metrics, recent activities, and quick access to essential features.'**
  String get dashboardScreenshotContent;

  /// No description provided for @categoryFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get categoryFeatures;

  /// No description provided for @categoryDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get categoryDashboard;

  /// No description provided for @faqDashboard1Question.
  ///
  /// In en, this message translates to:
  /// **'When can I request a payout?'**
  String get faqDashboard1Question;

  /// No description provided for @faqDashboard1Answer.
  ///
  /// In en, this message translates to:
  /// **'You can request your payout once a week, every Saturday. The weekly cutoff is Friday at 11:59 PM. Payouts are processed within 3-5 business days.'**
  String get faqDashboard1Answer;

  /// No description provided for @faqDashboard2Question.
  ///
  /// In en, this message translates to:
  /// **'Where do I request my payout?'**
  String get faqDashboard2Question;

  /// No description provided for @faqDashboard2Answer.
  ///
  /// In en, this message translates to:
  /// **'Navigate to your dashboard and click on the \'Earnings\' section. From there, you\'ll see your current balance and a \'Request Payout\' button. Follow the prompts to complete your request.'**
  String get faqDashboard2Answer;

  /// No description provided for @profileScreenCantChatWithYourself.
  ///
  /// In en, this message translates to:
  /// **'You can\'t chat with yourself'**
  String get profileScreenCantChatWithYourself;

  /// No description provided for @profileScreenStartingConversation.
  ///
  /// In en, this message translates to:
  /// **'Starting conversation...'**
  String get profileScreenStartingConversation;

  /// No description provided for @profileScreenNoActiveSession.
  ///
  /// In en, this message translates to:
  /// **'No active session — please log in again.'**
  String get profileScreenNoActiveSession;

  /// No description provided for @profileScreenSignInToChatMessage.
  ///
  /// In en, this message translates to:
  /// **'You have to sign in to send a message'**
  String get profileScreenSignInToChatMessage;

  /// No description provided for @profileScreenFollowFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Follow feature coming soon'**
  String get profileScreenFollowFeatureComingSoon;

  /// No description provided for @profileScreenEnterBioPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter a bio so people can know you'**
  String get profileScreenEnterBioPlaceholder;

  /// No description provided for @profileScreenNoBioYet.
  ///
  /// In en, this message translates to:
  /// **'No bio yet'**
  String get profileScreenNoBioYet;

  /// No description provided for @profileScreenErrorLoadingProfileBody.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile. Check your internet and try again.'**
  String get profileScreenErrorLoadingProfileBody;

  /// No description provided for @profileScreenLoadingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get profileScreenLoadingNotifications;

  /// No description provided for @profileHeaderBookingsStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get profileHeaderBookingsStatLabel;

  /// No description provided for @profileHeaderOrdersStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get profileHeaderOrdersStatLabel;

  /// No description provided for @profileHeaderEditProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileHeaderEditProfileButton;

  /// No description provided for @profileHeaderMessageButton.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get profileHeaderMessageButton;

  /// No description provided for @editableProfileAvatarTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get editableProfileAvatarTakePhoto;

  /// No description provided for @editableProfileAvatarChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get editableProfileAvatarChooseGallery;

  /// No description provided for @editProfileScreenAccountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get editProfileScreenAccountTypeLabel;

  /// No description provided for @editProfileScreenAccountTypeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select how you want to use this app. This determines what features are available to you.'**
  String get editProfileScreenAccountTypeSubtitle;

  /// No description provided for @editProfileScreenUpdatingAccountType.
  ///
  /// In en, this message translates to:
  /// **'Updating account type...'**
  String get editProfileScreenUpdatingAccountType;

  /// No description provided for @editProfileScreenPleaseLogIn.
  ///
  /// In en, this message translates to:
  /// **'Please log in'**
  String get editProfileScreenPleaseLogIn;

  /// No description provided for @editProfileScreenNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get editProfileScreenNameLabel;

  /// No description provided for @editProfileScreenNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get editProfileScreenNameHint;

  /// No description provided for @editProfileScreenUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get editProfileScreenUsernameLabel;

  /// No description provided for @editProfileScreenUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get editProfileScreenUsernameHint;

  /// No description provided for @editProfileScreenBioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get editProfileScreenBioLabel;

  /// No description provided for @editProfileScreenBioHint.
  ///
  /// In en, this message translates to:
  /// **'Tell something about yourself'**
  String get editProfileScreenBioHint;

  /// No description provided for @editProfileScreenEditWorkProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit work profile'**
  String get editProfileScreenEditWorkProfileTitle;

  /// No description provided for @profileTabsAppointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get profileTabsAppointments;

  /// No description provided for @profileTabsBuys.
  ///
  /// In en, this message translates to:
  /// **'Buys'**
  String get profileTabsBuys;

  /// No description provided for @profileTabsSaves.
  ///
  /// In en, this message translates to:
  /// **'Saves'**
  String get profileTabsSaves;

  /// No description provided for @searchScreenSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search shops, professionals, products...'**
  String get searchScreenSearchHint;

  /// No description provided for @searchScreenNoResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchScreenNoResultsFound;

  /// Empty state message for search with category placeholder
  ///
  /// In en, this message translates to:
  /// **'No {category} found'**
  String searchScreenNoResultsCategory(String category);

  /// Search query display in empty state
  ///
  /// In en, this message translates to:
  /// **'Searched for: \"{query}\"'**
  String searchScreenSearchedFor(String query);

  /// No description provided for @searchScreenSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get searchScreenSomethingWentWrong;

  /// No description provided for @searchAppBarSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchAppBarSearchHint;

  /// No description provided for @searchSuggestionsHint.
  ///
  /// In en, this message translates to:
  /// **'Search for shops, professionals for home service, or hair products to buy'**
  String get searchSuggestionsHint;

  /// No description provided for @searchSuggestionsRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get searchSuggestionsRecentSearches;

  /// No description provided for @searchSuggestionsClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get searchSuggestionsClearAll;

  /// No description provided for @searchEmptyStateNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchEmptyStateNoResults;

  /// Empty state message when no search results found
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find anything for \"{query}\"'**
  String searchEmptyStateCouldNotFind(String query);

  /// No description provided for @searchEmptyStateTryThese.
  ///
  /// In en, this message translates to:
  /// **'Try these instead:'**
  String get searchEmptyStateTryThese;

  /// No description provided for @searchResultsShopsHeader.
  ///
  /// In en, this message translates to:
  /// **'Shops'**
  String get searchResultsShopsHeader;

  /// No description provided for @searchResultsSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get searchResultsSeeAll;

  /// Category results screen title
  ///
  /// In en, this message translates to:
  /// **'{category} Results'**
  String searchResultsTitle(String category);

  /// Subtitle showing search query in results screen
  ///
  /// In en, this message translates to:
  /// **'Searching for \"{query}\"'**
  String searchResultsSearchingFor(String query);

  /// No description provided for @searchResultsTryDifferent.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords or remove filters'**
  String get searchResultsTryDifferent;

  /// No description provided for @searchResultsSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get searchResultsSomethingWentWrong;

  /// Title for nearby shops section showing distance radius
  ///
  /// In en, this message translates to:
  /// **'Near You\nwithin {km}km'**
  String nearYouShopsTitle(int km);

  /// Description of nearby shops feature
  ///
  /// In en, this message translates to:
  /// **'Shops located within {km} km of your current location, shown from closest to farthest. Simply set your location once, and we\'ll show you what\'s nearby—whether you\'re at home, work, or exploring a new neighborhood. Handy for last‑minute bookings or when you prefer to walk.'**
  String nearYouShopsBody(int km);

  /// No description provided for @nearYouShopsEmptyNoFilter.
  ///
  /// In en, this message translates to:
  /// **'No shops found nearby'**
  String get nearYouShopsEmptyNoFilter;

  /// Empty state message when no shops found for selected luxury level
  ///
  /// In en, this message translates to:
  /// **'No {luxury} shops found nearby'**
  String nearYouShopsEmptyWithFilter(String luxury);

  /// Empty state subtitle with location placeholder
  ///
  /// In en, this message translates to:
  /// **'Shops in {location} would be shown here once they become available'**
  String nearYouShopsEmptySubtitle(String location);

  /// No description provided for @premiumShopsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Shops'**
  String get premiumShopsScreenTitle;

  /// No description provided for @premiumShopsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No premium shops found'**
  String get premiumShopsEmpty;

  /// No description provided for @premiumShopsHorizontalTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium shops\nfor premium looks'**
  String get premiumShopsHorizontalTitle;

  /// No description provided for @premiumShopsHorizontalBody.
  ///
  /// In en, this message translates to:
  /// **'Handpicked high‑end salons and spas offering luxury experiences. These shops are classified as Luxury or Ultra‑Luxury based on their services, pricing, and customer reviews. Perfect when you\'re looking for that extra touch of elegance.'**
  String get premiumShopsHorizontalBody;

  /// No description provided for @premiumShopsHorizontalEmptyNoFilter.
  ///
  /// In en, this message translates to:
  /// **'No premium shops available'**
  String get premiumShopsHorizontalEmptyNoFilter;

  /// Empty state for premium shops with luxury level filter
  ///
  /// In en, this message translates to:
  /// **'No {luxury} premium shops available'**
  String premiumShopsHorizontalEmptyWithFilter(String luxury);

  /// No description provided for @premiumShopsHorizontalEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shops would be shown here once they become available'**
  String get premiumShopsHorizontalEmptySubtitle;

  /// No description provided for @topRatedShopsHorizontalTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get topRatedShopsHorizontalTitle;

  /// Top rated shops title with location
  ///
  /// In en, this message translates to:
  /// **'Top Rated \nin {location}'**
  String topRatedShopsHorizontalTitleWithLocation(String location);

  /// No description provided for @topRatedShopsHorizontalBody.
  ///
  /// In en, this message translates to:
  /// **'Shops with the highest customer ratings (4.5+ stars) and a solid number of reviews. These are the favorites among our community—consistently praised for quality, service, and professionalism. A great place to start if you want reliable, crowd‑approved options.'**
  String get topRatedShopsHorizontalBody;

  /// No description provided for @topRatedShopsHorizontalEmptyNoFilter.
  ///
  /// In en, this message translates to:
  /// **'No top rated shops available'**
  String get topRatedShopsHorizontalEmptyNoFilter;

  /// Empty state for top rated shops with luxury level filter
  ///
  /// In en, this message translates to:
  /// **'No {luxury} premium shops available'**
  String topRatedShopsHorizontalEmptyWithFilter(String luxury);

  /// No description provided for @topRatedShopsHorizontalEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shops would be shown here once they become available'**
  String get topRatedShopsHorizontalEmptySubtitle;

  /// No description provided for @topRatedShopsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Rated Shops'**
  String get topRatedShopsScreenTitle;

  /// No description provided for @topRatedShopsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No top rated shops found'**
  String get topRatedShopsEmpty;

  /// No description provided for @nearYouFreelancersScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Freelancers near you'**
  String get nearYouFreelancersScreenTitle;

  /// No description provided for @nearYouFreelancersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No freelancers found nearby'**
  String get nearYouFreelancersEmpty;

  /// No description provided for @nearYouFreelancersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try expanding your search area or change location'**
  String get nearYouFreelancersEmptySubtitle;

  /// No description provided for @topRatedFreelancersScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Top rated freelancers'**
  String get topRatedFreelancersScreenTitle;

  /// No description provided for @topRatedFreelancersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No top rated freelancers found'**
  String get topRatedFreelancersEmpty;

  /// No description provided for @topRatedFreelancersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search area'**
  String get topRatedFreelancersEmptySubtitle;

  /// Top rated freelancers title with location
  ///
  /// In en, this message translates to:
  /// **'Top Rated \nin {location}'**
  String topRatedFreelancersHorizontalTitle(String location);

  /// No description provided for @topRatedFreelancersHorizontalBody.
  ///
  /// In en, this message translates to:
  /// **'Handpicked high‑end professionals offering luxury experiences. These freelancers are classified as top rated based on their work quality, pricing, and customer reviews. Perfect when you\'re looking for that extra touch of excellence.'**
  String get topRatedFreelancersHorizontalBody;

  /// Freelancers near you title with location
  ///
  /// In en, this message translates to:
  /// **'Freelancers Near You in {location}'**
  String nearYouFreelancersHorizontalTitle(String location);

  /// No description provided for @nearYouFreelancersHorizontalBody.
  ///
  /// In en, this message translates to:
  /// **'Skilled professionals located near you. These freelancers are available for quick bookings and offer convenient, local service. Perfect when you\'re looking for reliability and proximity.'**
  String get nearYouFreelancersHorizontalBody;

  /// No description provided for @nearYouFreelancersHorizontalEmpty.
  ///
  /// In en, this message translates to:
  /// **'No top rated freelancers available'**
  String get nearYouFreelancersHorizontalEmpty;

  /// No description provided for @nearYouFreelancersHorizontalEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Freelancers would be shown here once they become available'**
  String get nearYouFreelancersHorizontalEmptySubtitle;

  /// No description provided for @shopNoLocationSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your location to discover'**
  String get shopNoLocationSetTitle;

  /// No description provided for @shopNoLocationSetContent.
  ///
  /// In en, this message translates to:
  /// **'Set your location to discover premium and top rated shops near you.'**
  String get shopNoLocationSetContent;

  /// No description provided for @providerTypeShops.
  ///
  /// In en, this message translates to:
  /// **'Shops'**
  String get providerTypeShops;

  /// No description provided for @providerTypeFreelancers.
  ///
  /// In en, this message translates to:
  /// **'Freelancers'**
  String get providerTypeFreelancers;

  /// No description provided for @providerTypeBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get providerTypeBuy;

  /// No description provided for @luxuryLevelChipsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get luxuryLevelChipsAll;

  /// No description provided for @searchRadiusSliderTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore radius'**
  String get searchRadiusSliderTitle;

  /// Subtitle showing current search radius
  ///
  /// In en, this message translates to:
  /// **'Showing results within {km}km of your location'**
  String searchRadiusSliderSubtitle(int km);

  /// Validation error for maximum password length
  ///
  /// In en, this message translates to:
  /// **'Password must be at most {max} characters'**
  String validationPasswordMaxLength(int max);

  /// No description provided for @validationPasswordRepeatingChars.
  ///
  /// In en, this message translates to:
  /// **'Password contains too many repeating characters'**
  String get validationPasswordRepeatingChars;

  /// No description provided for @validationPasswordSequential.
  ///
  /// In en, this message translates to:
  /// **'Password contains sequential characters'**
  String get validationPasswordSequential;

  /// Validation error for specific phone number digit requirement
  ///
  /// In en, this message translates to:
  /// **'Phone number must be {digits} digits'**
  String validationPhoneDigits(int digits);

  /// No description provided for @validationPhoneUK.
  ///
  /// In en, this message translates to:
  /// **'Invalid UK phone number'**
  String get validationPhoneUK;

  /// Validation error for URL scheme requirement
  ///
  /// In en, this message translates to:
  /// **'URL must start with {schemes}'**
  String validationUrlScheme(String schemes);

  /// No description provided for @validationUrlDomain.
  ///
  /// In en, this message translates to:
  /// **'Invalid domain name'**
  String get validationUrlDomain;

  /// No description provided for @validationUrlPublicAddress.
  ///
  /// In en, this message translates to:
  /// **'URL must point to a public address'**
  String get validationUrlPublicAddress;

  /// Validation error for maximum name length
  ///
  /// In en, this message translates to:
  /// **'{field} must be at most {max} characters'**
  String validationNameMaxLength(String field, int max);

  /// Validation error for consecutive special characters in name
  ///
  /// In en, this message translates to:
  /// **'{field} cannot contain consecutive hyphens or spaces'**
  String validationNameConsecutiveChars(String field);

  /// No description provided for @validationCreditCardFormat.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid credit card number'**
  String get validationCreditCardFormat;

  /// No description provided for @validationCreditCardInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid credit card number'**
  String get validationCreditCardInvalid;

  /// No description provided for @validationDatePastNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Date cannot be in the past'**
  String get validationDatePastNotAllowed;

  /// No description provided for @validationPostalCodeZip.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid ZIP code (e.g., 12345 or 12345-6789)'**
  String get validationPostalCodeZip;

  /// No description provided for @validationPostalCodeCanadian.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Canadian postal code (e.g., A1A 1A1)'**
  String get validationPostalCodeCanadian;

  /// No description provided for @validationPostalCodeGeneric.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid postal code'**
  String get validationPostalCodeGeneric;

  /// No description provided for @validationSSNFormat.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid SSN (e.g., 123-45-6789)'**
  String get validationSSNFormat;

  /// No description provided for @validationSSNInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid SSN'**
  String get validationSSNInvalid;

  /// No description provided for @validationEmailTooLong.
  ///
  /// In en, this message translates to:
  /// **'Email is too long (max 254 characters)'**
  String get validationEmailTooLong;

  /// No description provided for @validationEmailLocalPartTooLong.
  ///
  /// In en, this message translates to:
  /// **'Local part of email is too long'**
  String get validationEmailLocalPartTooLong;

  /// No description provided for @categoriesAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoriesAll;

  /// No description provided for @categoriesSalon.
  ///
  /// In en, this message translates to:
  /// **'Salons'**
  String get categoriesSalon;

  /// No description provided for @categoriesBarbershop.
  ///
  /// In en, this message translates to:
  /// **'Barbershops'**
  String get categoriesBarbershop;

  /// No description provided for @categoriesSpa.
  ///
  /// In en, this message translates to:
  /// **'Spas'**
  String get categoriesSpa;

  /// No description provided for @categoriesNailSalon.
  ///
  /// In en, this message translates to:
  /// **'Nail Salons'**
  String get categoriesNailSalon;

  /// No description provided for @categoriesLashStudio.
  ///
  /// In en, this message translates to:
  /// **'Lash Studios'**
  String get categoriesLashStudio;

  /// No description provided for @categoriesWaxing.
  ///
  /// In en, this message translates to:
  /// **'Waxing'**
  String get categoriesWaxing;

  /// No description provided for @categoriesMassage.
  ///
  /// In en, this message translates to:
  /// **'Massage'**
  String get categoriesMassage;

  /// No description provided for @categoriesMakeup.
  ///
  /// In en, this message translates to:
  /// **'Makeup'**
  String get categoriesMakeup;

  /// No description provided for @categoriesSkincare.
  ///
  /// In en, this message translates to:
  /// **'Skincare'**
  String get categoriesSkincare;

  /// No description provided for @luxuryLevelModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get luxuryLevelModerate;

  /// No description provided for @luxuryLevelLuxury.
  ///
  /// In en, this message translates to:
  /// **'Luxury'**
  String get luxuryLevelLuxury;

  /// No description provided for @luxuryLevelUltraLuxury.
  ///
  /// In en, this message translates to:
  /// **'Ultra Luxury'**
  String get luxuryLevelUltraLuxury;

  /// No description provided for @dashboardTabRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get dashboardTabRevenue;

  /// No description provided for @dashboardTabAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get dashboardTabAnalytics;

  /// No description provided for @dashboardTabInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get dashboardTabInsights;

  /// No description provided for @dashboardTabTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get dashboardTabTools;

  /// No description provided for @dashboardTabClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get dashboardTabClients;

  /// No description provided for @dashboardTabStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get dashboardTabStaff;

  /// No description provided for @walletRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get walletRecentTransactions;

  /// No description provided for @walletLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your wallet right now.'**
  String get walletLoadError;

  /// No description provided for @walletTransactionLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load recent transactions.'**
  String get walletTransactionLoadError;

  /// No description provided for @walletPaymentProcessing.
  ///
  /// In en, this message translates to:
  /// **'Kindly wait for the payment to finish processing and return to your app to complete your booking.'**
  String get walletPaymentProcessing;

  /// No description provided for @analyticsRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get analyticsRevenue;

  /// No description provided for @analyticsServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get analyticsServices;

  /// No description provided for @analyticsWorkers.
  ///
  /// In en, this message translates to:
  /// **'Workers'**
  String get analyticsWorkers;

  /// No description provided for @analyticsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load analytics'**
  String get analyticsLoadError;

  /// No description provided for @analyticsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No data available for analytics.'**
  String get analyticsEmpty;

  /// No description provided for @analyticsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Booking and revenue statistics would appear here'**
  String get analyticsEmptySubtitle;

  /// No description provided for @insightsReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get insightsReports;

  /// No description provided for @insightsSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get insightsSeeAll;

  /// No description provided for @insightsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load reports. Pull to refresh.'**
  String get insightsLoadError;

  /// No description provided for @insightsNoAlerts.
  ///
  /// In en, this message translates to:
  /// **'All good! No alerts'**
  String get insightsNoAlerts;

  /// No description provided for @insightsHeatmapError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the booking heatmap right now.'**
  String get insightsHeatmapError;

  /// No description provided for @insightsNoHeatmapData.
  ///
  /// In en, this message translates to:
  /// **'No heatmap data available'**
  String get insightsNoHeatmapData;

  /// No description provided for @toolsAdminTools.
  ///
  /// In en, this message translates to:
  /// **'Admin Tools'**
  String get toolsAdminTools;

  /// No description provided for @toolsConfigure.
  ///
  /// In en, this message translates to:
  /// **'Configure →'**
  String get toolsConfigure;

  /// No description provided for @toolsManage.
  ///
  /// In en, this message translates to:
  /// **'Manage →'**
  String get toolsManage;

  /// No description provided for @toolsExport.
  ///
  /// In en, this message translates to:
  /// **'Export →'**
  String get toolsExport;

  /// No description provided for @toolsAutomatedReminders.
  ///
  /// In en, this message translates to:
  /// **'Automated Reminders'**
  String get toolsAutomatedReminders;

  /// No description provided for @toolsPromotionsManager.
  ///
  /// In en, this message translates to:
  /// **'Promotions Manager'**
  String get toolsPromotionsManager;

  /// No description provided for @toolsExportReports.
  ///
  /// In en, this message translates to:
  /// **'Export Reports'**
  String get toolsExportReports;

  /// No description provided for @toolsPaymentSettings.
  ///
  /// In en, this message translates to:
  /// **'Payment Settings'**
  String get toolsPaymentSettings;

  /// No description provided for @toolsLoadingDetails.
  ///
  /// In en, this message translates to:
  /// **'Loading shop details…'**
  String get toolsLoadingDetails;

  /// No description provided for @toolsBusinessHours.
  ///
  /// In en, this message translates to:
  /// **'Business Hours'**
  String get toolsBusinessHours;

  /// No description provided for @toolsServiceManagement.
  ///
  /// In en, this message translates to:
  /// **'Service Management'**
  String get toolsServiceManagement;

  /// No description provided for @clientsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name...'**
  String get clientsSearchHint;

  /// No description provided for @clientsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load clients'**
  String get clientsLoadError;

  /// No description provided for @clientsNotFound.
  ///
  /// In en, this message translates to:
  /// **'No Clients Match'**
  String get clientsNotFound;

  /// No description provided for @clientsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Clients Yet'**
  String get clientsEmpty;

  /// Message shown when search returns no results
  ///
  /// In en, this message translates to:
  /// **'No clients match \"{query}\"'**
  String clientsSearchEmpty(String query);

  /// No description provided for @clientsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clients will appear here when they make their first booking.'**
  String get clientsEmptySubtitle;

  /// No description provided for @walletLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletLabel;

  /// No description provided for @walletAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get walletAvailableBalance;

  /// No description provided for @walletWithdrawFunds.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Funds'**
  String get walletWithdrawFunds;

  /// No description provided for @walletTotalEarned.
  ///
  /// In en, this message translates to:
  /// **'Total Earned'**
  String get walletTotalEarned;

  /// No description provided for @walletTotalWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Total Withdrawn'**
  String get walletTotalWithdrawn;

  /// No description provided for @transactionDepositReceived.
  ///
  /// In en, this message translates to:
  /// **'Deposit Received'**
  String get transactionDepositReceived;

  /// No description provided for @transactionServicePayment.
  ///
  /// In en, this message translates to:
  /// **'Service Payment'**
  String get transactionServicePayment;

  /// No description provided for @transactionWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get transactionWithdrawal;

  /// No description provided for @transactionRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get transactionRefund;

  /// No description provided for @transactionPlatformFee.
  ///
  /// In en, this message translates to:
  /// **'Platform Fee'**
  String get transactionPlatformFee;

  /// No description provided for @transactionAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get transactionAdjustment;

  /// No description provided for @transactionToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get transactionToday;

  /// No description provided for @transactionYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get transactionYesterday;

  /// No description provided for @withdrawalTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdrawalTitle;

  /// Withdrawal information message with fee details
  ///
  /// In en, this message translates to:
  /// **'Withdrawals are processed immediately and sent to your connected account. A {fee}% fee (min {currency} {minFee}) applies.'**
  String withdrawalInfo(double fee, String currency, double minFee);

  /// Shows available balance for withdrawal
  ///
  /// In en, this message translates to:
  /// **'Available balance: {currency} {amount}'**
  String withdrawalAvailableBalance(String currency, String amount);

  /// Amount input field label with currency code
  ///
  /// In en, this message translates to:
  /// **'Amount ({currency})'**
  String withdrawalAmountInputLabel(String currency);

  /// No description provided for @withdrawalAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter amount to withdraw'**
  String get withdrawalAmountHint;

  /// No description provided for @withdrawalAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get withdrawalAmountRequired;

  /// No description provided for @withdrawalAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get withdrawalAmountInvalid;

  /// Minimum withdrawal validation error
  ///
  /// In en, this message translates to:
  /// **'Minimum withdrawal is {currency} {min}'**
  String withdrawalMinimum(String currency, double min);

  /// Maximum withdrawal validation error
  ///
  /// In en, this message translates to:
  /// **'Maximum withdrawal per transaction is {currency} {max}'**
  String withdrawalMaximum(String currency, double max);

  /// Insufficient balance validation error
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance. Available: {currency} {available}'**
  String withdrawalInsufficientBalance(String currency, String available);

  /// No description provided for @withdrawalBreakdownAmount.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal amount:'**
  String get withdrawalBreakdownAmount;

  /// No description provided for @withdrawalFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Fee ({fee}%):'**
  String withdrawalFeeLabel(Object fee);

  /// No description provided for @withdrawalNetAmount.
  ///
  /// In en, this message translates to:
  /// **'You will receive:'**
  String get withdrawalNetAmount;

  /// No description provided for @withdrawalProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get withdrawalProcessing;

  /// No description provided for @withdrawalRequestButton.
  ///
  /// In en, this message translates to:
  /// **'Request Withdrawal'**
  String get withdrawalRequestButton;

  /// No description provided for @withdrawalNoPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'No payment method connected'**
  String get withdrawalNoPaymentMethod;

  /// No description provided for @withdrawalSuccess.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal request submitted successfully!'**
  String get withdrawalSuccess;

  /// No description provided for @deadLetterTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal needs review'**
  String get deadLetterTitle;

  /// Single stuck withdrawal message
  ///
  /// In en, this message translates to:
  /// **'{currency} {amount} stuck — tap for details'**
  String deadLetterSingle(String currency, String amount);

  /// Multiple stuck withdrawals message
  ///
  /// In en, this message translates to:
  /// **'{currency} {amount} stuck across {count} withdrawals — tap for details'**
  String deadLetterMultiple(String currency, String amount, int count);

  /// No description provided for @deadLetterReason.
  ///
  /// In en, this message translates to:
  /// **'Reason:'**
  String get deadLetterReason;

  /// No description provided for @deadLetterContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get deadLetterContactSupport;

  /// No description provided for @paymentSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete payout setup'**
  String get paymentSetupTitle;

  /// No description provided for @paymentSetupContent.
  ///
  /// In en, this message translates to:
  /// **'Connect your payout account to start withdrawing money from your wallet. This could be your mobile money number or your bank account.'**
  String get paymentSetupContent;

  /// No description provided for @calendarErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading calendar'**
  String get calendarErrorLoading;

  /// No description provided for @calendarErrorLoadingBookings.
  ///
  /// In en, this message translates to:
  /// **'Error loading bookings'**
  String get calendarErrorLoadingBookings;

  /// No description provided for @calendarNoAppointmentsDay.
  ///
  /// In en, this message translates to:
  /// **'No appointments for this day'**
  String get calendarNoAppointmentsDay;

  /// No description provided for @calendarNoBookingsDay.
  ///
  /// In en, this message translates to:
  /// **'No bookings for this day'**
  String get calendarNoBookingsDay;

  /// Number of appointments with plural handling
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, one{appointment} other{appointments}}'**
  String calendarAppointmentCount(int count);

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDecember;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySunday;

  /// Snackbar message when no appointments found for selected day
  ///
  /// In en, this message translates to:
  /// **'No appointments on this day\n{date}'**
  String calendarNoAppointmentsSnackbar(String date);

  /// App bar title for shop reviews screen
  ///
  /// In en, this message translates to:
  /// **'Reviews for {shopName}'**
  String reviewsScreenTitle(String shopName);

  /// No description provided for @reviewsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load reviews'**
  String get reviewsLoadError;

  /// No description provided for @reviewsNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get reviewsNoReviews;

  /// No description provided for @reviewsRateProduct.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Product'**
  String get reviewsRateProduct;

  /// No description provided for @reviewsYourReview.
  ///
  /// In en, this message translates to:
  /// **'Your Review'**
  String get reviewsYourReview;

  /// No description provided for @reviewsReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with this product...'**
  String get reviewsReviewHint;

  /// No description provided for @reviewsSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get reviewsSubmitButton;

  /// No description provided for @reviewsThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your review!'**
  String get reviewsThankYou;

  /// Error message when review submission fails
  ///
  /// In en, this message translates to:
  /// **'Failed to submit review: {error}'**
  String reviewsSubmitError(String error);

  /// No description provided for @bookingServiceAddress.
  ///
  /// In en, this message translates to:
  /// **'Service Address'**
  String get bookingServiceAddress;

  /// No description provided for @bookingFindingAvailableTimes.
  ///
  /// In en, this message translates to:
  /// **'Finding available times...'**
  String get bookingFindingAvailableTimes;

  /// Error when workers fail to load during booking
  ///
  /// In en, this message translates to:
  /// **'Error loading workers: {error}'**
  String bookingErrorLoadingWorkers(String error);

  /// Error when distance validation fails
  ///
  /// In en, this message translates to:
  /// **'Error validating distance: {error}'**
  String bookingErrorValidatingDistance(String error);

  /// No description provided for @bookingAddSpecialRequirements.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get bookingAddSpecialRequirements;

  /// No description provided for @bookingCancelSpecialRequirements.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get bookingCancelSpecialRequirements;

  /// No description provided for @bookingSaveSpecialRequirements.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get bookingSaveSpecialRequirements;

  /// Error when special requirements fail to save
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String bookingFailedSaveRequirements(String error);

  /// No description provided for @bookingInvitationSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent successfully'**
  String get bookingInvitationSent;

  /// No description provided for @bookingSavingAssignments.
  ///
  /// In en, this message translates to:
  /// **'Saving assignments...'**
  String get bookingSavingAssignments;

  /// No description provided for @bookingAssignmentsSaved.
  ///
  /// In en, this message translates to:
  /// **'Assignments saved successfully'**
  String get bookingAssignmentsSaved;

  /// Error when assignments fail to save
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String bookingAssignmentsError(String error);

  /// No description provided for @scheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleTitle;

  /// No description provided for @scheduleTabDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get scheduleTabDaily;

  /// No description provided for @scheduleTabMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get scheduleTabMonthly;

  /// Tools tab card label for the loyalty rule editor (Phase 13).
  ///
  /// In en, this message translates to:
  /// **'Loyalty rule'**
  String get toolsLoyaltyRule;

  /// No description provided for @loyaltyTitle.
  ///
  /// In en, this message translates to:
  /// **'Loyalty rule'**
  String get loyaltyTitle;

  /// No description provided for @loyaltyRewardHeader.
  ///
  /// In en, this message translates to:
  /// **'Reward every Nth completed booking'**
  String get loyaltyRewardHeader;

  /// No description provided for @loyaltyRewardSubheader.
  ///
  /// In en, this message translates to:
  /// **'Clients never see their progress. The discount auto-applies on the qualifying booking as a surprise reward.'**
  String get loyaltyRewardSubheader;

  /// No description provided for @loyaltyTriggerSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Trigger every'**
  String get loyaltyTriggerSectionTitle;

  /// No description provided for @loyaltyTriggerCompletedBookings.
  ///
  /// In en, this message translates to:
  /// **'completed bookings'**
  String get loyaltyTriggerCompletedBookings;

  /// No description provided for @loyaltyDiscountTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Discount type'**
  String get loyaltyDiscountTypeTitle;

  /// No description provided for @loyaltyDiscountTypePercent.
  ///
  /// In en, this message translates to:
  /// **'Percent'**
  String get loyaltyDiscountTypePercent;

  /// No description provided for @loyaltyDiscountTypeFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed amount'**
  String get loyaltyDiscountTypeFixed;

  /// No description provided for @loyaltyPercentOff.
  ///
  /// In en, this message translates to:
  /// **'Percent off'**
  String get loyaltyPercentOff;

  /// No description provided for @loyaltyAmountOff.
  ///
  /// In en, this message translates to:
  /// **'Amount off'**
  String get loyaltyAmountOff;

  /// No description provided for @loyaltyActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get loyaltyActiveTitle;

  /// No description provided for @loyaltyActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When off, no loyalty codes are generated for this shop.'**
  String get loyaltyActiveSubtitle;

  /// No description provided for @loyaltyLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the loyalty rule.'**
  String get loyaltyLoadFailed;

  /// No description provided for @loyaltyRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get loyaltyRetry;

  /// No description provided for @loyaltySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get loyaltySave;

  /// No description provided for @loyaltySavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Loyalty rule saved'**
  String get loyaltySavedSnackbar;

  /// No description provided for @promoFieldPerClientMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'Per-client redemption limit'**
  String get promoFieldPerClientMaxLabel;

  /// No description provided for @promoFieldPerClientMaxHint.
  ///
  /// In en, this message translates to:
  /// **'Times one client can use this code'**
  String get promoFieldPerClientMaxHint;

  /// No description provided for @promoFieldMinAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum booking amount (Optional)'**
  String get promoFieldMinAmountLabel;

  /// No description provided for @promoFieldMinAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Code only applies above this total'**
  String get promoFieldMinAmountHint;

  /// No description provided for @promoFieldServiceRestrictionTitle.
  ///
  /// In en, this message translates to:
  /// **'Restrict to services (Optional)'**
  String get promoFieldServiceRestrictionTitle;

  /// No description provided for @promoFieldServiceRestrictionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to apply to any service. Pick one or more to restrict the discount to bookings that include them.'**
  String get promoFieldServiceRestrictionSubtitle;

  /// No description provided for @promoFieldServiceRestrictionLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your services.'**
  String get promoFieldServiceRestrictionLoadFailed;

  /// No description provided for @promoFieldServiceRestrictionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No services to restrict against yet.'**
  String get promoFieldServiceRestrictionEmpty;

  /// No description provided for @promoFieldArchivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get promoFieldArchivedTitle;

  /// No description provided for @promoFieldArchivedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Archived promotions are hidden from clients and frees up the code text for re-use.'**
  String get promoFieldArchivedSubtitle;

  /// No description provided for @promoValidationPerClientMin.
  ///
  /// In en, this message translates to:
  /// **'Must be at least 1'**
  String get promoValidationPerClientMin;

  /// No description provided for @promoValidationMinAmountNonNegative.
  ///
  /// In en, this message translates to:
  /// **'Must be 0 or higher'**
  String get promoValidationMinAmountNonNegative;

  /// No description provided for @promoListShowSystemCodes.
  ///
  /// In en, this message translates to:
  /// **'Show system codes'**
  String get promoListShowSystemCodes;

  /// No description provided for @promoListHideSystemCodes.
  ///
  /// In en, this message translates to:
  /// **'Hide system codes'**
  String get promoListHideSystemCodes;

  /// No description provided for @promoSourceOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get promoSourceOwner;

  /// No description provided for @promoSourceLoyalty.
  ///
  /// In en, this message translates to:
  /// **'Loyalty'**
  String get promoSourceLoyalty;

  /// No description provided for @promoSourceRecovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get promoSourceRecovery;

  /// No description provided for @promoSourceAutoGeneratedReadOnly.
  ///
  /// In en, this message translates to:
  /// **'auto-generated · read-only'**
  String get promoSourceAutoGeneratedReadOnly;

  /// No description provided for @broadcastsTitle.
  ///
  /// In en, this message translates to:
  /// **'Broadcasts'**
  String get broadcastsTitle;

  /// No description provided for @broadcastsToolsCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Broadcasts'**
  String get broadcastsToolsCardLabel;

  /// No description provided for @broadcastsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No broadcasts yet'**
  String get broadcastsEmptyTitle;

  /// No description provided for @broadcastsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap + to send your first. You can broadcast once per day to up to 1000 clients.'**
  String get broadcastsEmptyBody;

  /// No description provided for @broadcastsFabTooltip.
  ///
  /// In en, this message translates to:
  /// **'New broadcast'**
  String get broadcastsFabTooltip;

  /// No description provided for @broadcastsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your broadcasts.'**
  String get broadcastsLoadFailed;

  /// No description provided for @broadcastsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get broadcastsRetry;

  /// No description provided for @broadcastCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New broadcast'**
  String get broadcastCreateTitle;

  /// No description provided for @broadcastSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get broadcastSubjectLabel;

  /// No description provided for @broadcastSubjectHelper.
  ///
  /// In en, this message translates to:
  /// **'Shown as the push notification title.'**
  String get broadcastSubjectHelper;

  /// No description provided for @broadcastSubjectRequired.
  ///
  /// In en, this message translates to:
  /// **'Subject is required.'**
  String get broadcastSubjectRequired;

  /// No description provided for @broadcastBodyLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get broadcastBodyLabel;

  /// No description provided for @broadcastBodyHelper.
  ///
  /// In en, this message translates to:
  /// **'Plain text only. WhatsApp recipients also see your shop name and an opt-out line.'**
  String get broadcastBodyHelper;

  /// No description provided for @broadcastBodyRequired.
  ///
  /// In en, this message translates to:
  /// **'Message is required.'**
  String get broadcastBodyRequired;

  /// No description provided for @broadcastAudienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Audience'**
  String get broadcastAudienceLabel;

  /// No description provided for @broadcastAudienceAllClients.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get broadcastAudienceAllClients;

  /// No description provided for @broadcastAudienceRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get broadcastAudienceRecent;

  /// No description provided for @broadcastAudienceLapsed.
  ///
  /// In en, this message translates to:
  /// **'Lapsed'**
  String get broadcastAudienceLapsed;

  /// No description provided for @broadcastAudienceByService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get broadcastAudienceByService;

  /// No description provided for @broadcastServiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get broadcastServiceLabel;

  /// No description provided for @broadcastServicePickRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick a service.'**
  String get broadcastServicePickRequired;

  /// No description provided for @broadcastServiceLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your services.'**
  String get broadcastServiceLoadFailed;

  /// No description provided for @broadcastServiceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No active services to pick from.'**
  String get broadcastServiceEmpty;

  /// No description provided for @broadcastPromoLabel.
  ///
  /// In en, this message translates to:
  /// **'Attach a promo code (optional)'**
  String get broadcastPromoLabel;

  /// No description provided for @broadcastPromoHelper.
  ///
  /// In en, this message translates to:
  /// **'Only your own promo codes can be attached. Loyalty and recovery codes aren\'t shown.'**
  String get broadcastPromoHelper;

  /// No description provided for @broadcastPromoNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get broadcastPromoNone;

  /// No description provided for @broadcastPreviewResolving.
  ///
  /// In en, this message translates to:
  /// **'Resolving audience…'**
  String get broadcastPreviewResolving;

  /// No description provided for @broadcastPreviewPickAudience.
  ///
  /// In en, this message translates to:
  /// **'Pick an audience to preview.'**
  String get broadcastPreviewPickAudience;

  /// No description provided for @broadcastPreviewPickService.
  ///
  /// In en, this message translates to:
  /// **'Pick a service to preview.'**
  String get broadcastPreviewPickService;

  /// No description provided for @broadcastPreviewCount.
  ///
  /// In en, this message translates to:
  /// **'This will send to {count} people.'**
  String broadcastPreviewCount(Object count);

  /// No description provided for @broadcastPreviewCapWarning.
  ///
  /// In en, this message translates to:
  /// **'Audience exceeds the 1000-recipient cap. Try a narrower preset.'**
  String get broadcastPreviewCapWarning;

  /// No description provided for @broadcastPreviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t preview audience.'**
  String get broadcastPreviewFailed;

  /// No description provided for @broadcastSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get broadcastSendButton;

  /// No description provided for @broadcastConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Send broadcast?'**
  String get broadcastConfirmTitle;

  /// No description provided for @broadcastConfirmBodyAll.
  ///
  /// In en, this message translates to:
  /// **'Send to {count} all clients? This cannot be undone.'**
  String broadcastConfirmBodyAll(Object count);

  /// No description provided for @broadcastConfirmBodyRecent.
  ///
  /// In en, this message translates to:
  /// **'Send to {count} recent clients? This cannot be undone.'**
  String broadcastConfirmBodyRecent(Object count);

  /// No description provided for @broadcastConfirmBodyLapsed.
  ///
  /// In en, this message translates to:
  /// **'Send to {count} lapsed clients? This cannot be undone.'**
  String broadcastConfirmBodyLapsed(Object count);

  /// No description provided for @broadcastConfirmBodyService.
  ///
  /// In en, this message translates to:
  /// **'Send to {count} clients of this service? This cannot be undone.'**
  String broadcastConfirmBodyService(Object count);

  /// No description provided for @broadcastConfirmBodyWithPromoSuffix.
  ///
  /// In en, this message translates to:
  /// **' A promo code will be attached.'**
  String get broadcastConfirmBodyWithPromoSuffix;

  /// No description provided for @broadcastConfirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get broadcastConfirmCancel;

  /// No description provided for @broadcastConfirmSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get broadcastConfirmSend;

  /// No description provided for @broadcastSentToast.
  ///
  /// In en, this message translates to:
  /// **'Sent to {count} people.'**
  String broadcastSentToast(Object count);

  /// No description provided for @broadcastStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get broadcastStatusPending;

  /// No description provided for @broadcastStatusDelivering.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get broadcastStatusDelivering;

  /// No description provided for @broadcastStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get broadcastStatusDelivered;

  /// No description provided for @broadcastStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get broadcastStatusFailed;

  /// No description provided for @broadcastDeliveringTooltip.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp template approval is pending. This usually resolves within 24h.'**
  String get broadcastDeliveringTooltip;

  /// No description provided for @broadcastAudienceLabelShort.
  ///
  /// In en, this message translates to:
  /// **'Audience: {audience}'**
  String broadcastAudienceLabelShort(Object audience);

  /// No description provided for @broadcastPromoLabelShort.
  ///
  /// In en, this message translates to:
  /// **'Promo attached: {id}'**
  String broadcastPromoLabelShort(Object id);

  /// No description provided for @broadcastRecipientsLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipients: {count}'**
  String broadcastRecipientsLabel(Object count);

  /// No description provided for @broadcastDeliveredLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivered: {when}'**
  String broadcastDeliveredLabel(Object when);

  /// No description provided for @broadcastStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String broadcastStatusLabel(Object status);

  /// No description provided for @broadcastDetailClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get broadcastDetailClose;

  /// No description provided for @broadcastRateLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already sent a broadcast today. Try again tomorrow.'**
  String get broadcastRateLimitMessage;

  /// No description provided for @broadcastInFlightMessage.
  ///
  /// In en, this message translates to:
  /// **'Another broadcast is being processed. Please wait a moment.'**
  String get broadcastInFlightMessage;

  /// No description provided for @broadcastInvalidAudienceMessage.
  ///
  /// In en, this message translates to:
  /// **'Please pick a valid audience and (if \'By service\') a service.'**
  String get broadcastInvalidAudienceMessage;

  /// No description provided for @broadcastPromoInvalidMessage.
  ///
  /// In en, this message translates to:
  /// **'This code is no longer valid. Pick another or remove the code.'**
  String get broadcastPromoInvalidMessage;

  /// No description provided for @broadcastCapExceededMessage.
  ///
  /// In en, this message translates to:
  /// **'This audience is larger than the 1000-recipient cap. Try a narrower audience.'**
  String get broadcastCapExceededMessage;

  /// No description provided for @broadcastSaveFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not send broadcast. Please try again.'**
  String get broadcastSaveFailedMessage;

  /// No description provided for @pricingChipDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get pricingChipDiscount;

  /// No description provided for @pricingChipSurcharge.
  ///
  /// In en, this message translates to:
  /// **'Surcharge'**
  String get pricingChipSurcharge;

  /// No description provided for @pricingOverridesTitle.
  ///
  /// In en, this message translates to:
  /// **'Pricing rules'**
  String get pricingOverridesTitle;

  /// No description provided for @pricingOverridesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No rules yet'**
  String get pricingOverridesEmptyTitle;

  /// No description provided for @pricingOverridesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add a time-based discount or surcharge for {serviceName}.'**
  String pricingOverridesEmptyBody(String serviceName);

  /// No description provided for @pricingOverridesEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Create rule'**
  String get pricingOverridesEmptyCta;

  /// No description provided for @pricingOverridesNewCta.
  ///
  /// In en, this message translates to:
  /// **'New rule'**
  String get pricingOverridesNewCta;

  /// No description provided for @pricingOverridesRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get pricingOverridesRefresh;

  /// No description provided for @pricingOverridesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load pricing rules.'**
  String get pricingOverridesLoadFailed;

  /// No description provided for @pricingOverridesRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get pricingOverridesRetry;

  /// No description provided for @pricingOverrideArchiveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive rule?'**
  String get pricingOverrideArchiveConfirmTitle;

  /// No description provided for @pricingOverrideArchiveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will stop applying to new bookings. Existing bookings keep the price they were confirmed at.'**
  String pricingOverrideArchiveConfirmBody(String name);

  /// No description provided for @pricingOverrideArchiveConfirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get pricingOverrideArchiveConfirmCancel;

  /// No description provided for @pricingOverrideArchiveConfirmArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get pricingOverrideArchiveConfirmArchive;

  /// No description provided for @pricingOverrideArchiveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Rule archived'**
  String get pricingOverrideArchiveSuccess;

  /// No description provided for @pricingOverrideArchiveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not archive the rule. Please try again.'**
  String get pricingOverrideArchiveFailed;

  /// No description provided for @pricingOverrideRowActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get pricingOverrideRowActionsTooltip;

  /// No description provided for @pricingOverrideRowEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get pricingOverrideRowEdit;

  /// No description provided for @pricingOverrideRowArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get pricingOverrideRowArchive;

  /// No description provided for @pricingOverrideAllWeek.
  ///
  /// In en, this message translates to:
  /// **'All week'**
  String get pricingOverrideAllWeek;

  /// No description provided for @pricingOverrideFormTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New rule'**
  String get pricingOverrideFormTitleNew;

  /// No description provided for @pricingOverrideFormTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit rule'**
  String get pricingOverrideFormTitleEdit;

  /// No description provided for @pricingOverrideFormName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get pricingOverrideFormName;

  /// No description provided for @pricingOverrideFormNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Off-peak Tuesday morning'**
  String get pricingOverrideFormNameHint;

  /// No description provided for @pricingOverrideFormNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get pricingOverrideFormNameRequired;

  /// No description provided for @pricingOverrideFormNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Max 80 characters'**
  String get pricingOverrideFormNameTooLong;

  /// No description provided for @pricingOverrideFormDayOfWeek.
  ///
  /// In en, this message translates to:
  /// **'Day of week'**
  String get pricingOverrideFormDayOfWeek;

  /// No description provided for @pricingOverrideFormTimeWindow.
  ///
  /// In en, this message translates to:
  /// **'Time window'**
  String get pricingOverrideFormTimeWindow;

  /// No description provided for @pricingOverrideFormStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get pricingOverrideFormStart;

  /// No description provided for @pricingOverrideFormEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get pricingOverrideFormEnd;

  /// No description provided for @pricingOverrideFormWindowError.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time'**
  String get pricingOverrideFormWindowError;

  /// No description provided for @pricingOverrideFormAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get pricingOverrideFormAdjustment;

  /// No description provided for @pricingOverrideFormKindPercentDiscount.
  ///
  /// In en, this message translates to:
  /// **'% off'**
  String get pricingOverrideFormKindPercentDiscount;

  /// No description provided for @pricingOverrideFormKindPercentSurcharge.
  ///
  /// In en, this message translates to:
  /// **'% up'**
  String get pricingOverrideFormKindPercentSurcharge;

  /// No description provided for @pricingOverrideFormKindFixedDiscount.
  ///
  /// In en, this message translates to:
  /// **'\$ off'**
  String get pricingOverrideFormKindFixedDiscount;

  /// No description provided for @pricingOverrideFormKindFixedSurcharge.
  ///
  /// In en, this message translates to:
  /// **'\$ up'**
  String get pricingOverrideFormKindFixedSurcharge;

  /// No description provided for @pricingOverrideFormValueRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get pricingOverrideFormValueRequired;

  /// No description provided for @pricingOverrideFormValueMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than 0'**
  String get pricingOverrideFormValueMustBePositive;

  /// No description provided for @pricingOverrideFormValuePercentRange.
  ///
  /// In en, this message translates to:
  /// **'Percent must be 0.01–100'**
  String get pricingOverrideFormValuePercentRange;

  /// No description provided for @pricingOverrideFormValidity.
  ///
  /// In en, this message translates to:
  /// **'Validity (optional)'**
  String get pricingOverrideFormValidity;

  /// No description provided for @pricingOverrideFormValidityStarts.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get pricingOverrideFormValidityStarts;

  /// No description provided for @pricingOverrideFormValidityEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get pricingOverrideFormValidityEnds;

  /// No description provided for @pricingOverrideFormValidityNoExpiry.
  ///
  /// In en, this message translates to:
  /// **'No expiry'**
  String get pricingOverrideFormValidityNoExpiry;

  /// No description provided for @pricingOverrideFormValidityToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get pricingOverrideFormValidityToday;

  /// No description provided for @pricingOverrideFormValidityError.
  ///
  /// In en, this message translates to:
  /// **'End date must be after start date'**
  String get pricingOverrideFormValidityError;

  /// No description provided for @pricingOverrideFormClearDayHint.
  ///
  /// In en, this message translates to:
  /// **'To clear the day filter, archive this rule and create a new one.'**
  String get pricingOverrideFormClearDayHint;

  /// No description provided for @pricingOverrideFormClearValidUntilHint.
  ///
  /// In en, this message translates to:
  /// **'To clear the end date, archive this rule and create a new one.'**
  String get pricingOverrideFormClearValidUntilHint;

  /// No description provided for @pricingOverrideFormPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get pricingOverrideFormPreviewLabel;

  /// No description provided for @pricingOverrideFormPreviewPrompt.
  ///
  /// In en, this message translates to:
  /// **'Base {base} · enter a value to see the effective price.'**
  String pricingOverrideFormPreviewPrompt(String base);

  /// No description provided for @pricingOverrideFormPreviewDiscount.
  ///
  /// In en, this message translates to:
  /// **'(saved {delta} vs {base} base)'**
  String pricingOverrideFormPreviewDiscount(String delta, String base);

  /// No description provided for @pricingOverrideFormPreviewSurcharge.
  ///
  /// In en, this message translates to:
  /// **'(+{delta} vs {base} base)'**
  String pricingOverrideFormPreviewSurcharge(String delta, String base);

  /// No description provided for @pricingOverrideFormSoftWarnPercent.
  ///
  /// In en, this message translates to:
  /// **'This is a +{value}% surcharge. Double-check before saving.'**
  String pricingOverrideFormSoftWarnPercent(String value);

  /// No description provided for @pricingOverrideFormSoftWarnFixed.
  ///
  /// In en, this message translates to:
  /// **'This surcharge is more than 5× the base price. Double-check before saving.'**
  String get pricingOverrideFormSoftWarnFixed;

  /// No description provided for @pricingOverrideFormSaveNew.
  ///
  /// In en, this message translates to:
  /// **'Create rule'**
  String get pricingOverrideFormSaveNew;

  /// No description provided for @pricingOverrideFormSaveEdit.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get pricingOverrideFormSaveEdit;

  /// No description provided for @pricingOverrideFormDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get pricingOverrideFormDiscardTitle;

  /// No description provided for @pricingOverrideFormDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Your edits will be lost.'**
  String get pricingOverrideFormDiscardBody;

  /// No description provided for @pricingOverrideFormDiscardKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get pricingOverrideFormDiscardKeep;

  /// No description provided for @pricingOverrideFormDiscardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get pricingOverrideFormDiscardConfirm;

  /// No description provided for @pricingOverrideCreatedToast.
  ///
  /// In en, this message translates to:
  /// **'Rule created'**
  String get pricingOverrideCreatedToast;

  /// No description provided for @pricingOverrideUpdatedToast.
  ///
  /// In en, this message translates to:
  /// **'Rule updated'**
  String get pricingOverrideUpdatedToast;

  /// No description provided for @pricingOverrideErrorWindow.
  ///
  /// In en, this message translates to:
  /// **'The end time must be after the start time.'**
  String get pricingOverrideErrorWindow;

  /// No description provided for @pricingOverrideErrorDay.
  ///
  /// In en, this message translates to:
  /// **'Please pick a valid day of the week.'**
  String get pricingOverrideErrorDay;

  /// No description provided for @pricingOverrideErrorAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Please re-check the discount amount.'**
  String get pricingOverrideErrorAdjustment;

  /// No description provided for @pricingOverrideErrorValidity.
  ///
  /// In en, this message translates to:
  /// **'The end date must be after the start date.'**
  String get pricingOverrideErrorValidity;

  /// No description provided for @pricingOverrideErrorCap.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the 50-rule limit on this service. Archive an old rule to free a slot.'**
  String get pricingOverrideErrorCap;

  /// No description provided for @pricingOverrideErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that pricing rule.'**
  String get pricingOverrideErrorNotFound;

  /// No description provided for @pricingOverrideErrorSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save the rule. Please try again.'**
  String get pricingOverrideErrorSaveFailed;

  /// No description provided for @pricingOverrideDayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get pricingOverrideDayMonday;

  /// No description provided for @pricingOverrideDayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get pricingOverrideDayTuesday;

  /// No description provided for @pricingOverrideDayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get pricingOverrideDayWednesday;

  /// No description provided for @pricingOverrideDayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get pricingOverrideDayThursday;

  /// No description provided for @pricingOverrideDayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get pricingOverrideDayFriday;

  /// No description provided for @pricingOverrideDaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get pricingOverrideDaySaturday;

  /// No description provided for @pricingOverrideDaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get pricingOverrideDaySunday;

  /// No description provided for @pricingOverrideDayShortMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get pricingOverrideDayShortMon;

  /// No description provided for @pricingOverrideDayShortTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get pricingOverrideDayShortTue;

  /// No description provided for @pricingOverrideDayShortWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get pricingOverrideDayShortWed;

  /// No description provided for @pricingOverrideDayShortThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get pricingOverrideDayShortThu;

  /// No description provided for @pricingOverrideDayShortFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get pricingOverrideDayShortFri;

  /// No description provided for @pricingOverrideDayShortSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get pricingOverrideDayShortSat;

  /// No description provided for @pricingOverrideDayShortSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get pricingOverrideDayShortSun;

  /// No description provided for @dailyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s report'**
  String get dailyReportTitle;

  /// No description provided for @dailyReportHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Past reports'**
  String get dailyReportHistoryTitle;

  /// No description provided for @dailyReportNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s report is ready'**
  String get dailyReportNotificationTitle;

  /// No description provided for @dailyReportRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get dailyReportRefresh;

  /// No description provided for @dailyReportRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get dailyReportRetry;

  /// No description provided for @dailyReportLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the report.'**
  String get dailyReportLoadFailed;

  /// No description provided for @dailyReportHistoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load history.'**
  String get dailyReportHistoryLoadFailed;

  /// No description provided for @dailyReportRevenueLabel.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get dailyReportRevenueLabel;

  /// No description provided for @dailyReportBookingsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get dailyReportBookingsCompleted;

  /// No description provided for @dailyReportBookingsNoShow.
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get dailyReportBookingsNoShow;

  /// No description provided for @dailyReportBookingsCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get dailyReportBookingsCancelled;

  /// No description provided for @dailyReportBookingsConfirmedPastEnd.
  ///
  /// In en, this message translates to:
  /// **'Confirmed past end'**
  String get dailyReportBookingsConfirmedPastEnd;

  /// No description provided for @dailyReportComparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Comparison'**
  String get dailyReportComparisonTitle;

  /// No description provided for @dailyReportComparisonYesterday.
  ///
  /// In en, this message translates to:
  /// **'vs yesterday'**
  String get dailyReportComparisonYesterday;

  /// No description provided for @dailyReportComparisonLastWeek.
  ///
  /// In en, this message translates to:
  /// **'vs same day last week'**
  String get dailyReportComparisonLastWeek;

  /// No description provided for @dailyReportComparisonNoData.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get dailyReportComparisonNoData;

  /// No description provided for @dailyReportPerWorkerTitle.
  ///
  /// In en, this message translates to:
  /// **'By staff'**
  String get dailyReportPerWorkerTitle;

  /// No description provided for @dailyReportPerServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'By service'**
  String get dailyReportPerServiceTitle;

  /// No description provided for @dailyReportWorkerUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get dailyReportWorkerUnassigned;

  /// No description provided for @dailyReportTomorrowTitle.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dailyReportTomorrowTitle;

  /// No description provided for @dailyReportTomorrowFirstBookingAt.
  ///
  /// In en, this message translates to:
  /// **'First booking at {time}'**
  String dailyReportTomorrowFirstBookingAt(String time);

  /// No description provided for @dailyReportTomorrowCount.
  ///
  /// In en, this message translates to:
  /// **'{count} bookings'**
  String dailyReportTomorrowCount(int count);

  /// No description provided for @dailyReportTomorrowGroupFlag.
  ///
  /// In en, this message translates to:
  /// **'Includes group bookings'**
  String get dailyReportTomorrowGroupFlag;

  /// No description provided for @dailyReportTomorrowEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bookings tomorrow.'**
  String get dailyReportTomorrowEmpty;

  /// No description provided for @dailyReportFollowUpsTitle.
  ///
  /// In en, this message translates to:
  /// **'Needs your attention'**
  String get dailyReportFollowUpsTitle;

  /// No description provided for @dailyReportFollowUpConfirmedPastEnd.
  ///
  /// In en, this message translates to:
  /// **'Confirmed but never closed out'**
  String get dailyReportFollowUpConfirmedPastEnd;

  /// No description provided for @dailyReportFollowUpUnpaidBalance.
  ///
  /// In en, this message translates to:
  /// **'Unpaid balance'**
  String get dailyReportFollowUpUnpaidBalance;

  /// No description provided for @dailyReportFollowUpNoShowNoAction.
  ///
  /// In en, this message translates to:
  /// **'No-show — no note logged'**
  String get dailyReportFollowUpNoShowNoAction;

  /// No description provided for @dailyReportRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Re-generate'**
  String get dailyReportRegenerate;

  /// No description provided for @dailyReportRegenerateConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-generate this report?'**
  String get dailyReportRegenerateConfirmTitle;

  /// No description provided for @dailyReportRegenerateConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This rebuilds the report from the current data. The previous version is overwritten.'**
  String get dailyReportRegenerateConfirmBody;

  /// No description provided for @dailyReportRegenerateConfirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dailyReportRegenerateConfirmCancel;

  /// No description provided for @dailyReportRegenerateConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Re-generate'**
  String get dailyReportRegenerateConfirmAction;

  /// No description provided for @dailyReportRegenerated.
  ///
  /// In en, this message translates to:
  /// **'Report updated.'**
  String get dailyReportRegenerated;

  /// No description provided for @dailyReportEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No report yet'**
  String get dailyReportEmptyTitle;

  /// No description provided for @dailyReportEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No bookings recorded for this date. Tap Re-generate to build an empty report.'**
  String get dailyReportEmptyBody;

  /// No description provided for @dailyReportHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No past reports yet.'**
  String get dailyReportHistoryEmpty;

  /// No description provided for @dailyReportErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t build the report. Please try again.'**
  String get dailyReportErrorGeneric;

  /// No description provided for @docsGettingStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get docsGettingStartedTitle;

  /// No description provided for @docsGettingStartedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn the basics'**
  String get docsGettingStartedSubtitle;

  /// No description provided for @docsGettingStartedWhatIsTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Aura In?'**
  String get docsGettingStartedWhatIsTitle;

  /// No description provided for @docsGettingStartedWhatIsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Understand the platform'**
  String get docsGettingStartedWhatIsSubtitle;

  /// No description provided for @docsGettingStartedWelcomeIntroContent.
  ///
  /// In en, this message translates to:
  /// **'Aura In is a mobile marketplace connecting service professionals with customers. Whether you offer haircuts, massages, freelance services, or sell products, this platform helps you grow your business.'**
  String get docsGettingStartedWelcomeIntroContent;

  /// No description provided for @docsGettingStartedWhoUsesTitle.
  ///
  /// In en, this message translates to:
  /// **'Who Uses Aura In?'**
  String get docsGettingStartedWhoUsesTitle;

  /// No description provided for @docsGettingStartedWhoUsesContent.
  ///
  /// In en, this message translates to:
  /// **'Two types of users power the platform:'**
  String get docsGettingStartedWhoUsesContent;

  /// No description provided for @docsGettingStartedWhoUsesProviders.
  ///
  /// In en, this message translates to:
  /// **'Service Providers - Salons, spas, barbers, freelancers who offer services'**
  String get docsGettingStartedWhoUsesProviders;

  /// No description provided for @docsGettingStartedWhoUsesCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers - People searching for and booking services in their area'**
  String get docsGettingStartedWhoUsesCustomers;

  /// No description provided for @docsGettingStartedWhoUsesSellers.
  ///
  /// In en, this message translates to:
  /// **'Product Sellers - Shops selling retail products or handmade items'**
  String get docsGettingStartedWhoUsesSellers;

  /// No description provided for @docsGettingStartedHowItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get docsGettingStartedHowItWorksTitle;

  /// No description provided for @docsGettingStartedHowItWorksContent.
  ///
  /// In en, this message translates to:
  /// **'Service providers create a profile, list their services with pricing, and accept bookings from customers. Customers search by location, browse services, and book appointments. Everything is managed through the app.'**
  String get docsGettingStartedHowItWorksContent;

  /// No description provided for @docsGettingStartedThreeWaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Three Ways to Use Aura In'**
  String get docsGettingStartedThreeWaysTitle;

  /// No description provided for @docsGettingStartedThreeWaysSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your role'**
  String get docsGettingStartedThreeWaysSubtitle;

  /// No description provided for @docsGettingStartedOption1Title.
  ///
  /// In en, this message translates to:
  /// **'Option 1: Browse & Book Services (Customer)'**
  String get docsGettingStartedOption1Title;

  /// No description provided for @docsGettingStartedOption1Content.
  ///
  /// In en, this message translates to:
  /// **'Search for salons, massage therapists, barbers, or freelancers near you. View their services, pricing, and availability. Book appointments directly through the app and pay securely.'**
  String get docsGettingStartedOption1Content;

  /// No description provided for @docsGettingStartedGuestBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest Booking (No App Download Needed)'**
  String get docsGettingStartedGuestBookingTitle;

  /// No description provided for @docsGettingStartedGuestBookingContent.
  ///
  /// In en, this message translates to:
  /// **'Don\'t want to download the app? Service providers can share a booking link - you can book and pay directly through that link without creating an account. Your booking details and receipt will be sent to your WhatsApp.'**
  String get docsGettingStartedGuestBookingContent;

  /// No description provided for @docsGettingStartedOption2Title.
  ///
  /// In en, this message translates to:
  /// **'Option 2: Offer Services (Shop Owner or Freelancer)'**
  String get docsGettingStartedOption2Title;

  /// No description provided for @docsGettingStartedOption2Content.
  ///
  /// In en, this message translates to:
  /// **'Create a shop or freelancer profile, list your services with pricing and duration, set your working hours, and manage bookings. Get paid for every service booked.'**
  String get docsGettingStartedOption2Content;

  /// No description provided for @docsGettingStartedOption3Title.
  ///
  /// In en, this message translates to:
  /// **'Option 3: Sell Products (Product Seller)'**
  String get docsGettingStartedOption3Title;

  /// No description provided for @docsGettingStartedOption3Content.
  ///
  /// In en, this message translates to:
  /// **'If you make handmade items or retail products, you can list them for sale. Customers browse and purchase directly from your shop.'**
  String get docsGettingStartedOption3Content;

  /// No description provided for @docsGettingStartedBookingPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking & Payment System'**
  String get docsGettingStartedBookingPaymentTitle;

  /// No description provided for @docsGettingStartedBookingPaymentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How service booking and payment work'**
  String get docsGettingStartedBookingPaymentSubtitle;

  /// No description provided for @docsGettingStartedBookingOverviewContent.
  ///
  /// In en, this message translates to:
  /// **'Customers book appointments with service providers. Payments are handled securely through the app using Paystack (Africa) or Stripe (Global).'**
  String get docsGettingStartedBookingOverviewContent;

  /// No description provided for @docsGettingStartedDepositPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit Payment (30%)'**
  String get docsGettingStartedDepositPaymentTitle;

  /// No description provided for @docsGettingStartedDepositPaymentContent.
  ///
  /// In en, this message translates to:
  /// **'When booking a service, customers pay 30% upfront as a deposit to secure the time slot. This confirms the booking is real and reserved.'**
  String get docsGettingStartedDepositPaymentContent;

  /// No description provided for @docsGettingStartedPlatformFeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Platform Fee'**
  String get docsGettingStartedPlatformFeeTitle;

  /// No description provided for @docsGettingStartedPlatformFeeContent.
  ///
  /// In en, this message translates to:
  /// **'A small platform fee (2%) is added to help us maintain the platform and provide support. This is calculated on the total booking amount.'**
  String get docsGettingStartedPlatformFeeContent;

  /// No description provided for @docsGettingStartedRemainingPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Remaining Payment (70%)'**
  String get docsGettingStartedRemainingPaymentTitle;

  /// No description provided for @docsGettingStartedRemainingPaymentContent.
  ///
  /// In en, this message translates to:
  /// **'The remaining 70% can be paid either: (1) in cash when the service is completed, or (2) online through the app before the appointment.'**
  String get docsGettingStartedRemainingPaymentContent;

  /// No description provided for @docsGettingStartedGuestBookingPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest Booking Payment'**
  String get docsGettingStartedGuestBookingPaymentTitle;

  /// No description provided for @docsGettingStartedGuestBookingPaymentContent.
  ///
  /// In en, this message translates to:
  /// **'No app download needed! Customers receive a booking link from the service provider. They pay 30% to secure the slot, and their receipt is sent to WhatsApp.'**
  String get docsGettingStartedGuestBookingPaymentContent;

  /// No description provided for @docsGettingStartedProductOrderingTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Ordering & Delivery'**
  String get docsGettingStartedProductOrderingTitle;

  /// No description provided for @docsGettingStartedProductOrderingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How product sales work'**
  String get docsGettingStartedProductOrderingSubtitle;

  /// No description provided for @docsGettingStartedProductOverviewContent.
  ///
  /// In en, this message translates to:
  /// **'Customers browse products, add items to cart, and checkout. Products are delivered to the customer\'s location.'**
  String get docsGettingStartedProductOverviewContent;

  /// No description provided for @docsGettingStartedCODPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery (COD)'**
  String get docsGettingStartedCODPaymentTitle;

  /// No description provided for @docsGettingStartedCODPaymentContent.
  ///
  /// In en, this message translates to:
  /// **'For product orders, payment is handled as Cash on Delivery. Customers pay the seller when they receive the items - no upfront payment needed.'**
  String get docsGettingStartedCODPaymentContent;

  /// No description provided for @docsGettingStartedShareYourProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Your Profile'**
  String get docsGettingStartedShareYourProfileTitle;

  /// No description provided for @docsGettingStartedShareYourProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make it easy for customers to find you'**
  String get docsGettingStartedShareYourProfileSubtitle;

  /// No description provided for @docsGettingStartedShareLinkContent.
  ///
  /// In en, this message translates to:
  /// **'As a service provider, you get a unique booking link. Share it on WhatsApp, social media, or email. Customers can book services without downloading the app.'**
  String get docsGettingStartedShareLinkContent;

  /// No description provided for @docsGettingStartedCustomURLTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom URL (Optional)'**
  String get docsGettingStartedCustomURLTitle;

  /// No description provided for @docsGettingStartedCustomURLContent.
  ///
  /// In en, this message translates to:
  /// **'You can customize your booking link slug (e.g., aura.in/glamour-salon instead of aura.in/abc123). Makes it easier to share and remember.'**
  String get docsGettingStartedCustomURLContent;

  /// No description provided for @docsGettingStartedGetHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Get Help'**
  String get docsGettingStartedGetHelpTitle;

  /// No description provided for @docsGettingStartedGetHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Where to find answers'**
  String get docsGettingStartedGetHelpSubtitle;

  /// No description provided for @docsGettingStartedHelpDocumentationContent.
  ///
  /// In en, this message translates to:
  /// **'This app has comprehensive documentation for every feature. When you need help, check the relevant guide - there\'s one for your role and the feature you\'re using.'**
  String get docsGettingStartedHelpDocumentationContent;

  /// No description provided for @docsGettingStartedFAQ1Question.
  ///
  /// In en, this message translates to:
  /// **'What is Aura In?'**
  String get docsGettingStartedFAQ1Question;

  /// No description provided for @docsGettingStartedFAQ1Answer.
  ///
  /// In en, this message translates to:
  /// **'Aura In is a mobile marketplace for service-based businesses. Customers find and book services (haircuts, massages, etc.), service providers manage bookings and revenue, and product sellers list items for sale.'**
  String get docsGettingStartedFAQ1Answer;

  /// No description provided for @docsGettingStartedFAQ2Question.
  ///
  /// In en, this message translates to:
  /// **'Do I need to pay to use the app?'**
  String get docsGettingStartedFAQ2Question;

  /// No description provided for @docsGettingStartedFAQ2Answer.
  ///
  /// In en, this message translates to:
  /// **'The app is free to download and use. Service providers only pay a small commission when customers pay for services. Payment processors (Paystack/Stripe) take a fee.'**
  String get docsGettingStartedFAQ2Answer;

  /// No description provided for @docsGettingStartedFAQ3Question.
  ///
  /// In en, this message translates to:
  /// **'What is the difference between Shop Owner and Freelancer?'**
  String get docsGettingStartedFAQ3Question;

  /// No description provided for @docsGettingStartedFAQ3Answer.
  ///
  /// In en, this message translates to:
  /// **'Shop owners have a fixed location with a team of workers. Freelancers work independently and can travel to clients. Choose based on your business model.'**
  String get docsGettingStartedFAQ3Answer;

  /// No description provided for @docsGettingStartedFAQ4Question.
  ///
  /// In en, this message translates to:
  /// **'How do I get paid?'**
  String get docsGettingStartedFAQ4Question;

  /// No description provided for @docsGettingStartedFAQ4Answer.
  ///
  /// In en, this message translates to:
  /// **'When customers pay for services, money goes to your wallet. You can withdraw to your bank account using Paystack (Africa) or Stripe (Global).'**
  String get docsGettingStartedFAQ4Answer;

  /// No description provided for @docsGettingStartedFAQ5Question.
  ///
  /// In en, this message translates to:
  /// **'Is my payment information secure?'**
  String get docsGettingStartedFAQ5Question;

  /// No description provided for @docsGettingStartedFAQ5Answer.
  ///
  /// In en, this message translates to:
  /// **'Yes. Aura In uses Paystack and Stripe, industry-leading payment processors with bank-level security. We never see your payment details.'**
  String get docsGettingStartedFAQ5Answer;

  /// No description provided for @docsGettingStartedFAQ6Question.
  ///
  /// In en, this message translates to:
  /// **'How do I know if service providers near me are trustworthy?'**
  String get docsGettingStartedFAQ6Question;

  /// No description provided for @docsGettingStartedFAQ6Answer.
  ///
  /// In en, this message translates to:
  /// **'Every service provider has ratings and reviews from customers who have booked with them. Read reviews before booking. High ratings mean consistent, quality service.'**
  String get docsGettingStartedFAQ6Answer;

  /// No description provided for @docsGettingStartedFAQ7Question.
  ///
  /// In en, this message translates to:
  /// **'Can I book without downloading the app?'**
  String get docsGettingStartedFAQ7Question;

  /// No description provided for @docsGettingStartedFAQ7Answer.
  ///
  /// In en, this message translates to:
  /// **'Yes! Service providers share a unique booking link. You can book directly through that link without downloading the app. Your receipt will be sent to WhatsApp.'**
  String get docsGettingStartedFAQ7Answer;

  /// No description provided for @docsGettingStartedFAQ8Question.
  ///
  /// In en, this message translates to:
  /// **'How much do I pay upfront for bookings?'**
  String get docsGettingStartedFAQ8Question;

  /// No description provided for @docsGettingStartedFAQ8Answer.
  ///
  /// In en, this message translates to:
  /// **'You pay 30% of the service total upfront to secure the booking slot (plus a 2% platform fee). The remaining 70% can be paid in cash or online before/at the service.'**
  String get docsGettingStartedFAQ8Answer;

  /// No description provided for @docsGettingStartedFAQ9Question.
  ///
  /// In en, this message translates to:
  /// **'How do I pay for products?'**
  String get docsGettingStartedFAQ9Question;

  /// No description provided for @docsGettingStartedFAQ9Answer.
  ///
  /// In en, this message translates to:
  /// **'Products use Cash on Delivery (COD). You pay the seller when you receive the items. This lets you check quality before paying and works well for local deliveries.'**
  String get docsGettingStartedFAQ9Answer;

  /// No description provided for @docsGettingStartedFAQ10Question.
  ///
  /// In en, this message translates to:
  /// **'Why the 2% platform fee?'**
  String get docsGettingStartedFAQ10Question;

  /// No description provided for @docsGettingStartedFAQ10Answer.
  ///
  /// In en, this message translates to:
  /// **'The platform fee helps us maintain Aura In, provide payment processing, customer support, and continuously improve features for both customers and service providers.'**
  String get docsGettingStartedFAQ10Answer;

  /// No description provided for @docsBookingStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting Started with Bookings'**
  String get docsBookingStartedTitle;

  /// No description provided for @docsBookingStartedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A simple guide to understanding how bookings work'**
  String get docsBookingStartedSubtitle;

  /// No description provided for @docsBookingIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Booking System'**
  String get docsBookingIntroTitle;

  /// No description provided for @docsBookingIntroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything you need to know about booking services, whether you\'re a client or a shop owner.'**
  String get docsBookingIntroSubtitle;

  /// No description provided for @docsBookingWhatIsTitle.
  ///
  /// In en, this message translates to:
  /// **'What is the Booking System?'**
  String get docsBookingWhatIsTitle;

  /// No description provided for @docsBookingWhatIsContent.
  ///
  /// In en, this message translates to:
  /// **'The booking system is your gateway to scheduling services at your favorite shops. Whether you need a haircut, beard trim, braiding, or any other service, the system makes it easy to book appointments at your convenience.'**
  String get docsBookingWhatIsContent;

  /// No description provided for @docsBookingWhoIsForTitle.
  ///
  /// In en, this message translates to:
  /// **'Who is this guide for?'**
  String get docsBookingWhoIsForTitle;

  /// No description provided for @docsBookingWhoIsForContent.
  ///
  /// In en, this message translates to:
  /// **'This guide is designed for two types of users:'**
  String get docsBookingWhoIsForContent;

  /// No description provided for @docsBookingWhoIsForClients.
  ///
  /// In en, this message translates to:
  /// **'Clients: People who want to book services at shops'**
  String get docsBookingWhoIsForClients;

  /// No description provided for @docsBookingWhoIsForGuests.
  ///
  /// In en, this message translates to:
  /// **'Guest Bookers: People who want to book via a link without creating an account'**
  String get docsBookingWhoIsForGuests;

  /// No description provided for @docsBookingWhoIsForOwners.
  ///
  /// In en, this message translates to:
  /// **'Shop Owners: People who manage shops, services, and workers'**
  String get docsBookingWhoIsForOwners;

  /// No description provided for @docsBookingGuestIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'New: Book Without Downloading the App'**
  String get docsBookingGuestIntroTitle;

  /// No description provided for @docsBookingGuestIntroContent.
  ///
  /// In en, this message translates to:
  /// **'No account? No problem! If a shop owner shares a booking link with you, you can book directly without downloading the app. Your receipt is sent to WhatsApp.'**
  String get docsBookingGuestIntroContent;

  /// No description provided for @docsBookingWelcomeTip.
  ///
  /// In en, this message translates to:
  /// **'No technical knowledge needed! This guide uses simple language and real examples to help you understand everything.'**
  String get docsBookingWelcomeTip;

  /// No description provided for @docsBookingAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Creating Your Account (Or Booking as Guest)'**
  String get docsBookingAccountTitle;

  /// No description provided for @docsBookingAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get started in minutes - with or without an account'**
  String get docsBookingAccountSubtitle;

  /// No description provided for @docsBookingTwoWaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Two Ways to Book'**
  String get docsBookingTwoWaysTitle;

  /// No description provided for @docsBookingTwoWaysContent.
  ///
  /// In en, this message translates to:
  /// **'You can book in two ways:'**
  String get docsBookingTwoWaysContent;

  /// No description provided for @docsBookingTwoWaysAccount.
  ///
  /// In en, this message translates to:
  /// **'With Account: Download app, create account, book anytime'**
  String get docsBookingTwoWaysAccount;

  /// No description provided for @docsBookingTwoWaysGuest.
  ///
  /// In en, this message translates to:
  /// **'As Guest: Use booking link, no app needed, receipt via WhatsApp'**
  String get docsBookingTwoWaysGuest;

  /// No description provided for @docsBookingAccountStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Create an Account'**
  String get docsBookingAccountStepsTitle;

  /// No description provided for @docsBookingAccountStepsContent.
  ///
  /// In en, this message translates to:
  /// **'Follow these simple steps to create your account:'**
  String get docsBookingAccountStepsContent;

  /// No description provided for @docsBookingAccountTypesTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Types'**
  String get docsBookingAccountTypesTitle;

  /// No description provided for @docsBookingAccountTypesContent.
  ///
  /// In en, this message translates to:
  /// **'There are two types of accounts:'**
  String get docsBookingAccountTypesContent;

  /// No description provided for @docsBookingAccountTypesClient.
  ///
  /// In en, this message translates to:
  /// **'Client Account: For booking services at shops'**
  String get docsBookingAccountTypesClient;

  /// No description provided for @docsBookingAccountTypesShop.
  ///
  /// In en, this message translates to:
  /// **'Shop Owner Account: For managing your own shop (requires approval)'**
  String get docsBookingAccountTypesShop;

  /// No description provided for @docsBookingGuestOptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking as a Guest (No Account)'**
  String get docsBookingGuestOptionTitle;

  /// No description provided for @docsBookingGuestOptionContent.
  ///
  /// In en, this message translates to:
  /// **'If someone shares a booking link with you, you can book directly without creating an account. Just click the link and follow the steps. Your receipt is sent to your WhatsApp.'**
  String get docsBookingGuestOptionContent;

  /// No description provided for @docsBookingVerificationNote.
  ///
  /// In en, this message translates to:
  /// **'You can browse and book without an account using a booking link. Creating an account gives you access to booking history, saved payments, and loyalty rewards.'**
  String get docsBookingVerificationNote;

  /// No description provided for @docsBookingFirstBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your First Booking'**
  String get docsBookingFirstBookingTitle;

  /// No description provided for @docsBookingFirstBookingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A quick walkthrough'**
  String get docsBookingFirstBookingSubtitle;

  /// No description provided for @docsBookingPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'How Payment Works'**
  String get docsBookingPaymentTitle;

  /// No description provided for @docsBookingPaymentContent.
  ///
  /// In en, this message translates to:
  /// **'When you book a service, here\'s how payment works:'**
  String get docsBookingPaymentContent;

  /// No description provided for @docsBookingPaymentDeposit.
  ///
  /// In en, this message translates to:
  /// **'30% Deposit Required: To secure your booking, you pay 30% of the total service cost upfront'**
  String get docsBookingPaymentDeposit;

  /// No description provided for @docsBookingPaymentNonRefundable.
  ///
  /// In en, this message translates to:
  /// **'Non-Refundable: This deposit is non-refundable if you cancel or don\'t show up'**
  String get docsBookingPaymentNonRefundable;

  /// No description provided for @docsBookingPaymentRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining Balance: The remaining 70% is paid after your service is completed'**
  String get docsBookingPaymentRemaining;

  /// No description provided for @docsBookingPaymentSecure.
  ///
  /// In en, this message translates to:
  /// **'Secure Payment: All payments are processed securely through our payment partners'**
  String get docsBookingPaymentSecure;

  /// No description provided for @docsBookingDepositNote.
  ///
  /// In en, this message translates to:
  /// **'The 30% deposit protects both you and the shop. It ensures your slot is reserved exclusively for you, and compensates the worker if you cancel last minute.'**
  String get docsBookingDepositNote;

  /// No description provided for @docsBookingBookingTip.
  ///
  /// In en, this message translates to:
  /// **'Pro tip: Book at least 24 hours in advance for the best selection of time slots, especially for popular services.'**
  String get docsBookingBookingTip;

  /// No description provided for @docsBookingAfterTitle.
  ///
  /// In en, this message translates to:
  /// **'After You Book'**
  String get docsBookingAfterTitle;

  /// No description provided for @docsBookingAfterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What happens next'**
  String get docsBookingAfterSubtitle;

  /// No description provided for @docsBookingWhatsNextTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Booking is Confirmed!'**
  String get docsBookingWhatsNextTitle;

  /// No description provided for @docsBookingWhatsNextContent.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what you can do after booking:'**
  String get docsBookingWhatsNextContent;

  /// No description provided for @docsBookingRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Reminders'**
  String get docsBookingRemindersTitle;

  /// No description provided for @docsBookingRemindersContent.
  ///
  /// In en, this message translates to:
  /// **'You\'ll receive reminders at:'**
  String get docsBookingRemindersContent;

  /// No description provided for @docsBookingAfterServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'After Your Service'**
  String get docsBookingAfterServiceTitle;

  /// No description provided for @docsBookingAfterServiceContent.
  ///
  /// In en, this message translates to:
  /// **'Once your service is complete:'**
  String get docsBookingAfterServiceContent;

  /// No description provided for @docsPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment & Fees Explained'**
  String get docsPaymentTitle;

  /// No description provided for @docsPaymentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How 30% deposits, platform fees, and guest bookings work'**
  String get docsPaymentSubtitle;

  /// No description provided for @docsPaymentOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'How Payment Works'**
  String get docsPaymentOverviewTitle;

  /// No description provided for @docsPaymentOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Simple, transparent, secure'**
  String get docsPaymentOverviewSubtitle;

  /// No description provided for @docsPaymentSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment at a Glance'**
  String get docsPaymentSummaryTitle;

  /// No description provided for @docsPaymentSummaryContent.
  ///
  /// In en, this message translates to:
  /// **'Our payment system is designed to be fair for both clients and shop owners. Here\'s the simple breakdown:'**
  String get docsPaymentSummaryContent;

  /// No description provided for @docsPaymentDeposit30.
  ///
  /// In en, this message translates to:
  /// **'30% Deposit: Paid at booking to secure your appointment'**
  String get docsPaymentDeposit30;

  /// No description provided for @docsPaymentPlatformFee.
  ///
  /// In en, this message translates to:
  /// **'Platform Fee: Small fixed fee (e.g., GHS 2) charged by the app'**
  String get docsPaymentPlatformFee;

  /// No description provided for @docsPaymentRemaining70.
  ///
  /// In en, this message translates to:
  /// **'Remaining 70%: Paid after your service is complete'**
  String get docsPaymentRemaining70;

  /// No description provided for @docsPaymentTwoWays.
  ///
  /// In en, this message translates to:
  /// **'Two Ways to Pay Remaining: Cash or via app'**
  String get docsPaymentTwoWays;

  /// No description provided for @docsPaymentQuickExampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Example'**
  String get docsPaymentQuickExampleTitle;

  /// No description provided for @docsPaymentQuickExampleContent.
  ///
  /// In en, this message translates to:
  /// **'Service cost: GHS 100\nAt booking: Pay GHS 30 (deposit) + GHS 2 (fee) = GHS 32\nAfter service: Pay GHS 70 (cash or app)\nTotal to shop: GHS 100\nPlatform fee: GHS 2'**
  String get docsPaymentQuickExampleContent;

  /// No description provided for @docsPaymentImportantNote.
  ///
  /// In en, this message translates to:
  /// **'The platform fee is charged by the app, not the shop. It helps us maintain the platform and provide you with a great booking experience.'**
  String get docsPaymentImportantNote;

  /// No description provided for @docsPaymentGuestBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest Booking (No App Download)'**
  String get docsPaymentGuestBookingTitle;

  /// No description provided for @docsPaymentGuestBookingContent.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have the app? No problem! You can still book through your provider\'s booking link without creating an account. You pay the same 30% deposit + platform fee, and your receipt is sent to WhatsApp.'**
  String get docsPaymentGuestBookingContent;

  /// No description provided for @docsDepositTitle.
  ///
  /// In en, this message translates to:
  /// **'The 30% Deposit'**
  String get docsDepositTitle;

  /// No description provided for @docsDepositSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Why it\'s needed and how it works'**
  String get docsDepositSubtitle;

  /// No description provided for @docsDepositWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why Do We Require a Deposit?'**
  String get docsDepositWhyTitle;

  /// No description provided for @docsDepositWhyContent.
  ///
  /// In en, this message translates to:
  /// **'The 30% deposit protects both you and the shop:'**
  String get docsDepositWhyContent;

  /// No description provided for @docsDepositProtectsYou.
  ///
  /// In en, this message translates to:
  /// **'For you: Your slot is guaranteed – no one else can book it'**
  String get docsDepositProtectsYou;

  /// No description provided for @docsDepositProtectsShop.
  ///
  /// In en, this message translates to:
  /// **'For the shop: Workers are compensated if you cancel last minute'**
  String get docsDepositProtectsShop;

  /// No description provided for @docsDepositProtectsEveryone.
  ///
  /// In en, this message translates to:
  /// **'For everyone: Reduces no-shows, keeping prices fair'**
  String get docsDepositProtectsEveryone;

  /// No description provided for @docsDepositCalcTitle.
  ///
  /// In en, this message translates to:
  /// **'How the Deposit is Calculated'**
  String get docsDepositCalcTitle;

  /// No description provided for @docsDepositCalcContent.
  ///
  /// In en, this message translates to:
  /// **'The deposit is always 30% of the total service cost. This includes:'**
  String get docsDepositCalcContent;

  /// No description provided for @docsDepositCalcSingle.
  ///
  /// In en, this message translates to:
  /// **'Single service: 30% of that service price'**
  String get docsDepositCalcSingle;

  /// No description provided for @docsDepositCalcMultiple.
  ///
  /// In en, this message translates to:
  /// **'Multiple services: 30% of all services combined'**
  String get docsDepositCalcMultiple;

  /// No description provided for @docsDepositCalcGroup.
  ///
  /// In en, this message translates to:
  /// **'Group bookings: 30% of total for all people'**
  String get docsDepositCalcGroup;

  /// No description provided for @docsDepositExamplesTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit Examples'**
  String get docsDepositExamplesTitle;

  /// No description provided for @docsDepositExamplesSingle.
  ///
  /// In en, this message translates to:
  /// **'Single Service:\nHaircut (GHS 45) → Deposit GHS 13.50'**
  String get docsDepositExamplesSingle;

  /// No description provided for @docsDepositExamplesMultiple.
  ///
  /// In en, this message translates to:
  /// **'Multiple Services:\nHaircut (GHS 45) + Beard Trim (GHS 25) = GHS 70 total\nDeposit: GHS 21'**
  String get docsDepositExamplesMultiple;

  /// No description provided for @docsDepositExamplesGroup.
  ///
  /// In en, this message translates to:
  /// **'Group Booking (3 people):\n3 × Haircut (GHS 45 each) = GHS 135 total\nDeposit: GHS 40.50'**
  String get docsDepositExamplesGroup;

  /// No description provided for @docsDepositRefundTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit Refund Policy'**
  String get docsDepositRefundTitle;

  /// No description provided for @docsDepositRefundContent.
  ///
  /// In en, this message translates to:
  /// **'The 30% deposit is non-refundable. This means:'**
  String get docsDepositRefundContent;

  /// No description provided for @docsDepositRefundCancel.
  ///
  /// In en, this message translates to:
  /// **'If you cancel: Deposit is not returned'**
  String get docsDepositRefundCancel;

  /// No description provided for @docsDepositRefundNoShow.
  ///
  /// In en, this message translates to:
  /// **'If you don\'t show up: Deposit is not returned'**
  String get docsDepositRefundNoShow;

  /// No description provided for @docsDepositRefundReschedule.
  ///
  /// In en, this message translates to:
  /// **'If you reschedule: Deposit transfers to new time'**
  String get docsDepositRefundReschedule;

  /// No description provided for @docsDepositRefundShop.
  ///
  /// In en, this message translates to:
  /// **'If shop cancels: Full deposit refunded'**
  String get docsDepositRefundShop;

  /// No description provided for @docsDepositWarning.
  ///
  /// In en, this message translates to:
  /// **'Please be sure about your booking before paying the deposit. While you can reschedule, the deposit cannot be refunded if you cancel.'**
  String get docsDepositWarning;

  /// No description provided for @docsFeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Platform Fee'**
  String get docsFeeTitle;

  /// No description provided for @docsFeeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The small fee that keeps the app running'**
  String get docsFeeSubtitle;

  /// No description provided for @docsFeeWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What is the Platform Fee?'**
  String get docsFeeWhatTitle;

  /// No description provided for @docsFeeWhatContent.
  ///
  /// In en, this message translates to:
  /// **'The platform fee is a small fixed charge (e.g., GHS 2) that goes to the app, not the shop. It covers:'**
  String get docsFeeWhatContent;

  /// No description provided for @docsFeeAppDev.
  ///
  /// In en, this message translates to:
  /// **'App development and maintenance'**
  String get docsFeeAppDev;

  /// No description provided for @docsFeeSupport.
  ///
  /// In en, this message translates to:
  /// **'Customer support and dispute resolution'**
  String get docsFeeSupport;

  /// No description provided for @docsFeeProcessing.
  ///
  /// In en, this message translates to:
  /// **'Payment processing costs'**
  String get docsFeeProcessing;

  /// No description provided for @docsFeeFeatures.
  ///
  /// In en, this message translates to:
  /// **'New features and improvements'**
  String get docsFeeFeatures;

  /// No description provided for @docsFeeHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How the Fee is Charged'**
  String get docsFeeHowTitle;

  /// No description provided for @docsFeeHowContent.
  ///
  /// In en, this message translates to:
  /// **'Important things to know about the platform fee:'**
  String get docsFeeHowContent;

  /// No description provided for @docsFeeFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed amount (not a percentage) – e.g., GHS 2 per booking'**
  String get docsFeeFixed;

  /// No description provided for @docsFeePerbooking.
  ///
  /// In en, this message translates to:
  /// **'Charged once per booking – not per service or per person'**
  String get docsFeePerbooking;

  /// No description provided for @docsFeeNonRefundable.
  ///
  /// In en, this message translates to:
  /// **'Non-refundable – even if you cancel'**
  String get docsFeeNonRefundable;

  /// No description provided for @docsFeeShown.
  ///
  /// In en, this message translates to:
  /// **'Clearly shown before you confirm payment'**
  String get docsFeeShown;

  /// No description provided for @docsFeeExamplesTitle.
  ///
  /// In en, this message translates to:
  /// **'Platform Fee Examples'**
  String get docsFeeExamplesTitle;

  /// No description provided for @docsFeeExamplesSingle.
  ///
  /// In en, this message translates to:
  /// **'Single person, one service: GHS 2 fee'**
  String get docsFeeExamplesSingle;

  /// No description provided for @docsFeeExamplesMultiple.
  ///
  /// In en, this message translates to:
  /// **'Single person, multiple services: GHS 2 fee (still one booking!)'**
  String get docsFeeExamplesMultiple;

  /// No description provided for @docsFeeExamplesGroup.
  ///
  /// In en, this message translates to:
  /// **'Family of 4 booking together: GHS 2 fee (entire group)'**
  String get docsFeeExamplesGroup;

  /// No description provided for @docsFeeExamplesSeparate.
  ///
  /// In en, this message translates to:
  /// **'Compare to booking separately:\n4 separate bookings = 4 × GHS 2 = GHS 8 in fees\n1 group booking = GHS 2 fee – you save GHS 6!'**
  String get docsFeeExamplesSeparate;

  /// No description provided for @docsFeeGroupTip.
  ///
  /// In en, this message translates to:
  /// **'Booking as a group saves you money on fees! Instead of paying the platform fee for each person, you pay just one fee for the entire group booking.'**
  String get docsFeeGroupTip;

  /// No description provided for @docsPaymentRemainingTitle.
  ///
  /// In en, this message translates to:
  /// **'Paying the Remaining 70%'**
  String get docsPaymentRemainingTitle;

  /// No description provided for @docsPaymentRemainingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cash or online - your choice'**
  String get docsPaymentRemainingSubtitle;

  /// No description provided for @docsPaymentRemainingOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Two Payment Options'**
  String get docsPaymentRemainingOptionsTitle;

  /// No description provided for @docsPaymentRemainingOptionsContent.
  ///
  /// In en, this message translates to:
  /// **'After your service is complete, you have two ways to pay the remaining 70%:'**
  String get docsPaymentRemainingOptionsContent;

  /// No description provided for @docsPaymentCashOption.
  ///
  /// In en, this message translates to:
  /// **'Cash: Pay directly to the shop or worker'**
  String get docsPaymentCashOption;

  /// No description provided for @docsPaymentAppOption.
  ///
  /// In en, this message translates to:
  /// **'Via app: Pay through the app using your saved payment method'**
  String get docsPaymentAppOption;

  /// No description provided for @docsPaymentRemainingTip.
  ///
  /// In en, this message translates to:
  /// **'Both payment methods are equally valid. Choose what\'s most convenient for you at the time of service.'**
  String get docsPaymentRemainingTip;

  /// No description provided for @docsCancellationTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancellations & Refunds'**
  String get docsCancellationTitle;

  /// No description provided for @docsCancellationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What happens if you need to cancel'**
  String get docsCancellationSubtitle;

  /// No description provided for @docsCancellationInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Policy'**
  String get docsCancellationInfoTitle;

  /// No description provided for @docsCancellationInfoContent.
  ///
  /// In en, this message translates to:
  /// **'Understanding what happens when you cancel:'**
  String get docsCancellationInfoContent;

  /// No description provided for @docsCancellationUpTo24.
  ///
  /// In en, this message translates to:
  /// **'Cancel up to 24 hours before: Deposit and fee are non-refundable'**
  String get docsCancellationUpTo24;

  /// No description provided for @docsCancellationLessThan24.
  ///
  /// In en, this message translates to:
  /// **'Cancel less than 24 hours before: Same policy – deposit and fee not refunded'**
  String get docsCancellationLessThan24;

  /// No description provided for @docsCancellationReschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule instead: Your deposit transfers to the new time (free to reschedule)'**
  String get docsCancellationReschedule;

  /// No description provided for @docsCancellationNoShow.
  ///
  /// In en, this message translates to:
  /// **'No-show: Deposit and fee lost, and may affect your account status'**
  String get docsCancellationNoShow;

  /// No description provided for @docsHowToBookTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Book Services'**
  String get docsHowToBookTitle;

  /// No description provided for @docsHowToBookSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A step-by-step guide to booking your appointments'**
  String get docsHowToBookSubtitle;

  /// No description provided for @docsHowToBookOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking at a Glance'**
  String get docsHowToBookOverviewTitle;

  /// No description provided for @docsHowToBookOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The booking process in simple steps'**
  String get docsHowToBookOverviewSubtitle;

  /// No description provided for @docsHowToBookTwoWaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Two Ways to Book'**
  String get docsHowToBookTwoWaysTitle;

  /// No description provided for @docsHowToBookTwoWaysContent.
  ///
  /// In en, this message translates to:
  /// **'You can book in two ways:'**
  String get docsHowToBookTwoWaysContent;

  /// No description provided for @docsHowToBookTwoWaysWithApp.
  ///
  /// In en, this message translates to:
  /// **'With App Account: Download app, create account, book anytime'**
  String get docsHowToBookTwoWaysWithApp;

  /// No description provided for @docsHowToBookTwoWaysGuest.
  ///
  /// In en, this message translates to:
  /// **'As Guest: Use booking link, no app needed, receipt via WhatsApp'**
  String get docsHowToBookTwoWaysGuest;

  /// No description provided for @docsHowToBookStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Booking Journey (With Account)'**
  String get docsHowToBookStepsTitle;

  /// No description provided for @docsHowToBookStepsContent.
  ///
  /// In en, this message translates to:
  /// **'Booking a service takes just a few minutes. Here\'s what you\'ll do:'**
  String get docsHowToBookStepsContent;

  /// No description provided for @docsHowToBookStep1.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Find a shop and browse services'**
  String get docsHowToBookStep1;

  /// No description provided for @docsHowToBookStep2.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Select your services and quantities'**
  String get docsHowToBookStep2;

  /// No description provided for @docsHowToBookStep3.
  ///
  /// In en, this message translates to:
  /// **'Step 3: Choose your preferred worker (if available)'**
  String get docsHowToBookStep3;

  /// No description provided for @docsHowToBookStep4.
  ///
  /// In en, this message translates to:
  /// **'Step 4: Pick a date and time'**
  String get docsHowToBookStep4;

  /// No description provided for @docsHowToBookStep5.
  ///
  /// In en, this message translates to:
  /// **'Step 5: Pay 30% deposit + small fee to confirm'**
  String get docsHowToBookStep5;

  /// No description provided for @docsHowToBookStep6.
  ///
  /// In en, this message translates to:
  /// **'Step 6: After service, pay remaining 70% in cash or via app'**
  String get docsHowToBookStep6;

  /// No description provided for @docsHowToBookGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest Booking (No App)'**
  String get docsHowToBookGuestTitle;

  /// No description provided for @docsHowToBookGuestContent.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have the app? If a shop shares a booking link with you, follow the same steps above but without needing to create an account. Your confirmation and receipt go to your WhatsApp.'**
  String get docsHowToBookGuestContent;

  /// No description provided for @docsHowToBookTimeTip.
  ///
  /// In en, this message translates to:
  /// **'The entire process usually takes less than 2 minutes. Your progress is saved as you go, so you can take your time.'**
  String get docsHowToBookTimeTip;

  /// No description provided for @docsBookingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Find Your Shop & Services'**
  String get docsBookingStep1Title;

  /// No description provided for @docsBookingStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover the perfect place for your needs'**
  String get docsBookingStep1Subtitle;

  /// No description provided for @docsBookingFindShopTitle.
  ///
  /// In en, this message translates to:
  /// **'How to find a shop'**
  String get docsBookingFindShopTitle;

  /// No description provided for @docsBookingFindShopContent.
  ///
  /// In en, this message translates to:
  /// **'You can find shops in several ways:'**
  String get docsBookingFindShopContent;

  /// No description provided for @docsBookingFindShopHome.
  ///
  /// In en, this message translates to:
  /// **'Home Screen: Browse recommended shops near you'**
  String get docsBookingFindShopHome;

  /// No description provided for @docsBookingFindShopSearch.
  ///
  /// In en, this message translates to:
  /// **'Search: Look for specific shops or services by name'**
  String get docsBookingFindShopSearch;

  /// No description provided for @docsBookingFindShopCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories: Filter by service type (Haircut, Braiding, Beard, etc.)'**
  String get docsBookingFindShopCategories;

  /// No description provided for @docsBookingFindShopFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites: Quick access to shops you\'ve saved'**
  String get docsBookingFindShopFavorites;

  /// No description provided for @docsBookingBrowseServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Browsing Services'**
  String get docsBookingBrowseServicesTitle;

  /// No description provided for @docsBookingBrowseServicesContent.
  ///
  /// In en, this message translates to:
  /// **'Once you select a shop, you\'ll see all their available services. Each service shows:'**
  String get docsBookingBrowseServicesContent;

  /// No description provided for @docsBookingServiceName.
  ///
  /// In en, this message translates to:
  /// **'Service name (e.g., Afro Haircut, Box Braids)'**
  String get docsBookingServiceName;

  /// No description provided for @docsBookingServiceDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration (how long it takes)'**
  String get docsBookingServiceDuration;

  /// No description provided for @docsBookingServicePrice.
  ///
  /// In en, this message translates to:
  /// **'Price (cost of the service - this goes to the shop)'**
  String get docsBookingServicePrice;

  /// No description provided for @docsBookingServiceDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (what\'s included)'**
  String get docsBookingServiceDescription;

  /// No description provided for @docsBookingServiceWorker.
  ///
  /// In en, this message translates to:
  /// **'Worker requirement (whether you can choose who does it)'**
  String get docsBookingServiceWorker;

  /// No description provided for @docsBookingServiceExampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get docsBookingServiceExampleTitle;

  /// No description provided for @docsBookingServiceExampleContent.
  ///
  /// In en, this message translates to:
  /// **'Haircut Service:\n• Name: Afro Haircut\n• Duration: 1 hour\n• Price: GHS 45 (paid to shop)\n• Description: Professional afro haircut with styling\n• Worker: You can choose your preferred barber'**
  String get docsBookingServiceExampleContent;

  /// No description provided for @docsBookingStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Select Your Services'**
  String get docsBookingStep2Title;

  /// No description provided for @docsBookingStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose what you want and how many people'**
  String get docsBookingStep2Subtitle;

  /// No description provided for @docsBookingSelectServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Selecting Services'**
  String get docsBookingSelectServicesTitle;

  /// No description provided for @docsBookingSelectServicesContent.
  ///
  /// In en, this message translates to:
  /// **'To select a service, simply tap on it. You\'ll see it become highlighted. You can select multiple services at once:'**
  String get docsBookingSelectServicesContent;

  /// No description provided for @docsBookingSelectServicesTap.
  ///
  /// In en, this message translates to:
  /// **'Tap a service to select it'**
  String get docsBookingSelectServicesTap;

  /// No description provided for @docsBookingSelectServicesCheckmark.
  ///
  /// In en, this message translates to:
  /// **'Selected services show a checkmark'**
  String get docsBookingSelectServicesCheckmark;

  /// No description provided for @docsBookingSelectServicesMultiple.
  ///
  /// In en, this message translates to:
  /// **'You can select multiple services (e.g., Haircut + Beard Trim)'**
  String get docsBookingSelectServicesMultiple;

  /// No description provided for @docsBookingSelectServicesDeselect.
  ///
  /// In en, this message translates to:
  /// **'Tap again to deselect'**
  String get docsBookingSelectServicesDeselect;

  /// No description provided for @docsBookingGroupBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking for Multiple People'**
  String get docsBookingGroupBookingTitle;

  /// No description provided for @docsBookingGroupBookingContent.
  ///
  /// In en, this message translates to:
  /// **'If you\'re booking for a group (like yourself and your children), you can increase the quantity:'**
  String get docsBookingGroupBookingContent;

  /// No description provided for @docsBookingGroupBookingQuantity.
  ///
  /// In en, this message translates to:
  /// **'After selecting a service, you\'ll see a + and - button'**
  String get docsBookingGroupBookingQuantity;

  /// No description provided for @docsBookingGroupBookingIncrease.
  ///
  /// In en, this message translates to:
  /// **'Tap + to increase the number of people'**
  String get docsBookingGroupBookingIncrease;

  /// No description provided for @docsBookingGroupBookingPrice.
  ///
  /// In en, this message translates to:
  /// **'The price updates automatically'**
  String get docsBookingGroupBookingPrice;

  /// No description provided for @docsBookingGroupBookingLimit.
  ///
  /// In en, this message translates to:
  /// **'Maximum quantity is shown (some services have limits)'**
  String get docsBookingGroupBookingLimit;

  /// No description provided for @docsBookingGroupExampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Example: Family Booking'**
  String get docsBookingGroupExampleTitle;

  /// No description provided for @docsBookingGroupExampleContent.
  ///
  /// In en, this message translates to:
  /// **'Dad wants haircuts for himself and his two sons:\n• Select \"Haircut\" service\n• Tap + until quantity shows 3\n• Total price shows 3 × GHS 45 = GHS 135 (for the shop)\n• You\'ll choose workers for each person later'**
  String get docsBookingGroupExampleContent;

  /// No description provided for @docsBookingQuantityTip.
  ///
  /// In en, this message translates to:
  /// **'The quantity feature is perfect for families, groups of friends, or anyone booking for multiple people at once.'**
  String get docsBookingQuantityTip;

  /// No description provided for @docsGroupBookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Group Bookings'**
  String get docsGroupBookingsTitle;

  /// No description provided for @docsGroupBookingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How to book services for yourself and others'**
  String get docsGroupBookingsSubtitle;

  /// No description provided for @docsGroupIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'What Are Group Bookings?'**
  String get docsGroupIntroTitle;

  /// No description provided for @docsGroupIntroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Booking for family, friends, or groups made simple'**
  String get docsGroupIntroSubtitle;

  /// No description provided for @docsGroupExplainedTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking for Multiple People'**
  String get docsGroupExplainedTitle;

  /// No description provided for @docsGroupExplainedContent.
  ///
  /// In en, this message translates to:
  /// **'Group bookings allow you to book services for more than one person at a time. This is perfect for:'**
  String get docsGroupExplainedContent;

  /// No description provided for @docsGroupExplainedFamilies.
  ///
  /// In en, this message translates to:
  /// **'Families: Parents booking haircuts for themselves and their children'**
  String get docsGroupExplainedFamilies;

  /// No description provided for @docsGroupExplainedFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends: Group of friends getting services together'**
  String get docsGroupExplainedFriends;

  /// No description provided for @docsGroupExplainedEvents.
  ///
  /// In en, this message translates to:
  /// **'Events: Bridal parties, birthdays, or special occasions'**
  String get docsGroupExplainedEvents;

  /// No description provided for @docsGroupExplainedColleagues.
  ///
  /// In en, this message translates to:
  /// **'Colleagues: Team building or work outings'**
  String get docsGroupExplainedColleagues;

  /// No description provided for @docsGroupRealExampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Real-Life Example'**
  String get docsGroupRealExampleTitle;

  /// No description provided for @docsGroupRealExampleContent.
  ///
  /// In en, this message translates to:
  /// **'The Mensah Family needs haircuts:\n• Father: Wants a fade haircut\n• Mother: Wants a trim\n• Son (10): Wants a kids haircut\n• Daughter (8): Wants braids\n\nInstead of making 4 separate bookings, they can book everything together in one go!'**
  String get docsGroupRealExampleContent;

  /// No description provided for @docsGroupBenefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Benefits of Group Booking'**
  String get docsGroupBenefitsTitle;

  /// No description provided for @docsGroupBenefitsContent.
  ///
  /// In en, this message translates to:
  /// **'Booking as a group gives you:'**
  String get docsGroupBenefitsContent;

  /// No description provided for @docsGroupBenefitsTransaction.
  ///
  /// In en, this message translates to:
  /// **'One transaction: Pay deposits for everyone at once'**
  String get docsGroupBenefitsTransaction;

  /// No description provided for @docsGroupBenefitsTiming.
  ///
  /// In en, this message translates to:
  /// **'Coordinated timing: Everyone gets served around the same time'**
  String get docsGroupBenefitsTiming;

  /// No description provided for @docsGroupBenefitsWorkers.
  ///
  /// In en, this message translates to:
  /// **'Different workers: Each person can choose their preferred worker'**
  String get docsGroupBenefitsWorkers;

  /// No description provided for @docsGroupBenefitsManagement.
  ///
  /// In en, this message translates to:
  /// **'Simplified management: View and manage all bookings together'**
  String get docsGroupBenefitsManagement;

  /// No description provided for @docsGroupBenefitsPlanning.
  ///
  /// In en, this message translates to:
  /// **'Better planning: Shop can prepare for your group'**
  String get docsGroupBenefitsPlanning;

  /// No description provided for @docsGroupTip.
  ///
  /// In en, this message translates to:
  /// **'Group bookings are perfect for families! You can book for yourself and your children in one go, choosing different workers for each person. No account needed? Use a booking link shared by the shop!'**
  String get docsGroupTip;

  /// No description provided for @docsGroupHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Make a Group Booking'**
  String get docsGroupHowTitle;

  /// No description provided for @docsGroupHowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step guide'**
  String get docsGroupHowSubtitle;

  /// No description provided for @docsGroupStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Select Your Service'**
  String get docsGroupStep1Title;

  /// No description provided for @docsGroupStep1Content.
  ///
  /// In en, this message translates to:
  /// **'Start by finding a shop and selecting the service you want. For example, tap on \"Haircut\".'**
  String get docsGroupStep1Content;

  /// No description provided for @docsGroupStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Choose the Quantity'**
  String get docsGroupStep2Title;

  /// No description provided for @docsGroupStep2Content.
  ///
  /// In en, this message translates to:
  /// **'After selecting a service, you\'ll see + and - buttons. Use these to set how many people need this service:'**
  String get docsGroupStep2Content;

  /// No description provided for @docsGroupStep2Plus.
  ///
  /// In en, this message translates to:
  /// **'Tap + to increase the number'**
  String get docsGroupStep2Plus;

  /// No description provided for @docsGroupStep2Minus.
  ///
  /// In en, this message translates to:
  /// **'Tap - to decrease'**
  String get docsGroupStep2Minus;

  /// No description provided for @docsGroupStep2Price.
  ///
  /// In en, this message translates to:
  /// **'The price updates automatically'**
  String get docsGroupStep2Price;

  /// No description provided for @docsGroupStep2Max.
  ///
  /// In en, this message translates to:
  /// **'You cannot exceed the maximum quantity shown'**
  String get docsGroupStep2Max;

  /// No description provided for @docsGroupStep2ExampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get docsGroupStep2ExampleTitle;

  /// No description provided for @docsGroupStep2ExampleContent.
  ///
  /// In en, this message translates to:
  /// **'For a family of 3 needing haircuts:\n• Select \"Haircut\" service\n• Tap + twice (or until quantity shows 3)\n• Total price shows: 3 × GHS 45 = GHS 135'**
  String get docsGroupStep2ExampleContent;

  /// No description provided for @docsGroupStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Step 3: Repeat for Each Service'**
  String get docsGroupStep3Title;

  /// No description provided for @docsGroupStep3Content.
  ///
  /// In en, this message translates to:
  /// **'If your group needs different services (e.g., some want haircuts, others want braids), select each service and set the quantity for each:'**
  String get docsGroupStep3Content;

  /// No description provided for @docsGroupStep3Haircut.
  ///
  /// In en, this message translates to:
  /// **'Select \"Haircut\" → set quantity 2'**
  String get docsGroupStep3Haircut;

  /// No description provided for @docsGroupStep3Braids.
  ///
  /// In en, this message translates to:
  /// **'Select \"Braids\" → set quantity 1'**
  String get docsGroupStep3Braids;

  /// No description provided for @docsGroupStep3Track.
  ///
  /// In en, this message translates to:
  /// **'The system keeps track of all selections'**
  String get docsGroupStep3Track;

  /// No description provided for @docsGroupStep3ExampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Example: Mixed Services'**
  String get docsGroupStep3ExampleTitle;

  /// No description provided for @docsGroupStep3ExampleContent.
  ///
  /// In en, this message translates to:
  /// **'Family of 4 with different needs:\n• Dad: Haircut (quantity 1)\n• Mom: Trim (quantity 1)\n• Son: Kids Haircut (quantity 1)\n• Daughter: Braids (quantity 1)\n\nTotal: 4 services, but you booked them all in one go!'**
  String get docsGroupStep3ExampleContent;

  /// No description provided for @docsGroupStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Step 4: Choose Workers for Each Person'**
  String get docsGroupStep4Title;

  /// No description provided for @docsGroupStep4Content.
  ///
  /// In en, this message translates to:
  /// **'For services that let you choose workers, you\'ll see a list of people. Tap on each person to assign their worker:'**
  String get docsGroupStep4Content;

  /// No description provided for @docsGroupStep4Person1.
  ///
  /// In en, this message translates to:
  /// **'Person 1: Choose John (fade specialist)'**
  String get docsGroupStep4Person1;

  /// No description provided for @docsGroupStep4Person2.
  ///
  /// In en, this message translates to:
  /// **'Person 2: Choose Sarah (braiding expert)'**
  String get docsGroupStep4Person2;

  /// No description provided for @docsGroupStep4Person3.
  ///
  /// In en, this message translates to:
  /// **'Person 3: Choose Michael (kids cuts)'**
  String get docsGroupStep4Person3;

  /// No description provided for @docsGroupStep4Person4.
  ///
  /// In en, this message translates to:
  /// **'Person 4: Choose John (same worker for multiple people)'**
  String get docsGroupStep4Person4;

  /// No description provided for @docsGroupStep4ExampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Example: Different Workers for Different People'**
  String get docsGroupStep4ExampleTitle;

  /// No description provided for @docsGroupStep4ExampleContent.
  ///
  /// In en, this message translates to:
  /// **'Family of 3 booking haircuts:\n• Person 1 (Dad): Choose John (fade specialist)\n• Person 2 (Son): Choose Michael (great with kids)\n• Person 3 (Daughter): Choose Sarah (braiding expert)\n\nAll three will be served during your appointment block.'**
  String get docsGroupStep4ExampleContent;

  /// No description provided for @docsGroupStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Step 5: Pick Your Time'**
  String get docsGroupStep5Title;

  /// No description provided for @docsGroupStep5Content.
  ///
  /// In en, this message translates to:
  /// **'When you select a date and time, the system will show slots that can accommodate ALL people in your group:'**
  String get docsGroupStep5Content;

  /// No description provided for @docsGroupStep5Regular.
  ///
  /// In en, this message translates to:
  /// **'Regular View: Shows slots for each service separately'**
  String get docsGroupStep5Regular;

  /// No description provided for @docsGroupStep5Combined.
  ///
  /// In en, this message translates to:
  /// **'Combined View: Shows only slots where everyone can be served together'**
  String get docsGroupStep5Combined;

  /// No description provided for @docsGroupStep5Duration.
  ///
  /// In en, this message translates to:
  /// **'Duration: The time shown includes all services for all people'**
  String get docsGroupStep5Duration;

  /// No description provided for @docsGroupStep5ExampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Example: Time Calculation'**
  String get docsGroupStep5ExampleTitle;

  /// No description provided for @docsGroupStep5ExampleContent.
  ///
  /// In en, this message translates to:
  /// **'Family booking:\n• Haircut (45 min) × 2 people = 90 min\n• Braids (2 hours) × 1 person = 120 min\n• Buffer time between services = 15 min\n• Total appointment time: 3 hours 45 min\n\nThe system handles all this automatically!'**
  String get docsGroupStep5ExampleContent;

  /// No description provided for @docsGroupStep6Title.
  ///
  /// In en, this message translates to:
  /// **'Step 6: Payment'**
  String get docsGroupStep6Title;

  /// No description provided for @docsGroupStep6Content.
  ///
  /// In en, this message translates to:
  /// **'For group bookings, you pay:'**
  String get docsGroupStep6Content;

  /// No description provided for @docsGroupStep6Deposit.
  ///
  /// In en, this message translates to:
  /// **'30% deposit: Calculated on the TOTAL cost of all services'**
  String get docsGroupStep6Deposit;

  /// No description provided for @docsGroupStep6Fee.
  ///
  /// In en, this message translates to:
  /// **'Platform fee: Small fixed fee (e.g., GHS 2) - charged ONCE for entire group'**
  String get docsGroupStep6Fee;

  /// No description provided for @docsGroupStep6Remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining 70%: Paid after all services are complete'**
  String get docsGroupStep6Remaining;

  /// No description provided for @docsGroupStep6Options.
  ///
  /// In en, this message translates to:
  /// **'Payment options: Cash, card, mobile money, or app payment'**
  String get docsGroupStep6Options;

  /// No description provided for @docsGroupStep6ExampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Example'**
  String get docsGroupStep6ExampleTitle;

  /// No description provided for @docsGroupStep6ExampleContent.
  ///
  /// In en, this message translates to:
  /// **'Family booking total: GHS 400\n• Deposit at booking: GHS 120 (30% of GHS 400)\n• Platform fee: GHS 2 (charged once for entire group)\n• Total to pay now: GHS 122\n• Remaining after service: GHS 280\n• Payment after: Cash to worker/shop OR via app (your choice)'**
  String get docsGroupStep6ExampleContent;

  /// No description provided for @docsGroupPaymentFlexibility.
  ///
  /// In en, this message translates to:
  /// **'Multiple Payment Options'**
  String get docsGroupPaymentFlexibility;

  /// No description provided for @docsGroupPaymentFlexibilityContent.
  ///
  /// In en, this message translates to:
  /// **'For the remaining 70%, you have options:'**
  String get docsGroupPaymentFlexibilityContent;

  /// No description provided for @docsGroupPaymentFlexibilityAllCash.
  ///
  /// In en, this message translates to:
  /// **'All Cash: Everyone pays in cash when service is done'**
  String get docsGroupPaymentFlexibilityAllCash;

  /// No description provided for @docsGroupPaymentFlexibilitySplit.
  ///
  /// In en, this message translates to:
  /// **'Split Payments: Some people pay cash, others pay via app'**
  String get docsGroupPaymentFlexibilitySplit;

  /// No description provided for @docsGroupPaymentFlexibilityMixed.
  ///
  /// In en, this message translates to:
  /// **'Mix of Cash & App: Pay part in cash, part via app'**
  String get docsGroupPaymentFlexibilityMixed;

  /// No description provided for @docsGroupPaymentFlexibilityIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual App Payments: Each person pays via app'**
  String get docsGroupPaymentFlexibilityIndividual;

  /// No description provided for @docsGroupPaymentFlexibilityTip.
  ///
  /// In en, this message translates to:
  /// **'Choose what works best for your group!'**
  String get docsGroupPaymentFlexibilityTip;

  /// No description provided for @docsGroupImportant.
  ///
  /// In en, this message translates to:
  /// **'The deposit and platform fee are calculated on the TOTAL group booking, not per person. You pay once for the whole group.'**
  String get docsGroupImportant;

  /// No description provided for @docsCreateShopTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Shop'**
  String get docsCreateShopTitle;

  /// No description provided for @docsCreateShopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your business'**
  String get docsCreateShopSubtitle;

  /// No description provided for @docsShopOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting Started with Your Shop'**
  String get docsShopOverviewTitle;

  /// No description provided for @docsShopOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn the basics of creating your business profile'**
  String get docsShopOverviewSubtitle;

  /// No description provided for @docsWelcomeIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Your Shop Dashboard'**
  String get docsWelcomeIntroTitle;

  /// No description provided for @docsWelcomeIntroContent.
  ///
  /// In en, this message translates to:
  /// **'Creating a shop on Aura In takes just a few minutes. You\'ll add your business information, set your services and working hours, and you\'re ready to accept bookings from customers.'**
  String get docsWelcomeIntroContent;

  /// No description provided for @docsSetupStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'What You\'ll Set Up'**
  String get docsSetupStepsTitle;

  /// No description provided for @docsSetupStepsContent.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what you\'ll do when creating your shop:'**
  String get docsSetupStepsContent;

  /// No description provided for @docsSetupStepsShopName.
  ///
  /// In en, this message translates to:
  /// **'Add your shop name and logo'**
  String get docsSetupStepsShopName;

  /// No description provided for @docsSetupStepsDescription.
  ///
  /// In en, this message translates to:
  /// **'Write a brief description of your business'**
  String get docsSetupStepsDescription;

  /// No description provided for @docsSetupStepsType.
  ///
  /// In en, this message translates to:
  /// **'Choose your shop type (salon, barber, spa, etc.)'**
  String get docsSetupStepsType;

  /// No description provided for @docsSetupStepsLocation.
  ///
  /// In en, this message translates to:
  /// **'Set your location and service address'**
  String get docsSetupStepsLocation;

  /// No description provided for @docsSetupStepsHours.
  ///
  /// In en, this message translates to:
  /// **'Add your working hours'**
  String get docsSetupStepsHours;

  /// No description provided for @docsSetupStepsServices.
  ///
  /// In en, this message translates to:
  /// **'Create services you offer with pricing'**
  String get docsSetupStepsServices;

  /// No description provided for @docsSetupStepsContact.
  ///
  /// In en, this message translates to:
  /// **'Add contact information'**
  String get docsSetupStepsContact;

  /// No description provided for @docsSetupStepsPhotos.
  ///
  /// In en, this message translates to:
  /// **'Upload photos and documents'**
  String get docsSetupStepsPhotos;

  /// No description provided for @docsSetupTip.
  ///
  /// In en, this message translates to:
  /// **'Your work is saved automatically as you fill in the form. You can come back anytime to continue editing or publish when ready.'**
  String get docsSetupTip;

  /// No description provided for @docsBasicInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic Shop Information'**
  String get docsBasicInfoTitle;

  /// No description provided for @docsBasicInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell customers who you are'**
  String get docsBasicInfoSubtitle;

  /// No description provided for @docsLogoTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Your Shop Logo'**
  String get docsLogoTitle;

  /// No description provided for @docsLogoContent.
  ///
  /// In en, this message translates to:
  /// **'Your logo is the first thing customers see. It should clearly represent your business. Use a square image (e.g., 500x500 pixels) for best results.'**
  String get docsLogoContent;

  /// No description provided for @docsShopNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop Name'**
  String get docsShopNameTitle;

  /// No description provided for @docsShopNameContent.
  ///
  /// In en, this message translates to:
  /// **'Enter your business name exactly as you want customers to see it. Be clear and professional. Example: \"Marie\'s Hair Studio\" or \"City Barbershop\"'**
  String get docsShopNameContent;

  /// No description provided for @docsShopTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Shop Type'**
  String get docsShopTypeTitle;

  /// No description provided for @docsShopTypeContent.
  ///
  /// In en, this message translates to:
  /// **'Select the type of business you run. This helps customers find you in search. Available types include:'**
  String get docsShopTypeContent;

  /// No description provided for @docsShopTypeSalon.
  ///
  /// In en, this message translates to:
  /// **'Hair Salon - for haircuts, coloring, styling'**
  String get docsShopTypeSalon;

  /// No description provided for @docsShopTypeBarber.
  ///
  /// In en, this message translates to:
  /// **'Barber Shop - for men\'s haircuts and grooming'**
  String get docsShopTypeBarber;

  /// No description provided for @docsShopTypeSpa.
  ///
  /// In en, this message translates to:
  /// **'Spa - for massages, facials, wellness services'**
  String get docsShopTypeSpa;

  /// No description provided for @docsShopTypeBeauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty Services - makeup, nails, and other beauty treatments'**
  String get docsShopTypeBeauty;

  /// No description provided for @docsShopTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other Services - for businesses not listed above'**
  String get docsShopTypeOther;

  /// No description provided for @docsDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop Description'**
  String get docsDescriptionTitle;

  /// No description provided for @docsDescriptionContent.
  ///
  /// In en, this message translates to:
  /// **'Write a short description about your shop (100-200 words). Tell customers what makes you special. Example: \"We specialize in natural hair care and modern styling for all hair types. Family-friendly environment with professional stylists.\"'**
  String get docsDescriptionContent;

  /// No description provided for @docsTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get docsTermsTitle;

  /// No description provided for @docsTermsContent.
  ///
  /// In en, this message translates to:
  /// **'Add any important rules customers should know. Examples: cancellation policy, age restrictions, deposit requirements, dress code, or health restrictions.'**
  String get docsTermsContent;

  /// No description provided for @docsLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location & Hours'**
  String get docsLocationTitle;

  /// No description provided for @docsLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Where customers can find you and when you work'**
  String get docsLocationSubtitle;

  /// No description provided for @docsLocationIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Your Location'**
  String get docsLocationIntroTitle;

  /// No description provided for @docsLocationIntroContent.
  ///
  /// In en, this message translates to:
  /// **'Customers need to know where to find you. You can either:'**
  String get docsLocationIntroContent;

  /// No description provided for @docsLocationPin.
  ///
  /// In en, this message translates to:
  /// **'Pin your location on the map (drag the marker)'**
  String get docsLocationPin;

  /// No description provided for @docsLocationSearch.
  ///
  /// In en, this message translates to:
  /// **'Search for your address in the search box'**
  String get docsLocationSearch;

  /// No description provided for @docsLocationManual.
  ///
  /// In en, this message translates to:
  /// **'Enter your street address manually'**
  String get docsLocationManual;

  /// No description provided for @docsLocationAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Make sure your location is accurate. Customers use it to find you and calculate travel time.'**
  String get docsLocationAccuracy;

  /// No description provided for @docsWorkingHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Your Working Hours'**
  String get docsWorkingHoursTitle;

  /// No description provided for @docsWorkingHoursContent.
  ///
  /// In en, this message translates to:
  /// **'Customers can only book times when you\'re open. Set your hours for each day of the week.'**
  String get docsWorkingHoursContent;

  /// No description provided for @docsHoursExampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Example Schedule'**
  String get docsHoursExampleTitle;

  /// No description provided for @docsHoursExampleContent.
  ///
  /// In en, this message translates to:
  /// **'Monday - Friday: 9:00 AM to 6:00 PM\nSaturday: 10:00 AM to 4:00 PM\nSunday: Closed'**
  String get docsHoursExampleContent;

  /// No description provided for @docsHoursTip.
  ///
  /// In en, this message translates to:
  /// **'You can set different hours for different days, or mark any day as closed when you\'re not working.'**
  String get docsHoursTip;

  /// No description provided for @docsServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Services & Pricing'**
  String get docsServicesTitle;

  /// No description provided for @docsServicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell customers what you offer and how much it costs'**
  String get docsServicesSubtitle;

  /// No description provided for @docsServicesIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Your Services'**
  String get docsServicesIntroTitle;

  /// No description provided for @docsServicesIntroContent.
  ///
  /// In en, this message translates to:
  /// **'Each service is something customers can book and pay for. Examples: \"Haircut\", \"Hair Color\", \"Massage\", \"Facial Treatment\".'**
  String get docsServicesIntroContent;

  /// No description provided for @docsServiceDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'For Each Service, Add:'**
  String get docsServiceDetailsTitle;

  /// No description provided for @docsServiceDetailsContent.
  ///
  /// In en, this message translates to:
  /// **'When you create a service, you need to provide:'**
  String get docsServiceDetailsContent;

  /// No description provided for @docsServiceName.
  ///
  /// In en, this message translates to:
  /// **'Service name - what you\'re offering (e.g., \"Haircut\")'**
  String get docsServiceName;

  /// No description provided for @docsServiceDescription.
  ///
  /// In en, this message translates to:
  /// **'Description - brief details about what\'s included'**
  String get docsServiceDescription;

  /// No description provided for @docsServicePrice.
  ///
  /// In en, this message translates to:
  /// **'Price - how much the service costs'**
  String get docsServicePrice;

  /// No description provided for @docsServiceDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration - how long it takes (e.g., 30 minutes, 1 hour)'**
  String get docsServiceDuration;

  /// No description provided for @docsServiceCategory.
  ///
  /// In en, this message translates to:
  /// **'Category - what type of service it is'**
  String get docsServiceCategory;

  /// No description provided for @docsPricingTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Pricing Tip'**
  String get docsPricingTipTitle;

  /// No description provided for @docsPricingTipContent.
  ///
  /// In en, this message translates to:
  /// **'Be clear with your prices. You can offer different service tiers (e.g., \"Basic Haircut\" vs \"Premium Haircut\") at different prices.'**
  String get docsPricingTipContent;

  /// No description provided for @docsDurationImportant.
  ///
  /// In en, this message translates to:
  /// **'Set the duration accurately. Customers book based on this time, and staff need to know how long to reserve.'**
  String get docsDurationImportant;

  /// No description provided for @docsTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Your Team'**
  String get docsTeamTitle;

  /// No description provided for @docsTeamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add staff members and assign them to services'**
  String get docsTeamSubtitle;

  /// No description provided for @docsWorkersIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Your Staff'**
  String get docsWorkersIntroTitle;

  /// No description provided for @docsWorkersIntroContent.
  ///
  /// In en, this message translates to:
  /// **'If you have team members working at your shop, you can add them here. This helps you manage who is available for bookings.'**
  String get docsWorkersIntroContent;

  /// No description provided for @docsAddWorkerTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Add a Staff Member'**
  String get docsAddWorkerTitle;

  /// No description provided for @docsAddWorkerContent.
  ///
  /// In en, this message translates to:
  /// **'When you add a worker, you need:'**
  String get docsAddWorkerContent;

  /// No description provided for @docsFreelancerTitle.
  ///
  /// In en, this message translates to:
  /// **'Become a Freelancer'**
  String get docsFreelancerTitle;

  /// No description provided for @docsFreelancerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Work independently'**
  String get docsFreelancerSubtitle;

  /// No description provided for @docsFreelancerOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting Started as a Freelancer'**
  String get docsFreelancerOverviewTitle;

  /// No description provided for @docsFreelancerOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn how to set up your profile and start taking clients'**
  String get docsFreelancerOverviewSubtitle;

  /// No description provided for @docsFreelancerWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Freelancing'**
  String get docsFreelancerWelcomeTitle;

  /// No description provided for @docsFreelancerWelcomeContent.
  ///
  /// In en, this message translates to:
  /// **'As a freelancer on Aura In, you offer services directly to customers in your area. Unlike a traditional shop, you work from your own location and can travel to meet clients. Set up your profile in just a few minutes and start accepting bookings.'**
  String get docsFreelancerWelcomeContent;

  /// No description provided for @docsFreelancerVsShopTitle.
  ///
  /// In en, this message translates to:
  /// **'Freelancer vs Shop: What\'s the Difference?'**
  String get docsFreelancerVsShopTitle;

  /// No description provided for @docsFreelancerVsShopContent.
  ///
  /// In en, this message translates to:
  /// **'Here\'s how freelancing works:'**
  String get docsFreelancerVsShopContent;

  /// No description provided for @docsFreelancerIndependent.
  ///
  /// In en, this message translates to:
  /// **'You work independently - no fixed storefront required'**
  String get docsFreelancerIndependent;

  /// No description provided for @docsFreelancerTravel.
  ///
  /// In en, this message translates to:
  /// **'You can travel to clients within your chosen radius'**
  String get docsFreelancerTravel;

  /// No description provided for @docsFreelancerHours.
  ///
  /// In en, this message translates to:
  /// **'You set your own hours and availability'**
  String get docsFreelancerHours;

  /// No description provided for @docsFreelancerManage.
  ///
  /// In en, this message translates to:
  /// **'You manage your own schedule and clients'**
  String get docsFreelancerManage;

  /// No description provided for @docsFreelancerBooking.
  ///
  /// In en, this message translates to:
  /// **'Customers book you directly for services'**
  String get docsFreelancerBooking;

  /// No description provided for @docsFreelancerRequirementsTitle.
  ///
  /// In en, this message translates to:
  /// **'What You\'ll Need'**
  String get docsFreelancerRequirementsTitle;

  /// No description provided for @docsFreelancerRequirementsContent.
  ///
  /// In en, this message translates to:
  /// **'To start as a freelancer, you need: your name, a profession type (hairdresser, massage therapist, etc.), location, travel radius, services, and your working hours. A professional photo helps customers trust you.'**
  String get docsFreelancerRequirementsContent;

  /// No description provided for @docsProfileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Profile'**
  String get docsProfileSetupTitle;

  /// No description provided for @docsProfileSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell customers who you are'**
  String get docsProfileSetupSubtitle;

  /// No description provided for @docsProfilePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Your Profile Photo'**
  String get docsProfilePhotoTitle;

  /// No description provided for @docsProfilePhotoContent.
  ///
  /// In en, this message translates to:
  /// **'A professional headshot or portrait builds trust with customers. Use a clear, well-lit photo of yourself. Customers want to know who they\'re booking with.'**
  String get docsProfilePhotoContent;

  /// No description provided for @docsYourNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get docsYourNameTitle;

  /// No description provided for @docsYourNameContent.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name exactly as you want customers to see it. Be professional and clear.'**
  String get docsYourNameContent;

  /// No description provided for @docsProfessionTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Profession'**
  String get docsProfessionTypeTitle;

  /// No description provided for @docsProfessionTypeContent.
  ///
  /// In en, this message translates to:
  /// **'Select what you do. Examples: Hairdresser, Massage Therapist, Makeup Artist, Barber, Esthetician, or other specialized services.'**
  String get docsProfessionTypeContent;

  /// No description provided for @docsBioDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Write Your Bio'**
  String get docsBioDescriptionTitle;

  /// No description provided for @docsBioDescriptionContent.
  ///
  /// In en, this message translates to:
  /// **'Write a short description about yourself and your experience (50-150 words). Tell customers what makes you unique. Example: \"I specialize in natural hair care with 5 years of experience. Certified in color and styling.\"'**
  String get docsBioDescriptionContent;

  /// No description provided for @docsTermsGuidelinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Your Guidelines'**
  String get docsTermsGuidelinesTitle;

  /// No description provided for @docsTermsGuidelinesContent.
  ///
  /// In en, this message translates to:
  /// **'Share any important rules or policies. Examples: age restrictions, cancellation policy, health requirements, or preparation instructions.'**
  String get docsTermsGuidelinesContent;

  /// No description provided for @docsServiceAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Your Service Area'**
  String get docsServiceAreaTitle;

  /// No description provided for @docsServiceAreaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Define where you work'**
  String get docsServiceAreaSubtitle;

  /// No description provided for @docsBaseLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Your Base Location'**
  String get docsBaseLocationTitle;

  /// No description provided for @docsBaseLocationContent.
  ///
  /// In en, this message translates to:
  /// **'This is where you normally work from. Customers within your travel radius can book you. You can either pin on the map or search for your address.'**
  String get docsBaseLocationContent;

  /// No description provided for @docsTravelRadiusTitle.
  ///
  /// In en, this message translates to:
  /// **'Travel Radius'**
  String get docsTravelRadiusTitle;

  /// No description provided for @docsTravelRadiusContent.
  ///
  /// In en, this message translates to:
  /// **'How far are you willing to travel to meet clients? Set this in kilometers. Example: \"5 km radius\" means clients up to 5 km from your location can book you.'**
  String get docsTravelRadiusContent;

  /// No description provided for @docsMobileVsFixedTitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile or Fixed Location?'**
  String get docsMobileVsFixedTitle;

  /// No description provided for @docsMobileVsFixedContent.
  ///
  /// In en, this message translates to:
  /// **'Choose whether you travel to clients or meet them at one location. If you\'re mobile, customers can request you at their home or office.'**
  String get docsMobileVsFixedContent;

  /// No description provided for @docsServiceAddressTip.
  ///
  /// In en, this message translates to:
  /// **'Customers will see your travel radius when searching. Be accurate so they know if you can serve their area.'**
  String get docsServiceAddressTip;

  /// No description provided for @docsToolsSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'List Your Tools & Equipment'**
  String get docsToolsSetupTitle;

  /// No description provided for @docsToolsSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show customers what you bring'**
  String get docsToolsSetupSubtitle;

  /// No description provided for @docsToolsIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'What Are Tools?'**
  String get docsToolsIntroTitle;

  /// No description provided for @docsToolsIntroContent.
  ///
  /// In en, this message translates to:
  /// **'Tools are the equipment or skills you have. They help customers understand what you can do and what to expect.'**
  String get docsToolsIntroContent;

  /// No description provided for @docsToolExamplesTitle.
  ///
  /// In en, this message translates to:
  /// **'Example Tools'**
  String get docsToolExamplesTitle;

  /// No description provided for @docsToolExamplesContent.
  ///
  /// In en, this message translates to:
  /// **'For different professions:'**
  String get docsToolExamplesContent;

  /// No description provided for @docsToolHairdresser.
  ///
  /// In en, this message translates to:
  /// **'Hairdresser: Blow dryer, flat iron, curling iron, scissors'**
  String get docsToolHairdresser;

  /// No description provided for @docsToolMassage.
  ///
  /// In en, this message translates to:
  /// **'Massage Therapist: Massage table, hot stones, aromatherapy oils'**
  String get docsToolMassage;

  /// No description provided for @docsToolMakeup.
  ///
  /// In en, this message translates to:
  /// **'Makeup Artist: Makeup brushes, airbrush, LED light'**
  String get docsToolMakeup;

  /// No description provided for @docsToolBarber.
  ///
  /// In en, this message translates to:
  /// **'Barber: Electric clippers, straight razor, styling cream'**
  String get docsToolBarber;

  /// No description provided for @docsToolSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Selecting Tools'**
  String get docsToolSelectionTitle;

  /// No description provided for @docsToolSelectionContent.
  ///
  /// In en, this message translates to:
  /// **'Choose all the tools and equipment you use professionally. Customers want to know you have the right equipment for their service.'**
  String get docsToolSelectionContent;

  /// No description provided for @docsServicesSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Services & Pricing'**
  String get docsServicesSetupTitle;

  /// No description provided for @docsServicesSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell customers what you offer'**
  String get docsServicesSetupSubtitle;

  /// No description provided for @docsServiceBasicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Your Services'**
  String get docsServiceBasicsTitle;

  /// No description provided for @docsServiceBasicsContent.
  ///
  /// In en, this message translates to:
  /// **'Each service is something customers can book. Examples: \"Haircut\", \"Full Body Massage\", \"Makeup Application\".'**
  String get docsServiceBasicsContent;

  /// No description provided for @docsServiceInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'For Each Service, Add:'**
  String get docsServiceInfoTitle;

  /// No description provided for @docsServiceInfoContent.
  ///
  /// In en, this message translates to:
  /// **'You need:'**
  String get docsServiceInfoContent;

  /// No description provided for @docsServiceInfoName.
  ///
  /// In en, this message translates to:
  /// **'Service name - what you\'re offering'**
  String get docsServiceInfoName;

  /// No description provided for @docsServiceInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'Description - what it includes'**
  String get docsServiceInfoDescription;

  /// No description provided for @docsServiceInfoPrice.
  ///
  /// In en, this message translates to:
  /// **'Price - how much it costs'**
  String get docsServiceInfoPrice;

  /// No description provided for @docsServiceInfoDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration - how long it takes (30 min, 1 hour, etc.)'**
  String get docsServiceInfoDuration;

  /// No description provided for @docsPricingStrategyTitle.
  ///
  /// In en, this message translates to:
  /// **'Pricing Tips'**
  String get docsPricingStrategyTitle;

  /// No description provided for @docsPricingStrategyContent.
  ///
  /// In en, this message translates to:
  /// **'Research what others charge for similar services in your area. Price competitively but fairly for your experience level.'**
  String get docsPricingStrategyContent;

  /// No description provided for @docsDurationImportanceFreelancer.
  ///
  /// In en, this message translates to:
  /// **'Set duration accurately. This is how long you block out for each booking. Customers rely on this time.'**
  String get docsDurationImportanceFreelancer;

  /// No description provided for @docsHoursSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Your Availability'**
  String get docsHoursSetupTitle;

  /// No description provided for @docsHoursSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When you\'re available to work'**
  String get docsHoursSetupSubtitle;

  /// No description provided for @docsHoursIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get docsHoursIntroTitle;

  /// No description provided for @docsHoursIntroContent.
  ///
  /// In en, this message translates to:
  /// **'Customers can only book during times you mark as available. Set your hours for each day of the week.'**
  String get docsHoursIntroContent;

  /// No description provided for @docsFlexibleHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Be Flexible or Strict?'**
  String get docsFlexibleHoursTitle;

  /// No description provided for @docsFlexibleHoursContent.
  ///
  /// In en, this message translates to:
  /// **'You decide. If you want consistent hours, set them. If you prefer flexibility, you can adjust daily as needed.'**
  String get docsFlexibleHoursContent;

  /// No description provided for @docsBlockTimeTip.
  ///
  /// In en, this message translates to:
  /// **'When a customer books you, that time is blocked on your calendar. Set hours wisely to avoid conflicts.'**
  String get docsBlockTimeTip;

  /// No description provided for @docsContactCredentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Info & Credentials'**
  String get docsContactCredentialsTitle;

  /// No description provided for @docsContactCredentialsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help customers reach you and build trust'**
  String get docsContactCredentialsSubtitle;

  /// No description provided for @docsCreateProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Sell Products Online'**
  String get docsCreateProductTitle;

  /// No description provided for @docsCreateProductSubtitle.
  ///
  /// In en, this message translates to:
  /// **'List items for sale and reach customers in your area'**
  String get docsCreateProductSubtitle;

  /// No description provided for @docsProductOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting Started Selling Products'**
  String get docsProductOverviewTitle;

  /// No description provided for @docsProductOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn how to list and sell items'**
  String get docsProductOverviewSubtitle;

  /// No description provided for @docsProductWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Product Selling'**
  String get docsProductWelcomeTitle;

  /// No description provided for @docsProductWelcomeContent.
  ///
  /// In en, this message translates to:
  /// **'Sell physical products directly to customers in your area. From handmade items to retail goods, you can reach customers looking for what you offer.'**
  String get docsProductWelcomeContent;

  /// No description provided for @docsPhoneRequirementTitle.
  ///
  /// In en, this message translates to:
  /// **'You Need a Verified Phone Number'**
  String get docsPhoneRequirementTitle;

  /// No description provided for @docsPhoneRequirementContent.
  ///
  /// In en, this message translates to:
  /// **'Before you can start selling products, you must verify your phone number. This is for customer communication and to validate your identity.'**
  String get docsPhoneRequirementContent;

  /// No description provided for @docsAddPhoneNumberTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Add Your Phone Number'**
  String get docsAddPhoneNumberTitle;

  /// No description provided for @docsAddPhoneNumberContent.
  ///
  /// In en, this message translates to:
  /// **'Go to your profile settings and add your phone number. You\'ll receive a verification code via SMS to confirm it\'s really your number. This takes just a minute.'**
  String get docsAddPhoneNumberContent;

  /// No description provided for @docsWhyPhoneVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Why Phone Verification?'**
  String get docsWhyPhoneVerifiedTitle;

  /// No description provided for @docsWhyPhoneVerifiedContent.
  ///
  /// In en, this message translates to:
  /// **'A verified phone number builds customer trust and allows us to contact you if there are issues. It also helps prevent fraud.'**
  String get docsWhyPhoneVerifiedContent;

  /// No description provided for @docsPhoneImportant.
  ///
  /// In en, this message translates to:
  /// **'You cannot list products until you have a verified phone number. This is required for all sellers.'**
  String get docsPhoneImportant;

  /// No description provided for @docsProductBasicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic Product Information'**
  String get docsProductBasicsTitle;

  /// No description provided for @docsProductBasicsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What to tell customers about your product'**
  String get docsProductBasicsSubtitle;

  /// No description provided for @docsProductNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get docsProductNameTitle;

  /// No description provided for @docsProductNameContent.
  ///
  /// In en, this message translates to:
  /// **'Enter your product name clearly. Customers search by product name, so be specific. Example: \"Handmade Leather Wallet - Brown\" instead of just \"Wallet\".'**
  String get docsProductNameContent;

  /// No description provided for @docsProductDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Description'**
  String get docsProductDescriptionTitle;

  /// No description provided for @docsProductDescriptionContent.
  ///
  /// In en, this message translates to:
  /// **'Write a detailed description. Tell customers what it is, what it\'s made of, how to use it, and why it\'s good. Be honest about condition (new, used, refurbished).'**
  String get docsProductDescriptionContent;

  /// No description provided for @docsCategorySelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a Category'**
  String get docsCategorySelectionTitle;

  /// No description provided for @docsCategorySelectionContent.
  ///
  /// In en, this message translates to:
  /// **'Select the right category. Customers browse by category to find items, so accuracy matters. Pick the most specific category available.'**
  String get docsCategorySelectionContent;

  /// No description provided for @docsProductConditionTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Condition'**
  String get docsProductConditionTitle;

  /// No description provided for @docsProductConditionContent.
  ///
  /// In en, this message translates to:
  /// **'Be clear about condition: New (never used), Like New (used once), Good (light wear), Fair (visible wear), or As-Is. Honesty builds trust.'**
  String get docsProductConditionContent;

  /// No description provided for @docsPricingStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Price & Availability'**
  String get docsPricingStockTitle;

  /// No description provided for @docsPricingStockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set your price and manage inventory'**
  String get docsPricingStockSubtitle;

  /// No description provided for @docsPricingTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Your Price'**
  String get docsPricingTitle;

  /// No description provided for @docsPricingContent.
  ///
  /// In en, this message translates to:
  /// **'Set a fair price based on condition, market value, and local demand. Customers can see similar items, so competitive pricing helps.'**
  String get docsPricingContent;

  /// No description provided for @docsCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get docsCurrencyTitle;

  /// No description provided for @docsCurrencyContent.
  ///
  /// In en, this message translates to:
  /// **'Prices are shown in your shop\'s currency. Make sure your shop currency is set correctly before adding products.'**
  String get docsCurrencyContent;

  /// No description provided for @docsStockQuantityTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock Quantity'**
  String get docsStockQuantityTitle;

  /// No description provided for @docsStockQuantityContent.
  ///
  /// In en, this message translates to:
  /// **'Enter how many items you have. When stock runs out, the product shows as unavailable. Update this as you sell items.'**
  String get docsStockQuantityContent;

  /// No description provided for @docsStockTip.
  ///
  /// In en, this message translates to:
  /// **'Keep stock accurate. Customers get frustrated if they order something out of stock. Update regularly as you sell.'**
  String get docsStockTip;

  /// No description provided for @docsProductPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Photos'**
  String get docsProductPhotosTitle;

  /// No description provided for @docsProductPhotosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show customers what they\'re buying'**
  String get docsProductPhotosSubtitle;

  /// No description provided for @docsPhotosImportanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos Matter Most'**
  String get docsPhotosImportanceTitle;

  /// No description provided for @docsPhotosImportanceContent.
  ///
  /// In en, this message translates to:
  /// **'Good photos are critical. Customers decide whether to buy based on photos. Poor photos = fewer sales.'**
  String get docsPhotosImportanceContent;

  /// No description provided for @docsWhatPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'What to Photograph'**
  String get docsWhatPhotosTitle;

  /// No description provided for @docsWhatPhotosContent.
  ///
  /// In en, this message translates to:
  /// **'Take photos that show the real product:'**
  String get docsWhatPhotosContent;

  /// No description provided for @docsPhotoFull.
  ///
  /// In en, this message translates to:
  /// **'Full product from multiple angles'**
  String get docsPhotoFull;

  /// No description provided for @docsPhotoCloseups.
  ///
  /// In en, this message translates to:
  /// **'Close-ups of details and quality'**
  String get docsPhotoCloseups;

  /// No description provided for @docsPhotoCondition.
  ///
  /// In en, this message translates to:
  /// **'Photos showing condition (if used)'**
  String get docsPhotoCondition;

  /// No description provided for @docsPhotoScale.
  ///
  /// In en, this message translates to:
  /// **'Photos next to something for scale (like a coin or hand)'**
  String get docsPhotoScale;

  /// No description provided for @docsPhotoDamage.
  ///
  /// In en, this message translates to:
  /// **'Photos of any damage or wear (honesty builds trust)'**
  String get docsPhotoDamage;

  /// No description provided for @docsPhotoTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Quality Tips'**
  String get docsPhotoTipsTitle;

  /// No description provided for @docsPhotoTipsContent.
  ///
  /// In en, this message translates to:
  /// **'Use natural light. Take photos on a clean background. Show colors accurately. Don\'t use filters that change how the product looks.'**
  String get docsPhotoTipsContent;

  /// No description provided for @docsPhotoCountTitle.
  ///
  /// In en, this message translates to:
  /// **'How Many Photos?'**
  String get docsPhotoCountTitle;

  /// No description provided for @docsPhotoCountContent.
  ///
  /// In en, this message translates to:
  /// **'Upload at least 3 clear photos. More photos help customers understand the product better. Limit to 10 photos per product.'**
  String get docsPhotoCountContent;

  /// No description provided for @docsToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Business Tools'**
  String get docsToolsTitle;

  /// No description provided for @docsToolsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Powerful features to automate, promote, and manage your business'**
  String get docsToolsSubtitle;

  /// No description provided for @docsToolsOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Tools Overview'**
  String get docsToolsOverviewTitle;

  /// No description provided for @docsToolsOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What each tool does and how to use it'**
  String get docsToolsOverviewSubtitle;

  /// No description provided for @docsToolsWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Business Tools'**
  String get docsToolsWelcomeTitle;

  /// No description provided for @docsToolsWelcomeContent.
  ///
  /// In en, this message translates to:
  /// **'The Tools tab has 8 powerful features to help you automate, promote, and manage your business more effectively. Each tool solves a specific business problem.'**
  String get docsToolsWelcomeContent;

  /// No description provided for @docsToolsListTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Tools'**
  String get docsToolsListTitle;

  /// No description provided for @docsToolsListContent.
  ///
  /// In en, this message translates to:
  /// **'You have access to these 8 tools:'**
  String get docsToolsListContent;

  /// No description provided for @docsToolsReminders.
  ///
  /// In en, this message translates to:
  /// **'Automated Reminders - Send reminders to customers'**
  String get docsToolsReminders;

  /// No description provided for @docsToolsPromotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions Manager - Create and manage discounts'**
  String get docsToolsPromotions;

  /// No description provided for @docsToolsExport.
  ///
  /// In en, this message translates to:
  /// **'Export Reports - Download your business data'**
  String get docsToolsExport;

  /// No description provided for @docsToolsPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment Settings - Configure how you receive payments'**
  String get docsToolsPayment;

  /// No description provided for @docsToolsHours.
  ///
  /// In en, this message translates to:
  /// **'Business Hours - Set your working schedule'**
  String get docsToolsHours;

  /// No description provided for @docsToolsServices.
  ///
  /// In en, this message translates to:
  /// **'Service Management - Add and edit your services'**
  String get docsToolsServices;

  /// No description provided for @docsToolsLoyalty.
  ///
  /// In en, this message translates to:
  /// **'Loyalty Program - Reward repeat customers'**
  String get docsToolsLoyalty;

  /// No description provided for @docsToolsBroadcasts.
  ///
  /// In en, this message translates to:
  /// **'Broadcasts - Send messages to your customers'**
  String get docsToolsBroadcasts;

  /// No description provided for @docsRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Automated Reminders'**
  String get docsRemindersTitle;

  /// No description provided for @docsRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send automatic reminders to customers'**
  String get docsRemindersSubtitle;

  /// No description provided for @docsReminderPurposeTitle.
  ///
  /// In en, this message translates to:
  /// **'What It Does'**
  String get docsReminderPurposeTitle;

  /// No description provided for @docsReminderPurposeContent.
  ///
  /// In en, this message translates to:
  /// **'Automatically send reminder messages to customers before their bookings. Reduces no-shows and keeps customers informed.'**
  String get docsReminderPurposeContent;

  /// No description provided for @docsReminderBenefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get docsReminderBenefitsTitle;

  /// No description provided for @docsReminderBenefitsContent.
  ///
  /// In en, this message translates to:
  /// **'Automated reminders help you:'**
  String get docsReminderBenefitsContent;

  /// No description provided for @docsReminderBenefitNoShow.
  ///
  /// In en, this message translates to:
  /// **'Reduce no-shows - customers are less likely to forget'**
  String get docsReminderBenefitNoShow;

  /// No description provided for @docsReminderBenefitExperience.
  ///
  /// In en, this message translates to:
  /// **'Improve customer experience - they know when to arrive'**
  String get docsReminderBenefitExperience;

  /// No description provided for @docsReminderBenefitTime.
  ///
  /// In en, this message translates to:
  /// **'Save time - no need to manually call or message'**
  String get docsReminderBenefitTime;

  /// No description provided for @docsReminderBenefitReliability.
  ///
  /// In en, this message translates to:
  /// **'Increase reliability - reminders go out automatically'**
  String get docsReminderBenefitReliability;

  /// No description provided for @docsReminderSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Set It Up'**
  String get docsReminderSetupTitle;

  /// No description provided for @docsReminderSetupContent.
  ///
  /// In en, this message translates to:
  /// **'Click \"Configure Automated Reminders\" to set timing: send reminders 24 hours before, 2 hours before, or on the morning of the appointment.'**
  String get docsReminderSetupContent;

  /// No description provided for @docsReminderImpact.
  ///
  /// In en, this message translates to:
  /// **'Shops using automated reminders see 20-30% fewer no-shows. This directly impacts your revenue.'**
  String get docsReminderImpact;

  /// No description provided for @docsPromosTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Promotions Manager'**
  String get docsPromosTitle;

  /// No description provided for @docsPromosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create special offers and discounts'**
  String get docsPromosSubtitle;

  /// No description provided for @docsPromosPurposeTitle.
  ///
  /// In en, this message translates to:
  /// **'What It Does'**
  String get docsPromosPurposeTitle;

  /// No description provided for @docsPromosPurposeContent.
  ///
  /// In en, this message translates to:
  /// **'Create time-limited promotions and discounts. Offer percentage off, fixed amount off, or free add-ons to attract more customers.'**
  String get docsPromosPurposeContent;

  /// No description provided for @docsPromosExamplesTitle.
  ///
  /// In en, this message translates to:
  /// **'Promotion Ideas'**
  String get docsPromosExamplesTitle;

  /// No description provided for @docsPromosExamplesContent.
  ///
  /// In en, this message translates to:
  /// **'You can create promotions like:'**
  String get docsPromosExamplesContent;

  /// No description provided for @docsPromosExample1.
  ///
  /// In en, this message translates to:
  /// **'20% off haircuts on Mondays'**
  String get docsPromosExample1;

  /// No description provided for @docsPromosExample2.
  ///
  /// In en, this message translates to:
  /// **'Free massage oil with any massage booking'**
  String get docsPromosExample2;

  /// No description provided for @docsPromosExample3.
  ///
  /// In en, this message translates to:
  /// **'50 off a full-service package'**
  String get docsPromosExample3;

  /// No description provided for @docsPromosExample4.
  ///
  /// In en, this message translates to:
  /// **'First-time customer: 30% discount'**
  String get docsPromosExample4;

  /// No description provided for @docsPromosExample5.
  ///
  /// In en, this message translates to:
  /// **'Loyalty bonus: 5th service is half price'**
  String get docsPromosExample5;

  /// No description provided for @docsPromosStrategyTitle.
  ///
  /// In en, this message translates to:
  /// **'Promotion Strategy'**
  String get docsPromosStrategyTitle;

  /// No description provided for @docsPromosStrategyContent.
  ///
  /// In en, this message translates to:
  /// **'Use promotions during slow periods to boost bookings. Track which promotions work best through your analytics.'**
  String get docsPromosStrategyContent;

  /// No description provided for @docsExportTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Export Reports'**
  String get docsExportTitle;

  /// No description provided for @docsExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download your data for analysis'**
  String get docsExportSubtitle;

  /// No description provided for @docsExportPurposeTitle.
  ///
  /// In en, this message translates to:
  /// **'What It Does'**
  String get docsExportPurposeTitle;

  /// No description provided for @docsExportPurposeContent.
  ///
  /// In en, this message translates to:
  /// **'Download detailed reports of your business data in spreadsheet format. Analyze bookings, revenue, customers, and more.'**
  String get docsExportPurposeContent;

  /// No description provided for @docsExportTypesTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Reports'**
  String get docsExportTypesTitle;

  /// No description provided for @docsExportTypesContent.
  ///
  /// In en, this message translates to:
  /// **'You can export:'**
  String get docsExportTypesContent;

  /// No description provided for @docsExportBookings.
  ///
  /// In en, this message translates to:
  /// **'Booking reports - all bookings with details'**
  String get docsExportBookings;

  /// No description provided for @docsExportRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue reports - earnings by date range'**
  String get docsExportRevenue;

  /// No description provided for @docsExportCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customer reports - your client list'**
  String get docsExportCustomers;

  /// No description provided for @docsExportServices.
  ///
  /// In en, this message translates to:
  /// **'Service reports - performance by service'**
  String get docsExportServices;

  /// No description provided for @docsExportWorkers.
  ///
  /// In en, this message translates to:
  /// **'Worker reports - staff performance metrics'**
  String get docsExportWorkers;

  /// No description provided for @docsExportUsesTitle.
  ///
  /// In en, this message translates to:
  /// **'Why Export Data?'**
  String get docsExportUsesTitle;

  /// No description provided for @docsExportUsesContent.
  ///
  /// In en, this message translates to:
  /// **'Use exported data in Excel for custom analysis, record-keeping, tax purposes, or sharing with accountant.'**
  String get docsExportUsesContent;

  /// No description provided for @docsTimeSlotsTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Slots Explained'**
  String get docsTimeSlotsTitle;

  /// No description provided for @docsTimeSlotsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Understanding how booking times work'**
  String get docsTimeSlotsSubtitle;

  /// No description provided for @docsTimeSlotsOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'What Are Time Slots?'**
  String get docsTimeSlotsOverviewTitle;

  /// No description provided for @docsTimeSlotsOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn how the scheduling system works'**
  String get docsTimeSlotsOverviewSubtitle;

  /// No description provided for @docsTimeSlotsWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Time Slots'**
  String get docsTimeSlotsWelcomeTitle;

  /// No description provided for @docsTimeSlotsWelcomeContent.
  ///
  /// In en, this message translates to:
  /// **'Time slots are the available times when customers can book your services. Understanding how they work helps you manage your schedule efficiently.'**
  String get docsTimeSlotsWelcomeContent;

  /// No description provided for @docsTimeSlotsBasicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Slot Basics'**
  String get docsTimeSlotsBasicsTitle;

  /// No description provided for @docsTimeSlotsBasicsContent.
  ///
  /// In en, this message translates to:
  /// **'Here\'s how time slots work:'**
  String get docsTimeSlotsBasicsContent;

  /// No description provided for @docsTimeSlotsPoint1.
  ///
  /// In en, this message translates to:
  /// **'Each service has a duration (how long it takes)'**
  String get docsTimeSlotsPoint1;

  /// No description provided for @docsTimeSlotsPoint2.
  ///
  /// In en, this message translates to:
  /// **'You set your available hours (when you work)'**
  String get docsTimeSlotsPoint2;

  /// No description provided for @docsTimeSlotsPoint3.
  ///
  /// In en, this message translates to:
  /// **'The system creates time slots based on service duration'**
  String get docsTimeSlotsPoint3;

  /// No description provided for @docsTimeSlotsPoint4.
  ///
  /// In en, this message translates to:
  /// **'Customers can only book available slots'**
  String get docsTimeSlotsPoint4;

  /// No description provided for @docsTimeSlotsExampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Example: Creating Time Slots'**
  String get docsTimeSlotsExampleTitle;

  /// No description provided for @docsTimeSlotsExampleContent.
  ///
  /// In en, this message translates to:
  /// **'If you offer a 30-minute haircut and work 9 AM to 5 PM:\n• 9:00 AM - 9:30 AM (Slot 1)\n• 9:30 AM - 10:00 AM (Slot 2)\n• 10:00 AM - 10:30 AM (Slot 3)\n...and so on throughout the day'**
  String get docsTimeSlotsExampleContent;

  /// No description provided for @docsTimeSlotsOverlapTitle.
  ///
  /// In en, this message translates to:
  /// **'What If Services Overlap?'**
  String get docsTimeSlotsOverlapTitle;

  /// No description provided for @docsTimeSlotsOverlapContent.
  ///
  /// In en, this message translates to:
  /// **'If you have multiple staff, each person has their own schedule. If you work alone, only one customer can book at a time — the system blocks conflicting times automatically.'**
  String get docsTimeSlotsOverlapContent;

  /// No description provided for @docsTimeSlotsGapTitle.
  ///
  /// In en, this message translates to:
  /// **'Setting Gaps Between Services'**
  String get docsTimeSlotsGapTitle;

  /// No description provided for @docsTimeSlotsGapContent.
  ///
  /// In en, this message translates to:
  /// **'You can set buffer time between bookings. Example: 15-minute gap after each haircut for cleanup. This reduces the available slots but gives you breathing room.'**
  String get docsTimeSlotsGapContent;

  /// No description provided for @docsTimeSlotsGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Group Bookings and Time Slots'**
  String get docsTimeSlotsGroupTitle;

  /// No description provided for @docsTimeSlotsGroupContent.
  ///
  /// In en, this message translates to:
  /// **'For group bookings, the system finds times that work for ALL people in the group. This makes it harder to find available slots, but ensures everyone gets served together.'**
  String get docsTimeSlotsGroupContent;

  /// No description provided for @docsTimeSlotsBlockingTitle.
  ///
  /// In en, this message translates to:
  /// **'Blocking Time'**
  String get docsTimeSlotsBlockingTitle;

  /// No description provided for @docsTimeSlotsBlockingContent.
  ///
  /// In en, this message translates to:
  /// **'You can manually block time for lunch, breaks, or personal appointments. Blocked time won\'t show as available to customers.'**
  String get docsTimeSlotsBlockingContent;

  /// No description provided for @docsTimeSlotsUtilizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Maximizing Your Time Slots'**
  String get docsTimeSlotsUtilizationTitle;

  /// No description provided for @docsTimeSlotsUtilizationContent.
  ///
  /// In en, this message translates to:
  /// **'Tips to use your slots efficiently:\n• Match service duration to reality (don\'t underestimate)\n• Set realistic gaps between services\n• Use buffer time strategically\n• Review and adjust based on customer feedback'**
  String get docsTimeSlotsUtilizationContent;

  /// No description provided for @docsGettingStartedWhatIsNanoembryo_title.
  ///
  /// In en, this message translates to:
  /// **'What is Aura In?'**
  String get docsGettingStartedWhatIsNanoembryo_title;

  /// No description provided for @docsGettingStartedWhatIsNanoembryo_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Understand the platform'**
  String get docsGettingStartedWhatIsNanoembryo_subtitle;

  /// No description provided for @docsGettingStartedWhatIsNanoembryo_welcomeIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Aura In'**
  String get docsGettingStartedWhatIsNanoembryo_welcomeIntroTitle;

  /// No description provided for @docsGettingStartedWhatIsNanoembryo_welcomeIntroContent.
  ///
  /// In en, this message translates to:
  /// **'Aura In is a mobile marketplace connecting service professionals with customers. Whether you offer haircuts, massages, freelance services, or sell products, this platform helps you grow your business.'**
  String get docsGettingStartedWhatIsNanoembryo_welcomeIntroContent;

  /// No description provided for @docsGettingStartedWhatIsNanoembryo_whoUsesAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Who Uses Aura In?'**
  String get docsGettingStartedWhatIsNanoembryo_whoUsesAppTitle;

  /// No description provided for @docsGettingStartedWhatIsNanoembryo_whoUsesAppContent.
  ///
  /// In en, this message translates to:
  /// **'Two types of users power the platform:'**
  String get docsGettingStartedWhatIsNanoembryo_whoUsesAppContent;

  /// No description provided for @docsGettingStartedWhatIsNanoembryo_whoUsesAppBullet1.
  ///
  /// In en, this message translates to:
  /// **'Service Providers - Salons, spas, barbers, freelancers who offer services'**
  String get docsGettingStartedWhatIsNanoembryo_whoUsesAppBullet1;

  /// No description provided for @docsGettingStartedWhatIsNanoembryo_whoUsesAppBullet2.
  ///
  /// In en, this message translates to:
  /// **'Customers - People searching for and booking services in their area'**
  String get docsGettingStartedWhatIsNanoembryo_whoUsesAppBullet2;

  /// No description provided for @docsGettingStartedWhatIsNanoembryo_whoUsesAppBullet3.
  ///
  /// In en, this message translates to:
  /// **'Product Sellers - Shops selling retail products or handmade items'**
  String get docsGettingStartedWhatIsNanoembryo_whoUsesAppBullet3;

  /// No description provided for @docsGettingStartedWhatIsNanoembryo_howItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get docsGettingStartedWhatIsNanoembryo_howItWorksTitle;

  /// No description provided for @docsGettingStartedWhatIsNanoembryo_howItWorksContent.
  ///
  /// In en, this message translates to:
  /// **'Service providers create a profile, list their services with pricing, and accept bookings from customers. Customers search by location, browse services, and book appointments. Everything is managed through the app.'**
  String get docsGettingStartedWhatIsNanoembryo_howItWorksContent;

  /// No description provided for @docsGettingStartedThreeUserTypes_title.
  ///
  /// In en, this message translates to:
  /// **'Three Ways to Use Aura In'**
  String get docsGettingStartedThreeUserTypes_title;

  /// No description provided for @docsGettingStartedThreeUserTypes_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your role'**
  String get docsGettingStartedThreeUserTypes_subtitle;

  /// No description provided for @docsGettingStartedThreeUserTypes_optionCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Option 1: Browse & Book Services (Customer)'**
  String get docsGettingStartedThreeUserTypes_optionCustomerTitle;

  /// No description provided for @docsGettingStartedThreeUserTypes_optionCustomerContent.
  ///
  /// In en, this message translates to:
  /// **'Search for salons, massage therapists, barbers, or freelancers near you. View their services, pricing, and availability. Book appointments directly through the app and pay securely.'**
  String get docsGettingStartedThreeUserTypes_optionCustomerContent;

  /// No description provided for @docsGettingStartedThreeUserTypes_guestBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest Booking (No App Download Needed)'**
  String get docsGettingStartedThreeUserTypes_guestBookingTitle;

  /// No description provided for @docsGettingStartedThreeUserTypes_guestBookingContent.
  ///
  /// In en, this message translates to:
  /// **'Don\'t want to download the app? Service providers can share a booking link - you can book and pay directly through that link without creating an account. Your booking details and receipt will be sent to your WhatsApp.'**
  String get docsGettingStartedThreeUserTypes_guestBookingContent;

  /// No description provided for @docsGettingStartedThreeUserTypes_optionProviderTitle.
  ///
  /// In en, this message translates to:
  /// **'Option 2: Offer Services (Shop Owner or Freelancer)'**
  String get docsGettingStartedThreeUserTypes_optionProviderTitle;

  /// No description provided for @docsGettingStartedThreeUserTypes_optionProviderContent.
  ///
  /// In en, this message translates to:
  /// **'Create a shop or freelancer profile, list your services with pricing and duration, set your working hours, and manage bookings. Get paid for every service booked.'**
  String get docsGettingStartedThreeUserTypes_optionProviderContent;

  /// No description provided for @docsGettingStartedThreeUserTypes_optionSellerTitle.
  ///
  /// In en, this message translates to:
  /// **'Option 3: Sell Products (Product Seller)'**
  String get docsGettingStartedThreeUserTypes_optionSellerTitle;

  /// No description provided for @docsGettingStartedThreeUserTypes_optionSellerContent.
  ///
  /// In en, this message translates to:
  /// **'If you make handmade items or sell products, you can list them for sale. Customers browse and purchase directly from your shop.'**
  String get docsGettingStartedThreeUserTypes_optionSellerContent;

  /// No description provided for @docsGettingStartedKeyFeatures_title.
  ///
  /// In en, this message translates to:
  /// **'Platform Features'**
  String get docsGettingStartedKeyFeatures_title;

  /// No description provided for @docsGettingStartedKeyFeatures_subtitle.
  ///
  /// In en, this message translates to:
  /// **'What you can do'**
  String get docsGettingStartedKeyFeatures_subtitle;

  /// No description provided for @docsGettingStartedKeyFeatures_featuresOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Core Platform Features'**
  String get docsGettingStartedKeyFeatures_featuresOverviewTitle;

  /// No description provided for @docsGettingStartedKeyFeatures_featuresOverviewContent.
  ///
  /// In en, this message translates to:
  /// **'Aura In includes everything you need to run a service business:'**
  String get docsGettingStartedKeyFeatures_featuresOverviewContent;

  /// No description provided for @docsGettingStartedKeyFeatures_featuresOverviewBullet1.
  ///
  /// In en, this message translates to:
  /// **'Booking System - Customers book services, you manage calendar'**
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet1;

  /// No description provided for @docsGettingStartedKeyFeatures_featuresOverviewBullet2.
  ///
  /// In en, this message translates to:
  /// **'Secure Payments - Accept payments via Paystack or Stripe'**
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet2;

  /// No description provided for @docsGettingStartedKeyFeatures_featuresOverviewBullet3.
  ///
  /// In en, this message translates to:
  /// **'Real-time Chat - Communicate with customers before/after bookings'**
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet3;

  /// No description provided for @docsGettingStartedKeyFeatures_featuresOverviewBullet4.
  ///
  /// In en, this message translates to:
  /// **'Location-based Search - Customers find you by location using Google Maps'**
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet4;

  /// No description provided for @docsGettingStartedKeyFeatures_featuresOverviewBullet5.
  ///
  /// In en, this message translates to:
  /// **'Business Dashboard - Analytics, revenue tracking, client management'**
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet5;

  /// No description provided for @docsGettingStartedKeyFeatures_featuresOverviewBullet6.
  ///
  /// In en, this message translates to:
  /// **'Team Management - Add staff members and assign them to services'**
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet6;

  /// No description provided for @docsGettingStartedKeyFeatures_featuresOverviewBullet7.
  ///
  /// In en, this message translates to:
  /// **'Automated Reminders - Send appointment reminders to reduce no-shows'**
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet7;

  /// No description provided for @docsGettingStartedKeyFeatures_featuresOverviewBullet8.
  ///
  /// In en, this message translates to:
  /// **'Promotions & Loyalty - Run discounts and reward repeat customers'**
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet8;

  /// No description provided for @docsGettingStartedKeyFeatures_featuresOverviewBullet9.
  ///
  /// In en, this message translates to:
  /// **'Product Selling - List items for sale if you offer products'**
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet9;

  /// No description provided for @docsGettingStartedKeyFeatures_featuresOverviewBullet10.
  ///
  /// In en, this message translates to:
  /// **'Reviews & Ratings - Build trust through customer feedback'**
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet10;

  /// No description provided for @docsGettingStartedForCustomers_title.
  ///
  /// In en, this message translates to:
  /// **'For Customers'**
  String get docsGettingStartedForCustomers_title;

  /// No description provided for @docsGettingStartedForCustomers_subtitle.
  ///
  /// In en, this message translates to:
  /// **'How to find and book services'**
  String get docsGettingStartedForCustomers_subtitle;

  /// No description provided for @docsGettingStartedForCustomers_customerStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting Started as a Customer'**
  String get docsGettingStartedForCustomers_customerStartTitle;

  /// No description provided for @docsGettingStartedForCustomers_customerStartContent.
  ///
  /// In en, this message translates to:
  /// **'Create an account, set your location, and start searching for services. You can view service providers near you, read reviews, check pricing, and book appointments.'**
  String get docsGettingStartedForCustomers_customerStartContent;

  /// No description provided for @docsGettingStartedForCustomers_customerFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer Capabilities'**
  String get docsGettingStartedForCustomers_customerFeaturesTitle;

  /// No description provided for @docsGettingStartedForCustomers_customerFeaturesContent.
  ///
  /// In en, this message translates to:
  /// **'As a customer, you can:'**
  String get docsGettingStartedForCustomers_customerFeaturesContent;

  /// No description provided for @docsGettingStartedForCustomers_customerFeaturesBullet1.
  ///
  /// In en, this message translates to:
  /// **'Search services by location (using Google Maps)'**
  String get docsGettingStartedForCustomers_customerFeaturesBullet1;

  /// No description provided for @docsGettingStartedForCustomers_customerFeaturesBullet2.
  ///
  /// In en, this message translates to:
  /// **'Filter by type of service, price range, or ratings'**
  String get docsGettingStartedForCustomers_customerFeaturesBullet2;

  /// No description provided for @docsGettingStartedForCustomers_customerFeaturesBullet3.
  ///
  /// In en, this message translates to:
  /// **'View detailed service provider profiles and reviews'**
  String get docsGettingStartedForCustomers_customerFeaturesBullet3;

  /// No description provided for @docsGettingStartedForCustomers_customerFeaturesBullet4.
  ///
  /// In en, this message translates to:
  /// **'Book appointments and select preferred staff member'**
  String get docsGettingStartedForCustomers_customerFeaturesBullet4;

  /// No description provided for @docsGettingStartedForCustomers_customerFeaturesBullet5.
  ///
  /// In en, this message translates to:
  /// **'Chat with providers before booking'**
  String get docsGettingStartedForCustomers_customerFeaturesBullet5;

  /// No description provided for @docsGettingStartedForCustomers_customerFeaturesBullet6.
  ///
  /// In en, this message translates to:
  /// **'Pay securely through the app'**
  String get docsGettingStartedForCustomers_customerFeaturesBullet6;

  /// No description provided for @docsGettingStartedForCustomers_customerFeaturesBullet7.
  ///
  /// In en, this message translates to:
  /// **'Receive appointment reminders'**
  String get docsGettingStartedForCustomers_customerFeaturesBullet7;

  /// No description provided for @docsGettingStartedForCustomers_customerFeaturesBullet8.
  ///
  /// In en, this message translates to:
  /// **'Rate and review services after completion'**
  String get docsGettingStartedForCustomers_customerFeaturesBullet8;

  /// No description provided for @docsGettingStartedFaq1Q.
  ///
  /// In en, this message translates to:
  /// **'What is Aura In?'**
  String get docsGettingStartedFaq1Q;

  /// No description provided for @docsGettingStartedFaq1A.
  ///
  /// In en, this message translates to:
  /// **'Aura In is a mobile marketplace for service-based businesses. Customers find and book services (haircuts, massages, etc.), service providers manage bookings and revenue, and product sellers list items for sale.'**
  String get docsGettingStartedFaq1A;

  /// No description provided for @docsGettingStartedFaq2Q.
  ///
  /// In en, this message translates to:
  /// **'Do I need to pay to use the app?'**
  String get docsGettingStartedFaq2Q;

  /// No description provided for @docsGettingStartedFaq2A.
  ///
  /// In en, this message translates to:
  /// **'The app is free to download and use. Service providers only pay a small commission when customers pay for services. Payment processors (Paystack/Stripe) take a fee.'**
  String get docsGettingStartedFaq2A;

  /// No description provided for @docsGettingStartedFaq3Q.
  ///
  /// In en, this message translates to:
  /// **'What is the difference between Shop Owner and Freelancer?'**
  String get docsGettingStartedFaq3Q;

  /// No description provided for @docsGettingStartedFaq3A.
  ///
  /// In en, this message translates to:
  /// **'Shop owners have a fixed location with a team of workers. Freelancers work independently and can travel to clients. Choose based on your business model.'**
  String get docsGettingStartedFaq3A;

  /// No description provided for @docsGettingStartedFaq4Q.
  ///
  /// In en, this message translates to:
  /// **'How do I get paid?'**
  String get docsGettingStartedFaq4Q;

  /// No description provided for @docsGettingStartedFaq4A.
  ///
  /// In en, this message translates to:
  /// **'When customers pay for services, money goes to your wallet. You can withdraw to your bank account using Paystack (Africa) or Stripe (Global).'**
  String get docsGettingStartedFaq4A;

  /// No description provided for @docsGettingStartedFaq5Q.
  ///
  /// In en, this message translates to:
  /// **'Is my payment information secure?'**
  String get docsGettingStartedFaq5Q;

  /// No description provided for @docsGettingStartedFaq5A.
  ///
  /// In en, this message translates to:
  /// **'Yes. Aura In uses Paystack and Stripe, industry-leading payment processors with bank-level security. We never see your payment details.'**
  String get docsGettingStartedFaq5A;

  /// No description provided for @docsCreateShopShopOverview_title.
  ///
  /// In en, this message translates to:
  /// **'Getting Started with Your Shop'**
  String get docsCreateShopShopOverview_title;

  /// No description provided for @docsCreateShopShopOverview_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn the basics of creating your business profile'**
  String get docsCreateShopShopOverview_subtitle;

  /// No description provided for @docsCreateShopShopOverview_welcomeIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Your Shop Dashboard'**
  String get docsCreateShopShopOverview_welcomeIntroTitle;

  /// No description provided for @docsCreateShopShopOverview_welcomeIntroContent.
  ///
  /// In en, this message translates to:
  /// **'Creating a shop on Aura In takes just a few minutes. You\'ll add your business information, set your services and working hours, and you\'re ready to accept bookings from customers.'**
  String get docsCreateShopShopOverview_welcomeIntroContent;

  /// No description provided for @docsCreateShopShopOverview_setupStepsOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'What You\'ll Set Up'**
  String get docsCreateShopShopOverview_setupStepsOverviewTitle;

  /// No description provided for @docsCreateShopShopOverview_setupStepsOverviewContent.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what you\'ll do when creating your shop:'**
  String get docsCreateShopShopOverview_setupStepsOverviewContent;

  /// No description provided for @docsCreateShopShopOverview_setupStepsOverviewBullet1.
  ///
  /// In en, this message translates to:
  /// **'Add your shop name and logo'**
  String get docsCreateShopShopOverview_setupStepsOverviewBullet1;

  /// No description provided for @docsCreateShopShopOverview_setupStepsOverviewBullet2.
  ///
  /// In en, this message translates to:
  /// **'Write a brief description of your business'**
  String get docsCreateShopShopOverview_setupStepsOverviewBullet2;

  /// No description provided for @docsCreateShopShopOverview_setupStepsOverviewBullet3.
  ///
  /// In en, this message translates to:
  /// **'Choose your shop type (salon, barber, spa, etc.)'**
  String get docsCreateShopShopOverview_setupStepsOverviewBullet3;

  /// No description provided for @docsCreateShopShopOverview_setupStepsOverviewBullet4.
  ///
  /// In en, this message translates to:
  /// **'Set your location and service address'**
  String get docsCreateShopShopOverview_setupStepsOverviewBullet4;

  /// No description provided for @docsCreateShopShopOverview_setupStepsOverviewBullet5.
  ///
  /// In en, this message translates to:
  /// **'Add your working hours'**
  String get docsCreateShopShopOverview_setupStepsOverviewBullet5;

  /// No description provided for @docsCreateShopShopOverview_setupStepsOverviewBullet6.
  ///
  /// In en, this message translates to:
  /// **'Create services you offer with pricing'**
  String get docsCreateShopShopOverview_setupStepsOverviewBullet6;

  /// No description provided for @docsCreateShopShopOverview_setupStepsOverviewBullet7.
  ///
  /// In en, this message translates to:
  /// **'Add contact information'**
  String get docsCreateShopShopOverview_setupStepsOverviewBullet7;

  /// No description provided for @docsCreateShopShopOverview_setupStepsOverviewBullet8.
  ///
  /// In en, this message translates to:
  /// **'Upload photos and documents'**
  String get docsCreateShopShopOverview_setupStepsOverviewBullet8;

  /// No description provided for @docsCreateShopShopOverview_saveProgressTipContent.
  ///
  /// In en, this message translates to:
  /// **'Your work is saved automatically as you fill in the form. You can come back anytime to continue editing or publish when ready.'**
  String get docsCreateShopShopOverview_saveProgressTipContent;

  /// No description provided for @docsCreateShopBasicInfo_title.
  ///
  /// In en, this message translates to:
  /// **'Basic Shop Information'**
  String get docsCreateShopBasicInfo_title;

  /// No description provided for @docsCreateShopBasicInfo_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell customers who you are'**
  String get docsCreateShopBasicInfo_subtitle;

  /// No description provided for @docsCreateShopBasicInfo_logoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Your Shop Logo'**
  String get docsCreateShopBasicInfo_logoSectionTitle;

  /// No description provided for @docsCreateShopBasicInfo_logoSectionContent.
  ///
  /// In en, this message translates to:
  /// **'Your logo is the first thing customers see. It should clearly represent your business. Use a square image (e.g., 500x500 pixels) for best results.'**
  String get docsCreateShopBasicInfo_logoSectionContent;

  /// No description provided for @docsCreateShopBasicInfo_shopNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop Name'**
  String get docsCreateShopBasicInfo_shopNameTitle;

  /// No description provided for @docsCreateShopBasicInfo_shopNameContent.
  ///
  /// In en, this message translates to:
  /// **'Enter your business name exactly as you want customers to see it. Be clear and professional. Example: \"Marie\'s Hair Studio\" or \"City Barbershop\"'**
  String get docsCreateShopBasicInfo_shopNameContent;

  /// No description provided for @docsCreateShopBasicInfo_shopTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Shop Type'**
  String get docsCreateShopBasicInfo_shopTypeTitle;

  /// No description provided for @docsCreateShopBasicInfo_shopTypeContent.
  ///
  /// In en, this message translates to:
  /// **'Select the type of business you run. This helps customers find you in search. Available types include:'**
  String get docsCreateShopBasicInfo_shopTypeContent;

  /// No description provided for @docsCreateShopBasicInfo_shopTypeBullet1.
  ///
  /// In en, this message translates to:
  /// **'Hair Salon - for haircuts, coloring, styling'**
  String get docsCreateShopBasicInfo_shopTypeBullet1;

  /// No description provided for @docsCreateShopBasicInfo_shopTypeBullet2.
  ///
  /// In en, this message translates to:
  /// **'Barber Shop - for men\'s haircuts and grooming'**
  String get docsCreateShopBasicInfo_shopTypeBullet2;

  /// No description provided for @docsCreateShopBasicInfo_shopTypeBullet3.
  ///
  /// In en, this message translates to:
  /// **'Spa - for massages, facials, wellness services'**
  String get docsCreateShopBasicInfo_shopTypeBullet3;

  /// No description provided for @docsCreateShopBasicInfo_shopTypeBullet4.
  ///
  /// In en, this message translates to:
  /// **'Beauty Services - makeup, nails, and other beauty treatments'**
  String get docsCreateShopBasicInfo_shopTypeBullet4;

  /// No description provided for @docsCreateShopBasicInfo_shopTypeBullet5.
  ///
  /// In en, this message translates to:
  /// **'Other Services - for businesses not listed above'**
  String get docsCreateShopBasicInfo_shopTypeBullet5;

  /// No description provided for @docsCreateShopBasicInfo_descriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop Description'**
  String get docsCreateShopBasicInfo_descriptionTitle;

  /// No description provided for @docsCreateShopBasicInfo_descriptionContent.
  ///
  /// In en, this message translates to:
  /// **'Write a short description about your shop (100-200 words). Tell customers what makes you special. Example: \"We specialize in natural hair care and modern styling for all hair types. Family-friendly environment with professional stylists.\"'**
  String get docsCreateShopBasicInfo_descriptionContent;

  /// No description provided for @docsCreateShopBasicInfo_termsInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get docsCreateShopBasicInfo_termsInfoTitle;

  /// No description provided for @docsCreateShopBasicInfo_termsInfoContent.
  ///
  /// In en, this message translates to:
  /// **'Add any important rules customers should know. Examples: cancellation policy, age restrictions, deposit requirements, dress code, or health restrictions.'**
  String get docsCreateShopBasicInfo_termsInfoContent;

  /// No description provided for @docsCreateShopLocationSetup_title.
  ///
  /// In en, this message translates to:
  /// **'Location & Hours'**
  String get docsCreateShopLocationSetup_title;

  /// No description provided for @docsCreateShopLocationSetup_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Where customers can find you and when you work'**
  String get docsCreateShopLocationSetup_subtitle;

  /// No description provided for @docsCreateShopLocationSetup_locationIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Your Location'**
  String get docsCreateShopLocationSetup_locationIntroTitle;

  /// No description provided for @docsCreateShopLocationSetup_locationIntroContent.
  ///
  /// In en, this message translates to:
  /// **'Customers need to know where to find you. You can either:'**
  String get docsCreateShopLocationSetup_locationIntroContent;

  /// No description provided for @docsCreateShopLocationSetup_locationIntroBullet1.
  ///
  /// In en, this message translates to:
  /// **'Pin your location on the map (drag the marker)'**
  String get docsCreateShopLocationSetup_locationIntroBullet1;

  /// No description provided for @docsCreateShopLocationSetup_locationIntroBullet2.
  ///
  /// In en, this message translates to:
  /// **'Search for your address in the search box'**
  String get docsCreateShopLocationSetup_locationIntroBullet2;

  /// No description provided for @docsCreateShopLocationSetup_locationIntroBullet3.
  ///
  /// In en, this message translates to:
  /// **'Enter your street address manually'**
  String get docsCreateShopLocationSetup_locationIntroBullet3;

  /// No description provided for @docsCreateShopLocationSetup_locationAccuracyContent.
  ///
  /// In en, this message translates to:
  /// **'Make sure your location is accurate. Customers use it to find you and calculate travel time.'**
  String get docsCreateShopLocationSetup_locationAccuracyContent;

  /// No description provided for @docsCreateShopLocationSetup_workingHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Your Working Hours'**
  String get docsCreateShopLocationSetup_workingHoursTitle;

  /// No description provided for @docsCreateShopLocationSetup_workingHoursContent.
  ///
  /// In en, this message translates to:
  /// **'Customers can only book times when you\'re open. Set your hours for each day of the week.'**
  String get docsCreateShopLocationSetup_workingHoursContent;

  /// No description provided for @docsCreateShopLocationSetup_hoursExampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Example Hours'**
  String get docsCreateShopLocationSetup_hoursExampleTitle;

  /// No description provided for @docsCreateShopLocationSetup_hoursExampleContent.
  ///
  /// In en, this message translates to:
  /// **'Monday - Friday: 9:00 AM to 6:00 PM\nSaturday: 9:00 AM to 5:00 PM\nSunday: Closed'**
  String get docsCreateShopLocationSetup_hoursExampleContent;

  /// No description provided for @docsCreateShopLocationSetup_hoursTipContent.
  ///
  /// In en, this message translates to:
  /// **'You can set different hours for different days, or mark any day as closed when you\'re not working.'**
  String get docsCreateShopLocationSetup_hoursTipContent;

  /// No description provided for @docsCreateShopServicesSetup_title.
  ///
  /// In en, this message translates to:
  /// **'Services & Pricing'**
  String get docsCreateShopServicesSetup_title;

  /// No description provided for @docsCreateShopServicesSetup_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell customers what you offer and how much it costs'**
  String get docsCreateShopServicesSetup_subtitle;

  /// No description provided for @docsCreateShopServicesSetup_servicesIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Your Services'**
  String get docsCreateShopServicesSetup_servicesIntroTitle;

  /// No description provided for @docsCreateShopServicesSetup_servicesIntroContent.
  ///
  /// In en, this message translates to:
  /// **'Each service is something customers can book and pay for. Examples: \"Haircut\", \"Hair Color\", \"Massage\", \"Facial Treatment\".'**
  String get docsCreateShopServicesSetup_servicesIntroContent;

  /// No description provided for @docsCreateShopServicesSetup_serviceDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'For Each Service, Add:'**
  String get docsCreateShopServicesSetup_serviceDetailsTitle;

  /// No description provided for @docsCreateShopServicesSetup_serviceDetailsContent.
  ///
  /// In en, this message translates to:
  /// **'When you create a service, you need to provide:'**
  String get docsCreateShopServicesSetup_serviceDetailsContent;

  /// No description provided for @docsCreateShopServicesSetup_serviceDetailsBullet1.
  ///
  /// In en, this message translates to:
  /// **'Service name - what you\'re offering (e.g., \"Haircut\")'**
  String get docsCreateShopServicesSetup_serviceDetailsBullet1;

  /// No description provided for @docsCreateShopServicesSetup_serviceDetailsBullet2.
  ///
  /// In en, this message translates to:
  /// **'Description - brief details about what\'s included'**
  String get docsCreateShopServicesSetup_serviceDetailsBullet2;

  /// No description provided for @docsCreateShopServicesSetup_serviceDetailsBullet3.
  ///
  /// In en, this message translates to:
  /// **'Price - how much the service costs'**
  String get docsCreateShopServicesSetup_serviceDetailsBullet3;

  /// No description provided for @docsCreateShopServicesSetup_serviceDetailsBullet4.
  ///
  /// In en, this message translates to:
  /// **'Duration - how long it takes (e.g., 30 minutes, 1 hour)'**
  String get docsCreateShopServicesSetup_serviceDetailsBullet4;

  /// No description provided for @docsCreateShopServicesSetup_serviceDetailsBullet5.
  ///
  /// In en, this message translates to:
  /// **'Category - what type of service it is'**
  String get docsCreateShopServicesSetup_serviceDetailsBullet5;

  /// No description provided for @docsCreateShopServicesSetup_pricingTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Pricing Tip'**
  String get docsCreateShopServicesSetup_pricingTipTitle;

  /// No description provided for @docsCreateShopServicesSetup_pricingTipContent.
  ///
  /// In en, this message translates to:
  /// **'Be clear with your prices. You can offer different service tiers (e.g., \"Basic Haircut\" vs \"Premium Haircut\") at different prices.'**
  String get docsCreateShopServicesSetup_pricingTipContent;

  /// No description provided for @docsCreateShopServicesSetup_durationImportantContent.
  ///
  /// In en, this message translates to:
  /// **'Set the duration accurately. Customers book based on this time, and staff need to know how long to reserve.'**
  String get docsCreateShopServicesSetup_durationImportantContent;

  /// No description provided for @docsCreateShopFaq1Q.
  ///
  /// In en, this message translates to:
  /// **'How long does it take to create a shop?'**
  String get docsCreateShopFaq1Q;

  /// No description provided for @docsCreateShopFaq1A.
  ///
  /// In en, this message translates to:
  /// **'Most businesses can set up a shop in 5-15 minutes. You just need your business name, location, at least one service, and working hours.'**
  String get docsCreateShopFaq1A;

  /// No description provided for @docsCreateShopFaq2Q.
  ///
  /// In en, this message translates to:
  /// **'What do I need to start?'**
  String get docsCreateShopFaq2Q;

  /// No description provided for @docsCreateShopFaq2A.
  ///
  /// In en, this message translates to:
  /// **'You need: your business name, location address, shop type, at least one service with pricing, and your working hours. A logo and photos are optional but recommended.'**
  String get docsCreateShopFaq2A;

  /// No description provided for @docsCreateShopFaq3Q.
  ///
  /// In en, this message translates to:
  /// **'Can I change things after publishing?'**
  String get docsCreateShopFaq3Q;

  /// No description provided for @docsCreateShopFaq3A.
  ///
  /// In en, this message translates to:
  /// **'Yes! You can edit everything after your shop is live. Go to \"My Shops\", click on your shop, and click \"Edit\". All changes take effect immediately.'**
  String get docsCreateShopFaq3A;

  /// No description provided for @docsCreateShopFaq4Q.
  ///
  /// In en, this message translates to:
  /// **'Do I need team members to start?'**
  String get docsCreateShopFaq4Q;

  /// No description provided for @docsCreateShopFaq4A.
  ///
  /// In en, this message translates to:
  /// **'No. If you\'re a solo business, you can start immediately. You can add team members anytime from your shop settings.'**
  String get docsCreateShopFaq4A;

  /// No description provided for @docsFreelancerFreelancerOverview_title.
  ///
  /// In en, this message translates to:
  /// **'Getting Started as a Freelancer'**
  String get docsFreelancerFreelancerOverview_title;

  /// No description provided for @docsFreelancerFreelancerOverview_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn how to set up your profile and start taking clients'**
  String get docsFreelancerFreelancerOverview_subtitle;

  /// No description provided for @docsFreelancerFreelancerOverview_freelancerWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Freelancing'**
  String get docsFreelancerFreelancerOverview_freelancerWelcomeTitle;

  /// No description provided for @docsFreelancerFreelancerOverview_freelancerWelcomeContent.
  ///
  /// In en, this message translates to:
  /// **'As a freelancer on Aura In, you offer services directly to customers in your area. Unlike a traditional shop, you work from your own location and can travel to meet clients. Set up your profile in just a few minutes and start accepting bookings.'**
  String get docsFreelancerFreelancerOverview_freelancerWelcomeContent;

  /// No description provided for @docsFreelancerFreelancerOverview_freelancerVsShopTitle.
  ///
  /// In en, this message translates to:
  /// **'Freelancer vs Shop: What\'s the Difference?'**
  String get docsFreelancerFreelancerOverview_freelancerVsShopTitle;

  /// No description provided for @docsFreelancerFreelancerOverview_freelancerVsShopContent.
  ///
  /// In en, this message translates to:
  /// **'Here\'s how freelancing works:'**
  String get docsFreelancerFreelancerOverview_freelancerVsShopContent;

  /// No description provided for @docsFreelancerFreelancerOverview_freelancerVsShopBullet1.
  ///
  /// In en, this message translates to:
  /// **'You work independently - no fixed storefront required'**
  String get docsFreelancerFreelancerOverview_freelancerVsShopBullet1;

  /// No description provided for @docsFreelancerFreelancerOverview_freelancerVsShopBullet2.
  ///
  /// In en, this message translates to:
  /// **'You can travel to clients within your chosen radius'**
  String get docsFreelancerFreelancerOverview_freelancerVsShopBullet2;

  /// No description provided for @docsFreelancerFreelancerOverview_freelancerVsShopBullet3.
  ///
  /// In en, this message translates to:
  /// **'You set your own hours and availability'**
  String get docsFreelancerFreelancerOverview_freelancerVsShopBullet3;

  /// No description provided for @docsFreelancerFreelancerOverview_freelancerVsShopBullet4.
  ///
  /// In en, this message translates to:
  /// **'You manage your own schedule and clients'**
  String get docsFreelancerFreelancerOverview_freelancerVsShopBullet4;

  /// No description provided for @docsFreelancerFreelancerOverview_freelancerVsShopBullet5.
  ///
  /// In en, this message translates to:
  /// **'Customers book you directly for services'**
  String get docsFreelancerFreelancerOverview_freelancerVsShopBullet5;

  /// No description provided for @docsFreelancerFreelancerOverview_freelancerRequirementsTitle.
  ///
  /// In en, this message translates to:
  /// **'What You\'ll Need'**
  String get docsFreelancerFreelancerOverview_freelancerRequirementsTitle;

  /// No description provided for @docsFreelancerFreelancerOverview_freelancerRequirementsContent.
  ///
  /// In en, this message translates to:
  /// **'To start as a freelancer, you need: your name, a profession type (hairdresser, massage therapist, etc.), location, travel radius, services, and your working hours. A professional photo helps customers trust you.'**
  String get docsFreelancerFreelancerOverview_freelancerRequirementsContent;

  /// No description provided for @docsFreelancerProfileSetup_title.
  ///
  /// In en, this message translates to:
  /// **'Create Your Profile'**
  String get docsFreelancerProfileSetup_title;

  /// No description provided for @docsFreelancerProfileSetup_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell customers who you are'**
  String get docsFreelancerProfileSetup_subtitle;

  /// No description provided for @docsFreelancerProfileSetup_profilePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Your Profile Photo'**
  String get docsFreelancerProfileSetup_profilePhotoTitle;

  /// No description provided for @docsFreelancerProfileSetup_profilePhotoContent.
  ///
  /// In en, this message translates to:
  /// **'A professional headshot or portrait builds trust with customers. Use a clear, well-lit photo of yourself. Customers want to know who they\'re booking with.'**
  String get docsFreelancerProfileSetup_profilePhotoContent;

  /// No description provided for @docsFreelancerProfileSetup_yourNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get docsFreelancerProfileSetup_yourNameTitle;

  /// No description provided for @docsFreelancerProfileSetup_yourNameContent.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name exactly as you want customers to see it. Be professional and clear.'**
  String get docsFreelancerProfileSetup_yourNameContent;

  /// No description provided for @docsFreelancerProfileSetup_professionTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Profession'**
  String get docsFreelancerProfileSetup_professionTypeTitle;

  /// No description provided for @docsFreelancerProfileSetup_professionTypeContent.
  ///
  /// In en, this message translates to:
  /// **'Select what you do. Examples: Hairdresser, Massage Therapist, Makeup Artist, Barber, Esthetician, or other specialized services.'**
  String get docsFreelancerProfileSetup_professionTypeContent;

  /// No description provided for @docsFreelancerProfileSetup_bioDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Write Your Bio'**
  String get docsFreelancerProfileSetup_bioDescriptionTitle;

  /// No description provided for @docsFreelancerProfileSetup_bioDescriptionContent.
  ///
  /// In en, this message translates to:
  /// **'Write a short description about yourself and your experience (50-150 words). Tell customers what makes you unique. Example: \"I specialize in natural hair care with 5 years of experience. Certified in color and styling.\"'**
  String get docsFreelancerProfileSetup_bioDescriptionContent;

  /// No description provided for @docsFreelancerProfileSetup_termsGuidelinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Your Guidelines'**
  String get docsFreelancerProfileSetup_termsGuidelinesTitle;

  /// No description provided for @docsFreelancerProfileSetup_termsGuidelinesContent.
  ///
  /// In en, this message translates to:
  /// **'Share any important rules or policies. Examples: age restrictions, cancellation policy, health requirements, or preparation instructions.'**
  String get docsFreelancerProfileSetup_termsGuidelinesContent;

  /// No description provided for @docsFreelancerServiceArea_title.
  ///
  /// In en, this message translates to:
  /// **'Set Your Service Area'**
  String get docsFreelancerServiceArea_title;

  /// No description provided for @docsFreelancerServiceArea_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Define where you work'**
  String get docsFreelancerServiceArea_subtitle;

  /// No description provided for @docsFreelancerServiceArea_baseLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Your Base Location'**
  String get docsFreelancerServiceArea_baseLocationTitle;

  /// No description provided for @docsFreelancerServiceArea_baseLocationContent.
  ///
  /// In en, this message translates to:
  /// **'This is where you normally work from. Customers within your travel radius can book you. You can either pin on the map or search for your address.'**
  String get docsFreelancerServiceArea_baseLocationContent;

  /// No description provided for @docsFreelancerServiceArea_travelRadiusTitle.
  ///
  /// In en, this message translates to:
  /// **'Travel Radius'**
  String get docsFreelancerServiceArea_travelRadiusTitle;

  /// No description provided for @docsFreelancerServiceArea_travelRadiusContent.
  ///
  /// In en, this message translates to:
  /// **'How far are you willing to travel to meet clients? Set this in kilometers. Example: \"5 km radius\" means clients up to 5 km from your location can book you.'**
  String get docsFreelancerServiceArea_travelRadiusContent;

  /// No description provided for @docsFreelancerServiceArea_mobileVsFixedTitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile or Fixed Location?'**
  String get docsFreelancerServiceArea_mobileVsFixedTitle;

  /// No description provided for @docsFreelancerServiceArea_mobileVsFixedContent.
  ///
  /// In en, this message translates to:
  /// **'Choose whether you travel to clients or meet them at one location. If you\'re mobile, customers can request you at their home or office.'**
  String get docsFreelancerServiceArea_mobileVsFixedContent;

  /// No description provided for @docsFreelancerServiceArea_serviceAddressTipContent.
  ///
  /// In en, this message translates to:
  /// **'Customers will see your travel radius when searching. Be accurate so they know if you can serve their area.'**
  String get docsFreelancerServiceArea_serviceAddressTipContent;

  /// No description provided for @docsFreelancerFaq1Q.
  ///
  /// In en, this message translates to:
  /// **'What\'s the difference between a freelancer and a shop owner?'**
  String get docsFreelancerFaq1Q;

  /// No description provided for @docsFreelancerFaq1A.
  ///
  /// In en, this message translates to:
  /// **'A freelancer works independently, often traveling to clients. A shop owner has a fixed location. Freelancers are more flexible, shops are more established.'**
  String get docsFreelancerFaq1A;

  /// No description provided for @docsFreelancerFaq2Q.
  ///
  /// In en, this message translates to:
  /// **'How do customers find me?'**
  String get docsFreelancerFaq2Q;

  /// No description provided for @docsFreelancerFaq2A.
  ///
  /// In en, this message translates to:
  /// **'Your profile appears in customer searches based on your location, profession, and services. A good photo and portfolio help you get found more.'**
  String get docsFreelancerFaq2A;

  /// No description provided for @docsFreelancerFaq3Q.
  ///
  /// In en, this message translates to:
  /// **'Can I work for multiple platforms?'**
  String get docsFreelancerFaq3Q;

  /// No description provided for @docsFreelancerFaq3A.
  ///
  /// In en, this message translates to:
  /// **'Yes! You can set up profiles on multiple platforms. Just make sure your availability matches across all platforms.'**
  String get docsFreelancerFaq3A;

  /// No description provided for @docsFreelancerFaq4Q.
  ///
  /// In en, this message translates to:
  /// **'How do payments work?'**
  String get docsFreelancerFaq4Q;

  /// No description provided for @docsFreelancerFaq4A.
  ///
  /// In en, this message translates to:
  /// **'Customers pay through the app. You receive payment to your account after the service is completed.'**
  String get docsFreelancerFaq4A;

  /// No description provided for @docsFreelancerFaq5Q.
  ///
  /// In en, this message translates to:
  /// **'What if I need to cancel a booking?'**
  String get docsFreelancerFaq5Q;

  /// No description provided for @docsFreelancerFaq5A.
  ///
  /// In en, this message translates to:
  /// **'You can cancel before the booking time. Contact support if you need to reschedule. Be fair to customers - frequent cancellations hurt your rating.'**
  String get docsFreelancerFaq5A;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'it', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'it': return AppLocalizationsIt();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
