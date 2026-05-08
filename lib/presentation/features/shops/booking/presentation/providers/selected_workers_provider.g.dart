// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_workers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedWorkersHash() => r'f801252a0cb2b7363b193c3b3c7d0eb5e1d54298';

/// Provider that maps service IDs to selected workers.
///
/// This maintains the relationship between each selected service
/// and the worker chosen to perform it (if any).
///
/// ## Features
/// - Null values indicate no worker selected (for services that don't require one)
/// - Automatically cleans up when services are removed
/// - Used for worker availability checks
///
/// ## Usage
/// ```dart
/// // Get worker for a specific service
/// final worker = ref.watch(selectedWorkersProvider)[serviceId];
///
/// // Select a worker for a service
/// ref.read(selectedWorkersProvider.notifier).selectWorker(serviceId, worker);
///
/// Copied from [SelectedWorkers].
@ProviderFor(SelectedWorkers)
final selectedWorkersProvider = AutoDisposeNotifierProvider<SelectedWorkers,
    Map<String, List<Map<String, String?>>>>.internal(
  SelectedWorkers.new,
  name: r'selectedWorkersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedWorkersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedWorkers
    = AutoDisposeNotifier<Map<String, List<Map<String, String?>>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
