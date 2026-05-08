// lib/features/shop/creation/presentation/screens/preview_shop_screen.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/screens/shared/booking_success_widget.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/service_selection/service_ticket_widget.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/shop_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/screens/shop_creation.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/publish_provider.dart';
import 'dart:io';

import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_media_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_details_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/screens/shop_details_content.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_details_info_section.dart';

class PreviewShopScreen extends ConsumerStatefulWidget {
  final String mode;

  const PreviewShopScreen({super.key, required this.mode});

  @override
  ConsumerState<PreviewShopScreen> createState() => _PreviewShopScreenState();
}

class _PreviewShopScreenState extends ConsumerState<PreviewShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<AppTabItem> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = _getInitialTabs();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  List<AppTabItem> _getInitialTabs() {
    return [
      AppTabItem(label: 'Info', icon: null, content: const SizedBox()),
      AppTabItem(label: 'Services', icon: null, content: const SizedBox()),
      AppTabItem(label: 'Buy', icon: null, content: const SizedBox()),
      AppTabItem(label: 'Works', icon: null, content: const SizedBox()),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(shopCreationProvider);
    final publishState = ref.watch(publishProvider);

    // Convert draft to ShopDetailsDTO
    final previewDTO = ShopDetailsDTO.fromDraft(draft);

    // Update tabs with real content
    if (_tabs.first.content is SizedBox) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _tabs = [
              AppTabItem(
                label: 'Info',
                icon: null,
                content: ShopDetailsInfoSection(
                  isPreview: true,
                  shop: previewDTO,
                ),
              ),
              AppTabItem(
                label: 'Services',
                icon: null,
                content: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: _buildServicesPreview(draft),
                ),
              ),
              AppTabItem(label: 'Buy', icon: null, content: Container()),
              AppTabItem(label: 'Works', icon: null, content: Container()),
            ];
          });
        }
      });
    }

    return Scaffold(
      body: ShopDetailsContent(
        mode: widget.mode,
        shop: previewDTO,
        tabController: _tabController,
        tabs: _tabs,
      ),
      bottomNavigationBar:
          widget.mode == 'edit'
              ? null
              : publishState.isPublishing
              ? null
              : SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(Spacing.md.h),
                  child:
                  // publishState.isPublishing
                  //     ? SizedBox(
                  //       height: 50.h,
                  //       child: InfoRowWidget(
                  //         subtitle: 'please wait....',
                  //         title: 'Publishing shop',
                  //         icon: Icons.storefront_rounded,
                  //         avatarRadius: 0,
                  //         iconSize: 0,
                  //         trailing: CircularLoadingIndicator(),
                  //         onTap: () {},
                  //         showAvatar: false,
                  //         showDivider: false,
                  //         disableTrailing: false,
                  //         showTrailingArrow: false,
                  //       ),
                  //     )
                  //     //  CircularLoadingIndicator()
                  //     :
                  AppButton(
                    elevation: 0,
                    label: 'Publish Shop',
                    center: false,
                    iconData: Icons.publish,
                    prefixIcon: Icons.arrow_circle_right_outlined,
                    prefixIconColor: Theme.of(context).colorScheme.background,
                    onPressed: () => _confirmPublish(context, ref),
                    size: ButtonSize.small,
                    width: double.infinity,
                    padding: Spacing.horizontalMd,
                    height: 40.h,
                  ),
                ),
              ),
    );
  }

  Widget _buildServicesPreview(ShopDraft draft) {
    if (draft.services.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          subtitle: 'No services added\nTry adding a service',
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: draft.services.map(_buildServiceTile).toList(),
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

  void _confirmPublish(BuildContext context, WidgetRef ref) {
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      maxHeight: 400.h,
      widget: ConfirmationDialog(
        icon: Icons.publish,
        type: ConfirmationType.info,
        title: 'Publish Shop?',
        message:
            'Your shop will be submitted for review. You can still edit it while pending verification.',
        confirmText: 'Publish',
        onConfirm: () async {
          context.showLoadingSnackbar('Publishing your shop...');
          final notifier = ref.read(publishProvider.notifier);
          final success = await notifier.publish();

          if (success && context.mounted) {
            final shopId = ref.read(publishProvider).shopId;
            _showSuccessDialog(context, shopId ?? '');
            // // Navigate after dialog closes
            // Future.delayed(const Duration(milliseconds: 500), () {
            //   if (context.mounted) {
            //     context.push('/shop/$shopId');
            //   }
            // });
          } else if (context.mounted) {
            final error = ref.read(publishProvider).error;
            context.showErrorSnackbar(error ?? 'Failed to publish shop');
            ref.read(publishProvider.notifier).reset();
          }
        },
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String shopId) async {
    await BottomSheetUtils.showDocumentationBottomSheet(
      maxHeight: 500.h,
      context: context,
      widget: BookingSuccessDialog(
        title: 'Shop Submitted!  🎉',
        infoMessages: [
          'Your shop has been submitted for verification. You\'ll be notified once it\'s approved. You can continue editing while pending.',
        ],
        onViewBooking: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        actionText: 'Share profile',
        onDone: () {
          // context.popUntil((route) => route.settings.name == 'my_shops');

          // Navigator.pop(context);
        },
      ),
    );
  }

  // void _showSuccessDialog(BuildContext context, WidgetRef ref) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder:
  //         (ctx) => AlertDialog(
  //           title: const Text('Shop Submitted! 🎉'),
  //           content: const Text(
  //             'Your shop has been submitted for verification. You\'ll be notified once it\'s approved. You can continue editing while pending.',
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(ctx);
  //               },
  //               child: const Text('OK'),
  //             ),
  //           ],
  //         ),
  //   );
  // }
}
