// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_selection_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workerSelectionControllerHash() =>
    r'e6a5315af7b830513c584e1d74eecf05d1341781';

/// Controller responsible for worker selection and availability.
///
/// Handles loading available workers for each service and managing
/// the selection state for parallel group bookings.
///
/// Copied from [WorkerSelectionController].
@ProviderFor(WorkerSelectionController)
final workerSelectionControllerProvider = AutoDisposeNotifierProvider<
    WorkerSelectionController, WorkerAvailabilityState>.internal(
  WorkerSelectionController.new,
  name: r'workerSelectionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$workerSelectionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WorkerSelectionController
    = AutoDisposeNotifier<WorkerAvailabilityState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
