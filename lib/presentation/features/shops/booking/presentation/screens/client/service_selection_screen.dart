// lib/features/booking/presentation/screens/service_selection_screen.dart
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/service_addons_sheet.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/service_addons_provider.dart';

final shopServicesProvider =
    shopAppointmentSlotsProvider; // Just alias or use directly

class ServiceSelectionScreen extends ConsumerStatefulWidget {
  final String shopId;
  final String shopCurrency;

  const ServiceSelectionScreen({
    Key? key,
    required this.shopId,
    required this.shopCurrency,
  }) : super(key: key);

  @override
  ConsumerState<ServiceSelectionScreen> createState() =>
      _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends ConsumerState<ServiceSelectionScreen>
    with AutomaticKeepAliveClientMixin {
  String _selectedCategory = 'All';
  List<String> _categories = [];

  // Add this after building the list to sync quantities with selected services
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncQuantities();
    });
  }

  void _syncQuantities() {
    final selectedServices = ref.read(selectedServicesProvider);
    ref
        .read(serviceQuantityProvider.notifier)
        .syncWithSelectedServices(selectedServices);
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // final shopId = ref.watch(selectedShopIdProvider);

    // Pass shopId to the provider
    final servicesAsync = ref.watch(
      shopAppointmentSlotsProvider(shopId: widget.shopId),
    );
    final selectedServices = ref.watch(selectedServicesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        children: [
          // Category chips
          servicesAsync.when(
            data: (services) {
              _categories = _extractCategories(services);
              return ServiceCategoryChips(
                categories: _categories,
                showAllOption: false,
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              );
            },
            loading:
                () => Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.md),
                  child: ShopSchimmerSkeleton(height: 50),
                ),
            error:
                (error, stack) => Center(
                  child: ErrorStateWidget(
                    showDetails: true,
                    compact: true,
                    title: 'Failed to load service',
                    subtitle: '',
                    errorDetails: '',
                    type: ErrorStateType.genericError,
                  ),
                ),
          ),
          servicesAsync.when(
            data: (services) {
              final filteredServices = _filterServices(services);

              if (filteredServices.isEmpty) {
                return Center(
                  child: EmptyStateWidget(
                    subtitle: 'No services available\nTry another category',
                  ),
                );
              }

              return SizedBox(
                height: services.length * 250.h,
                child: ListView.builder(
                  // padding: EdgeInsets.all(Spacing.md.w),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = filteredServices[index];
                    final isSelected = selectedServices.any(
                      (s) => s.id == service.id,
                    );

                    return ServiceTicketWidget(
                      service: service,
                      isSelected: isSelected,
                      onTap: () => _toggleService(service),
                      currency: widget.shopCurrency,
                      showWorkerIndicator: true,
                    );
                  },
                ),
              );
            },
            loading:
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (i) => Padding(
                      padding: EdgeInsets.only(bottom: Spacing.md.w),
                      child: ShopSchimmerSkeleton(height: 200),
                    ),
                  ),
                ),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ],
      ),
    );
  }

  List<String> _extractCategories(List<AppointmentSlotDTO> services) {
    final categories = services.map((s) => s.serviceName).toSet().toList();
    categories.remove('All');
    categories.sort();
    return ['All', ...categories];
  }

  List<AppointmentSlotDTO> _filterServices(List<AppointmentSlotDTO> services) {
    if (_selectedCategory == 'All') return services;
    return services.where((s) => s.serviceName == _selectedCategory).toList();
  }

  void _toggleService(AppointmentSlotDTO service) {
    final currentSelected = ref.read(selectedServicesProvider);
    final selectedServicesNotifier = ref.read(
      selectedServicesProvider.notifier,
    );
    final quantityNotifier = ref.read(serviceQuantityProvider.notifier);

    if (currentSelected.any((s) => s.id == service.id)) {
      selectedServicesNotifier.removeService(service.id);
      quantityNotifier.removeService(service.id);
      ref.read(selectedWorkersProvider.notifier).removeService(service.id);
      ref.read(selectedAddonsProvider.notifier).clearSlot(service.id);
    } else {
      selectedServicesNotifier.addService(service);
      quantityNotifier.setQuantity(service.id, 1);
      // Show add-on picker if the slot has persisted add-ons.
      _showAddonsSheet(service);
    }
  }

  void _showAddonsSheet(AppointmentSlotDTO service) {
    // Only show if the slot has a real id (not a template pre-fill).
    if (service.id.isEmpty) return;
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      maxHeight: 520,
      widget: ServiceAddonsSheet(
        service: service,
        currency: widget.shopCurrency,
        onDone: () => Navigator.pop(context),
      ),
    );
  }
}
