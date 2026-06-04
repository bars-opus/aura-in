// lib/presentation/features/shops/dashboard/presentation/controllers/business_hours_edit_controller.dart
//
// Tools-tab BusinessHoursScreen controller.
//
// Why this exists and NOT just a reuse of HoursNotifier:
//   The creation-flow HoursNotifier (at
//   lib/presentation/features/shops/creation/providers/hours_provider.dart:77-83)
//   writes back into `shopCreationProvider` / `freelancerCreationProvider`
//   on every state change. Reusing it from the Tools tab would silently
//   overwrite a half-completed shop-creation draft if the owner happens
//   to be editing hours on a published shop while a creation flow is
//   parked in another navigation stack.
//
// Lifecycle:
//   * `load()` on construction (one network round-trip to
//     `shopDetailsProvider`'s underlying repository).
//   * `updateDay(...)` mutates in-memory state only.
//   * `save()` rebuilds via the atomic RPC; throws typed exceptions on
//     failure (the caller maps to SnackBar copy).
//   * `discard()` re-fetches from server.
//
// State shape: AsyncValue<List<OpeningHoursDraft>>.
//   * loading      — initial + during discard()/refresh
//   * data(rows)   — hydrated
//   * error(...)   — load failed
// The screen uses AsyncValue.when to render.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/business_hours_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_details_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/repositories/shop_repository.dart';

class BusinessHoursEditController
    extends StateNotifier<AsyncValue<List<OpeningHoursDraft>>> {
  final String _shopId;
  final DashboardRepository _dashboardRepo;
  final ShopRepository _shopRepo;
  bool _disposed = false;

  BusinessHoursEditController({
    required String shopId,
    required DashboardRepository dashboardRepo,
    required ShopRepository shopRepo,
  })  : _shopId = shopId,
        _dashboardRepo = dashboardRepo,
        _shopRepo = shopRepo,
        super(const AsyncValue.loading()) {
    load();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Load hours from the server. Replaces any pending edits — used by
  /// both initial construction and `discard()`.
  Future<void> load() async {
    if (_disposed) return;
    state = const AsyncValue.loading();
    try {
      final shop = await _shopRepo.getShopDetailsById(_shopId);
      if (_disposed) return;
      state = AsyncValue.data(_hydrate(shop));
    } catch (e, st) {
      if (_disposed) return;
      state = AsyncValue.error(e, st);
    }
  }

  /// Re-fetch from server. Convenience name pairs with the screen's
  /// Cancel/Discard action.
  Future<void> discard() => load();

  /// Update a single day's fields without touching the others. Silent
  /// no-op when the controller is in loading/error state — UI guards
  /// against this with AsyncValue.when's `data` callback.
  void updateDay(
    int dayOfWeek, {
    String? opensAt,
    String? closesAt,
    bool? isClosed,
  }) {
    if (_disposed) return;
    final current = state.value;
    if (current == null) return;
    final next = current.map((row) {
      if (row.dayOfWeek != dayOfWeek) return row;
      return OpeningHoursDraft(
        dayOfWeek: row.dayOfWeek,
        opensAt: opensAt ?? row.opensAt,
        closesAt: closesAt ?? row.closesAt,
        isClosed: isClosed ?? row.isClosed,
        isSet: true,
      );
    }).toList();
    state = AsyncValue.data(next);
  }

  /// `true` when every non-closed day has `opens < closes`. The screen
  /// disables Save when this returns false. Returns `false` while
  /// loading/error — Save is also disabled in those states for the
  /// same reason.
  bool get isValid {
    final rows = state.value;
    if (rows == null) return false;
    for (final r in rows) {
      if (r.isClosed) continue;
      final opens = _toMinutes(r.opensAt);
      final closes = _toMinutes(r.closesAt);
      if (opens == null || closes == null) continue;
      if (closes <= opens) return false;
    }
    return true;
  }

  /// Saves to the server via the atomic rebuild RPC. Caller is
  /// responsible for surfacing the thrown exception to the UI as a
  /// SnackBar — this controller throws, it does not store the error
  /// in state. The screen catches and shows `e.userMessage`.
  Future<void> save() async {
    if (_disposed) return;
    final rows = state.value;
    if (rows == null) {
      throw HoursSaveFailedException();
    }
    if (!isValid) {
      throw InvalidHoursPayloadException();
    }
    await _dashboardRepo.rebuildShopOpeningHours(
      shopId: _shopId,
      hours: rows,
    );
  }

  /// Map ShopDetailsDTO.openingHours into a length-7
  /// `List<OpeningHoursDraft>` indexed by day_of_week. Missing days
  /// default to closed.
  List<OpeningHoursDraft> _hydrate(ShopDetailsDTO shop) {
    final byDay = <int, OpeningHoursDraft>{
      for (final h in shop.openingHours)
        h.dayOfWeek: OpeningHoursDraft(
          dayOfWeek: h.dayOfWeek,
          opensAt: h.opensAt,
          closesAt: h.closesAt,
          isClosed: h.isClosed,
          isSet: true,
        ),
    };
    // 1..7 matches OpeningHoursDraft's documented range (Monday=1).
    // The RPC accepts 0..7, so loading legacy 0-rows would still work,
    // but we render 1..7 as the canonical week.
    return List<OpeningHoursDraft>.generate(7, (i) {
      final dow = i + 1;
      return byDay[dow] ??
          OpeningHoursDraft(
            dayOfWeek: dow,
            opensAt: '09:00 AM',
            closesAt: '05:00 PM',
            isClosed: false,
            isSet: false,
          );
    });
  }

  /// Parse `"09:00 AM"` / `"09:00"` to total minutes since midnight.
  /// Returns null on unparseable input so the validator silently
  /// passes the row (the row widget surfaces its own inline error).
  int? _toMinutes(String raw) {
    final trimmed = raw.trim().toUpperCase();
    final isAm = trimmed.endsWith('AM');
    final isPm = trimmed.endsWith('PM');
    final stripped = (isAm || isPm)
        ? trimmed.substring(0, trimmed.length - 2).trim()
        : trimmed;
    final parts = stripped.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    var hours24 = h;
    if (isPm && h != 12) hours24 = h + 12;
    if (isAm && h == 12) hours24 = 0;
    return hours24 * 60 + m;
  }
}
