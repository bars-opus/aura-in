// lib/features/booking/presentation/screens/service_address_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/app_text_form_field.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/presentation/features/currency/domain/entities/parsed_address.dart';

/// Screen for capturing service address when booking a traveling freelancer
class ServiceAddressScreen extends ConsumerStatefulWidget {
  final String freelancerId;
  final String freelancerName;
  final double freelancerLat;
  final double freelancerLng;
  final int travelRadiusKm;

  const ServiceAddressScreen({
    super.key,
    required this.freelancerId,
    required this.freelancerName,
    required this.freelancerLat,
    required this.freelancerLng,
    required this.travelRadiusKm,
  });

  @override
  ConsumerState<ServiceAddressScreen> createState() =>
      _ServiceAddressScreenState();
}

class _ServiceAddressScreenState extends ConsumerState<ServiceAddressScreen> {
  final TextEditingController _addressController = TextEditingController();
  ParsedAddress? _selectedAddress;
  double? _distance;
  bool _isLoading = false;
  bool _isWithinRadius = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _openLocationPicker() async {
    final result = await showModalBottomSheet<ParsedAddress>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LocationPickerBottomSheet(),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedAddress = result;
        _addressController.text = result.fullAddress;
      });
      await _validateDistance(result);
    }
  }

  Future<void> _validateDistance(ParsedAddress address) async {
    if (address.latitude == null || address.longitude == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final locationService = ref.read(locationServiceProvider);
      final distance = locationService.calculateDistance(
        widget.freelancerLat,
        widget.freelancerLng,
        address.latitude!,
        address.longitude!,
      );

      setState(() {
        _distance = distance;
        _isWithinRadius = distance <= widget.travelRadiusKm;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error validating distance: $e')));
    }
  }

  void _continueToBooking() {
    if (_selectedAddress == null || !_isWithinRadius) return;

    Navigator.pop(context, _selectedAddress);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Address'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Spacing.lg.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: EdgeInsets.all(Spacing.md.h),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: colorScheme.primary),
                  Gap(Spacing.sm.w),
                  Expanded(
                    child: Text(
                      '${widget.freelancerName} travels up to ${widget.travelRadiusKm}km. '
                      'Please provide your service address to check if they can serve your area.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Gap(Spacing.xl.h),

            // Address input
            Text(
              'Service Address',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(Spacing.sm.h),
            GestureDetector(
              onTap: _openLocationPicker,
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
                            'Tap to select address',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              _selectedAddress != null
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
            Gap(Spacing.md.h),

            // Distance validation result
            if (_isLoading)
              const Center(child: CircularLoadingIndicator(
         
        ),)
            else if (_distance != null) ...[
              Container(
                padding: EdgeInsets.all(Spacing.md.h),
                decoration: BoxDecoration(
                  color:
                      _isWithinRadius
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isWithinRadius ? Icons.check_circle : Icons.warning,
                      color: _isWithinRadius ? Colors.green : Colors.red,
                    ),
                    Gap(Spacing.md.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isWithinRadius
                                ? 'Great! You\'re within service area'
                                : 'Outside service area',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color:
                                  _isWithinRadius ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            'Distance: ${_distance!.toStringAsFixed(1)}km / ${widget.travelRadiusKm}km limit',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            Gap(Spacing.xl.h),

            // Continue button
            AppButton(
              label: 'Continue to Booking',
              onPressed:
                  _selectedAddress != null && _isWithinRadius && !_isLoading
                      ? _continueToBooking
                      : null,
              width: double.infinity,
              height: 48.h,
            ),
          ],
        ),
      ),
    );
  }
}
