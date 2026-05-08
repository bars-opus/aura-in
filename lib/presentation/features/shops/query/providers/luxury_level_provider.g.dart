// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'luxury_level_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$luxuryLevelListHash() => r'e205191b1edf3120fd38fd3eef2ad907875fa4db';

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

/// Provider that fetches luxury levels for a specific shop type
///
/// Copied from [luxuryLevelList].
@ProviderFor(luxuryLevelList)
const luxuryLevelListProvider = LuxuryLevelListFamily();

/// Provider that fetches luxury levels for a specific shop type
///
/// Copied from [luxuryLevelList].
class LuxuryLevelListFamily extends Family<AsyncValue<List<LuxuryLevelInfo>>> {
  /// Provider that fetches luxury levels for a specific shop type
  ///
  /// Copied from [luxuryLevelList].
  const LuxuryLevelListFamily();

  /// Provider that fetches luxury levels for a specific shop type
  ///
  /// Copied from [luxuryLevelList].
  LuxuryLevelListProvider call({
    required String shopType,
  }) {
    return LuxuryLevelListProvider(
      shopType: shopType,
    );
  }

  @override
  LuxuryLevelListProvider getProviderOverride(
    covariant LuxuryLevelListProvider provider,
  ) {
    return call(
      shopType: provider.shopType,
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
  String? get name => r'luxuryLevelListProvider';
}

/// Provider that fetches luxury levels for a specific shop type
///
/// Copied from [luxuryLevelList].
class LuxuryLevelListProvider
    extends AutoDisposeFutureProvider<List<LuxuryLevelInfo>> {
  /// Provider that fetches luxury levels for a specific shop type
  ///
  /// Copied from [luxuryLevelList].
  LuxuryLevelListProvider({
    required String shopType,
  }) : this._internal(
          (ref) => luxuryLevelList(
            ref as LuxuryLevelListRef,
            shopType: shopType,
          ),
          from: luxuryLevelListProvider,
          name: r'luxuryLevelListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$luxuryLevelListHash,
          dependencies: LuxuryLevelListFamily._dependencies,
          allTransitiveDependencies:
              LuxuryLevelListFamily._allTransitiveDependencies,
          shopType: shopType,
        );

  LuxuryLevelListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.shopType,
  }) : super.internal();

  final String shopType;

  @override
  Override overrideWith(
    FutureOr<List<LuxuryLevelInfo>> Function(LuxuryLevelListRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LuxuryLevelListProvider._internal(
        (ref) => create(ref as LuxuryLevelListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        shopType: shopType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<LuxuryLevelInfo>> createElement() {
    return _LuxuryLevelListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LuxuryLevelListProvider && other.shopType == shopType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, shopType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LuxuryLevelListRef
    on AutoDisposeFutureProviderRef<List<LuxuryLevelInfo>> {
  /// The parameter `shopType` of this provider.
  String get shopType;
}

class _LuxuryLevelListProviderElement
    extends AutoDisposeFutureProviderElement<List<LuxuryLevelInfo>>
    with LuxuryLevelListRef {
  _LuxuryLevelListProviderElement(super.provider);

  @override
  String get shopType => (origin as LuxuryLevelListProvider).shopType;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
