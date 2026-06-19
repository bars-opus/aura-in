// lib/features/shop/creation/presentation/screens/shop_creation_dashboard.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nano_embryo/core/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/create_shop_data.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/local_draft_storage.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/shop_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/completion_progress_bar.dart.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/draft_auto_save_indicator.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/edit_shop_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/repository/supabase_shop_creation_repository.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/screens/my_shops_screen.dart';

enum ShopMode { create, edit }

class ShopCreation extends ConsumerStatefulWidget {
  final String? shopId;
  final ShopMode mode;

  const ShopCreation({super.key, this.shopId, this.mode = ShopMode.create});

  @override
  ConsumerState<ShopCreation> createState() => _ShopCreationState();
}

class _ShopCreationState extends ConsumerState<ShopCreation> {
  bool _hasUnsavedChanges = false;
  ShopDraft? _initialDraft;

  @override
  void initState() {
    super.initState();

    if (widget.mode == ShopMode.edit && widget.shopId != null) {
      // Invalidate the cached edit provider so the notifier is recreated and
      // loadShopData() runs fresh on every entry (fixes stale data on re-open).
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ref.invalidate(editShopProvider(widget.shopId!));
        await ref.read(shopCreationProvider.notifier).clearDraft();
      });
    } else {
      // Create mode: capture the (empty) starting state for change detection.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initialDraft = ref.read(shopCreationProvider);
      });
    }
  }

  Future<bool> _showUnsavedChangesDialog(BuildContext context) async {
    final completer = Completer<bool>();
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      maxHeight: 400.h,
      showButtons: false,
      widget: ConfirmationDialog(
        type: ConfirmationType.info,
        title: 'You have unsaved changes. What would you like to do?',
        confirmText: 'Save changes',
        cancelText: 'Leave and discard',
        message: '',
        onConfirm: () async {
          final success = await _saveChanges(
            context,
            ref.read(shopCreationProvider),
          );
          if (context.mounted) Navigator.pop(context); // close the sheet
          completer.complete(success); // allow pop only if save succeeded
        },
        onCancel: () {
          if (context.mounted) Navigator.pop(context); // close the sheet
          completer.complete(true); // allow pop — user chose to discard
        },
      ),
    );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(shopCreationProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sections = CreateShopDataSource.getSettingsSections(context, draft);

    // Check for unsaved changes
    if (_initialDraft != null &&
        _initialDraft != draft &&
        !_hasUnsavedChanges) {
      _hasUnsavedChanges = true;
    }

    // For edit mode, watch the edit state
    final editState =
        widget.mode == ShopMode.edit && widget.shopId != null
            ? ref.watch(editShopProvider(widget.shopId!))
            : null;

    // Capture _initialDraft once, after the edit load finishes (not before).
    // Doing this in initState was too early — the data hadn't arrived yet.
    if (widget.mode == ShopMode.edit &&
        _initialDraft == null &&
        editState != null &&
        !editState.isLoading) {
      _initialDraft = draft;
    }

    // // Show loading if edit data is loading
    // if (editState?.isLoading == true) {
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    // Show error if edit data failed to load
    if (editState?.error != null) {
      debugPrint('EditShop load error: ${editState!.error}');
      return Scaffold(
        body: Center(
          child: ErrorStateWidget(
            subtitle: 'Failed to load shop data. Please try again.',
            title: '',
            onPrimaryAction: () {
              ref.invalidate(editShopProvider(widget.shopId!));
            },
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges) {
          return await _showUnsavedChangesDialog(context);
        }
        return true;
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: colorScheme.neutral,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                editState?.isLoading == true && editState?.draft == null
                    ? 'Initializing shop...'
                    : widget.mode == ShopMode.create
                    ? 'Create Your Shop'
                    : 'Edit Shop',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),

              actions: [
                if (editState?.isLoading == true && editState?.draft == null)
                  Padding(
                    padding: const EdgeInsets.only(right: Spacing.md),
                    child: CircularLoadingIndicator(),
                  ),
              ],
            ),
            body: ListView(
              padding: EdgeInsets.fromLTRB(Spacing.lg.w, 0, Spacing.lg.w, 0),
              children: [
                Gap(Spacing.md.h),
                CompletionProgressBar(
                  completed: draft.completedSectionsCount,
                  total: ShopDraft.totalSections,
                  entityType: 'shop',
                ),
                Gap(Spacing.lg.h),
                ...sections.map((section) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gap(Spacing.md.h),
                      if (section.title.isNotEmpty) ...[
                        Text(
                          section.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                        Gap(Spacing.sm.h),
                      ],
                      CardInkWell(
                        margin: EdgeInsets.only(bottom: Spacing.md.h),
                        onTap: () {},
                        child: Column(
                          children: [
                            ...section.items.map(
                              (config) => SettingsItem(
                                showDivider:
                                    section.items.indexOf(config) <
                                    section.items.length - 1,
                                config: config,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
                Gap(Spacing.md.h),
                AppDivider(),
                Gap(Spacing.xl.h),
                AppButton(
                  elevation: 0,
                  label:
                      widget.mode == ShopMode.edit
                          ? 'Save Changes'
                          : 'Preview Shop',
                  onPressed:
                      widget.mode == ShopMode.edit
                          ? () => _saveChanges(context, draft)
                          : draft.isMinimumViable
                          ? () => context.push('/previewShop', extra: 'create')
                          : () {
                            context.showErrorSnackbar(
                              'Complete your profile info',
                            );
                          },
                  size: ButtonSize.small,
                  width: double.infinity,
                  padding: Spacing.horizontalMd,
                  height: 40.h,
                ),
                Gap(Spacing.md.h),
                if (widget.mode == ShopMode.edit)
                  AppButton(
                    elevation: 0,
                    label: 'Delete Shop',
                    onPressed:
                        widget.shopId == null
                            ? null
                            : () => _showDeleteConfirmation(context),
                    size: ButtonSize.small,
                    width: double.infinity,
                    customColor: colorScheme.error,
                    padding: Spacing.horizontalMd,
                    height: 40.h,
                  ),
                Gap(Spacing.xl.h),
                SemanticContainerWidget(
                  content:
                      'Payout details for withdrawing money from your wallet would be collected on your dashboard after is published',
                  icon: Icons.payment,
                  title: '',
                  backgroundColor: colorScheme.success.withOpacity(0.1),
                  borderColor: colorScheme.success,
                  iconColor: colorScheme.success,
                  textTheme: theme.textTheme,
                ),
                Gap(Spacing.md.h),
                SemanticContainerWidget(
                  content:
                      'Your dashboard and daily appointment schedules would show after your shop is published',
                  icon: Icons.dashboard_outlined,
                  title: '',
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  borderColor: colorScheme.primary,
                  iconColor: colorScheme.primary,
                  textTheme: theme.textTheme,
                ),
                Gap(Spacing.md.h),
                SemanticContainerWidget(
                  content:
                      'You can edit your shop and any other information anytime after publishing.',
                  icon: Icons.warning_amber,
                  title: '',
                  backgroundColor: colorScheme.warning.withOpacity(0.1),
                  borderColor: colorScheme.warning,
                  iconColor: colorScheme.warning,
                  textTheme: theme.textTheme,
                ),
                Gap(Spacing.xl.h),
                Gap(Spacing.xl.h),
              ],
            ),
          ),
          const DraftAutoSaveIndicator(),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      maxHeight: 400.h,
      widget: ConfirmationDialog(
        icon: Icons.delete_forever,
        type: ConfirmationType.warning,
        title: 'Delete Shop?',
        confirmText: 'Delete',
        message:
            'Are you sure you want to delete this shop? This action cannot be undone.',
        onConfirm: () async {
          context.showLoadingSnackbar('Deleting shop...');

          try {
            final repository = ref.read(shopCreationRepositoryProvider);
            await repository.deleteShop(widget.shopId ?? '');

            final profileId = ref.read(currentProfileIdProvider);
            if (profileId != null) {
              final storage = ref.read(localDraftStorageProvider);
              await storage.clearDraft(profileId);
            }

            ScaffoldMessenger.of(context).clearSnackBars();
            ref.read(shopFlashMessageProvider.notifier).state =
                'Shop deleted successfully';
            context.go(RouteNames.myShopsScreen);
          } catch (e) {
            ScaffoldMessenger.of(context).clearSnackBars();
            context.showErrorSnackbar('Failed to delete shop: $e');
          }
        },
      ),
    );
  }

  Future<bool> _saveChanges(BuildContext context, ShopDraft draft) async {
    if (widget.shopId == null) return false;
    if (!draft.isMinimumViable) {
      context.showErrorSnackbar(
        'Please complete all required fields before saving',
      );
      return false;
    }

    // Show loading indicator
    context.showLoadingSnackbar('Saving changes...');

    try {
      final editState = ref.read(editShopProvider(widget.shopId!));
      final pathToUrl = editState.localPathToOriginalUrl;
      final docPathToUrl = editState.localDocPathToOriginalUrl;
      final imageUrlToId = editState.imageUrlToId;
      final docUrlToId = editState.docUrlToId;
      final existingUrls = editState.existingImageUrls;
      final existingDocumentUrls = editState.existingDocumentUrls;
      final currentImagePaths = draft.localImagePaths;
      final currentDocuments = draft.documents;

      // Images whose original URL is no longer in the current path list
      final keptOriginalUrls =
          currentImagePaths
              .map((p) => pathToUrl[p])
              .whereType<String>()
              .toSet();
      final removedImageUrls =
          existingUrls.where((url) => !keptOriginalUrls.contains(url)).toList();

      // Resolve removed URLs → DB ids for reliable PK-based deletion
      final imageIdsToDelete =
          removedImageUrls
              .map((url) => imageUrlToId[url])
              .whereType<String>()
              .toList();

      // Files in the current list that have no mapping are truly new
      final newImageFiles =
          currentImagePaths
              .where((p) => !pathToUrl.containsKey(p))
              .map((p) => File(p))
              .toList();

      // Documents whose original URL is no longer present
      final keptDocUrls =
          currentDocuments
              .map((d) => docPathToUrl[d.file.path])
              .whereType<String>()
              .toSet();
      final removedDocUrls =
          existingDocumentUrls
              .where((url) => !keptDocUrls.contains(url))
              .toList();
      final docIdsToDelete =
          removedDocUrls
              .map((url) => docUrlToId[url])
              .whereType<String>()
              .toList();

      // Documents with no mapping are new additions
      final newDocuments =
          currentDocuments
              .where((d) => !docPathToUrl.containsKey(d.file.path))
              .toList();

      final notifier = ref.read(editShopProvider(widget.shopId!).notifier);
      final success = await notifier.saveChanges(
        newImages: newImageFiles,
        imageIdsToDelete: imageIdsToDelete,
        imagesToDelete: removedImageUrls,
        newDocuments: newDocuments,
        docIdsToDelete: docIdsToDelete,
        documentUrlsToDelete: removedDocUrls,
      );

      ScaffoldMessenger.of(context).clearSnackBars();

      if (success && mounted) {
        _hasUnsavedChanges = false;
        _initialDraft = ref.read(shopCreationProvider);
        context.showSuccessSnackbar('Shop updated successfully');
        return true;
      } else if (mounted) {
        final error = ref.read(editShopProvider(widget.shopId!)).error;
        context.showErrorSnackbar(error ?? 'Failed to update shop');
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      context.showErrorSnackbar('Error: $e');
      return false;
    }

    return false;
  }
}
