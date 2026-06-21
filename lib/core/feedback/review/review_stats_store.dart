import 'package:shared_preferences/shared_preferences.dart';

/// Read/write the persisted counters that drive the rating-prompt heuristic.
///
/// All keys are namespaced under `feedback.review.` so they're easy to find
/// (and easy to wipe in a test or migration). All methods are best-effort:
/// SharedPreferences failures are swallowed because losing a launch count
/// must never crash the app.
class ReviewStatsStore {
  final SharedPreferences _prefs;
  ReviewStatsStore(this._prefs);

  static const String _kLaunchCount = 'feedback.review.launch_count';
  static const String _kFirstLaunchAt = 'feedback.review.first_launch_at';
  static const String _kLastPromptAt = 'feedback.review.last_prompt_at';
  static const String _kLastHappyAt = 'feedback.review.last_happy_at';

  int get launchCount => _prefs.getInt(_kLaunchCount) ?? 0;

  DateTime? get firstLaunchAt => _readDate(_kFirstLaunchAt);
  DateTime? get lastPromptAt => _readDate(_kLastPromptAt);
  DateTime? get lastHappyAt => _readDate(_kLastHappyAt);

  /// Increments [launchCount] and seeds [firstLaunchAt] if missing.
  /// Returns the new launch count.
  Future<int> recordLaunch({DateTime? now}) async {
    final current = launchCount + 1;
    try {
      await _prefs.setInt(_kLaunchCount, current);
      if (!_prefs.containsKey(_kFirstLaunchAt)) {
        await _writeDate(_kFirstLaunchAt, now ?? DateTime.now());
      }
    } catch (_) {
      // Swallow — losing a count is preferable to crashing on boot.
    }
    return current;
  }

  Future<void> recordPromptShown({DateTime? now}) async {
    try {
      await _writeDate(_kLastPromptAt, now ?? DateTime.now());
    } catch (_) {/* swallow */}
  }

  Future<void> recordHappyMoment({DateTime? now}) async {
    try {
      await _writeDate(_kLastHappyAt, now ?? DateTime.now());
    } catch (_) {/* swallow */}
  }

  /// Test-only / dev-only reset.
  Future<void> reset() async {
    try {
      await _prefs.remove(_kLaunchCount);
      await _prefs.remove(_kFirstLaunchAt);
      await _prefs.remove(_kLastPromptAt);
      await _prefs.remove(_kLastHappyAt);
    } catch (_) {/* swallow */}
  }

  DateTime? _readDate(String key) {
    final ms = _prefs.getInt(key);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  Future<void> _writeDate(String key, DateTime when) {
    return _prefs.setInt(key, when.toUtc().millisecondsSinceEpoch);
  }
}
