import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/feedback/config/feedback_config.dart';
import 'package:nano_embryo/core/feedback/data/services/feedback_screenshot_uploader.dart';
import 'package:nano_embryo/core/feedback/domain/entities/feedback.dart';
import 'package:nano_embryo/core/feedback/domain/repositories/feedback_repository.dart';
import 'package:nano_embryo/core/feedback/exceptions/feedback_exceptions.dart';
import 'package:nano_embryo/core/feedback/utils/feedback_logger.dart';
import 'package:nano_embryo/core/feedback/utils/feedback_pii_scrubber.dart';
import 'package:nano_embryo/core/feedback/utils/feedback_type_validator.dart';
import 'package:uuid/uuid.dart';

class FeedbackState {
  final bool isSubmitting;
  final String? errorMessage;

  /// True when the user-visible error is safe to dismiss with a "Try again"
  /// (network blips, timeouts). False for permanent errors (auth, validation).
  final bool errorIsRetryable;

  final List<Feedback> userFeedback;
  final bool isLoadingHistory;

  /// (uploaded, total) when an upload is in flight; null otherwise. Drives
  /// the progress UI on the submit button.
  final ({int uploaded, int total})? uploadProgress;

  const FeedbackState({
    this.isSubmitting = false,
    this.errorMessage,
    this.errorIsRetryable = false,
    this.userFeedback = const [],
    this.isLoadingHistory = false,
    this.uploadProgress,
  });

  FeedbackState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool? errorIsRetryable,
    bool clearError = false,
    List<Feedback>? userFeedback,
    bool? isLoadingHistory,
    ({int uploaded, int total})? uploadProgress,
    bool clearUploadProgress = false,
  }) {
    return FeedbackState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorIsRetryable: clearError
          ? false
          : (errorIsRetryable ?? this.errorIsRetryable),
      userFeedback: userFeedback ?? this.userFeedback,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      uploadProgress: clearUploadProgress
          ? null
          : (uploadProgress ?? this.uploadProgress),
    );
  }
}

class FeedbackController extends StateNotifier<FeedbackState> {
  final FeedbackRepository _repository;
  final FeedbackScreenshotUploader _uploader;
  final FeedbackConfig _config;
  final String _userId;
  final void Function(String event, Map<String, Object?> attributes)? _onEvent;
  final Uuid _uuid;

  /// Maximum number of submissions kept in the in-memory list — bounds
  /// memory growth on long-running sessions that keep adding feedback.
  static const int _maxHistoryInState = 200;

  /// Guards against double-submit (button mash, accidental re-tap).
  bool _submitInFlight = false;

  FeedbackController(
    this._repository,
    this._uploader,
    this._config,
    this._userId, {
    void Function(String event, Map<String, Object?> attributes)? onEvent,
    Uuid? uuid,
  }) : _onEvent = onEvent,
       _uuid = uuid ?? const Uuid(),
       super(const FeedbackState());

  /// Validates input, uploads any screenshots, then writes the row.
  /// Reentrant calls (double-tap) short-circuit immediately.
  /// Returns the persisted [Feedback] on success, null on failure.
  Future<Feedback?> submitFeedback({
    required String type,
    required String title,
    required String description,
    List<File> screenshots = const [],
    Map<String, dynamic>? deviceInfo,
    required String appVersion,
  }) async {
    if (!mounted) return null;
    if (_submitInFlight) return null;

    final trimmedTitle = title.trim();
    final trimmedDesc = description.trim();

    if (trimmedTitle.isEmpty || trimmedTitle.length > _config.maxTitleLength) {
      state = state.copyWith(
        errorMessage:
            'Title must be between 1 and ${_config.maxTitleLength} characters',
        errorIsRetryable: false,
      );
      return null;
    }
    if (trimmedDesc.isEmpty ||
        trimmedDesc.length > _config.maxDescriptionLength) {
      state = state.copyWith(
        errorMessage:
            'Description must be between 1 and ${_config.maxDescriptionLength} characters',
        errorIsRetryable: false,
      );
      return null;
    }
    if (screenshots.length > _config.maxScreenshots) {
      state = state.copyWith(
        errorMessage:
            'Please attach at most ${_config.maxScreenshots} screenshots',
        errorIsRetryable: false,
      );
      return null;
    }
    // Validate type against the configured allow-list + DB charset.
    try {
      FeedbackTypeValidator.validate(
        type,
        _config.types.map((t) => t.key),
      );
    } on FeedbackValidationException catch (e) {
      state = state.copyWith(
        errorMessage: e.message,
        errorIsRetryable: false,
      );
      _emit('feedback_submit_failed', {'category': 'validation'});
      return null;
    }

    _submitInFlight = true;
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearUploadProgress: true,
    );
    _emit('feedback_submit_started', {
      'type': type,
      'has_screenshots': screenshots.isNotEmpty,
      'screenshot_count': screenshots.length,
    });

    // Generate the idempotency key ONCE per logical submission. If the user
    // taps Submit, the screenshot upload succeeds, the DB insert times out,
    // and the user re-taps, the same key dedupes server-side.
    final idempotencyKey = _uuid.v4();
    FeedbackUploadResult? uploadResult;

    try {
      if (_config.enableScreenshots && screenshots.isNotEmpty) {
        uploadResult = await _uploader.uploadAll(
          userId: _userId,
          files: screenshots,
          onProgress: (uploaded, total) {
            if (!mounted) return;
            state = state.copyWith(
              uploadProgress: (uploaded: uploaded, total: total),
            );
          },
        );
      }
      if (!mounted) return null;

      final now = DateTime.now().toUtc();
      final draft = Feedback(
        userId: _userId,
        type: type,
        title: trimmedTitle,
        description: trimmedDesc,
        screenshotUrls: uploadResult?.urls ?? const [],
        appVersion: appVersion,
        deviceInfo: scrubDeviceInfoForPersistence(deviceInfo),
        idempotencyKey: idempotencyKey,
        createdAt: now,
        updatedAt: now,
      );

      final saved = await _repository.submitFeedback(draft);
      if (!mounted) return null;

      final updatedHistory = [saved, ...state.userFeedback];
      state = state.copyWith(
        isSubmitting: false,
        userFeedback: updatedHistory.take(_maxHistoryInState).toList(),
        clearUploadProgress: true,
      );
      _emit('feedback_submitted', {
        'type': saved.type,
        'screenshot_count': saved.screenshotUrls.length,
      });
      return saved;
    } on FeedbackException catch (e) {
      // Repo failed AFTER screenshots uploaded → clean up orphans.
      if (uploadResult != null && uploadResult.storagePaths.isNotEmpty) {
        // Fire-and-forget; the uploader logs its own failures.
        unawaited(_uploader.deleteAll(uploadResult.storagePaths));
      }
      if (!mounted) return null;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _mapMessage(e),
        errorIsRetryable: _isRetryable(e),
        clearUploadProgress: true,
      );
      _emit('feedback_submit_failed', {'category': _category(e)});
      return null;
    } finally {
      _submitInFlight = false;
    }
  }

  Future<void> loadFeedbackHistory() async {
    if (!mounted) return;
    state = state.copyWith(isLoadingHistory: true, clearError: true);
    try {
      final list = await _repository.getUserFeedback();
      if (!mounted) return;
      state = state.copyWith(
        isLoadingHistory: false,
        userFeedback: list,
        clearError: true,
      );
      _emit('feedback_history_loaded', {'count': list.length});
    } on FeedbackException catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoadingHistory: false,
        errorMessage: _mapMessage(e),
        errorIsRetryable: _isRetryable(e),
      );
      _emit('feedback_history_load_failed', {'category': _category(e)});
    }
  }

  void clearError() {
    if (!mounted) return;
    state = state.copyWith(clearError: true);
  }

  void _emit(String event, Map<String, Object?> attributes) {
    FeedbackLogger.debug('feedback.$event', attributes: attributes);
    final hook = _onEvent;
    if (hook != null) {
      try {
        hook(event, attributes);
      } catch (e, st) {
        // Event hook is host-app code; never let it crash the engine.
        FeedbackLogger.warn('feedback.onEvent.threw', error: e, stack: st);
      }
    }
  }

  String _mapMessage(FeedbackException e) {
    if (e is FeedbackAuthException) return 'Please log in to submit feedback.';
    if (e is FeedbackValidationException) return e.message;
    if (e is FeedbackStorageException) {
      return "Couldn't upload your screenshot. Try again or remove it — your text is still here.";
    }
    if (e is FeedbackTimeoutException) {
      return "The network is slow. Tap \"Try again\" — your feedback hasn't been lost.";
    }
    if (e is FeedbackDatabaseException) {
      return "Unable to submit feedback right now. It's safe to try again.";
    }
    return 'Something went wrong. Please try again.';
  }

  bool _isRetryable(FeedbackException e) {
    if (e is FeedbackAuthException) return false;
    if (e is FeedbackValidationException) return false;
    return true;
  }

  String _category(FeedbackException e) {
    if (e is FeedbackAuthException) return 'auth';
    if (e is FeedbackValidationException) return 'validation';
    if (e is FeedbackStorageException) return 'storage';
    if (e is FeedbackTimeoutException) return 'timeout';
    if (e is FeedbackDatabaseException) return 'database';
    return 'unknown';
  }
}

