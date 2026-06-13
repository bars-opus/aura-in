import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';

// State class (same as before, but now using BookingParams)

// ============================================================
// STATE CLASS
// ============================================================

/// State class for client bookings with pagination support
class ClientBookingsState extends Equatable {
  final List<ClientCalendarBooking> bookings;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasNextPage;
  final int currentPage;
  final String? error;
  final bool isRefreshing;

  const ClientBookingsState({
    this.bookings = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasNextPage = true,
    this.currentPage = 1,
    this.error,
    this.isRefreshing = false,
  });

  ClientBookingsState copyWith({
    List<ClientCalendarBooking>? bookings,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasNextPage,
    int? currentPage,
    String? error,
    bool? isRefreshing,
  }) {
    return ClientBookingsState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      currentPage: currentPage ?? this.currentPage,
      error: error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    bookings,
    isLoading,
    isLoadingMore,
    hasNextPage,
    currentPage,
    error,
    isRefreshing,
  ];
}

// ============================================================
// CONTROLLER CLASS
// ============================================================

/// Controller that manages client bookings list with pagination
class ClientBookingsController extends StateNotifier<ClientBookingsState> {
  final BookingRepository _repository;
  final String _userId;
  static const int _pageSize = 10;

  ClientBookingsController({
    required BookingRepository repository,
    required String userId,
  }) : _repository = repository,
       _userId = userId,
       super(const ClientBookingsState());

  /// Load first page of bookings
  Future<void> loadFirstPage() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.getClientBookings(
        userId: _userId,
        page: 1,
        pageSize: _pageSize,
        sortBy: 'start_time',
        sortAscending: false,
      );

      state = state.copyWith(
        bookings: result.bookings,
        isLoading: false,
        hasNextPage: result.hasNextPage,
        currentPage: result.currentPage,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load next page of bookings (infinite scroll)
  Future<void> loadNextPage() async {
    if (!state.hasNextPage || state.isLoadingMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await _repository.getClientBookings(
        userId: _userId,
        page: state.currentPage + 1,
        pageSize: _pageSize,
        sortBy: 'start_time',
        sortAscending: false,
      );

      final updatedBookings = [...state.bookings, ...result.bookings];

      state = state.copyWith(
        bookings: updatedBookings,
        isLoadingMore: false,
        hasNextPage: result.hasNextPage,
        currentPage: result.currentPage,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  /// Refresh the list (pull-to-refresh)
  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, error: null);

    try {
      final result = await _repository.getClientBookings(
        userId: _userId,
        page: 1,
        pageSize: _pageSize,
        sortBy: 'start_time',
        sortAscending: false,
      );

      state = state.copyWith(
        bookings: result.bookings,
        isRefreshing: false,
        hasNextPage: result.hasNextPage,
        currentPage: result.currentPage,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }

  /// Reset state (useful for logout)
  void reset() {
    state = const ClientBookingsState();
  }
}

// ============================================================
// PROVIDER
// ============================================================

/// Provider for ClientBookingsController
final clientBookingsControllerProvider = StateNotifierProvider.autoDispose<
  ClientBookingsController,
  ClientBookingsState
>((ref) {
  // Get dependencies
  final repository = ref.watch(bookingRepositoryProvider);
  final userId = ref.watch(currentUserProvider)?.id;

  // Validate user is logged in
  if (userId == null) {
    throw Exception('User must be logged in to view bookings');
  }

  // Create controller
  final controller = ClientBookingsController(
    repository: repository,
    userId: userId,
  );

  // // Clean up on dispose
  // ref.onDispose(controller.reset);

  // Load first page after microtask (avoids building during frame)
  Future.microtask(() => controller.loadFirstPage());

  return controller;
});

// Provider for single booking.
//
// Client-side authorization (defense in depth on top of Supabase RLS):
// the booking is only returned if the current user is either the booking
// owner (`booking.userId`) or the owner of the shop hosting the booking
// (`booking.shopId in userShopsProvider`). Checklist v3.1 P0-U 1.4.
final bookingDetailProvider = FutureProvider.autoDispose
    .family<BookingModel, String>((ref, bookingId) async {
      final repository = ref.watch(bookingRepositoryProvider);
      final booking = await repository.getBookingById(bookingId);

      if (booking == null) {
        throw Exception('Booking not found');
      }

      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw BookingAuthorizationException();
      }

      final ownsBooking =
          booking.userId.isNotEmpty && booking.userId == currentUser.id;
      if (ownsBooking) return booking;

      // Shop-owner branch: confirm current user owns the hosting shop.
      final userShops = await ref.read(userShopsProvider.future);
      final ownsShop = userShops.any((s) => s.id == booking.shopId);
      if (ownsShop) return booking;

      throw BookingAuthorizationException();
    });
