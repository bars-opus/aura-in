/// Thresholds that gate the native store-review prompt.
///
/// The defaults are the "conservative" preset: ~5 launches, ~3 days installed,
/// ~90 days between prompts, and at least one host-app-declared happy moment.
/// These bias toward fewer, better-converting prompts.
///
/// The OS itself enforces its own rate limit on top of this (Apple ~3/year,
/// Google opaque) — these knobs only decide when WE *try* to ask.
class FeedbackReviewConfig {
  /// Minimum number of cold launches required before the prompt may fire.
  final int minLaunchCount;

  /// Minimum days since first install required before the prompt may fire.
  final int minDaysSinceInstall;

  /// Minimum days since the last successful `requestReview` call before we
  /// may try again. Survives both "submitted" and "not now" because the OS
  /// doesn't tell us which outcome happened.
  final int minDaysBetweenPrompts;

  /// When true, [maybeAsk] requires at least one host-recorded happy moment
  /// before firing. When false, the launch + days gates are sufficient.
  final bool requireHappyMoment;

  /// How long a recorded happy moment stays "fresh". After this window we
  /// treat it as if it never happened — asking long after the warm feeling
  /// faded converts worse than waiting for the next one.
  final Duration happyMomentFreshness;

  /// Apple App Store ID for the manual "Rate this app" entry point. When
  /// null, the manual entry falls back to launching the iOS store via
  /// `openStoreListing`, which still works but is less precise.
  final String? appStoreId;

  /// Android applicationId for the Play Store deep link used by the manual
  /// entry point. Defaults to the running app's package name when null.
  final String? androidPackageName;

  const FeedbackReviewConfig({
    this.minLaunchCount = 5,
    this.minDaysSinceInstall = 3,
    this.minDaysBetweenPrompts = 90,
    this.requireHappyMoment = true,
    this.happyMomentFreshness = const Duration(days: 7),
    this.appStoreId,
    this.androidPackageName,
  });

  /// "Off switch" — passing this to FeedbackConfig disables the prompter
  /// entirely. Useful for tests, dev builds, or apps that aren't on the
  /// stores yet.
  factory FeedbackReviewConfig.disabled() {
    return const FeedbackReviewConfig(
      minLaunchCount: 1 << 30,
      minDaysSinceInstall: 1 << 30,
      requireHappyMoment: true,
    );
  }
}
