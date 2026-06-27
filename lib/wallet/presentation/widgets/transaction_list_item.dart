// lib/features/wallet/presentation/widgets/transaction_list_item.dart

import 'package:nano_embryo/core/utils/date_formatter.dart';
import 'package:nano_embryo/core/utils/money.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:nano_embryo/wallet/data/models/wallet_transaction_model.dart';

class TransactionListItem extends StatelessWidget {
  final WalletTransactionModel transaction;
  final String currencyCode;

  const TransactionListItem({
    Key? key,
    required this.transaction,
    required this.currencyCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    final isCredit = transaction.isCredit;
    final icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
    final iconColor = isCredit ? Colors.green : Colors.red;
    final amountColor = isCredit ? Colors.green : Colors.red;
    final amountPrefix = isCredit ? '+' : '-';

    return CardInkWell(
      margin: EdgeInsets.only(bottom: Spacing.sm.h),
      child: InfoRowWidget(
        title: _getTransactionTitle(loc),
        subtitle:
            "${MyDateFormat.toDate(transaction.createdAt)}\n${MyDateFormat.toTime(transaction.createdAt)}",
        iconColor: iconColor,
        backgroundColor: iconColor.withOpacity(.1),
        icon: icon,
        avatarRadius: 20.h,
        showTrailingArrow: false,
        disableTrailing: false,
        circularRadius: 10.r,
        showDivider: false,
        trailing: // Trend indicator
            Text(
          '$amountPrefix${formatMajorMoney(transaction.amount.abs(), currencyCode)}',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: amountColor,
          ),
        ),
      ),
    );

    // Container(
    //   margin: EdgeInsets.symmetric(
    //     horizontal: Spacing.md.w,
    //     vertical: Spacing.xs.h,
    //   ),
    //   child: Material(
    //     color: Colors.transparent,
    //     child: InkWell(
    //       borderRadius: BorderRadius.circular(12.r),
    //       onTap: () {
    //         // Show transaction details
    //       },
    //       child: Container(
    //         padding: EdgeInsets.all(Spacing.md.w),
    //         decoration: BoxDecoration(
    //           color: colorScheme.surfaceVariant.withOpacity(0.3),
    //           borderRadius: BorderRadius.circular(12.r),
    //         ),
    //         child: Row(
    //           children: [
    //             Container(
    //               width: 44.w,
    //               height: 44.h,
    //               decoration: BoxDecoration(
    //                 color: iconColor.withOpacity(0.1),
    //                 shape: BoxShape.circle,
    //               ),
    //               child: Icon(icon, color: iconColor, size: 24.w),
    //             ),
    //             Gap(Spacing.md.w),
    //             Expanded(
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text(
    //                     _getTransactionTitle(loc),
    //                     style: theme.textTheme.titleSmall?.copyWith(
    //                       fontWeight: FontWeight.w600,
    //                     ),
    //                   ),
    //                   Gap(Spacing.xs.h),
    //                   Text(
    //                     _formatDate(transaction.createdAt, loc),
    //                     style: theme.textTheme.labelSmall?.copyWith(
    //                       color: colorScheme.onSurface.withOpacity(0.6),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    // Text(
    //   '$amountPrefix GHS ${transaction.amount.abs().toStringAsFixed(2)}',
    //   style: theme.textTheme.titleSmall?.copyWith(
    //     fontWeight: FontWeight.w700,
    //     color: amountColor,
    //   ),
    // ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  String _getTransactionTitle(AppLocalizations loc) {
    switch (transaction.type) {
      case TransactionType.deposit:
        return loc.transactionDepositReceived;
      case TransactionType.servicePayment:
        return loc.transactionServicePayment;
      case TransactionType.withdrawal:
        return loc.transactionWithdrawal;
      case TransactionType.refund:
        return loc.transactionRefund;
      case TransactionType.platformFee:
        return loc.transactionPlatformFee;
      case TransactionType.adjustment:
        return loc.transactionAdjustment;
    }
  }
}
