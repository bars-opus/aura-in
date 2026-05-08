// lib/features/wallet/presentation/widgets/transaction_list_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/data/models/wallet_transaction_model.dart';


class TransactionListItem extends StatelessWidget {
  final WalletTransactionModel transaction;

  const TransactionListItem({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isCredit = transaction.isCredit;
    final icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
    final iconColor = isCredit ? Colors.green : Colors.red;
    final amountColor = isCredit ? Colors.green : Colors.red;
    final amountPrefix = isCredit ? '+' : '-';

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.xs.h,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            // Show transaction details
          },
          child: Container(
            padding: EdgeInsets.all(Spacing.md.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24.w),
                ),
                Gap(Spacing.md.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTransactionTitle(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gap(Spacing.xs.h),
                      Text(
                        _formatDate(transaction.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$amountPrefix GHS ${transaction.amount.abs().toStringAsFixed(2)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: amountColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTransactionTitle() {
    switch (transaction.type) {
      case TransactionType.deposit:
        return 'Deposit Received';
      case TransactionType.servicePayment:
        return 'Service Payment';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.platformFee:
        return 'Platform Fee';
      case TransactionType.adjustment:
        return 'Adjustment';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return 'Today, ${_formatTime(date)}';
    } else if (dateDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year}, ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $period';
  }
}
