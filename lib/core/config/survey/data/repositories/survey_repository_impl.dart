import 'package:nano_embryo/core/config/survey/data/models/survey_response_model.dart';
import 'package:nano_embryo/core/config/survey/domain/entities/survey_response.dart';
import 'package:nano_embryo/core/config/survey/domain/repositories/survey_repository.dart';
import 'package:nano_embryo/core/config/survey/exceptions/survey_exceptions.dart';
import 'package:nano_embryo/core/config/survey/utils/feature_key_validator.dart';
import 'package:nano_embryo/core/config/survey/utils/survey_logger.dart';
import 'package:nano_embryo/core/config/survey/utils/survey_retry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SurveyRepositoryImpl implements SurveyRepository {
  final SupabaseClient _supabase;

  SurveyRepositoryImpl(this._supabase);

  static const String _table = 'feature_survey_responses';
  static const String _conflictKey = 'user_id,feature_key';

  /// Cap on rows per submit. Defensive: the screen UI is bounded by
  /// `SurveyConfig.features.length`, but a misconfigured config or a future
  /// caller could pass an unbounded map.
  static const int _maxBatchSize = 64;

  @override
  Future<void> submitResponse(
    String userId,
    String featureKey,
    Sentiment sentiment,
  ) =>
      submitResponses(userId, {featureKey: sentiment});

  @override
  Future<void> submitResponses(
    String userId,
    Map<String, Sentiment> responses,
  ) async {
    if (responses.isEmpty) return;

    if (responses.length > _maxBatchSize) {
      throw SurveyValidationException(
        'Too many responses in one submit (${responses.length} > $_maxBatchSize)',
      );
    }

    // Fail fast on bad keys before incurring a network round-trip.
    for (final key in responses.keys) {
      FeatureKeyValidator.validate(key);
    }

    final now = DateTime.now().toUtc();
    final rows = responses.entries
        .map(
          (e) => SurveyResponseModel(
            userId: userId,
            featureKey: e.key,
            sentiment: e.value,
            createdAt: now,
            updatedAt: now,
          ).toJson(),
        )
        .toList();

    try {
      await runSurveyCall(
        () => _supabase
            .from(_table)
            .upsert(rows, onConflict: _conflictKey),
      );
    } on PostgrestException catch (e, st) {
      SurveyLogger.warn(
        'survey.upsert.failed',
        error: e,
        stack: st,
        attributes: {
          'count': rows.length,
          'code': e.code,
          'user_id': userId,
        },
      );
      throw SurveyDatabaseException(_safeMessage(e.message), code: e.code);
    } on AuthException catch (e) {
      throw SurveyAuthException(_safeMessage(e.message));
    } on SurveyException {
      rethrow;
    } catch (e, st) {
      SurveyLogger.error('survey.upsert.unknown', error: e, stack: st);
      throw SurveyException('Unexpected error while saving feedback.');
    }
  }

  @override
  Future<Map<String, Sentiment>> getUserResponses(String userId) async {
    try {
      final response = await runSurveyCall(
        () => _supabase.from(_table).select().eq('user_id', userId),
      );

      final result = <String, Sentiment>{};
      for (final json in response as List) {
        final model = SurveyResponseModel.fromJson(
          json as Map<String, dynamic>,
        );
        result[model.featureKey] = model.sentiment;
      }
      return result;
    } on PostgrestException catch (e, st) {
      SurveyLogger.warn(
        'survey.select.failed',
        error: e,
        stack: st,
        attributes: {'code': e.code, 'user_id': userId},
      );
      throw SurveyDatabaseException(_safeMessage(e.message), code: e.code);
    } on AuthException catch (e) {
      throw SurveyAuthException(_safeMessage(e.message));
    } on SurveyException {
      rethrow;
    } catch (e, st) {
      SurveyLogger.error('survey.select.unknown', error: e, stack: st);
      throw SurveyException('Unexpected error while loading feedback.');
    }
  }

  /// Strips URLs and schema/table/policy identifiers from provider messages
  /// before they leave the repo. Pairs with checklist 2.4 (don't leak
  /// internals) and 4.4 (PII out of logs / breadcrumbs).
  static String _safeMessage(String raw) {
    return raw
        // URLs
        .replaceAll(RegExp(r'https?://\S+'), '[url]')
        // Quoted schema/table identifiers
        .replaceAll(RegExp(r'"public"\.\w+'), '[table]')
        .replaceAll(RegExp(r'relation "\w+"'), 'relation [table]');
  }
}
