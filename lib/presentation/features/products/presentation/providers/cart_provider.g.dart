// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cartNotifierHash() => r'bd9abf38478c6a8dbcc2d4ae6af308aa05fb7f1b';

/// Cart is **per-user**. Storage key is namespaced by `auth.uid()` so
/// signing out and back in as a different user on the same device does
/// not surface the previous user's cart. Sign-out triggers a rebuild
/// (via ref.watch on currentUserProvider) that re-loads from the new
/// (or guest) bucket.
///
/// keepAlive: the cart is app-wide state. Without it the autoDispose notifier
/// is torn down whenever no widget watches it (e.g. navigating away from
/// ProductDetailScreen back to Discover), so opening CartScreen rebuilds from
/// `const CartState()` and shows empty until the async storage reload resolves.
/// Keeping it alive preserves the in-memory cart and a correct badge count.
///
/// Copied from [CartNotifier].
@ProviderFor(CartNotifier)
final cartNotifierProvider = NotifierProvider<CartNotifier, CartState>.internal(
  CartNotifier.new,
  name: r'cartNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cartNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CartNotifier = Notifier<CartState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
