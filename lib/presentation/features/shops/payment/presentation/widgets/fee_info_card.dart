import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/payment/data/models/payment_settings_model.dart';
import 'package:nano_embryo/presentation/features/shops/payment/presentation/widgets/info_row.dart';

class FeeInfoCard extends StatelessWidget {
  final String provider;
  final PaymentSettings? settings;

  const FeeInfoCard({
    super.key,
    required this.provider,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isStripe = provider == 'stripe';
    final percentageFee = isStripe ? 2.9 : 1.5;
    final fixedFee = isStripe ? 0.30 : 0.20;
    final currency = settings?.payoutCurrency ?? 'USD';

    return CardInkWell(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Fees',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onBackground,
            ),
          ),
          Gap(Spacing.sm.h),
          InfoRow(
            label: 'Platform Fee',
            value: '$percentageFee% + $fixedFee $currency',
          ),
          Gap(Spacing.sm.h),
          InfoRow(
            label: 'You Keep',
            value: '${100 - percentageFee}% of transaction',
          ),
          Gap(Spacing.sm.h),
          Text(
            'Fees are deducted automatically from each transaction.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
