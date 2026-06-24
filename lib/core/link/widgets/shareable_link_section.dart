// lib/core/link/widgets/shareable_link_section.dart
//
// Reusable widget for the shop owner's Tools tab. Renders a shareable
// public URL (booking or products marketplace), copy + share + edit
// affordances, and an empty-state generator when the slug hasn't been
// created yet.
//
// Two flavors, controlled by ShareableLinkKind:
//   * booking  — https://<domain>/book/<slug>  (link-booking)
//   * products — https://<domain>/m/<slug>     (link-products, shop_products)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/core/widgets/card_inkwell.dart';
import 'package:nano_embryo/core/widgets/info_row_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nano_embryo/core/link/config/aurain_link_config.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/usecases/publish_shop_usecase.dart'
    show slugifyShopName;

/// Distinguishes the two shareable-link surfaces.
enum ShareableLinkKind {
  booking,
  products;

  String get pathPrefix => switch (this) {
        ShareableLinkKind.booking  => 'book',
        ShareableLinkKind.products => 'm',
      };

  String get headline => switch (this) {
        ShareableLinkKind.booking  => 'Shareable booking link',
        ShareableLinkKind.products => 'Shareable products link',
      };

  String get emptySubtitle => switch (this) {
        ShareableLinkKind.booking =>
          'No public booking link yet. Generate one to start sharing on WhatsApp or Instagram.',
        ShareableLinkKind.products =>
          'No public products link yet. Generate one so clients can order without the app — pay on delivery.',
      };

  String get explanation => switch (this) {
        ShareableLinkKind.booking =>
          'Share this on WhatsApp or Instagram to let clients book without the app.',
        ShareableLinkKind.products =>
          'Share this on WhatsApp or Instagram to let clients order products. They pay on delivery.',
      };

  String get editTitle => switch (this) {
        ShareableLinkKind.booking  => 'Edit booking link slug',
        ShareableLinkKind.products => 'Edit products link slug',
      };

  String shareText(String entityName, String url) => switch (this) {
        ShareableLinkKind.booking =>
          'Book your appointment at $entityName: $url',
        ShareableLinkKind.products =>
          'Order from $entityName (pay on delivery): $url',
      };

  String shareSubject(String entityName) => switch (this) {
        ShareableLinkKind.booking  => 'Book at $entityName',
        ShareableLinkKind.products => 'Order from $entityName',
      };
}

class ShareableLinkSection extends ConsumerWidget {
  /// The currently-cached slug (read from `shops.booking_slug` or
  /// `shops.products_slug` depending on kind). null if the shop hasn't
  /// been saved yet or slug generation failed earlier.
  final String? currentSlug;

  /// Display name used in the share text and in the slug fallback when
  /// the user opens the editor on an empty state.
  final String entityName;

  /// Called when the owner edits/generates the slug. Caller is responsible
  /// for validating uniqueness (LinkService.createShopLink /
  /// createShopProductsLink handles that) and refreshing the upstream
  /// provider so `currentSlug` updates.
  final Future<void> Function(String newSlug) onEditSlug;

  /// Which surface this widget renders for. Defaults to booking for
  /// backward compat with existing callers.
  final ShareableLinkKind kind;

  const ShareableLinkSection({
    super.key,
    required this.currentSlug,
    required this.entityName,
    required this.onEditSlug,
    this.kind = ShareableLinkKind.booking,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final config = AuraInLinkConfig.getConfig();

    if (currentSlug == null) {
      return CardInkWell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoRowWidget(
              subtitle: kind.emptySubtitle,
              title: kind.headline,
              icon: Icons.link,
              avatarRadius: 25.r,
              onTap: () {},
              disableTrailing: true,
              showAvatar: false,
              showTrailingArrow: false,
              showDivider: false,
            ),
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
          ],
        ),
      );
    }

    final url = 'https://${config.baseDomain}/${kind.pathPrefix}/$currentSlug';

    return CardInkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kind.headline,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onBackground,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            kind.explanation,
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
                  onPressed: () => Share.share(
                    kind.shareText(entityName, url),
                    subject: kind.shareSubject(entityName),
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
    );
  }

  Future<void> _showEditSlugDialog(BuildContext context) async {
    final config = AuraInLinkConfig.getConfig();
    final defaultSlug = currentSlug ?? slugifyShopName(entityName);
    final ctrl = TextEditingController(text: defaultSlug);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(kind.editTitle),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            prefixText: '${config.baseDomain}/${kind.pathPrefix}/',
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Slug updated')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update slug: $e')),
        );
      }
    }
  }
}
