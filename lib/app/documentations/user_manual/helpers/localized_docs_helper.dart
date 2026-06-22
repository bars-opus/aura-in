import 'package:flutter/material.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';
import 'package:nano_embryo/app/documentations/user_manual/models/manual_content.dart';
import 'package:nano_embryo/app/documentations/user_manual/models/manual_section.dart';

/// Helper class to manage localized documentation content.
///
/// This reduces code duplication by providing methods to fetch localized strings
/// from AppLocalizations and build ManualContent/ManualSection objects.
///
/// Usage:
/// ```dart
/// final content = LocalizedDocsHelper.createTextContent(
///   context: context,
///   id: 'welcome_intro',
///   titleKey: 'docsGettingStarted_welcomeIntroTitle',
///   contentKey: 'docsGettingStarted_welcomeIntroContent',
///   numberPrefix: '1',
/// );
/// ```
class LocalizedDocsHelper {
  /// Get a localized string from AppLocalizations.
  ///
  /// Returns the localized string or the key itself as fallback if not found.
  static String getLocalizedString(
    BuildContext context,
    String Function(AppLocalizations) keyAccessor,
  ) {
    try {
      final loc = AppLocalizations.of(context);
      if (loc == null) return '';
      return keyAccessor(loc);
    } catch (e) {
      return '';
    }
  }

  /// Create a text-type ManualContent with localized strings.
  static ManualContent createTextContent({
    required BuildContext context,
    required String id,
    required String Function(AppLocalizations) titleKey,
    required String Function(AppLocalizations) contentKey,
    String? numberPrefix,
  }) {
    final loc = AppLocalizations.of(context)!;
    return ManualContent(
      id: id,
      title: titleKey(loc),
      content: contentKey(loc),
      numberPrefix: numberPrefix,
      type: ManualContentType.text,
    );
  }

  /// Create a bullet-list ManualContent with localized strings.
  static ManualContent createBulletContent({
    required BuildContext context,
    required String id,
    required String Function(AppLocalizations) titleKey,
    required String Function(AppLocalizations) contentKey,
    required List<String> Function(AppLocalizations) bulletPointsKey,
    String? numberPrefix,
  }) {
    final loc = AppLocalizations.of(context)!;
    return ManualContent(
      id: id,
      title: titleKey(loc),
      content: contentKey(loc),
      numberPrefix: numberPrefix,
      type: ManualContentType.bulletList,
      bulletPoints: bulletPointsKey(loc),
    );
  }

  /// Create an important-box ManualContent with localized strings.
  static ManualContent createImportantContent({
    required BuildContext context,
    required String id,
    required String Function(AppLocalizations) contentKey,
  }) {
    final loc = AppLocalizations.of(context)!;
    return ManualContent(
      id: id,
      title: '',
      content: contentKey(loc),
      type: ManualContentType.important,
    );
  }

  /// Create a tip-box ManualContent with localized strings.
  static ManualContent createTipContent({
    required BuildContext context,
    required String id,
    required String Function(AppLocalizations) contentKey,
  }) {
    final loc = AppLocalizations.of(context)!;
    return ManualContent(
      id: id,
      title: '',
      content: contentKey(loc),
      type: ManualContentType.tip,
    );
  }

  /// Create a ManualSection with localized title/subtitle.
  static ManualSection createSection({
    required BuildContext context,
    required String id,
    required String Function(AppLocalizations) titleKey,
    required String Function(AppLocalizations) subtitleKey,
    required IconData icon,
    required List<ManualContent> contents,
    required String category,
    required int order,
  }) {
    final loc = AppLocalizations.of(context)!;
    return ManualSection(
      id: id,
      title: titleKey(loc),
      subtitle: subtitleKey(loc),
      icon: icon,
      contents: contents,
      category: category,
      order: order,
    );
  }

  /// Split a multiline bullet-point string into a list.
  ///
  /// Supports both:
  /// - Newline-separated: "Point 1\nPoint 2\nPoint 3"
  /// - Already a list: ["Point 1", "Point 2"]
  ///
  /// Also handles bullet prefixes like "• Point" or "- Point"
  static List<String> parseBulletPoints(String? bulletText) {
    if (bulletText == null || bulletText.isEmpty) return [];

    return bulletText
        .split('\n')
        .map((line) => line
            .replaceAll(RegExp(r'^[•\-\*]\s*'), '') // Remove bullet prefixes
            .trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  /// Create bullet points from a simple list that's already separated.
  /// This is useful when the localization string contains newline-separated bullets.
  static List<String> createBulletPointsList(String bulletString) {
    return parseBulletPoints(bulletString);
  }
}
