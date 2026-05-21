// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_transactions_paginated_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$walletTransactionsPaginatedHash() =>
    r'6fe3f13249046ef9f3e91dc3670ef237bf37fa80';

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

abstract class _$WalletTransactionsPaginated
    extends BuildlessAutoDisposeAsyncNotifier<List<WalletTransactionModel>> {
  late final String shopId;

  FutureOr<List<WalletTransactionModel>> build(
    String shopId,
  );
}

/// See also [WalletTransactionsPaginated].
@ProviderFor(WalletTransactionsPaginated)
const walletTransactionsPaginatedProvider = WalletTransactionsPaginatedFamily();

/// See also [WalletTransactionsPaginated].
class WalletTransactionsPaginatedFamily
    extends Family<AsyncValue<List<WalletTransactionModel>>> {
  /// See also [WalletTransactionsPaginated].
  const WalletTransactionsPaginatedFamily();

  /// See also [WalletTransactionsPaginated].
  WalletTransactionsPaginatedProvider call(
    String shopId,
  ) {
    return WalletTransactionsPaginatedProvider(
      shopId,
    );
  }

  @override
  WalletTransactionsPaginatedProvider getProviderOverride(
    covariant WalletTransactionsPaginatedProvider provider,
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
  String? get name => r'walletTransactionsPaginatedProvider';
}

/// See also [WalletTransactionsPaginated].
class WalletTransactionsPaginatedProvider
    extends AutoDisposeAsyncNotifierProviderImpl<WalletTransactionsPaginated,
        List<WalletTransactionModel>> {
  /// See also [WalletTransactionsPaginated].
  WalletTransactionsPaginatedProvider(
    String shopId,
  ) : this._internal(
          () => WalletTransactionsPaginated()..shopId = shopId,
          from: walletTransactionsPaginatedProvider,
          name: r'walletTransactionsPaginatedProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$walletTransactionsPaginatedHash,
          dependencies: WalletTransactionsPaginatedFamily._dependencies,
          allTransitiveDependencies:
              WalletTransactionsPaginatedFamily._allTransitiveDependencies,
          shopId: shopId,
        );

  WalletTransactionsPaginatedProvider._internal(
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
  FutureOr<List<WalletTransactionModel>> runNotifierBuild(
    covariant WalletTransactionsPaginated notifier,
  ) {
    return notifier.build(
      shopId,
    );
  }

  @override
  Override overrideWith(WalletTransactionsPaginated Function() create) {
    return ProviderOverride(
      origin: this,
      override: WalletTransactionsPaginatedProvider._internal(
        () => create()..shopId = shopId,
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
  AutoDisposeAsyncNotifierProviderElement<WalletTransactionsPaginated,
      List<WalletTransactionModel>> createElement() {
    return _WalletTransactionsPaginatedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletTransactionsPaginatedProvider &&
        other.shopId == shopId;
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
mixin WalletTransactionsPaginatedRef
    on AutoDisposeAsyncNotifierProviderRef<List<WalletTransactionModel>> {
  /// The parameter `shopId` of this provider.
  String get shopId;
}

class _WalletTransactionsPaginatedProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WalletTransactionsPaginated,
        List<WalletTransactionModel>> with WalletTransactionsPaginatedRef {
  _WalletTransactionsPaginatedProviderElement(super.provider);

  @override
  String get shopId => (origin as WalletTransactionsPaginatedProvider).shopId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
