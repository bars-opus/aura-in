// lib/features/dashboard/presentation/widgets/client_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/profile/widgets/profile_header.dart';
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/clients/client_profile.dart';

class ClientCard extends ConsumerWidget {
  final ClientProfile client;
  final VoidCallback? onMessageTap;

  const ClientCard({super.key, required this.client, this.onMessageTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final String currentUserId = user == null ? '' : user.id;
    return GestureDetector(
      onTap:
          () => context.push(
            '/profileScreen',
            extra: {
              'profileUserId': client.id,
              'currentUserId': currentUserId ?? '',
            },
          ),
      child: Column(
        children: [
          ProfileHeader(
            mode: ProfileHeaderMode.compact,
            displayName: client.displayName,
            userId: client.id,
            avatarUrl: client.avatarUrl,
            bio: "@${client.username}",

            enableHero: false,
            onProfileNavigatePressed:
                () => context.push(
                  '/profileScreen',
                  extra: {
                    'profileUserId': client.id,
                    'currentUserId': currentUserId ?? '',
                  },
                ),
          ),
          Gap(Spacing.sm.h),
          Padding(
            padding: EdgeInsets.only(left: Spacing.xl + Spacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatChip(
                  icon: Icons.attach_money,
                  label: '\$${client.totalSpent.toStringAsFixed(0)}',
                ),
                _StatChip(
                  icon: Icons.calendar_today_outlined,
                  label:
                      '${client.totalBookings} visits\n${_getLastBookingText(client.lastBookingAt!)}',
                ),
              ],
            ),
          ),
          Gap(Spacing.sm),
          AppDivider(),
          Gap(Spacing.md),
        ],
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
