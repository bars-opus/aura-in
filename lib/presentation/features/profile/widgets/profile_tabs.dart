import 'package:flutter/material.dart';
import 'package:nano_embryo/core/widgets/app_tabs.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/presentation/screens/calendar_screen.dart';

List<AppTabItem> buildProfileTabs(String currentUserId, isCurrentUser) {
  return [
    AppTabItem(
      label: 'Appointments',
      icon: null,
      content:
          currentUserId.isEmpty
              ? SizedBox.shrink()
              : CalendarScreen(
                isShopOwner: false,
                currentUserId: currentUserId,
                isCurrentUser: isCurrentUser,
              ),
    ),
    AppTabItem(
      label: 'Save',
      icon: null,
      content: currentUserId.isEmpty ? SizedBox.shrink() : Container(),
    ),
    AppTabItem(
      label: 'Shops',
      icon: null,
      content: currentUserId.isEmpty ? SizedBox.shrink() : Container(),
    ),
  ];
}
