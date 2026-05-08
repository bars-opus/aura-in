import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';

class PhoneOptionsBottomSheet extends StatelessWidget {
  final ContactDraft contact;

  const PhoneOptionsBottomSheet({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BottomSheetHeader(title: 'Contact via ${contact.formattedValue}'),
        Gap(Spacing.md),
        // Call Option
        CardInkWell(
          // elevation: 0,
          onTap: () {},
          child: Column(
            children: [
              _buildOption(
                context,
                icon: Icons.phone,
                label: 'Call',
                subtitle: 'Make a regular phone call',
                onTap: () {
                  Navigator.pop(context);
                  UrlLauncherUtils.launchPhone(
                    context: context,
                    phoneNumber: contact.value,
                  );
                },
                showDivider: true,
              ),

              // WhatsApp Option
              _buildOption(
                context,
                icon: Icons.chat,
                label: 'WhatsApp',
                subtitle: 'Send WhatsApp message',
                onTap: () {
                  Navigator.pop(context);
                  _launchWhatsApp(context);
                },
                showDivider: true,
              ),

              // SMS Option
              _buildOption(
                context,
                icon: Icons.sms,
                label: 'SMS',
                subtitle: 'Send text message',
                onTap: () {
                  Navigator.pop(context);
                  _launchSms(context);
                },
                showDivider: false,
              ),
            ],
          ),
        ),

        Gap(Spacing.lg.h),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return InfoRowWidget(
      subtitle: subtitle,
      //  contact.type.displayName,
      title: label,
      icon: icon,
      avatarRadius: 25.h,
      onTap: onTap,
      showAvatar: true,
      showTrailingArrow: false,
      showDivider: showDivider,
      titleMaxLines: 1,
    );

    // InkWell(
    //   onTap: onTap,
    //   child: Padding(
    //     padding: EdgeInsets.symmetric(
    //       horizontal: Spacing.md.w,
    //       vertical: Spacing.sm.h,
    //     ),
    //     child: Row(
    //       children: [
    //         Container(
    //           width: 48.w,
    //           height: 48.h,
    //           decoration: BoxDecoration(
    //             color: colorScheme.primaryContainer,
    //             shape: BoxShape.circle,
    //           ),
    //           child: Icon(icon, color: colorScheme.primary, size: 24.h),
    //         ),
    //         SizedBox(width: Spacing.md.w),
    //         Expanded(
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text(
    //                 label,
    //                 style: theme.textTheme.titleSmall?.copyWith(
    //                   fontWeight: FontWeight.w600,
    //                 ),
    //               ),
    //               SizedBox(height: 2.h),
    //               Text(
    //                 subtitle,
    //                 style: theme.textTheme.bodySmall?.copyWith(
    //                   color: colorScheme.onSurface.withOpacity(0.6),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //         Icon(
    //           Icons.chevron_right,
    //           color: colorScheme.onSurface.withOpacity(0.3),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  void _launchWhatsApp(BuildContext context) async {
    final phoneNumber = contact.value.replaceAll('+', '').replaceAll(' ', '');
    final whatsappUrl = 'https://wa.me/$phoneNumber';

    await UrlLauncherUtils.launchUrlWithFeedback(
      context: context,
      url: whatsappUrl,
      errorMessage: 'WhatsApp is not installed on this device',
    );
  }

  void _launchSms(BuildContext context) async {
    String? body;
    // if (appointmentDate != null) {
    //   body = 'Regarding my appointment on $appointmentDate...';
    // }

    await UrlLauncherUtils.launchSms(
      context: context,
      phoneNumber: contact.value,
      body: body,
    );
  }
}
