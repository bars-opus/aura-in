// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calendarRepositoryHash() =>
    r'b85934acab3bab5de159810a9d514ce57f72b52e';

/// See also [calendarRepository].
@ProviderFor(calendarRepository)
final calendarRepositoryProvider =
    AutoDisposeProvider<CalendarRepository>.internal(
  calendarRepository,
  name: r'calendarRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CalendarRepositoryRef = AutoDisposeProviderRef<CalendarRepository>;
String _$calendarControllerHash() =>
    r'8403f1dfdae902223deccfc7ae5a024c92750e83';

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

abstract class _$CalendarController
    extends BuildlessAutoDisposeAsyncNotifier<CalendarState> {
  late final String userIdOrShopId;
  late final bool isShopOwner;

  FutureOr<CalendarState> build({
    required String userIdOrShopId,
    required bool isShopOwner,
  });
}

/// See also [CalendarController].
@ProviderFor(CalendarController)
const calendarControllerProvider = CalendarControllerFamily();

/// See also [CalendarController].
class CalendarControllerFamily extends Family<AsyncValue<CalendarState>> {
  /// See also [CalendarController].
  const CalendarControllerFamily();

  /// See also [CalendarController].
  CalendarControllerProvider call({
    required String userIdOrShopId,
    required bool isShopOwner,
  }) {
    return CalendarControllerProvider(
      userIdOrShopId: userIdOrShopId,
      isShopOwner: isShopOwner,
    );
  }

  @override
  CalendarControllerProvider getProviderOverride(
    covariant CalendarControllerProvider provider,
  ) {
    return call(
      userIdOrShopId: provider.userIdOrShopId,
      isShopOwner: provider.isShopOwner,
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
  String? get name => r'calendarControllerProvider';
}

/// See also [CalendarController].
class CalendarControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    CalendarController, CalendarState> {
  /// See also [CalendarController].
  CalendarControllerProvider({
    required String userIdOrShopId,
    required bool isShopOwner,
  }) : this._internal(
          () => CalendarController()
            ..userIdOrShopId = userIdOrShopId
            ..isShopOwner = isShopOwner,
          from: calendarControllerProvider,
          name: r'calendarControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$calendarControllerHash,
          dependencies: CalendarControllerFamily._dependencies,
          allTransitiveDependencies:
              CalendarControllerFamily._allTransitiveDependencies,
          userIdOrShopId: userIdOrShopId,
          isShopOwner: isShopOwner,
        );

  CalendarControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userIdOrShopId,
    required this.isShopOwner,
  }) : super.internal();

  final String userIdOrShopId;
  final bool isShopOwner;

  @override
  FutureOr<CalendarState> runNotifierBuild(
    covariant CalendarController notifier,
  ) {
    return notifier.build(
      userIdOrShopId: userIdOrShopId,
      isShopOwner: isShopOwner,
    );
  }

  @override
  Override overrideWith(CalendarController Function() create) {
    return ProviderOverride(
      origin: this,
      override: CalendarControllerProvider._internal(
        () => create()
          ..userIdOrShopId = userIdOrShopId
          ..isShopOwner = isShopOwner,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userIdOrShopId: userIdOrShopId,
        isShopOwner: isShopOwner,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<CalendarController, CalendarState>
      createElement() {
    return _CalendarControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarControllerProvider &&
        other.userIdOrShopId == userIdOrShopId &&
        other.isShopOwner == isShopOwner;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userIdOrShopId.hashCode);
    hash = _SystemHash.combine(hash, isShopOwner.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CalendarControllerRef
    on AutoDisposeAsyncNotifierProviderRef<CalendarState> {
  /// The parameter `userIdOrShopId` of this provider.
  String get userIdOrShopId;

  /// The parameter `isShopOwner` of this provider.
  bool get isShopOwner;
}

class _CalendarControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<CalendarController,
        CalendarState> with CalendarControllerRef {
  _CalendarControllerProviderElement(super.provider);

  @override
  String get userIdOrShopId =>
      (origin as CalendarControllerProvider).userIdOrShopId;
  @override
  bool get isShopOwner => (origin as CalendarControllerProvider).isShopOwner;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
