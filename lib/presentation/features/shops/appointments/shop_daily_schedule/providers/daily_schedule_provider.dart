import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'daily_schedule_notifier.dart';
import 'daily_schedule_state.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  // Get Supabase client from wherever it's provided
  final supabaseClient = Supabase.instance.client;
  return SupabaseBookingRepository(supabaseClient);
});

final dailyScheduleNotifierProvider = StateNotifierProviderFamily<DailyScheduleNotifier, DailyScheduleState, String>((ref, shopId) {
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  return DailyScheduleNotifier(
    bookingRepository: bookingRepository,
    shopId: shopId,
  );
});
