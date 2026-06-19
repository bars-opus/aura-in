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

  const MapFabColumn({
    super.key,
    required this.fetchMode,
    required this.isFetchingGps,
    required this.isFetchingAppLocation,
    required this.showAppLocationFab,
    required this.onGpsPressed,
    required this.onAppLocationPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned(
          bottom: 200.h + Spacing.xxl.h + Spacing.xxl.h,
          right: Spacing.md.w,
          child: AnimatedScaleFade(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            child: FloatingActionButton.small(
              heroTag: 'fab_gps',
              backgroundColor: colorScheme.background,
              onPressed: onGpsPressed,
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
        if (showAppLocationFab)
          Positioned(
            bottom: 200.h + Spacing.lg.h + Spacing.md.h,
            right: Spacing.md.w,
            child: AnimatedScaleFade(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              child: FloatingActionButton.small(
                heroTag: 'fab_app_location',
                backgroundColor: colorScheme.background,
                onPressed: onAppLocationPressed,
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
    );
  }
}
