import 'package:flutter/material.dart' hide Feedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/feedback/domain/entities/feedback.dart';
import 'package:nano_embryo/core/feedback/review/feedback_review_config.dart';

/// One selectable feedback category in the form.
///
/// `key` is persisted in `user_feedback.type` and must be stable across app
/// versions. Display name + icon are app-customisable.
class FeedbackTypeOption {
  /// Stable column value ('bug', 'suggestion', 'shop_issue', etc.).
  final String key;

  /// User-facing label (already-localised by the host app if needed).
  final String label;

  /// Optional leading icon shown in the chip.
  final IconData? icon;

  const FeedbackTypeOption({required this.key, required this.label, this.icon});
}

/// Single configuration object for the feedback engine.
///
/// Override [feedbackConfigProvider] in the root [ProviderScope] with an
/// instance customised for your app — see FEEDBACK_ENGINE.md for the full
/// integration guide.
class FeedbackConfig {
  /// Your app's display name (used in default copy and log messages).
  final String appName;

  /// Feedback categories shown as chips in the form.
  /// The first entry is selected by default.
  final List<FeedbackTypeOption> types;

  /// Title field label.
  final String titleLabel;

  /// Title field placeholder.
  final String titleHint;

  /// Description field label.
  final String descriptionLabel;

  /// Description field placeholder.
  final String descriptionHint;

  /// AppBar title for the submit screen.
  final String submitScreenTitle;

  /// AppBar title for the history screen.
  final String historyScreenTitle;

  /// Submit button label.
  final String submitLabel;

  /// Snackbar shown after a successful submit.
  final String thanksMessage;

  /// Maximum length of the title field (inclusive).
  final int maxTitleLength;

  /// Maximum length of the description field (inclusive).
  final int maxDescriptionLength;

  /// When true, the form shows the attach-screenshot row.
  final bool enableScreenshots;

  /// Supabase Storage bucket where screenshots are uploaded.
  /// Only consulted when [enableScreenshots] is true.
  final String screenshotBucket;

  /// Maximum number of screenshots per submission.
  final int maxScreenshots;

  /// Optional callback invoked after a successful submit. Useful for
  /// analytics or follow-up navigation.
  final void Function(BuildContext context, Feedback feedback)? onSubmitted;

  /// Optional structured-event sink for analytics dashboards.
  /// Fires on `feedback_submit_started`, `feedback_submitted`,
  /// `feedback_submit_failed`, `feedback_history_loaded`,
  /// `feedback_history_load_failed`. Attributes never contain PII — only
  /// counts, error categories, and feedback type keys.
  final void Function(String event, Map<String, Object?> attributes)? onEvent;

  /// Thresholds and store identifiers for the native rating prompt.
  /// See [FeedbackReviewConfig] for the heuristic.
  final FeedbackReviewConfig review;

  const FeedbackConfig({
    required this.appName,
    this.types = const [
      FeedbackTypeOption(
        key: 'bug',
        label: 'Bug Report',
        icon: Icons.bug_report,
      ),
      FeedbackTypeOption(
        key: 'suggestion',
        label: 'Suggestion',
        icon: Icons.lightbulb_outline,
      ),
      FeedbackTypeOption(
        key: 'question',
        label: 'Question',
        icon: Icons.help_outline,
      ),
      FeedbackTypeOption(key: 'other', label: 'Other', icon: Icons.edit_note),
    ],
    this.titleLabel = 'Title',
    this.titleHint = 'Brief summary of your feedback',
    this.descriptionLabel = 'Description',
    this.descriptionHint = 'Please provide details...',
    this.submitScreenTitle = 'Send Feedback',
    this.historyScreenTitle = 'My Feedback',
    this.submitLabel = 'Submit Feedback',
    this.thanksMessage = 'Thank you for your feedback!',
    this.maxTitleLength = 100,
    this.maxDescriptionLength = 5000,
    this.enableScreenshots = false,
    this.screenshotBucket = 'feedback-screenshots',
    this.maxScreenshots = 3,
    this.onSubmitted,
    this.onEvent,
    this.review = const FeedbackReviewConfig(),
  });

  factory FeedbackConfig.defaults() {
    return const FeedbackConfig(appName: 'App');
  }

  /// Lookup a type by key, falling back to the first entry.
  FeedbackTypeOption typeForKey(String key) {
    return types.firstWhere(
      (t) => t.key == key,
      orElse:
          () =>
              types.isNotEmpty
                  ? types.first
                  : const FeedbackTypeOption(key: 'other', label: 'Other'),
    );
  }
}

/// Override this in your root [ProviderScope] with your app's [FeedbackConfig].
///
/// ```dart
/// ProviderScope(
///   overrides: [
///     feedbackConfigProvider.overrideWithValue(
///       FeedbackConfig(appName: 'MyApp', types: [...]),
///     ),
///   ],
///   child: MyApp(),
/// )
/// ```
final feedbackConfigProvider = Provider<FeedbackConfig>((ref) {
  return FeedbackConfig.defaults();
});
