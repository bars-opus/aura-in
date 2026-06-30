import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/connectivity_provider.dart';

/// App-wide connectivity banner for the HomeScreen shell.
///
/// Uses the shared connectivity provider so there is a single source of truth
/// for online/offline state across the app. The banner is shown at the top to
/// communicate global status without covering bottom navigation or bottom CTAs.
class NetworkStatus extends ConsumerWidget {
  final Widget child;

  const NetworkStatus({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connectivityAsync = ref.watch(connectivityStreamProvider);
    final showOfflineBanner = connectivityAsync.maybeWhen(
      data: (result) => result == ConnectivityResult.none,
      orElse: () => false,
    );

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        child,
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: Spacing.xxl.h + Spacing.xxl.h + Spacing.sm.h,
              left: Spacing.md.w,
              right: Spacing.md.w,
            ),
            child: SizedBox(
              height: 50.h,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                offset: showOfflineBanner ? Offset.zero : const Offset(0, -1.2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: showOfflineBanner ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !showOfflineBanner,
                    child: Material(
                      color: Colors.transparent,
                      child: SemanticContainerWidget(
                        borderRadius: 100.r,
                        content: 'Connect to the internet and try again',
                        icon: Icons.wifi_off_rounded,
                        title: '',
                        backgroundColor: theme.colorScheme.error.withOpacity(
                          0.7,
                        ),
                        borderColor: theme.colorScheme.background,
                        iconColor: theme.colorScheme.background,
                        textTheme: theme.textTheme,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
