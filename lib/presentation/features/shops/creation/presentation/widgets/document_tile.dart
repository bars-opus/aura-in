// lib/features/shop/creation/presentation/widgets/document_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/date_formatter.dart';
import 'package:nano_embryo/core/widgets/buttons/app_icon_button.dart';
import 'package:nano_embryo/core/widgets/card_inkwell.dart';
import 'package:nano_embryo/core/widgets/info_row_widget.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/mini_container_indicator.dart';

class DocumentTile extends StatelessWidget {
  final DocumentDraft document;
  final VoidCallback onView;
  final VoidCallback onDelete;
  final bool isDraggable;

  const DocumentTile({
    super.key,
    required this.document,
    required this.onView,
    required this.onDelete,
    this.isDraggable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpired = document.isExpired;

    return CardInkWell(
      margin: EdgeInsets.only(bottom: Spacing.xs),
      child: InfoRowWidget(
        subtitle: MyDateFormat.toDate(document.expiryDate ?? DateTime.now()),

        //  '${document.fileName} ${_formatDate(document.expiryDate!)}',
        title: document.title ?? document.type.displayName,

        icon: document.type.icon,
        iconSize: 0.0,
        // iconColor: Colors.grey,
        avatarRadius: 25.h,
        onTap: () {},
        showAvatar: false,
        showTrailingArrow: false,
        showDivider: false,
        titleMaxLines: 1,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIconButton(
                  icon: Icons.visibility,
                  onPressed: onView,
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
                    iconColor: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    color: theme.colorScheme.surfaceVariant,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: Image.file(
                      document.file, // ✅ Use the File object directly
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Show icon if image fails to load
                        return Center(
                          child: Icon(
                            document.type.icon,
                            color: theme.colorScheme.primary,
                            size: 24.sp,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            if (isExpired)
              MiniContainerIndicator(color: Colors.red, text: 'Expired'),
          ],
        ),
      ),
    );
  }
}
