// lib/features/search/presentation/widgets/search_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_icon_button.dart';


class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;
  final VoidCallback? onFiltersPressed;

  const SearchAppBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onQueryChanged,
    required this.onClear,
    this.onFiltersPressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Container(
        padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    SizedBox(width: Spacing.md.w),
                    Icon(
                      Icons.search,
                      size: 20.h,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: Spacing.sm.w),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.6),
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                        onChanged: onQueryChanged,
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                    if (controller.text.isNotEmpty)
                      AppIconButton(
                        icon: Icons.clear,
                        onPressed: onClear,
                       
                      ),
                    SizedBox(width: Spacing.xs.w),
                  ],
                ),
              ),
            ),
            if (onFiltersPressed != null) ...[
              SizedBox(width: Spacing.sm.w),
              AppIconButton(
                icon: Icons.tune,
                onPressed: onFiltersPressed,
               
              ),
            ],
          ],
        ),
      ),
    );
  }
}
