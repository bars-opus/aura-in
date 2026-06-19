// lib/features/freelancer/creation/presentation/screens/freelancer_location_screen.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/utils/location/location_search_mode.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_creation_provider.dart';

/// Screen for freelancer to set base location and travel radius
/// Reuses the existing LocationPickerBottomSheet for location selection
class FreelancerLocationScreen extends ConsumerStatefulWidget {
  const FreelancerLocationScreen({super.key});

  @override
  ConsumerState<FreelancerLocationScreen> createState() =>
      _FreelancerLocationScreenState();
}

class _FreelancerLocationScreenState
    extends ConsumerState<FreelancerLocationScreen> {
  double _travelRadius = 10; // km
  bool _canTravel = true;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final draft = ref.read(freelancerCreationProvider);
    if (draft.baseLatitude != null && draft.baseLongitude != null) {
      _travelRadius = draft.travelRadiusKm.toDouble();
      _canTravel = draft.canTravel;
    }
  }

  Future<void> _openLocationPicker() async {
    await BottomSheetUtils.showDocumentationBottomSheet(
      maxHeight: 500.h,
      context: context,
      widget: LocationPickerBottomSheet(
        mode: LocationSearchMode.address,
        onLocationSelected: (address) {
          ref
              .read(freelancerCreationProvider.notifier)
              .updateLocation(
                latitude: address.latitude,
                longitude: address.longitude,
                travelRadiusKm: _travelRadius.toInt(),
                canTravel: _canTravel,
              );
        },
      ),
    );
  }

  void _autoSave() {
    final draft = ref.read(freelancerCreationProvider);
    if (draft.baseLatitude != null && draft.baseLongitude != null) {
      ref
          .read(freelancerCreationProvider.notifier)
          .updateLocation(
            latitude: draft.baseLatitude,
            longitude: draft.baseLongitude,
            travelRadiusKm: _travelRadius.toInt(),
            canTravel: _canTravel,
          );
    }
  }

  void _saveLocation() {
    final draft = ref.read(freelancerCreationProvider);
    if (draft.baseLatitude != null && draft.baseLongitude != null) {
      Navigator.pop(context);
      context.push('/freelancerToolsScreen');
    } else {
      context.showErrorSnackbar('Please select a location first');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final draft = ref.watch(freelancerCreationProvider);
    final hasLocation =
        draft.baseLatitude != null && draft.baseLongitude != null;

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(backgroundColor: Colors.transparent),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Spacing.md.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SemanticContainerWidget(
              content:
                  'Enter the city, coummunity or region you would like to work in.',
              icon: Icons.location_city_rounded,
              title: 'Enter your location',
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              borderColor: colorScheme.primary,
              iconColor: colorScheme.primary,
              textTheme: theme.textTheme,
            ),
            Gap(Spacing.md.h),
            // Location Selection Card
            CardInkWell(
              margin: EdgeInsets.only(bottom: Spacing.md.h),

              child: InfoRowWidget(
                subtitle: 'Base Location',
                title:
                    draft.baseLatitude != null && draft.baseLongitude != null
                        ? 'Lat: ${draft.baseLatitude!.toStringAsFixed(4)}, '
                            'Lng: ${draft.baseLongitude!.toStringAsFixed(4)}'
                        : 'Tap to select your base location',
                icon: Icons.location_on,
                avatarRadius: 25.h,
                onTap: _openLocationPicker,
                showAvatar: true,
                showTrailingArrow: false,
                showDivider: false,
                trailing: AppIconButton(
                  icon: Icons.add,
                  onPressed: _openLocationPicker,
                ),
              ),
            ),
            // Travel radius slider
            CardInkWell(
              margin: EdgeInsets.only(bottom: Spacing.md.h),
              child: Column(
                children: [
                  Text(
                    'Travel Radius',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Gap(Spacing.sm.h),
                  AppDivider(),
                  Gap(Spacing.sm.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'How far are you willing to travel?',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      MiniContainerIndicator(
                        color: colorScheme.primary,
                        text: '${_travelRadius.toInt()} km',
                        fontSize: 20,
                      ),
                    ],
                  ),
                  Gap(Spacing.md.h),
                  Slider(
                    value: _travelRadius,
                    min: 5,
                    max: 50,
                    divisions: 45,
                    label: '${_travelRadius.toInt()} km',
                    onChanged: (value) {
                      setState(() {
                        _travelRadius = value;
                      });
                      _autoSave();
                    },
                  ),
                  Text(
                    'You will serve clients within ${_travelRadius.toInt()}km of your base location',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Gap(Spacing.xl.h),
                  // Can travel toggle
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'I can travel to clients',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      _canTravel
                          ? 'You will travel to client locations'
                          : 'Clients must come to your location',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    value: _canTravel,
                    onChanged: (value) {
                      setState(() {
                        _canTravel = value;
                      });
                      _autoSave();
                    },
                    activeColor: colorScheme.primary,
                  ),
                ],
              ),
            ),

            Gap(Spacing.xl.h),

            if (!hasLocation)
              Padding(
                padding: EdgeInsets.only(top: Spacing.md.h),
                child: SemanticContainerWidget(
                  content: 'Please select a base location before saving',
                  icon: Icons.warning_amber_rounded,
                  title: '',
                  backgroundColor: colorScheme.warning.withOpacity(0.1),
                  borderColor: colorScheme.warning,
                  iconColor: colorScheme.warning,
                  textTheme: theme.textTheme,
                ),
              ),
          ],
        ),
      ),

      bottomNavigationBar:
          hasLocation
              ? SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(Spacing.md.h),
                  child: AppButton(
                    elevation: 0,
                    label: 'Continue to tools',
                    center: false,
                    iconData: FontAwesomeIcons.scissors,
                    prefixIcon: Icons.arrow_circle_right_outlined,
                    prefixIconColor: colorScheme.background,
                    onPressed: _saveLocation,
                    size: ButtonSize.small,
                    width: double.infinity,
                    padding: Spacing.horizontalMd,
                    height: 40.h,
                  ),
                ),
              )
              : null,
    );
  }
}
