// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dead_letter_withdrawals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deadLetterWithdrawalsHash() =>
    r'bd6d979c1d4419132620792ead1a2c3b6f4172d6';

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

/// See also [deadLetterWithdrawals].
@ProviderFor(deadLetterWithdrawals)
const deadLetterWithdrawalsProvider = DeadLetterWithdrawalsFamily();

/// See also [deadLetterWithdrawals].
class DeadLetterWithdrawalsFamily
    extends Family<AsyncValue<List<WithdrawalRequestModel>>> {
  /// See also [deadLetterWithdrawals].
  const DeadLetterWithdrawalsFamily();

  /// See also [deadLetterWithdrawals].
  DeadLetterWithdrawalsProvider call(
    String shopId,
  ) {
    return DeadLetterWithdrawalsProvider(
      shopId,
    );
  }

  @override
  DeadLetterWithdrawalsProvider getProviderOverride(
    covariant DeadLetterWithdrawalsProvider provider,
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
  String? get name => r'deadLetterWithdrawalsProvider';
}

/// See also [deadLetterWithdrawals].
class DeadLetterWithdrawalsProvider
    extends AutoDisposeStreamProvider<List<WithdrawalRequestModel>> {
  /// See also [deadLetterWithdrawals].
  DeadLetterWithdrawalsProvider(
    String shopId,
  ) : this._internal(
          (ref) => deadLetterWithdrawals(
            ref as DeadLetterWithdrawalsRef,
            shopId,
          ),
          from: deadLetterWithdrawalsProvider,
          name: r'deadLetterWithdrawalsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deadLetterWithdrawalsHash,
          dependencies: DeadLetterWithdrawalsFamily._dependencies,
          allTransitiveDependencies:
              DeadLetterWithdrawalsFamily._allTransitiveDependencies,
          shopId: shopId,
        );

  DeadLetterWithdrawalsProvider._internal(
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
    Stream<List<WithdrawalRequestModel>> Function(
            DeadLetterWithdrawalsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeadLetterWithdrawalsProvider._internal(
        (ref) => create(ref as DeadLetterWithdrawalsRef),
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
  AutoDisposeStreamProviderElement<List<WithdrawalRequestModel>>
      createElement() {
    return _DeadLetterWithdrawalsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeadLetterWithdrawalsProvider && other.shopId == shopId;
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
mixin DeadLetterWithdrawalsRef
    on AutoDisposeStreamProviderRef<List<WithdrawalRequestModel>> {
  /// The parameter `shopId` of this provider.
  String get shopId;
}

class _DeadLetterWithdrawalsProviderElement
    extends AutoDisposeStreamProviderElement<List<WithdrawalRequestModel>>
    with DeadLetterWithdrawalsRef {
  _DeadLetterWithdrawalsProviderElement(super.provider);

  @override
  String get shopId => (origin as DeadLetterWithdrawalsProvider).shopId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
