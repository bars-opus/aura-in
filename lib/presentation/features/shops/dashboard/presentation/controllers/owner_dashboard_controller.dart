// lib/features/dashboard/presentation/controllers/owner_dashboard_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/dashboard_metrics.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/today_schedule_item.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart';

class OwnerDashboardState extends Equatable {
  final DashboardMetrics metrics;
  final List<TodayScheduleItem> schedule;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final String shopId;

  const OwnerDashboardState({
    required this.shopId,
    required this.metrics,
    required this.schedule,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
  });

  factory OwnerDashboardState.initial({required String shopId}) {
    return OwnerDashboardState(
      shopId: shopId,
      metrics: DashboardMetrics.empty,
      schedule: const [],
      isLoading: true,
    );
  }

  bool get hasError => error != null;
  bool get isEmpty =>
      !isLoading && schedule.isEmpty && metrics == DashboardMetrics.empty;

  OwnerDashboardState copyWith({
    DashboardMetrics? metrics,
    List<TodayScheduleItem>? schedule,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
  }) {
    return OwnerDashboardState(
      shopId: shopId,
      metrics: metrics ?? this.metrics,
      schedule: schedule ?? this.schedule,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    shopId,
    metrics,
    schedule,
    isLoading,
    isRefreshing,
    error,
  ];
}

class OwnerDashboardController extends StateNotifier<OwnerDashboardState> {
  final DashboardRepository _repository;
  bool _disposed = false;
  bool _isLoading = false;

  OwnerDashboardController({
    required DashboardRepository repository,
    required String shopId,
  }) : _repository = repository,
       super(OwnerDashboardState.initial(shopId: shopId)) {
    loadDashboard();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> loadDashboard() async {
    // Prevent multiple simultaneous loads
    if (_isLoading || _disposed) return;
    _isLoading = true;

    print('🔵 loadDashboard STARTED');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _repository.getMetrics(shopId: state.shopId),
        _repository.getTodaySchedule(shopId: state.shopId),
      ]);

      if (_disposed) return;

      state = state.copyWith(
        metrics: results[0] as DashboardMetrics,
        schedule: results[1] as List<TodayScheduleItem>,
        isLoading: false,
        error: null,
      );
      print('✅ State updated, isLoading: ${state.isLoading}');
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(isLoading: false, error: e.toString());
      print('❌ Error: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() async {
    if (_disposed) return;

    // For refresh, we want to reload even if already loaded
    _isLoading = false; // Reset the flag so we can reload
    await loadDashboard();
  }

  void reset() {
    if (_disposed) return;
    state = OwnerDashboardState.initial(shopId: state.shopId);
    // loadDashboard();
  }
}
