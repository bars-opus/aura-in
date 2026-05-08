// lib/features/booking/presentation/controllers/booking_repository_provider.dart

import 'package:nano_embryo/presentation/features/search/presentation/state/search_providers.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/data/models/booking_review.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

part 'booking_repository_provider.g.dart';

/// Provider for the BookingRepository implementation.
///
/// This is the foundation provider that supplies the repository
/// to all other booking-related providers and controllers.
///
/// ## Usage
/// ```dart
/// final repo = ref.watch(bookingRepositoryProvider);
/// final bookings = await repo.getBookings(params);
/// ```
@riverpod
BookingRepository bookingRepository(BookingRepositoryRef ref) {
  // supabaseClientProvider already returns SupabaseClient directly
  final supabaseClient = ref.watch(supabaseClientProvider);

  // Pass the client directly - no .client property needed
  return SupabaseBookingRepository(supabaseClient);
}

final bookingReviewProvider = FutureProvider.family<BookingReview?, String>((
  ref,
  bookingId,
) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getReviewForBooking(bookingId);
});
