import 'package:nano_embryo/core/feedback/data/models/feedback_model.dart';
import 'package:nano_embryo/core/feedback/domain/entities/feedback.dart';
import 'package:nano_embryo/core/feedback/domain/repositories/feedback_repository.dart';
import 'package:nano_embryo/core/feedback/exceptions/feedback_exceptions.dart';
import 'package:nano_embryo/core/feedback/utils/feedback_logger.dart';
import 'package:nano_embryo/core/feedback/utils/feedback_retry.dart';
import 'package:nano_embryo/core/feedback/utils/feedback_safe_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final SupabaseClient _supabase;

  FeedbackRepositoryImpl(this._supabase);

  static const String _table = 'user_feedback';

  @override
  Future<Feedback> submitFeedback(Feedback feedback) async {
    final model = FeedbackModel(
      userId: feedback.userId,
      type: feedback.type,
      title: feedback.title,
      description: feedback.description,
      screenshotUrls: feedback.screenshotUrls,
      appVersion: feedback.appVersion,
      deviceInfo: feedback.deviceInfo,
      idempotencyKey: feedback.idempotencyKey,
      createdAt: feedback.createdAt,
      updatedAt: feedback.updatedAt,
    );

    try {
      final response = await runFeedbackCall(
        () => _supabase
            .from(_table)
            .insert(model.toInsertJson())
            .select()
            .single(),
      );
      return FeedbackModel.fromJson(response);
    } on PostgrestException catch (e, st) {
      // Idempotency-key dedupe: this is the retry-of-a-prior-success path.
      // Fetch and return the original row instead of failing.
      if (e.code == '23505' && feedback.idempotencyKey != null) {
        FeedbackLogger.debug(
          'feedback.submit.dedup_hit',
          attributes: {'user_id': feedback.userId},
        );
        try {
          final existing = await runFeedbackCall(
            () => _supabase
                .from(_table)
                .select()
                .eq('user_id', feedback.userId)
                .eq('idempotency_key', feedback.idempotencyKey!)
                .single(),
          );
          return FeedbackModel.fromJson(existing);
        } catch (refetchError, refetchStack) {
          FeedbackLogger.warn(
            'feedback.submit.dedup_refetch_failed',
            error: refetchError,
            stack: refetchStack,
          );
          // Fall through to the normal database-error path.
        }
      }
      FeedbackLogger.warn(
        'feedback.submit.failed',
        error: e,
        stack: st,
        attributes: {'code': e.code, 'user_id': feedback.userId},
      );
      throw FeedbackDatabaseException(
        feedbackSafeMessage(e.message),
        code: e.code,
      );
    } on AuthException catch (e) {
      throw FeedbackAuthException(feedbackSafeMessage(e.message));
    } on FeedbackException {
      rethrow;
    } catch (e, st) {
      FeedbackLogger.error('feedback.submit.unknown', error: e, stack: st);
      throw FeedbackException('Unexpected error while submitting feedback.');
    }
  }

  @override
  Future<List<Feedback>> getUserFeedback({
    int limit = 50,
    int offset = 0,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw FeedbackAuthException('User not logged in');
    }

    try {
      final response = await runFeedbackCall(
        () => _supabase
            .from(_table)
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1),
      );

      return (response as List)
          .map((json) =>
              FeedbackModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e, st) {
      FeedbackLogger.warn(
        'feedback.history.failed',
        error: e,
        stack: st,
        attributes: {'code': e.code, 'user_id': userId},
      );
      throw FeedbackDatabaseException(
        feedbackSafeMessage(e.message),
        code: e.code,
      );
    } on AuthException catch (e) {
      throw FeedbackAuthException(feedbackSafeMessage(e.message));
    } on FeedbackException {
      rethrow;
    } catch (e, st) {
      FeedbackLogger.error('feedback.history.unknown', error: e, stack: st);
      throw FeedbackException('Unexpected error while loading feedback.');
    }
  }
}
