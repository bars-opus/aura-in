// lib/features/dashboard/presentation/screens/promotions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
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

    if (state.promotions.isEmpty) {
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
        itemCount: state.promotions.length,
        itemBuilder: (context, index) {
          final promotion = state.promotions[index];
          return PromotionCard(
            promotion: promotion,
            onEdit: () => _onEditPromotion(promotion),
            onDelete: () => _onDeletePromotion(promotion),
          );
        },
      ),
    );
  }
}
