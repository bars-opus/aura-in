// lib/features/shop/workers/widgets/pending_invite_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/worker_invite.dart';

class PendingInviteTile extends StatelessWidget {
  final WorkerInvite invite;
  final VoidCallback onCancel;
  final VoidCallback onResend;

  const PendingInviteTile({
    super.key,
    required this.invite,
    required this.onCancel,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workerName = invite.worker?.name ?? 'Worker';
    final daysLeft = invite.expiresAt.difference(DateTime.now()).inDays;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: Spacing.md.w, vertical: Spacing.xs.h),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24.r,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(Icons.person_outline, color: theme.colorScheme.primary),
        ),
        title: Text(
          workerName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invitation pending',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.orange,
              ),
            ),
            if (daysLeft > 0)
              Text(
                'Expires in $daysLeft days',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: onResend,
              child: const Text('Resend'),
            ),
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
