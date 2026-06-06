// lib/presentation/features/shops/dashboard/presentation/screens/loyalty_rule_screen.dart
//
// Phase 13 — owner-facing editor for the per-shop loyalty rule.
//
// Save model: explicit Save button, NO debounce / autosave. Matches
// the Phase 12 ClientStickyNoteCard precedent. Loads via
// loyaltyRuleProvider(shopId); on null returns the LoyaltyRuleDTO.draft
// shape (6 visits, 15% off, active). Save calls upsert_loyalty_rule
// via the repository which maps HINT codes to typed exceptions; the
// screen surfaces userMessage via Snackbar.error.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/widgets/feedback/snackbar_widget.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/promotion_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/loyalty_rule_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/promotion_model.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/loyalty_rule_provider.dart';

class LoyaltyRuleScreen extends ConsumerStatefulWidget {
  final String shopId;

  const LoyaltyRuleScreen({super.key, required this.shopId});

  @override
  ConsumerState<LoyaltyRuleScreen> createState() => _LoyaltyRuleScreenState();
}

class _LoyaltyRuleScreenState extends ConsumerState<LoyaltyRuleScreen> {
  int _triggerVisitCount = 6;
  DiscountType _discountType = DiscountType.percentage;
  double _discountValue = 15;
  bool _isActive = true;
  bool _didSeed = false;
  bool _saving = false;

  /// Snapshot of the server-loaded values. Used to enable/disable the
  /// Save button when the form has any pending change.
  LoyaltyRuleDTO? _snapshot;

  bool get _isDirty {
    if (_snapshot == null) return true; // never saved → always dirty
    return _snapshot!.triggerVisitCount != _triggerVisitCount ||
        _snapshot!.discountType != _discountType ||
        _snapshot!.discountValue != _discountValue ||
        _snapshot!.isActive != _isActive;
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(promotionsRepositoryProvider);
      await repo.upsertLoyaltyRule(
        shopId: widget.shopId,
        triggerVisitCount: _triggerVisitCount,
        discountType: _discountType,
        discountValue: _discountValue,
        isActive: _isActive,
      );
      _snapshot = LoyaltyRuleDTO(
        id: _snapshot?.id,
        shopId: widget.shopId,
        triggerVisitCount: _triggerVisitCount,
        discountType: _discountType,
        discountValue: _discountValue,
        isActive: _isActive,
        createdAt: _snapshot?.createdAt,
        updatedAt: DateTime.now(),
      );
      ref.invalidate(loyaltyRuleProvider(widget.shopId));
      if (!mounted) return;
      Snackbar.success(context, 'Loyalty rule saved');
      setState(() => _saving = false);
    } on PromotionException catch (e) {
      if (!mounted) return;
      Snackbar.error(context, e.userMessage);
      setState(() => _saving = false);
    } catch (_) {
      if (!mounted) return;
      Snackbar.error(context, LoyaltyRuleSaveFailedException().userMessage);
      setState(() => _saving = false);
    }
  }

  void _seedFrom(LoyaltyRuleDTO? rule) {
    if (_didSeed) return;
    final src = rule ?? LoyaltyRuleDTO.draft(widget.shopId);
    _triggerVisitCount = src.triggerVisitCount;
    _discountType = src.discountType;
    _discountValue = src.discountValue;
    _isActive = src.isActive;
    _snapshot = rule;
    _didSeed = true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ruleAsync = ref.watch(loyaltyRuleProvider(widget.shopId));

    return Scaffold(
      appBar: AppBar(title: const Text('Loyalty rule')),
      body: ruleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("We couldn't load the loyalty rule.",
                  style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () =>
                    ref.invalidate(loyaltyRuleProvider(widget.shopId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (rule) {
          _seedFrom(rule);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reward every Nth completed booking',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Clients never see their progress. The discount auto-applies '
                  'on the qualifying booking as a surprise reward.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Trigger visit count ────────────────────────────
                Text('Trigger every', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _triggerVisitCount > 2
                          ? () => setState(() => _triggerVisitCount--)
                          : null,
                    ),
                    SizedBox(
                      width: 56,
                      child: Text(
                        '$_triggerVisitCount',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _triggerVisitCount < 50
                          ? () => setState(() => _triggerVisitCount++)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text('completed bookings',
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Discount type ──────────────────────────────────
                Text('Discount type', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<DiscountType>(
                  segments: const [
                    ButtonSegment(
                      value: DiscountType.percentage,
                      label: Text('Percent'),
                    ),
                    ButtonSegment(
                      value: DiscountType.fixed,
                      label: Text('Fixed amount'),
                    ),
                  ],
                  selected: {_discountType},
                  onSelectionChanged: (sel) =>
                      setState(() => _discountType = sel.first),
                ),
                const SizedBox(height: 24),

                // ── Discount value ─────────────────────────────────
                Text(
                  _discountType == DiscountType.percentage
                      ? 'Percent off'
                      : 'Amount off',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _discountValue.toStringAsFixed(
                      _discountType == DiscountType.percentage ? 0 : 2),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixText: _discountType == DiscountType.percentage
                        ? '%'
                        : null,
                  ),
                  onChanged: (s) {
                    final v = double.tryParse(s);
                    if (v != null) setState(() => _discountValue = v);
                  },
                ),
                const SizedBox(height: 24),

                // ── Active toggle ──────────────────────────────────
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  subtitle: const Text(
                      'When off, no loyalty codes are generated for this shop.'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_saving)
                      const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    FilledButton(
                      onPressed: (_isDirty && !_saving) ? _save : null,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
