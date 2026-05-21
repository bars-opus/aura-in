import 'package:flutter/services.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/payment/data/models/paystack_subaacount_result.dart';
import 'package:nano_embryo/payment/data/repositories/payment_settings_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum PaymentMethodType { bank, mobileMoney }

class PaystackConnectionScreen extends StatefulWidget {
  final String shopName;
  final String shopId;
  final String shopOwnerId;
  final String shopCurrencyCode;

  const PaystackConnectionScreen({
    super.key,
    required this.shopName,
    required this.shopId,
    required this.shopCurrencyCode,
    required this.shopOwnerId,
  });

  @override
  State<PaystackConnectionScreen> createState() =>
      _PaystackConnectionScreenState();
}

class _PaystackConnectionScreenState extends State<PaystackConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();

  PaymentMethodType _selectedMethod = PaymentMethodType.bank;

  bool _isLoadingBanks = true;
  // bool _isVerifying = false;
  bool _hasBankLoadError = false;

  List<Map<String, String>> _banks = [];
  String? _selectedBankCode;
  String? _selectedBankName;

  final repository = PaymentSettingsRepository(
    supabaseClient: Supabase.instance.client,
  );

  // Mobile money fields
  String? _selectedMobileMoneyProvider;
  final List<Map<String, String>> _mobileMoneyProviders = [
    {'code': 'MTN', 'name': 'MTN Mobile Money'},
    {'code': 'VOD', 'name': 'Vodafone Cash'},
    {'code': 'ATL', 'name': 'AirtelTigo Money'},
  ];

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }

  // Load banks
  Future<void> _loadBanks() async {
    setState(() {
      _isLoadingBanks = true;
      _hasBankLoadError = false;
    });

    try {
      final banks = await repository.fetchBanks(widget.shopCurrencyCode);
      if (mounted) setState(() => _banks = banks);
    } catch (e) {
      print(e.toString());
      if (mounted) setState(() => _hasBankLoadError = true);
    } finally {
      if (mounted) setState(() => _isLoadingBanks = false);
    }
  }

  void _connect() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMethod == PaymentMethodType.bank && _selectedBankCode == null)
      return;
    if (_selectedMethod == PaymentMethodType.mobileMoney &&
        _selectedMobileMoneyProvider == null)
      return;

    final result = PaystackSubaccountResult(
      businessName: widget.shopName,
      bankCode:
          _selectedMethod == PaymentMethodType.bank
              ? _selectedBankCode!
              : _selectedMobileMoneyProvider!,
      accountNumber: _accountNumberController.text.trim(),
      accountType:
          _selectedMethod == PaymentMethodType.bank ? 'bank' : 'mobile_money',
      provider:
          _selectedMethod == PaymentMethodType.mobileMoney
              ? _selectedMobileMoneyProvider
              : null,
    );

    if (mounted) {
      Navigator.pop(context, result);
    }
  }

  void _showMethodSelector() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(Spacing.md.w),
                  child: Text(
                    'Select Payment Method',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.account_balance_wallet,
                    color:
                        _selectedMethod == PaymentMethodType.bank
                            ? Theme.of(context).colorScheme.primary
                            : null,
                  ),
                  title: const Text('Bank Account'),
                  subtitle: const Text('Receive payouts to your bank account'),
                  trailing:
                      _selectedMethod == PaymentMethodType.bank
                          ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                          : null,
                  onTap: () {
                    setState(() {
                      _selectedMethod = PaymentMethodType.bank;

                      _accountNumberController.clear();
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.phone_android,
                    color:
                        _selectedMethod == PaymentMethodType.mobileMoney
                            ? Theme.of(context).colorScheme.primary
                            : null,
                  ),
                  title: const Text('Mobile Money'),
                  subtitle: const Text('Receive payouts to your mobile wallet'),
                  trailing:
                      _selectedMethod == PaymentMethodType.mobileMoney
                          ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                          : null,
                  onTap: () {
                    setState(() {
                      _selectedMethod = PaymentMethodType.mobileMoney;

                      _accountNumberController.clear();
                    });
                    Navigator.pop(context);
                  },
                ),
                Gap(Spacing.md.h),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isBank = _selectedMethod == PaymentMethodType.bank;

    return Scaffold(
      appBar: AppBar(title: const Text('Connect Paystack'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Spacing.md.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your details to receive payouts',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Gap(Spacing.lg.h),

            // Payment Method Selector
            InkWell(
              onTap: _showMethodSelector,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.all(Spacing.md.w),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      isBank
                          ? Icons.account_balance_wallet
                          : Icons.phone_android,
                      color: colorScheme.primary,
                    ),
                    Gap(Spacing.md.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBank ? 'Bank Account' : 'Mobile Money',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            isBank
                                ? 'Receive payouts to your bank'
                                : 'Receive payouts to your mobile wallet',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
            Gap(Spacing.lg.h),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business Name (read-only)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(Spacing.md.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Business Name',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Gap(Spacing.xs.h),
                        Text(
                          widget.shopName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(Spacing.md.h),

                  // Bank / Mobile Money Selection
                  if (isBank)
                    _buildBankSelection()
                  else
                    _buildMobileMoneySelection(),
                  Gap(Spacing.md.h),

                  // Account Number / Phone Number
                  AppTextFormField(
                    controller: _accountNumberController,
                    label: isBank ? 'Account Number *' : 'Phone Number *',
                    hintText:
                        isBank ? '10-digit account number' : 'e.g., 024XXXXXXX',
                    keyboardType: TextInputType.phone,
                    maxLength: isBank ? 20 : 10,
                    suffixIcon: null,

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return isBank
                            ? 'Please enter your account number'
                            : 'Please enter your phone number';
                      }
                      if (!isBank && value.length < 9) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  Gap(Spacing.md.h),
                ],
              ),
            ),
            Gap(Spacing.lg.h),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                Gap(Spacing.md.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (!_isLoadingBanks) ? _connect : null,
                    child: const Text('Connect'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankSelection() {
    if (_hasBankLoadError) {
      return _BankLoadError(onRetry: _loadBanks);
    }

    if (_isLoadingBanks) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              height: 18,
              width: 18,
              child: CircularLoadingIndicator()
            ),
            SizedBox(width: 12),
            Text('Loading banks…'),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Select Bank *',
        prefixIcon: Icon(Icons.account_balance),
      ),
      value: _selectedBankCode,
      items:
          _banks.map((bank) {
            return DropdownMenuItem(
              value: bank['code'],
              child: Text(bank['name']!),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedBankCode = value;
          final selected = _banks.firstWhere(
            (b) => b['code'] == value,
            orElse: () => {},
          );
          _selectedBankName = selected['name'];
        });
      },
      validator: (value) => value == null ? 'Please select your bank' : null,
    );
  }

  Widget _buildMobileMoneySelection() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Select Mobile Money Provider *',
        prefixIcon: Icon(Icons.phone_android),
      ),
      value: _selectedMobileMoneyProvider,
      items:
          _mobileMoneyProviders.map((provider) {
            return DropdownMenuItem(
              value: provider['code'],
              child: Text(provider['name']!),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedMobileMoneyProvider = value;
        });
      },
      validator:
          (value) =>
              value == null ? 'Please select a mobile money provider' : null,
    );
  }
}

class _BankLoadError extends StatelessWidget {
  final VoidCallback onRetry;
  const _BankLoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.onErrorContainer,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Could not load banks. Check your connection.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
