// Products sold by an account (across all of its shops), for the profile
// "Buys" tab. Resolves the profile user's shops, then merges each shop's
// products into one list.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/product_providers.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_repository_provider.dart';

/// All products across every shop owned by [profileUserId].
/// Empty list when the user has no shops or no products.
final accountProductsProvider =
    FutureProvider.autoDispose.family<List<ProductModel>, String>(
  (ref, profileUserId) async {
    final shops =
        await ref.watch(shopRepositoryProvider).getShopsByProfileId(profileUserId);
    if (shops.isEmpty) return const [];

    final productRepo = ref.watch(productRepositoryProvider);
    final results = await Future.wait(
      shops.map((s) => productRepo.getShopProducts(s.id)),
    );
    // Flatten the per-shop lists into one.
    return [for (final list in results) ...list];
  },
);
