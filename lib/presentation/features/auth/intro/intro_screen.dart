import 'package:nano_embryo/core/providers/shared_prefs_provider.dart';

import 'package:nano_embryo/presentation/features/auth/utility/auth_exports.dart';

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  final PageController pageController = PageController();
  late ScrollController _scrollController;

  List<DocumentationModule> modules = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    DocumentationRegistry.initialize();
    modules = DocumentationRegistry.getAllModules();
    // Schedule the scroll after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && modules.length > 1) {
        // Get the screen width
        final screenWidth = MediaQuery.of(context).size.width;
        final itemWidth = _getItemWidth();

        // Calculate offset to center the second item (index 1)
        // Formula: (itemWidth * index) - (screenWidth/2) + (itemWidth/2)
        final offset = (itemWidth * 1) - (screenWidth / 2) + (itemWidth / 2);

        // Ensure offset is not negative (for first items)
        final clampedOffset = offset.clamp(0.0, double.infinity);

        _scrollController.jumpTo(clampedOffset);
      }
    });
  }

  double _getItemWidth() {
    return 250.w; // Your item width
  }

  // void _startAutoAdvanceTimer() {
  //   autoAdvanceTimer = Timer.periodic(Duration(seconds: 30), (timer) {
  //     if (pageController.hasClients && modules.length > 1) {
  //       final currentPage = pageController.page?.toInt() ?? 0;
  //       final isLastPage = currentPage == modules.length - 1;

  //       if (isLastPage) {
  //         pageController.jumpToPage(0);
  //       } else {
  //         final nextPage = currentPage + 1;
  //         pageController.animateToPage(
  //           nextPage,
  //           duration: Duration(milliseconds: 500),
  //           curve: Curves.easeInOut,
  //         );
  //       }
  //     }
  //   });
  // }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.appColors.appColor,

      body: SafeArea(
        child: Column(
          children: [
            // Top Section with Title and Subtitle
            Padding(
              padding: EdgeInsets.all(20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Gap(Spacing.xxl.h + 30),

                  // Main Title
                  Text(
                    'Welcome\n${AppConstants.appName}',
                    style: textTheme.displayLarge?.copyWith(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.background,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Gap(Spacing.sm.h),

                  // Legal Text
                  Text(
                    'Welcome to this new platform we made for you. Enjoy yourself and have fun. We have the best waiting for you.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.background,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Gap(Spacing.xxl.h),
                  SizedBox(
                    width: 200.w,
                    child: AppButton(
                      height: 45.h,
                      label: loc.introGetStarted,
                      onPressed: () async {
                        final prefsService = ref.read(
                          preferencesServiceProvider,
                        );
                        await prefsService.setFirstLaunchCompleted();

                        // 🚨 CRITICAL: Tell Riverpod to reload isFirstLaunchProvider
                        ref.invalidate(isFirstLaunchProvider);

                        // Now navigate
                        // context.go('/home');
                      },

                      borderRadius: BorderRadiusTokens.xlAll,
                      variant: ButtonVariant.outline,
                      size: ButtonSize.small,
                      width: double.infinity,
                      outlineColor: colorScheme.background,
                      textColor: colorScheme.background,
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Modules List
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 250.h,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: modules.length,
                      itemBuilder: (context, index) {
                        final module = modules[index];
                        return SizedBox(
                          width: 250.w, // Make sure items have fixed width
                          child: IntroGuideWidget(module: module),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Section with Legal Text and Button
            GestureDetector(
              onTap: () {
                BottomSheetUtils.showDocumentationBottomSheet(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  context: context,
                  widget: AllLegalDocumentationsScreen(),
                );
              },
              child: Text(
                'Read legalities',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.background,
                  decoration: TextDecoration.underline,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Gap(Spacing.xl.h),
          ],
        ),
      ),
    );
  }
}
