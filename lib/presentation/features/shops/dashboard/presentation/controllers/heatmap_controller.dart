// lib/features/dashboard/presentation/controllers/heatmap_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/booking_heatmap_data.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart';

class HeatmapState extends Equatable {
  final BookingHeatmapData? heatmapData;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final DateTime startDate;
  final DateTime endDate;

  const HeatmapState({
    this.heatmapData,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    required this.startDate,
    required this.endDate,
  });

  factory HeatmapState.initial() {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    return HeatmapState(
      startDate: startDate,
      endDate: endDate,
      isLoading: true,
    );
  }

  bool get hasError => error != null;
  bool get isEmpty => !isLoading && (heatmapData == null || heatmapData!.dataPoints.isEmpty);

  HeatmapState copyWith({
    BookingHeatmapData? heatmapData,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return HeatmapState(
      heatmapData: heatmapData ?? this.heatmapData,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [heatmapData, isLoading, isRefreshing, error, startDate, endDate];
}

class HeatmapController extends StateNotifier<HeatmapState> {
  final DashboardRepository _repository;
  final String _shopId;
  bool _disposed = false;

  HeatmapController({
    required DashboardRepository repository,
    required String shopId,
  }) : _repository = repository,
       _shopId = shopId,
       super(HeatmapState.initial()) {
    loadHeatmap();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> loadHeatmap() async {
    if (_disposed) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _repository.getBookingHeatmap(
        shopId: _shopId,
        startDate: state.startDate,
        endDate: state.endDate,
      );
      if (_disposed) return;

      state = state.copyWith(heatmapData: data, isLoading: false, error: null);
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    if (_disposed) return;

    state = state.copyWith(isRefreshing: true, error: null);

    try {
      final data = await _repository.getBookingHeatmap(
        shopId: _shopId,
        startDate: state.startDate,
        endDate: state.endDate,
      );
      if (_disposed) return;

      state = state.copyWith(heatmapData: data, isRefreshing: false, error: null);
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }

  Future<void> setDateRange(DateTime start, DateTime end) async {
    if (_disposed) return;

    state = state.copyWith(startDate: start, endDate: end, isLoading: true);

    try {
      final data = await _repository.getBookingHeatmap(
        shopId: _shopId,
        startDate: start,
        endDate: end,
      );
      if (_disposed) return;

      state = state.copyWith(heatmapData: data, isLoading: false, error: null);
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    if (_disposed) return;
    state = HeatmapState.initial();
    loadHeatmap();
  }
}
