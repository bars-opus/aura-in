// lib/features/booking/presentation/screens/booking_confirmation_screen.dart
import 'dart:async';

import 'package:nano_embryo/core/feedback/review/review_providers.dart';
import 'package:nano_embryo/core/utils/logging/app_logger.dart';
import 'package:nano_embryo/core/utils/money.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/applied_promo.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/controllers/booking_creation_controller.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/payment/config/payment_config.dart';
import 'package:nano_embryo/payment/presentation/controllers/payment_controller.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/client_promo_code_field.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/service_addons_provider.dart';

class BookingConfirmationScreen extends ConsumerStatefulWidget {
  final String shopType;
  final String shopName;
  final String shopCurrency;
  final String shopAddress;
  final double latitude;
  final double longitude;
  final String shopLogoUrl;

  const BookingConfirmationScreen({
    Key? key,
    required this.shopType,
    required this.shopName,
    required this.shopCurrency,
    required this.shopLogoUrl,
    required this.latitude,
    required this.longitude,
    required this.shopAddress,
  }) : super(key: key);

  @override
  ConsumerState<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends ConsumerState<BookingConfirmationScreen> {
  bool _isProcessing = false;

  // ── Phase 13 — applied promo code state ────────────────────────────
  // Updated by ClientPromoCodeField via the onApplied callback. Null
  // when no code is applied. processPayment reads these to pass through
  // promotionId + promoAmountOff in the request body so the success
  // webhook can call redeem_promotion.
  AppliedPromo? _appliedPromo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedServices = ref.watch(selectedServicesProvider);
    final selectedWorkersData = ref.watch(selectedWorkersProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTimeSlots = ref.watch(selectedTimeSlotsProvider); // ← Changed
    final isCombinedView = ref.watch(isCombinedViewProvider); // ← Add this
    final bookingState = ref.watch(bookingCreationControllerProvider);
    final shopId = ref.read(selectedShopIdProvider);

    // Listen for the app-bar "Book" button signal from BookingFlowScreen.
    ref.listen(bookingPaymentTriggerProvider, (prev, next) {
      if ((prev ?? 0) < next && !_isProcessing) {
        _showPaymentDialog();
      }
    });

    // Convert workers to IDs only (keep as is)
    final selectedWorkerIdsOnly = <String, List<String?>>{};
    selectedWorkersData.forEach((serviceId, workerEntries) {
      selectedWorkerIdsOnly[serviceId] =
          workerEntries.map((entry) => entry['id']).toList();
    });

    // Calculate totals
    final selectedQuantities = ref.watch(serviceQuantityProvider);
    final selectedAddons = ref.watch(selectedAddonsProvider);
    final totalDuration = _calculateTotalDuration(selectedServices);
    // Phase 17: int kobo end-to-end. Add-on prices fold into the total.
    final totalPriceMinor = _calculateTotalPriceMinor(
      selectedServices,
      selectedQuantities,
      selectedTimeSlots,
      selectedAddons,
    );

    // Check if anything is missing - UPDATED LOGIC
    bool isValid = false;

    if (isCombinedView) {
      // Combined view: need at least one slot
      isValid = selectedServices.isNotEmpty && selectedTimeSlots.isNotEmpty;
    } else {
      // Regular view: need a slot for EVERY service
      isValid =
          selectedServices.isNotEmpty &&
          selectedServices.every(
            (service) => selectedTimeSlots.containsKey(service.id),
          );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body:
          isValid
              ? _buildConfirmationContent(
                theme,
                colorScheme,
                selectedServices,
                selectedWorkerIdsOnly,
                selectedDate,
                selectedTimeSlots, // ← Now passing the map, not a single slot
                isCombinedView, // ← Pass this too
                totalDuration,
                totalPriceMinor,
                bookingState,
                shopId ?? '',
              )
              : _buildErrorState(
                theme,
                colorScheme,
                isCombinedView,
              ), // ← Updated
    );
  }

  Widget _buildConfirmationContent(
    ThemeData theme,
    ColorScheme colorScheme,
    List<AppointmentSlotDTO> services,
    Map<String, List<String?>> workers,
    DateTime date,
    Map<String, TimeSlotModel> timeSlots, // ← Changed from single TimeSlotModel
    bool isCombinedView, // ← New parameter
    Duration totalDuration,
    int totalPriceMinor,
    BookingCreationState bookingState,
    String shopId,
  ) {
    final allWorkersAsync = ref.watch(shopWorkersProvider(shopId: shopId));
    final profileAsync = ref.watch(currentUserProfileProvider);

    // Handle loading state
    if (profileAsync.isLoading) {
      return const SizedBox.shrink();
    }
    if (profileAsync.hasError) {
      return const SizedBox.shrink();
    }
    final profile = profileAsync.value;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(Spacing.md.h),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProfileAvatar(
                      avatarUrl: profile?.avatarUrl ?? '',
                      currentUserId: profile?.id ?? '',
                      size: 50.h,
                    ),
                    Gap(Spacing.sm.h),
                    Text(
                      profile?.username ?? '',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(Spacing.sm.h),
              // Show selected times

              // Booking summary card with async data
              allWorkersAsync.when(
                data: (allWorkers) {
                  return BookingSummaryCard(
                    services: services,
                    workers: workers ?? {},
                    payOnPressed: _showPaymentDialog,
                    allWorkers: allWorkers,
                    date: date,
                    timeSlots: timeSlots,
                    isCombinedView: isCombinedView,
                    totalDuration: totalDuration,
                    // Phase 17: widget signature flips in Wave 5.6. Until then,
                    // convert at the boundary.
                    totalPrice: totalPriceMinor / 100,
                    shopCurrency: '',
                    isProcessing: _isProcessing,
                    reference: '',
                  );
                },
                loading: () => ShopSchimmerSkeleton(height: 100.h),
                error:
                    (error, stack) =>
                        Center(child: Text('Error loading workers: $error')),
              ),

              Gap(Spacing.md.h),
              AppDivider(),

              // Phase 13: promo code field. Auto-applies any silent
              // loyalty / recovery code on mount; manual entry replaces
              // the auto-applied one. The widget passes back the
              // promotionId + amountOff via _onPromoApplied.
              ClientPromoCodeField(
                shopId: shopId,
                userId: profile?.id,
                guestProfileId: null,
                // Phase 17: ClientPromoCodeField widget signature stays
                // major-units until Wave 5.1 flips it. Boundary-convert.
                bookingTotal: totalPriceMinor / 100,
                serviceIds: services.map((s) => s.id).toList(),
                onApplied: _onPromoApplied,
              ),

              AppDivider(),
              Gap(Spacing.lg.h),

              SemanticContainerWidget(
                content:
                    _isProcessing
                        ? 'Processing payment....'
                        : 'You can change the worker later if they become unavailable',
                icon:
                    _isProcessing
                        ? Icons.warning_amber_rounded
                        : Icons.info_outline,
                title: '',
                backgroundColor: Colors.red.withOpacity(0.1),
                borderColor: Colors.red,
                iconColor: Colors.red,
                textTheme: theme.textTheme,
              ),

              Gap(Spacing.md.h),

              SemanticContainerWidget(
                content:
                    _isProcessing
                        ? 'Kindly wait for the paypemt to finish processing and return to your app to generate your appointment'
                        : 'You can change the worker later if they become unavailable',
                icon: Icons.payment,
                title: '',
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                borderColor: colorScheme.primary,
                iconColor: colorScheme.primary,
                textTheme: theme.textTheme,
              ),

              // Error display if any
              if (bookingState.hasError)
                Padding(
                  padding: EdgeInsets.only(top: Spacing.md.h),
                  child: ErrorStateWidget(
                    subtitle: bookingState.error!,
                    compact: true,
                  ),
                ),
              Gap(Spacing.lg.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isCombinedView,
  ) {
    String message =
        isCombinedView
            ? 'Please select a time slot'
            : 'Please select a time slot for each service';
    return Center(
      child: ErrorStateWidget(
        showDetails: true,
        compact: true,
        title: 'Missing Time Selections',

        subtitle: message,
        errorDetails: '',
        type: ErrorStateType.genericError,
      ),
    );
  }

  Duration _calculateTotalDuration(List<AppointmentSlotDTO> services) {
    return services.fold<Duration>(
      Duration.zero,
      (sum, service) => sum + DurationUtils.parse(service.duration),
    );
  }

  /// Phase 13 — promo applied / cleared callback from ClientPromoCodeField.
  /// State updates only; the discounted total is read directly from
  /// _appliedPromo?.newTotal at processPayment time.
  void _onPromoApplied(AppliedPromo? applied) {
    setState(() => _appliedPromo = applied);
  }

  /// Phase 17: effective price per service in int kobo. Reads
  /// `TimeSlotModel.priceMinor` (already int) for the override-applied
  /// slot and falls back to `service.price` (already minor units after
  /// DB migration) when no slot is mapped.
  int _calculateTotalPriceMinor(
    List<AppointmentSlotDTO> services,
    Map<String, int> quantities,
    Map<String, TimeSlotModel> timeSlots,
    Map<String, List<dynamic>> selectedAddons,
  ) {
    return services.fold<int>(0, (sum, service) {
      final effectiveMinor = timeSlots[service.id]?.priceMinor ?? service.price;
      final qty = quantities[service.id] ?? 1;
      final addonMinor = (selectedAddons[service.id] ?? []).fold<int>(
        0,
        (s, a) => s + (a.priceMinor as int),
      );
      return sum + (effectiveMinor + addonMinor) * qty;
    });
  }

  Future<void> _confirmBooking() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      context.showErrorSnackbar('Please log in to continue');
      return;
    }

    final shopId = ref.read(selectedShopIdProvider);
    if (shopId == null) return;

    setState(() => _isProcessing = true);

    final config = ref.read(paymentConfigProvider);

    try {
      final services = ref.read(selectedServicesProvider);
      final workers = ref.read(selectedWorkersProvider);
      final quantities = ref.read(serviceQuantityProvider);
      final timeSlots = ref.read(selectedTimeSlotsProvider);
      final addons = ref.read(selectedAddonsProvider);
      // Phase 17: int kobo end-to-end. Add-on prices included in total.
      final totalPriceMinor = _calculateTotalPriceMinor(
        services,
        quantities,
        timeSlots,
        addons,
      );
      final firstSlot = timeSlots.values.first;

      // Phase 13: when a promo code is applied, the discounted total
      // becomes the canonical totalAmount sent to the payment provider,
      // and the platform fee recomputes against that new total. The
      // pre-discount totalPrice is no longer used after this point.
      // Phase 17: AppliedPromo now carries int kobo (Wave 5.1).
      final effectiveTotalMinor =
          _appliedPromo?.newTotalMinor ?? totalPriceMinor;

      // Expand services by quantity so the server-side amount validation
      // (sum(priceAtBookingMinor) == totalAmountMinor) holds for group bookings.
      // Phase 17: send both legacy + new keys; edge function reads either.
      final servicesData =
          services.expand<Map<String, dynamic>>((service) {
            final qty = quantities[service.id] ?? 1;
            final workerEntries = workers[service.id] ?? [];
            final effectivePriceMinor =
                timeSlots[service.id]?.priceMinor ?? service.price;
            final serviceAddons = addons[service.id] ?? [];
            final addonMinor = serviceAddons.fold<int>(
              0,
              (s, a) => s + (a.priceMinor as int),
            );
            final addonDurationMins = serviceAddons.fold<int>(
              0,
              (s, a) => s + ((a.durationMinutes as int?) ?? 0),
            );
            return List.generate(qty, (i) {
              final worker = i < workerEntries.length ? workerEntries[i] : null;
              return {
                'slotId': service.id,
                'workerId': worker?['id'],
                'priceAtBookingMinor': effectivePriceMinor + addonMinor,
                'durationMinutes':
                    DurationUtils.parse(service.duration).inMinutes +
                    addonDurationMins,
                'serviceName': service.serviceName,
                'workerName': worker?['name'] ?? '',
                if (serviceAddons.isNotEmpty)
                  'addons':
                      serviceAddons
                          .map(
                            (a) => {
                              'id': a.id,
                              'name': a.name,
                              'priceMinor': a.priceMinor,
                              'durationMinutes': a.durationMinutes,
                            },
                          )
                          .toList(),
              };
            });
          }).toList();

      final paymentProvider = _getPaymentProvider(widget.shopCurrency);

      final paymentController = ref.read(paymentControllerProvider.notifier);
      final result = await paymentController.processPayment(
        shopId: shopId,
        userId: user.id,
        userEmail: user.email ?? '',
        services: servicesData,
        startTime: firstSlot.startTime,
        endTime: firstSlot.endTime,
        actualEndTime: firstSlot.actualEndTime,
        // Phase 17: int kobo via `applyBps`. Deposit/platform-fee math is
        // exact integer; no float rounding dust.
        totalAmountMinor: effectiveTotalMinor,
        depositAmountMinor: applyBps(effectiveTotalMinor, config.depositBps),
        platformFeeMinor: applyBps(effectiveTotalMinor, config.platformFeeBps),
        paymentProvider: paymentProvider,
        context: context,
        promotionId: _appliedPromo?.promotionId,
        // Phase 17: AppliedPromo carries int kobo directly (Wave 5.1).
        promoAmountOffMinor: _appliedPromo?.amountOffMinor,
      );

      if (result != null && mounted) {
        await _showBookingSuccess(result);
      } else {
        _showError('Payment failed. Please try again.');
      }
    } catch (e) {
      // F-P2-8: never surface raw exception strings to the client.
      // Log the detail; show a generic message.
      AppLogger.warn(
        'booking_confirmation.confirm_failed',
        fields: {'error': e.toString()},
      );
      _showError("We couldn't complete your booking. Please try again.");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  String _getPaymentProvider(String shopCurrency) {
    // Matches both currency codes (what the DB stores) and country codes
    // (defensive, in case the caller ever passes a country instead).
    const paystackIdentifiers = {
      // Currency codes
      'GHS', 'GHC', // Ghana
      'NGN', // Nigeria
      'KES', // Kenya
      'ZAR', // South Africa
      'UGX', // Uganda
      'TZS', // Tanzania
      'RWF', // Rwanda
      'ZMW', // Zambia
      'BWP', // Botswana
      // Country code fallbacks
      'GH', 'NG', 'KE', 'ZA', 'UG', 'TZ', 'RW', 'ZM', 'BW',
    };
    final key = shopCurrency.trim().toUpperCase();
    return (key.isNotEmpty && paystackIdentifiers.contains(key))
        ? 'paystack'
        : 'stripe';
  }

  Future<void> _showBookingSuccess(Map<String, dynamic> result) async {
    final booking = BookingModel.fromJson(result);

    // Feedback engine — a successful booking is a canonical "happy moment".
    // Record it now (cheap, persistent) and try the rating prompt once the
    // user dismisses the success sheet. The heuristic decides whether to
    // actually ask; this call is a no-op if launch count / freshness gates
    // aren't met.
    final prompter = ref.read(reviewPrompterProvider);
    unawaited(prompter.recordHappyMoment());

    // Only ask for a rating when the user dismissed via "Done" — not when
    // they tapped "View booking," because the OS dialog would stack over
    // the booking-detail sheet.
    var viewedBooking = false;

    await BottomSheetUtils.showDocumentationBottomSheet(
      maxHeight: 500.h,
      context: context,
      widget: BookingSuccessDialog(
        title: 'Booking Successful',
        infoMessages: [
          'Your booking is confirmed',
          'Reference: #${booking.id.substring(0, 8)}',
          // Phase 17: format from int kobo via the single helper.
          'Deposit paid: ${formatMoney(booking.depositAmountMinor, widget.shopCurrency)}',
          'Remaining: ${formatMoney(booking.remainingBalanceMinor, widget.shopCurrency)} (pay after service)',
        ],
        onViewBooking: () {
          viewedBooking = true;
          Navigator.pop(context);
          BottomSheetUtils.showDocumentationBottomSheet(
            context: context,
            padding: 20,
            widget: BookingDetailScreen(
              startTime: booking.startTime,
              endTime: booking.endTime,
              bookingId: booking.id,
              totalAmountMinor: booking.totalAmountMinor,
              preLoadedBookingDetail: booking,
              shopType: widget.shopType,
              shopName: widget.shopName,
              shopCurrency: widget.shopCurrency,
              shopLogoUrl: widget.shopLogoUrl,
              shopAddress: widget.shopAddress,
              isShopOwner: false,
            ),
          );
        },
        onDone: () {
          Navigator.pop(context);
        },
      ),
    );

    if (!viewedBooking && mounted) {
      unawaited(prompter.maybeAsk());
    }
  }

  void _showPaymentDialog() {
    final config = ref.read(paymentConfigProvider);
    // Phase 17: bps → percent for display: 3000 bps = 30%.
    final depositPct = config.depositBps ~/ 100;
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      maxHeight: 350.h,
      widget: ConfirmationDialog(
        noIcon: true,
        type: ConfirmationType.info,
        title:
            'You are required to make a $depositPct% deposit to secure this appointment',
        confirmText: 'Continue',
        message:
            'A $depositPct% deposit is required to confirm your booking. The remaining balance is paid after your appointment.',
        onConfirm: () {
          _confirmBooking();
        },
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    context.showErrorSnackbar(message);
  }

  // In your booking_confirmation_screen.dart - add this method
}
