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
      ];
}
