import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class BookingPriceBreakdown extends StatelessWidget {
  final double totalAmount;
  final double depositAmount;
  final double platformFee;
  final VoidCallback payOnPressed;
  final bool isProcessing;
  final String buttonText;
  final String reference;
  final String shopCurrency;
  final bool isShopOwner;

  const BookingPriceBreakdown({
    super.key,
    required this.totalAmount,
    required this.depositAmount,
    required this.platformFee,
    required this.payOnPressed,
    required this.isProcessing,
    required this.buttonText,
    required this.reference,
    required this.isShopOwner,

    required this.shopCurrency,
  });

  String _fmt(double amount) => amount.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final remainingAmount = totalAmount - depositAmount;
    return Column(
      children: [
        SizedBox(height: Spacing.xl.h),
        Text(
          "Receipt",
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),

        Gap(Spacing.sm.h),
        AppDivider(),

        _buildPriceRow(
          context,
          'Reference',
          reference.isEmpty ? '' : reference.substring(0, 5),
          valueColor: Colors.grey,
        ),
        AppDivider(),
        _buildPriceRow(context, 'Total Amount', _fmt(totalAmount)),
        AppDivider(),
        _buildPriceRow(
          context,
          'Deposit (30%)',
          _fmt(depositAmount),
        ),
        AppDivider(),
        _buildPriceRow(
          context,
          'Platform Fee',
          _fmt(platformFee),
        ),
        AppDivider(),
        // The amount charged now = deposit + platform fee (the fee is on top so
        // the shop receives the full deposit). The remaining 70% is billed
        // after the service with no fee.
        _buildPriceRow(
          context,
          'Pay Now',
          _fmt(depositAmount + platformFee),
          isBold: true,
          valueColor: Colors.green,
        ),
        AppDivider(),
        _buildPriceRow(
          context,
          'Remaining (after service)',
          _fmt(remainingAmount),
          valueColor: colorScheme.primary,
        ),

        AppDivider(),
        Gap(Spacing.md.h),
        if (!isShopOwner)
          isProcessing
              ? CircularLoadingIndicator()
              : AppButton(
                elevation: 0,
                label: buttonText,
                onPressed: payOnPressed,

                size: ButtonSize.small,
                width: double.infinity,
                padding: Spacing.horizontalMd,
                height: 40.h,
              ),
        Gap(Spacing.md.h),
      ],
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String amount, {
    bool isBold = false,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          label == 'Reference'
              ? amount.toString()
              : shopCurrency.isNotEmpty
                  ? '$shopCurrency $amount'
                  : amount,
          style:
              isBold
                  ? theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? theme.colorScheme.onSurface,
                  )
                  : theme.textTheme.bodyMedium?.copyWith(
                    color: valueColor ?? theme.colorScheme.onSurface,
                  ),
        ),
      ],
    );
  }
}
