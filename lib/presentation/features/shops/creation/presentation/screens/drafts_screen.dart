// lib/features/shop/creation/presentation/screens/drafts_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/app.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/core/widgets/buttons/app_icon_button.dart';
import 'package:nano_embryo/core/widgets/info_row_widget.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/local_draft_storage.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/draft_preview.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/drafts_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';
import 'dart:io';
import 'shop_creation.dart';

class DraftsScreen extends ConsumerStatefulWidget {
  const DraftsScreen({super.key});

  @override
  ConsumerState<DraftsScreen> createState() => _DraftsScreenState();
}

class _DraftsScreenState extends ConsumerState<DraftsScreen> {
  @override
  Widget build(BuildContext context) {
    final draftPreview = ref.watch(draftsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
      ),
      body:
          draftPreview == null
              ? _buildNoDraft()
              : _buildDraftPreview(draftPreview, theme),
    );
  }

  Widget _buildNoDraft() {
    return Center(
      child: EmptyStateWidget(
        subtitle: 'Start creating your first shop',
        title: 'No draft in progress',
        icon: Icons.storefront_rounded,
        actionLabel: 'Create shop',
        onAction: () {
          context.push('/shopCreation');
        },
      ),
    );
  }

  Widget _buildDraftPreview(DraftPreview draft, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardInkWell(
            margin: const EdgeInsets.all(0),
            elevation: 0,
            padding: const EdgeInsets.all(0),
            onTap: () {},
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: theme.dividerColor, width: .2),
                  ),
                  child: Column(
                    children: [
                      // Cover Image or Placeholder
                      if (draft.coverImagePath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16.r),
                          ),
                          child: Image.file(
                            File(draft.coverImagePath!),
                            height: 150.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          height: 120.h,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16.r),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.storefront,
                              size: 60.sp,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),

                      Padding(
                        padding: EdgeInsets.all(Spacing.md.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Shop Name and Type
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    draft.shopName ?? 'Unnamed Shop',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onBackground,
                                    ),
                                  ),
                                ),
                                if (draft.shopType != null)
                                  MiniContainerIndicator(
                                    color: Colors.blue,
                                    text: draft.shopType!,
                                  ),
                              ],
                            ),
                            Text(
                              'Completion',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Gap(Spacing.md),
                            // Progress Bar
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4.r),
                                    child: LinearProgressIndicator(
                                      value: draft.completionPercentage,
                                      backgroundColor: theme.dividerColor
                                          .withOpacity(.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getProgressColor(
                                          draft.completionPercentage,
                                          theme.colorScheme,
                                        ),
                                      ),
                                      minHeight: 8.h,
                                    ),
                                  ),
                                ),
                                Gap(Spacing.md.w),
                                Text(
                                  '${draft.completedSections}/${draft.totalSections}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),

                            Gap(Spacing.sm.h),

                            // Last Updated
                            InfoRowWidget(
                              title: draft.formattedLastUpdated,
                              titleStyle: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onBackground,

                                // fontWeight: FontWeight.w500,
                              ),
                              subtitle: 'Last edited',
                              icon: Icons.storefront,
                              iconSize: 0,
                              showAvatar: false,
                              showDivider: false,
                              showTrailingArrow: true,
                              disableTrailing: false,
                              trailing: AppIconButton(
                                icon: Icons.delete_outline,
                                onPressed: () => _confirmDeleteDraft(context),
                                // tooltip: 'Delete draft',
                              ),
                            ),

                            Gap(Spacing.lg.h),

                            // Continue Button
                            AppButton(
                              elevation: 0,
                              label: 'Continue Editing',
                              onPressed: _continueEditing,
                              size: ButtonSize.small,
                              width: double.infinity,
                              padding: Spacing.horizontalMd,
                              height: 40.h,
                              // AppButton(
                              //   label: 'Continue Editing',
                              //   onPressed: _continueEditing,
                              // type: AppButtonType.primary,
                              // icon: Icons.edit,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Gap(Spacing.xs),
          SemanticContainerWidget(
            content:
                'Add at least one service to continue. You can add more later.',
            icon: Icons.info_outline,
            title: 'Continue where you left off',
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            borderColor: colorScheme.primary,
            iconColor: colorScheme.primary,
            textTheme: theme.textTheme,
          ),
          // Divider with OR
          Gap(Spacing.xl.h),

          // Start New Shop Button
          CardInkWell(
            elevation: 0,
            padding: const EdgeInsets.all(Spacing.md),
            onTap: () {},
            child: InfoRowWidget(
              subtitle: 'Starting a new shop will replace your current draft',
              title: 'Start New Shop',
              icon: Icons.add,
              avatarRadius: 25.h,
              onTap: () {
                BottomSheetUtils.showDocumentationBottomSheet(
                  context: context,
                  widget: ConfirmationDialog(
                    type: ConfirmationType.warning,
                    title: 'Start New Shop?',
                    confirmText: 'Continue',
                    message:
                        'This will replace your current draft progress. Are you sure you want to continue?',
                    onConfirm: () {
                      final profileId = ref.read(currentProfileIdProvider);
                      final storage = ref.read(localDraftStorageProvider);
                      
                      if (storage != null && profileId != null) {
                        final draft = storage.loadDraft(profileId);
                        print('🔍 TEST: draft content=${draft?.shopName}');
                      }

                      // Navigator.pop(context, true);
                      // _startNewShop();
                    },
                  ),
                );
              },

              //  _confirmStartNew,

              // context.push('/shopCreation'),
              showAvatar: false,
              showTrailingArrow: true,
              showDivider: false,
            ),
          ),

          // AppButton(
          //   elevation: 0,
          //   label: 'Start New Shop',
          //   onPressed: _confirmStartNew,

          //   size: ButtonSize.small,
          //   width: double.infinity,
          //   padding: Spacing.horizontalMd,
          //   customColor: Colors.grey,
          //   height: 40.h,

          //   // type: AppButtonType.outline,
          //   // icon: Icons.add_business,
          // ),
          Gap(Spacing.md.h),

          // SemanticContainerWidget(
          //   content: 'Starting a new shop will replace your current draft',
          //   icon: Icons.warning,
          //   title: 'Continue where you left off',
          //   backgroundColor: Colors.orange.withOpacity(0.1),
          //   borderColor: Colors.orange,
          //   iconColor: Colors.orange,
          //   textTheme: theme.textTheme,
          // ),

          // Info text
          // Center(
          //   child: Text(
          //     'Starting a new shop will replace your current draft',
          //     style: theme.textTheme.bodySmall?.copyWith(
          //       color: theme.colorScheme.onSurface.withOpacity(0.5),
          //     ),
          //     textAlign: TextAlign.center,
          //   ),
          // ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage, ColorScheme colorScheme) {
    if (percentage >= 0.7) {
      return Colors.green; // 70% or more - Green
    } else if (percentage >= 0.4) {
      return Colors.orange; // 40% to 69% - Orange
    } else {
      return colorScheme.primary; // Less than 40% - Primary color
    }
  }

  Future<void> _confirmDeleteDraft(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Draft?'),
            content: const Text(
              'Are you sure you want to delete this draft? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await ref.read(draftsProvider.notifier).clearDraft();
      if (mounted) {
        context.showSuccessSnackbar('Draft deleted');
      }
    }
  }

  // Future<void> _confirmStartNew() async {
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder:
  //         (ctx) => AlertDialog(
  //           title: const Text('Start New Shop?'),
  //           content: const Text(
  //             'This will replace your current draft progress. Are you sure you want to continue?',
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(ctx, false),
  //               child: const Text('Cancel'),
  //             ),
  //             TextButton(
  //               onPressed: () => Navigator.pop(ctx, true),
  //               style: TextButton.styleFrom(foregroundColor: Colors.red),
  //               child: const Text('Start New'),
  //             ),
  //           ],
  //         ),
  //   );

  // if (confirmed == true) {
  //   _startNewShop();
  // }
  // }

  void _continueEditing() {
    context.push('/shopCreation');
  }

  void _startNewShop() async {
    // Clear existing draft
    await ref.read(draftsProvider.notifier).clearDraft();

    // Initialize new empty draft
    final notifier = ref.read(shopCreationProvider.notifier);
    await notifier.clearDraft(); // This resets to empty with profileId

    // Navigate to creation screen
    if (mounted) {
      context.push('/shopCreation');
    }
  }
}
