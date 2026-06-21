// Products sold by an account (across all of its shops), for the profile
// "Buys" tab. Paginates sequentially per shop: shop[0] fully, then shop[1], …
// so infinite scroll works for any number of shops without dup/skip.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/paginated_list_notifier.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/product_providers.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_repository_provider.dart';

class AccountProductsNotifier extends PagedListNotifier<ProductModel> {
  AccountProductsNotifier(this._ref, this._profileUserId);

  final Ref _ref;
  final String _profileUserId;

  // Resolved lazily on first fetch, then cached for the run.
  List<String>? _shopIds;
  // Cursor into the sequential walk: which shop, and that shop's next page.
  int _shopIndex = 0;
  int _shopPage = 0;

  Future<List<String>> _resolveShopIds() async {
    final shops = await _ref
        .read(shopRepositoryProvider)
        .getShopsByProfileId(_profileUserId);
    return shops.map((s) => s.id).toList();
  }

  @override
  Future<List<ProductModel>> fetchPage(int page, int limit) async {
    // The base passes a global page counter we don't use — we keep our own
    // per-shop cursor. On the first page (page == 0) reset the cursor so a
    // refresh() restarts the walk cleanly.
    if (page == 0) {
      _shopIds = null;
      _shopIndex = 0;
      _shopPage = 0;
    }
    _shopIds ??= await _resolveShopIds();
    final shopIds = _shopIds!;
    if (shopIds.isEmpty) return const [];

    final repo = _ref.read(productRepositoryProvider);

    // Walk shops sequentially until we collect a full page or run out.
    final collected = <ProductModel>[];
    while (_shopIndex < shopIds.length && collected.length < limit) {
      final remaining = limit - collected.length;
      final fetched = await repo.getShopProducts(
        shopIds[_shopIndex],
        limit: remaining,
        page: _shopPage,
      );
      collected.addAll(fetched);
      if (fetched.length < remaining) {
        // This shop is exhausted — advance to the next shop, page 0.
        _shopIndex++;
        _shopPage = 0;
      } else {
        // Filled the request from this shop; its next page continues here.
        _shopPage++;
      }
    }
    // Returning < limit signals hasMore=false to the base notifier, which is
    // correct only when every shop is exhausted (the while-loop exits on
    // _shopIndex >= length in that case).
    return collected;
  }
}

final accountProductsProvider = StateNotifierProvider.autoDispose
    .family<AccountProductsNotifier, PagedListState<ProductModel>, String>(
  (ref, profileUserId) => AccountProductsNotifier(ref, profileUserId),
);
