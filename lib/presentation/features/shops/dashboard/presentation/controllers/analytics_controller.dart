// lib/features/dashboard/presentation/controllers/analytics_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:nano_embryo/core/utils/logging/app_logger.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/quarterly_revenue.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/top_service.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/workers/worker_performance.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart';

class AnalyticsState extends Equatable {
  final YearlyRevenue quarterlyRevenue;
  final TopServicesData weeklyServices;
  final TopServicesData monthlyServices;
  final TopWorkersData weeklyWorkers;
  final TopWorkersData monthlyWorkers;
  final Map<String, dynamic>? revenueComparisons;
  final bool isLoading;
  final String? error;
  final String shopId;

  const AnalyticsState({
    required this.shopId,
    required this.quarterlyRevenue,
    required this.weeklyServices,
    required this.monthlyServices,
    required this.weeklyWorkers,
    required this.monthlyWorkers,
    this.revenueComparisons,
    this.isLoading = false,
    this.error,
  });

  factory AnalyticsState.initial({required String shopId}) {
    return AnalyticsState(
      shopId: shopId,
      quarterlyRevenue: YearlyRevenue.empty,
      weeklyServices: TopServicesData.empty,
      monthlyServices: TopServicesData.empty,
      weeklyWorkers: TopWorkersData.empty,
      monthlyWorkers: TopWorkersData.empty,
      isLoading: true,
    );
  }

  bool get hasError => error != null;
  // bool get isEmpty => !isLoading && quarterlyRevenue.quarters.isEmpty && weeklyServices.services.isEmpty;

  // In analytics_controller.dart
  bool get isEmpty =>
      !isLoading &&
      quarterlyRevenue.quarters.isEmpty &&
      weeklyServices.services.isEmpty &&
      monthlyServices.services.isEmpty &&
      weeklyWorkers.workers.isEmpty &&
      monthlyWorkers.workers.isEmpty;

  AnalyticsState copyWith({
    YearlyRevenue? quarterlyRevenue,
    TopServicesData? weeklyServices,
    TopServicesData? monthlyServices,
    TopWorkersData? weeklyWorkers,
    TopWorkersData? monthlyWorkers,
    Map<String, dynamic>? revenueComparisons,
    bool? isLoading,
    String? error,
  }) {
    return AnalyticsState(
      shopId: shopId,
      quarterlyRevenue: quarterlyRevenue ?? this.quarterlyRevenue,
      weeklyServices: weeklyServices ?? this.weeklyServices,
      monthlyServices: monthlyServices ?? this.monthlyServices,
      weeklyWorkers: weeklyWorkers ?? this.weeklyWorkers,
      monthlyWorkers: monthlyWorkers ?? this.monthlyWorkers,
      revenueComparisons: revenueComparisons ?? this.revenueComparisons,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    shopId,
    quarterlyRevenue,
    weeklyServices,
    monthlyServices,
    weeklyWorkers,
    monthlyWorkers,
    revenueComparisons,
    isLoading,
    error,
  ];
}

class AnalyticsController extends StateNotifier<AnalyticsState> {
  final DashboardRepository _repository;
  bool _disposed = false;

  AnalyticsController({
    required DashboardRepository repository,
    required String shopId,
  }) : _repository = repository,
       super(AnalyticsState.initial(shopId: shopId)) {
    loadAnalytics();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> loadAnalytics() async {
    if (_disposed) return;
    state = state.copyWith(isLoading: true, error: null);

    // The six queries are independent reads. Previously they ran in
    // strict serial — six round-trips end-to-end. Running them in
    // parallel cuts wall-clock latency to the slowest single query
    // (typically getQuarterlyRevenue) without changing semantics.
    //
    // Failures are isolated: if one query fails, the others still
    // populate the state. The error banner only fires when every
    // query failed — which means the controller actually has nothing
    // to show. This implements checklist 1.3 (graceful degradation).
    final results = await Future.wait<Object?>(
      [
        _safe('quarterly', () => _repository.getQuarterlyRevenue(shopId: state.shopId)),
        _safe('services.weekly', () => _repository.getTopServices(
              shopId: state.shopId,
              period: AnalyticsPeriod.weekly,
              limit: 5,
            )),
        _safe('services.monthly', () => _repository.getTopServices(
              shopId: state.shopId,
              period: AnalyticsPeriod.monthly,
              limit: 5,
            )),
        _safe('workers.weekly', () => _repository.getTopWorkers(
              shopId: state.shopId,
              period: AnalyticsPeriod.weekly,
              limit: 5,
            )),
        _safe('workers.monthly', () => _repository.getTopWorkers(
              shopId: state.shopId,
              period: AnalyticsPeriod.monthly,
              limit: 5,
            )),
        _safe('revenue_comparisons', () => _repository.getRevenueComparisons(shopId: state.shopId)),
      ],
      eagerError: false,
    );

    if (_disposed) return;

    final quarterly = results[0] as YearlyRevenue?;
    final servicesWeekly = results[1] as TopServicesData?;
    final servicesMonthly = results[2] as TopServicesData?;
    final workersWeekly = results[3] as TopWorkersData?;
    final workersMonthly = results[4] as TopWorkersData?;
    final comparisons = results[5] as Map<String, dynamic>?;

    final allFailed = results.every((r) => r == null);

    state = state.copyWith(
      quarterlyRevenue: quarterly ?? state.quarterlyRevenue,
      weeklyServices: servicesWeekly ?? state.weeklyServices,
      monthlyServices: servicesMonthly ?? state.monthlyServices,
      weeklyWorkers: workersWeekly ?? state.weeklyWorkers,
      monthlyWorkers: workersMonthly ?? state.monthlyWorkers,
      revenueComparisons: comparisons ?? state.revenueComparisons,
      isLoading: false,
      // Generic user-safe message; details only in logs.
      error: allFailed ? "Couldn't load analytics. Pull to refresh." : null,
    );
  }

  /// Runs a single analytics fetch and returns null on failure. Logs the
  /// failure with structured context so we can debug without leaking
  /// stack traces into the UI (checklist 5.5).
  Future<T?> _safe<T>(String tag, Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (e) {
      AppLogger.warn(
        'analytics.load_failed',
        fields: {
          'tag': tag,
          'shop_id': state.shopId,
          'error': e.toString(),
        },
      );
      return null;
    }
  }

  Future<void> refresh() async {
    await loadAnalytics();
  }

  void reset() {
    if (_disposed) return;
    state = AnalyticsState.initial(shopId: state.shopId);
    loadAnalytics();
  }
}
