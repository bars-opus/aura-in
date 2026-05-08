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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    var remainingAmount = totalAmount - depositAmount;
    return Column(
      children: [
        SizedBox(height: Spacing.xl.h),
        Text(
          "Receipt",
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onBackground,
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
        _buildPriceRow(context, 'Total Amount', totalAmount.toString()),
        AppDivider(),
        _buildPriceRow(
          context,
          'Deposit Paid (30%)',
          depositAmount.toString(),
          valueColor: Colors.green,
        ),
        AppDivider(),
        _buildPriceRow(
          context,
          'Platform Fee',
          platformFee.toString() ?? '',
          valueColor: Colors.green,
        ),
        AppDivider(),
        _buildPriceRow(
          context,
          'Remaining to Pay',
          remainingAmount.toString(),
          isBold: true,
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
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          label == 'Reference'
              ? amount.toString()
              : '${shopCurrency} ${amount}',
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
