// lib/features/booking/presentation/screens/booking_confirmation_screen.dart
import 'package:nano_embryo/presentation/features/shops/booking/presentation/controllers/booking_creation_controller.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/payment/presentation/controllers/payment_controller.dart';

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

    // Convert workers to IDs only (keep as is)
    final selectedWorkerIdsOnly = <String, List<String?>>{};
    selectedWorkersData.forEach((serviceId, workerEntries) {
      selectedWorkerIdsOnly[serviceId] =
          workerEntries.map((entry) => entry['id']).toList();
    });

    // Calculate totals
    final totalDuration = _calculateTotalDuration(selectedServices);
    final totalPrice = _calculateTotalPrice(selectedServices);

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
                    payOnPressed: () {
                      BottomSheetUtils.showDocumentationBottomSheet(
                        context: context,
                        maxHeight: 350.h,
                        widget: ConfirmationDialog(
                          noIcon: true,
                          type: ConfirmationType.info,
                          title:
                              'You are required to make a 30% deposit to secure this appointment',
                          confirmText: 'Continue',
                          message:
                              'We Continue to the bext page and see what is there all day al nught',
                          onConfirm: () {
                            _confirmBooking();
                          },
                        ),
                      );
                    },
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

  double _calculateTotalPrice(List<AppointmentSlotDTO> services) {
    return services.fold<double>(0, (sum, service) => sum + service.price);
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

    try {
      final services = ref.read(selectedServicesProvider);
      final workers = ref.read(selectedWorkersProvider);
      final quantities = ref.read(serviceQuantityProvider);
      final timeSlots = ref.read(selectedTimeSlotsProvider);
      final totalPrice = _calculateTotalPrice(services);
      final firstSlot = timeSlots.values.first;

      // Prepare services data - worker name comes directly from workers map
      final servicesData =
          services.map((service) {
            final workerEntries = workers[service.id] ?? [];
            final firstWorker =
                workerEntries.isNotEmpty ? workerEntries.first : null;

            return {
              'slotId': service.id,
              'workerId': firstWorker?['id'],
              'priceAtBooking': service.price,
              'durationMinutes':
                  DurationUtils.parse(service.duration).inMinutes,
              'serviceName': service.serviceName,
              'workerName': firstWorker?['name'] ?? '',
            };
          }).toList();

      final paymentProvider = _getPaymentProvider(widget.shopCurrency ?? 'GH');

      final paymentController = ref.read(paymentControllerProvider.notifier);
      final result = await paymentController.processPayment(
        shopId: shopId,
        userId: user.id,
        userEmail: user.email ?? '',
        services: servicesData,
        startTime: firstSlot.startTime,
        endTime: firstSlot.endTime,
        actualEndTime: firstSlot.actualEndTime,
        totalAmount: totalPrice,
        depositAmount: 2.0,
        //  totalPrice * 0.3,
        platformFee: 2.0,
        paymentProvider: paymentProvider,
        context: context,
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

  String _getPaymentProvider(String countryCode) {
    const africanCountries = [
      'NG',
      'GH',
      'KE',
      'ZA',
      'UG',
      'TZ',
      'RW',
      'ZM',
      'BW',
    ];
    return africanCountries.contains(countryCode.toUpperCase())
        ? 'paystack'
        : 'stripe';
  }

  Future<void> _showBookingSuccess(Map<String, dynamic> result) async {
    final booking = BookingModel.fromJson(result['booking']);

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

  void _showError(String message) {
    if (!mounted) return;
    context.showErrorSnackbar(message);
  }

  // In your booking_confirmation_screen.dart - add this method
}
