// lib/wallet/presentation/widgets/dead_letter_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/wallet/data/models/withdrawal_request_model.dart';
import 'package:nano_embryo/wallet/providers/dead_letter_withdrawals_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DeadLetterBanner extends ConsumerStatefulWidget {
  const DeadLetterBanner({required this.shopId, super.key});
  final String shopId;

  @override
  ConsumerState<DeadLetterBanner> createState() => _DeadLetterBannerState();
}

class _DeadLetterBannerState extends ConsumerState<DeadLetterBanner> {
  bool _expanded = false;

  Future<void> _contactSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@nanoembryo.app',
      queryParameters: {
        'subject': 'Withdrawal needs review',
        'body':
            'My withdrawal is stuck and needs manual review. Shop ID: ${widget.shopId}',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(deadLetterWithdrawalsProvider(widget.shopId));
    final list = async.valueOrNull ?? const <WithdrawalRequestModel>[];
    if (list.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final total = list.fold<double>(0, (sum, w) => sum + w.amount);
    const currency = 'GHS';

    return Material(
      color: cs.tertiaryContainer,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: cs.onTertiaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Withdrawal needs review',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: cs.onTertiaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          list.length == 1
                              ? '$currency ${total.toStringAsFixed(2)} stuck — tap for details'
                              : '$currency ${total.toStringAsFixed(2)} stuck across ${list.length} withdrawals — tap for details',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onTertiaryContainer),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: cs.onTertiaryContainer,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 12),
                Divider(
                    color: cs.onTertiaryContainer.withValues(alpha: 0.2),
                    height: 1),
                const SizedBox(height: 12),
                ...list.map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _DeadLetterRow(withdrawal: w, currency: currency),
                    )),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonal(
                    onPressed: _contactSupport,
                    child: const Text('Contact support'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DeadLetterRow extends StatelessWidget {
  const _DeadLetterRow({required this.withdrawal, required this.currency});
  final WithdrawalRequestModel withdrawal;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final d = withdrawal.updatedAt;
    final fmtDate =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final shortId = withdrawal.id.length >= 8
        ? withdrawal.id.substring(0, 8)
        : withdrawal.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• $currency ${withdrawal.amount.toStringAsFixed(2)} — $fmtDate — #$shortId',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onTertiaryContainer,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (withdrawal.deadLetterReason != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 2),
            child: Text(
              'Reason: ${withdrawal.deadLetterReason}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onTertiaryContainer.withValues(alpha: 0.85),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
