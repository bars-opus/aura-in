// lib/features/auth/presentation/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/auth/services/auth_service.dart';
import 'package:nano_embryo/presentation/features/chat/data/cache/chat_cache_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ==================== CORE PROVIDERS ====================

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseClientProvider));
});

// ==================== STATE PROVIDERS ====================

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges.map((event) => event.session?.user);
});

// Full auth state stream — exposes the event type (e.g. passwordRecovery).
final authEventProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

/// Current user provider - use this to get the logged-in user
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull;
});

final authErrorProvider = StateProvider<String?>((ref) => null);

final isLoadingProvider = StateProvider<bool>((ref) => false);

// ==================== OPERATIONS PROVIDER ====================

final authOperationsProvider = Provider<AuthOperations>((ref) {
  return AuthOperations(ref);
});

class AuthOperations {
  final Ref ref;

  AuthOperations(this.ref);

  // ==================== EMAIL/PASSWORD ====================

  Future<void> signInWithEmail(String email, String password) async {
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmail(email: email, password: password);
    } on AuthException catch (e) {
      ref.read(authErrorProvider.notifier).state = e.message;
      rethrow;
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.signUpWithEmail(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      ref.read(authErrorProvider.notifier).state = e.message;
      rethrow;
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  // ==================== OAUTH ====================

  Future<void> signInWithGoogle() async {
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();
    } on AuthException catch (e) {
      ref.read(authErrorProvider.notifier).state = e.message;
      rethrow;
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> signInWithApple() async {
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithApple();
    } on AuthException catch (e) {
      ref.read(authErrorProvider.notifier).state = e.message;
      rethrow;
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  // ==================== OTHER ====================

  Future<void> signOut() async {
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      // Clear chat cache before sign-out to prevent cross-session data leakage.
      await ref.read(chatCacheServiceProvider).clearAll();
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
    } on AuthException catch (e) {
      ref.read(authErrorProvider.notifier).state = e.message;
      rethrow;
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;
    try {
      final authService = ref.read(authServiceProvider);
      await authService.updatePassword(newPassword);
    } on AuthException catch (e) {
      ref.read(authErrorProvider.notifier).state = e.message;
      rethrow;
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  // Add this method to your existing AuthService class

  Future<void> resetPassword(String email) async {
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      final authService = ref.read(authServiceProvider);
      await authService.resetPassword(email);
    } on AuthException catch (e) {
      ref.read(authErrorProvider.notifier).state = e.message;
      rethrow;
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }
}
