import 'package:nano_embryo/core/config/survey/domain/entities/survey_response.dart';

/// Plug-and-play survey repository contract.
///
/// Implementations should throw [SurveyException] subclasses on failure
/// (`SurveyAuthException`, `SurveyDatabaseException`, `SurveyTimeoutException`,
/// `SurveyValidationException`). They should NOT throw raw provider exceptions.
abstract class SurveyRepository {
  /// Insert or update a single feature response. Idempotent via upsert.
  ///
  /// Prefer [submitResponses] for batches — one round-trip beats N.
  Future<void> submitResponse(
    String userId,
    String featureKey,
    Sentiment sentiment,
  );

  /// Insert or update many feature responses in a single round-trip.
  /// Atomic at the row level (PostgreSQL upsert): either every row commits or
  /// none do, eliminating the partial-commit class of bugs.
  ///
  /// Empty input is a no-op.
  Future<void> submitResponses(
    String userId,
    Map<String, Sentiment> responses,
  );

  /// Returns a map of `featureKey -> sentiment` for the user. Empty map if
  /// the user has never submitted.
  Future<Map<String, Sentiment>> getUserResponses(String userId);
}
