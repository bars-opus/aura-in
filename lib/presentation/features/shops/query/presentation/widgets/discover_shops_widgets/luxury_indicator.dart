import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class LuxuryIndicator extends StatelessWidget {
  final String luxuryLevel;
  const LuxuryIndicator({super.key, required this.luxuryLevel});

  @override
  Widget build(BuildContext context) {
    Color _getLuxuryColor(String level) {
      switch (level) {
        case 'Moderate':
          return Colors.green;
        case 'Luxury':
          return Colors.purple;
        case 'UltraLuxury':
          return Colors.amber.shade700;
        default:
          return Colors.grey;
      }
    }

    return luxuryLevel.isEmpty
        ? const SizedBox.shrink()
        : MiniContainerIndicator(
          color: _getLuxuryColor(luxuryLevel),
          text: luxuryLevel,
        );
  }
}
