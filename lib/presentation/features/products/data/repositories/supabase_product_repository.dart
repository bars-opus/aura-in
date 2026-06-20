import 'dart:io';

import 'package:nano_embryo/presentation/features/products/data/exceptions/marketplace_exceptions.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/data/repositories/product_repository.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_logger.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/retry_policy.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/marketplace_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProductRepository implements ProductRepository {
  final SupabaseClient _supabase;

  SupabaseProductRepository(this._supabase);

  // Image upload constraints. Enforced client-side BEFORE upload so we
  // never spend bytes / time on a file the server would reject. A
  // Supabase storage bucket policy should mirror these limits as a
  // second line of defense.
  static const int _maxImageBytes = 5 * 1024 * 1024; // 5 MB
  static const Set<String> _allowedImageExts = {'jpg', 'jpeg', 'png', 'webp'};

  void _validateImageFile(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    if (!_allowedImageExts.contains(ext)) {
      throw ProductImageUploadException(
        'Unsupported image type: .$ext (allowed: ${_allowedImageExts.join(", ")})',
      );
    }
    final size = file.lengthSync();
    if (size > _maxImageBytes) {
      final mb = (size / (1024 * 1024)).toStringAsFixed(1);
      throw ProductImageUploadException(
        'Image too large: ${mb}MB (max ${_maxImageBytes ~/ (1024 * 1024)}MB)',
      );
    }
    if (size == 0) {
      throw ProductImageUploadException('Image file is empty');
    }
  }

  @override
  Future<List<ProductModel>> getShopProducts(
    String shopId, {
    int limit = 30,
    int page = 0,
  }) async {
    try {
      final from = page * limit;
      final response = await RetryPolicy.run(
        () => _supabase
            .from('products')
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false)
            .range(from, from + limit - 1),
        operationName: 'getShopProducts',
      );

      return (response as List)
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      MarketplaceLogger.error('getShopProducts failed', error: e, stack: stack);
      throw mapToMarketplaceException(e, 'Failed to load products');
    }
  }

  @override
  Future<List<ProductModel>> getMarketplaceProducts({
    String? category,
    SortOption? sortBy,
    double? minPrice,
    double? maxPrice,
    bool showVerifiedOnly = false,
    required int limit,
    required int page,
    int seed = 0,
  }) async {
    try {
      // Map SortOption to RPC's p_sort_by string.
      // discover (and null) → null so the RPC uses seeded shuffle.
      final String? rpcSortBy;
      switch (sortBy ?? SortOption.discover) {
        case SortOption.discover:
          rpcSortBy = null;
          break;
        case SortOption.recent:
          rpcSortBy = 'recent';
          break;
        case SortOption.priceLowHigh:
          rpcSortBy = 'price_low';
          break;
        case SortOption.priceHighLow:
          rpcSortBy = 'price_high';
          break;
        case SortOption.popular:
          rpcSortBy = 'popular';
          break;
      }

      final response = await RetryPolicy.run(
        () => _supabase.rpc(
          'discover_products',
          params: {
            'p_seed': seed,
            'p_category': category,
            'p_min_price': minPrice,
            'p_max_price': maxPrice,
            'p_sort_by': rpcSortBy,
            'p_limit': limit,
            'p_offset': page * limit,
          },
        ),
        operationName: 'getMarketplaceProducts',
      );

      // RPC returns rows of {product: jsonb} — unwrap before parsing.
      return (response as List)
          .map(
            (row) => ProductModel.fromJson(
              (row as Map<String, dynamic>)['product']
                  as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e, stack) {
      MarketplaceLogger.error('getMarketplaceProducts failed',
          error: e, stack: stack);
      throw mapToMarketplaceException(e, 'Failed to load marketplace');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts({
    required String query,
    int limit = 20,
  }) async {
    try {
      final response = await RetryPolicy.run(
        () => _supabase
            .from('products')
            .select('''
              *,
              shops!inner (
                id,
                shop_name,
                verified,
                average_rating
              )
            ''')
            .eq('is_active', true)
            .textSearch('search_vector', query)
            .limit(limit),
        operationName: 'searchProducts',
      );

      return (response as List)
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      MarketplaceLogger.error('searchProducts failed',
          error: e, stack: stack);
      throw mapToMarketplaceException(e, 'Failed to search products');
    }
  }

  @override
  Future<List<ProductModel>> getShopProductsForCustomer(String shopId) async {
    try {
      final response = await RetryPolicy.run(
        () => _supabase
            .from('products')
            .select()
            .eq('shop_id', shopId)
            .eq('is_active', true)
            .order('created_at', ascending: false),
        operationName: 'getShopProductsForCustomer',
      );

      return (response as List)
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      MarketplaceLogger.error('getShopProductsForCustomer failed',
          error: e, stack: stack);
      throw mapToMarketplaceException(e, 'Failed to load shop products');
    }
  }

  @override
  Future<ProductModel> getProduct(String productId) async {
    try {
      final response = await RetryPolicy.run(
        () => _supabase
            .from('products')
            .select('''
              *,
              shops!inner (
                id,
                shop_name,
                verified
              )
            ''')
            .eq('id', productId)
            .maybeSingle(),
        operationName: 'getProduct',
      );

      if (response == null) {
        throw ProductNotFoundException(productId);
      }
      return ProductModel.fromJson(response);
    } on ProductNotFoundException {
      rethrow;
    } catch (e, stack) {
      MarketplaceLogger.error('getProduct failed', error: e, stack: stack);
      throw mapToMarketplaceException(e, 'Failed to load product');
    }
  }

  @override
  Future<ProductModel> createProduct({
    required String shopId,
    required String name,
    required String? description,
    required double price,
    required List<String> images,
    required String category,
    int stockQuantity = 0,
  }) async {
    try {
      final response = await _supabase
          .from('products')
          .insert({
            'shop_id': shopId,
            'name': name,
            'description': description,
            'price': price,
            'images': images,
            'category': category,
            'is_active': true,
            'stock_quantity': stockQuantity,
          })
          .select()
          .single();

      return ProductModel.fromJson(response);
    } catch (e, stack) {
      MarketplaceLogger.error('createProduct failed', error: e, stack: stack);
      throw mapToMarketplaceException(e, 'Failed to create product');
    }
  }

  @override
  Future<ProductModel> updateProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    List<String>? images,
    String? category,
    bool? isActive,
    int? stockQuantity,
  }) async {
    try {
      final updateData = <String, dynamic>{
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (price != null) 'price': price,
        if (images != null) 'images': images,
        if (category != null) 'category': category,
        if (isActive != null) 'is_active': isActive,
        if (stockQuantity != null) 'stock_quantity': stockQuantity,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('products')
          .update(updateData)
          .eq('id', productId)
          .select()
          .single();

      return ProductModel.fromJson(response);
    } catch (e, stack) {
      MarketplaceLogger.error('updateProduct failed', error: e, stack: stack);
      throw mapToMarketplaceException(e, 'Failed to update product');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _supabase.from('products').delete().eq('id', productId);
    } catch (e, stack) {
      MarketplaceLogger.error('deleteProduct failed', error: e, stack: stack);
      throw mapToMarketplaceException(e, 'Failed to delete product');
    }
  }

  @override
  Future<String> uploadProductImage({
    required String shopId,
    required String productId,
    required File imageFile,
  }) async {
    _validateImageFile(imageFile);
    try {
      final ext = imageFile.path.split('.').last.toLowerCase();
      final fileName =
          '$shopId/$productId/${DateTime.now().millisecondsSinceEpoch}.$ext';
      final storagePath = 'products/$fileName';

      await RetryPolicy.run(
        () => _supabase.storage
            .from('product-images')
            .upload(storagePath, imageFile),
        operationName: 'uploadProductImage',
      );

      return _supabase.storage.from('product-images').getPublicUrl(storagePath);
    } on ProductImageUploadException {
      rethrow;
    } catch (e, stack) {
      MarketplaceLogger.error('image upload failed', error: e, stack: stack);
      throw ProductImageUploadException(e.toString());
    }
  }

  @override
  Future<List<String>> uploadMultipleProductImages({
    required String shopId,
    required String productId,
    required List<File> imageFiles,
  }) async {
    final uploadedUrls = <String>[];
    for (final imageFile in imageFiles) {
      uploadedUrls.add(await uploadProductImage(
        shopId: shopId,
        productId: productId,
        imageFile: imageFile,
      ));
    }
    return uploadedUrls;
  }

  @override
  Future<String> uploadTemporaryProductImage({
    required String shopId,
    required File imageFile,
  }) async {
    _validateImageFile(imageFile);
    try {
      final ext = imageFile.path.split('.').last.toLowerCase();
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final fileName =
          '$shopId/$tempId/${DateTime.now().millisecondsSinceEpoch}.$ext';
      final storagePath = 'products/$fileName';

      await RetryPolicy.run(
        () => _supabase.storage
            .from('product-images')
            .upload(storagePath, imageFile),
        operationName: 'uploadProductImage',
      );

      return _supabase.storage.from('product-images').getPublicUrl(storagePath);
    } on ProductImageUploadException {
      rethrow;
    } catch (e, stack) {
      MarketplaceLogger.error('image upload failed', error: e, stack: stack);
      throw ProductImageUploadException(e.toString());
    }
  }
}
