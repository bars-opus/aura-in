class AccountLifecycleGuardResult {
  final bool shouldRedirect;
  final String? route;

  const AccountLifecycleGuardResult._(this.shouldRedirect, this.route);

  const AccountLifecycleGuardResult.allow() : this._(false, null);

  const AccountLifecycleGuardResult.redirect(String route)
    : this._(true, route);
}

AccountLifecycleGuardResult accountLifecycleGuard({
  required Object? profile,
  required String currentLocation,
  required String restoreRoute,
  required String homeRoute,
}) {
  final status = accountLifecycleStatusFromProfile(profile);
  final needsRestore =
      status == 'deleted' ||
      status == 'deactivated' ||
      status == 'pending_delete';

  if (needsRestore) {
    if (currentLocation == restoreRoute) {
      return const AccountLifecycleGuardResult.allow();
    }
    return AccountLifecycleGuardResult.redirect(restoreRoute);
  }

  if (currentLocation == restoreRoute) {
    return AccountLifecycleGuardResult.redirect(homeRoute);
  }

  return const AccountLifecycleGuardResult.allow();
}

String? accountLifecycleStatusFromProfile(Object? profile) {
  if (profile == null) return null;
  if (profile is Map<String, dynamic>) {
    return profile['account_status'] as String?;
  }

  try {
    final dynamic value = profile;
    final json = value.toJson() as Map<String, dynamic>;
    return json['account_status'] as String?;
  } catch (_) {
    return null;
  }
}
