import 'package:nano_embryo/core/feedback/domain/entities/feedback.dart';

/// Plug-and-play feedback repository contract.
///
/// Implementations should throw [FeedbackException] subclasses on failure.
abstract class FeedbackRepository {
  /// Insert a new feedback row. Returns the row with server-populated `id`,
  /// `status`, and timestamps.
  Future<Feedback> submitFeedback(Feedback feedback);

  /// Returns the current user's submissions, newest first.
  Future<List<Feedback>> getUserFeedback({int limit = 50, int offset = 0});
}
