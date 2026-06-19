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
