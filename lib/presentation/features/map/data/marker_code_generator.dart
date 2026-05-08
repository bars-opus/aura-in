import 'package:flutter/material.dart';

class MarkerCodeGenerator {
  /// Get the type code for the shop (e.g., "SALON", "BARB", "SPA")
  static String getTypeCode(String? shopType) {
    switch (shopType?.toLowerCase()) {
      case 'salon':
        return 'SAL.';
      case 'barbershop':
        return 'BARB.';
      case 'spa':
        return 'SPA.';
      case 'nail_salon':
        return 'NAIL.';
      case 'specialty':
        return 'SPEC.';
      default:
        return 'SHOP';
    }
  }

  /// Get the luxury level color
  static Color getLuxuryColor(String? luxuryLevel) {
    switch (luxuryLevel?.toLowerCase()) {
      case 'moderate':
        return Colors.green;
      case 'luxury':
        return Colors.purple;
      case 'ultraluxury':
        return Colors.amber.shade700;
      default:
        return Colors.grey;
    }
  }
}
