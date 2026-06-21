import 'dart:io';

import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class ScreenshotPickerRow extends StatelessWidget {
  final List<File> screenshots;
  final int maxScreenshots;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const ScreenshotPickerRow({
    super.key,
    required this.screenshots,
    required this.maxScreenshots,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canAdd = screenshots.length < maxScreenshots;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Screenshots',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            Gap(Spacing.sm.w),
            Text(
              '${screenshots.length}/$maxScreenshots',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        Gap(Spacing.sm.h),
        SizedBox(
          height: 88.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: screenshots.length + (canAdd ? 1 : 0),
            separatorBuilder: (_, _) => Gap(Spacing.sm.w),
            itemBuilder: (context, index) {
              if (index == screenshots.length && canAdd) {
                return _AddTile(onTap: onAdd);
              }
              return _ThumbTile(
                file: screenshots[index],
                onRemove: () => onRemove(index),
                index: index,
                total: screenshots.length,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: 'Add screenshot',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: 88.w,
          height: 88.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.4),
              style: BorderStyle.solid,
            ),
          ),
          child: Icon(
            Icons.add_a_photo_outlined,
            size: 28.w,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _ThumbTile extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;
  final int index;
  final int total;
  const _ThumbTile({
    required this.file,
    required this.onRemove,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Screenshot ${index + 1} of $total',
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.file(
              file,
              width: 88.w,
              height: 88.h,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: 2,
            top: 2,
            child: Semantics(
              button: true,
              label: 'Remove screenshot ${index + 1}',
              child: InkWell(
                onTap: onRemove,
                child: CircleAvatar(
                  radius: 11.r,
                  backgroundColor: Colors.black.withValues(alpha: 0.6),
                  child: Icon(Icons.close, size: 14.w, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
