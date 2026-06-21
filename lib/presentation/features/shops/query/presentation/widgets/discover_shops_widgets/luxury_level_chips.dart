// lib/features/shops/presentation/widgets/luxury_level_chips.dart
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class LuxuryLevelChips extends ConsumerWidget {
  final String selectedCategory;
  final String? selectedLuxuryLevel;
  final Function(String?) onLuxurySelected;

  const LuxuryLevelChips({
    super.key,
    required this.selectedCategory,
    required this.selectedLuxuryLevel,
    required this.onLuxurySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final luxuryAsync = ref.watch(
      luxuryLevelListProvider(shopType: selectedCategory),
    );
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    return luxuryAsync.when(
      data:
          (luxuryLevels) =>
              _buildChips(context, luxuryLevels, colorScheme, loc, isLoading: false),
      loading:
          () => _buildChips(
            context,
            [], // Empty list during loading
            colorScheme,
            loc,
            isLoading: true,
          ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildChips(
    BuildContext context,
    List<LuxuryLevelInfo> luxuryLevels,
    ColorScheme colorScheme,
    AppLocalizations loc, {
    required bool isLoading,
  }) {
    // Define all possible luxury levels in order

    // ['Budget', 'Mid-range', 'Premium', 'Luxury'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // "All" chip
          Padding(
            padding: EdgeInsets.only(right: Spacing.sm.w),
            child: AppFilterChip(
              label: loc.luxuryLevelChipsAll,
              selected: !isLoading && selectedLuxuryLevel == null,
              onSelected:
                  isLoading
                      ? (_) {} // Disabled during loading
                      : (_) => onLuxurySelected(null),
              backgroundColor: colorScheme.background,
              labelColor: colorScheme.onBackground,
              borderWidth: 0.1,

              // fontSize: ,
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.sm.w,
                vertical: Spacing.xs.h,
              ),
            ),
          ),

          // Luxury level chips
          ...AppConstants.luxuryLevels.map((level) {
            // During loading, assume all levels have shops
            final hasShops =
                !isLoading
                    ? (luxuryLevels
                            .firstWhere(
                              (l) => l.level == level,
                              orElse:
                                  () => LuxuryLevelInfo(level: level, count: 0),
                            )
                            .count >
                        0)
                    : true; // Assume true during loading
            final isSelected = !isLoading && selectedLuxuryLevel == level;
            final displayName = _getLocalizedLuxuryLevel(level, loc);
            return Padding(
              padding: EdgeInsets.only(right: Spacing.sm.w),
              child: AppFilterChip(
                label: displayName,
                selected: isSelected,
                onSelected:
                    !isLoading && hasShops
                        ? (_) => onLuxurySelected(level)
                        : (_) {}, // Empty function when disabled or loading
                selectedColor: colorScheme.primary,
                backgroundColor: colorScheme.background,
                labelColor: colorScheme.onBackground,
                borderWidth: 0.3,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getLocalizedLuxuryLevel(String level, AppLocalizations loc) {
    switch (level) {
      case 'Moderate':
        return loc.luxuryLevelModerate;
      case 'Luxury':
        return loc.luxuryLevelLuxury;
      case 'UltraLuxury':
        return loc.luxuryLevelUltraLuxury;
      default:
        return level;
    }
  }
}
