// lib/features/wallet/presentation/widgets/wallet_balance_card.dart
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class WalletBalanceCard extends StatelessWidget {
  final double balance;
  final double totalEarned;
  final double totalWithdrawn;
  final VoidCallback onWithdraw;
  final bool isLoading;

  const WalletBalanceCard({
    Key? key,
    required this.balance,
    required this.totalEarned,
    required this.totalWithdrawn,
    required this.onWithdraw,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return ShopSchimmerSkeleton(height: 180.h);
    }

    return Container(
      padding: EdgeInsets.all(Spacing.lg.w),
      margin: EdgeInsets.symmetric(vertical: Spacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.2, 0.9],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Background subtle pattern (optional)
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.02),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -30,
            right: 30,
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      AppIconButton(
                        size: 35,
                        iconSize: 20,
                        icon: Icons.wallet,
                        iconColor: Colors.brown.shade800,
                        backgroundColor: Colors.amber.shade300,
                      ),

                      Gap(Spacing.sm.w),
                      Text(
                        'Wallet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Wallet label and balance
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        children: [
                          TextSpan(
                            text: 'Available Balance\n',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          TextSpan(
                            text: 'GHS ${balance.toStringAsFixed(2)}',
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 22.sp,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // // Card number placeholder
              // Gap(Spacing.md.h),
              Gap(Spacing.md.h),
              AppButton(
                height: 35.h,
                label: 'Withdraw Funds',
                onPressed: onWithdraw,
                padding: Spacing.horizontalMd,
                variant: ButtonVariant.outline,
                size: ButtonSize.small,
                width: double.infinity,
                textColor: Colors.white,
                customColor: Colors.transparent,
                outlineColor: Colors.white.withOpacity(0.5),
              ),
              Gap(Spacing.lg.h),

              // Stats row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL EARNED',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white.withOpacity(0.6),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'GHS ${totalEarned.toStringAsFixed(2)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'TOTAL WITHDRAWN',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white.withOpacity(0.6),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'GHS ${totalWithdrawn.toStringAsFixed(2)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Gap(Spacing.md.h),

              // Withdraw button
            ],
          ),
        ],
      ),
    );
  }
}
