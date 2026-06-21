import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/feedback/review/review_stats_store.dart';

/// Drop this widget high in the tree (just inside `MaterialApp`'s builder, or
/// wrapping it) so the engine can count cold launches and foreground-resumes.
///
/// Counting rules:
///   - First mount = one launch.
///   - Backgrounded for ≥ [minBackgroundedDuration] then resumed = one launch.
///   - Rapid in/out transitions (e.g. iOS share sheet, system permission
///     dialog) do NOT count — that's not a meaningful new session.
class AppLifecycleLaunchCounter extends ConsumerStatefulWidget {
  final Widget child;

  /// Minimum time the app must have been backgrounded before resume counts
  /// as a new launch. Defaults to 30 seconds.
  final Duration minBackgroundedDuration;

  /// Provider that yields the store. Wired from the host app so the engine
  /// doesn't need to know about your SharedPreferences provider.
  final ProviderListenable<ReviewStatsStore> storeProvider;

  /// Injectable clock for tests. When null, [DateTime.now] is used.
  final DateTime Function()? clock;

  const AppLifecycleLaunchCounter({
    super.key,
    required this.child,
    required this.storeProvider,
    this.minBackgroundedDuration = const Duration(seconds: 30),
    this.clock,
  });

  DateTime _now() => (clock ?? DateTime.now)();

  @override
  ConsumerState<AppLifecycleLaunchCounter> createState() =>
      _AppLifecycleLaunchCounterState();
}

class _AppLifecycleLaunchCounterState
    extends ConsumerState<AppLifecycleLaunchCounter>
    with WidgetsBindingObserver {
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Cold launch — record asynchronously so we don't block first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(widget.storeProvider).recordLaunch();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _pausedAt = widget._now();
      case AppLifecycleState.resumed:
        final pausedAt = _pausedAt;
        _pausedAt = null;
        if (pausedAt == null) return;
        if (widget._now().difference(pausedAt) < widget.minBackgroundedDuration) {
          return; // too quick — not a real new session
        }
        if (!mounted) return;
        ref.read(widget.storeProvider).recordLaunch();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // ignore — transitional states
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
