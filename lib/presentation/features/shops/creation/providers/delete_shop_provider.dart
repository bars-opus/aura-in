// lib/features/shop/creation/presentation/providers/delete_shop_provider.dart

import 'package:nano_embryo/presentation/features/shops/creation/repository/supabase_shop_creation_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_shop_provider.g.dart';

enum DeleteShopStatus { idle, loading, success, error }

class DeleteShopState {
  final DeleteShopStatus status;
  final String? error;
  final bool isDeleting;

  const DeleteShopState({
    this.status = DeleteShopStatus.idle,
    this.error,
    this.isDeleting = false,
  });

  DeleteShopState copyWith({
    DeleteShopStatus? status,
    String? error,
    bool? isDeleting,
  }) {
    return DeleteShopState(
      status: status ?? this.status,
      error: error,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

@riverpod
class DeleteShopNotifier extends _$DeleteShopNotifier {
  @override
  DeleteShopState build() => const DeleteShopState();

  /// Delete a shop
  Future<bool> deleteShop(String shopId) async {
    state = const DeleteShopState(
      status: DeleteShopStatus.loading,
      isDeleting: true,
    );

    try {
      final repository = ref.read(shopCreationRepositoryProvider);

      // Call the Supabase RPC function
      await repository.deleteShop(shopId);

      state = const DeleteShopState(
        status: DeleteShopStatus.success,
        isDeleting: false,
      );

      return true;
    } catch (e) {
      state = DeleteShopState(
        status: DeleteShopStatus.error,
        error: _getUserFriendlyError(e),
        isDeleting: false,
      );
      return false;
    }
  }

  /// Reset state
  void reset() {
    state = const DeleteShopState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null, status: DeleteShopStatus.idle);
  }

  /// Get user-friendly error message
  String _getUserFriendlyError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('foreign key')) {
      return 'Cannot delete shop because it has existing bookings.';
    }
    if (errorString.contains('permission') ||
        errorString.contains('unauthorized')) {
      return 'You don\'t have permission to delete this shop.';
    }
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your connection.';
    }

    return 'Failed to delete shop. Please try again.';
  }
}
