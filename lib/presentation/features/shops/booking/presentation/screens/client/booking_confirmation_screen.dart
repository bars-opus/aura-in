// lib/features/booking/presentation/screens/booking_confirmation_screen.dart
import 'package:nano_embryo/presentation/features/shops/booking/presentation/controllers/booking_creation_controller.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/payment/config/payment_config.dart';
import 'package:nano_embryo/payment/presentation/controllers/payment_controller.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/client_promo_code_field.dart';

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
    final totalDuration = _calculateTotalDuration(selectedServices);
    final totalPrice = _calculateTotalPrice(
      selectedServices,
      selectedQuantities,
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
                totalPrice,
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
    double totalPrice,
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
                    totalPrice: totalPrice,
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

              // Phase 13: promo code field. Auto-applies any silent
              // loyalty / recovery code on mount; manual entry replaces
              // the auto-applied one. The widget passes back the
              // promotionId + amountOff via _onPromoApplied.
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
                child: ClientPromoCodeField(
                  shopId: shopId,
                  userId: profile?.id,
                  guestProfileId: null,
                  bookingTotal: totalPrice,
                  serviceIds: services.map((s) => s.id).toList(),
                  onApplied: _onPromoApplied,
                ),
              ),

              Gap(Spacing.md.h),

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

  double _calculateTotalPrice(
    List<AppointmentSlotDTO> services,
    Map<String, int> quantities,
  ) {
    return services.fold<double>(
      0,
      (sum, service) => sum + service.price * (quantities[service.id] ?? 1),
    );
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
      final totalPrice = _calculateTotalPrice(services, quantities);
      final firstSlot = timeSlots.values.first;

      // Phase 13: when a promo code is applied, the discounted total
      // becomes the canonical totalAmount sent to the payment provider,
      // and the platform fee recomputes against that new total. The
      // pre-discount totalPrice is no longer used after this point.
      final effectiveTotal = _appliedPromo?.newTotal ?? totalPrice;

      // Expand services by quantity so the server-side amount validation
      // (sum(priceAtBooking) == totalAmount) holds for group bookings.
      final servicesData = services
          .expand<Map<String, dynamic>>((service) {
            final qty = quantities[service.id] ?? 1;
            final workerEntries = workers[service.id] ?? [];
            return List.generate(qty, (i) {
              final worker = i < workerEntries.length ? workerEntries[i] : null;
              return {
                'slotId': service.id,
                'workerId': worker?['id'],
                'priceAtBooking': service.price,
                'durationMinutes':
                    DurationUtils.parse(service.duration).inMinutes,
                'serviceName': service.serviceName,
                'workerName': worker?['name'] ?? '',
              };
            });
          })
          .toList();

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
        // Phase 13: discounted amounts. When no promo applied,
        // effectiveTotal == totalPrice so the pre-Phase-13 behavior is
        // preserved.
        totalAmount: effectiveTotal,
        depositAmount: effectiveTotal * config.depositFraction,
        platformFee: effectiveTotal * config.platformFeeFraction,
        paymentProvider: paymentProvider,
        context: context,
        promotionId: _appliedPromo?.promotionId,
        promoAmountOff: _appliedPromo?.amountOff,
      );

      if (result != null && mounted) {
        await _showBookingSuccess(result);
      } else {
        _showError('Payment failed. Please try again.');
      }
    } catch (e) {
      _showError(e.toString());
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

    await BottomSheetUtils.showDocumentationBottomSheet(
      maxHeight: 500.h,
      context: context,
      widget: BookingSuccessDialog(
        title: 'Booking Successful',
        infoMessages: [
          'Your booking is confirmed',
          'Reference: #${booking.id.substring(0, 8)}',
          'Deposit paid: ${widget.shopCurrency} ${booking.depositAmount.toStringAsFixed(2)}',
          'Remaining: ${widget.shopCurrency} ${(booking.totalAmount - booking.depositAmount).toStringAsFixed(2)} (pay after service)',
        ],
        onViewBooking: () {
          Navigator.pop(context);
          BottomSheetUtils.showDocumentationBottomSheet(
            context: context,
            padding: 20,
            widget: BookingDetailScreen(
              startTime: booking.startTime,
              endTime: booking.endTime,
              bookingId: booking.id,
              totalAmount: booking.totalAmount,
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
  }

  void _showPaymentDialog() {
    final config = ref.read(paymentConfigProvider);
    final depositPct = (config.depositFraction * 100).round();
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
