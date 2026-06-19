import 'package:nano_embryo/core/feedback/review/feedback_review_config.dart';
import 'package:nano_embryo/core/feedback/review/in_app_review_client.dart';
import 'package:nano_embryo/core/feedback/review/review_stats_store.dart';
import 'package:nano_embryo/core/feedback/utils/feedback_logger.dart';

/// Decision returned by [FeedbackReviewPrompter.maybeAsk].
///
/// `shown` means we successfully called the OS API — but the OS itself may
/// have silently no-op'd because of its own per-year rate limit. We treat
/// "the OS accepted our request" as "we asked"; that's all we get to know.
enum ReviewPromptOutcome {
  shown,
  declinedTooFewLaunches,
  declinedTooFreshInstall,
  declinedRecentlyPrompted,
  declinedNoHappyMoment,
  declinedNotAvailable,
  declinedError,
}

/// Decides whether and when to show the native store-review prompt, then
/// asks the OS to show it. Configured by [FeedbackReviewConfig].
///
/// Usage:
///   - Call [recordHappyMoment] from satisfying outcomes (booking confirmed,
///     payment succeeded, etc.). Cheap — just bumps a SharedPreferences int.
///   - Call [maybeAsk] from those same callsites (or shortly after). If the
///     heuristic passes, the OS dialog appears in-place.
///   - Call [openStoreListing] from a manual "Rate this app" button.
class FeedbackReviewPrompter {
  final ReviewStatsStore _stats;
  final InAppReviewClient _client;
  final FeedbackReviewConfig _config;

  /// Injectable clock so tests can simulate "tomorrow" without sleeping.
  final DateTime Function() _now;

  FeedbackReviewPrompter({
    required ReviewStatsStore stats,
    required InAppReviewClient client,
    required FeedbackReviewConfig config,
    DateTime Function()? now,
  }) : _stats = stats,
       _client = client,
       _config = config,
       _now = (now ?? DateTime.now);

  /// Records a "happy moment" — a satisfying user outcome the host app
  /// considers a good time to ask for a rating. Cheap; safe to call from a
  /// post-frame callback. Survives sync errors silently.
  Future<void> recordHappyMoment() async {
    await _stats.recordHappyMoment(now: _now());
    FeedbackLogger.debug(
      'review.happy_moment_recorded',
      attributes: {'launch_count': _stats.launchCount},
    );
  }

  /// Evaluates the heuristic. Returns the [ReviewPromptOutcome] without any
  /// side effect. Useful for analytics dashboards or "should we show a hint?"
  /// before committing.
  ReviewPromptOutcome evaluate() {
    final now = _now();

    if (_stats.launchCount < _config.minLaunchCount) {
      return ReviewPromptOutcome.declinedTooFewLaunches;
    }

    final firstLaunch = _stats.firstLaunchAt;
    if (firstLaunch == null ||
        now.difference(firstLaunch).inDays < _config.minDaysSinceInstall) {
      return ReviewPromptOutcome.declinedTooFreshInstall;
    }

    final lastPrompt = _stats.lastPromptAt;
    if (lastPrompt != null &&
        now.difference(lastPrompt).inDays < _config.minDaysBetweenPrompts) {
      return ReviewPromptOutcome.declinedRecentlyPrompted;
    }

    if (_config.requireHappyMoment) {
      final happy = _stats.lastHappyAt;
      if (happy == null || now.difference(happy) > _config.happyMomentFreshness) {
        return ReviewPromptOutcome.declinedNoHappyMoment;
      }
    }

    return ReviewPromptOutcome.shown;
  }

  /// Heuristic + ask. Returns the outcome.
  ///
  /// Records `last_prompt_at` only if the OS API call succeeded — so a
  /// platform-channel error doesn't burn the 90-day cooldown.
  Future<ReviewPromptOutcome> maybeAsk() async {
    final decision = evaluate();
    if (decision != ReviewPromptOutcome.shown) {
      FeedbackLogger.debug(
        'review.prompt_skipped',
        attributes: {'reason': decision.name},
      );
      return decision;
    }

    try {
      final available = await _client.isAvailable();
      if (!available) {
        FeedbackLogger.debug('review.prompt_unavailable');
        return ReviewPromptOutcome.declinedNotAvailable;
      }
      await _client.requestReview();
      await _stats.recordPromptShown(now: _now());
      FeedbackLogger.debug('review.prompt_shown', attributes: {
        'launch_count': _stats.launchCount,
      });
      return ReviewPromptOutcome.shown;
    } catch (e, st) {
      FeedbackLogger.warn('review.prompt_failed', error: e, stack: st);
      return ReviewPromptOutcome.declinedError;
    }
  }

  /// Opens the platform store listing — used by manual "Rate this app"
  /// buttons. The OS will not show the inline dialog this way; the user is
  /// taken to the store page. Always best-effort.
  Future<void> openStoreListing() async {
    try {
      await _client.openStoreListing(appStoreId: _config.appStoreId);
    } catch (e, st) {
      FeedbackLogger.warn('review.open_store_failed', error: e, stack: st);
    }
  }
}
