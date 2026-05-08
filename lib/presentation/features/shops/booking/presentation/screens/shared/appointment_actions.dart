import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/appointments/shop_daily_schedule/providers/daily_schedule_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/contact_bottom_sheet.dart';

class AppointmentActions extends ConsumerStatefulWidget {
  final bool isShopOwner;
  final String shopId;
  final String shopName;

  final DateTime startTime;
  final String bookingId;
  final String status;

  const AppointmentActions({
    super.key,
    required this.isShopOwner,
    required this.shopId,
    required this.startTime,
    required this.bookingId,
    required this.status,
    required this.shopName,
  });

  @override
  ConsumerState<AppointmentActions> createState() => _AppointmentActionsState();
}

class _AppointmentActionsState extends ConsumerState<AppointmentActions> {
  @override
  Widget build(BuildContext context) {
    final scheduleNotifier = ref.read(
      dailyScheduleNotifierProvider(widget.shopId).notifier,
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isCompleted = widget.status == 'completed';
    final bool isNoShow = widget.status == 'noShow';

    return CardInkWell(
      elevation: 0,
      color: colorScheme.primary,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      borderRadius: BorderRadius.circular(30.r),
      onTap: () {},
      child:
          widget.isShopOwner
              ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mark as Completed button (only show if not already completed/cancelled)
                  if (!isCompleted && !isNoShow)
                    AppIconButton(
                      icon: Icons.check_circle_outline,
                      iconColor: colorScheme.onPrimary,
                      onPressed: () {
                        BottomSheetUtils.showDocumentationBottomSheet(
                          context: context,
                          widget: ConfirmationDialog(
                            type: ConfirmationType.info,
                            icon: Icons.check_circle,
                            title: 'Mark as Completed',
                            confirmText: 'Complete',
                            message:
                                'Are you sure you want to mark this appointment as completed?',
                            onConfirm: () async {
                              context.showLoadingSnackbar(
                                'Marking as completed...',
                              );

                              try {
                                await scheduleNotifier.markBookingAsCompleted(
                                  widget.bookingId,
                                  widget.startTime,
                                );

                                if (mounted) {
                                  Snackbar.hide(context);
                                  context.showSuccessSnackbar(
                                    'Appointment marked as completed',
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  Snackbar.hide(context);
                                  context.showErrorSnackbar(
                                    'Failed to mark appointment: $e',
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                      tooltip: 'Mark Complete',
                    ),

                  // Mark as No-Show button (only show if not already completed/cancelled/no-show)
                  if (!isCompleted && !isNoShow)
                    AppIconButton(
                      icon: Icons.person_off_outlined,
                      iconColor: colorScheme.onPrimary,
                      onPressed: () {
                        BottomSheetUtils.showDocumentationBottomSheet(
                          context: context,
                          widget: ConfirmationDialog(
                            type: ConfirmationType.warning,
                            icon: Icons.person_off_outlined,
                            title: 'Mark as No-Show',
                            confirmText: 'Mark No-Show',
                            message:
                                'Mark this client as no-show? This will affect their record.',
                            onConfirm: () async {
                              context.showLoadingSnackbar(
                                'Marking as no-show...',
                              );

                              try {
                                await scheduleNotifier.markBookingAsNoShow(
                                  widget.bookingId,
                                  widget.startTime,
                                );

                                if (mounted) {
                                  Snackbar.hide(context);
                                  context.showSuccessSnackbar(
                                    'Client marked as no-show',
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  Snackbar.hide(context);
                                  context.showErrorSnackbar(
                                    'Failed to mark no-show: $e',
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                      tooltip: 'Mark No-Show',
                    ),

                  // Cancel button (only show if not already completed/cancelled)

                  // Message button (always visible)
                  AppIconButton(
                    icon: Icons.message,
                    iconColor: colorScheme.onPrimary,
                    onPressed: () {
                      // _handleContactClient();
                    },
                    tooltip: 'Message',
                  ),
                ],
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // AppIconButton(
                  //   icon: Icons.edit,
                  //   iconColor: colorScheme.onPrimary,
                  //   onPressed: () {
                  //   },
                  //   tooltip: 'Add special requirements',
                  // ),
                  AppIconButton(
                    icon: Icons.call,
                    iconColor: colorScheme.onPrimary,
                    onPressed: () {
                      BottomSheetUtils.showDocumentationBottomSheet(
                        context: context,
                        widget: ContactBottomSheet(
                          shopId: widget.shopId,
                          shopName: widget.shopName,
                        ),
                      );
                    },
                    tooltip: 'Call',
                  ),
                  AppIconButton(
                    icon: Icons.message,
                    iconColor: colorScheme.onPrimary,
                    onPressed: () {},
                    tooltip: 'Message',
                  ),
                ],
              ),
    );
  }
}
