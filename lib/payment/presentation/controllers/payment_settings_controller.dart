// lib/features/dashboard/presentation/controllers/payment_settings_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:nano_embryo/payment/data/models/payment_settings_model.dart';
import 'package:nano_embryo/payment/data/repositories/payment_settings_repository.dart';
import 'package:nano_embryo/payment/services/country_detection_service.dart';

class PaymentSettingsState extends Equatable {
  final PaymentSettings? settings;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String shopCountry;
  final String recommendedProvider;

  const PaymentSettingsState({
    this.settings,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    required this.shopCountry,
    required this.recommendedProvider,
  });

  factory PaymentSettingsState.initial({required String shopCountry}) {
    return PaymentSettingsState(
      shopCountry: shopCountry,
      recommendedProvider: CountryDetectionService.getRecommendedProvider(
        shopCountry,
      ),
      isLoading: true,
    );
  }

  bool get isStripeRegion => recommendedProvider == 'stripe';
  bool get isPaystackRegion => recommendedProvider == 'paystack';
  bool get hasSettings => settings != null;
  bool get isConnected => settings?.isConnected ?? false;

  PaymentSettingsState copyWith({
    PaymentSettings? settings,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? shopCountry,
    String? recommendedProvider,
  }) {
    return PaymentSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      shopCountry: shopCountry ?? this.shopCountry,
      recommendedProvider: recommendedProvider ?? this.recommendedProvider,
    );
  }

  @override
  List<Object?> get props => [
    settings,
    isLoading,
    isSaving,
    error,
    shopCountry,
    recommendedProvider,
  ];
}

class PaymentSettingsController extends StateNotifier<PaymentSettingsState> {
  final PaymentSettingsRepository _repository;
  final String _shopId;
  bool _disposed = false;
  bool _isLoading = false;
  bool _initialized = false; // Ensure load runs only once

  PaymentSettingsController({
    required PaymentSettingsRepository repository,
    required String shopId,
    required String shopCountry,
  }) : _repository = repository,
       _shopId = shopId,
       super(PaymentSettingsState.initial(shopCountry: shopCountry)) {
    _loadSettingsOnce();
  }

  // Internal method that runs only once
  void _loadSettingsOnce() {
    if (_initialized) return;
    _initialized = true;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (_isLoading || _disposed) return;
    _isLoading = true;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final settings = await _repository.getSettings(_shopId);
      if (!_disposed) {
        state = state.copyWith(
          settings: settings,
          isLoading: false,
          error: null,
        );
      }
    } catch (e) {
      if (!_disposed) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    } finally {
      _isLoading = false;
    }
  }

  // Public method for manual refresh (pull-to-refresh, after connect/disconnect)
  Future<void> refreshSettings() async {
    if (_disposed) return;
    await _loadSettings();
  }

  Future<void> updatePayoutSettings({
    required PayoutSchedule schedule,
    required double minimum,
  }) async {
    if (_disposed) return;

    state = state.copyWith(isSaving: true, error: null);

    try {
      final currentSettings = state.settings;

      // Phase 17: PaymentSettings.payoutMinimum is now int kobo. Owner UI
      // captures major-unit input as double; convert at the boundary.
      final minimumMinor = (minimum * 100).round();
      final updatedSettings =
          currentSettings?.copyWith(
            payoutSchedule: schedule,
            payoutMinimumMinor: minimumMinor,
          ) ??
          PaymentSettings(
            shopId: _shopId,
            paymentProvider: PaymentProvider.none,
            payoutSchedule: schedule,
            payoutMinimumMinor: minimumMinor,
            payoutCurrency: CountryDetectionService.getCurrencyForCountry(
              state.shopCountry,
            ),
            autoPayoutEnabled: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

      final saved = await _repository.saveSettings(updatedSettings);
      if (_disposed) return;

      state = state.copyWith(settings: saved, isSaving: false, error: null);
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  Future<void> disconnectProvider() async {
    if (_disposed) return;

    state = state.copyWith(isSaving: true, error: null);

    try {
      final currentSettings = state.settings;
      if (currentSettings == null) {
        state = state.copyWith(isSaving: false);
        return;
      }

      final updatedSettings = currentSettings.copyWith(
        paymentProvider: PaymentProvider.none,
        stripeAccountId: null,
        paystackSubaccountCode: null,
        paystackVerified: false,
        connectedAt: null,
      );

      final saved = await _repository.saveSettings(updatedSettings);
      if (_disposed) return;

      state = state.copyWith(settings: saved, isSaving: false, error: null);
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  void reset() {
    if (_disposed) return;
    _initialized = false;
    _isLoading = false;
    state = PaymentSettingsState.initial(shopCountry: state.shopCountry);
    _loadSettingsOnce();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
