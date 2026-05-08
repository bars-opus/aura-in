// lib/features/wallet/presentation/screens/wallet_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/todays_view.dart';
import 'package:nano_embryo/presentation/features/shops/payment/presentation/widgets/payment_setup_banner.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/presentation/providers/payment_setup_provider.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/presentation/widgets/transaction_list_item.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/presentation/widgets/wallet_balance_card.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/presentation/widgets/withdrawal_sheet.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/providers/wallet_providers.dart';

class WalletScreen extends ConsumerStatefulWidget {
  final String shopId;
  final String shopName;
  final String shopOwnerId;
  final String shopCountry;
  final String shopCurrencyCode;

  const WalletScreen({
    Key? key,
    required this.shopId,
    required this.shopOwnerId,
    required this.shopCurrencyCode,
    required this.shopCountry,
    required this.shopName,
  }) : super(key: key);

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Watch wallet data
    final walletAsync = ref.watch(shopWalletProvider(widget.shopId));
    final transactionsAsync = ref.watch(
      walletTransactionsProvider(shopId: widget.shopId, limit: 20),
    );

    // Watch real-time payment setup status
    final paymentSetupAsync = ref.watch(
      paymentSetupStatusProvider(widget.shopId),
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(shopWalletProvider(widget.shopId));
            ref.invalidate(walletTransactionsProvider(shopId: widget.shopId));
            ref.invalidate(paymentSetupStatusProvider(widget.shopId));
          },
          child: CustomScrollView(
            slivers: [
              // Payment Setup Banner - Shows/Hides in real-time
              SliverToBoxAdapter(
                child: paymentSetupAsync.when(
                  data: (hasPaymentSetup) {
                    // Only show banner if no payment setup exists
                    if (!hasPaymentSetup) {
                      return PaymentSetupBanner(
                        shopId: widget.shopId,
                        shopOwnerId: widget.shopOwnerId,
                        shopCurrencyCode: widget.shopCurrencyCode,
                        shopName: widget.shopName,
                        hasPaymentSetup: false,
                        shopCountry: widget.shopCountry,
                      );
                    }
                    return GestureDetector(
                      onTap: () {
                        context.push(
                          '/paymentSettingsScreen',
                          extra: {
                            'shopId': widget.shopId,
                            'shopName': widget.shopName,
                            'shopOwnerId': widget.shopOwnerId,
                            'shopCurrencyCode': widget.shopCurrencyCode,
                            'shopCountry': widget.shopCountry,
                          },
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: Spacing.lg,
                          bottom: Spacing.sm,
                        ),
                        child: SemanticContainerWidget(
                          content:
                              'Kindly wait for the payment to finish processing and return to your app to generate your appointment',
                          icon: Icons.monetization_on,
                          title: '',
                          backgroundColor: colorScheme.primary.withOpacity(0.1),
                          borderColor: colorScheme.primary,
                          iconColor: colorScheme.primary,
                          textTheme: theme.textTheme,
                        ),
                      ),
                    );
                    // const SizedBox.shrink();
                  },
                  loading:
                      () =>
                          const SizedBox.shrink(), // Don't show anything while loading
                  error: (error, stack) {
                    print('Error checking payment setup: $error');
                    return const SizedBox.shrink();
                  },
                ),
              ),

              // Wallet Balance Card
              SliverToBoxAdapter(
                child: walletAsync.when(
                  data:
                      (wallet) => WalletBalanceCard(
                        balance: wallet.balance,
                        totalEarned: wallet.totalEarned,
                        totalWithdrawn: wallet.totalWithdrawn,
                        onWithdraw: () {
                          BottomSheetUtils.showDocumentationBottomSheet(
                            padding: Spacing.md,
                            context: context,
                            widget: WithdrawalSheet(
                              shopId: widget.shopId,
                              availableBalance: wallet.balance,
                              onSuccess: () {
                                // Invalidate all relevant providers to refresh data
                                ref.invalidate(
                                  shopWalletProvider(widget.shopId),
                                );
                                ref.invalidate(
                                  walletTransactionsProvider(
                                    shopId: widget.shopId,
                                  ),
                                );
                                ref.invalidate(
                                  paymentSetupStatusProvider(widget.shopId),
                                );
                              },
                              shopCurrency: widget.shopCurrencyCode,
                            ),
                          );
                        },

                        // => _showWithdrawalSheet(wallet.balance),
                      ),
                  loading:
                      () => Padding(
                        padding: EdgeInsets.symmetric(vertical: Spacing.xl),
                        child: ShopSchimmerSkeleton(height: 250.h, raduis: 20),
                      ),
                  error:
                      (error, stack) => Center(
                        child: ErrorStateWidget(
                          compact: true,
                          subtitle: 'Error loading wallet: $error',
                          title: '',
                          showDetails: true,
                          errorDetails: 'Error loading wallet: $error',
                        ),
                      ),
                ),
              ),

              // Quick Stats Section
              SliverToBoxAdapter(child: TodaysView(shopId: widget.shopId)),

              // Transactions Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.md.w,
                    vertical: Spacing.sm.h,
                  ),
                  child: Text(
                    'Recent Transactions',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),

              // Transactions List
              transactionsAsync.when(
                data:
                    (transactions) => SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final transaction = transactions[index];
                        return TransactionListItem(transaction: transaction);
                      }, childCount: transactions.length),
                    ),
                loading:
                    () => const SliverFillRemaining(
                      child: Center(child: CircularLoadingIndicator()),
                    ),
                error:
                    (error, stack) => SliverFillRemaining(
                      child: Center(
                        child: Text('Error loading transactions: $error'),
                      ),
                    ),
              ),
              SliverToBoxAdapter(child: Gap(Spacing.xxl)),
            ],
          ),
        ),
      ),
    );
  }
}
