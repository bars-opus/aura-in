// lib/features/shop/creation/presentation/widgets/contact_tile.dart

import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/phone_options_bottom_sheet.dart';

class ContactTile extends StatelessWidget {
  final ContactDraft contact;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isDraggable;

  const ContactTile({
    super.key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
    this.isDraggable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CardInkWell(
      margin: EdgeInsets.only(bottom: Spacing.xs),

      onTap: () {
        _handleContactTap(context, contact);
      },
      child: InfoRowWidget(
        subtitle: contact.isPrimary ? 'Primary' : '',
        //  contact.type.displayName,
        title: contact.formattedValue,
        icon: contact.type.icon,

        iconColor: Colors.grey,

        avatarRadius: 25.h,
        onTap: () {
          _handleContactTap(context, contact);
        },
        showAvatar: false,
        showTrailingArrow: false,
        showDivider: false,
        titleMaxLines: 1,
        trailing:
            onEdit == null
                ? null
                : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIconButton(
                          icon: Icons.edit,
                          onPressed: onEdit,
                          iconColor: theme.colorScheme.primary,
                        ),

                        AppIconButton(
                          icon: Icons.delete,
                          onPressed: onDelete,
                          iconColor: theme.colorScheme.error,
                        ),

                        if (isDraggable)
                          AppIconButton(
                            icon: Icons.drag_handle,
                            onPressed: onDelete,
                            iconColor: theme.colorScheme.onSurface.withOpacity(
                              0.3,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
      ),
    );
  }

  void _handleContactTap(BuildContext context, ContactDraft contact) {
    switch (contact.type) {
      case ContactType.phone:
        // Show phone options bottom sheet
        Navigator.pop(context); // Close contact sheet first
        BottomSheetUtils.showDocumentationBottomSheet(
          context: context,
          widget: PhoneOptionsBottomSheet(contact: contact),
        );
        break;

      case ContactType.email:
        Navigator.pop(context);
        UrlLauncherUtils.launchEmail(
          context: context,
          email: contact.value,
          subject: 'Regarding my appointment',
          body: 'Hello, ',
        );
        break;

      case ContactType.website:
        Navigator.pop(context);
        UrlLauncherUtils.launchUrlWithFeedback(
          context: context,
          url: contact.launchUrl,
          errorMessage: 'Cannot open website',
        );
        break;
    }
  }
}
