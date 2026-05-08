// lib/core/utils/icon_code_point_helper.dart
import 'package:flutter/material.dart';

/// Helper utility to get Material Icon code points
/// Use this when adding new tools to the database
class ToolsIconCodePointHelper {
  /// Get code point for any Material Icon
  /// Example: getCodePoint(Icons.content_cut) -> returns 0xe14c
  static int getCodePoint(IconData icon) {
    return icon.codePoint;
  }
  
  /// Get the full icon data for a code point
  static IconData getIcon(int codePoint, {String fontFamily = 'MaterialIcons'}) {
    return IconData(codePoint, fontFamily: fontFamily);
  }
}

// Usage in development:
// print(ToolsIconCodePointHelper.getCodePoint(Icons.content_cut));
// Output: 57676 (0xe14c)
