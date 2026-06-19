import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One entry in the feature-survey list.
///
/// Defined by each host app and passed via [SurveyConfig.features].
class SurveyFeature {
  /// Stable key persisted in `feature_survey_responses.feature_key`.
  /// Do not rename once shipped — it joins user responses across versions.
  final String key;

  final String title;
  final String description;
  final IconData icon;

  const SurveyFeature({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// Single configuration object for the survey engine.
///
/// Override [surveyConfigProvider] in the root [ProviderScope] with an
/// instance customised for your app — see SURVEY_ENGINE.md for the full
/// integration guide.
class SurveyConfig {
  /// App display name (used in default copy and log messages).
  final String appName;

  /// Features the user is asked to rate. The same list drives the screen
  /// layout, completion threshold, and the `feature_key` column.
  final List<SurveyFeature> features;

  /// Headline copy at the top of the survey screen.
  final String headline;

  /// Body copy under the headline.
  final String intro;

  /// Section header above the feature list.
  final String featureSectionTitle;

  /// Banner shown when the user has already completed the survey.
  final String completedBanner;

  /// Footer disclaimer under the submit button.
  final String privacyNote;

  /// Submit button label when no prior responses exist.
  final String submitLabel;

  /// Submit button label when updating an earlier submission.
  final String updateLabel;

  /// Snackbar shown after a successful submit.
  final String thanksMessage;

  /// Minimum number of features the user must rate to count as "complete".
  /// Defaults to roughly 2/3 of the feature list.
  final int completionThreshold;

  /// Optional callback invoked after a successful submit. Useful for
  /// analytics or follow-up navigation.
  final void Function(BuildContext context, Map<String, String> responses)?
  onSubmitted;

  /// Optional structured-event sink for analytics dashboards.
  /// Fires on `survey_loaded`, `survey_submit_started`, `survey_submitted`,
  /// `survey_submit_failed`. Attributes never contain PII — only counts,
  /// error categories, and feature keys.
  final void Function(String event, Map<String, Object?> attributes)? onEvent;

  SurveyConfig({
    required this.appName,
    required this.features,
    this.headline = 'Help us improve',
    this.intro =
        'Which features do you like or dislike? '
        'Your feedback helps us prioritize what to build next.',
    this.featureSectionTitle = 'Rate each feature',
    this.completedBanner =
        'Thank you for completing the survey! '
        'You can update your responses anytime.',
    this.privacyNote =
        'Your responses are anonymous to other users '
        'and only used to improve the app.',
    this.submitLabel = 'Submit Feedback',
    this.updateLabel = 'Update Feedback',
    this.thanksMessage = "Thank you for your feedback! We'll use this to improve the app.",
    int? completionThreshold,
    this.onSubmitted,
    this.onEvent,
  }) : completionThreshold =
           completionThreshold ?? (features.length * 2 ~/ 3);

  factory SurveyConfig.defaults() {
    return SurveyConfig(appName: 'App', features: const []);
  }
}

/// Override this in your root [ProviderScope] with your app's [SurveyConfig].
///
/// ```dart
/// ProviderScope(
///   overrides: [
///     surveyConfigProvider.overrideWithValue(
///       SurveyConfig(appName: 'MyApp', features: [...]),
///     ),
///   ],
///   child: MyApp(),
/// )
/// ```
final surveyConfigProvider = Provider<SurveyConfig>((ref) {
  return SurveyConfig.defaults();
});
