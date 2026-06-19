import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Min / max / default for the discover-screen search radius slider.
const double kSearchRadiusMinKm = 1;
const double kSearchRadiusMaxKm = 20;
const double kSearchRadiusDefaultKm = 2;

/// Discover-screen search radius (km).
///
/// Watched by all proximity-based discover providers (NearYouShopsList,
/// NearbyFreelancersList, nearYouFreelancersProvider, allFreelancersProvider).
/// When this changes, those providers refetch with the new radius.
final searchRadiusKmProvider = StateProvider<double>(
  (ref) => kSearchRadiusDefaultKm,
);
