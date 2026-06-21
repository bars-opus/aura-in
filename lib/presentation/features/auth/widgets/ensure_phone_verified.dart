// lib/presentation/features/auth/widgets/ensure_phone_verified.dart
//
// Gate for producer flows (freelancer / shop / product). Returns true when the
// account already has a verified phone, or completes verification via a
// phone-only AddContactModal. Returns false if the user dismisses.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/profile_providers/profile_provider.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/add_contact_modal.dart';

Future<bool> ensurePhoneVerified(BuildContext context, WidgetRef ref) async {
  final profile = await ref.read(currentUserProfileProvider.future);
  if (profile?.isPhoneVerified == true) return true;

  if (!context.mounted) return false;
  final result = await BottomSheetUtils.showDocumentationBottomSheet<bool>(
    context: context,
    widget: const AddContactModal(verifyMode: true),
  );
  return result == true;
}
