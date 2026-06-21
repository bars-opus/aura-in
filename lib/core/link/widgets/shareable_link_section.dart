// lib/core/link/widgets/shareable_link_section.dart
//
// Reusable widget for shop settings (and future freelancer settings).
// Shows the public booking link, copy + share buttons via the system
// share sheet, and an "Edit slug" affordance.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/core/widgets/info_row_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nano_embryo/core/link/config/aurain_link_config.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/usecases/publish_shop_usecase.dart'
    show slugifyShopName;

class ShareableLinkSection extends ConsumerWidget {
  /// The currently-cached slug (read from `shops.booking_slug`). null if
  /// the shop hasn't been saved yet or slug generation failed earlier.
  final String? currentSlug;

  /// Display name used in the share text (e.g. "Book your appointment at `name`...").
  final String entityName;

  /// Called when the owner edits the slug. Caller is responsible for
  /// validating uniqueness (LinkService.createShopLink handles that) and
  /// refreshing the upstream provider so currentSlug updates.
  final Future<void> Function(String newSlug) onEditSlug;

  const ShareableLinkSection({
    super.key,
    required this.currentSlug,
    required this.entityName,
    required this.onEditSlug,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final config = AuraInLinkConfig.getConfig();

    if (currentSlug == null) {
      // Empty state covers two cases: (1) shop just created, slug generation
      // failed best-effort and never retried; (2) shop existed before Plan A
      // shipped, so the publish-time hook never ran. Either way, let the
      // owner generate the link on demand from here.
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoRowWidget(
                subtitle:
                    'No public link yet. Generate one to start sharing on WhatsApp or Instagram.',
                title: 'Shareable booking link',
                icon: Icons.link,
                avatarRadius: 25.r,
                onTap: () {},
                disableTrailing: true,
                showAvatar: false,
                showTrailingArrow: false,
                showDivider: false,
              ),
              // const ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   leading: Icon(Icons.link),
              //   title: Text('Shareable booking link'),
              //   subtitle: Text(
              //     'No public link yet. Generate one to start sharing on WhatsApp or Instagram.',
              //   ),
              // ),
              const Gap(Spacing.md),
              AppButton(
                height: 40.h,
                label: 'Generate link',
                onPressed: () {
                  _showEditSlugDialog(context);
                },
                padding: Spacing.horizontalMd,
                variant: ButtonVariant.outline,
                size: ButtonSize.small,
                width: double.infinity,
              ),
              // Align(
              //   alignment: Alignment.centerRight,
              //   child: FilledButton.icon(
              //     icon: const Icon(Icons.add_link, size: 18),
              //     label: const Text('Generate link'),
              //     onPressed: () => _showEditSlugDialog(context),
              //   ),
              // ),
            ],
          ),
        ),
      );
    }

    final url = 'https://${config.baseDomain}/book/$currentSlug';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shareable booking link',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Share this on WhatsApp or Instagram to let clients book without the app.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground.withOpacity(.7),
                fontSize: 12.sp,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                url,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.blue,
                  fontSize: 14.sp,
                  // fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy'),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: url));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link copied')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Share'),
                    onPressed:
                        () => Share.share(
                          'Book your appointment at $entityName: $url',
                          subject: 'Book at $entityName',
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _showEditSlugDialog(context),
              child: const Text('Edit slug'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditSlugDialog(BuildContext context) async {
    final config = AuraInLinkConfig.getConfig();
    // Pre-fill with the current slug if we have one, otherwise a slug derived
    // from the shop/freelancer name so the owner only has to tap Save.
    final defaultSlug = currentSlug ?? slugifyShopName(entityName);
    final ctrl = TextEditingController(text: defaultSlug);
    final result = await showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Edit booking link slug'),
            content: TextField(
              controller: ctrl,
              decoration: InputDecoration(
                prefixText: '${config.baseDomain}/book/',
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                child: const Text('Save'),
              ),
            ],
          ),
    );
    if (result == null || result.isEmpty || result == currentSlug) return;
    try {
      await onEditSlug(result);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Slug updated')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not update slug: $e')));
      }
    }
  }
}
