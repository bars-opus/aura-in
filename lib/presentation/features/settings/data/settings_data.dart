// lib/features/settings/data/settings_data.dart
import 'dart:io';
import 'package:nano_embryo/app/routing/app_router.dart' as routes;
import 'package:nano_embryo/core/link/entity_share_links.dart';
import 'package:nano_embryo/core/link/widgets/link_qr_view.dart';
import 'package:nano_embryo/core/providers/routing_providers.dart';
import 'package:nano_embryo/core/providers/shared_prefs_provider.dart';
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsDataSource {
  static List<SettingsSection> getSettingsSections(
    BuildContext context,
    String currentUserId,
  ) {
    // Access localization for language prefence
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Profile share — no dedicated web page for user profiles, so we use
    // the app home URL with the user's display name in the share text.
    final displayName =
        Supabase.instance.client.auth.currentUser?.userMetadata?['display_name']
            as String? ??
        '';
    final profileShareUrl = EntityShareLinks.homeUrl;
    final profileShareText = EntityShareLinks.shareText(
      url: profileShareUrl,
      displayName: displayName.isNotEmpty ? displayName : null,
    );

    return [
      // ── Section 1: Profile & Preferences ─────────────────────────────────
      SettingsSection(
        id: 'account',
        title: '',
        items: [
          SettingsConfig(
            id: 'profile',
            title: loc.profileItemTitle,
            subtitle: loc.profileItemSubtitle,
            icon: Icons.person,
            type: SettingsItemType.navigation,
            routeName: RouteNames.editScreen,
            onTap: () => context.push(RouteNames.editScreen),
            iconColor: theme.colorScheme.primary,
            order: 1,
          ),
          SettingsConfig(
            id: 'location',
            title: loc.locationItemTitle,
            subtitle: loc.locationItemSubtitle,
            icon: Icons.location_on,
            type: SettingsItemType.navigation,
            routeName: '/editLocation',
            onTap: () => context.push('/editLocation'),
            iconColor: Colors.green,
            order: 2,
          ),
          SettingsConfig(
            id: 'notifications',
            title: loc.notificationsItemTitle,
            subtitle: loc.notificationsItemSubtitle,
            icon: Icons.notifications,
            type: SettingsItemType.navigation,
            routeName: '/notifications',
            iconColor: Colors.orange,
            order: 3,
          ),
          SettingsConfig(
            id: 'blocked',
            title: loc.blockedItemTitle,
            subtitle: loc.blockedItemSubtitle,
            icon: Icons.block,
            type: SettingsItemType.navigation,
            routeName: RouteNames.blockedAccounts,
            iconColor: Colors.red,
            order: 4,
          ),
        ],
      ),

      // ── Section 2: My Activity ────────────────────────────────────────────
      SettingsSection(
        id: 'activity',
        title: 'My Activity',
        items: [
          SettingsConfig(
            id: 'my_shops',
            title: 'My Shops',
            subtitle: 'Manage your shops and services',
            icon: Icons.store_outlined,
            type: SettingsItemType.navigation,
            routeName: RouteNames.myShopsScreen,
            onTap: () => context.push(RouteNames.myShopsScreen),
            iconColor: Colors.teal,
            order: 1,
          ),
          SettingsConfig(
            id: 'customer_orders',
            title: 'My Orders',
            subtitle: 'Track your product orders',
            icon: Icons.shopping_bag_outlined,
            type: SettingsItemType.navigation,
            routeName: RouteNames.customerOrders,
            onTap: () => context.push(RouteNames.customerOrders),
            iconColor: Colors.indigo,
            order: 2,
          ),
        ],
      ),

      // ── Section 3: Share ──────────────────────────────────────────────────
      SettingsSection(
        id: 'share',
        title: 'Share',
        items: [
          SettingsConfig(
            id: 'qr_code',
            title: loc.qrCodeItemTitle,
            subtitle: loc.qrCodeItemSubtitle,
            icon: Icons.qr_code_2_rounded,
            type: SettingsItemType.action,
            iconColor: Colors.purple,
            order: 1,
            onTap: () {
              BottomSheetUtils.showDocumentationBottomSheet(
                context: context,
                widget: Padding(
                  padding: EdgeInsets.all(Spacing.lg),
                  child: LinkQrView(
                    url: profileShareUrl,
                    label: displayName.isNotEmpty ? displayName : 'My profile',
                  ),
                ),
              );
            },
          ),
          SettingsConfig(
            id: 'share_profile',
            title: loc.shareProfileItemTitle,
            subtitle: loc.shareProfileItemSubtitle,
            icon: Icons.share,
            type: SettingsItemType.action,
            iconColor: Colors.blue,
            order: 2,
            onTap: () async {
              if (Platform.isIOS) {
                await Share.shareUri(Uri.parse(profileShareUrl));
              } else {
                await Share.share(profileShareText);
              }
            },
          ),
        ],
      ),
      SettingsSection(
        id: 'app',
        title:
        //Change to display settings
         loc.appSettingsSectionTitle,
        subtitle: loc.appSettingsSectionSubtitle,
        items: [
          SettingsConfig(
            id: 'theme',
            title: loc.themeItemTitle,
            subtitle: loc.themeItemSubtitle,
            icon: Icons.dark_mode,
            type: SettingsItemType.navigation,
            routeName: '/theme',
            iconColor: Colors.grey,
            order: 1,
          ),
          SettingsConfig(
            id: 'language',
            title: loc.languageItemTitle,
            subtitle: loc.languageItemSubtitle,
            icon: Icons.language_outlined,
            type: SettingsItemType.navigation,
            onTap: () => context.push('/language'),
            iconColor: Colors.grey,
            order: 1,
            trailing: Consumer(
              builder: (context, ref, child) {
                final currentLanguage = ref.watch(localeNotifierProvider);
                return Text(
                  currentLanguage.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),
         
        ],
      ),
      SettingsSection(
        id: 'support',
        title: loc.supportSectionTitle,
        items: [
          SettingsConfig(
            id: 'guide',
            title: loc.guideItemTitle,
            subtitle: loc.guideItemSubtitle,
            icon: Icons.menu_book,
            onTap: () {},
            type: SettingsItemType.info,
            routeName: '/guide',
            iconColor: Colors.grey,
            order: 1,
          ),
          SettingsConfig(
            id: 'help',
            title: loc.helpItemTitle,
            subtitle: loc.helpItemSubtitle,
            icon: Icons.support_agent,
            type: SettingsItemType.link,
            url: AppConstants.whatAppCustomerSupportLink,
            iconColor: Colors.grey,
            order: 1,
          ),
          SettingsConfig(
            id: 'feedback',
            title: loc.feedbackItemTitle,
            subtitle: loc.feedbackItemSubtitle,
            icon: Icons.feedback,
            type: SettingsItemType.navigation,
            onTap: () => context.push('/feedback'),
            iconColor: Colors.grey,
            order: 2,
          ),
          SettingsConfig(
            id: 'feature_survey', // NEW
            title: 'Feature Feedback',
            subtitle: 'Tell us what you like/dislike',
            icon: Icons.thumb_up_alt_outlined,
            type: SettingsItemType.navigation,
            onTap: () => context.push('/featureSurvey'),
            iconColor: Colors.grey,
            order: 3,
          ),
          SettingsConfig(
            id: 'rate',
            title: loc.rateItemTitle,
            subtitle: loc.rateItemSubtitle,
            icon: Icons.star,
            type: SettingsItemType.link,
            url: 'https://yourapp.com/privacy',
            iconColor: Colors.grey,
            order: 4,
          ),
          SettingsConfig(
            id: 'appInfoScreen',
            title: loc.appInfoItemTitle(AppConstants.appName),

            subtitle: loc.appInfoItemSubtitle,
            icon: Icons.memory,
            type: SettingsItemType.navigation,
            routeName: '/appInfoScreen',
            iconColor: Colors.grey,
            order: 5,
          ),
        ],
      ),
      SettingsSection(
        id: 'legal',
        title: loc.legalSectionTitle,
        showDivider: false,
        items: [
          SettingsConfig(
            id: 'terms',
            title: loc.termsItemTitle,
            subtitle: loc.termsItemSubtitle,
            icon: Icons.description,
            type: SettingsItemType.info,
            routeName: '/terms',
            iconColor: Colors.grey,
            order: 1,
          ),
          SettingsConfig(
            id: 'licenses',
            title: loc.licensesItemTitle,
            subtitle: loc.licensesItemSubtitle,
            icon: Icons.code,
            type: SettingsItemType.navigation,
            routeName: '/licenses',
            iconColor: Colors.grey,
            order: 3,
          ),
        ],
      ),
      if (currentUserId.isNotEmpty)
        SettingsSection(
          id: 'danger',
          title: loc.accountActionsSectionTitle,
          items: [
            SettingsConfig(
              id: 'update password ',
              title: loc.updatePasswordItemTitle,
              subtitle: loc.updatePasswordItemSubtitle,
              icon: Icons.lock,
              type: SettingsItemType.navigation,
              routeName: RouteNames.updatePasswordScreen,
              iconColor: Colors.grey,
              order: 1,
            ),
            SettingsConfig(
              id: 'deactivate',
              title: loc.deactivateItemTitle,
              subtitle: loc.deactivateItemSubtitle,
              icon: Icons.person_off_outlined,
              type: SettingsItemType.navigation,
              routeName: routes.RouteNames.deactivateAccount,
              iconColor: Colors.grey,
              order: 1,
            ),
            SettingsConfig(
              id: 'delete',
              title: loc.deleteItemTitle,
              subtitle: loc.deleteItemSubtitle,
              icon: Icons.delete,
              type: SettingsItemType.destructive,
              onTap: () => context.push(routes.RouteNames.deleteAccount),
              iconColor: Colors.red,
              order: 2,
            ),
            SettingsConfig(
              id: 'logout',

              title: loc.logoutItemTitle,
              subtitle: loc.logoutItemSubtitle,
              icon: Icons.logout,
              type: SettingsItemType.destructive,
              onTap: () {
                BottomSheetUtils.showDocumentationBottomSheet(
                  maxHeight: 320.h,
                  context: context,
                  widget: ConfirmationDialog(
                    noIcon: true,
                    type: ConfirmationType.info,
                    title: loc.logoutConfirmTitle,
                    confirmText: loc.logoutConfirmButton,
                    message: loc.logoutConfirmMessage,
                    onConfirm: () async {
                      try {
                        final ref = ProviderScope.containerOf(
                          context,
                          listen: false,
                        );

                        // signOut() clears the Supabase session + encrypted chat cache.
                        await ref.read(authOperationsProvider).signOut();

                        // Clear user-specific SharedPrefs (keeps theme/language).
                        await ref
                            .read(preferencesServiceProvider)
                            .clearUserData();

                        // Bypass the 100ms debounce so the router sees null user
                        // immediately when context.go fires below.
                        ref.read(routingNotifierProvider).clearUser();

                        if (context.mounted) {
                          context.showSuccessSnackbar(loc.logoutSuccessMessage);
                          context.go(RouteNames.intro);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          context.showErrorSnackbar(
                            loc.logoutFailedMessage(e.toString()),
                          );
                        }
                      }
                    },
                  ),
                );
              },
              iconColor: theme.colorScheme.primary,
              order: 1,
            ),
          ],
        ),
    ];
  }
}
