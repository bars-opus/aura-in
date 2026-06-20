// Abstract product repository. Implementations live alongside in
// supabase_product_repository.dart and may be swapped (test fakes, future
// REST backend, etc.) without touching the providers or UI.

import 'dart:io';

import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/marketplace_providers.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getShopProducts(
    String shopId, {
    int limit = 30,
    int page = 0,
  });

  Future<List<ProductModel>> getMarketplaceProducts({
    String? category,
    SortOption? sortBy,
    double? minPrice,
    double? maxPrice,
    bool showVerifiedOnly = false,
    required int limit,
    required int page,
    int seed = 0,
  });

  Future<List<ProductModel>> searchProducts({
    required String query,
    int limit = 20,
  });

  Future<List<ProductModel>> getShopProductsForCustomer(String shopId);

  Future<ProductModel> getProduct(String productId);

  Future<ProductModel> createProduct({
    required String shopId,
    required String name,
    required String? description,
    required double price,
    required List<String> images,
    required String category,
    required List<String> shopTypes,
    int stockQuantity = 0,
  });

  Future<ProductModel> updateProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    List<String>? images,
    String? category,
    bool? isActive,
    int? stockQuantity,
    List<String>? shopTypes,
  });

  Future<void> deleteProduct(String productId);

  Future<String> uploadProductImage({
    required String shopId,
    required String productId,
    required File imageFile,
  });

  Future<List<String>> uploadMultipleProductImages({
    required String shopId,
    required String productId,
    required List<File> imageFiles,
  });

  Future<String> uploadTemporaryProductImage({
    required String shopId,
    required File imageFile,
  });
}
