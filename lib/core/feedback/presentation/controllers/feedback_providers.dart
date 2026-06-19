import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/feedback/config/feedback_config.dart';
import 'package:nano_embryo/core/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:nano_embryo/core/feedback/data/services/feedback_screenshot_uploader.dart';
import 'package:nano_embryo/core/feedback/domain/repositories/feedback_repository.dart';
import 'package:nano_embryo/core/feedback/presentation/controllers/feedback_controller.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';

/// Repository provider — resolves the [FeedbackRepository] backed by Supabase.
///
/// Kept here (not in feedback_controller.dart) so unit tests can `import`
/// the controller without pulling in the auth-provider dep graph.
final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return FeedbackRepositoryImpl(supabase);
});

/// Uploader provider — used when [FeedbackConfig.enableScreenshots] is true.
final feedbackScreenshotUploaderProvider =
    Provider<FeedbackScreenshotUploader>((ref) {
      final supabase = ref.watch(supabaseClientProvider);
      final bucket = ref.watch(feedbackConfigProvider).screenshotBucket;
      return FeedbackScreenshotUploader(supabase, bucket: bucket);
    });

/// Family keyed by `userId` so multi-account scenarios stay isolated.
final feedbackControllerProvider = StateNotifierProvider.family<
  FeedbackController,
  FeedbackState,
  String
>((ref, userId) {
  final repo = ref.watch(feedbackRepositoryProvider);
  final uploader = ref.watch(feedbackScreenshotUploaderProvider);
  final config = ref.watch(feedbackConfigProvider);
  return FeedbackController(
    repo,
    uploader,
    config,
    userId,
    onEvent: config.onEvent,
  );
});
