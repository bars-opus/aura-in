// lib/features/dashboard/presentation/controllers/analytics_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
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

    print('🔵 loadAnalytics STARTED');

    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🔵 Calling getQuarterlyRevenue...');
      final quarterlyRevenue = await _repository.getQuarterlyRevenue(
        shopId: state.shopId,
      );
      print(
        '🔵 quarterlyRevenue quarters: ${quarterlyRevenue.quarters.length}',
      );

      print('🔵 Calling getTopServices (weekly)...');
      final weeklyServices = await _repository.getTopServices(
        shopId: state.shopId,
        period: AnalyticsPeriod.weekly,
        limit: 5,
      );
      print('🔵 weeklyServices services: ${weeklyServices.services.length}');

      print('🔵 Calling getTopServices (monthly)...');
      final monthlyServices = await _repository.getTopServices(
        shopId: state.shopId,
        period: AnalyticsPeriod.monthly,
        limit: 5,
      );
      print('🔵 monthlyServices services: ${monthlyServices.services.length}');

      print('🔵 Calling getTopWorkers (weekly)...');
      final weeklyWorkers = await _repository.getTopWorkers(
        shopId: state.shopId,
        period: AnalyticsPeriod.weekly,
        limit: 5,
      );
      print('🔵 weeklyWorkers workers: ${weeklyWorkers.workers.length}');

      print('🔵 Calling getTopWorkers (monthly)...');
      final monthlyWorkers = await _repository.getTopWorkers(
        shopId: state.shopId,
        period: AnalyticsPeriod.monthly,
        limit: 5,
      );
      print('🔵 monthlyWorkers workers: ${monthlyWorkers.workers.length}');

      print('🔵 Calling getRevenueComparisons...');
      final revenueComparisons = await _repository.getRevenueComparisons(
        shopId: state.shopId,
      );
      print('🔵 revenueComparisons: $revenueComparisons');

      if (_disposed) return;

      state = state.copyWith(
        quarterlyRevenue: quarterlyRevenue,
        weeklyServices: weeklyServices,
        monthlyServices: monthlyServices,
        weeklyWorkers: weeklyWorkers,
        monthlyWorkers: monthlyWorkers,
        revenueComparisons: revenueComparisons,
        isLoading: false,
        error: null,
      );

      print(
        '✅ State updated - quarters: ${state.quarterlyRevenue.quarters.length}, isLoading: ${state.isLoading}',
      );
    } catch (e) {
      print('❌ loadAnalytics ERROR: $e');
      if (_disposed) return;
      state = state.copyWith(isLoading: false, error: e.toString());
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
