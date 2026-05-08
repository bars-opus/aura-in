// lib/features/dashboard/presentation/controllers/attendance_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/today_attendance.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/workers/worker_attendance.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart';

// ============ STATE ============

/// State for attendance controller
class AttendanceState extends Equatable {
  final List<TodayAttendance> todayAttendance;
  final Map<String, List<WorkerAttendance>> workerHistory;
  final Map<String, Map<String, dynamic>> workerSummaries;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final String shopId;
  final DateTime selectedMonth;

  const AttendanceState({
    required this.shopId,
    this.todayAttendance = const [],
    this.workerHistory = const {},
    this.workerSummaries = const {},
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    required this.selectedMonth,
  });

  factory AttendanceState.initial({required String shopId}) {
    return AttendanceState(
      shopId: shopId,
      selectedMonth: DateTime.now(),
      isLoading: true,
    );
  }

  /// Get today's attendance for a specific worker
  TodayAttendance? getWorkerTodayAttendance(String workerId) {
    try {
      return todayAttendance.firstWhere(
        (attendance) => attendance.workerId == workerId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Get attendance history for a specific worker
  List<WorkerAttendance> getWorkerHistory(String workerId) {
    return workerHistory[workerId] ?? [];
  }

  /// Get attendance summary for a specific worker
  Map<String, dynamic>? getWorkerSummary(String workerId) {
    return workerSummaries[workerId];
  }

  AttendanceState copyWith({
    List<TodayAttendance>? todayAttendance,
    Map<String, List<WorkerAttendance>>? workerHistory,
    Map<String, Map<String, dynamic>>? workerSummaries,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    DateTime? selectedMonth,
  }) {
    return AttendanceState(
      shopId: shopId,
      todayAttendance: todayAttendance ?? this.todayAttendance,
      workerHistory: workerHistory ?? this.workerHistory,
      workerSummaries: workerSummaries ?? this.workerSummaries,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }

  @override
  List<Object?> get props => [
    shopId,
    todayAttendance,
    workerHistory,
    workerSummaries,
    isLoading,
    isRefreshing,
    error,
    selectedMonth,
  ];
}

// ============ CONTROLLER ============

/// Controller for attendance management (view-only)
class AttendanceController extends StateNotifier<AttendanceState> {
  final DashboardRepository _repository;

  // Add this flag to track if controller is still active
  bool _isDisposed = false;

  // Add mounted getter
  bool get mounted => !_isDisposed;

  AttendanceController({
    required DashboardRepository repository,
    required String shopId,
  }) : _repository = repository,
       super(AttendanceState.initial(shopId: shopId)) {
    loadAttendance();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Load all attendance data (today + summaries for all workers)
  Future<void> loadAttendance() async {
    if (!mounted) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load today's attendance
      final todayAttendance = await _repository.getTodayAttendance(
        shopId: state.shopId,
      );

      if (!mounted) return;

      final todayList =
          todayAttendance
              .map((json) => TodayAttendance.fromJson(json))
              .toList();

      state = state.copyWith(
        todayAttendance: todayList,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      if (!mounted) return;

      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh all attendance data
  Future<void> refresh() async {
    if (!mounted) return;

    state = state.copyWith(isRefreshing: true, error: null);

    try {
      // Load today's attendance
      final todayAttendance = await _repository.getTodayAttendance(
        shopId: state.shopId,
      );

      if (!mounted) return;

      final todayList =
          todayAttendance
              .map((json) => TodayAttendance.fromJson(json))
              .toList();

      state = state.copyWith(
        todayAttendance: todayList,
        isRefreshing: false,
        error: null,
      );
    } catch (e) {
      if (!mounted) return;

      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }

  /// Load attendance history for a specific worker
  Future<void> loadWorkerHistory({
    required String workerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!mounted) return;

    try {
      final history = await _repository.getWorkerAttendanceHistory(
        workerId: workerId,
        startDate: startDate,
        endDate: endDate,
        limit: 30,
      );

      if (!mounted) return;

      final updatedHistory = Map<String, List<WorkerAttendance>>.from(
        state.workerHistory,
      );
      updatedHistory[workerId] = history;

      state = state.copyWith(workerHistory: updatedHistory, error: null);
    } catch (e) {
      if (!mounted) return;

      state = state.copyWith(error: e.toString());
    }
  }

  /// Load attendance summary for a specific worker
  Future<void> loadWorkerSummary({
    required String workerId,
    DateTime? month,
  }) async {
    if (!mounted) return;

    try {
      final summary = await _repository.getWorkerAttendanceSummary(
        workerId: workerId,
        month: month ?? state.selectedMonth,
      );

      if (!mounted) return;

      final updatedSummaries = Map<String, Map<String, dynamic>>.from(
        state.workerSummaries,
      );
      updatedSummaries[workerId] = summary;

      state = state.copyWith(workerSummaries: updatedSummaries, error: null);
    } catch (e) {
      if (!mounted) return;

      state = state.copyWith(error: e.toString());
    }
  }

  /// Load data for a specific worker (history + summary)
  Future<void> loadWorkerData({
    required String workerId,
    DateTime? month,
  }) async {
    if (!mounted) return;

    await Future.wait([
      loadWorkerHistory(workerId: workerId),
      loadWorkerSummary(workerId: workerId, month: month),
    ]);
  }

  /// Set selected month (for monthly summaries)
  void setSelectedMonth(DateTime month) {
    if (!mounted) return;

    state = state.copyWith(selectedMonth: month);
    // Reload all worker summaries for new month
    for (final worker in state.todayAttendance) {
      loadWorkerSummary(workerId: worker.workerId, month: month);
    }
  }

  /// Reset state
  void reset() {
    if (!mounted) return;
    state = AttendanceState.initial(shopId: state.shopId);
  }
}
