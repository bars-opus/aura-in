// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shopAppointmentSlotsHash() =>
    r'4774a48e010a4baa7955c4beaa3140c72edbbd1f';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for fetching appointment slots for the selected shop
///
/// Copied from [shopAppointmentSlots].
@ProviderFor(shopAppointmentSlots)
const shopAppointmentSlotsProvider = ShopAppointmentSlotsFamily();

/// Provider for fetching appointment slots for the selected shop
///
/// Copied from [shopAppointmentSlots].
class ShopAppointmentSlotsFamily
    extends Family<AsyncValue<List<AppointmentSlotDTO>>> {
  /// Provider for fetching appointment slots for the selected shop
  ///
  /// Copied from [shopAppointmentSlots].
  const ShopAppointmentSlotsFamily();

  /// Provider for fetching appointment slots for the selected shop
  ///
  /// Copied from [shopAppointmentSlots].
  ShopAppointmentSlotsProvider call({
    required String shopId,
  }) {
    return ShopAppointmentSlotsProvider(
      shopId: shopId,
    );
  }

  @override
  ShopAppointmentSlotsProvider getProviderOverride(
    covariant ShopAppointmentSlotsProvider provider,
  ) {
    return call(
      shopId: provider.shopId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'shopAppointmentSlotsProvider';
}

/// Provider for fetching appointment slots for the selected shop
///
/// Copied from [shopAppointmentSlots].
class ShopAppointmentSlotsProvider
    extends AutoDisposeFutureProvider<List<AppointmentSlotDTO>> {
  /// Provider for fetching appointment slots for the selected shop
  ///
  /// Copied from [shopAppointmentSlots].
  ShopAppointmentSlotsProvider({
    required String shopId,
  }) : this._internal(
          (ref) => shopAppointmentSlots(
            ref as ShopAppointmentSlotsRef,
            shopId: shopId,
          ),
          from: shopAppointmentSlotsProvider,
          name: r'shopAppointmentSlotsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shopAppointmentSlotsHash,
          dependencies: ShopAppointmentSlotsFamily._dependencies,
          allTransitiveDependencies:
              ShopAppointmentSlotsFamily._allTransitiveDependencies,
          shopId: shopId,
        );

  ShopAppointmentSlotsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.shopId,
  }) : super.internal();

  final String shopId;

  @override
  Override overrideWith(
    FutureOr<List<AppointmentSlotDTO>> Function(
            ShopAppointmentSlotsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShopAppointmentSlotsProvider._internal(
        (ref) => create(ref as ShopAppointmentSlotsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        shopId: shopId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<AppointmentSlotDTO>> createElement() {
    return _ShopAppointmentSlotsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShopAppointmentSlotsProvider && other.shopId == shopId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, shopId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ShopAppointmentSlotsRef
    on AutoDisposeFutureProviderRef<List<AppointmentSlotDTO>> {
  /// The parameter `shopId` of this provider.
  String get shopId;
}

class _ShopAppointmentSlotsProviderElement
    extends AutoDisposeFutureProviderElement<List<AppointmentSlotDTO>>
    with ShopAppointmentSlotsRef {
  _ShopAppointmentSlotsProviderElement(super.provider);

  @override
  String get shopId => (origin as ShopAppointmentSlotsProvider).shopId;
}

String _$shopWorkersHash() => r'4a1e3f74bbf959bbecb717f67a2b7ce34c94b514';

/// Provider for fetching all workers for the selected shop
/// Provider for fetching all workers for the selected shop
///
/// Copied from [shopWorkers].
@ProviderFor(shopWorkers)
const shopWorkersProvider = ShopWorkersFamily();

/// Provider for fetching all workers for the selected shop
/// Provider for fetching all workers for the selected shop
///
/// Copied from [shopWorkers].
class ShopWorkersFamily extends Family<AsyncValue<List<WorkerDTO>>> {
  /// Provider for fetching all workers for the selected shop
  /// Provider for fetching all workers for the selected shop
  ///
  /// Copied from [shopWorkers].
  const ShopWorkersFamily();

  /// Provider for fetching all workers for the selected shop
  /// Provider for fetching all workers for the selected shop
  ///
  /// Copied from [shopWorkers].
  ShopWorkersProvider call({
    required String shopId,
  }) {
    return ShopWorkersProvider(
      shopId: shopId,
    );
  }

  @override
  ShopWorkersProvider getProviderOverride(
    covariant ShopWorkersProvider provider,
  ) {
    return call(
      shopId: provider.shopId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'shopWorkersProvider';
}

/// Provider for fetching all workers for the selected shop
/// Provider for fetching all workers for the selected shop
///
/// Copied from [shopWorkers].
class ShopWorkersProvider extends AutoDisposeFutureProvider<List<WorkerDTO>> {
  /// Provider for fetching all workers for the selected shop
  /// Provider for fetching all workers for the selected shop
  ///
  /// Copied from [shopWorkers].
  ShopWorkersProvider({
    required String shopId,
  }) : this._internal(
          (ref) => shopWorkers(
            ref as ShopWorkersRef,
            shopId: shopId,
          ),
          from: shopWorkersProvider,
          name: r'shopWorkersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shopWorkersHash,
          dependencies: ShopWorkersFamily._dependencies,
          allTransitiveDependencies:
              ShopWorkersFamily._allTransitiveDependencies,
          shopId: shopId,
        );

  ShopWorkersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.shopId,
  }) : super.internal();

  final String shopId;

  @override
  Override overrideWith(
    FutureOr<List<WorkerDTO>> Function(ShopWorkersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShopWorkersProvider._internal(
        (ref) => create(ref as ShopWorkersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        shopId: shopId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<WorkerDTO>> createElement() {
    return _ShopWorkersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShopWorkersProvider && other.shopId == shopId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, shopId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ShopWorkersRef on AutoDisposeFutureProviderRef<List<WorkerDTO>> {
  /// The parameter `shopId` of this provider.
  String get shopId;
}

class _ShopWorkersProviderElement
    extends AutoDisposeFutureProviderElement<List<WorkerDTO>>
    with ShopWorkersRef {
  _ShopWorkersProviderElement(super.provider);

  @override
  String get shopId => (origin as ShopWorkersProvider).shopId;
}

String _$slotWorkerAssignmentsHash() =>
    r'75b0410625d848c9f2469c858340a8c27c9cca74';

/// Provider for fetching slot-worker assignments for the selected shop
///
/// Copied from [slotWorkerAssignments].
@ProviderFor(slotWorkerAssignments)
const slotWorkerAssignmentsProvider = SlotWorkerAssignmentsFamily();

/// Provider for fetching slot-worker assignments for the selected shop
///
/// Copied from [slotWorkerAssignments].
class SlotWorkerAssignmentsFamily
    extends Family<AsyncValue<Map<String, List<String>>>> {
  /// Provider for fetching slot-worker assignments for the selected shop
  ///
  /// Copied from [slotWorkerAssignments].
  const SlotWorkerAssignmentsFamily();

  /// Provider for fetching slot-worker assignments for the selected shop
  ///
  /// Copied from [slotWorkerAssignments].
  SlotWorkerAssignmentsProvider call({
    required String shopId,
  }) {
    return SlotWorkerAssignmentsProvider(
      shopId: shopId,
    );
  }

  @override
  SlotWorkerAssignmentsProvider getProviderOverride(
    covariant SlotWorkerAssignmentsProvider provider,
  ) {
    return call(
      shopId: provider.shopId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'slotWorkerAssignmentsProvider';
}

/// Provider for fetching slot-worker assignments for the selected shop
///
/// Copied from [slotWorkerAssignments].
class SlotWorkerAssignmentsProvider
    extends AutoDisposeFutureProvider<Map<String, List<String>>> {
  /// Provider for fetching slot-worker assignments for the selected shop
  ///
  /// Copied from [slotWorkerAssignments].
  SlotWorkerAssignmentsProvider({
    required String shopId,
  }) : this._internal(
          (ref) => slotWorkerAssignments(
            ref as SlotWorkerAssignmentsRef,
            shopId: shopId,
          ),
          from: slotWorkerAssignmentsProvider,
          name: r'slotWorkerAssignmentsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$slotWorkerAssignmentsHash,
          dependencies: SlotWorkerAssignmentsFamily._dependencies,
          allTransitiveDependencies:
              SlotWorkerAssignmentsFamily._allTransitiveDependencies,
          shopId: shopId,
        );

  SlotWorkerAssignmentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.shopId,
  }) : super.internal();

  final String shopId;

  @override
  Override overrideWith(
    FutureOr<Map<String, List<String>>> Function(
            SlotWorkerAssignmentsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SlotWorkerAssignmentsProvider._internal(
        (ref) => create(ref as SlotWorkerAssignmentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        shopId: shopId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, List<String>>> createElement() {
    return _SlotWorkerAssignmentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SlotWorkerAssignmentsProvider && other.shopId == shopId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, shopId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SlotWorkerAssignmentsRef
    on AutoDisposeFutureProviderRef<Map<String, List<String>>> {
  /// The parameter `shopId` of this provider.
  String get shopId;
}

class _SlotWorkerAssignmentsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, List<String>>>
    with SlotWorkerAssignmentsRef {
  _SlotWorkerAssignmentsProviderElement(super.provider);

  @override
  String get shopId => (origin as SlotWorkerAssignmentsProvider).shopId;
}

String _$workersForSlotHash() => r'eff7100c489bae80d1366c62db1994b0837ecdd7';

/// Combined provider that returns workers for a specific slot
///
/// Copied from [workersForSlot].
@ProviderFor(workersForSlot)
const workersForSlotProvider = WorkersForSlotFamily();

/// Combined provider that returns workers for a specific slot
///
/// Copied from [workersForSlot].
class WorkersForSlotFamily extends Family<AsyncValue<List<WorkerDTO>>> {
  /// Combined provider that returns workers for a specific slot
  ///
  /// Copied from [workersForSlot].
  const WorkersForSlotFamily();

  /// Combined provider that returns workers for a specific slot
  ///
  /// Copied from [workersForSlot].
  WorkersForSlotProvider call({
    required String shopId,
    required String slotId,
  }) {
    return WorkersForSlotProvider(
      shopId: shopId,
      slotId: slotId,
    );
  }

  @override
  WorkersForSlotProvider getProviderOverride(
    covariant WorkersForSlotProvider provider,
  ) {
    return call(
      shopId: provider.shopId,
      slotId: provider.slotId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'workersForSlotProvider';
}

/// Combined provider that returns workers for a specific slot
///
/// Copied from [workersForSlot].
class WorkersForSlotProvider
    extends AutoDisposeFutureProvider<List<WorkerDTO>> {
  /// Combined provider that returns workers for a specific slot
  ///
  /// Copied from [workersForSlot].
  WorkersForSlotProvider({
    required String shopId,
    required String slotId,
  }) : this._internal(
          (ref) => workersForSlot(
            ref as WorkersForSlotRef,
            shopId: shopId,
            slotId: slotId,
          ),
          from: workersForSlotProvider,
          name: r'workersForSlotProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$workersForSlotHash,
          dependencies: WorkersForSlotFamily._dependencies,
          allTransitiveDependencies:
              WorkersForSlotFamily._allTransitiveDependencies,
          shopId: shopId,
          slotId: slotId,
        );

  WorkersForSlotProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.shopId,
    required this.slotId,
  }) : super.internal();

  final String shopId;
  final String slotId;

  @override
  Override overrideWith(
    FutureOr<List<WorkerDTO>> Function(WorkersForSlotRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WorkersForSlotProvider._internal(
        (ref) => create(ref as WorkersForSlotRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        shopId: shopId,
        slotId: slotId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<WorkerDTO>> createElement() {
    return _WorkersForSlotProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkersForSlotProvider &&
        other.shopId == shopId &&
        other.slotId == slotId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, shopId.hashCode);
    hash = _SystemHash.combine(hash, slotId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WorkersForSlotRef on AutoDisposeFutureProviderRef<List<WorkerDTO>> {
  /// The parameter `shopId` of this provider.
  String get shopId;

  /// The parameter `slotId` of this provider.
  String get slotId;
}

class _WorkersForSlotProviderElement
    extends AutoDisposeFutureProviderElement<List<WorkerDTO>>
    with WorkersForSlotRef {
  _WorkersForSlotProviderElement(super.provider);

  @override
  String get shopId => (origin as WorkersForSlotProvider).shopId;
  @override
  String get slotId => (origin as WorkersForSlotProvider).slotId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
