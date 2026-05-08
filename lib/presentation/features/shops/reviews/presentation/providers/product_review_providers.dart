import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/data/models/product_review_model.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/data/repositories/supabase_product_review_repository.dart';

// Repository provider
final productReviewRepositoryProvider =
    Provider<SupabaseProductReviewRepository>((ref) {
      final supabase = ref.watch(supabaseClientProvider);
      return SupabaseProductReviewRepository(supabase);
    });

// Product reviews provider
final productReviewsProvider =
    FutureProvider.family<List<ProductReview>, String>((ref, productId) async {
      final repository = ref.read(productReviewRepositoryProvider);
      return repository.getProductReviews(productId);
    });

// Check if user can review product
final canReviewProductProvider = FutureProvider.family<bool, String>((
  ref,
  productId,
) async {
  final repository = ref.read(productReviewRepositoryProvider);
  return repository.canUserReviewProduct(productId);
});

// Submit review provider
final submitProductReviewProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
      final repository = ref.read(productReviewRepositoryProvider);
      await repository.createReview(
        orderId: params['orderId'],
        productId: params['productId'],
        rating: params['rating'],
        review: params['review'],
      );
    });
