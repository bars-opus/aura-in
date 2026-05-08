// lib/features/shop/creation/utils/validation_messages.dart

import '../domain/models/shop_draft.dart';

class ValidationMessages {
  static String? validateShopName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Shop name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Invalid price';
    }
    if (price <= 0) {
      return 'Price must be greater than 0';
    }
    if (price > 10000) {
      return 'Price seems too high';
    }
    return null;
  }

  static String? validateDuration(String? value) {
    if (value == null || value.isEmpty) {
      return 'Duration is required';
    }
    final minutes = int.tryParse(value);
    if (minutes == null) {
      return 'Invalid duration';
    }
    if (minutes < 5) {
      return 'Minimum 5 minutes';
    }
    if (minutes > 480) {
      return 'Maximum 8 hours';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }
    // Simple phone validation - can be enhanced with libphonenumber
    if (!RegExp(r'^[\d\-\+\s\(\)]{10,}$').hasMatch(value)) {
      return 'Invalid phone number';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Invalid email';
    }
    return null;
  }

  static String getSectionRequirementMessage(ShopDraft draft) {
    final missing = <String>[];
    
    if (!draft.isBasicsComplete) missing.add('basic info');
    if (!draft.isLocationComplete) missing.add('location');
    if (!draft.isServicesComplete) missing.add('at least one service');
    if (!draft.isHoursComplete) missing.add('opening hours');
    if (!draft.isMediaComplete) missing.add('3 photos');
    
    if (missing.isEmpty) return 'Ready to publish!';
    
    if (missing.length == 1) {
      return 'Missing: ${missing[0]}';
    }
    
    final last = missing.last;
    final others = missing.sublist(0, missing.length - 1).join(', ');
    return 'Missing: $others and $last';
  }
}
