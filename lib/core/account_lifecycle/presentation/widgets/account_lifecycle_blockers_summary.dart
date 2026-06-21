import 'package:flutter/material.dart';
import 'package:nano_embryo/core/account_lifecycle/config/account_lifecycle_texts.dart';
import 'package:nano_embryo/core/account_lifecycle/data/account_lifecycle_models.dart';
import 'package:nano_embryo/presentation/home/widgets/semantic_container_widget.dart';

class AccountLifecycleBlockersSummary extends StatelessWidget {
  final AccountLifecycleBlockers blockers;
  final AccountLifecycleTexts texts;

  const AccountLifecycleBlockersSummary({
    super.key,
    required this.blockers,
    required this.texts,
  });

  @override
  Widget build(BuildContext context) {
    if (!blockers.hasBlockers) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final rows = <String>[
      if (blockers.activeBookings > 0)
        texts.blockerActiveBookings(blockers.activeBookings),
      if (blockers.ownedShopActiveBookings > 0)
        texts.blockerOwnedShopActiveBookings(blockers.ownedShopActiveBookings),
      if (blockers.activeOrders > 0)
        texts.blockerActiveOrders(blockers.activeOrders),
      if (blockers.ownedShopActiveOrders > 0)
        texts.blockerOwnedShopActiveOrders(blockers.ownedShopActiveOrders),
      if (blockers.activeWithdrawals > 0)
        texts.blockerActiveWithdrawals(blockers.activeWithdrawals),
    ];

    return SemanticContainerWidget(
      content: rows.join('\n'),
      icon: Icons.lock_clock_outlined,
      title: texts.blockersTitle,
      backgroundColor: colorScheme.error.withOpacity(0.1),
      borderColor: colorScheme.error,
      iconColor: colorScheme.error,
      textTheme: theme.textTheme,
    );
  }
}
