// lib/presentation/features/shops/dashboard/presentation/controllers/lost_bookings_controller.dart
//
// Controller for the Analytics > Revenue lost-booking headline card.
// Loads the three RPC outputs in parallel with per-query graceful
// degradation: if one query fails the other two still populate. The
// error banner only fires when every query failed.
//
// Mirrors the pattern in analytics_controller.dart (parallel
// Future.wait + _safe + _disposed guard).
//
// Error handling (checklist 4.4, 4.5, 5.5):
//   * `state.error` is a stable code string ('load_failed' / null), never
//     `e.toString()` — the UI maps it to user-safe copy.
//   * Per-query failures route through AppLogger.warn with a structured
//     tag and the repository's classified error code only. The raw
//     PostgrestException body is never logged.

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/logging/app_logger.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/lost_booking_metrics.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart';

class LostBookingsState extends Equatable {
  final String shopId;
  final int periodDays;

  final LostBookingSummary? summary;
  final List<LostBookingWeek> weeks;
  final List<LostBookingOffender> offenders;

  final bool isLoading;
  final bool isRefreshing;

  /// Stable code string ('load_failed') or null. Never `e.toString()`.
  /// The widget maps it to fixed user copy.
  final String? error;

  const LostBookingsState({
    required this.shopId,
    required this.periodDays,
    this.summary,
    this.weeks = const [],
    this.offenders = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
  });

  factory LostBookingsState.initial({
    required String shopId,
    required int periodDays,
  }) =>
      LostBookingsState(
        shopId: shopId,
        periodDays: periodDays,
        isLoading: true,
      );

  bool get hasError => error != null;

  LostBookingsState copyWith({
    LostBookingSummary? summary,
    List<LostBookingWeek>? weeks,
    List<LostBookingOffender>? offenders,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
  }) {
    return LostBookingsState(
      shopId: shopId,
      periodDays: periodDays,
      summary: summary ?? this.summary,
      weeks: weeks ?? this.weeks,
      offenders: offenders ?? this.offenders,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        shopId,
        periodDays,
        summary,
        weeks,
        offenders,
        isLoading,
        isRefreshing,
        error,
      ];
}

class LostBookingsController extends StateNotifier<LostBookingsState> {
  final DashboardRepository _repository;
  bool _disposed = false;

  LostBookingsController({
    required DashboardRepository repository,
    required String shopId,
    int periodDays = 7,
  })  : _repository = repository,
        super(LostBookingsState.initial(
          shopId: shopId,
          periodDays: periodDays,
        )) {
    load();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// First-time / triggered load. Sets `isLoading: true` synchronously
  /// before any await so the headline card can render its skeleton
  /// state inside the same frame (checklist 5.2).
  Future<void> load() async {
    if (_disposed) return;
    state = state.copyWith(isLoading: true, clearError: true);

    final results = await Future.wait<Object?>(
      [
        _safe('summary', () => _repository.getLostBookingSummary(
              shopId: state.shopId,
              periodDays: state.periodDays,
            )),
        _safe('weekly_series',
            () => _repository.getLostBookingWeeklySeries(shopId: state.shopId)),
        _safe('offenders',
            () => _repository.getLostBookingOffenders(shopId: state.shopId)),
      ],
      eagerError: false,
    );

    if (_disposed) return;

    final summary = results[0] as LostBookingSummary?;
    final weeks = results[1] as List<LostBookingWeek>?;
    final offenders = results[2] as List<LostBookingOffender>?;

    final allFailed = summary == null && weeks == null && offenders == null;

    state = state.copyWith(
      summary: summary ?? state.summary,
      weeks: weeks ?? state.weeks,
      offenders: offenders ?? state.offenders,
      isLoading: false,
      error: allFailed ? 'load_failed' : null,
      clearError: !allFailed,
    );
  }

  /// Pull-to-refresh / mutation-driven reload. Keeps the current data on
  /// screen while refetching so the user doesn't see a skeleton flash.
  Future<void> refresh() async {
    if (_disposed) return;
    state = state.copyWith(isRefreshing: true, clearError: true);

    final results = await Future.wait<Object?>(
      [
        _safe('summary', () => _repository.getLostBookingSummary(
              shopId: state.shopId,
              periodDays: state.periodDays,
            )),
        _safe('weekly_series',
            () => _repository.getLostBookingWeeklySeries(shopId: state.shopId)),
        _safe('offenders',
            () => _repository.getLostBookingOffenders(shopId: state.shopId)),
      ],
      eagerError: false,
    );

    if (_disposed) return;

    final summary = results[0] as LostBookingSummary?;
    final weeks = results[1] as List<LostBookingWeek>?;
    final offenders = results[2] as List<LostBookingOffender>?;

    final allFailed = summary == null && weeks == null && offenders == null;

    state = state.copyWith(
      summary: summary ?? state.summary,
      weeks: weeks ?? state.weeks,
      offenders: offenders ?? state.offenders,
      isRefreshing: false,
      error: allFailed ? 'load_failed' : null,
      clearError: !allFailed,
    );
  }

  /// Runs a single analytics fetch and returns null on failure. Logs the
  /// failure with structured context — tag + shop_id + classified
  /// `error_code` ONLY. We never include the raw exception body in the
  /// fields map (checklist 4.4).
  Future<T?> _safe<T>(String tag, Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (e) {
      final code = e is DashboardRepositoryException ? e.message : 'load_failed';
      AppLogger.warn(
        'analytics.load_failed',
        fields: {
          'tag': 'lost_booking_$tag',
          'shop_id': state.shopId,
          'error_code': code,
        },
      );
      return null;
    }
  }
}
