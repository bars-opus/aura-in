import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/map/presentation/controllers/map_controller.dart';
import 'package:nano_embryo/core/utils/animations/animated_scale_fade.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';

/// Stacks the device-GPS and (optional) app-location FABs on the
/// right edge of the map.
///
/// The app-location FAB is hidden when [showAppLocationFab] is false
/// (i.e. when `MapConfig.appLocationProvider` is null).
class MapFabColumn extends StatelessWidget {
  final MapFetchMode fetchMode;
  final bool isFetchingGps;
  final bool isFetchingAppLocation;
  final bool showAppLocationFab;
  final VoidCallback onGpsPressed;
  final VoidCallback onAppLocationPressed;
  final String deviceLocationLabel;
  final String appLocationLabel;

  const MapFabColumn({
    super.key,
    required this.fetchMode,
    required this.isFetchingGps,
    required this.isFetchingAppLocation,
    required this.showAppLocationFab,
    required this.onGpsPressed,
    required this.onAppLocationPressed,
    required this.deviceLocationLabel,
    required this.appLocationLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScaleFade(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          child: Semantics(
            button: true,
            label: deviceLocationLabel,
            child: FloatingActionButton.small(
              heroTag: 'fab_gps',
              tooltip: deviceLocationLabel,
              backgroundColor: colorScheme.surface,
              onPressed: isFetchingGps ? null : onGpsPressed,
              child:
                  isFetchingGps
                      ? const CircularLoadingIndicator()
                      : Icon(
                        fetchMode == MapFetchMode.deviceGps
                            ? Icons.gps_fixed
                            : Icons.gps_not_fixed,
                        color:
                            fetchMode == MapFetchMode.deviceGps
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                      ),
            ),
          ),
        ),
        if (showAppLocationFab) ...[
          SizedBox(height: Spacing.sm.h),
          AnimatedScaleFade(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            child: Semantics(
              button: true,
              label: appLocationLabel,
              child: FloatingActionButton.small(
                heroTag: 'fab_app_location',
                tooltip: appLocationLabel,
                backgroundColor: colorScheme.surface,
                onPressed: isFetchingAppLocation ? null : onAppLocationPressed,
                child:
                    isFetchingAppLocation
                        ? const CircularLoadingIndicator()
                        : Icon(
                          fetchMode == MapFetchMode.appLocation
                              ? Icons.location_on
                              : Icons.location_on_outlined,
                          color:
                              fetchMode == MapFetchMode.appLocation
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                        ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
