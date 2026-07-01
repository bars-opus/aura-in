// lib/features/booking/presentation/screens/booking_flow_screen.dart
import 'package:nano_embryo/presentation/features/shops/booking/presentation/providers/is_freelancer_provider.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/client/booking_address_step.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

/// Main booking flow screen that manages the multi-step booking process.
class BookingFlowScreen extends ConsumerStatefulWidget {
  final String shopId;
  final String shopType;
  final String shopName;
  final String shopCurrency;
  final String shopLogoUrl;
  final String shopAddress;
  final double latitude;
  final double longitude;
  final bool isFreelancer;
  final int? travelRadiusKm; // For freelancer distance validation
  final bool canTravel; // For freelancer address capture

  const BookingFlowScreen({
    Key? key,
    required this.shopId,
    required this.shopType,
    required this.shopName,
    required this.shopAddress,
    required this.shopCurrency,
    required this.shopLogoUrl,
    required this.latitude,
    required this.longitude,
    this.isFreelancer = false,
    this.travelRadiusKm,
    this.canTravel = false,
  }) : super(key: key);

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen>
    with AutomaticKeepAliveClientMixin {
  int _currentTabIndex = 0;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(selectedShopIdProvider.notifier).setShopId(widget.shopId);
      ref.read(isFreelancerProvider.notifier).state = widget.isFreelancer;

      // Reset booking state on entry so a stale draft from a previous
      // session doesn't bleed into the new one.
      ref.read(selectedServicesProvider.notifier).state = [];
      ref.read(selectedWorkersProvider.notifier).clear();
      ref.read(selectedTimeSlotsProvider.notifier).clear();
      ref.read(selectedAddressProvider.notifier).state = null;

      // Default selected date to today, never the past. If the date
      // provider was left over from a previous session and is now
      // historical, snap it forward.
      final currentDate = ref.read(selectedDateProvider);
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      if (currentDate.isBefore(todayDate)) {
        ref.read(selectedDateProvider.notifier).state = todayDate;
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  // Validation methods
  bool _canProceedToWorkers() {
    final selectedServices = ref.read(selectedServicesProvider);
    return selectedServices.isNotEmpty;
  }

  bool _canProceedToTime() {
    // For freelancers, skip worker validation entirely
    if (widget.isFreelancer) return true;

    final selectedWorkers = ref.read(selectedWorkersProvider);
    final servicesRequiringWorkers =
        ref
            .read(selectedServicesProvider)
            .where((s) => s.selectPreferredWorker)
            .toList();

    if (servicesRequiringWorkers.isEmpty) return true;

    // Check each service that requires worker selection
    return servicesRequiringWorkers.every((service) {
      final workerList = selectedWorkers[service.id];
      if (workerList == null) return false;

      // All entries must have non-null IDs
      return workerList.every((entry) => entry['id'] != null);
    });
  }

  bool _canProceedToAddress() {
    // Only show address step for freelancers who can travel
    if (!widget.isFreelancer || !widget.canTravel) return true;

    final selectedAddress = ref.read(selectedAddressProvider);
    return selectedAddress != null;
  }

  bool _canProceedToConfirm() {
    final selectedServices = ref.read(selectedServicesProvider);
    final selectedTimeSlots = ref.read(selectedTimeSlotsProvider);
    final isCombinedView = ref.read(isCombinedViewProvider);

    if (isCombinedView) {
      return selectedTimeSlots.isNotEmpty;
    } else {
      if (selectedServices.isEmpty) return false;
      return selectedServices.every(
        (service) => selectedTimeSlots.containsKey(service.id),
      );
    }
  }

  void _handleContinue() {
    // Determine current step based on freelancer status
    final hasWorkersStep = !widget.isFreelancer;
    final hasAddressStep = widget.isFreelancer && widget.canTravel;

    if (_currentTabIndex == 0 && _canProceedToWorkers()) {
      // Skip workers step for freelancers
      if (!hasWorkersStep) {
        _goToTimeStep();
      } else {
        _goToWorkersStep();
      }
      return;
    }

    if (_currentTabIndex == 0) {
      if (!_canProceedToWorkers()) {
        context.showErrorSnackbar('Please select at least one service');
        return;
      }
      if (hasWorkersStep) {
        _goToWorkersStep();
      } else {
        _goToTimeStep();
      }
    } else if (_currentTabIndex == 1 && hasWorkersStep) {
      if (!_canProceedToTime()) {
        context.showErrorSnackbar('Please select workers for all services');
        return;
      }
      _goToTimeStep();
    } else if (_currentTabIndex == (hasWorkersStep ? 2 : 1)) {
      if (!_canProceedToConfirm()) {
        context.showErrorSnackbar('Please select a time slot');
        return;
      }
      if (hasAddressStep && !_canProceedToAddress()) {
        _goToAddressStep();
      } else {
        _goToConfirmStep();
      }
    } else if (_currentTabIndex == (hasWorkersStep ? 3 : 2) && hasAddressStep) {
      if (!_canProceedToAddress()) {
        context.showErrorSnackbar('Please select a valid service address');
        return;
      }
      _goToConfirmStep();
    } else if (_currentTabIndex ==
        (hasWorkersStep
            ? (hasAddressStep ? 4 : 3)
            : (hasAddressStep ? 3 : 2))) {
      // Both shops and freelancers go through the same Paystack payment flow.
      // _processBooking() is the old payment-free path — do not call it here.
      ref.read(bookingPaymentTriggerProvider.notifier).update((v) => v + 1);
    }
  }

  void _goToWorkersStep() {
    _navigateToTab(1);
  }

  void _goToTimeStep() {
    _navigateToTab(widget.isFreelancer ? 1 : 2);
  }

  void _goToAddressStep() {
    _navigateToTab(widget.isFreelancer ? 2 : 3);
  }

  void _goToConfirmStep() {
    _navigateToTab(widget.isFreelancer ? (widget.canTravel ? 3 : 2) : 3);
  }

  void _navigateToTab(int index) {
    setState(() => _currentTabIndex = index);
    _tabController?.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentShopId = ref.watch(selectedShopIdProvider);
    final selectedServices = ref.watch(selectedServicesProvider);

    if (currentShopId == null) {
      return Scaffold(
        backgroundColor: colorScheme.neutral,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.md),
                child: Column(
                  children: [
                    Gap(20.h),
                    const ShopSchimmerSkeleton(height: 100),
                    Gap(20.h),
                    const ShopSchimmerSkeleton(height: 100),
                    Gap(5.h),
                    const ShopSchimmerSkeleton(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Build tabs based on freelancer status
    final List<AppTabItem> tabs = [
      AppTabItem(
        label: 'Services',
        content: ServiceSelectionScreen(
          shopId: widget.shopId,
          shopCurrency: widget.shopCurrency,
        ),
      ),
    ];

    // Only add Workers tab for shops (not freelancers)
    if (!widget.isFreelancer) {
      tabs.add(
        AppTabItem(label: 'Workers', content: const WorkerSelectionScreen()),
      );
    }

    // Add Time tab
    tabs.add(
      AppTabItem(
        label: 'Time',
        content: TimeSlotSelectionScreen(
          isFreelancer: widget.isFreelancer,
          shopCurrency: widget.shopCurrency,
        ),
      ),
    );

    // Add Address tab for traveling freelancers
    if (widget.isFreelancer && widget.canTravel) {
      tabs.add(
        AppTabItem(
          label: 'Address',
          content: BookingAddressStep(
            freelancerName: widget.shopName,
            freelancerLat: widget.latitude,
            freelancerLng: widget.longitude,
            travelRadiusKm: widget.travelRadiusKm ?? 10,
          ),
        ),
      );
    }

    // Add Confirm tab
    tabs.add(
      AppTabItem(
        label: 'Confirm',
        content: BookingConfirmationScreen(
          shopType: widget.shopType,
          shopName: widget.shopName,
          shopAddress: widget.shopAddress,
          shopCurrency: widget.shopCurrency,
          shopLogoUrl: widget.shopLogoUrl,
          latitude: widget.latitude,
          longitude: widget.longitude,
          // isFreelancer: widget.isFreelancer,
        ),
      ),
    );

    // Determine initial tab index
    int initialIndex = selectedServices.isNotEmpty ? 1 : 0;
    if (widget.isFreelancer) {
      initialIndex = selectedServices.isNotEmpty ? 1 : 0;
    }

    // Determine button text
    final totalSteps = tabs.length;
    final isLastStep = _currentTabIndex == totalSteps - 1;
    final buttonText = isLastStep ? 'Book' : 'Continue';

    return TabsWithContent(
      showCloseIcon: true,
      useNestedScrollMode: true,
      appBartext: buttonText,
      appBarOnPressed: _handleContinue,
      onControllerCreated: (controller) => _tabController = controller,
      onTabChangeRequest: (fromIndex, toIndex) {
        // Validate navigation based on freelancer status
        if (toIndex > fromIndex) {
          if (fromIndex == 0 && !_canProceedToWorkers()) {
            context.showErrorSnackbar('Please select at least one service');
            return false;
          }
          if (!widget.isFreelancer && fromIndex == 1 && !_canProceedToTime()) {
            context.showErrorSnackbar('Please select workers for all services');
            return false;
          }
          if (fromIndex == (widget.isFreelancer ? 1 : 2) &&
              !_canProceedToConfirm()) {
            context.showErrorSnackbar('Please select a time slot');
            return false;
          }
          // Block tapping past the address tab when address is missing.
          // The address tab index is 2 for freelancers (no workers step).
          // Block when: jumping FROM the address tab OR jumping over it
          // (e.g. tapping Confirm directly from Time).
          final hasAddressStep = widget.isFreelancer && widget.canTravel;
          if (hasAddressStep && !_canProceedToAddress()) {
            final addressTabIndex =
                2; // freelancer: Services(0) Time(1) Address(2) Confirm(3)
            if (toIndex > addressTabIndex) {
              context.showErrorSnackbar(
                'Please select a valid service address',
              );
              return false;
            }
          }
        }
        return true;
      },
      onTabChanged: (index) {
        if (mounted) setState(() => _currentTabIndex = index);
      },
      tabs: tabs,
      initialIndex: initialIndex.clamp(0, tabs.length - 1),
      scrollable: false,
      showContent: true,
    );
  }
}
