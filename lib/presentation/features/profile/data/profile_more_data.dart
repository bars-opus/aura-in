// lib/features/settings/data/settings_data.dart
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nano_embryo/core/link/entity_share_links.dart';
import 'package:nano_embryo/core/moderation/data/moderation_models.dart';
import 'package:nano_embryo/presentation/features/settings/models/settings_config.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class ProfileMoreData {
  static List<SettingsSection> getSettingsSections(
    BuildContext context, {
    ModerationTarget? moderationTarget,
    String? shareUrl,
  }) {
    // The link Share / Copy / Send act on. Callers pass a real entity URL
    // (e.g. a shop's /book/<slug>); otherwise we fall back to the app home so
    // the link always resolves rather than 404-ing.
    final effectiveShareUrl =
        (shareUrl != null && shareUrl.trim().isNotEmpty)
            ? shareUrl.trim()
            : EntityShareLinks.homeUrl;
    final shareMessage = EntityShareLinks.shareText(
      url: effectiveShareUrl,
      displayName: moderationTarget?.displayName,
    );
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

      // Share / Copy / Send all act on a shareable link to the entity being
      // viewed. Only shown when we have a target to build that link from.
      if (moderationTarget != null)
        SettingsSection(
          id: 'profile_actions',
          title: '',
          items: [
            SettingsConfig(
              id: 'send',
              title: loc.actionsSend,
              subtitle: '',
              icon: Icons.send_outlined,
              type: SettingsItemType.action,
              // Forward the entity link into an in-app conversation the user
              // picks (SendToChatScreen).
              onTap: () {
                final currentUserId =
                    Supabase.instance.client.auth.currentUser?.id ?? '';
                if (currentUserId.isEmpty) {
                  context.showErrorSnackbar('Please sign in to send a message');
                  return;
                }
                Navigator.of(context).maybePop();
                context.push(
                  RouteNames.sendToChat,
                  extra: <String, String>{
                    'currentUserId': currentUserId,
                    'message': shareMessage,
                  },
                );
              },
              iconColor: theme.colorScheme.onSurface.withValues(alpha: .6),
              order: 1,
            ),

            SettingsConfig(
              id: 'share',
              title: loc.actionsShare,
              subtitle: '',
              icon: Icons.share,
              type: SettingsItemType.action,
              onTap: () {
                Navigator.of(context).maybePop();
                Share.share(shareMessage);
              },
              iconColor: theme.colorScheme.onSurface.withValues(alpha: .6),
              order: 2,
            ),
            SettingsConfig(
              id: 'copy',
              title: loc.actionsCopy,
              subtitle: '',
              icon: Icons.copy,
              type: SettingsItemType.action,
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: effectiveShareUrl));
                if (context.mounted) {
                  Navigator.of(context).maybePop();
                  context.showInfoSnackbar('Link copied');
                }
              },
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
            routeName: RouteNames.feedback,
            iconColor: theme.colorScheme.primary,
            order: 2,
          ),
        ],
      ),
    ];
  }
}
