// NanoEmbryo-specific survey configuration.
//
// When copying this engine to a new app, replace the contents of this file
// with your own feature list and copy. Everything else in core/config/survey/
// is generic and can be copied unchanged.
//
// See SURVEY_ENGINE.md for the full integration guide.

import 'package:flutter/material.dart';
import 'package:nano_embryo/core/config/survey/config/survey_config.dart';

/// Returns the NanoEmbryo [SurveyConfig].
///
/// Pass this to [surveyConfigProvider] in the root [ProviderScope].
SurveyConfig buildNanoEmbryoSurveyConfig() {
  return SurveyConfig(
    appName: 'Aura In',
    features: const [
      SurveyFeature(
        key: 'booking',
        title: 'Booking System',
        description: 'Book appointments with your favorite barbers and salons',
        icon: Icons.calendar_today,
      ),
      SurveyFeature(
        key: 'discover_shops',
        title: 'Discover Shops',
        description: 'Find new salons and barbershops near you',
        icon: Icons.explore,
      ),
      SurveyFeature(
        key: 'google_map',
        title: 'Interactive Maps',
        description: 'View shop locations and get directions easily',
        icon: Icons.map,
      ),
      SurveyFeature(
        key: 'home_service',
        title: 'Home Service',
        description: 'Book freelancers for at-home grooming services',
        icon: Icons.home_work,
      ),
      SurveyFeature(
        key: 'shop_dashboard',
        title: 'Shop Dashboard',
        description: 'Track your business performance and analytics',
        icon: Icons.dashboard,
      ),
      SurveyFeature(
        key: 'shop_admin',
        title: 'Admin Tools',
        description: 'Manage your shop, staff, and appointments',
        icon: Icons.admin_panel_settings,
      ),
    ],
  );
}
