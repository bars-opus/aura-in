// lib/features/dashboard/presentation/widgets/reminder_settings_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';


class ReminderSettingsCard extends ConsumerStatefulWidget {
  final String shopId;

  const ReminderSettingsCard({super.key, required this.shopId});

  @override
  ConsumerState<ReminderSettingsCard> createState() => _ReminderSettingsCardState();
}

class _ReminderSettingsCardState extends ConsumerState<ReminderSettingsCard> {
  late bool _enabled;
  late int _reminderHours;
  late bool _smsEnabled;
  late bool _emailEnabled;
  late bool _marketingEnabled;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final settings = await ref.read(dashboardRepositoryProvider).getReminderSettings(widget.shopId);
      
      setState(() {
        _enabled = settings['enabled'] ?? true;
        _reminderHours = settings['reminder_hours'] ?? 24;
        _smsEnabled = settings['sms_enabled'] ?? true;
        _emailEnabled = settings['email_enabled'] ?? true;
        _marketingEnabled = settings['marketing_enabled'] ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load settings: $e')),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(dashboardRepositoryProvider).updateReminderSettings(
        shopId: widget.shopId,
        enabled: _enabled,
        reminderHours: _reminderHours,
        smsEnabled: _smsEnabled,
        emailEnabled: _emailEnabled,
        marketingEnabled: _marketingEnabled,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Center(
        child: CircularLoadingIndicator(
         
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(Spacing.md.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: BorderWidthTokens.hairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Automated Reminders',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(Spacing.sm.h),

          // Enable toggle
          SwitchListTile(
            title: Text('Send Reminders'),
            subtitle: Text(
              'Automatically send reminders to clients before appointments',
              style: theme.textTheme.labelSmall,
            ),
            value: _enabled,
            onChanged: (value) {
              setState(() => _enabled = value);
              _saveSettings();
            },
            contentPadding: EdgeInsets.zero,
          ),
          Gap(Spacing.sm.h),

          if (_enabled) ...[
            // Reminder timing
            ListTile(
              title: Text('Send Reminder'),
              subtitle: Text('$_reminderHours hours before appointment'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      if (_reminderHours > 1) {
                        setState(() => _reminderHours--);
                        _saveSettings();
                      }
                    },
                    icon: Icon(Icons.remove, size: IconSizes.sm),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Gap(Spacing.sm.w),
                  IconButton(
                    onPressed: () {
                      setState(() => _reminderHours++);
                      _saveSettings();
                    },
                    icon: Icon(Icons.add, size: IconSizes.sm),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              contentPadding: EdgeInsets.zero,
            ),

            // SMS toggle
            SwitchListTile(
              title: Text('SMS Reminders'),
              subtitle: Text('Send text message reminders'),
              value: _smsEnabled,
              onChanged: (value) {
                setState(() => _smsEnabled = value);
                _saveSettings();
              },
              contentPadding: EdgeInsets.zero,
            ),

            // Email toggle
            SwitchListTile(
              title: Text('Email Reminders'),
              subtitle: Text('Send email reminders'),
              value: _emailEnabled,
              onChanged: (value) {
                setState(() => _emailEnabled = value);
                _saveSettings();
              },
              contentPadding: EdgeInsets.zero,
            ),

            // Marketing toggle
            SwitchListTile(
              title: Text('Marketing Messages'),
              subtitle: Text('Send occasional promotions and offers'),
              value: _marketingEnabled,
              onChanged: (value) {
                setState(() => _marketingEnabled = value);
                _saveSettings();
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }
}
