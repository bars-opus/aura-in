import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/utils/location/location_search_mode.dart';
import 'package:nano_embryo/presentation/features/currency/domain/entities/parsed_address.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/providers/is_freelancer_provider.dart';

/// Address step embedded as a tab inside [BookingFlowScreen] for travelling
/// freelancers. Writes the validated address directly to [selectedAddressProvider]
/// so the flow's `_canProceedToAddress()` guard works correctly.
///
/// Replaces the old [ServiceAddressScreen] which was a full Scaffold designed
/// for route-based navigation — embedding it as a tab meant its AppBar showed
/// nested navigation chrome and `Navigator.pop` did nothing useful.
class BookingAddressStep extends ConsumerStatefulWidget {
  final String freelancerName;
  final double freelancerLat;
  final double freelancerLng;
  final int travelRadiusKm;

  const BookingAddressStep({
    super.key,
    required this.freelancerName,
    required this.freelancerLat,
    required this.freelancerLng,
    required this.travelRadiusKm,
  });

  @override
  ConsumerState<BookingAddressStep> createState() => _BookingAddressStepState();
}

class _BookingAddressStepState extends ConsumerState<BookingAddressStep> {
  bool _isValidating = false;
  double? _distanceKm;
  bool _isWithinRadius = false;

  Future<void> _openPicker() async {
    ParsedAddress? picked;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => LocationPickerBottomSheet(
            mode: LocationSearchMode.address,
            onLocationSelected: (address) {
              picked = address;
            },
          ),
    );

    if (picked != null && mounted) {
      await _validateAndCommit(picked!);
    }
  }

  Future<void> _validateAndCommit(ParsedAddress address) async {
    if (address.latitude == null || address.longitude == null) return;

    setState(() {
      _isValidating = true;
      _distanceKm = null;
      _isWithinRadius = false;
    });

    try {
      final locationService = ref.read(locationServiceProvider);
      final distance = locationService.calculateDistance(
        widget.freelancerLat,
        widget.freelancerLng,
        address.latitude!,
        address.longitude!,
      );

      final withinRadius = distance <= widget.travelRadiusKm;

      setState(() {
        _isValidating = false;
        _distanceKm = distance;
        _isWithinRadius = withinRadius;
      });

      if (withinRadius) {
        ref.read(selectedAddressProvider.notifier).setAddress(address);
      } else {
        ref.read(selectedAddressProvider.notifier).setAddress(null);
        if (mounted) {
          context.showErrorSnackbar(
            'That address is ${distance.toStringAsFixed(1)}km away — '
            '${widget.freelancerName} only travels ${widget.travelRadiusKm}km.',
          );
        }
      }
    } catch (_) {
      setState(() => _isValidating = false);
      ref.read(selectedAddressProvider.notifier).setAddress(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final selectedAddress = ref.watch(selectedAddressProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.lg.w,
        vertical: Spacing.xl.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: EdgeInsets.all(Spacing.md.h),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary, size: 18),
                Gap(Spacing.sm.w),
                Expanded(
                  child: Text(
                    '${widget.freelancerName} travels up to '
                    '${widget.travelRadiusKm}km. Select where you\'d like '
                    'the service to be done.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Gap(Spacing.xl.h),

          Text(
            'Service address',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(Spacing.sm.h),

          // Address picker row
          GestureDetector(
            onTap: _openPicker,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.md.w,
                vertical: Spacing.md.h,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      selectedAddress != null
                          ? (_isWithinRadius
                              ? colorScheme.primary
                              : colorScheme.error)
                          : colorScheme.outline,
                  width: selectedAddress != null ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color:
                        selectedAddress != null
                            ? (_isWithinRadius
                                ? colorScheme.primary
                                : colorScheme.error)
                            : colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  Gap(Spacing.md.w),
                  Expanded(
                    child: Text(
                      selectedAddress?.fullAddress ??
                          'Tap to select your address',
                      style: textTheme.bodyMedium?.copyWith(
                        color:
                            selectedAddress != null
                                ? colorScheme.onSurface
                                : colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Gap(Spacing.sm.w),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),

          Gap(Spacing.md.h),

          // Validation feedback
          if (_isValidating)
            const Center(child: CircularLoadingIndicator())
          else if (_distanceKm != null) ...[
            Container(
              padding: EdgeInsets.all(Spacing.md.h),
              decoration: BoxDecoration(
                color:
                    _isWithinRadius
                        ? colorScheme.primary.withValues(alpha: 0.07)
                        : colorScheme.error.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    _isWithinRadius ? Icons.check_circle : Icons.cancel,
                    color:
                        _isWithinRadius
                            ? colorScheme.primary
                            : colorScheme.error,
                    size: 20,
                  ),
                  Gap(Spacing.sm.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isWithinRadius
                              ? 'Within service area'
                              : 'Outside service area',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                _isWithinRadius
                                    ? colorScheme.primary
                                    : colorScheme.error,
                          ),
                        ),
                        Text(
                          '${_distanceKm!.toStringAsFixed(1)} km '
                          '/ ${widget.travelRadiusKm} km limit',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Required-address reminder when nothing selected yet
          if (_distanceKm == null && !_isValidating) ...[
            Text(
              'An address is required to continue.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
