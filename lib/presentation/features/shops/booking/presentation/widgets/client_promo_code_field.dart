// lib/presentation/features/shops/booking/presentation/widgets/client_promo_code_field.dart
//
// Phase 13 — checkout promo code surface.
//
// Two paths:
//   1. Auto-apply (on mount): calls validate_and_apply_promo with
//      p_code=NULL. If a silent loyalty/recovery code matches the
//      caller, surfaces a single line-item ("Loyalty reward" /
//      "Welcome back") and reports it via [onApplied]. NEVER displays
//      the code text for silent codes — the client doesn't need it.
//   2. Manual entry: client types a code and taps Apply. Replaces any
//      previously-applied (auto or manual) code with the new one.
//
// All discount math is server-authoritative. The widget passes
// (promotionId, amountOff, newTotal) to the parent screen via the
// [onApplied] callback; the parent re-derives platform fee from the
// discounted new_total and stores promotionId for processPayment.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/money.dart';
import 'package:nano_embryo/core/widgets/feedback/snackbar_widget.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/promotion_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/promotion_model.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/promotions_repository.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

/// Lightweight result snapshot the parent screen reads from
/// [onApplied]. Mirrors [PromoValidation] but adds a source-keyed
/// display label that's already i18n-friendly for the line item.
class AppliedPromo {
  final String promotionId;
  final String code;

  /// Phase 17: int minor units (kobo). Display via `formatMoney(amountOffMinor, currency)`.
  final int amountOffMinor;
  final int newTotalMinor;
  final PromoSource source;

  const AppliedPromo({
    required this.promotionId,
    required this.code,
    required this.amountOffMinor,
    required this.newTotalMinor,
    required this.source,
  });

  /// Source-keyed label shown in the totals line item. Owner-defined
  /// codes show the code text; silent codes show a friendly name.
  String get displayLabel {
    switch (source) {
      case PromoSource.loyalty:
        return 'Loyalty reward';
      case PromoSource.recovery:
        return 'Welcome back';
      case PromoSource.ownerDefined:
        return 'Code: $code';
    }
  }
}

class ClientPromoCodeField extends ConsumerStatefulWidget {
  final String shopId;

  /// Caller identity. Exactly one must be non-null. The widget's
  /// internal RPC calls pass these straight through to the server.
  final String? userId;
  final String? guestProfileId;

  /// Pre-discount booking total. The widget uses this for both the
  /// auto-apply on mount and the manual Apply tap.
  ///
  /// Phase 17: stays `double` for API stability — Phase 17 callers
  /// boundary-convert at the call site (`totalPriceMinor / 100`). The
  /// widget converts back to int via `parseMoneyMinor` before passing
  /// to the validate RPC. Flip to int in a follow-up sweep.
  final double bookingTotal;

  /// Optional service id list — when non-null, the server checks
  /// `service_restriction` against it and rejects codes whose restriction
  /// doesn't overlap. Pass the selected appointment_slot ids.
  final List<String>? serviceIds;

  /// Fires after a successful validate_and_apply_promo. Parent screen
  /// updates `promotionId` / `_discountedTotal` / `_platformFee`. Fires
  /// with null when the field is cleared.
  final ValueChanged<AppliedPromo?> onApplied;

  const ClientPromoCodeField({
    super.key,
    required this.shopId,
    required this.userId,
    required this.guestProfileId,
    required this.bookingTotal,
    required this.onApplied,
    this.serviceIds,
  }) : assert(
          (userId == null) != (guestProfileId == null),
          'Exactly one of userId / guestProfileId must be non-null',
        );

  @override
  ConsumerState<ClientPromoCodeField> createState() =>
      _ClientPromoCodeFieldState();
}

class _ClientPromoCodeFieldState extends ConsumerState<ClientPromoCodeField> {
  final TextEditingController _controller = TextEditingController();
  bool _busy = false;
  AppliedPromo? _applied;
  bool _autoApplyChecked = false;

  @override
  void initState() {
    super.initState();
    // Defer the auto-apply call to after the first frame so we have a
    // valid BuildContext if any error needs surfacing.
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoApply());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _autoApply() async {
    if (_autoApplyChecked) return;
    _autoApplyChecked = true;
    try {
      final repo = ref.read(promotionsRepositoryProvider);
      final result = await repo.validateAndApplyPromo(
        shopId: widget.shopId,
        code: null,
        userId: widget.userId,
        guestProfileId: widget.guestProfileId,
        bookingTotal: widget.bookingTotal,
        serviceIds: widget.serviceIds,
      );
      if (!mounted || result == null) return;
      _applyResult(result);
    } catch (_) {
      // Auto-apply failures are silent — the manual code path stays open.
    }
  }

  Future<void> _applyManual() async {
    if (_busy) return;
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;
    setState(() => _busy = true);
    try {
      final repo = ref.read(promotionsRepositoryProvider);
      final result = await repo.validateAndApplyPromo(
        shopId: widget.shopId,
        code: raw,
        userId: widget.userId,
        guestProfileId: widget.guestProfileId,
        bookingTotal: widget.bookingTotal,
        serviceIds: widget.serviceIds,
      );
      if (!mounted) return;
      if (result == null) {
        Snackbar.error(context, "We couldn't find that code.");
        setState(() => _busy = false);
        return;
      }
      _applyResult(result);
      setState(() => _busy = false);
    } on PromotionException catch (e) {
      if (!mounted) return;
      Snackbar.error(context, e.userMessage);
      setState(() => _busy = false);
    } catch (_) {
      if (!mounted) return;
      Snackbar.error(context, 'Something went wrong. Please try again.');
      setState(() => _busy = false);
    }
  }

  void _applyResult(PromoValidation result) {
    // Phase 17: PromoValidation flips to int kobo in Wave 5.2 (boundary
    // moves to the repository). Until that lands, convert here.
    final applied = AppliedPromo(
      promotionId: result.promotionId,
      code: result.code,
      amountOffMinor: parseMoneyMinor(result.amountOff),
      newTotalMinor: parseMoneyMinor(result.newTotal),
      source: result.source,
    );
    setState(() => _applied = applied);
    widget.onApplied(applied);
  }

  void _clear() {
    _controller.clear();
    setState(() => _applied = null);
    widget.onApplied(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Applied state: show the line item and an X to clear.
    if (_applied != null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.local_offer_outlined,
                size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_applied!.displayLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                  Text(
                    // Phase 17: format int kobo via the single helper.
                    '-${formatMoney(_applied!.amountOffMinor, "")}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: _busy ? null : _clear,
              tooltip: 'Remove code',
            ),
          ],
        ),
      );
    }

    // Default: text field + Apply button.
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Promo code',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onSubmitted: (_) => _applyManual(),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _busy ? null : _applyManual,
          child: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Apply'),
        ),
      ],
    );
  }
}
