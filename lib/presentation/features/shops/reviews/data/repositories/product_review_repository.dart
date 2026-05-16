// Abstract product review repository.

import 'package:nano_embryo/presentation/features/shops/reviews/data/models/product_review_model.dart';

abstract class ProductReviewRepository {
  Future<List<ProductReview>> getProductReviews(String productId);

  Future<bool> canUserReviewProduct(String productId);

  Future<void> createReview({
    required String orderId,
    required String productId,
    required int rating,
    String? review,
  });

  Future<void> respondToReview({
    required String reviewId,
    required String response,
  });
}
