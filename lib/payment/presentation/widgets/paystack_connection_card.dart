import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/payment/data/models/payment_settings_model.dart';
import 'package:nano_embryo/payment/presentation/widgets/info_row.dart';

class PaystackConnectionCard extends StatelessWidget {
  final bool isConnected;
  final PaymentSettings? settings;
  final bool isConnecting;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final String paymentProvider;

  const PaystackConnectionCard({
    super.key,
    required this.isConnected,
    required this.settings,
    required this.isConnecting,
    required this.onConnect,
    required this.paymentProvider,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CardInkWell(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            paymentProvider,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onBackground,
            ),
          ),
          Gap(Spacing.md.h),
          if (isConnected && settings != null) ...[
            Gap(Spacing.sm.h),
            InfoRow(
              label: 'Payout id',
              value: settings!.paystackRecipientId ?? '',
            ),
            InfoRow(
              label: 'Verification Status',
              value:
                  settings!.paystackVerified == true ? 'Verified' : 'Pending',
              valueColor:
                  settings!.paystackVerified == true
                      ? colorScheme.success
                      : colorScheme.warning,
            ),
            Gap(Spacing.lg.h),
            AppButton(
              height: 35.h,
              label: 'Disconnect Paystack',
              onPressed: onDisconnect,
              outlineColor: colorScheme.error,
              textColor: colorScheme.error,
              padding: Spacing.horizontalMd,
              variant: ButtonVariant.outline,
              size: ButtonSize.small,
              width: double.infinity,
            ),
          ] else ...[
            Text(
              'Connect your mobile money or bank account to start accepting payments and receive payouts.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
            Gap(Spacing.md.h),
            isConnecting
                ? LoadingStateWidget(type: LoadingStateType.inline)
                : AppButton(
                  elevation: 0,
                  label: 'Connect',
                  onPressed: isConnecting ? null : onConnect,
                  size: ButtonSize.small,
                  width: double.infinity,
                  padding: Spacing.horizontalMd,
                  height: 35.h,
                ),
          ],
        ],
      ),
    );
  }
}
