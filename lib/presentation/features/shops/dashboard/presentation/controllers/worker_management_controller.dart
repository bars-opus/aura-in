// lib/features/dashboard/presentation/controllers/worker_management_controller.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/workers/worker_profile.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart';

class WorkerManagementState extends Equatable {
  final List<WorkerProfile> workers;
  final Map<String, Map<String, dynamic>> workerAttendanceSummaries;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final String? searchQuery;
  final String shopId;

  const WorkerManagementState({
    required this.shopId,
    this.workers = const [],
    this.workerAttendanceSummaries = const {},
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.searchQuery,
  });

  factory WorkerManagementState.initial({required String shopId}) {
    return WorkerManagementState(shopId: shopId, isLoading: true);
  }

  bool get hasError => error != null;
  bool get isEmpty => !isLoading && workers.isEmpty;

  List<WorkerProfile> get filteredWorkers {
    if (searchQuery == null || searchQuery!.isEmpty) return workers;
    final query = searchQuery!.toLowerCase();
    return workers
        .where(
          (w) =>
              w.name.toLowerCase().contains(query) ||
              w.specialties.any((s) => s.toLowerCase().contains(query)),
        )
        .toList();
  }

  WorkerManagementState copyWith({
    List<WorkerProfile>? workers,
    Map<String, Map<String, dynamic>>? workerAttendanceSummaries,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    String? searchQuery,
  }) {
    return WorkerManagementState(
      shopId: shopId,
      workers: workers ?? this.workers,
      workerAttendanceSummaries:
          workerAttendanceSummaries ?? this.workerAttendanceSummaries,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    shopId,
    workers,
    workerAttendanceSummaries,
    isLoading,
    isRefreshing,
    error,
    searchQuery,
  ];
}

class WorkerManagementController extends StateNotifier<WorkerManagementState> {
  final DashboardRepository _repository;
  bool _disposed = false;

  WorkerManagementController({
    required DashboardRepository repository,
    required String shopId,
  }) : _repository = repository,
       super(WorkerManagementState.initial(shopId: shopId)) {
    loadWorkers();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> loadWorkers() async {
    if (_disposed) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final workers = await _repository.getWorkers(shopId: state.shopId);
      if (_disposed) return;

      final summaries = <String, Map<String, dynamic>>{};
      for (final worker in workers) {
        final summary = await _repository.getWorkerAttendanceSummary(
          workerId: worker.id,
        );
        if (_disposed) return;
        summaries[worker.id] = summary;
      }
      if (_disposed) return;

      state = state.copyWith(
        workers: workers,
        workerAttendanceSummaries: summaries,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    if (_disposed) return;

    state = state.copyWith(isRefreshing: true, error: null);

    try {
      final workers = await _repository.getWorkers(shopId: state.shopId);
      if (_disposed) return;

      final summaries = <String, Map<String, dynamic>>{};
      for (final worker in workers) {
        final summary = await _repository.getWorkerAttendanceSummary(
          workerId: worker.id,
        );
        if (_disposed) return;
        summaries[worker.id] = summary;
      }
      if (_disposed) return;

      state = state.copyWith(
        workers: workers,
        workerAttendanceSummaries: summaries,
        isRefreshing: false,
        error: null,
      );
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }

  void setSearchQuery(String query) {
    if (_disposed) return;
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    if (_disposed) return;
    state = state.copyWith(searchQuery: null);
  }

  void reset() {
    if (_disposed) return;
    state = WorkerManagementState.initial(shopId: state.shopId);
    loadWorkers();
  }
}
