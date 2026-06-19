// lib/presentation/features/auth/providers/phone_verification_provider.dart
//
// Drives the Twilio Verify edge functions for one-time phone verification.
// On a successful check, invalidates the profile so isPhoneVerified flips.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/core/providers/profile_providers/profile_provider.dart';

class PhoneVerificationController {
  PhoneVerificationController(this._ref);
  final Ref _ref;

  Future<void> sendCode(String phoneE164) async {
    final client = _ref.read(supabaseClientProvider);
    final res = await client.functions.invoke(
      'phone-verify-start',
      body: {'phone_e164': phoneE164},
    );
    final data = res.data;
    final ok = data is Map && data['success'] == true;
    if (!ok) {
      throw Exception(
        (data is Map ? data['error'] : null)?.toString() ??
            'Could not send code. Please try again.',
      );
    }
  }

  /// Returns true when the code was approved and the profile updated.
  Future<bool> verifyCode(String phoneE164, String code) async {
    final client = _ref.read(supabaseClientProvider);
    final res = await client.functions.invoke(
      'phone-verify-check',
      body: {'phone_e164': phoneE164, 'code': code},
    );
    final data = res.data;
    final verified = data is Map && data['verified'] == true;
    if (verified) {
      _ref.invalidate(currentUserProfileProvider);
    }
    return verified;
  }
}

final phoneVerificationControllerProvider =
    Provider<PhoneVerificationController>(
  (ref) => PhoneVerificationController(ref),
);
