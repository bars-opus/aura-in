// lib/core/extensions/snackbar_extensions.dart
import 'package:flutter/material.dart';
import 'package:nano_embryo/core/widgets/feedback/snackbar_widget.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';

extension LocalizedSnackbar on BuildContext {
  // Success messages
  void showSuccessSnackbar(String message, {Color? backgroundColor}) {
    Snackbar.success(this, message, backgroundColor: backgroundColor);
  }

  void showSuccessSnackbarKey(String messageKey) {
    final loc = AppLocalizations.of(this);
    Snackbar.success(this, loc?.getTranslation(messageKey) ?? messageKey);
  }

  // Error messages
  void showErrorSnackbar(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    Snackbar.error(this, message, actionLabel: actionLabel, onAction: onAction);
  }

  void showErrorSnackbarKey(
    String messageKey, {
    String? actionKey,
    VoidCallback? onAction,
  }) {
    final loc = AppLocalizations.of(this);
    Snackbar.error(
      this,
      loc?.getTranslation(messageKey) ?? messageKey,
      actionLabel: actionKey != null ? loc?.getTranslation(actionKey) : null,
      onAction: onAction,
    );
  }

  // Warning messages
  void showWarningSnackbar(String message) {
    Snackbar.warning(this, message);
  }

  void showWarningSnackbarKey(String messageKey) {
    final loc = AppLocalizations.of(this);
    Snackbar.warning(this, loc?.getTranslation(messageKey) ?? messageKey);
  }

  // Info messages
  void showInfoSnackbar(String message) {
    Snackbar.info(this, message);
  }

  void showInfoSnackbarKey(String messageKey) {
    final loc = AppLocalizations.of(this);
    Snackbar.info(this, loc?.getTranslation(messageKey) ?? messageKey);
  }

  // Loading messages
  void showLoadingSnackbar(
    String message, {
    Color? progressColor,
    Color? backgroundColor,
  }) {
    // Option 1: Use the regular show method
    Snackbar.show(
      context: this,
      message: message,
      type: SnackbarType.loading,
      dismissible: false,
      // duration: Duration(milliseconds: 2000),
    );
  }

  void showLoadingSnackbarKey(String messageKey) {
    final loc = AppLocalizations.of(this);
    Snackbar.loading(this, loc?.getTranslation(messageKey) ?? messageKey);
  }

  // Hide snackbar
  void hideSnackbar() {
    Snackbar.hide(this);
  }
}

// Optional: Add direct translation method if not exists
extension AppLocalizationsExtensions on AppLocalizations {
  String getTranslation(String key) {
    // This depends on how your localization keys work
    // If you have a method for each key, you'll need a different approach
    // Example: if key is 'loginSuccess', you might need reflection or a map
    return key; // Placeholder - implement based on your structure
  }
}
