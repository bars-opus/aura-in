import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/products/data/exceptions/marketplace_exceptions.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/data/repositories/product_repository.dart';
import 'package:nano_embryo/presentation/features/products/data/repositories/supabase_product_repository.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_logger.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/paginated_list_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_providers.g.dart';
part 'product_providers.freezed.dart';

// Returns the abstract interface so consumers depend on `ProductRepository`
// rather than the Supabase impl — testability + matches wallet/booking pattern.
@riverpod
ProductRepository productRepository(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseProductRepository(supabase);
}

// Lightweight lookup so cart items (which require a shopName) can be
// constructed from a ProductModel that only carries shop_id.
final shopNameByIdProvider = FutureProvider.family<String?, String>((
  ref,
  shopId,
) async {
  final supabase = ref.watch(supabaseClientProvider);
  final response = await supabase
      .from('shops')
      .select('shop_name')
      .eq('id', shopId)
      .maybeSingle();
  return response?['shop_name'] as String?;
});

@riverpod
Future<List<ProductModel>> shopProducts(Ref ref, String shopId) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getShopProducts(shopId);
}

class ShopProductsPagedNotifier extends PagedListNotifier<ProductModel> {
  final Ref _ref;
  final String _shopId;
  ShopProductsPagedNotifier(this._ref, this._shopId);

  @override
  Future<List<ProductModel>> fetchPage(int page, int limit) =>
      _ref.read(productRepositoryProvider).getShopProducts(
            _shopId,
            limit: limit,
            page: page,
          );
}

final shopProductsPagedProvider = StateNotifierProvider.autoDispose
    .family<ShopProductsPagedNotifier, PagedListState<ProductModel>, String>(
  (ref, shopId) => ShopProductsPagedNotifier(ref, shopId),
);

@riverpod
Future<ProductModel> product(Ref ref, String productId) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProduct(productId);
}

@freezed
class ProductFormState with _$ProductFormState {
  const factory ProductFormState({
    @Default(false) bool isLoading,
    @Default(false) bool success,
    String? error,
    ProductModel? createdProduct,
    ProductModel? updatedProduct,
  }) = _ProductFormState;

  factory ProductFormState.initial() => const ProductFormState();
}

@riverpod
class ProductFormNotifier extends _$ProductFormNotifier {
  @override
  ProductFormState build() => ProductFormState.initial();

  Future<void> createProduct({
    required String shopId,
    required String name,
    required String? description,
    required double price,
    required List<String> images,
    required String category,
    required List<String> shopTypes,
    int stockQuantity = 0,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final product =
          await ref.read(productRepositoryProvider).createProduct(
                shopId: shopId,
                name: name,
                description: description,
                price: price,
                images: images,
                category: category,
                shopTypes: shopTypes,
                stockQuantity: stockQuantity,
              );
      state = state.copyWith(
        isLoading: false,
        success: true,
        createdProduct: product,
      );
    } on MarketplaceException catch (e, stack) {
      MarketplaceLogger.warn('ProductFormNotifier rejected',
          error: e, stack: stack);
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e, stack) {
      MarketplaceLogger.error('ProductFormNotifier failed',
          error: e, stack: stack);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    List<String>? images,
    String? category,
    bool? isActive,
    int? stockQuantity,
    List<String>? shopTypes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final product =
          await ref.read(productRepositoryProvider).updateProduct(
                productId: productId,
                name: name,
                description: description,
                price: price,
                images: images,
                category: category,
                isActive: isActive,
                stockQuantity: stockQuantity,
                shopTypes: shopTypes,
              );
      state = state.copyWith(
        isLoading: false,
        success: true,
        updatedProduct: product,
      );
    } on MarketplaceException catch (e, stack) {
      MarketplaceLogger.warn('ProductFormNotifier rejected',
          error: e, stack: stack);
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e, stack) {
      MarketplaceLogger.error('ProductFormNotifier failed',
          error: e, stack: stack);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteProduct(String productId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(productRepositoryProvider).deleteProduct(productId);
      state = state.copyWith(isLoading: false, success: true);
    } on MarketplaceException catch (e, stack) {
      MarketplaceLogger.warn('ProductFormNotifier rejected',
          error: e, stack: stack);
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e, stack) {
      MarketplaceLogger.error('ProductFormNotifier failed',
          error: e, stack: stack);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = ProductFormState.initial();
  }
}
