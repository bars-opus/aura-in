// lib/features/freelancer/creation/presentation/screens/freelancer_preview_screen.dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/admin/providers/admin_provider.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/domain/models/freelancer_draft.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_creation_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/screens/freelancer_creation_dashboard.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/models/freelancer_details_dto.dart';
import 'package:nano_embryo/presentation/features/freelancer/domain/usecases/publish_freelancer_usecase.dart';
import 'package:nano_embryo/presentation/features/freelancer/enums/freelancer_type.dart';
import 'package:nano_embryo/presentation/features/freelancer/presentation/providers/freelancer_details_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/presentation/widgets/freelancer_details_content.dart';
import 'package:nano_embryo/presentation/features/freelancer/presentation/widgets/freelancer_details_info_section.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/screens/shared/booking_success_widget.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/service_selection/service_ticket_widget.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/opening_hours_dto.dart';

/// Preview screen that shows the freelancer profile exactly as clients will see it.
/// Wraps [FreelancerDetailsContent] in a [ProviderScope] that overrides all
/// remote providers with draft data so no network calls are made.
class FreelancerPreviewScreen extends ConsumerStatefulWidget {
  final FreelancerMode mode;
  final FreelancerDraft? draft;

  const FreelancerPreviewScreen({super.key, required this.mode, this.draft});

  @override
  ConsumerState<FreelancerPreviewScreen> createState() =>
      _FreelancerPreviewScreenState();
}

class _FreelancerPreviewScreenState
    extends ConsumerState<FreelancerPreviewScreen>
    with SingleTickerProviderStateMixin {
  static const _previewId = '__preview__';

  late TabController _tabController;
  late List<AppTabItem> _tabs;
  late FreelancerDraft _draft;
  late FreelancerDetailsDTO _previewDto;
  late List<Override> _providerOverrides;
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft ?? ref.read(freelancerCreationProvider);
    _previewDto = _dtoFromDraft(_draft);
    _tabController = TabController(length: 4, vsync: this);
    // Tabs contain Theme.of(context) calls — defer to first frame.
    _tabs = List.generate(
      4,
      (_) => const AppTabItem(label: '', content: SizedBox()),
    );
    _providerOverrides = _buildOverrides();
  }

  FreelancerDetailsDTO _dtoFromDraft(FreelancerDraft draft) {
    return FreelancerDetailsDTO(
      id: _previewId,
      userId: draft.userId ?? '',
      name: draft.name ?? '',
      bio: draft.bio,
      profileImageUrl: draft.profileImagePath,
      specialties: draft.specialties,
      isActive: true,
      isFreelancer: true,
      freelancerType:
          draft.freelancerType != null
              ? FreelancerType.fromString(draft.freelancerType!)
              : null,
      freelancerTypes:
          draft.freelancerTypes.map(FreelancerType.fromString).toList(),
      tools: draft.toolIds,
      canTravel: draft.canTravel,
      baseLatitude: draft.baseLatitude,
      baseLongitude: draft.baseLongitude,
      travelRadiusKm: draft.travelRadiusKm,
      terms: draft.terms,
      subaccountId: draft.subaccountId,
      transferRecipientId: draft.transferRecipientId,
      autoAcceptBookings: draft.autoAcceptBookings,
      maxBookingsPerDay: draft.maxBookingsPerDay,
      bufferMinutesBetweenBookings: draft.bufferMinutesBetweenBookings,
    );
  }

  List<Override> _buildOverrides() {
    const id = _previewId;
    return [
      freelancerPortfolioProvider(
        id,
      ).overrideWith((ref) async => _draft.localImagePaths),
      freelancerSocialLinksProvider(
        id,
      ).overrideWith((ref) async => _draft.socialLinks),
      freelancerDocumentUrlsProvider(id).overrideWith(
        (ref) async => _draft.documents.map((d) => d.file.path).toList(),
      ),
      freelancerHoursProvider(id).overrideWith(
        (ref) async =>
            _draft.openingHours
                .map(
                  (h) => OpeningHoursDTO(
                    id: 'preview_${h.dayOfWeek}',
                    dayOfWeek: h.dayOfWeek,
                    opensAt: h.opensAt,
                    closesAt: h.closesAt,
                    isClosed: h.isClosed,
                  ),
                )
                .toList(),
      ),
      freelancerToolsProvider(id).overrideWith((ref) async => _draft.toolIds),
    ];
  }

  List<AppTabItem> _buildTabs() {
    return [
      AppTabItem(
        label: 'Info',
        content: FreelancerDetailsInfoSection(
          freelancer: _previewDto,
          isPreview: true,
        ),
      ),
      AppTabItem(label: 'Services', content: _buildServicesPreview()),
      const AppTabItem(label: 'Buy', content: SizedBox()),
      const AppTabItem(label: 'Works', content: SizedBox()),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_tabs.first.label.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _tabs = _buildTabs());
      });
    }

    return ProviderScope(
      overrides: _providerOverrides,
      child: Scaffold(
        body: FreelancerDetailsContent(
          freelancerDetails: _previewDto,
          tabController: _tabController,
          tabs: _tabs,
          mode: 'preview',
          coverImageUrl: '',
        ),
        bottomNavigationBar:
            widget.mode == FreelancerMode.edit
                ? null
                : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(Spacing.md.h),
                    child:
                        _isPublishing
                            ? SizedBox(
                              height: 50.h,
                              width: 50.w,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                            : AppButton(
                              elevation: 0,
                              label: 'Publish Profile',
                              iconData: Icons.arrow_circle_right_outlined,
                              onPressed: () {
                                BottomSheetUtils.showDocumentationBottomSheet(
                                  context: context,
                                  maxHeight: 400.h,
                                  widget: ConfirmationDialog(
                                    type: ConfirmationType.info,
                                    title: 'Publish Profile?',
                                    confirmText: 'Publish',
                                    message:
                                        'Your profile will be visible to clients. '
                                        'You can still edit it later.',

                                    onConfirm: () {
                                      _publishProfile(context, _draft);
                                    },
                                  ),
                                );
                              },
                              // () => _confirmPublish(context, _draft),
                              size: ButtonSize.small,
                              width: double.infinity,
                              padding: Spacing.horizontalMd,
                              height: 40.h,
                            ),
                  ),
                ),
      ),
    );
  }

  Widget _buildServicesPreview() {
    if (_draft.services.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          subtitle: 'No services added\nTry adding a service',
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _draft.services.map(_buildServiceTile).toList(),
    );
  }

  Widget _buildServiceTile(AppointmentSlotDTO service) {
    return ServiceTicketWidget(
      service: service,
      isSelected: false,
      onTap: () {},
      currency: '',
      showWorkerIndicator: true,
    );
  }

  // void _confirmPublish(BuildContext context, FreelancerDraft draft) {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (ctx) => AlertDialog(
  //           title: const Text('Publish Profile?'),
  //           content: Text(
  // 'Your profile will be visible to clients. '
  // 'You can still edit it later.\n\n'
  // 'Completed: ${draft.completedSectionsCount}/${FreelancerDraft.totalSections} sections',
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(ctx),
  //               child: const Text('Cancel'),
  //             ),
  //             ElevatedButton(
  //               onPressed: () => _publishProfile(ctx, draft),
  //               child: const Text('Publish'),
  //             ),
  //           ],
  //         ),
  //   );
  // }

  Future<void> _publishProfile(
    BuildContext context,
    FreelancerDraft draft,
  ) async {
    setState(() => _isPublishing = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('User not logged in');

      final portfolioFiles =
          draft.localImagePaths.map((path) => File(path)).toList();
      final documentFiles = draft.documents.map((doc) => doc.file).toList();

      final publishUseCase = ref.read(publishFreelancerUseCaseProvider);
      final freelancerId = await publishUseCase.execute(
        userId: user.id,
        draft: draft,
        portfolioImages: portfolioFiles,
        documents: documentFiles,
      );

      // Best-effort verification submit. Failure is non-fatal: the worker row
      // already defaults to 'pending'; this just stamps submitted_at so the
      // admin queue orders correctly.
      try {
        await ref.read(verificationActionsProvider).submit(
          entityType: 'worker',
          entityId: freelancerId,
        );
      } catch (e) {
        debugPrint('⚠️ Freelancer verification submit failed (non-fatal): $e');
      }

      await ref.read(freelancerCreationProvider.notifier).clearDraft();

      if (mounted) {
        ref.read(homeTabIndexProvider.notifier).state = 3;
        context.go(RouteNames.home);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) _showSuccessDialog(context, freelancerId);
        });
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackbar('Failed to publish: $e');
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  void _showSuccessDialog(BuildContext context, String freelancerId) async {
    await BottomSheetUtils.showDocumentationBottomSheet(
      maxHeight: 500.h,
      context: context,
      widget: BookingSuccessDialog(
        title: 'Profile Published!  🎉',
        infoMessages: [
          'Your freelancer profile is now live and visible to clients. '
              'You can continue editing it anytime.',
        ],
        onViewBooking: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        actionText: 'Share profile',
        onDone: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  // void _showSuccessDialog(BuildContext context, String freelancerId) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder:
  //         (ctx) => AlertDialog(
  //           title: const Text('Profile Published!'),
  //           content: const Text(
  //             'Your freelancer profile is now live and visible to clients. '
  //             'You can continue editing it anytime.',
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(ctx);
  //                 Navigator.pushReplacementNamed(
  //                   context,
  //                   '/freelancer/$freelancerId',
  //                 );
  //               },
  //               child: const Text('View Profile'),
  //             ),
  //           ],
  //         ),
  //   );
  // }
}
