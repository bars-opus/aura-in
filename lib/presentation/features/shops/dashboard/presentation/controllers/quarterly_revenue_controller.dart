// lib/features/dashboard/presentation/controllers/quarterly_revenue_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/monthly_revenue.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/quaterly_category_breakdown.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

// ============================================================================
// STATE
// ============================================================================

class QuarterlyRevenueState extends Equatable {
  final int selectedQuarter;

  // Store data per quarter
  final Map<int, List<MonthlyRevenue>> quarterlyMonthlyData;
  final Map<int, List<QuaterlyCategoryBreakdown>> quarterlyCategories;
  final Map<int, bool> quarterlyLoaded;

  final bool isLoading;
  final String? error;

  const QuarterlyRevenueState({
    this.selectedQuarter = 1,
    this.quarterlyMonthlyData = const {},
    this.quarterlyCategories = const {},
    this.quarterlyLoaded = const {},
    this.isLoading = false,
    this.error,
  });

  factory QuarterlyRevenueState.initial() {
    return const QuarterlyRevenueState(isLoading: true);
  }

  // Get current quarter's monthly data
  List<MonthlyRevenue> get currentMonthlyData {
    return quarterlyMonthlyData[selectedQuarter] ?? [];
  }

  // Get current quarter's categories
  List<QuaterlyCategoryBreakdown> get currentCategories {
    return quarterlyCategories[selectedQuarter] ?? [];
  }

  // Get total bookings for current quarter
  int get currentTotalBookings {
    return currentMonthlyData.fold<int>(0, (sum, m) => sum + m.bookingCount);
  }

  bool get hasError => error != null;
  bool get isCurrentQuarterLoaded => quarterlyLoaded[selectedQuarter] == true;
  bool get isEmpty =>
      !isLoading &&
      isCurrentQuarterLoaded &&
      currentMonthlyData.isEmpty &&
      currentCategories.isEmpty;

  QuarterlyRevenueState copyWith({
    int? selectedQuarter,
    Map<int, List<MonthlyRevenue>>? quarterlyMonthlyData,
    Map<int, List<QuaterlyCategoryBreakdown>>? quarterlyCategories,
    Map<int, bool>? quarterlyLoaded,
    bool? isLoading,
    String? error,
  }) {
    return QuarterlyRevenueState(
      selectedQuarter: selectedQuarter ?? this.selectedQuarter,
      quarterlyMonthlyData: quarterlyMonthlyData ?? this.quarterlyMonthlyData,
      quarterlyCategories: quarterlyCategories ?? this.quarterlyCategories,
      quarterlyLoaded: quarterlyLoaded ?? this.quarterlyLoaded,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    selectedQuarter,
    quarterlyMonthlyData,
    quarterlyCategories,
    quarterlyLoaded,
    isLoading,
    error,
  ];
}

// ============================================================================
// CONTROLLER
// ============================================================================
class QuarterlyRevenueController extends StateNotifier<QuarterlyRevenueState> {
  final DashboardRepository _repository;
  final String _shopId;
  final int _year;
  bool _disposed = false;
  bool _isLoading = false;

  QuarterlyRevenueController({
    required DashboardRepository repository,
    required String shopId,
    required int year,
  }) : _repository = repository,
       _shopId = shopId,
       _year = year,
       super(QuarterlyRevenueState.initial()) {
    // Load Q1 data on init
    Future.microtask(() => loadDataForQuarter(1));
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> loadDataForQuarter(int quarter) async {
    // Check if already loaded
    if (state.quarterlyLoaded[quarter] == true) {
      print('⚠️ Quarter $quarter already loaded, just updating selection');
      // Still update the selected quarter
      if (state.selectedQuarter != quarter) {
        state = state.copyWith(selectedQuarter: quarter);
      }
      return;
    }

    if (_isLoading) {
      print('⚠️ Already loading, skipping Q$quarter');
      return;
    }

    if (_disposed) {
      print('⚠️ Controller disposed, skipping Q$quarter');
      return;
    }

    print('🔵 Loading data for Q$quarter');
    _isLoading = true;

    state = state.copyWith(
      selectedQuarter: quarter,
      isLoading: true,
      error: null,
    );

    try {
      // Fetch monthly revenue
      final monthlyData = await _repository.getMonthlyRevenueForQuarter(
        shopId: _shopId,
        year: _year,
        quarter: quarter,
      );

      // Fetch category breakdown
      final categories = await _repository.getCategoryBreakdownForQuarter(
        shopId: _shopId,
        year: _year,
        quarter: quarter,
      );

      if (_disposed) return;

      // Update state with new data for this quarter
      final updatedMonthlyData = Map<int, List<MonthlyRevenue>>.from(
        state.quarterlyMonthlyData,
      );
      updatedMonthlyData[quarter] = monthlyData;

      final updatedCategories = Map<int, List<QuaterlyCategoryBreakdown>>.from(
        state.quarterlyCategories,
      );
      updatedCategories[quarter] = categories;

      final updatedLoaded = Map<int, bool>.from(state.quarterlyLoaded);
      updatedLoaded[quarter] = true;

      state = state.copyWith(
        quarterlyMonthlyData: updatedMonthlyData,
        quarterlyCategories: updatedCategories,
        quarterlyLoaded: updatedLoaded,
        isLoading: false,
        error: null,
      );
      print('✅ State updated for Q$quarter');
    } catch (e) {
      print('❌ Error loading Q$quarter: $e');
      if (_disposed) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    } finally {
      _isLoading = false;
    }
  }

  void setQuarter(int quarter) {
    if (_disposed || state.selectedQuarter == quarter) return;
    print('🔵 Quarter changed to: $quarter');

    // Update selected quarter first (for immediate UI response)
    state = state.copyWith(selectedQuarter: quarter);

    // Load data if not already loaded
    if (state.quarterlyLoaded[quarter] != true) {
      loadDataForQuarter(quarter);
    }
  }

  void refreshCurrentQuarter() async {
    final quarter = state.selectedQuarter;
    // Clear loaded flag to force reload
    final updatedLoaded = Map<int, bool>.from(state.quarterlyLoaded);
    updatedLoaded.remove(quarter);
    state = state.copyWith(quarterlyLoaded: updatedLoaded);
    await loadDataForQuarter(quarter);
  }

  void reset() {
    if (_disposed) return;
    print('🔵 Reset called');
    _isLoading = false;
    state = QuarterlyRevenueState.initial();
    loadDataForQuarter(1);
  }
}

// ============================================================================
// PROVIDER
// ============================================================================
class QuarterlyRevenueParams {
  final String shopId;
  final int year;

  const QuarterlyRevenueParams({required this.shopId, required this.year});
}

final quarterlyRevenueControllerProviderFamily = StateNotifierProvider.family<
  QuarterlyRevenueController,
  QuarterlyRevenueState,
  QuarterlyRevenueParams
>((ref, params) {
  final repository = ref.watch(dashboardRepositoryProvider);

  final controller = QuarterlyRevenueController(
    repository: repository,
    shopId: params.shopId,
    year: params.year,
  );

  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
});
