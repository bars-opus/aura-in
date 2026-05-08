// lib/features/search/presentation/widgets/empty_state_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/core/widgets/feedback/empty_state.dart';

class EmptySearchStateSuggestionWidget extends StatelessWidget {
  final VoidCallback? onAction;
  final String? subTitle;
    final String? title;

  final List<String>? suggestions;

  const EmptySearchStateSuggestionWidget({
    super.key,
 this.onAction,
    this.title,
    this.subTitle,
    this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EmptyStateWidget(
              title: title,
              subtitle: subTitle,
              icon: Icons.search_off_outlined,
            ),
            if (suggestions != null && suggestions!.isNotEmpty) ...[
              SizedBox(height: 24.h),
              Text(
                'Try these:',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                alignment: WrapAlignment.center,
                children:
                    suggestions!.map((suggestion) {
                      return ActionChip(
                        label: Text(suggestion),
                        onPressed: () {
                          // Handle suggestion tap
                        },
                      );
                    }).toList(),
              ),
            ],
            if (onAction != null) ...[
              SizedBox(height: 24.h),
              ElevatedButton(onPressed: onAction, child: Text('Try')),
            ],
          ],
        ),
      ),
    );
  }
}
