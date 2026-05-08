import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/search/presentation/state/search_providers.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/repositories/booking_repository.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/repositories/supabase_booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseBookingRepository(supabaseClient);
});
