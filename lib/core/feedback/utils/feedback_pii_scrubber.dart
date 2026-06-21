/// Strips PII-flagged fields from a `device_info` map before persistence.
///
/// `DeviceInfoService` captures `device_name` on iOS, which is user-set and
/// commonly contains the owner's first name ("John's iPhone"). We don't want
/// that in `user_feedback.device_info` for compliance reasons.
///
/// Other fields are deterministic device properties (model, OS version) and
/// stay.
Map<String, dynamic>? scrubDeviceInfoForPersistence(
  Map<String, dynamic>? info,
) {
  if (info == null) return null;
  const piiKeys = {'device_name', 'name'};
  final scrubbed = <String, dynamic>{
    for (final entry in info.entries)
      if (!piiKeys.contains(entry.key)) entry.key: entry.value,
  };
  return scrubbed;
}
