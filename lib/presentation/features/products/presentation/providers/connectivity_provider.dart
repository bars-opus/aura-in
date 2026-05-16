import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True when the device has *some* network connection (wifi/mobile/ethernet).
/// Used by checkout to gate the Place Order button — if we can't reach the
/// network, the request will fail anyway; failing fast with a clear banner
/// is better UX than a generic SnackBar after a timeout.
///
/// Falls back to `true` (connected) if connectivity_plus errors out — we
/// don't want to wrongly block the user when the package itself is broken.
final connectivityStreamProvider = StreamProvider<ConnectivityResult>(
  (ref) => Connectivity().onConnectivityChanged,
);

final isOnlineProvider = Provider<bool>((ref) {
  final async = ref.watch(connectivityStreamProvider);
  return async.maybeWhen(
    data: (result) => result != ConnectivityResult.none,
    orElse: () => true, // optimistic until first result lands
  );
});
