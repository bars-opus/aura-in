// lib/presentation/features/discover/providers/discovery_seed_provider.dart
//
// Per-session seed for randomized discovery ordering. Held constant within a
// browse session (so offset pagination stays stable) and regenerated on
// pull-to-refresh via reshuffleDiscovery().
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _rng = Random();

/// A fresh 31-bit positive seed (fits a Postgres int4 / Dart int comfortably).
int newDiscoverySeed() => _rng.nextInt(1 << 31);

final discoverySeedProvider = StateProvider<int>((ref) => newDiscoverySeed());

/// Regenerate the seed so the next discovery load reshuffles.
void reshuffleDiscovery(Ref ref) {
  ref.read(discoverySeedProvider.notifier).state = newDiscoverySeed();
}
