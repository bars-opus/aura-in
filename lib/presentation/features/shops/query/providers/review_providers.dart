import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/appointments/shop_daily_schedule/providers/daily_schedule_provider.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/data/models/booking_review.dart';


/// Provider to fetch all reviews for a specific shop
final shopReviewsProvider = FutureProvider.family<List<BookingReview>, String>((ref, shopId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getShopReviews(shopId);
});

/// Provider to fetch average rating for a shop
final shopAverageRatingProvider = FutureProvider.family<double, String>((ref, shopId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final reviews = await repository.getShopReviews(shopId);
  if (reviews.isEmpty) return 0.0;
  final total = reviews.fold<double>(0, (sum, review) => sum + review.rating);
  return total / reviews.length;
});

/// Provider to fetch total review count for a shop
final shopTotalReviewsProvider = FutureProvider.family<int, String>((ref, shopId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final reviews = await repository.getShopReviews(shopId);
  return reviews.length;
});
