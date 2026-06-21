import 'package:intl/intl.dart';

class AccountLifecycleTexts {
  const AccountLifecycleTexts();

  String get deactivateTitle => 'Deactivate account';
  String get deleteTitle => 'Delete account';
  String get restoreTitle => 'Restore account';

  String get deactivateWarningTitle => 'Your account will be hidden';
  String get deactivateWarningBody =>
      'Your profile and public presence will be hidden. You can restore access by signing in again.';
  String get deleteWarningTitle => 'Deletion is scheduled for 30 days';
  String get deleteWarningBody =>
      'Your public presence will be hidden now. You can restore your account within 30 days.';

  String get passwordConfirmLabel => 'Confirm password';
  String get passwordConfirmHint => 'Enter your password';
  String phraseConfirmLabel(String phrase) => 'Type $phrase to confirm';
  String phraseMismatch(String phrase) => 'Type $phrase to continue';
  String get reasonLabel => 'Reason (optional)';
  String get reasonHint => 'Tell us why you are leaving';
  String get passwordRequired => 'Password is required.';
  String get reasonTooLong => 'Reason must be 1000 characters or fewer.';

  String get deactivateButton => 'Deactivate account';
  String get deleteButton => 'Request deletion';
  String get restoreButton => 'Restore account';
  String get logoutButton => 'Log out';

  String get deactivatedSuccess => 'Your account has been deactivated.';
  String get deletionRequestedSuccess => 'Account deletion has been scheduled.';
  String get restoredSuccess => 'Your account has been restored.';
  String get restoreFailed => 'We could not restore this account.';

  String get actionBlocked =>
      'Resolve active bookings, orders, or withdrawals before continuing.';
  String get blockersTitle => 'Resolve these first';
  String blockerActiveBookings(int count) => '$count active booking(s)';
  String blockerOwnedShopActiveBookings(int count) =>
      '$count active shop booking(s)';
  String blockerActiveOrders(int count) => '$count active order(s)';
  String blockerOwnedShopActiveOrders(int count) =>
      '$count active shop order(s)';
  String blockerActiveWithdrawals(int count) => '$count pending withdrawal(s)';

  String get somethingWentWrong => 'Something went wrong';
  String get loadFailed =>
      'We could not load account requirements. Please try again.';
  String get genericError =>
      'We could not complete this account action. Please try again.';
  String get recentAuthRequired => 'Please sign in again before continuing.';
  String invalidConfirmation(String phrase) => phraseMismatch(phrase);
  String get missingProfile => 'We could not load your profile.';
  String get rateLimited =>
      'Too many attempts. Please wait a few minutes and try again.';

  String get deactivatedTitle => 'Account deactivated';
  String get deactivatedBody =>
      'Your account is hidden. Restore it to continue using the app.';
  String get pendingDeleteTitle => 'Account pending deletion';
  String pendingDeleteBody(DateTime? scheduledFor) {
    final dateText =
        scheduledFor == null
            ? 'the scheduled date'
            : DateFormat.yMMMd().format(scheduledFor.toLocal());
    return 'Your account is scheduled for deletion on $dateText. Restore it before then to keep your account.';
  }

  String get deletedTitle => 'Account deleted';
  String get deletedBody =>
      'This account has been deleted and can no longer be restored.';
}
