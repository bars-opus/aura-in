import 'package:nano_embryo/core/moderation/data/moderation_models.dart';

/// Default English copy for the moderation engine. Subclass and override the
/// getters you want to localize. See `feature/moderation_config.dart` for the
/// NanoEmbryo `AppLocalizations`-backed subclass.
class ModerationTexts {
  const ModerationTexts();

  String get blockActionLabel => 'Block user';
  String get reportActionLabel => 'Report user';
  String get blockedAccountsTitle => 'Blocked Accounts';
  String get blockedAccountsSubtitle => 'Accounts you have blocked';
  String get blockedAccountsEmptyTitle => 'No blocked accounts';
  String get blockedAccountsEmptyBody => 'People you block will appear here.';
  String get blockScreenTitle => 'Block account';
  String blockScreenBody(String displayName) =>
      'You will no longer see or contact $displayName, and they will not be able to interact with you.';
  String get reportScreenTitle => 'Report';
  String reportScreenBody(String displayName) =>
      'Tell us why you are reporting $displayName.';
  String get blockReasonLabel => 'Reason (optional)';
  String get blockReasonHint => 'Why are you blocking this account?';
  String get reportDetailsLabel => 'Details (optional)';
  String get reportDetailsHint =>
      'Add context that will help review this report';
  String get reportReasonLabel => 'Reason';
  String get blockButton => 'Block account';
  String get unblockButton => 'Unblock';
  String get reportButton => 'Submit report';
  String get reasonRequired => 'Select a reason before continuing.';
  String get detailsTooLong => 'Details must be 1000 characters or fewer.';
  String get blockReasonTooLong => 'Reason must be 300 characters or fewer.';
  String get blockSuccess => 'Account blocked.';
  String get unblockSuccess => 'Account unblocked.';
  String get reportSuccess => 'Report submitted.';
  String get actionFailed => 'We could not complete this moderation action.';
  String get loadFailed => 'We could not load moderation data.';
  String get blockedUnavailableTitle => 'This account is unavailable';
  String get blockedUnavailableBody =>
      'This profile or listing is not available because one of you has blocked the other.';
  String get somethingWentWrong => 'Something went wrong';
  String get selfBlockNotAllowed => 'You cannot block your own account.';
  String get selfReportNotAllowed => 'You cannot report your own account.';
  String get targetNotFound =>
      'This profile or listing is no longer available.';
  String get invalidInput => 'Please check the information you entered.';
  String get authRequired => 'Please sign in to continue.';
  String get rateLimitedHour =>
      'You have submitted too many reports recently. Please try again later.';
  String get rateLimitedTarget =>
      'You have already reported this account multiple times today.';
  String get timeout => 'The request took too long. Please try again.';
  String get retryLabel => 'Try again';

  List<ModerationReasonOption> reasonOptions() {
    return const [
      ModerationReasonOption(key: 'spam', label: 'Spam'),
      ModerationReasonOption(key: 'harassment', label: 'Harassment'),
      ModerationReasonOption(key: 'impersonation', label: 'Impersonation'),
      ModerationReasonOption(
        key: 'inappropriate_content',
        label: 'Inappropriate content',
      ),
      ModerationReasonOption(key: 'scam_fraud', label: 'Scam or fraud'),
      ModerationReasonOption(key: 'safety_concern', label: 'Safety concern'),
      ModerationReasonOption(key: 'other', label: 'Other'),
    ];
  }
}
