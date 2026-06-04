// lib/features/dashboard/presentation/controllers/client_management_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:nano_embryo/core/utils/logging/app_logger.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/clients/client_profile.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart';

class ClientManagementState extends Equatable {
  final List<ClientProfile> clients;
  final Map<String, dynamic>? stats;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final String? searchQuery;
  final String shopId;

  const ClientManagementState({
    required this.shopId,
    this.clients = const [],
    this.stats,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.searchQuery,
  });

  factory ClientManagementState.initial({required String shopId}) {
    return ClientManagementState(shopId: shopId, isLoading: true);
  }

  bool get hasError => error != null;
  bool get isEmpty => !isLoading && clients.isEmpty;

  List<ClientProfile> get filteredClients {
    if (searchQuery == null || searchQuery!.isEmpty) return clients;
    final query = searchQuery!.toLowerCase();
    return clients
        .where((c) => c.displayName.toLowerCase().contains(query))
        .toList();
  }

  ClientManagementState copyWith({
    List<ClientProfile>? clients,
    Map<String, dynamic>? stats,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    String? searchQuery,
  }) {
    return ClientManagementState(
      shopId: shopId,
      clients: clients ?? this.clients,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    shopId,
    clients,
    stats,
    isLoading,
    isRefreshing,
    error,
    searchQuery,
  ];
}

class ClientManagementController extends StateNotifier<ClientManagementState> {
  final DashboardRepository _repository;
  bool _disposed = false;

  ClientManagementController({
    required DashboardRepository repository,
    required String shopId,
  }) : _repository = repository,
       super(ClientManagementState.initial(shopId: shopId)) {
    loadClients();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> loadClients() async {
    if (_disposed) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final clients = await _repository.getClients(
        shopId: state.shopId,
        limit: 50,
      );
      if (_disposed) return;

      final stats = await _repository.getClientStats(shopId: state.shopId);
      if (_disposed) return;

      state = state.copyWith(
        clients: clients,
        stats: stats,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      if (_disposed) return;
      AppLogger.warn('clients.load_failed', fields: {'shop_id': state.shopId, 'error': e.toString()});
      state = state.copyWith(isLoading: false, error: 'load_failed');
    }
  }

  Future<void> refresh() async {
    if (_disposed) return;

    state = state.copyWith(isRefreshing: true, error: null);

    try {
      final clients = await _repository.getClients(
        shopId: state.shopId,
        limit: 50,
      );
      if (_disposed) return;

      final stats = await _repository.getClientStats(shopId: state.shopId);
      if (_disposed) return;

      state = state.copyWith(
        clients: clients,
        stats: stats,
        isRefreshing: false,
        error: null,
      );
    } catch (e) {
      if (_disposed) return;
      AppLogger.warn('clients.refresh_failed', fields: {'shop_id': state.shopId, 'error': e.toString()});
      state = state.copyWith(isRefreshing: false, error: 'refresh_failed');
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
    state = ClientManagementState.initial(shopId: state.shopId);
    loadClients();
  }
}
