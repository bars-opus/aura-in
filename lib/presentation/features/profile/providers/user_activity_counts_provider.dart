import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';

/// Aggregate activity counts for a profile, shown in the ProfileHeader stats.
class UserActivityCounts {
  final int bookingCount;
  final int orderCount;

  const UserActivityCounts({
    required this.bookingCount,
    required this.orderCount,
  });

  static const empty = UserActivityCounts(bookingCount: 0, orderCount: 0);
}

/// Public booking + order counts for [userId]. Backed by the
/// get_user_activity_counts SECURITY DEFINER RPC, which returns only the two
/// aggregate integers (no row data) so it works for any viewer despite RLS on
/// bookings/orders. Defaults to zero counts on any error — a failed stat fetch
/// must never break the profile screen.
final userActivityCountsProvider =
    FutureProvider.family<UserActivityCounts, String>((ref, userId) async {
  if (userId.isEmpty) return UserActivityCounts.empty;
  final client = ref.watch(supabaseClientProvider);
  try {
    final rows = await client.rpc(
      'get_user_activity_counts',
      params: {'p_user_id': userId},
    );
    // The RPC returns a single-row set: [{booking_count, order_count}].
    if (rows is List && rows.isNotEmpty) {
      final row = rows.first as Map<String, dynamic>;
      return UserActivityCounts(
        bookingCount: (row['booking_count'] as num?)?.toInt() ?? 0,
        orderCount: (row['order_count'] as num?)?.toInt() ?? 0,
      );
    }
    return UserActivityCounts.empty;
  } catch (_) {
    return UserActivityCounts.empty;
  }
});
