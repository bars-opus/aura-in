// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$walletRepositoryHash() => r'c343f31df4473f2031e38707ed4da4b99cdfc60b';

/// See also [walletRepository].
@ProviderFor(walletRepository)
final walletRepositoryProvider = AutoDisposeProvider<WalletRepository>.internal(
  walletRepository,
  name: r'walletRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$walletRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WalletRepositoryRef = AutoDisposeProviderRef<WalletRepository>;
String _$shopWalletHash() => r'cb947fc46c83a51e6cb13a9106d98dde87f81728';

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

/// See also [shopWallet].
@ProviderFor(shopWallet)
const shopWalletProvider = ShopWalletFamily();

/// See also [shopWallet].
class ShopWalletFamily extends Family<AsyncValue<WalletModel>> {
  /// See also [shopWallet].
  const ShopWalletFamily();

  /// See also [shopWallet].
  ShopWalletProvider call(
    String shopId,
  ) {
    return ShopWalletProvider(
      shopId,
    );
  }

  @override
  ShopWalletProvider getProviderOverride(
    covariant ShopWalletProvider provider,
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
  String? get name => r'shopWalletProvider';
}

/// See also [shopWallet].
class ShopWalletProvider extends AutoDisposeFutureProvider<WalletModel> {
  /// See also [shopWallet].
  ShopWalletProvider(
    String shopId,
  ) : this._internal(
          (ref) => shopWallet(
            ref as ShopWalletRef,
            shopId,
          ),
          from: shopWalletProvider,
          name: r'shopWalletProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shopWalletHash,
          dependencies: ShopWalletFamily._dependencies,
          allTransitiveDependencies:
              ShopWalletFamily._allTransitiveDependencies,
          shopId: shopId,
        );

  ShopWalletProvider._internal(
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
    FutureOr<WalletModel> Function(ShopWalletRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShopWalletProvider._internal(
        (ref) => create(ref as ShopWalletRef),
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
  AutoDisposeFutureProviderElement<WalletModel> createElement() {
    return _ShopWalletProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShopWalletProvider && other.shopId == shopId;
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
mixin ShopWalletRef on AutoDisposeFutureProviderRef<WalletModel> {
  /// The parameter `shopId` of this provider.
  String get shopId;
}

class _ShopWalletProviderElement
    extends AutoDisposeFutureProviderElement<WalletModel> with ShopWalletRef {
  _ShopWalletProviderElement(super.provider);

  @override
  String get shopId => (origin as ShopWalletProvider).shopId;
}

String _$walletTransactionsHash() =>
    r'07236fea5bc291cd8981e921b48dd1a8244d6e71';

/// See also [walletTransactions].
@ProviderFor(walletTransactions)
const walletTransactionsProvider = WalletTransactionsFamily();

/// See also [walletTransactions].
class WalletTransactionsFamily
    extends Family<AsyncValue<List<WalletTransactionModel>>> {
  /// See also [walletTransactions].
  const WalletTransactionsFamily();

  /// See also [walletTransactions].
  WalletTransactionsProvider call({
    required String shopId,
    int? limit,
    TransactionType? type,
  }) {
    return WalletTransactionsProvider(
      shopId: shopId,
      limit: limit,
      type: type,
    );
  }

  @override
  WalletTransactionsProvider getProviderOverride(
    covariant WalletTransactionsProvider provider,
  ) {
    return call(
      shopId: provider.shopId,
      limit: provider.limit,
      type: provider.type,
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
  String? get name => r'walletTransactionsProvider';
}

/// See also [walletTransactions].
class WalletTransactionsProvider
    extends AutoDisposeFutureProvider<List<WalletTransactionModel>> {
  /// See also [walletTransactions].
  WalletTransactionsProvider({
    required String shopId,
    int? limit,
    TransactionType? type,
  }) : this._internal(
          (ref) => walletTransactions(
            ref as WalletTransactionsRef,
            shopId: shopId,
            limit: limit,
            type: type,
          ),
          from: walletTransactionsProvider,
          name: r'walletTransactionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$walletTransactionsHash,
          dependencies: WalletTransactionsFamily._dependencies,
          allTransitiveDependencies:
              WalletTransactionsFamily._allTransitiveDependencies,
          shopId: shopId,
          limit: limit,
          type: type,
        );

  WalletTransactionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.shopId,
    required this.limit,
    required this.type,
  }) : super.internal();

  final String shopId;
  final int? limit;
  final TransactionType? type;

  @override
  Override overrideWith(
    FutureOr<List<WalletTransactionModel>> Function(
            WalletTransactionsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WalletTransactionsProvider._internal(
        (ref) => create(ref as WalletTransactionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        shopId: shopId,
        limit: limit,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<WalletTransactionModel>>
      createElement() {
    return _WalletTransactionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletTransactionsProvider &&
        other.shopId == shopId &&
        other.limit == limit &&
        other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, shopId.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WalletTransactionsRef
    on AutoDisposeFutureProviderRef<List<WalletTransactionModel>> {
  /// The parameter `shopId` of this provider.
  String get shopId;

  /// The parameter `limit` of this provider.
  int? get limit;

  /// The parameter `type` of this provider.
  TransactionType? get type;
}

class _WalletTransactionsProviderElement
    extends AutoDisposeFutureProviderElement<List<WalletTransactionModel>>
    with WalletTransactionsRef {
  _WalletTransactionsProviderElement(super.provider);

  @override
  String get shopId => (origin as WalletTransactionsProvider).shopId;
  @override
  int? get limit => (origin as WalletTransactionsProvider).limit;
  @override
  TransactionType? get type => (origin as WalletTransactionsProvider).type;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
