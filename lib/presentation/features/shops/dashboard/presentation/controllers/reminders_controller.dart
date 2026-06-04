// lib/features/dashboard/presentation/controllers/reminders_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:nano_embryo/core/utils/logging/app_logger.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/services/notification_service.dart';

class RemindersState extends Equatable {
  final Map<String, dynamic> settings;
  final bool isLoading;
  final bool isRefreshing;
  final bool isSending;
  final String? error;
  final int? lastSentCount;
  final String shopId;

  const RemindersState({
    required this.shopId,
    this.settings = const {},
    this.isLoading = false,
    this.isRefreshing = false,
    this.isSending = false,
    this.error,
    this.lastSentCount,
  });

  factory RemindersState.initial({required String shopId}) {
    return RemindersState(shopId: shopId, isLoading: true);
  }

  bool get hasError => error != null;
  bool get isEmpty => !isLoading && settings.isEmpty;

  RemindersState copyWith({
    Map<String, dynamic>? settings,
    bool? isLoading,
    bool? isRefreshing,
    bool? isSending,
    String? error,
    int? lastSentCount,
  }) {
    return RemindersState(
      shopId: shopId,
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSending: isSending ?? this.isSending,
      error: error,
      lastSentCount: lastSentCount ?? this.lastSentCount,
    );
  }

  @override
  List<Object?> get props => [shopId, settings, isLoading, isRefreshing, isSending, error, lastSentCount];
}

class RemindersController extends StateNotifier<RemindersState> {
  final DashboardRepository _repository;
  final NotificationService _notificationService;
  bool _disposed = false;

  RemindersController({
    required DashboardRepository repository,
    required NotificationService notificationService,
    required String shopId,
  }) : _repository = repository,
       _notificationService = notificationService,
       super(RemindersState.initial(shopId: shopId)) {
    loadSettings();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> loadSettings() async {
    if (_disposed) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final settings = await _repository.getReminderSettings(state.shopId);
      if (_disposed) return;

      state = state.copyWith(settings: settings, isLoading: false, error: null);
    } catch (e) {
      if (_disposed) return;
      AppLogger.warn('reminders.load_failed',
          fields: {'shop_id': state.shopId, 'error': e.toString()});
      state = state.copyWith(isLoading: false, error: 'load_failed');
    }
  }

  Future<void> refresh() async {
    if (_disposed) return;

    state = state.copyWith(isRefreshing: true, error: null);

    try {
      final settings = await _repository.getReminderSettings(state.shopId);
      if (_disposed) return;

      state = state.copyWith(settings: settings, isRefreshing: false, error: null);
    } catch (e) {
      if (_disposed) return;
      AppLogger.warn('reminders.refresh_failed',
          fields: {'shop_id': state.shopId, 'error': e.toString()});
      state = state.copyWith(isRefreshing: false, error: 'refresh_failed');
    }
  }

  Future<void> updateSettings(Map<String, dynamic> newSettings) async {
    if (_disposed) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.updateReminderSettings(
        shopId: state.shopId,
        enabled: newSettings['enabled'],
        reminderHours: newSettings['reminder_hours'],
        smsEnabled: newSettings['sms_enabled'],
        emailEnabled: newSettings['email_enabled'],
        marketingEnabled: newSettings['marketing_enabled'],
      );
      if (_disposed) return;

      final settings = await _repository.getReminderSettings(state.shopId);
      if (_disposed) return;

      state = state.copyWith(settings: settings, isLoading: false, error: null);
    } catch (e) {
      if (_disposed) return;
      AppLogger.warn('reminders.update_failed',
          fields: {'shop_id': state.shopId, 'error': e.toString()});
      state = state.copyWith(isLoading: false, error: 'update_failed');
    }
  }

  Future<void> sendBulkReminders({DateTime? date}) async {
    if (_disposed) return;

    state = state.copyWith(isSending: true, error: null);

    try {
      final count = await _repository.sendBulkReminders(state.shopId, date: date);
      if (_disposed) return;

      state = state.copyWith(isSending: false, lastSentCount: count, error: null);
    } catch (e) {
      if (_disposed) return;
      AppLogger.warn('reminders.send_bulk_failed',
          fields: {'shop_id': state.shopId, 'error': e.toString()});
      state = state.copyWith(isSending: false, error: 'send_bulk_failed');
    }
  }

  Future<void> sendManualReminder(String bookingId) async {
    if (_disposed) return;

    state = state.copyWith(isSending: true, error: null);

    try {
      await _repository.sendManualReminder(bookingId);
      if (_disposed) return;

      state = state.copyWith(isSending: false, error: null);
    } catch (e) {
      if (_disposed) return;
      AppLogger.warn('reminders.send_manual_failed',
          fields: {'shop_id': state.shopId, 'error': e.toString()});
      state = state.copyWith(isSending: false, error: 'send_manual_failed');
    }
  }

  void reset() {
    if (_disposed) return;
    state = RemindersState.initial(shopId: state.shopId);
    loadSettings();
  }
}
