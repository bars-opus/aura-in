// lib/features/dashboard/presentation/screens/payment_settings_screen.dart
import 'dart:async';

import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';
import 'package:nano_embryo/payment/data/models/payment_settings_model.dart';
import 'package:nano_embryo/payment/data/models/paystack_subaacount_result.dart';
import 'package:nano_embryo/payment/data/repositories/payment_settings_repository.dart';
import 'package:nano_embryo/payment/presentation/controllers/payment_settings_controller.dart';
import 'package:nano_embryo/payment/presentation/widgets/fee_info_card.dart';
import 'package:nano_embryo/payment/presentation/widgets/payout_settings_card.dart';
import 'package:nano_embryo/payment/presentation/widgets/paystack_connection_card.dart';
import 'package:nano_embryo/payment/presentation/widgets/region_info_card.dart';
import 'package:nano_embryo/payment/presentation/widgets/stripe_oauth_popup.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentSettingsScreen extends ConsumerStatefulWidget {
  final String shopId;
  final String shopOwnerId;

  final String shopCountry;
  final String shopName;
  final String shopCurrencyCode;

  const PaymentSettingsScreen({
    super.key,
    required this.shopId,
    required this.shopOwnerId,
    required this.shopCountry,
    required this.shopName,
    required this.shopCurrencyCode,
  });

  @override
  ConsumerState<PaymentSettingsScreen> createState() =>
      _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends ConsumerState<PaymentSettingsScreen> {
  bool _isConnecting = false;

  final repository = PaymentSettingsRepository(
    supabaseClient: Supabase.instance.client,
  );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      paymentSettingsControllerProviderFamily(
        PaymentSettingsParams(
          shopId: widget.shopId,
          shopCountry: widget.shopCountry,
        ),
      ),
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),

        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _buildContent(state),
    );
  }

  Widget _buildContent(PaymentSettingsState state) {
    if (state.isLoading) {
      return const Center(child: CircularLoadingIndicator());
    }
    if (state.error != null && state.settings == null) {
      return Center(
        child: ErrorStateWidget(
          subtitle: 'Failed to load settings',
          title: '',
          onPrimaryAction:
              () =>
                  ref
                      .read(
                        paymentSettingsControllerProviderFamily(
                          PaymentSettingsParams(
                            shopId: widget.shopId,
                            shopCountry: widget.shopCountry,
                          ),
                        ).notifier,
                      )
                      .refreshSettings(),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(Spacing.md.h),
      children: [
        RegionInfoCard(
          country: widget.shopCountry,
          recommendedProvider: state.recommendedProvider,
        ),
        Gap(Spacing.lg.h),
        if (state.isStripeRegion)
          PaystackConnectionCard(
            isConnected: state.isConnected,
            settings: state.settings,
            isConnecting: _isConnecting,
            onConnect: _connectStripe,
            onDisconnect: _disconnectProvider,
            paymentProvider: 'Stripe',
          )
        else if (state.isPaystackRegion)
          PaystackConnectionCard(
            isConnected: state.isConnected,
            settings: state.settings,
            isConnecting: _isConnecting,
            onConnect: _connectPaystack,
            onDisconnect: _disconnectProvider,
            paymentProvider: 'Paystack',
          ),
        if (state.isConnected && state.settings != null)
          PayoutSettingsCard(
            settings: state.settings!,
            isSaving: state.isSaving,
            onSave: _updatePayoutSettings,
          ),
        FeeInfoCard(
          provider: state.recommendedProvider,
          settings: state.settings,
        ),
      ],
    );
  }

  // Connect Paystack
  Future<void> _connectPaystack() async {
    final result = await context.push<PaystackSubaccountResult>(
      RouteNames.paystackConnectionScreen,
      extra: {
        'shopName': widget.shopName,
        'shopId': widget.shopId,
        'shopCurrencyCode': widget.shopCurrencyCode,
      },
    );

    if (result != null) {
      setState(() => _isConnecting = true);

      try {
        // ✅ Simplified - no accountType or provider needed
        final createResult = await repository.createSubaccount(
          shopId: widget.shopId,
          businessName: result.businessName,
          bankCode:
              result
                  .bankCode, // This is the actual bank code (e.g., '058' for MTN)
          accountNumber: result.accountNumber,
          currencyCode: widget.shopCurrencyCode, // Add this parameter
        );

        if (createResult['success'] == true) {
          await ref
              .read(
                paymentSettingsControllerProviderFamily(
                  PaymentSettingsParams(
                    shopId: widget.shopId,
                    shopCountry: widget.shopCountry,
                  ),
                ).notifier,
              )
              .refreshSettings();
          _showSuccess('Paystack account connected successfully!');
        }
      } catch (e) {
        _showError('Failed to connect Paystack: $e');
      } finally {
        if (mounted) setState(() => _isConnecting = false);
      }
    }
  }

  Future<void> _connectStripe() async {
    setState(() => _isConnecting = true);

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.functions.invoke(
        'stripe-connect',
        body: {'action': 'create-oauth-link'},
      );

      final data = response.data as Map<String, dynamic>;

      if (data['url'] != null) {
        final completer = Completer<bool?>();

        BottomSheetUtils.showDocumentationBottomSheet(
          context: context,
          maxHeight: 650.h, // Adjust height for webview
          widget: StripeOAuthPopup(
            url: data['url'],
            onSuccess: () {
              completer.complete(true);
              Navigator.pop(context);
            },
            onError: (error) {
              _showError('Stripe connection failed: $error');
              completer.complete(false);
              Navigator.pop(context);
            },
          ),
        );

        final result = await completer.future;

        if (result == true) {
          await ref
              .read(
                paymentSettingsControllerProviderFamily(
                  PaymentSettingsParams(
                    shopId: widget.shopId,
                    shopCountry: widget.shopCountry,
                  ),
                ).notifier,
              )
              .refreshSettings();
          _showSuccess('Stripe account connected successfully!');
        }
      } else {
        throw Exception('No OAuth URL received');
      }
    } catch (e) {
      _showError('Failed to connect Stripe: $e');
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  Future<void> _disconnectProvider() async {
    final completer = Completer<bool?>();

    BottomSheetUtils.showDocumentationBottomSheet(
      maxHeight: 320.h,
      context: context,
      widget: ConfirmationDialog(
        noIcon: true,
        type: ConfirmationType.info,
        title: 'Disconnect Payment Provider',
        confirmText: 'Disconnect',
        message:
            'Are you sure you want to disconnect your payment account? '
            'You will not be able to receive payouts until you reconnect.',
        onConfirm: () {
          completer.complete(true);
          Navigator.pop(context);
        },
        onCancel: () {
          completer.complete(false);
          Navigator.pop(context);
        },
      ),
    );

    final confirmed = await completer.future;

    if (confirmed == true) {
      await ref
          .read(
            paymentSettingsControllerProviderFamily(
              PaymentSettingsParams(
                shopId: widget.shopId,
                shopCountry: widget.shopCountry,
              ),
            ).notifier,
          )
          .disconnectProvider();
      _showSuccess('Payment provider disconnected');
    }
  }

  Future<void> _updatePayoutSettings(
    PayoutSchedule schedule,
    double minimum,
  ) async {
    await ref
        .read(
          paymentSettingsControllerProviderFamily(
            PaymentSettingsParams(
              shopId: widget.shopId,
              shopCountry: widget.shopCountry,
            ),
          ).notifier,
        )
        .updatePayoutSettings(schedule: schedule, minimum: minimum);

    if (mounted) {
      _showSuccess('Payout settings saved');
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    context.showSuccessSnackbar(message);
  }

  void _showError(String message) {
    if (!mounted) return;
    context.showErrorSnackbar(message);
  }
}
