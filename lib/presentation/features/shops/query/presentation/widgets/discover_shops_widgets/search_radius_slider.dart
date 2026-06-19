import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/search_radius_provider.dart';

/// Slider controlling the discover-screen search radius (km).
///
/// Updates local state during drag for smooth UI; commits to
/// [searchRadiusKmProvider] on release (`onChangeEnd`) so dependent providers
/// only refetch once per gesture instead of on every pixel.
class SearchRadiusSlider extends ConsumerStatefulWidget {
  const SearchRadiusSlider({super.key});

  @override
  ConsumerState<SearchRadiusSlider> createState() => _SearchRadiusSliderState();
}

class _SearchRadiusSliderState extends ConsumerState<SearchRadiusSlider> {
  late double _value;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _value = ref.read(searchRadiusKmProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    // Sync local state if the provider changed from elsewhere (e.g. reset).
    final providerValue = ref.watch(searchRadiusKmProvider);
    if (!_isDragging && providerValue != _value) {
      _value = providerValue;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.searchRadiusSliderTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              MiniContainerIndicator(
                color: colorScheme.primary,
                text: '${_value.toInt()} km',
                fontSize: 16,
              ),
            ],
          ),
          Slider(
            value: _value,
            min: kSearchRadiusMinKm,
            max: kSearchRadiusMaxKm,
            divisions: (kSearchRadiusMaxKm - kSearchRadiusMinKm).toInt(),
            label: '${_value.toInt()} km',
            onChanged: (value) {
              // Light haptic on each integer-km tick crossed, mirroring native
              // picker behavior on iOS / Android.
              if (value.toInt() != _value.toInt()) {
                HapticFeedback.selectionClick();
              }
              setState(() {
                _value = value;
                _isDragging = true;
              });
            },
            onChangeEnd: (value) {
              // Slightly stronger haptic on release to confirm commit.
              HapticFeedback.lightImpact();
              setState(() => _isDragging = false);
              ref.read(searchRadiusKmProvider.notifier).state = value;
            },
          ),
          Text(
            loc.searchRadiusSliderSubtitle(_value.toInt()),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
