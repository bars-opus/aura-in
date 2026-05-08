// lib/features/dashboard/presentation/screens/reminder_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/tools/reminder_settings_card.dart';


class ReminderSettingsScreen extends ConsumerWidget {
  final String shopId;

  const ReminderSettingsScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Reminder Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Spacing.md.h),
        child: ReminderSettingsCard(
          shopId: shopId,
        ),
      ),
    );
  }
}
