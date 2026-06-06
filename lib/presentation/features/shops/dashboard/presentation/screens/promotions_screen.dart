// lib/features/dashboard/presentation/screens/promotions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/promotion_model.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/controllers/promotions_controller.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/create_promotion_screen.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/tools/promotion_card.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';


class PromotionsScreen extends ConsumerStatefulWidget {
  final String shopId;

  const PromotionsScreen({super.key, required this.shopId});

  @override
  ConsumerState<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends ConsumerState<PromotionsScreen> {
  /// Phase 13.1 — when false, loyalty + recovery rows are hidden from
  /// the owner's main list. System codes are owner-visible only when
  /// the toggle is on, and never editable.
  bool _showSystemCodes = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(promotionsControllerProviderFamily(
        PromotionsParams(shopId: widget.shopId),
      ).notifier).loadPromotions();
    });
  }

  void _onCreatePromotion() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePromotionScreen(shopId: widget.shopId),
      ),
    ).then((_) {
      ref.read(promotionsControllerProviderFamily(
        PromotionsParams(shopId: widget.shopId),
      ).notifier).refresh();
    });
  }

  void _onEditPromotion(Promotion promotion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePromotionScreen(
          shopId: widget.shopId,
          promotion: promotion,
        ),
      ),
    ).then((_) {
      ref.read(promotionsControllerProviderFamily(
        PromotionsParams(shopId: widget.shopId),
      ).notifier).refresh();
    });
  }

  void _onDeletePromotion(Promotion promotion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Promotion'),
        content: Text('Are you sure you want to delete "${promotion.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(promotionsControllerProviderFamily(
                PromotionsParams(shopId: widget.shopId),
              ).notifier).deletePromotion(promotion.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(promotionsControllerProviderFamily(
      PromotionsParams(shopId: widget.shopId),
    ));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Promotions Manager',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Phase 13.1 — toggle to surface system-generated codes
          // (loyalty / recovery) in the owner's list. Hidden by default
          // because the codes are autonomous and not editable.
          IconButton(
            tooltip: _showSystemCodes
                ? loc.promoListHideSystemCodes
                : loc.promoListShowSystemCodes,
            onPressed: () =>
                setState(() => _showSystemCodes = !_showSystemCodes),
            icon: Icon(
              _showSystemCodes
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: () => ref.read(promotionsControllerProviderFamily(
              PromotionsParams(shopId: widget.shopId),
            ).notifier).refresh(),
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
          ),
          IconButton(
            onPressed: _onCreatePromotion,
            icon: Icon(Icons.add, color: colorScheme.primary),
          ),
        ],
      ),
      body: _buildContent(state),
    );
  }

  Widget _buildContent(PromotionsState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (state.isLoading && state.promotions.isEmpty) {
      return const Center(child: CircularLoadingIndicator());
    }

    if (state.hasError && state.promotions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.w, color: colorScheme.error),
            Gap(Spacing.md.h),
            Text('Failed to load promotions', style: theme.textTheme.titleMedium),
            Gap(Spacing.xs.h),
            Text(state.error!, style: theme.textTheme.bodySmall),
            Gap(Spacing.lg.h),
            ElevatedButton(
              onPressed: () => ref.read(promotionsControllerProviderFamily(
                PromotionsParams(shopId: widget.shopId),
              ).notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Phase 13.1 — filter system codes unless the owner asks to see them.
    final visiblePromotions = state.promotions.where((p) {
      if (_showSystemCodes) return true;
      return !p.isSystemGenerated;
    }).toList();

    if (visiblePromotions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 64.w,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            Gap(Spacing.md.h),
            Text(
              'No Promotions Yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(Spacing.xs.h),
            Text(
              'Create your first promotion to attract more clients',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Gap(Spacing.lg.h),
            ElevatedButton(
              onPressed: _onCreatePromotion,
              child: const Text('Create Promotion'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(promotionsControllerProviderFamily(
        PromotionsParams(shopId: widget.shopId),
      ).notifier).refresh(),
      child: ListView.builder(
        padding: EdgeInsets.all(Spacing.md.h),
        itemCount: visiblePromotions.length,
        itemBuilder: (context, index) {
          final promotion = visiblePromotions[index];
          // Phase 13.1 — wrap with a source badge. System-generated
          // codes also disable edit/delete since the trigger / helper
          // owns their lifecycle.
          return _PromotionRow(
            promotion: promotion,
            onEdit: promotion.isSystemGenerated
                ? null
                : () => _onEditPromotion(promotion),
            onDelete: promotion.isSystemGenerated
                ? null
                : () => _onDeletePromotion(promotion),
          );
        },
      ),
    );
  }
}

/// Phase 13.1 — row wrapper that prefixes a source badge and routes
/// edit/delete callbacks. System-generated rows (loyalty / recovery)
/// pass `null` for onEdit/onDelete to signal read-only.
class _PromotionRow extends StatelessWidget {
  final Promotion promotion;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _PromotionRow({
    required this.promotion,
    required this.onEdit,
    required this.onDelete,
  });

  Color _badgeColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (promotion.source) {
      case PromoSource.loyalty:
        return scheme.primary;
      case PromoSource.recovery:
        return scheme.tertiary;
      case PromoSource.ownerDefined:
        return scheme.secondary;
    }
  }

  String _badgeText(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    switch (promotion.source) {
      case PromoSource.loyalty:
        return loc.promoSourceLoyalty;
      case PromoSource.recovery:
        return loc.promoSourceRecovery;
      case PromoSource.ownerDefined:
        return loc.promoSourceOwner;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.xs.w,
            vertical: Spacing.xs.h,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _badgeColor(context).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _badgeText(context),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _badgeColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (promotion.isSystemGenerated) ...[
                const SizedBox(width: 8),
                Text(
                  loc.promoSourceAutoGeneratedReadOnly,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        PromotionCard(
          promotion: promotion,
          onEdit: onEdit ?? () {},
          onDelete: onDelete ?? () {},
        ),
      ],
    );
  }
}
