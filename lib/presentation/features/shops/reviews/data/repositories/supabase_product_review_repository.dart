import 'package:nano_embryo/presentation/features/products/data/exceptions/marketplace_exceptions.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_logger.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/retry_policy.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/data/models/product_review_model.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/data/repositories/product_review_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProductReviewRepository implements ProductReviewRepository {
  final SupabaseClient _supabase;

  SupabaseProductReviewRepository(this._supabase);

  @override
  Future<List<ProductReview>> getProductReviews(String productId) async {
    try {
      final response = await RetryPolicy.run(
        () => _supabase
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
            .order('created_at', ascending: false),
        operationName: 'getProductReviews',
      );

      return (response as List)
          .map((json) => ProductReview.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      MarketplaceLogger.error('getProductReviews failed',
          error: e, stack: stack);
      throw mapToMarketplaceException(e, 'Failed to load reviews');
    }
  }

  @override
  Future<bool> canUserReviewProduct(String productId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await RetryPolicy.run(
        () => _supabase
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
            .maybeSingle(),
        operationName: 'canUserReviewProduct',
      );

      return response != null;
    } catch (e, stack) {
      // canUser… is a non-fatal gate; warn (not error) and return false
      // so the UI hides the CTA gracefully.
      MarketplaceLogger.warn('canUserReviewProduct check failed',
          error: e, stack: stack);
      return false;
    }
  }

  /// NOT retried — there is no per-user-per-product idempotency on the
  /// insert path. Retry could create duplicate review rows (then fail
  /// on the UNIQUE constraint, which is benign but confusing).
  @override
  Future<void> createReview({
    required String orderId,
    required String productId,
    required int rating,
    String? review,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw NotEligibleToReviewException();
      }

      await _supabase.from('product_reviews').insert({
        'order_id': orderId,
        'product_id': productId,
        'user_id': user.id,
        'rating': rating,
        'comment': review,
      });
    } on ProductReviewException {
      rethrow;
    } catch (e, stack) {
      MarketplaceLogger.error('createReview failed', error: e, stack: stack);
      throw mapToMarketplaceException(e, 'Failed to submit review');
    }
  }

  /// NOT retried — an update is idempotent in principle, but the
  /// shop_response_at timestamp would be overwritten on each retry,
  /// causing confusion in audit views. Manual retry from the UI is fine.
  @override
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
    } catch (e, stack) {
      MarketplaceLogger.error('respondToReview failed',
          error: e, stack: stack);
      throw mapToMarketplaceException(e, 'Failed to respond to review');
    }
  }
}
