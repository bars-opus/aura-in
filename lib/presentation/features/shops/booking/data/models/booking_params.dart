// lib/features/booking/data/models/booking_params.dart

import 'package:equatable/equatable.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/booking_model.dart';

/// Parameters for querying bookings with filtering, pagination, and sorting.
///
/// Similar to [ShopQueryParams] from your shop feature, this class provides
/// a clean, type-safe way to build booking queries.
///
/// ## Example
/// ```dart
/// final params = BookingParams(
///   shopId: 'shop_123',
///   status: BookingStatus.confirmed,
///   fromDate: DateTime(2024, 1, 1),
///   toDate: DateTime(2024, 1, 31),
///   page: 1,
///   pageSize: 20,
/// );
/// ```
class BookingParams extends Equatable {
  final String? userId;
  final String? shopId;
  final String? workerId;
  final BookingStatus? status;
  final PaymentStatus? paymentStatus;
  final DateTime? fromDate;
  final DateTime? toDate;
  final DateTime? fromStartTime;
  final DateTime? toStartTime;
  final int page;
  final int pageSize;
  final String? sortBy;
  final bool sortAscending;

  const BookingParams({
    this.userId,
    this.shopId,
    this.workerId,
    this.status,
    this.paymentStatus,
    this.fromDate,
    this.toDate,
    this.fromStartTime,
    this.toStartTime,
    this.page = 1,
    this.pageSize = 20,
    this.sortBy = 'start_time',
    this.sortAscending = false, // Most recent first by default
  });

  /// Creates a copy with modified parameters.
  BookingParams copyWith({
    String? userId,
    String? shopId,
    String? workerId,
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? fromDate,
    DateTime? toDate,
    DateTime? fromStartTime,
    DateTime? toStartTime,
    int? page,
    int? pageSize,
    String? sortBy,
    bool? sortAscending,
  }) {
    return BookingParams(
      userId: userId ?? this.userId,
      shopId: shopId ?? this.shopId,
      workerId: workerId ?? this.workerId,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      fromStartTime: fromStartTime ?? this.fromStartTime,
      toStartTime: toStartTime ?? this.toStartTime,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  /// Converts to a map of query parameters for Supabase.
  Map<String, dynamic> toQueryParameters() {
    final map = <String, dynamic>{};

    if (userId != null) map['user_id'] = 'eq.$userId';
    if (shopId != null) map['shop_id'] = 'eq.$shopId';
    if (workerId != null) map['worker_id'] = 'eq.$workerId';
    if (status != null) map['status'] = 'eq.${status!.value}';
    if (paymentStatus != null)
      map['payment_status'] = 'eq.${paymentStatus!.value}';
    if (fromDate != null)
      map['booking_date'] = 'gte.${fromDate!.toIso8601String()}';
    if (toDate != null)
      map['booking_date'] = 'lte.${toDate!.toIso8601String()}';

    // Pagination
    final from = (page - 1) * pageSize;
    final to = from + pageSize - 1;
    map['offset'] = from;
    map['limit'] = pageSize;

    // Sorting
    map['order'] = '$sortBy.${sortAscending ? 'asc' : 'desc'}';

    return map;
  }

  @override
  List<Object?> get props => [
    userId,
    shopId,
    workerId,
    status,
    paymentStatus,
    fromDate,
    toDate,
    fromStartTime,
    toStartTime,
    page,
    pageSize,
    sortBy,
    sortAscending,
  ];
}

/// Paginated result wrapper for booking queries.
/// Generic paginated result wrapper for booking queries.
class PaginatedBookings<T> extends Equatable {
  final List<T> bookings;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool hasNextPage;

  const PaginatedBookings({
    required this.bookings,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.hasNextPage,
  });

  factory PaginatedBookings.fromSupabase(
    List<Map<String, dynamic>> data,
    int totalCount,
    BookingParams params,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    return PaginatedBookings<T>(
      bookings: data.map((json) => fromJson(json)).toList(),
      totalCount: totalCount,
      currentPage: params.page,
      pageSize: params.pageSize,
      hasNextPage: (params.page * params.pageSize) < totalCount,
    );
  }

  @override
  List<Object?> get props => [
    bookings,
    totalCount,
    currentPage,
    pageSize,
    hasNextPage,
  ];
}
