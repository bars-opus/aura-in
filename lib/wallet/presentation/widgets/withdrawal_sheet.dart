// lib/features/wallet/presentation/widgets/withdrawal_sheet.dart

import 'dart:async';

import 'package:nano_embryo/core/feedback/review/review_providers.dart';
import 'package:nano_embryo/core/utils/logging/app_logger.dart';
import 'package:nano_embryo/payment/presentation/widgets/info_row.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:nano_embryo/wallet/presentation/controllers/wallet_controller.dart';
import 'package:nano_embryo/wallet/presentation/providers/payment_setup_provider.dart';

class WithdrawalSheet extends ConsumerStatefulWidget {
  final String shopId;
  final String shopCurrency;

  final double availableBalance;
  final VoidCallback onSuccess;

  const WithdrawalSheet({
    Key? key,
    required this.shopId,
    required this.shopCurrency,
    required this.availableBalance,
    required this.onSuccess,
  }) : super(key: key);

  @override
  ConsumerState<WithdrawalSheet> createState() => _WithdrawalSheetState();
}

class _WithdrawalSheetState extends ConsumerState<WithdrawalSheet> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _connectedProvider;
  bool _isLoadingProvider = true;

  // Constants
  static const double minWithdrawal = 50;
  static const double maxWithdrawal = 5000;
  static const double withdrawalFeePercentage = 2.0;
  static const double minFee = 1.0;

  @override
  void initState() {
    super.initState();
    _loadPaymentProvider();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentProvider() async {
    try {
      final provider = await ref.read(
        connectedPaymentProviderProvider(widget.shopId).future,
      );
      if (mounted) {
        setState(() {
          _connectedProvider = provider;
          _isLoadingProvider = false;
        });
      }
    } catch (e) {
      AppLogger.warn(
        'wallet.withdrawal_sheet.provider_load_failed',
        fields: {'shop_id': widget.shopId, 'error': e.toString()},
      );
      if (mounted) {
        setState(() {
          _connectedProvider = null;
          _isLoadingProvider = false;
        });
      }
    }
  }

  double _calculateFee(double amount) {
    final fee = amount * withdrawalFeePercentage / 100;
    return fee > minFee ? fee : minFee;
  }

  double _calculateNetAmount(double amount) {
    return amount - _calculateFee(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 1.0, // Now 1.0 relative to the Container
      minChildSize: 0.5,
      maxChildSize: 1.0,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BottomSheetHeader(title: loc.withdrawalTitle),
                Gap(Spacing.lg.h),
                SemanticContainerWidget(
                  content: loc.withdrawalInfo(
                    withdrawalFeePercentage,
                    widget.shopCurrency,
                    minFee,
                  ),
                  icon: Icons.monetization_on,
                  title: loc.withdrawalAvailableBalance(
                    widget.shopCurrency,
                    widget.availableBalance.toStringAsFixed(2),
                  ),
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  borderColor: colorScheme.primary,
                  iconColor: colorScheme.primary,
                  textTheme: theme.textTheme,
                ),

                _errorAndLoading(loc),

                Gap(Spacing.lg.h),

                // Amount field
                AppTextFormField(
                  controller: _amountController,

                  label: loc.withdrawalAmountInputLabel(widget.shopCurrency),
                  hintText: loc.withdrawalAmountHint,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.attach_money,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return loc.withdrawalAmountRequired;
                    }
                    final amount = double.tryParse(value);
                    if (amount == null) {
                      return loc.withdrawalAmountInvalid;
                    }
                    if (amount < minWithdrawal) {
                      return loc.withdrawalMinimum(widget.shopCurrency, minWithdrawal);
                    }
                    if (amount > maxWithdrawal) {
                      return loc.withdrawalMaximum(widget.shopCurrency, maxWithdrawal);
                    }
                    if (amount > widget.availableBalance) {
                      return loc.withdrawalInsufficientBalance(
                        widget.shopCurrency,
                        widget.availableBalance.toStringAsFixed(2),
                      );
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                Gap(Spacing.md.h),

                // Fee breakdown
                if (_amountController.text.isNotEmpty)
                  _buildFeeBreakdown(theme, colorScheme, loc),
                Gap(Spacing.xl.h),

                // Submit button
                _isSubmitting
                    ? Center(
                      child: LoadingStateWidget(type: LoadingStateType.inline),
                    )
                    : AppButton(
                      elevation: 0,
                      label:
                          _isSubmitting
                              ? loc.withdrawalProcessing
                              : loc.withdrawalRequestButton,
                      onPressed:
                          _isSubmitting || _connectedProvider == null
                              ? null
                              : _submitWithdrawal,

                      size: ButtonSize.small,
                      width: double.infinity,
                      padding: Spacing.horizontalMd,
                      height: 40.h,
                    ),

                Gap(Spacing.md.h),
              ],
            ),
          ),
        );
      },
    );
  }

  _errorAndLoading(AppLocalizations loc) {
    return Column(
      children: [
        // Connected payment method
        if (_isLoadingProvider)
          const Center(child: LoadingStateWidget(type: LoadingStateType.inline))
        else if (_connectedProvider == null)
          _buildErrorWidget(loc.withdrawalNoPaymentMethod)
        else
          SizedBox.shrink(),
      ],
    );
  }

  Widget _buildFeeBreakdown(ThemeData theme, ColorScheme colorScheme, AppLocalizations loc) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final fee = _calculateFee(amount);
    final netAmount = _calculateNetAmount(amount);

    return Container(
      padding: EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          InfoRow(
            valueColor: colorScheme.onBackground,
            label: loc.withdrawalBreakdownAmount,
            value: '${widget.shopCurrency} ${amount.toStringAsFixed(2)}',
          ),

          InfoRow(
            valueColor: colorScheme.error,
            label: loc.withdrawalFeeLabel(withdrawalFeePercentage),
            value: '- ${widget.shopCurrency} ${fee.toStringAsFixed(2)}',
          ),

          InfoRow(
            valueColor: colorScheme.primary,
            label: loc.withdrawalNetAmount,
            value: '${widget.shopCurrency} ${netAmount.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return ErrorStateWidget(subtitle: message, title: '');
  }

  Future<void> _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);

    setState(() => _isSubmitting = true);

    try {
      final controller = ref.read(walletControllerProvider.notifier);
      await controller.requestWithdrawal(
        shopId: widget.shopId,
        amount: amount,
      );

      if (mounted) {
        final loc = AppLocalizations.of(context)!;

        // Feedback engine — a successful withdrawal is the canonical
        // shop-owner happy moment. Capture the prompter BEFORE Navigator.pop
        // because `ref` will be detached once this sheet is gone. Delay the
        // OS prompt a beat so the success snackbar gets to render first.
        final prompter = ref.read(reviewPrompterProvider);
        unawaited(prompter.recordHappyMoment());

        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.withdrawalSuccess),
            backgroundColor: Colors.green,
          ),
        );

        unawaited(
          Future<void>.delayed(const Duration(milliseconds: 1500), () {
            prompter.maybeAsk();
          }),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
