// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productRepositoryHash() => r'0d5f796534bcef694840213278163c5a2cf94fa0';

/// See also [productRepository].
@ProviderFor(productRepository)
final productRepositoryProvider =
    AutoDisposeProvider<ProductRepository>.internal(
  productRepository,
  name: r'productRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductRepositoryRef = AutoDisposeProviderRef<ProductRepository>;
String _$shopProductsHash() => r'0282e77ada3c70ceddb4b730731697f15d839d15';

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

/// See also [shopProducts].
@ProviderFor(shopProducts)
const shopProductsProvider = ShopProductsFamily();

/// See also [shopProducts].
class ShopProductsFamily extends Family<AsyncValue<List<ProductModel>>> {
  /// See also [shopProducts].
  const ShopProductsFamily();

  /// See also [shopProducts].
  ShopProductsProvider call(
    String shopId,
  ) {
    return ShopProductsProvider(
      shopId,
    );
  }

  @override
  ShopProductsProvider getProviderOverride(
    covariant ShopProductsProvider provider,
  ) {
    return call(
      provider.shopId,
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
  String? get name => r'shopProductsProvider';
}

/// See also [shopProducts].
class ShopProductsProvider
    extends AutoDisposeFutureProvider<List<ProductModel>> {
  /// See also [shopProducts].
  ShopProductsProvider(
    String shopId,
  ) : this._internal(
          (ref) => shopProducts(
            ref as ShopProductsRef,
            shopId,
          ),
          from: shopProductsProvider,
          name: r'shopProductsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shopProductsHash,
          dependencies: ShopProductsFamily._dependencies,
          allTransitiveDependencies:
              ShopProductsFamily._allTransitiveDependencies,
          shopId: shopId,
        );

  ShopProductsProvider._internal(
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
    FutureOr<List<ProductModel>> Function(ShopProductsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShopProductsProvider._internal(
        (ref) => create(ref as ShopProductsRef),
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
  AutoDisposeFutureProviderElement<List<ProductModel>> createElement() {
    return _ShopProductsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShopProductsProvider && other.shopId == shopId;
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
mixin ShopProductsRef on AutoDisposeFutureProviderRef<List<ProductModel>> {
  /// The parameter `shopId` of this provider.
  String get shopId;
}

class _ShopProductsProviderElement
    extends AutoDisposeFutureProviderElement<List<ProductModel>>
    with ShopProductsRef {
  _ShopProductsProviderElement(super.provider);

  @override
  String get shopId => (origin as ShopProductsProvider).shopId;
}

String _$productHash() => r'5e31eef1271d2b2845dce346d4377667e8209463';

/// See also [product].
@ProviderFor(product)
const productProvider = ProductFamily();

/// See also [product].
class ProductFamily extends Family<AsyncValue<ProductModel>> {
  /// See also [product].
  const ProductFamily();

  /// See also [product].
  ProductProvider call(
    String productId,
  ) {
    return ProductProvider(
      productId,
    );
  }

  @override
  ProductProvider getProviderOverride(
    covariant ProductProvider provider,
  ) {
    return call(
      provider.productId,
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
  String? get name => r'productProvider';
}

/// See also [product].
class ProductProvider extends AutoDisposeFutureProvider<ProductModel> {
  /// See also [product].
  ProductProvider(
    String productId,
  ) : this._internal(
          (ref) => product(
            ref as ProductRef,
            productId,
          ),
          from: productProvider,
          name: r'productProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productHash,
          dependencies: ProductFamily._dependencies,
          allTransitiveDependencies: ProductFamily._allTransitiveDependencies,
          productId: productId,
        );

  ProductProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String productId;

  @override
  Override overrideWith(
    FutureOr<ProductModel> Function(ProductRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductProvider._internal(
        (ref) => create(ref as ProductRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ProductModel> createElement() {
    return _ProductProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductProvider && other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductRef on AutoDisposeFutureProviderRef<ProductModel> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _ProductProviderElement
    extends AutoDisposeFutureProviderElement<ProductModel> with ProductRef {
  _ProductProviderElement(super.provider);

  @override
  String get productId => (origin as ProductProvider).productId;
}

String _$productFormNotifierHash() =>
    r'eb1be99eb375b537167bee002e06e9ceba11cbdd';

/// See also [ProductFormNotifier].
@ProviderFor(ProductFormNotifier)
final productFormNotifierProvider =
    AutoDisposeNotifierProvider<ProductFormNotifier, ProductFormState>.internal(
  ProductFormNotifier.new,
  name: r'productFormNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productFormNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProductFormNotifier = AutoDisposeNotifier<ProductFormState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
