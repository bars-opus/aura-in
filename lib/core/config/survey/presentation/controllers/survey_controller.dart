import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/config/survey/domain/entities/survey_response.dart';
import 'package:nano_embryo/core/config/survey/domain/repositories/survey_repository.dart';
import 'package:nano_embryo/core/config/survey/exceptions/survey_exceptions.dart';
import 'package:nano_embryo/core/config/survey/utils/survey_logger.dart';

class SurveyState {
  final Map<String, Sentiment> responses;
  final bool isSubmitting;
  final bool isLoading;
  final String? errorMessage;

  /// True when the user-visible error is safe to dismiss with a "Try again"
  /// (network blips, timeouts). False for permanent errors (auth, validation).
  final bool errorIsRetryable;
  final bool hasCompleted;

  const SurveyState({
    this.responses = const {},
    this.isSubmitting = false,
    this.isLoading = false,
    this.errorMessage,
    this.errorIsRetryable = false,
    this.hasCompleted = false,
  });

  SurveyState copyWith({
    Map<String, Sentiment>? responses,
    bool? isSubmitting,
    bool? isLoading,
    String? errorMessage,
    bool? errorIsRetryable,
    bool clearError = false,
    bool? hasCompleted,
  }) {
    return SurveyState(
      responses: responses ?? this.responses,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorIsRetryable: clearError
          ? false
          : (errorIsRetryable ?? this.errorIsRetryable),
      hasCompleted: hasCompleted ?? this.hasCompleted,
    );
  }
}

class SurveyController extends StateNotifier<SurveyState> {
  final SurveyRepository _repository;
  final String _userId;
  final int _completionThreshold;
  final void Function(String event, Map<String, Object?> attributes)? _onEvent;

  /// Guards against double-submit (button mash, accidental re-tap). Cleared
  /// from `submitAllResponses` itself in a `try/finally`.
  bool _submitInFlight = false;

  SurveyController(
    this._repository,
    this._userId, {
    required int completionThreshold,
    void Function(String event, Map<String, Object?> attributes)? onEvent,
  }) : _completionThreshold = completionThreshold,
       _onEvent = onEvent,
       super(const SurveyState());

  Future<void> loadResponses() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final responses = await _repository.getUserResponses(_userId);
      // Awaited — controller may have been disposed while we were waiting.
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        responses: responses,
        hasCompleted: responses.length >= _completionThreshold,
        clearError: true,
      );
      _emit('survey_loaded', {'response_count': responses.length});
    } on SurveyException catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapMessage(e),
        errorIsRetryable: _isRetryable(e),
      );
      _emit('survey_load_failed', {'category': _category(e)});
    }
  }

  /// Optimistic update — flips the chip immediately. Pure synchronous state
  /// transition, no I/O.
  void setSentiment(String featureKey, Sentiment sentiment) {
    if (!mounted) return;
    final updated = Map<String, Sentiment>.from(state.responses);
    updated[featureKey] = sentiment;
    state = state.copyWith(
      responses: updated,
      hasCompleted: updated.length >= _completionThreshold,
    );
  }

  /// Submits every entry the user has touched in a single atomic upsert.
  /// Returns true on full success.
  ///
  /// Reentrant calls (double-tap) short-circuit to the in-flight result —
  /// the second tap returns false without firing a second request.
  Future<bool> submitAllResponses() async {
    if (!mounted) return false;
    if (_submitInFlight) return false;

    if (state.responses.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please provide feedback for at least one feature',
        errorIsRetryable: false,
      );
      return false;
    }

    _submitInFlight = true;
    state = state.copyWith(isSubmitting: true, clearError: true);
    _emit('survey_submit_started', {
      'response_count': state.responses.length,
    });

    try {
      // Snapshot the responses so a concurrent setSentiment call (race) can't
      // mutate the batch we're about to send.
      final batch = Map<String, Sentiment>.from(state.responses);

      try {
        await _repository.submitResponses(_userId, batch);
        if (!mounted) return false;
        state = state.copyWith(isSubmitting: false);
        _emit('survey_submitted', {
          'response_count': batch.length,
          'likes':    batch.values.where((s) => s == Sentiment.like).length,
          'dislikes': batch.values.where((s) => s == Sentiment.dislike).length,
        });
        return true;
      } on SurveyException catch (e) {
        if (!mounted) return false;
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: _mapMessage(e),
          errorIsRetryable: _isRetryable(e),
        );
        _emit('survey_submit_failed', {'category': _category(e)});
        return false;
      }
    } finally {
      _submitInFlight = false;
    }
  }

  void clearError() {
    if (!mounted) return;
    state = state.copyWith(clearError: true);
  }

  void _emit(String event, Map<String, Object?> attributes) {
    SurveyLogger.debug('survey.$event', attributes: attributes);
    final hook = _onEvent;
    if (hook != null) {
      try {
        hook(event, attributes);
      } catch (e, st) {
        // The event hook is host-app code; never let it crash the engine.
        SurveyLogger.warn('survey.onEvent.threw', error: e, stack: st);
      }
    }
  }

  String _mapMessage(SurveyException e) {
    if (e is SurveyAuthException) return 'Please log in to submit feedback.';
    if (e is SurveyValidationException) {
      return 'Some of your feedback is invalid. Please try again.';
    }
    if (e is SurveyTimeoutException) {
      return 'The network is slow. Tap "Try again" to retry — your selections are still here.';
    }
    if (e is SurveyDatabaseException) {
      return 'Unable to save your feedback right now. It\'s safe to try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  bool _isRetryable(SurveyException e) {
    if (e is SurveyAuthException) return false;
    if (e is SurveyValidationException) return false;
    return true; // network / db / timeout / unknown — safe to retry.
  }

  String _category(SurveyException e) {
    if (e is SurveyAuthException) return 'auth';
    if (e is SurveyValidationException) return 'validation';
    if (e is SurveyTimeoutException) return 'timeout';
    if (e is SurveyDatabaseException) return 'database';
    return 'unknown';
  }
}
