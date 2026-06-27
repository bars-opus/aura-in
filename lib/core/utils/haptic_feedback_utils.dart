import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticFeedbackUtils {
  const HapticFeedbackUtils._();

  static Future<void> triggerSelectionFeedback() async {
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        await Vibration.vibrate(duration: 35, amplitude: 96);
        return;
      }
    } catch (_) {
      // Fall back to Flutter haptics below.
    }

    await HapticFeedback.selectionClick();
  }
}
