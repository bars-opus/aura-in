// lib/features/dashboard/presentation/controllers/promotions_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/promotion_model.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/promotions_repository.dart';

class PromotionsState extends Equatable {
  final List<Promotion> promotions;
  final Map<String, dynamic>? stats;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final String shopId;

  const PromotionsState({
    required this.shopId,
    this.promotions = const [],
    this.stats,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
  });

  factory PromotionsState.initial({required String shopId}) {
    return PromotionsState(
      shopId: shopId,
      isLoading: true,
    );
  }

  bool get hasError => error != null;
  bool get isEmpty => !isLoading && promotions.isEmpty;

  PromotionsState copyWith({
    List<Promotion>? promotions,
    Map<String, dynamic>? stats,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
  }) {
    return PromotionsState(
      shopId: shopId,
      promotions: promotions ?? this.promotions,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    shopId, promotions, stats, isLoading, isRefreshing, error
  ];
}

class PromotionsController extends StateNotifier<PromotionsState> {
  final PromotionsRepository _repository;
  bool _disposed = false;

  PromotionsController({
    required PromotionsRepository repository,
    required String shopId,
  }) : _repository = repository,
       super(PromotionsState.initial(shopId: shopId)) {
    loadPromotions();
    loadStats();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> loadPromotions() async {
    if (_disposed) return;
    
    state = state.copyWith(isLoading: true, error: null);

    try {
      final promotions = await _repository.getPromotions(state.shopId);
      if (_disposed) return;
      
      state = state.copyWith(
        promotions: promotions,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadStats() async {
    if (_disposed) return;
    
    try {
      final stats = await _repository.getPromotionStats(state.shopId);
      if (_disposed) return;
      
      state = state.copyWith(stats: stats);
    } catch (e) {
      // Stats are optional, don't show error
      print('Error loading promotion stats: $e');
    }
  }

  Future<void> refresh() async {
    if (_disposed) return;
    
    state = state.copyWith(isRefreshing: true, error: null);

    try {
      final promotions = await _repository.getPromotions(state.shopId);
      final stats = await _repository.getPromotionStats(state.shopId);
      
      if (_disposed) return;
      
      state = state.copyWith(
        promotions: promotions,
        stats: stats,
        isRefreshing: false,
        error: null,
      );
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }

  Future<void> createPromotion(Promotion promotion) async {
    if (_disposed) return;
    
    state = state.copyWith(isLoading: true, error: null);

    try {
      final newPromotion = await _repository.createPromotion(promotion);
      if (_disposed) return;
      
      final updatedPromotions = [newPromotion, ...state.promotions];
      state = state.copyWith(
        promotions: updatedPromotions,
        isLoading: false,
        error: null,
      );
      await loadStats();
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updatePromotion(Promotion promotion) async {
    if (_disposed) return;
    
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedPromotion = await _repository.updatePromotion(promotion);
      if (_disposed) return;
      
      final updatedPromotions = state.promotions.map((p) {
        return p.id == updatedPromotion.id ? updatedPromotion : p;
      }).toList();
      
      state = state.copyWith(
        promotions: updatedPromotions,
        isLoading: false,
        error: null,
      );
      await loadStats();
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deletePromotion(String promotionId) async {
    if (_disposed) return;
    
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.deletePromotion(promotionId);
      if (_disposed) return;
      
      final updatedPromotions = state.promotions.where((p) => p.id != promotionId).toList();
      state = state.copyWith(
        promotions: updatedPromotions,
        isLoading: false,
        error: null,
      );
      await loadStats();
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void reset() {
    if (_disposed) return;
    state = PromotionsState.initial(shopId: state.shopId);
  }
}
