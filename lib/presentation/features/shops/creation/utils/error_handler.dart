// lib/features/shop/creation/utils/error_handler.dart

import 'package:flutter/material.dart';

class ShopCreationErrorHandler {
  static String getUserFriendlyMessage(dynamic error) {
    if (error.toString().contains('duplicate key')) {
      return 'A shop with this name already exists';
    }
    if (error.toString().contains('network')) {
      return 'Network error. Please check your connection';
    }
    if (error.toString().contains('timeout')) {
      return 'Request timed out. Please try again';
    }
    if (error.toString().contains('permission')) {
      return 'You don\'t have permission to perform this action';
    }
    if (error.toString().contains('storage')) {
      return 'Failed to upload images. Please try again';
    }
    
    return 'Something went wrong. Please try again';
  }

  static void showErrorSnackbar(BuildContext context, dynamic error) {
    final message = getUserFriendlyMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
