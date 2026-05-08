// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_details_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shopDetailsHash() => r'2aae9006571eb4fc935d21a1300838cb0cf78aab';

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

/// See also [shopDetails].
@ProviderFor(shopDetails)
const shopDetailsProvider = ShopDetailsFamily();

/// See also [shopDetails].
class ShopDetailsFamily extends Family<AsyncValue<ShopDetailsDTO>> {
  /// See also [shopDetails].
  const ShopDetailsFamily();

  /// See also [shopDetails].
  ShopDetailsProvider call({
    required String shopId,
  }) {
    return ShopDetailsProvider(
      shopId: shopId,
    );
  }

  @override
  ShopDetailsProvider getProviderOverride(
    covariant ShopDetailsProvider provider,
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
  String? get name => r'shopDetailsProvider';
}

/// See also [shopDetails].
class ShopDetailsProvider extends AutoDisposeFutureProvider<ShopDetailsDTO> {
  /// See also [shopDetails].
  ShopDetailsProvider({
    required String shopId,
  }) : this._internal(
          (ref) => shopDetails(
            ref as ShopDetailsRef,
            shopId: shopId,
          ),
          from: shopDetailsProvider,
          name: r'shopDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shopDetailsHash,
          dependencies: ShopDetailsFamily._dependencies,
          allTransitiveDependencies:
              ShopDetailsFamily._allTransitiveDependencies,
          shopId: shopId,
        );

  ShopDetailsProvider._internal(
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
    FutureOr<ShopDetailsDTO> Function(ShopDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShopDetailsProvider._internal(
        (ref) => create(ref as ShopDetailsRef),
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
  AutoDisposeFutureProviderElement<ShopDetailsDTO> createElement() {
    return _ShopDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShopDetailsProvider && other.shopId == shopId;
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
mixin ShopDetailsRef on AutoDisposeFutureProviderRef<ShopDetailsDTO> {
  /// The parameter `shopId` of this provider.
  String get shopId;
}

class _ShopDetailsProviderElement
    extends AutoDisposeFutureProviderElement<ShopDetailsDTO>
    with ShopDetailsRef {
  _ShopDetailsProviderElement(super.provider);

  @override
  String get shopId => (origin as ShopDetailsProvider).shopId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
