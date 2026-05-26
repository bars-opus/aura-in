import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/map/config/feature/map_config.dart';
import 'package:nano_embryo/core/map/presentation/controllers/map_controller.dart';
import 'package:nano_embryo/core/map/presentation/providers/map_filter_providers.dart';

/// Floats at top-center of the map. Visible when the user has panned
/// since the last fetch (`MapState.viewportIsDirty == true`). Tapping
/// triggers `MapController.refreshForCurrentViewport`.
class SearchThisAreaPill extends ConsumerWidget {
  const SearchThisAreaPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDirty = ref.watch(
      mapControllerProvider.select((s) => s.viewportIsDirty),
    );
    final isFetching = ref.watch(
      mapControllerProvider.select((s) => s.isFetching),
    );
    final copy = ref.watch(mapConfigProvider.select((c) => c.copy));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: isDirty
          ? GestureDetector(
              key: const ValueKey('pill_visible'),
              onTap: isFetching
                  ? null
                  : () {
                      final controller =
                          ref.read(mapControllerProvider.notifier);
                      final filters = ref.read(mapFiltersProvider);
                      controller.refreshForCurrentViewport(filters);
                    },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.lg.w,
                  vertical: Spacing.sm.h,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isFetching) ...[
                      SizedBox(
                        width: 14.w,
                        height: 14.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: Spacing.sm.w),
                    ] else ...[
                      Icon(
                        Icons.search,
                        size: 16.r,
                        color: colorScheme.onPrimary,
                      ),
                      SizedBox(width: Spacing.xs.w),
                    ],
                    Text(
                      copy.searchThisAreaLabel,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(key: ValueKey('pill_hidden')),
    );
  }
}
