import 'package:nano_embryo/presentation/features/shops/booking/presentation/controllers/booking_repository_provider.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/data/models/shop_calendar_booking.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/data/repositories/calendar_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'calendar_provider.g.dart';

// ==================== DEPENDENCIES ====================

@riverpod
CalendarRepository calendarRepository(CalendarRepositoryRef ref) {
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  return CalendarRepository(bookingRepository: bookingRepository);
}

// ==================== PARAMETERS ====================

/// Parameters for initializing the calendar controller
class CalendarParams {
  final String userId;
  final bool isShopOwner;

  const CalendarParams({required this.userId, required this.isShopOwner});
}

// ==================== STATE ====================

/// Simple class to hold month range
class MonthRange {
  final DateTime start;
  final DateTime end;
  final String monthKey; // Format: YYYY-MM

  MonthRange({required DateTime month})
    : start = DateTime(month.year, month.month, 1),
      end = DateTime(month.year, month.month + 1, 0),
      monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
}

/// Enum for calendar view type
enum CalendarViewType {
  client, // User is a client
  shop, // User is a shop owner with shops
}

/// State for the calendar screen
class CalendarState {
  final CalendarViewType viewType;
  final List<dynamic>
  bookings; // Can be ClientCalendarBooking or ShopCalendarBooking
  final DateTime focusedMonth;
  final Map<String, List<dynamic>> cache; // monthKey -> bookings
  final String? activeShopId;
  final List<Map<String, dynamic>> availableShops;
  final bool isLoading;

  CalendarState({
    required this.viewType,
    required this.bookings,
    required this.focusedMonth,
    required this.cache,
    this.activeShopId,
    required this.availableShops,
    required this.isLoading,
  });

  CalendarState copyWith({
    CalendarViewType? viewType,
    List<dynamic>? bookings,
    DateTime? focusedMonth,
    Map<String, List<dynamic>>? cache,
    String? activeShopId,
    List<Map<String, dynamic>>? availableShops,
    bool? isLoading,
  }) {
    return CalendarState(
      viewType: viewType ?? this.viewType,
      bookings: bookings ?? this.bookings,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      cache: cache ?? this.cache,
      activeShopId: activeShopId ?? this.activeShopId,
      availableShops: availableShops ?? this.availableShops,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ==================== CONTROLLER ====================
@riverpod
class CalendarController extends _$CalendarController {
  late final CalendarRepository _repository;
  late final String _userIdOrShopId; // For clients: userId, for shops: shopId
  late final bool _isShopOwner;
  static const String _activeShopPrefKey = 'active_shop_id';

  // Cache the initialized state
  CalendarState? _cachedState;

  @override
  Future<CalendarState> build({
    required String userIdOrShopId,
    required bool isShopOwner,
  }) async {
    // If we already have a cached state and parameters haven't changed, return it
    if (_cachedState != null &&
        _userIdOrShopId == userIdOrShopId &&
        _isShopOwner == isShopOwner) {
      return _cachedState!;
    }

    _userIdOrShopId = userIdOrShopId;
    _isShopOwner = isShopOwner;
    _repository = ref.watch(calendarRepositoryProvider);

    try {
      CalendarState state;
      if (!_isShopOwner) {
        // Client: use userId to fetch personal bookings
        state = await _initializeClientView();
      } else {
        // Shop owner: use shopId directly to fetch shop bookings
        state = await _initializeShopOwnerView();
      }

      _cachedState = state;
      return state;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<CalendarState> _initializeClientView() async {
    final now = DateTime.now();
    final monthRange = MonthRange(month: now);

    final bookings = await _repository.getClientBookingsForRange(
      userId: _userIdOrShopId, // This is the user ID
      startDate: monthRange.start,
      endDate: monthRange.end,
    );

    return CalendarState(
      viewType: CalendarViewType.client,
      bookings: bookings,
      focusedMonth: now,
      cache: {monthRange.monthKey: bookings},
      availableShops: [],
      isLoading: false,
    );
  }

  Future<CalendarState> _initializeShopOwnerView() async {
    final now = DateTime.now();
    final monthRange = MonthRange(month: now);

    // DIRECTLY use the passed shop ID to fetch bookings
    final shopId = _userIdOrShopId; // This is the shop ID

    List<ShopCalendarBooking> bookings = [];
    if (shopId.isNotEmpty) {
      bookings = await _repository.getShopBookingsForRange(
        shopId: shopId, // Use shop ID directly
        startDate: monthRange.start,
        endDate: monthRange.end,
      );
    }

    return CalendarState(
      viewType: CalendarViewType.shop,
      bookings: bookings,
      focusedMonth: now,
      cache: {monthRange.monthKey: bookings},
      activeShopId: shopId,
      availableShops: [], // No shop selector since we have a fixed shop
      isLoading: false,
    );
  }

  /// Load bookings for a specific month
  Future<void> loadMonth(DateTime month) async {
    final state = await future;
    if (state.isLoading) return;

    final monthRange = MonthRange(month: month);

    // Check cache first
    if (state.cache.containsKey(monthRange.monthKey)) {
      this.state = AsyncValue.data(
        state.copyWith(
          bookings: state.cache[monthRange.monthKey],
          focusedMonth: month,
        ),
      );
      return;
    }

    // Not in cache, fetch
    this.state = AsyncValue.data(state.copyWith(isLoading: true));

    try {
      List<dynamic> bookings;

      if (state.viewType == CalendarViewType.client) {
        bookings = await _repository.getClientBookingsForRange(
          userId: _userIdOrShopId,
          startDate: monthRange.start,
          endDate: monthRange.end,
        );
      } else {
        // Shop owner: use the shop ID directly
        final shopId = _userIdOrShopId;
        if (shopId.isEmpty) {
          bookings = [];
        } else {
          bookings = await _repository.getShopBookingsForRange(
            shopId: shopId,
            startDate: monthRange.start,
            endDate: monthRange.end,
          );
        }
      }

      final updatedCache = Map<String, List<dynamic>>.from(state.cache)
        ..[monthRange.monthKey] = bookings;

      this.state = AsyncValue.data(
        state.copyWith(
          bookings: bookings,
          focusedMonth: month,
          cache: updatedCache,
          isLoading: false,
        ),
      );
    } catch (e) {
      this.state = AsyncValue.data(state.copyWith(isLoading: false));
    }
  }

}
