// lib/presentation/features/shops/dashboard/presentation/screens/broadcasts_screen.dart
//
// Phase 14 — owner broadcast list view. Mirrors PromotionsScreen layout
// + the Phase 13.1 `_PromotionRow` badge pattern (using status instead
// of source).
//
// Strings are hardcoded EN; localization keys land in Wave 3
// (.../app_en.arb). Each user-facing string here has a matching key
// inventory in 14-PLAN.md for the swap.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/broadcast_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/create_broadcast_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/broadcasts_provider.dart';

class BroadcastsScreen extends ConsumerWidget {
  final String shopId;

  const BroadcastsScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    final broadcastsAsync = ref.watch(broadcastsProvider(shopId));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          loc.broadcastsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(broadcastsProvider(shopId)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: loc.broadcastsFabTooltip,
        icon: const Icon(Icons.add),
        label: Text(loc.broadcastsFabTooltip),
        onPressed: () async {
          final result = await Navigator.of(context).push<(
            String broadcastId,
            int recipientCount
          )?>(
            MaterialPageRoute(
              builder: (_) => CreateBroadcastScreen(shopId: shopId),
            ),
          );
          if (result != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc.broadcastSentToast(result.$2))),
            );
          }
        },
      ),
      body: broadcastsAsync.when(
        loading: () => const Center(child: CircularLoadingIndicator()),
        error: (e, _) => _ErrorState(
          onRetry: () => ref.invalidate(broadcastsProvider(shopId)),
        ),
        data: (broadcasts) {
          if (broadcasts.isEmpty) return const _EmptyState();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(broadcastsProvider(shopId)),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: broadcasts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _BroadcastRow(broadcast: broadcasts[i]),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_outlined,
                size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(loc.broadcastsEmptyTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              loc.broadcastsEmptyBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              loc.broadcastsLoadFailed,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: Text(loc.broadcastsRetry)),
          ],
        ),
      ),
    );
  }
}

class _BroadcastRow extends StatelessWidget {
  final BroadcastDTO broadcast;
  const _BroadcastRow({required this.broadcast});

  /// Awaiting-template tooltip for delivering rows >6h old. Phase 14
  /// SPEC line 170 — auto-retry tooltip until WhatsApp template approval
  /// resolves (typically <24h).
  bool get _showApprovalPendingTooltip {
    if (broadcast.status != BroadcastStatus.delivering) return false;
    return DateTime.now().difference(broadcast.createdAt) >
        const Duration(hours: 6);
  }

  Color _statusColor(ColorScheme scheme) {
    switch (broadcast.status) {
      case BroadcastStatus.pending:
        return scheme.outline;
      case BroadcastStatus.delivering:
        return scheme.tertiary;
      case BroadcastStatus.delivered:
        return scheme.primary;
      case BroadcastStatus.failed:
        return scheme.error;
    }
  }

  String _statusLabel(AppLocalizations loc) {
    switch (broadcast.status) {
      case BroadcastStatus.pending:
        return loc.broadcastStatusPending;
      case BroadcastStatus.delivering:
        return loc.broadcastStatusDelivering;
      case BroadcastStatus.delivered:
        return loc.broadcastStatusDelivered;
      case BroadcastStatus.failed:
        return loc.broadcastStatusFailed;
    }
  }

  String _audienceLabel(AppLocalizations loc) {
    switch (broadcast.audienceType) {
      case BroadcastAudience.allClients:
        return loc.broadcastAudienceAllClients;
      case BroadcastAudience.recent:
        return loc.broadcastAudienceRecent;
      case BroadcastAudience.lapsed:
        return loc.broadcastAudienceLapsed;
      case BroadcastAudience.byService:
        return loc.broadcastAudienceByService;
    }
  }

  /// Compact relative time. Doesn't need a dep — Phase 14 only renders
  /// days / hours / minutes / "just now". intl handles plurals if/when
  /// we localize.
  String _relativeTime() {
    final delta = DateTime.now().difference(broadcast.createdAt);
    if (delta.inMinutes < 1) return 'just now';
    if (delta.inHours < 1) return '${delta.inMinutes}m ago';
    if (delta.inDays < 1) return '${delta.inHours}h ago';
    if (delta.inDays < 30) return '${delta.inDays}d ago';
    final m = (delta.inDays / 30).floor();
    return '${m}mo ago';
  }

  void _showDetail(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(broadcast.subject),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(broadcast.body, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              Text(loc.broadcastAudienceLabelShort(_audienceLabel(loc)),
                  style: theme.textTheme.bodySmall),
              if (broadcast.promotionId != null) ...[
                const SizedBox(height: 4),
                Text(loc.broadcastPromoLabelShort(broadcast.promotionId!),
                    style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: 4),
              Text(loc.broadcastRecipientsLabel(broadcast.recipientCount),
                  style: theme.textTheme.bodySmall),
              if (broadcast.deliveredAt != null) ...[
                const SizedBox(height: 4),
                Text(
                    loc.broadcastDeliveredLabel(
                        broadcast.deliveredAt!.toIso8601String()),
                    style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: 4),
              Text(loc.broadcastStatusLabel(_statusLabel(loc)),
                  style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.broadcastDetailClose),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    final statusColor = _statusColor(colorScheme);

    final statusChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _statusLabel(loc),
        style: theme.textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Card(
      child: InkWell(
        onTap: () => _showDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _showApprovalPendingTooltip
                      ? Tooltip(
                          message: loc.broadcastDeliveringTooltip,
                          child: statusChip,
                        )
                      : statusChip,
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      broadcast.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      broadcast.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.people_outline,
                            size: 14, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${broadcast.recipientCount}',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _relativeTime(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
