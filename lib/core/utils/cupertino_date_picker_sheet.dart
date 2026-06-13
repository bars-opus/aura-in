import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_text_button.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';

/// Shows a Cupertino date/time picker inside a bottom-sheet.
/// Returns the chosen [DateTime] or null if dismissed.
Future<DateTime?> showCupertinoDatePickerSheet({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? minimumDate,
  DateTime? maximumDate,
  CupertinoDatePickerMode mode = CupertinoDatePickerMode.date,
  double sheetHeight = 320,
}) async {
  final completer = Completer<DateTime?>();
  DateTime selected = initialDate;

  await BottomSheetUtils.showDocumentationBottomSheet(
    context: context,
    maxHeight: sheetHeight.h,
    showButtons: false,
    widget: Builder(
      builder: (ctx) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.md.w,
                vertical: Spacing.sm.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppTextButton(
                    text: 'Cancel',
                    onPressed: () {
                      Navigator.pop(ctx);
                      completer.complete(null);
                    },
                  ),
                  AppTextButton(
                    text: 'Done',
                    onPressed: () {
                      Navigator.pop(ctx);
                      completer.complete(selected);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: CupertinoDatePicker(
                mode: mode,
                initialDateTime: initialDate,
                minimumDate: minimumDate,
                maximumDate: maximumDate,
                onDateTimeChanged: (dt) => selected = dt,
              ),
            ),
          ],
        );
      },
    ),
  );

  return completer.future;
}
