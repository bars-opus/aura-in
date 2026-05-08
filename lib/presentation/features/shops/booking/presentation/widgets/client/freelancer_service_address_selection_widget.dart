// lib/features/booking/presentation/widgets/service_address_selection_widget.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/currency/domain/entities/parsed_address.dart';
import 'package:nano_embryo/presentation/features/freelancer/presentation/providers/freelancer_details_provider.dart';

class FreelancerServiceAddressSelectionWidget extends ConsumerStatefulWidget {
  final String freelancerId;
  final Function(ParsedAddress, bool) onAddressValidated;

  const FreelancerServiceAddressSelectionWidget({
    super.key,
    required this.freelancerId,
    required this.onAddressValidated,
  });

  @override
  ConsumerState<FreelancerServiceAddressSelectionWidget> createState() =>
      _FreelancerServiceAddressSelectionWidgetState();
}

class _FreelancerServiceAddressSelectionWidgetState
    extends ConsumerState<FreelancerServiceAddressSelectionWidget> {
  ParsedAddress? _selectedAddress;
  bool _isValidating = false;
  bool _isValid = false;
  double? _distance;
  int? _travelRadius;

  @override
  void initState() {
    super.initState();
    _loadFreelancerData();
  }

  Future<void> _loadFreelancerData() async {
    final freelancer = await ref.read(
      freelancerDetailsProvider(widget.freelancerId).future,
    );
    if (freelancer != null && mounted) {
      setState(() {
        _travelRadius = freelancer.travelRadiusKm;
      });
    }
  }

  Future<void> _selectAddress() async {
    final result = await showModalBottomSheet<ParsedAddress>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LocationPickerBottomSheet(),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedAddress = result;
        _isValidating = true;
      });
      await _validateAddress(result);
    }
  }

  Future<void> _validateAddress(ParsedAddress address) async {
    if (address.latitude == null ||
        address.longitude == null ||
        _travelRadius == null) {
      setState(() {
        _isValidating = false;
        _isValid = false;
      });
      widget.onAddressValidated(_selectedAddress!, false);
      return;
    }

    try {
      final freelancer = await ref.read(
        freelancerDetailsProvider(widget.freelancerId).future,
      );
      if (freelancer == null) throw Exception('Freelancer not found');

      final locationService = ref.read(locationServiceProvider);
      final distance = locationService.calculateDistance(
        freelancer.baseLatitude!,
        freelancer.baseLongitude!,
        address.latitude!,
        address.longitude!,
      );

      final isValid = distance <= (freelancer.travelRadiusKm);

      setState(() {
        _distance = distance;
        _isValid = isValid;
        _isValidating = false;
      });

      widget.onAddressValidated(_selectedAddress!, isValid);
    } catch (e) {
      setState(() {
        _isValidating = false;
        _isValid = false;
      });
      widget.onAddressValidated(_selectedAddress!, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Address selection button
        GestureDetector(
          onTap: _selectAddress,
          child: Container(
            padding: EdgeInsets.all(Spacing.md.h),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color:
                      _selectedAddress != null
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.5),
                ),
                Gap(Spacing.md.w),
                Expanded(
                  child: Text(
                    _selectedAddress?.fullAddress ??
                        'Tap to select service address',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
        Gap(Spacing.md.h),

        // Validation result
        if (_isValidating)
          const Center(child: CircularLoadingIndicator())
        else if (_distance != null && _travelRadius != null)
          Container(
            padding: EdgeInsets.all(Spacing.md.h),
            decoration: BoxDecoration(
              color:
                  _isValid
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  _isValid ? Icons.check_circle : Icons.warning,
                  color: _isValid ? Colors.green : Colors.red,
                ),
                Gap(Spacing.md.w),
                Expanded(
                  child: Text(
                    _isValid
                        ? '✓ Within service area (${_distance!.toStringAsFixed(1)}km)'
                        : '✗ Outside service area (${_distance!.toStringAsFixed(1)}km / ${_travelRadius}km limit)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _isValid ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
