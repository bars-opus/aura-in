// lib/presentation/features/shops/dashboard/presentation/screens/business_hours_screen.dart
//
// Tools-tab Business Hours editor. Renders a 7-row weekly grid backed
// by BusinessHoursEditController. Save calls the atomic rebuild RPC;
// Discard re-fetches from server.
//
// Locked correction 6: this screen MUST NOT call hoursProvider or
// touch any creation-flow state. The grep gate in the plan's DoD
// catches accidental regressions.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/feedback/snackbar_widget.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_details_provider.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/business_hours_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

class BusinessHoursScreen extends ConsumerStatefulWidget {
  final String shopId;
  const BusinessHoursScreen({super.key, required this.shopId});

  @override
  ConsumerState<BusinessHoursScreen> createState() =>
      _BusinessHoursScreenState();
}

class _BusinessHoursScreenState extends ConsumerState<BusinessHoursScreen> {
  bool _isSaving = false;

  static const _dayNames = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await ref
          .read(businessHoursEditControllerProvider(widget.shopId).notifier)
          .save();
      if (!mounted) return;
      // Invalidate shop details so any other screen reading them picks
      // up the new hours.
      ref.invalidate(shopDetailsProvider(widget.shopId));
      Snackbar.success(context, 'Hours saved');
      Navigator.of(context).pop();
    } on BusinessHoursException catch (e) {
      if (!mounted) return;
      Snackbar.error(context, e.userMessage);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(businessHoursEditControllerProvider(widget.shopId));
    final notifier = ref
        .read(businessHoursEditControllerProvider(widget.shopId).notifier);
    final theme = Theme.of(context);

    final canSave = !_isSaving && state.hasValue && notifier.isValid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Hours'),
        actions: [
          if (state.hasValue)
            TextButton(
              onPressed: _isSaving ? null : notifier.discard,
              child: const Text('Reset'),
            ),
          IconButton(
            tooltip: 'Save',
            onPressed: canSave ? _save : null,
            icon: _isSaving
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(Spacing.lg.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "We couldn't load your hours.",
                  style: theme.textTheme.titleMedium,
                ),
                Gap(Spacing.md.h),
                ElevatedButton(
                  onPressed: notifier.discard,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (rows) => ListView.separated(
          padding: EdgeInsets.all(Spacing.md.h),
          itemBuilder: (context, i) => _DayRow(
            row: rows[i],
            label: _dayNames[rows[i].dayOfWeek] ?? 'Day ${rows[i].dayOfWeek}',
            onChanged: (opens, closes, closed) => notifier.updateDay(
              rows[i].dayOfWeek,
              opensAt: opens,
              closesAt: closes,
              isClosed: closed,
            ),
          ),
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: rows.length,
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final OpeningHoursDraft row;
  final String label;
  final void Function(String? opens, String? closes, bool? closed) onChanged;

  const _DayRow({
    required this.row,
    required this.label,
    required this.onChanged,
  });

  Future<void> _pickTime(
    BuildContext context, {
    required bool isOpen,
  }) async {
    final initial = TimeOfDay.now();
    final localizations = MaterialLocalizations.of(context);
    final result = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (result == null) return;
    // Use the localizations snapshot captured BEFORE the await to avoid
    // referencing the context after an async gap.
    final formatted = localizations.formatTimeOfDay(result); // e.g. "9:00 AM"
    if (isOpen) {
      onChanged(formatted, null, null);
    } else {
      onChanged(null, formatted, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final invalid = !row.isClosed && _ordering(row.opensAt, row.closesAt) <= 0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm.w,
        vertical: Spacing.sm.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: theme.textTheme.titleSmall),
              ),
              const Text('Closed'),
              Gap(Spacing.sm.w),
              Switch(
                value: row.isClosed,
                onChanged: (v) => onChanged(null, null, v),
              ),
            ],
          ),
          if (!row.isClosed) ...[
            Gap(Spacing.xs.h),
            Row(
              children: [
                Expanded(
                  child: _TimeChip(
                    label: 'Open',
                    value: row.opensAt,
                    onTap: () => _pickTime(context, isOpen: true),
                  ),
                ),
                Gap(Spacing.sm.w),
                Expanded(
                  child: _TimeChip(
                    label: 'Close',
                    value: row.closesAt,
                    onTap: () => _pickTime(context, isOpen: false),
                  ),
                ),
              ],
            ),
            if (invalid) ...[
              Gap(Spacing.xs.h),
              Text(
                'Close time must be after open time.',
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// Returns positive if close > open, zero if equal, negative if close
  /// is before open. Compares as minutes-since-midnight using the same
  /// "HH:MM AM/PM" parser shape the controller uses for validation.
  int _ordering(String open, String close) {
    final o = _toMinutes(open);
    final c = _toMinutes(close);
    if (o == null || c == null) return 1; // can't tell — let it slide
    return c - o;
  }

  int? _toMinutes(String raw) {
    final trimmed = raw.trim().toUpperCase();
    final isAm = trimmed.endsWith('AM');
    final isPm = trimmed.endsWith('PM');
    final stripped = (isAm || isPm)
        ? trimmed.substring(0, trimmed.length - 2).trim()
        : trimmed;
    final parts = stripped.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    var hours24 = h;
    if (isPm && h != 12) hours24 = h + 12;
    if (isAm && h == 12) hours24 = 0;
    return hours24 * 60 + m;
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _TimeChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BorderRadiusTokens.sm),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.md.w,
          vertical: Spacing.sm.h,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outline),
          borderRadius: BorderRadius.circular(BorderRadiusTokens.sm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Gap(Spacing.xs.h),
            Text(value, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}
