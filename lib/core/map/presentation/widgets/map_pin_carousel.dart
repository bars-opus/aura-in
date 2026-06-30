import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:nano_embryo/core/map/config/feature/map_config.dart';
import 'package:nano_embryo/core/map/presentation/controllers/map_controller.dart';
import 'package:nano_embryo/core/utils/haptic_feedback_utils.dart';

/// Always-visible horizontal carousel at the bottom of the map.
///
/// Bidirectional sync with marker selection:
/// - Page change → `controller.selectPin(pinId)`. The screen listens
///   and flies the camera to the selected pin.
/// - `selectedPinId` change (from outside, e.g. marker tap) →
///   carousel animates to that page. The `_isProgrammaticChange` flag
///   prevents the listener loop.
///
/// Hidden (zero-height) when there are no pins.
class MapPinCarousel extends ConsumerStatefulWidget {
  const MapPinCarousel({super.key});

  @override
  ConsumerState<MapPinCarousel> createState() => _MapPinCarouselState();
}

class _MapPinCarouselState extends ConsumerState<MapPinCarousel> {
  static const double _carouselHeight = 240;
  static const double _viewportFraction = 0.88;

  late final PageController _pageController;
  bool _isProgrammaticChange = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _viewportFraction);
    _pageController.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    if (_isProgrammaticChange) return;
    if (!_pageController.hasClients || _pageController.page == null) return;
    final pins = ref.read(mapControllerProvider).pins;
    if (pins.isEmpty) return;

    final pageIndex = _pageController.page!.round();
    if (pageIndex < 0 || pageIndex >= pins.length) return;

    final pin = pins[pageIndex];
    final currentSelected = ref.read(mapControllerProvider).selectedPinId;
    if (currentSelected != pin.id) {
      // Haptic feedback when a new card snaps to center.
      // selectionClick is the iOS-style subtle tap; on Android it maps to
      // a light click. Only fire when the focused pin actually changes
      // (not for in-between scroll positions).
      HapticFeedbackUtils.triggerSelectionFeedback();
      ref.read(mapControllerProvider.notifier).selectPin(pin.id);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pins = ref.watch(mapControllerProvider.select((s) => s.pins));
    final selectedId = ref.watch(
      mapControllerProvider.select((s) => s.selectedPinId),
    );
    final config = ref.watch(mapConfigProvider);

    // External selection change → animate carousel to that page.
    ref.listen<String?>(mapControllerProvider.select((s) => s.selectedPinId), (
      prev,
      next,
    ) {
      if (next == null) return;
      final index = pins.indexWhere((p) => p.id == next);
      if (index < 0) return;
      if (!_pageController.hasClients) return;
      final current = _pageController.page?.round();
      if (current == index) return;

      _isProgrammaticChange = true;
      _pageController
          .animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          )
          .then((_) {
            if (mounted) {
              Future<void>.delayed(const Duration(milliseconds: 50), () {
                _isProgrammaticChange = false;
              });
            }
          });
    });

    if (pins.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: SizedBox(
        height: _carouselHeight.h,
        child: PageView.builder(
          controller: _pageController,
          itemCount: pins.length,
          itemBuilder: (context, index) {
            final pin = pins[index];
            final isSelected = pin.id == selectedId;
            return Semantics(
              button: true,
              label: 'View shop ${index + 1} of ${pins.length}',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => config.onPinTap(pin, context),
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.symmetric(
                    vertical: isSelected ? 0 : 6.h,
                    horizontal: isSelected ? 0 : 3.w,
                  ),
                  child: config.buildCarouselCard(pin, isSelected, context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
