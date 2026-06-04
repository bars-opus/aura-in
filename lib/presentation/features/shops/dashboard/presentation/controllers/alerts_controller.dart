// lib/features/dashboard/presentation/controllers/alerts_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:nano_embryo/core/utils/logging/app_logger.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/performance_alert.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart';

class AlertsState extends Equatable {
  final List<PerformanceAlert> alerts;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final String shopId;

  const AlertsState({
    required this.shopId,
    this.alerts = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
  });

  factory AlertsState.initial({required String shopId}) {
    return AlertsState(shopId: shopId, isLoading: true);
  }

  bool get hasError => error != null;
  bool get isEmpty => !isLoading && alerts.isEmpty;

  List<PerformanceAlert> get unreadAlerts => alerts.where((a) => !a.isRead).toList();

  AlertsState copyWith({
    List<PerformanceAlert>? alerts,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
  }) {
    return AlertsState(
      shopId: shopId,
      alerts: alerts ?? this.alerts,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
    );
  }

  @override
  List<Object?> get props => [shopId, alerts, isLoading, isRefreshing, error];
}

class AlertsController extends StateNotifier<AlertsState> {
  final DashboardRepository _repository;
  bool _disposed = false;

  AlertsController({
    required DashboardRepository repository,
    required String shopId,
  }) : _repository = repository,
       super(AlertsState.initial(shopId: shopId)) {
    loadAlerts();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> loadAlerts() async {
    if (_disposed) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final alerts = await _repository.getAlerts(shopId: state.shopId);
      if (_disposed) return;

      state = state.copyWith(alerts: alerts, isLoading: false, error: null);
    } catch (e) {
      if (_disposed) return;
      AppLogger.warn('alerts.load_failed', fields: {'shop_id': state.shopId, 'error': e.toString()});
      state = state.copyWith(isLoading: false, error: 'load_failed');
    }
  }

  Future<void> refresh() async {
    if (_disposed) return;

    state = state.copyWith(isRefreshing: true, error: null);

    try {
      final alerts = await _repository.getAlerts(shopId: state.shopId);
      if (_disposed) return;

      state = state.copyWith(alerts: alerts, isRefreshing: false, error: null);
    } catch (e) {
      if (_disposed) return;
      AppLogger.warn('alerts.refresh_failed', fields: {'shop_id': state.shopId, 'error': e.toString()});
      state = state.copyWith(isRefreshing: false, error: 'refresh_failed');
    }
  }

  Future<void> markAlertRead(String alertId) async {
    if (_disposed) return;

    try {
      await _repository.markAlertRead(alertId);
      if (_disposed) return;

      final updatedAlerts = state.alerts.map((a) {
        if (a.id == alertId) return PerformanceAlert.fromJson({...a.toJson(), 'is_read': true});
        return a;
      }).toList();
      state = state.copyWith(alerts: updatedAlerts);
    } catch (e) {
      if (_disposed) return;
      AppLogger.warn('alerts.mark_read_failed', fields: {'alert_id': alertId, 'error': e.toString()});
      state = state.copyWith(error: 'mark_read_failed');
    }
  }

  Future<void> resolveAlert(String alertId) async {
    if (_disposed) return;

    try {
      await _repository.resolveAlert(alertId);
      if (_disposed) return;

      final updatedAlerts = state.alerts.where((a) => a.id != alertId).toList();
      state = state.copyWith(alerts: updatedAlerts);
    } catch (e) {
      if (_disposed) return;
      AppLogger.warn('alerts.resolve_failed', fields: {'alert_id': alertId, 'error': e.toString()});
      state = state.copyWith(error: 'resolve_failed');
    }
  }

  Future<void> generateAlerts() async {
    if (_disposed) return;

    try {
      await _repository.generateAlerts(state.shopId);
      if (_disposed) return;
      await loadAlerts();
    } catch (e) {
      if (_disposed) return;
      AppLogger.warn('alerts.generate_failed', fields: {'shop_id': state.shopId, 'error': e.toString()});
      state = state.copyWith(error: 'generate_failed');
    }
  }

  void reset() {
    if (_disposed) return;
    state = AlertsState.initial(shopId: state.shopId);
    loadAlerts();
  }
}
