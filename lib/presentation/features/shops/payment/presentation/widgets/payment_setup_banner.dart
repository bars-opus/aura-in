// lib/features/shop/dashboard/widgets/payment_setup_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/presentation/features/shops/payment/presentation/screens/payment_settings_screen.dart';
import 'package:nano_embryo/presentation/home/widgets/semantic_container_widget.dart';

class PaymentSetupBanner extends ConsumerWidget {
  final String shopId;
  final String shopName;
  final String shopOwnerId;
  final String shopCountry;

  final bool hasPaymentSetup;
  final String shopCurrencyCode;

  const PaymentSetupBanner({
    super.key,
    required this.shopCountry,
    required this.shopId,
    required this.shopOwnerId,
    required this.shopName,
    required this.hasPaymentSetup,
    required this.shopCurrencyCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (hasPaymentSetup) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => _navigateToPaymentSettings(context),
      child: SemanticContainerWidget(
        content:
            'Connect your payout account to start withdrawing money from your wallet. This could be your mobile money number or your bank account.',
        icon: Icons.warning,
        title: 'Complete payout setup',
        backgroundColor: colorScheme.error.withOpacity(0.1),
        borderColor: colorScheme.error,
        iconColor: colorScheme.error,
        textTheme: theme.textTheme,
      ),
    );
  }

  void _navigateToPaymentSettings(BuildContext context) {
    context.push(
      '/paymentSettingsScreen',
      extra: {
        'shopId': shopId,
        'shopName': shopName,
        'shopOwnerId': shopOwnerId,
        'shopCurrencyCode': shopCurrencyCode,
        'shopCountry': shopCountry,
      },
    );

  }
}
