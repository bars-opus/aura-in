// lib/features/shop/creation/utils/undo_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service to handle undo operations for destructive actions
class UndoService {
  static void showUndoSnackbar({
    required BuildContext context,
    required String message,
    required VoidCallback onUndo,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: onUndo,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Mixin to add undo capability to providers
mixin UndoCapability<T> on StateNotifier<T> {
  T? _previousState;

  void saveSnapshot() {
    _previousState = state;
  }

  bool undo() {
    if (_previousState != null) {
      state = _previousState as T;
      _previousState = null;
      return true;
    }
    return false;
  }
}
