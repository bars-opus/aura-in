import 'dart:async';
import 'dart:io';

import 'package:nano_embryo/core/feedback/exceptions/feedback_exceptions.dart';
import 'package:nano_embryo/core/feedback/utils/feedback_logger.dart';
import 'package:nano_embryo/core/feedback/utils/feedback_retry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Maximum permitted file size for a single screenshot. `ImagePickerService`
/// already compresses to ~85% JPEG at 1024×1024, but a third-party picker or
/// "raw" file could push much larger. Stop them before paying the upload
/// round-trip.
const int kMaxScreenshotBytes = 5 * 1024 * 1024; // 5 MiB

/// Progress callback: fired after each successful upload with
/// (uploaded so far, total). Use it to drive a progress UI.
typedef UploadProgress = void Function(int uploaded, int total);

/// Reports the result of a batched upload so callers can persist the URLs
/// AND know which storage paths to clean up if the DB insert fails next.
class FeedbackUploadResult {
  final List<String> urls;
  final List<String> storagePaths;
  const FeedbackUploadResult({required this.urls, required this.storagePaths});
}

/// Uploads feedback screenshots to a Supabase Storage bucket and returns
/// public URLs ready to persist on the feedback row.
///
/// Behaviour:
///   - Validates each file against [kMaxScreenshotBytes] before upload.
///   - Uploads in parallel — order is preserved in the returned URL list.
///   - Wraps each upload in [runFeedbackCall] (timeout + transient retry).
///   - If any single upload fails after retries, [deleteAll] is invoked on
///     all already-uploaded paths so we don't leave orphans behind.
class FeedbackScreenshotUploader {
  final SupabaseClient _supabase;
  final String _bucket;

  FeedbackScreenshotUploader(this._supabase, {required String bucket})
    : _bucket = bucket;

  /// Uploads [files] under `<userId>/<timestamp>_<index>.<ext>`. Returns
  /// the public URLs (in input order) plus the storage paths (for cleanup
  /// on a downstream failure).
  Future<FeedbackUploadResult> uploadAll({
    required String userId,
    required List<File> files,
    UploadProgress? onProgress,
  }) async {
    if (files.isEmpty) {
      return const FeedbackUploadResult(urls: [], storagePaths: []);
    }

    // Size-check up front. Failing one rejects the whole batch — better than
    // wasting time uploading the small ones first.
    for (final file in files) {
      final size = await file.length();
      if (size > kMaxScreenshotBytes) {
        throw FeedbackValidationException(
          'Screenshot is too large '
          '(${(size / 1024 / 1024).toStringAsFixed(1)} MB, max '
          '${(kMaxScreenshotBytes / 1024 / 1024).toStringAsFixed(0)} MB)',
        );
      }
    }

    final ts = DateTime.now().millisecondsSinceEpoch;
    final paths = List<String>.generate(
      files.length,
      (i) => '$userId/${ts}_$i${_extensionOf(files[i].path)}',
    );

    var completed = 0;
    onProgress?.call(0, files.length);

    Future<String> uploadOne(int index) async {
      try {
        await runFeedbackCall(
          () => _supabase.storage.from(_bucket).upload(
                paths[index],
                files[index],
                fileOptions: const FileOptions(upsert: false),
              ),
          timeout: kFeedbackUploadTimeout,
        );
        completed++;
        onProgress?.call(completed, files.length);
        return _supabase.storage.from(_bucket).getPublicUrl(paths[index]);
      } on StorageException catch (e) {
        throw FeedbackStorageException(e.message);
      } on FeedbackException {
        rethrow;
      } catch (e) {
        throw FeedbackStorageException(e.toString());
      }
    }

    try {
      final urls = await Future.wait(
        List.generate(files.length, uploadOne),
        eagerError: true,
      );
      return FeedbackUploadResult(urls: urls, storagePaths: paths);
    } catch (e) {
      // Best-effort cleanup of anything that did land before the failure.
      final landed = paths.sublist(0, completed);
      if (landed.isNotEmpty) {
        unawaited(deleteAll(landed));
      }
      rethrow;
    }
  }

  /// Deletes the given storage paths. Best-effort — failures are logged
  /// but never thrown. Used as orphan-cleanup when the DB insert that was
  /// supposed to reference these URLs fails.
  Future<void> deleteAll(List<String> storagePaths) async {
    if (storagePaths.isEmpty) return;
    try {
      await _supabase.storage.from(_bucket).remove(storagePaths);
      FeedbackLogger.debug(
        'feedback.screenshots.cleanup',
        attributes: {'count': storagePaths.length},
      );
    } catch (e, st) {
      FeedbackLogger.warn(
        'feedback.screenshots.cleanup_failed',
        error: e,
        stack: st,
        attributes: {'count': storagePaths.length},
      );
    }
  }

  String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot == path.length - 1) return '.jpg';
    final ext = path.substring(dot).toLowerCase();
    const allowed = {'.jpg', '.jpeg', '.png', '.webp', '.gif', '.heic'};
    return allowed.contains(ext) ? ext : '.jpg';
  }
}
