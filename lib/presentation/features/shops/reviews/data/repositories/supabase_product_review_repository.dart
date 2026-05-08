// lib/features/products/data/repositories/product_review_repository.dart

import 'package:nano_embryo/presentation/features/shops/reviews/data/models/product_review_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProductReviewRepository {
  final SupabaseClient _supabase;

  SupabaseProductReviewRepository(this._supabase);

  // Get reviews for a product
  Future<List<ProductReview>> getProductReviews(String productId) async {
    try {
      final response = await _supabase
          .from('product_reviews')
          .select('''
            *,
            profiles!user_id (
              full_name,
              avatar_url
            ),
            products!product_id (
              name,
              images
            )
          ''')
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProductReview.fromJson(json))
          .toList();
    } catch (e) {
      throw AuthException('Failed to load reviews: $e');
    }
  }

  // Check if user can review a product (has delivered order with this product)
  Future<bool> canUserReviewProduct(String productId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response =
          await _supabase
              .from('order_items')
              .select('''
            order_id,
            orders!inner (
              user_id,
              status
            )
          ''')
              .eq('product_id', productId)
              .eq('orders.user_id', user.id)
              .eq('orders.status', 'delivered')
              .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Create a review
  Future<void> createReview({
    required String orderId,
    required String productId,
    required int rating,
    String? review,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      await _supabase.from('product_reviews').insert({
        'order_id': orderId,
        'product_id': productId,
        'user_id': user.id,
        'rating': rating,
        'comment': review,
      });
    } catch (e) {
      throw AuthException('Failed to submit review: $e');
    }
  }

  // Shop response to review
  Future<void> respondToReview({
    required String reviewId,
    required String response,
  }) async {
    try {
      await _supabase
          .from('product_reviews')
          .update({
            'shop_response': response,
            'shop_response_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reviewId);
    } catch (e) {
      throw AuthException('Failed to respond to review: $e');
    }
  }
}
