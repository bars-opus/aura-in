// NanoEmbryo-specific feedback configuration.
//
// When copying this engine to a new app, replace the contents of this file
// with your own feedback types, copy, and callbacks. Everything else in
// core/feedback/ is generic and can be copied unchanged.
//
// See FEEDBACK_ENGINE.md for the full integration guide.

import 'package:flutter/material.dart';
import 'package:nano_embryo/core/feedback/config/feedback_config.dart';
import 'package:nano_embryo/core/feedback/review/feedback_review_config.dart';

/// Returns the NanoEmbryo [FeedbackConfig].
///
/// Pass this to [feedbackConfigProvider] in the root [ProviderScope].
FeedbackConfig buildNanoEmbryoFeedbackConfig() {
  return const FeedbackConfig(
    appName: 'Aura In',
    types: [
      FeedbackTypeOption(
        key: 'bug',
        label: 'Bug Report',
        icon: Icons.bug_report,
      ),
      FeedbackTypeOption(
        key: 'suggestion',
        label: 'Suggestion',
        icon: Icons.lightbulb_outline,
      ),
      FeedbackTypeOption(
        key: 'shop_issue',
        label: 'Shop Issue',
        icon: Icons.storefront,
      ),
      FeedbackTypeOption(
        key: 'payment_problem',
        label: 'Payment Problem',
        icon: Icons.payment,
      ),
      FeedbackTypeOption(
        key: 'question',
        label: 'Question',
        icon: Icons.help_outline,
      ),
      FeedbackTypeOption(
        key: 'other',
        label: 'Other',
        icon: Icons.edit_note,
      ),
    ],
    enableScreenshots: true,
    review: FeedbackReviewConfig(
      // Conservative preset (defaults). Fill in `appStoreId` once the iOS
      // listing is live (numeric ID from App Store Connect, e.g. '6471234567').
      androidPackageName: 'com.barsOpus.florence',
    ),
  );
}
