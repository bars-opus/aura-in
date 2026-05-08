// lib/features/products/data/repositories/supabase_product_repository.dart

import 'dart:io';

import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/marketplace_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRepository {
  final SupabaseClient _supabase;

  ProductRepository(this._supabase);

  // Get all products for a shop (including inactive)
  Future<List<ProductModel>> getShopProducts(String shopId) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw AuthException(
        'Failed to load products: $e',
      ); // Use generic AuthException
    }
  }

  // Get marketplace products with filters
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

      // Apply filters (using PostgrestFilterBuilder)
      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }

      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }

      if (showVerifiedOnly) {
        query = query.eq('shops.verified', true);
      }

      // Apply sorting (returns PostgrestTransformBuilder)
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

      // Apply pagination
      final from = page * limit;
      final finalQuery = filteredQuery.range(from, from + limit - 1);
      final response = await finalQuery;

      return (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw AuthException('Failed to load marketplace products: $e');
    }
  }

  // Search products
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
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw AuthException('Failed to search products: $e');
    }
  }

  // Get products by shop ID (for customer view)
  Future<List<ProductModel>> getShopProductsForCustomer(String shopId) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('shop_id', shopId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw AuthException('Failed to load shop products: $e');
    }
  }

  // Get single product by ID
  Future<ProductModel> getProduct(String productId) async {
    try {
      final response =
          await _supabase
              .from('products')
              .select()
              .eq('id', productId)
              .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw AuthException('Failed to load product: $e');
    }
  }

  // Create new product
  Future<ProductModel> createProduct({
    required String shopId,
    required String name,
    required String? description,
    required double price,
    required List<String> images,
    required String category,
  }) async {
    try {
      final response =
          await _supabase
              .from('products')
              .insert({
                'shop_id': shopId,
                'name': name,
                'description': description,
                'price': price,
                'images': images,
                'category': category,
                'is_active': true,
              })
              .select()
              .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw AuthException('Failed to create product: $e');
    }
  }

  // Update existing product
  Future<ProductModel> updateProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    List<String>? images,
    String? category,
    bool? isActive,
  }) async {
    try {
      final updateData = {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (price != null) 'price': price,
        if (images != null) 'images': images,
        if (category != null) 'category': category,
        if (isActive != null) 'is_active': isActive,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase
              .from('products')
              .update(updateData)
              .eq('id', productId)
              .select()
              .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw AuthException('Failed to update product: $e');
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _supabase.from('products').delete().eq('id', productId);
    } catch (e) {
      throw AuthException('Failed to delete product: $e');
    }
  }

  // Upload product image
  Future<String> uploadProductImage({
    required String shopId,
    required String productId,
    required File imageFile,
  }) async {
    try {
      final fileName =
          '$shopId/$productId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'products/$fileName';

      await _supabase.storage
          .from('product-images')
          .upload(storagePath, imageFile);

      return _supabase.storage.from('product-images').getPublicUrl(storagePath);
    } catch (e) {
      throw AuthException('Failed to upload image: $e');
    }
  }

  // Upload multiple images
  Future<List<String>> uploadMultipleProductImages({
    required String shopId,
    required String productId,
    required List<File> imageFiles,
  }) async {
    try {
      final List<String> uploadedUrls = [];

      for (final imageFile in imageFiles) {
        final url = await uploadProductImage(
          shopId: shopId,
          productId: productId,
          imageFile: imageFile,
        );
        uploadedUrls.add(url);
      }

      return uploadedUrls;
    } catch (e) {
      throw AuthException('Failed to upload images: $e');
    }
  }

  // Add this helpful method for temporary uploads (for new products)
  Future<String> uploadTemporaryProductImage({
    required String shopId,
    required File imageFile,
  }) async {
    try {
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final fileName =
          '$shopId/$tempId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'products/$fileName';

      await _supabase.storage
          .from('product-images')
          .upload(storagePath, imageFile);

      return _supabase.storage.from('product-images').getPublicUrl(storagePath);
    } catch (e) {
      throw AuthException('Failed to upload temporary image: $e');
    }
  }
}
