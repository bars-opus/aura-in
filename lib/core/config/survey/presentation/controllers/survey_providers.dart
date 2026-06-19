import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/config/survey/config/survey_config.dart';
import 'package:nano_embryo/core/config/survey/data/repositories/survey_repository_impl.dart';
import 'package:nano_embryo/core/config/survey/domain/repositories/survey_repository.dart';
import 'package:nano_embryo/core/config/survey/presentation/controllers/survey_controller.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';

/// Repository provider — resolves the [SurveyRepository] backed by Supabase.
///
/// Kept here (not in survey_controller.dart) so unit tests can `import`
/// the controller without pulling in the auth-provider dep graph.
final surveyRepositoryProvider = Provider<SurveyRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SurveyRepositoryImpl(supabase);
});

/// Family keyed by `userId` so multi-account scenarios stay isolated.
final surveyControllerProvider = StateNotifierProvider.family<
  SurveyController,
  SurveyState,
  String
>((ref, userId) {
  final repo = ref.watch(surveyRepositoryProvider);
  final config = ref.watch(surveyConfigProvider);
  return SurveyController(
    repo,
    userId,
    completionThreshold: config.completionThreshold,
    onEvent: config.onEvent,
  );
});
