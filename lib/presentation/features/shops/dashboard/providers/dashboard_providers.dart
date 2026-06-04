// lib/features/dashboard/shared/providers/dashboard_providers.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/controllers/booking_creation_controller.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/export_repository.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/promotions_repository.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/alerts_controller.dart'
    show AlertsState, AlertsController;
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/analytics_controller.dart'
    show AnalyticsState, AnalyticsController;
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/attendance_controller.dart'
    show AttendanceState, AttendanceController;
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/client_management_controller.dart'
    show ClientManagementState, ClientManagementController;
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/export_controller.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/heatmap_controller.dart'
    show HeatmapState, HeatmapController;
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/lost_bookings_controller.dart'
    show LostBookingsState, LostBookingsController;
import 'package:nano_embryo/presentation/features/shops/booking/presentation/providers/booking_mutation_signal.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/owner_dashboard_controller.dart'
    show OwnerDashboardState, OwnerDashboardController;
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/promotions_controller.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/reminders_controller.dart'
    show RemindersState, RemindersController;
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/worker_management_controller.dart'
    show WorkerManagementState, WorkerManagementController;
import 'package:nano_embryo/presentation/features/shops/dashboard/services/export_service.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/services/notification_service.dart';
import 'package:nano_embryo/payment/presentation/controllers/payment_settings_controller.dart';
import 'package:nano_embryo/payment/data/repositories/payment_settings_repository.dart';

// ============ Core Providers ============

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseDashboardRepository(supabaseClient: supabaseClient);
});

// ============ Parameter Classes ============

// Then update each parameter class
class OwnerDashboardParams extends Equatable {
  final String shopId;
  const OwnerDashboardParams({required this.shopId});

  @override
  List<Object?> get props => [shopId];
}

class WorkerManagementParams extends Equatable {
  final String shopId;
  const WorkerManagementParams({required this.shopId});

  @override
  List<Object?> get props => [shopId];
}

class ClientManagementParams extends Equatable {
  final String shopId;
  const ClientManagementParams({required this.shopId});

  @override
  List<Object?> get props => [shopId];
}

class AnalyticsParams extends Equatable {
  final String shopId;
  const AnalyticsParams({required this.shopId});

  @override
  List<Object?> get props => [shopId];
}

class AlertsParams extends Equatable {
  final String shopId;
  const AlertsParams({required this.shopId});

  @override
  List<Object?> get props => [shopId];
}

class HeatmapParams extends Equatable {
  final String shopId;
  const HeatmapParams({required this.shopId});

  @override
  List<Object?> get props => [shopId];
}

class RemindersParams extends Equatable {
  final String shopId;
  const RemindersParams({required this.shopId});

  @override
  List<Object?> get props => [shopId];
}

class AttendanceParams extends Equatable {
  final String shopId;
  const AttendanceParams({required this.shopId});

  @override
  List<Object?> get props => [shopId];
}

class LostBookingsParams extends Equatable {
  final String shopId;
  final int periodDays;
  const LostBookingsParams({required this.shopId, this.periodDays = 7});

  @override
  List<Object?> get props => [shopId, periodDays];
}
// ============ Controller Providers (NO autoDispose) ============

final ownerDashboardControllerProviderFamily = StateNotifierProvider.family<
  OwnerDashboardController,
  OwnerDashboardState,
  OwnerDashboardParams
>((ref, params) {
  final repository = ref.watch(dashboardRepositoryProvider);
  final controller = OwnerDashboardController(
    repository: repository,
    shopId: params.shopId,
  );
  // ref.onDispose(controller.reset);
  return controller;
});

final workerManagementControllerProviderFamily = StateNotifierProvider.family<
  WorkerManagementController,
  WorkerManagementState,
  WorkerManagementParams
>((ref, params) {
  final repository = ref.watch(dashboardRepositoryProvider);
  final controller = WorkerManagementController(
    repository: repository,
    shopId: params.shopId,
  );
  // ref.onDispose(controller.reset);
  return controller;
});

final clientManagementControllerProviderFamily = StateNotifierProvider.family<
  ClientManagementController,
  ClientManagementState,
  ClientManagementParams
>((ref, params) {
  final repository = ref.watch(dashboardRepositoryProvider);
  final controller = ClientManagementController(
    repository: repository,
    shopId: params.shopId,
  );
  // ref.onDispose(controller.reset);
  return controller;
});

final analyticsControllerProviderFamily = StateNotifierProvider.family<
  AnalyticsController,
  AnalyticsState,
  AnalyticsParams
>((ref, params) {
  final repository = ref.watch(dashboardRepositoryProvider);
  final controller = AnalyticsController(
    repository: repository,
    shopId: params.shopId,
  );
  // ref.onDispose(controller.reset);
  return controller;
});

final alertsControllerProviderFamily =
    StateNotifierProvider.family<AlertsController, AlertsState, AlertsParams>((
      ref,
      params,
    ) {
      final repository = ref.watch(dashboardRepositoryProvider);
      final controller = AlertsController(
        repository: repository,
        shopId: params.shopId,
      );
      // ref.onDispose(controller.reset);
      return controller;
    });

final heatmapControllerProviderFamily = StateNotifierProvider.family<
  HeatmapController,
  HeatmapState,
  HeatmapParams
>((ref, params) {
  final repository = ref.watch(dashboardRepositoryProvider);
  final controller = HeatmapController(
    repository: repository,
    shopId: params.shopId,
  );
  // ref.onDispose(controller.reset);
  return controller;
});

final lostBookingsControllerProviderFamily = StateNotifierProvider.family<
  LostBookingsController,
  LostBookingsState,
  LostBookingsParams
>((ref, params) {
  final repository = ref.watch(dashboardRepositoryProvider);
  final controller = LostBookingsController(
    repository: repository,
    shopId: params.shopId,
    periodDays: params.periodDays,
  );
  // ref.listen (NOT watch) — we react to the tick without tearing down
  // the controller every time the signal bumps.
  ref.listen<int>(bookingMutationProvider, (_, __) {
    controller.refresh();
  });
  return controller;
});

final remindersControllerProviderFamily = StateNotifierProvider.family<
  RemindersController,
  RemindersState,
  RemindersParams
>((ref, params) {
  final repository = ref.watch(dashboardRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final controller = RemindersController(
    repository: repository,
    notificationService: notificationService,
    shopId: params.shopId,
  );
  // ref.onDispose(controller.reset);
  return controller;
});

final attendanceControllerProviderFamily = StateNotifierProvider.family<
  AttendanceController,
  AttendanceState,
  AttendanceParams
>((ref, params) {
  final repository = ref.watch(dashboardRepositoryProvider);
  final controller = AttendanceController(
    repository: repository,
    shopId: params.shopId,
  );
  // ref.onDispose(controller.reset);
  return controller;
});

final promotionsRepositoryProvider = Provider<PromotionsRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return PromotionsRepository(supabaseClient: supabaseClient);
});

class PromotionsParams {
  final String shopId;
  const PromotionsParams({required this.shopId});
}

final promotionsControllerProviderFamily = StateNotifierProvider.autoDispose
    .family<PromotionsController, PromotionsState, PromotionsParams>((
      ref,
      params,
    ) {
      final repository = ref.watch(promotionsRepositoryProvider);
      final controller = PromotionsController(
        repository: repository,
        shopId: params.shopId,
      );
      ref.onDispose(controller.reset);
      return controller;
    });

// Export Repository
final exportRepositoryProvider = Provider<ExportRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ExportRepository(supabaseClient: supabaseClient);
});

// Export Service (already exists, but ensure it's provided)
final exportServiceProvider = Provider<ExportService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ExportService(supabaseClient: supabaseClient);
});

// Export Controller
final exportControllerProvider =
    StateNotifierProvider<ExportController, ExportState>((ref) {
      final exportService = ref.watch(exportServiceProvider);
      return ExportController(exportService: exportService);
    });

// Payment Settings Repository
final paymentSettingsRepositoryProvider = Provider<PaymentSettingsRepository>((
  ref,
) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return PaymentSettingsRepository(supabaseClient: supabaseClient);
});

// Payment Settings Params
class PaymentSettingsParams extends Equatable {
  final String shopId;
  final String shopCountry;

  const PaymentSettingsParams({
    required this.shopId,
    required this.shopCountry,
  });

  @override
  List<Object?> get props => [shopId, shopCountry];
}
// Payment Settings Controller
final paymentSettingsControllerProviderFamily = StateNotifierProvider
    .autoDispose
    .family<
      PaymentSettingsController,
      PaymentSettingsState,
      PaymentSettingsParams
    >((ref, params) {
      final repository = ref.watch(paymentSettingsRepositoryProvider);
      final controller = PaymentSettingsController(
        repository: repository,
        shopId: params.shopId,
        shopCountry: params.shopCountry,
      );
      ref.onDispose(controller.reset);
      return controller;
    });
// ============ Helper Providers ============

final currentUserShopIdProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final supabase = ref.watch(supabaseClientProvider);

  final shopResponse =
      await supabase
          .from('shops')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

  if (shopResponse != null) {
    return shopResponse['id'];
  }

  final workerResponse =
      await supabase
          .from('workers')
          .select('shop_id')
          .eq('user_id', user.id)
          .maybeSingle();

  return workerResponse?['shop_id'];
});

final isShopOwnerProvider = FutureProvider<bool>((ref) async {
  final shopId = await ref.watch(currentUserShopIdProvider.future);
  return shopId != null;
});

final isWorkerProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;

  final supabase = ref.watch(supabaseClientProvider);
  final response =
      await supabase
          .from('workers')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

  return response != null;
});
