// lib/features/freelancer/creation/presentation/screens/freelancer_creation_dashboard.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/app_divider.dart';
import 'package:nano_embryo/core/widgets/card_inkwell.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/data/create_freelancer_data.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/domain/models/freelancer_draft.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/edit_freelancer_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/repositories/supabase_freelancer_repository.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_creation_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/models/freelancer_details_dto.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/models/freelancer_edit_data.dart';
import 'package:nano_embryo/presentation/features/freelancer/domain/usecases/publish_freelancer_usecase.dart';
import 'package:nano_embryo/presentation/features/settings/models/settings_config.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/completion_progress_bar.dart.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/draft_auto_save_indicator.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/section_status_indicator.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/draft_context_provider.dart';

enum FreelancerMode { create, edit }

/// Main dashboard for freelancer creation
class FreelancerCreationDashboard extends ConsumerStatefulWidget {
  final String? freelancerId;
  final String? userId;
  final FreelancerMode mode;
  final FreelancerEditData? existingFreelancer;
  const FreelancerCreationDashboard({
    super.key,
    this.freelancerId,
    this.userId,
    this.mode = FreelancerMode.create,
    this.existingFreelancer,
  });

  @override
  ConsumerState<FreelancerCreationDashboard> createState() =>
      _FreelancerCreationDashboardState();
}

class _FreelancerCreationDashboardState
    extends ConsumerState<FreelancerCreationDashboard> {
  bool _isPublishing = false;
  bool _hasUnsavedChanges = false;
  late ProviderContainer _container;

  // Tracks the resolved freelancer ID after auto-detect; null until resolved.
  String? _resolvedFreelancerId;
  FreelancerMode _resolvedMode = FreelancerMode.create;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _container = ProviderScope.containerOf(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _resolvedFreelancerId = widget.freelancerId;
    _resolvedMode = widget.mode;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Auto-detect existing freelancer when navigating from profile screen
      // (userId passed, mode == create, no freelancerId yet).
      if (widget.mode == FreelancerMode.create &&
          widget.freelancerId == null &&
          widget.userId != null) {
        final repository = ref.read(freelancerRepositoryProvider);
        final existing = await repository.getFreelancerByUserId(widget.userId!);
        if (!mounted) return;
        if (existing != null) {
          setState(() {
            _resolvedFreelancerId = existing.id;
            _resolvedMode = FreelancerMode.edit;
          });
          // Trigger the edit provider to load full data.
          ref.read(editFreelancerProvider(existing.id).notifier);
        }
      } else if (widget.mode == FreelancerMode.edit &&
          widget.existingFreelancer != null) {
        _loadEditDataIntoDraft(widget.existingFreelancer!);
      } else if (widget.mode == FreelancerMode.edit &&
          widget.freelancerId != null) {
        ref.read(editFreelancerProvider(widget.freelancerId!).notifier);
      }

      ref.read(draftContextProvider.notifier).state = DraftContext.freelancer;
    });
  }

  /// Convert FreelancerEditData to draft and load into provider
  void _loadEditDataIntoDraft(FreelancerEditData data) {
    final draft = FreelancerDraft(
      freelancerId: data.profile.id,
      userId: null,
      name: data.profile.name,
      bio: data.profile.bio,
      terms: data.profile.terms,
      profileImagePath: data.profile.profileImageUrl,
      specialties: data.profile.specialties,
      freelancerType: data.profile.freelancerType?.name,
      freelancerTypes: data.profile.freelancerTypes.map((t) => t.name).toList(),
      toolIds: data.toolIds,
      baseLatitude: data.profile.baseLatitude,
      baseLongitude: data.profile.baseLongitude,
      travelRadiusKm: data.profile.travelRadiusKm,
      canTravel: data.profile.canTravel,
      services: data.services,
      openingHours: data.openingHours,
      localImagePaths: [], // Images already exist in storage
      documents: data.documents,
      contacts: data.contacts,
      socialLinks: data.socialLinks,
      awards: data.awards,
      subaccountId: data.profile.subaccountId,
      transferRecipientId: data.profile.transferRecipientId,
      autoAcceptBookings: data.profile.autoAcceptBookings,
      maxBookingsPerDay: data.profile.maxBookingsPerDay,
      bufferMinutesBetweenBookings: data.profile.bufferMinutesBetweenBookings,
    );

    ref.read(freelancerCreationProvider.notifier).loadExistingFreelancer(draft);
  }

  @override
  Widget build(BuildContext context) {
    // Re-assert freelancer context every time this dashboard is shown. initState
    // runs only once, so after a detour into shop creation (whose dispose resets
    // the flag to shop) the context would otherwise stay wrong when we pop back.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(draftContextProvider) != DraftContext.freelancer) {
        ref.read(draftContextProvider.notifier).state = DraftContext.freelancer;
      }
    });
    final draft = ref.watch(freelancerCreationProvider);
    final editState =
        _resolvedMode == FreelancerMode.edit && _resolvedFreelancerId != null
            ? ref.watch(editFreelancerProvider(_resolvedFreelancerId!))
            : null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sections = CreateFreelancerDataSource.getSettingsSections(
      context,
      draft,
    );

    // Track unsaved changes
    ref.listen(freelancerCreationProvider, (previous, next) {
      if (previous != next && mounted) {
        setState(() {
          _hasUnsavedChanges = true;
        });
      }
    });

    // Show loading if edit data is loading
    // if (editState?.isLoading == true) {
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    // Show error if edit data failed to load
    if (editState?.error != null) {
      return Scaffold(
        body: Center(
          child: ErrorStateWidget(
            subtitle:
                editState!.error ?? 'Something went wrong. Please try again.',
            title: '',
            onPrimaryAction: () {
              if (_resolvedFreelancerId != null) {
                ref.invalidate(editFreelancerProvider(_resolvedFreelancerId!));
              }
            },
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges) {
          return await _showUnsavedChangesDialog(context, draft);
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
                    ? 'Initializing freelancer profile...'
                    : _resolvedMode == FreelancerMode.edit
                    ? 'Edit Freelancer Profile'
                    : 'Become a Freelancer',
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
                  total: FreelancerDraft.totalSections,
                  entityType: 'freelancer',
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
                      _resolvedMode == FreelancerMode.edit
                          ? 'Save Changes'
                          : 'Preview Profile',
                  onPressed:
                      _resolvedMode == FreelancerMode.edit
                          ? (_isPublishing ? null : () => _saveChanges(draft))
                          : (_isPublishing
                              ? null
                              : (draft.isMinimumViable
                                  ? () {
                                    final currentDraft = ref.read(
                                      freelancerCreationProvider,
                                    );
                                    context.push(
                                      '/freelancerPreviewScreen',
                                      extra: {
                                        'mode': FreelancerMode.create,
                                        'draft': currentDraft,
                                      },
                                    );
                                  }
                                  : () {
                                    context.showErrorSnackbar(
                                      'Complete your profile info',
                                    );
                                  })),

                  size: ButtonSize.small,
                  width: double.infinity,
                  padding: Spacing.horizontalMd,
                  height: 40.h,
                ),
                Gap(Spacing.xl.h),
                SemanticContainerWidget(
                  content:
                      'Payout details for withdrawing money from your wallet would be collected after profile approval',
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
                      'Your dashboard and daily appointment schedules would show after your profile is published',
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
                      'You can edit your profile and any other information anytime after publishing.',
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
          // Loading overlay
          // if (_isPublishing)
          //   Container(
          //     color: Colors.black.withOpacity(0.5),
          //     child: const Center(child: CircularProgressIndicator()),
          //   ),
        ],
      ),
    );
  }

  /// Show unsaved changes dialog when user tries to go back
  Future<bool> _showUnsavedChangesDialog(
    BuildContext context,
    FreelancerDraft draft,
  ) async {
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
          final success = await _saveChanges(draft);
          if (context.mounted) Navigator.pop(context);
          completer.complete(success);
        },
        onCancel: () {
          if (context.mounted) Navigator.pop(context);
          completer.complete(true);
        },
      ),
    );

    return completer.future;
  }

  /// Save changes for edit mode

  /// Save changes for edit mode
  Future<bool> _saveChanges(FreelancerDraft draft) async {
    if (_resolvedFreelancerId == null) return false;
    // Guard against concurrent taps (edit path shares _isPublishing with create).
    if (_isPublishing) return false;

    if (!draft.isMinimumViable) {
      context.showErrorSnackbar(
        'Please complete all required fields before saving',
      );
      return false;
    }

    setState(() => _isPublishing = true);
    context.showLoadingSnackbar('Saving changes...');

    try {
      final editState = ref.read(
        editFreelancerProvider(_resolvedFreelancerId!),
      );
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

      final notifier = ref.read(
        editFreelancerProvider(_resolvedFreelancerId!).notifier,
      );
      final success = await notifier.saveChanges(
        newImages: newImageFiles,
        imageIdsToDelete: imageIdsToDelete,
        imagesToDelete: removedImageUrls,
        newDocuments: newDocuments,
        docIdsToDelete: docIdsToDelete,
        documentUrlsToDelete: removedDocUrls,
      );

      // Guard all context access after the async gap.
      if (!mounted) return false;
      ScaffoldMessenger.of(context).clearSnackBars();

      if (success) {
        _hasUnsavedChanges = false;
        context.showSuccessSnackbar('Profile updated successfully');
        Navigator.pop(context);
        return true;
      } else {
        context.showErrorSnackbar(
          'Failed to update profile. Please try again.',
        );
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).clearSnackBars();
      context.showErrorSnackbar('Something went wrong. Please try again.');
      return false;
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  void dispose() {
    // Defer the reset: dispose can run during tree finalization (e.g. when the
    // publish flow replaces this route), and Riverpod forbids mutating a
    // provider mid-build. Capture the container first since `ref` is gone after.
    final container = _container;
    Future.microtask(() {
      container.read(draftContextProvider.notifier).state = DraftContext.shop;
    });
    super.dispose();
  }
}
