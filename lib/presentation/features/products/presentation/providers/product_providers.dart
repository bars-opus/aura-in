// lib/features/products/presentation/providers/product_providers.dart

import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/data/repositories/supabase_product_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_providers.g.dart';
part 'product_providers.freezed.dart';

// ============================================
// Repository Provider
// ============================================

@riverpod
ProductRepository productRepository(ProductRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ProductRepository(supabase);
}

// ============================================
// Product List Providers
// ============================================

@riverpod
Future<List<ProductModel>> shopProducts(ShopProductsRef ref, String shopId) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getShopProducts(shopId);
}

@riverpod
Future<ProductModel> product(ProductRef ref, String productId) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProduct(productId);
}

// ============================================
// Product Form State (Using Freezed)
// ============================================

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

// ============================================
// Product Form Notifier (Using Riverpod)
// ============================================

@riverpod
class ProductFormNotifier extends _$ProductFormNotifier {
  @override
  ProductFormState build() {
    return ProductFormState.initial();
  }

  Future<void> createProduct({
    required String shopId,
    required String name,
    required String? description,
    required double price,
    required List<String> images,
    required String category,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(productRepositoryProvider);
      final product = await repository.createProduct(
        shopId: shopId,
        name: name,
        description: description,
        price: price,
        images: images,
        category: category,
      );

      state = state.copyWith(
        isLoading: false,
        success: true,
        createdProduct: product,
      );
    } catch (e) {
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
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(productRepositoryProvider);
      final product = await repository.updateProduct(
        productId: productId,
        name: name,
        description: description,
        price: price,
        images: images,
        category: category,
        isActive: isActive,
      );

      state = state.copyWith(
        isLoading: false,
        success: true,
        updatedProduct: product,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteProduct(String productId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(productRepositoryProvider);
      await repository.deleteProduct(productId);

      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = ProductFormState.initial();
  }
}
