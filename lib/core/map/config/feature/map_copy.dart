import 'package:equatable/equatable.dart';

/// User-facing copy used by the engine. All fields have sensible defaults
/// so a minimal `MapConfig` doesn't need to fill any of these out.
class MapCopy extends Equatable {
  final String emptyStateSubtitle;
  final String errorRetryLabel;
  final String locationPermissionTitle;
  final String locationPermissionBody;
  final String locationPermissionCancelLabel;
  final String locationPermissionOpenSettingsLabel;
  final String appLocationMissingSnackbar;
  final String searchThisAreaLabel;
  final String filtersLabel;
  final String deviceLocationLabel;
  final String appLocationLabel;
  final String mapLoadErrorLabel;
  final String loadingLabel;

  const MapCopy({
    this.emptyStateSubtitle = 'No results in this area.',
    this.errorRetryLabel = 'Retry',
    this.locationPermissionTitle = 'Location Permission Required',
    this.locationPermissionBody =
        'Please enable location permission to see results near you. '
            'You can change this in your device settings.',
    this.locationPermissionCancelLabel = 'Cancel',
    this.locationPermissionOpenSettingsLabel = 'Open Settings',
    this.appLocationMissingSnackbar = 'Set your location first.',
    this.searchThisAreaLabel = 'Search this area',
    this.filtersLabel = 'Filters',
    this.deviceLocationLabel = 'Use my current location',
    this.appLocationLabel = 'Use my saved location',
    this.mapLoadErrorLabel = "We couldn't load shops in this area.",
    this.loadingLabel = 'Finding shops nearby...',
  });

  @override
  List<Object?> get props => [
    emptyStateSubtitle,
    errorRetryLabel,
    locationPermissionTitle,
    locationPermissionBody,
    locationPermissionCancelLabel,
    locationPermissionOpenSettingsLabel,
    appLocationMissingSnackbar,
    searchThisAreaLabel,
    filtersLabel,
    deviceLocationLabel,
    appLocationLabel,
    mapLoadErrorLabel,
    loadingLabel,
  ];
}
