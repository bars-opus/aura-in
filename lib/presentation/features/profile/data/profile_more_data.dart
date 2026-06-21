// lib/features/settings/data/settings_data.dart
import 'package:nano_embryo/core/moderation/data/moderation_models.dart';
import 'package:nano_embryo/presentation/features/settings/models/settings_config.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class ProfileMoreData {
  static List<SettingsSection> getSettingsSections(
    BuildContext context, {
    ModerationTarget? moderationTarget,
  }) {
    // Access localization for language prefence
    final loc = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    return [
      if (moderationTarget != null)
        SettingsSection(
          id: 'app_actions',
          title: '',
          items: [
            SettingsConfig(
              id: 'block',
              title: loc.actionsBlock,
              subtitle: '',
              icon: Icons.block,
              type: SettingsItemType.destructive,
              onTap:
                  () => context.push(
                    RouteNames.blockAccount,
                    extra: moderationTarget,
                  ),
              iconColor: Colors.red,
              order: 1,
            ),
            SettingsConfig(
              id: 'report',
              title: loc.actionsReport,
              subtitle: '',
              icon: Icons.flag_outlined,
              type: SettingsItemType.destructive,
              onTap:
                  () => context.push(
                    RouteNames.reportTarget,
                    extra: moderationTarget,
                  ),
              iconColor: Colors.red,
              order: 3,
            ),
          ],
        ),

      SettingsSection(
        id: 'profile_actions',
        title: '',
        items: [
          SettingsConfig(
            id: 'send',
            title: loc.actionsSend,
            subtitle: '',
            icon: Icons.send_outlined,
            type: SettingsItemType.navigation,
            onTap: () {},
            iconColor: theme.colorScheme.onSurface.withValues(alpha: .6),
            order: 1,
          ),

          SettingsConfig(
            id: 'share',
            title: loc.actionsShare,
            subtitle: '',
            icon: Icons.share,
            type: SettingsItemType.link,
            url: 'https://yourapp.com/privacy',
            routeName: '/share',
            iconColor: theme.colorScheme.onSurface.withValues(alpha: .6),
            order: 2,
          ),
          SettingsConfig(
            id: 'copy',
            title: loc.actionsCopy,
            subtitle: '',
            icon: Icons.copy,
            type: SettingsItemType.link,
            url: 'https://yourapp.com/privacy',
            routeName: '/copy',
            iconColor: theme.colorScheme.onSurface.withValues(alpha: .6),
            order: 3,
          ),
        ],
      ),

      SettingsSection(
        id: 'app_actions',
        title: '',
        items: [
          SettingsConfig(
            id: 'feedback',
            title: loc.feedbackItemTitle,
            subtitle:
                'Share your thoughts with the ${AppConstants.appName} team',
            icon: Icons.feedback_outlined,
            type: SettingsItemType.navigation,
            onTap: () {},
            iconColor: theme.colorScheme.primary,
            order: 2,
          ),
        ],
      ),
    ];
  }
}
