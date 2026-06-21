import 'package:nano_embryo/presentation/features/auth/utility/auth_exports.dart';

class LoginProfile extends ConsumerWidget {
  // Change to ConsumerWidget

  const LoginProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add WidgetRef
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;

    // 🎯 Watch the profile for this user
    final profileAsync = ref.watch(currentUserProfileProvider);

    // Handle loading state
    if (profileAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularLoadingIndicator()));
    }

    // Handle error state
    if (profileAsync.hasError) {
      return Scaffold(
        body: ErrorStateWidget(
          showDetails: true,
          title: '',
          subtitle:
              'Unable to process profile.\nThis might be a temporary issue',
          errorDetails: '',
          type: ErrorStateType.genericError,
        ),
      );
    }

    Widget _buildAuthButtons() {
      final loc = AppLocalizations.of(context)!;
      final authButtons = getAuthButtons(loc, '', ref); // Add ref here

      return Column(
        children:
            authButtons
                .mapIndexed(
                  (index, button) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index < authButtons.length - 1 ? Spacing.sm.h : 0,
                    ),
                    child: AppButton(
                      center: false,
                      elevation: 0,
                      prefixIcon: button.prefixIcon,
                      prefixIconColor: colorScheme.background,
                      label: button.label,
                      onPressed:
                          () =>
                              button.onPressed?.call(context), // Use safe call
                      iconData: button.icon,
                      borderRadius: BorderRadiusTokens.xlAll,
                      size: ButtonSize.small,
                      width: double.infinity,
                      padding: Spacing.horizontalMd,
                      height: 50.h,

                      textColor: colorScheme.background,
                      customColor: colorScheme.primary,
                    ),
                  ),
                )
                .toList(),
      );
    }

    String _overview = loc.authGuestOverview(AppConstants.appName);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: AppIconButton(
                      icon: Icons.menu,
                      onPressed: () => context.push('/settings'),
                    ),
                  ),
                  Gap(Spacing.lg.h),
                  Center(
                    child: Text(
                      loc.authGuestHello,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        fontSize: 40,
                      ),
                    ),
                  ),
                  Gap(Spacing.md.h),
                  GestureDetector(
                    onTap: () {
                      BottomSheetUtils.showDocumentationBottomSheet(
                        context: context,
                        widget: ReadAll(body: _overview),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _overview,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            height: 1.5.h,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          loc.commonLearnMore,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Gap(Spacing.md.h),
                  AppButton(
                    height: 45.h,
                    label: loc.createAccount,
                    onPressed: () {
                      BottomSheetUtils.showDocumentationBottomSheet(
                        context: context,
                        document: LegalDocumentationData.eula(context),
                        onAgree: () {
                          context.goNamed('loginOptions', extra: 'Register');
                        },
                        onDecline: () {
                          Navigator.pop(context);
                        },
                        agreeButtonText: loc.commonAccept,
                        declineButtonText: loc.commonReject,
                      );
                    },
                    borderRadius: BorderRadiusTokens.xlAll,
                    variant: ButtonVariant.outline,
                    size: ButtonSize.small,
                    width: double.infinity,
                    outlineColor: colorScheme.onBackground,
                    textColor: colorScheme.onBackground,
                  ),
                  Gap(Spacing.md.h - 3),
                  _buildAuthButtons(),
                  Gap(Spacing.md.h),
                ],
              ),
            ),
          ),
        ),

        SliverFillRemaining(
          child: TabsWithContent(
            useNestedScrollMode: false,
            tabs: buildProfileTabs('', false, true,).toList(),
            initialIndex: 0,
            scrollable: false,
            showContent: true,
            
          ),
        ),
      ],
    );
  }
}
