import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/feedback/config/feedback_config.dart';
import 'package:nano_embryo/core/feedback/review/feedback_review_prompter.dart';
import 'package:nano_embryo/core/feedback/review/in_app_review_client.dart';
import 'package:nano_embryo/core/feedback/review/review_stats_store.dart';
import 'package:nano_embryo/core/providers/shared_prefs_provider.dart';

/// Persistent counters for the prompt heuristic. Keyed off the global
/// `SharedPreferences` so other features can stay unaware.
final reviewStatsStoreProvider = Provider<ReviewStatsStore>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ReviewStatsStore(prefs);
});

/// Platform-channel seam. Override with a fake in widget/integration tests.
final inAppReviewClientProvider = Provider<InAppReviewClient>((ref) {
  return DefaultInAppReviewClient();
});

/// Read-only entry point host code uses: `ref.read(reviewPrompterProvider)`.
final reviewPrompterProvider = Provider<FeedbackReviewPrompter>((ref) {
  return FeedbackReviewPrompter(
    stats: ref.watch(reviewStatsStoreProvider),
    client: ref.watch(inAppReviewClientProvider),
    config: ref.watch(feedbackConfigProvider).review,
  );
});
