enum AccountLifecycleStatus {
  active('active'),
  deactivated('deactivated'),
  pendingDelete('pending_delete'),
  deleted('deleted');

  final String value;

  const AccountLifecycleStatus(this.value);

  static AccountLifecycleStatus fromValue(String? value) {
    return AccountLifecycleStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AccountLifecycleStatus.active,
    );
  }
}

class AccountLifecycleProfile {
  final String id;
  final AccountLifecycleStatus status;
  final DateTime? deactivatedAt;
  final DateTime? pendingDeletionAt;
  final DateTime? deletionScheduledFor;
  final DateTime? deletedAt;

  const AccountLifecycleProfile({
    required this.id,
    required this.status,
    this.deactivatedAt,
    this.pendingDeletionAt,
    this.deletionScheduledFor,
    this.deletedAt,
  });

  factory AccountLifecycleProfile.fromJson(Map<String, dynamic> json) {
    return AccountLifecycleProfile(
      id: json['id']?.toString() ?? '',
      status: AccountLifecycleStatus.fromValue(
        json['account_status']?.toString(),
      ),
      deactivatedAt: _parseDate(json['deactivated_at']),
      pendingDeletionAt: _parseDate(json['pending_deletion_at']),
      deletionScheduledFor: _parseDate(json['deletion_scheduled_for']),
      deletedAt: _parseDate(json['deleted_at']),
    );
  }

  bool get canRestore => status != AccountLifecycleStatus.deleted;
  bool get needsRestore =>
      status == AccountLifecycleStatus.deactivated ||
      status == AccountLifecycleStatus.pendingDelete;

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

class AccountLifecycleBlockers {
  final int activeBookings;
  final int ownedShopActiveBookings;
  final int activeOrders;
  final int ownedShopActiveOrders;
  final int activeWithdrawals;

  const AccountLifecycleBlockers({
    required this.activeBookings,
    required this.ownedShopActiveBookings,
    required this.activeOrders,
    required this.ownedShopActiveOrders,
    required this.activeWithdrawals,
  });

  factory AccountLifecycleBlockers.fromJson(Map<String, dynamic> json) {
    return AccountLifecycleBlockers(
      activeBookings: _readInt(json['active_bookings']),
      ownedShopActiveBookings: _readInt(json['owned_shop_active_bookings']),
      activeOrders: _readInt(json['active_orders']),
      ownedShopActiveOrders: _readInt(json['owned_shop_active_orders']),
      activeWithdrawals: _readInt(json['active_withdrawals']),
    );
  }

  bool get hasBlockers =>
      activeBookings > 0 ||
      ownedShopActiveBookings > 0 ||
      activeOrders > 0 ||
      ownedShopActiveOrders > 0 ||
      activeWithdrawals > 0;

  int get total =>
      activeBookings +
      ownedShopActiveBookings +
      activeOrders +
      ownedShopActiveOrders +
      activeWithdrawals;

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class AccountLifecycleActionResult {
  final bool success;
  final String? reason;
  final AccountLifecycleBlockers? blockers;
  final DateTime? deletionScheduledFor;

  const AccountLifecycleActionResult({
    required this.success,
    this.reason,
    this.blockers,
    this.deletionScheduledFor,
  });

  factory AccountLifecycleActionResult.fromJson(Map<String, dynamic> json) {
    final blockers = json['blockers'];
    return AccountLifecycleActionResult(
      success: json['success'] == true,
      reason: json['reason'] as String?,
      blockers:
          blockers is Map<String, dynamic>
              ? AccountLifecycleBlockers.fromJson(blockers)
              : null,
      deletionScheduledFor: DateTime.tryParse(
        json['deletion_scheduled_for']?.toString() ?? '',
      ),
    );
  }
}
