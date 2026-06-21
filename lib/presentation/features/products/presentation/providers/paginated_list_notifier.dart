import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/products/data/exceptions/marketplace_exceptions.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_logger.dart';

/// Generic state for an offset-paginated list.
class PagedListState<T> {
  final List<T> items;
  final int page;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool hasMore;
  final String? error;

  const PagedListState({
    this.items = const [],
    this.page = 0,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.hasMore = true,
    this.error,
  });

  bool get isInitialLoading => items.isEmpty && (isLoadingMore || isRefreshing);

  PagedListState<T> copyWith({
    List<T>? items,
    int? page,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return PagedListState<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// StateNotifier that drives an infinite-scroll list. Subclasses override
/// [fetchPage] to plug in the actual data source.
///
/// Page size is hard-coded to 30 to match the repository defaults — if the
/// repo returns fewer than that, hasMore flips to false.
abstract class PagedListNotifier<T> extends StateNotifier<PagedListState<T>> {
  static const int pageSize = 30;

  // PagedListState<T>() not `const PagedListState()` — the const form infers
  // PagedListState<Never>, so the first copyWith(items: List<T>) in loadNext
  // throws "List<T> is not a subtype of List<Never>?".
  PagedListNotifier() : super(PagedListState<T>()) {
    // Kick off the first page eagerly so the UI shows the spinner.
    loadNext();
  }

  /// Subclasses fetch the requested page and return the items. Throwing
  /// a [MarketplaceException] surfaces a user-friendly message.
  Future<List<T>> fetchPage(int page, int limit);

  Future<void> loadNext() async {
    if (state.isLoadingMore || state.isRefreshing || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final fetched = await fetchPage(state.page, pageSize);
      state = state.copyWith(
        items: [...state.items, ...fetched],
        page: state.page + 1,
        hasMore: fetched.length >= pageSize,
        isLoadingMore: false,
      );
    } on MarketplaceException catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.message);
    } catch (e, stack) {
      MarketplaceLogger.error('PagedList fetch failed', error: e, stack: stack);
      state = state.copyWith(isLoadingMore: false, error: 'Failed to load');
    }
  }

  Future<void> refresh() async {
    // Type the reset to T — `const PagedListState()` infers
    // PagedListState<Never>, so a later copyWith(items: List<T>) throws
    // "List<T> is not a subtype of List<Never>?".
    state = PagedListState<T>(isRefreshing: true);
    try {
      final fetched = await fetchPage(0, pageSize);
      state = state.copyWith(
        items: fetched,
        page: 1,
        hasMore: fetched.length >= pageSize,
        isRefreshing: false,
      );
    } on MarketplaceException catch (e) {
      state = state.copyWith(isRefreshing: false, error: e.message);
    } catch (e, stack) {
      MarketplaceLogger.error('PagedList refresh failed', error: e, stack: stack);
      state = state.copyWith(isRefreshing: false, error: 'Failed to refresh');
    }
  }
}
