// lib/features/dashboard/presentation/widgets/client_card.dart
import 'package:nano_embryo/core/utils/money.dart';
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/clients/client_profile.dart';

class ClientCard extends ConsumerWidget {
  final ClientProfile client;
  final String currencyCode;
  final VoidCallback? onMessageTap;

  const ClientCard({
    super.key,
    required this.client,
    required this.currencyCode,
    this.onMessageTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final String currentUserId = user == null ? '' : user.id;
    return CardInkWell(
      child: InfoRowWidget(
        title: client.displayName,
        subtitle: client.displayName,
        imageUrl: client.avatarUrl ?? '',
        isNotAvatarImage: false,
        iconSize: 40,

        avatarRadius: 45.h,
        titleMaxLines: 1,
        subTitleMaxLines: 1,
        showDivider: false,
        showTrailingArrow: false,

        trailing: Text(
          formatMajorMoney(client.totalSpent, currencyCode, fractionDigits: 0),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        onTap:
            () => context.push(
              '/profileScreen',
              extra: {
                'profileUserId': client.id,
                'currentUserId': currentUserId,
              },
            ),
        bottomWidget: _StatChip(
          icon: Icons.calendar_today_outlined,
          label:
              '${client.totalBookings} visits\n${_getLastBookingText(client.lastBookingAt!)}',
        ),
      ),
    );
  }

  String _getLastBookingText(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${difference.inDays ~/ 7}w ago';
    return '${difference.inDays ~/ 30}m ago';
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Gap(Spacing.xs.w),
        Icon(
          icon,
          size: IconSizes.sm,
          color: colorScheme.onSurface.withOpacity(0.5),
        ),
      ],
    );
  }
}
