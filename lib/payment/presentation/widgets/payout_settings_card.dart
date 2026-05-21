import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/payment/data/models/payment_settings_model.dart';

class PayoutSettingsCard extends ConsumerStatefulWidget {
  final PaymentSettings settings;
  final bool isSaving;
  final Function(PayoutSchedule, double) onSave;

  const PayoutSettingsCard({
    super.key,
    required this.settings,
    required this.isSaving,
    required this.onSave,
  });

  @override
  ConsumerState<PayoutSettingsCard> createState() => _PayoutSettingsCardState();
}

class _PayoutSettingsCardState extends ConsumerState<PayoutSettingsCard> {
  late PayoutSchedule _selectedSchedule;
  late TextEditingController _minimumController;
  late bool _autoPayoutEnabled;

  @override
  void initState() {
    super.initState();
    _selectedSchedule = widget.settings.payoutSchedule;
    _minimumController = TextEditingController(
      text: widget.settings.payoutMinimum.toString(),
    );
    _autoPayoutEnabled = widget.settings.autoPayoutEnabled;
  }

  @override
  void dispose() {
    _minimumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currency =
        widget.settings.payoutCurrency.isNotEmpty
            ? widget.settings.payoutCurrency
            : 'GHS';

    return CardInkWell(
      onTap: () {},
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payout Settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onBackground,
                ),
              ),
              // Auto-payout toggle
              Row(
                children: [
                  Text('Auto-payout', style: theme.textTheme.bodySmall),
                  Switch(
                    value: _autoPayoutEnabled,
                    onChanged: (value) {
                      setState(() {
                        _autoPayoutEnabled = value;
                      });
                      // Save auto-payout setting
                      widget.onSave(
                        _selectedSchedule,
                        double.tryParse(_minimumController.text) ?? 50.00,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          Gap(Spacing.md.h),
          // Payout Schedule
          Text(
            'Payout Schedule',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onBackground,
            ),
          ),
          Gap(Spacing.sm.h),
          Wrap(
            spacing: Spacing.sm.w,
            children:
                PayoutSchedule.values.map((schedule) {
                  final isSelected = _selectedSchedule == schedule;
                  return AppFilterChip(
                    label: schedule.displayName,
                    borderWidth: 0.3,
                    selected: isSelected,
                    onSelected:
                        _autoPayoutEnabled
                            ? (bool selected) {
                              if (selected) {
                                setState(() {
                                  _selectedSchedule = schedule;
                                });
                              }
                            }
                            : (
                              bool selected,
                            ) {}, // Empty callback when disabled (not null)
                  );
                }).toList(),
          ),
          Gap(Spacing.md.h),

          // Minimum Payout Amount
          Text(
            'Minimum Payout Amount ($currency)',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onBackground,
            ),
          ),
          Gap(Spacing.sm.h),

          AppTextFormField(
            controller: _minimumController,
            maxLength: 10,
            label: 'Minimum payout amount',
            hintText: 'Enter minimum payout amount',
            prefixIcon: Icons.money,
            keyboardType: TextInputType.number,
            enabled: _autoPayoutEnabled,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter minimum amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Enter a valid amount';
              }
              return null;
            },
          ),
          Gap(Spacing.lg.h),

          AppButton(
            elevation: 0,
            label: 'Save Payout Settings',
            onPressed:
                widget.isSaving
                    ? null
                    : () {
                      final minimum =
                          double.tryParse(_minimumController.text) ?? 50.00;
                      widget.onSave(_selectedSchedule, minimum);
                    },
            size: ButtonSize.small,
            width: double.infinity,
            padding: Spacing.horizontalMd,
            height: 35.h,
          ),
          Gap(Spacing.md.h),
          SemanticContainerWidget(
            content:
                'Payouts will be automatically sent to your connected bank account based on your schedule',
            title: '',
            icon: Icons.warning,
            backgroundColor: colorScheme.warning.withOpacity(0.1),
            borderColor: colorScheme.warning,
            iconColor: colorScheme.warning,
            textTheme: theme.textTheme,
          ),
        ],
      ),
    );
  }
}
