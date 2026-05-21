import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class RegionInfoCard extends StatelessWidget {
  final String country;
  final String recommendedProvider;

  const RegionInfoCard({super.key, 
    required this.country,
    required this.recommendedProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final providerName =
        recommendedProvider == 'stripe' ? 'Stripe' : 'Paystack';
    final providerIcon =
        recommendedProvider == 'stripe'
            ? Icons.credit_card
            : Icons.account_balance_wallet;

    return SemanticContainerWidget(
      content:
          'Based on your location, we recommend using $providerName '
          'for payment processing.',
      icon: providerIcon,
      title: 'Payment Provider for $country',
      backgroundColor: colorScheme.primary.withOpacity(0.1),
      borderColor: colorScheme.primary,
      iconColor: colorScheme.primary,
      textTheme: theme.textTheme,
    );
  }
}
