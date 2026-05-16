import 'dart:io';

import 'package:nano_embryo/presentation/features/products/data/exceptions/marketplace_exceptions.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/data/repositories/product_repository.dart';
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
  Future<List<ProductModel>> getShopProducts(String shopId) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
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
  }) async {
    try {
      var query = _supabase
          .from('products')
          .select('''
            *,
            shops!inner (
              id,
              shop_name,
              verified,
              luxury_level,
              average_rating
            )
          ''')
          .eq('is_active', true);

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }
      if (minPrice != null) query = query.gte('price', minPrice);
      if (maxPrice != null) query = query.lte('price', maxPrice);
      if (showVerifiedOnly) query = query.eq('shops.verified', true);

      PostgrestTransformBuilder filteredQuery;
      switch (sortBy ?? SortOption.recent) {
        case SortOption.recent:
          filteredQuery = query.order('created_at', ascending: false);
          break;
        case SortOption.priceLowHigh:
          filteredQuery = query.order('price', ascending: true);
          break;
        case SortOption.priceHighLow:
          filteredQuery = query.order('price', ascending: false);
          break;
        case SortOption.popular:
          filteredQuery = query.order('total_orders_count', ascending: false);
          break;
      }

      final from = page * limit;
      final response = await filteredQuery.range(from, from + limit - 1);

      return (response as List)
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw mapToMarketplaceException(e, 'Failed to load marketplace');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts({
    required String query,
    int limit = 20,
  }) async {
    try {
      final response = await _supabase
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
          .limit(limit);

      return (response as List)
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw mapToMarketplaceException(e, 'Failed to search products');
    }
  }

  @override
  Future<List<ProductModel>> getShopProductsForCustomer(String shopId) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('shop_id', shopId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw mapToMarketplaceException(e, 'Failed to load shop products');
    }
  }

  @override
  Future<ProductModel> getProduct(String productId) async {
    try {
      final response = await _supabase
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
          .maybeSingle();

      if (response == null) {
        throw ProductNotFoundException(productId);
      }
      return ProductModel.fromJson(response);
    } on ProductNotFoundException {
      rethrow;
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
      throw mapToMarketplaceException(e, 'Failed to update product');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _supabase.from('products').delete().eq('id', productId);
    } catch (e) {
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

      await _supabase.storage
          .from('product-images')
          .upload(storagePath, imageFile);

      return _supabase.storage.from('product-images').getPublicUrl(storagePath);
    } on ProductImageUploadException {
      rethrow;
    } catch (e) {
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

      await _supabase.storage
          .from('product-images')
          .upload(storagePath, imageFile);

      return _supabase.storage.from('product-images').getPublicUrl(storagePath);
    } on ProductImageUploadException {
      rethrow;
    } catch (e) {
      throw ProductImageUploadException(e.toString());
    }
  }
}
