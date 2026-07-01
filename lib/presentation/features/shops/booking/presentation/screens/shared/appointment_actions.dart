import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/exceptions/booking_error_messages.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/utils/booking_logger.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/services/business_chat_launcher.dart';
import 'package:nano_embryo/presentation/features/shops/appointments/shop_daily_schedule/providers/daily_schedule_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/contact_bottom_sheet.dart';

class AppointmentActions extends ConsumerStatefulWidget {
  final bool isShopOwner;
  final String shopId;
  final String shopName;

  final DateTime startTime;
  final String bookingId;
  final String status;
  final BookingModel booking;

  const AppointmentActions({
    super.key,
    required this.isShopOwner,
    required this.shopId,
    required this.startTime,
    required this.bookingId,
    required this.status,
    required this.shopName,
    required this.booking,
  });

  @override
  ConsumerState<AppointmentActions> createState() => _AppointmentActionsState();
}

class _AppointmentActionsState extends ConsumerState<AppointmentActions> {
  bool _busy = false;

  Future<void> _runMutation({
    required String op,
    required String loadingMessage,
    required String successMessage,
    required Future<void> Function() action,
  }) async {
    if (_busy || !mounted) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    context.showLoadingSnackbar(loadingMessage);
    try {
      await action();
      if (!mounted) return;
      messenger?.hideCurrentSnackBar();
      context.showSuccessSnackbar(successMessage);
    } catch (e, st) {
      BookingLogger.error(op, error: e, stack: st);
      if (!mounted) return;
      messenger?.hideCurrentSnackBar();
      context.showErrorSnackbar(BookingErrorMessages.forUser(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

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
                      onPressed:
                          _busy
                              ? null
                              : () {
                                BottomSheetUtils.showDocumentationBottomSheet(
                                  maxHeight: 400.h,
                                  context: context,

                                  widget: ConfirmationDialog(
                                    type: ConfirmationType.success,
                                    icon: Icons.check_circle,

                                    title: 'Mark as Completed',
                                    confirmText: 'Complete',
                                    message:
                                        'Are you sure you want to mark this appointment as completed?',
                                    onConfirm:
                                        () => _runMutation(
                                          op: 'mark_complete_failed',
                                          loadingMessage:
                                              'Marking as completed...',
                                          successMessage:
                                              'Appointment marked as completed',
                                          action:
                                              () => scheduleNotifier
                                                  .markBookingAsCompleted(
                                                    widget.bookingId,
                                                    widget.startTime,
                                                  ),
                                        ),
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
                      onPressed:
                          _busy
                              ? null
                              : () {
                                BottomSheetUtils.showDocumentationBottomSheet(
                                  maxHeight: 400.h,
                                  context: context,
                                  widget: ConfirmationDialog(
                                    type: ConfirmationType.warning,
                                    icon: Icons.person_off_outlined,
                                    title: 'Mark as No-Show',
                                    confirmText: 'Mark No-Show',
                                    message:
                                        'Mark this client as no-show? This will affect their record.',
                                    onConfirm:
                                        () => _runMutation(
                                          op: 'mark_no_show_failed',
                                          loadingMessage:
                                              'Marking as no-show...',
                                          successMessage:
                                              'Client marked as no-show',
                                          action:
                                              () => scheduleNotifier
                                                  .markBookingAsNoShow(
                                                    widget.bookingId,
                                                    widget.startTime,
                                                  ),
                                        ),
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
                    onPressed:
                        widget.booking.userId.isEmpty
                            ? null
                            : () => BusinessChatLauncher.openForBooking(
                              context,
                              ref,
                              widget.booking,
                              isShopOwner: true,
                              shopName: widget.shopName,
                            ),
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
                        maxHeight: 400.h,
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
                    onPressed:
                        () => BusinessChatLauncher.openForBooking(
                          context,
                          ref,
                          widget.booking,
                          isShopOwner: false,
                          shopName: widget.shopName,
                        ),
                    tooltip: 'Message',
                  ),
                ],
              ),
    );
  }
}
