import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';

class ToolsDocs implements DocumentationModule {
  @override
  int get order => 5;

  @override
  String getTitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsToolsTitle;
  }

  @override
  String get id => 'business_tools';

  @override
  String getSubtitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsToolsSubtitle;
  }

  @override
  IconData get icon => Icons.build;

  @override
  List<ManualSection> getSections(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
    // Section 1: Overview
    ManualSection(
      id: 'tools_overview',
      title: loc.docsToolsOverviewTitle,
      subtitle: loc.docsToolsOverviewSubtitle,
      icon: Icons.info_outline,
      category: 'Tools',
      order: 1,
      contents: [
        ManualContent(
          id: 'tools_welcome',
          title: loc.docsToolsWelcomeTitle,
          content: loc.docsToolsWelcomeContent,
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'tools_list',
          title: loc.docsToolsListTitle,
          content: loc.docsToolsListContent,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsToolsReminders,
            loc.docsToolsPromotions,
            loc.docsToolsExport,
            loc.docsToolsPayment,
            loc.docsToolsHours,
            loc.docsToolsServices,
            loc.docsToolsLoyalty,
            loc.docsToolsBroadcasts,
          ],
        ),
      ],
    ),

    // Section 2: Automated Reminders
    ManualSection(
      id: 'automated_reminders',
      title: loc.docsToolsAutomatedRemindersTitle,
      subtitle: loc.docsToolsAutomatedRemindersSubtitle,
      icon: Icons.notifications_active,
      category: 'Individual Tools',
      order: 2,
      contents: [
        ManualContent(
          id: 'reminder_purpose',
          title: 'What It Does',
          content: loc.docsToolsReminderPurpose,
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'reminder_benefits',
          title: 'Benefits',
          content: loc.docsToolsReminderBenefits,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsToolsReminderBenefitNoShow,
            loc.docsToolsReminderBenefitExperience,
            loc.docsToolsReminderBenefitTime,
            loc.docsToolsReminderBenefitReliability,
          ],
        ),
        ManualContent(
          id: 'reminder_setup',
          title: 'How to Set It Up',
          content: loc.docsToolsReminderSetup,
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'reminder_impact',
          title: '',
          content: loc.docsToolsReminderImpact,
          type: ManualContentType.important,
        ),
      ],
    ),

    // Section 3: Promotions Manager
    ManualSection(
      id: 'promotions_manager',
      title: loc.docsToolsPromotionsManagerTitle,
      subtitle: loc.docsToolsPromotionsManagerSubtitle,
      icon: Icons.local_offer,
      category: 'Individual Tools',
      order: 3,
      contents: [
        ManualContent(
          id: 'promo_purpose',
          title: 'What It Does',
          content: loc.docsToolsPromoPurpose,
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'promo_examples',
          title: loc.docsToolsPromoIdeasTitle,
          content: loc.docsToolsPromoIdeasContent,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsToolsPromoIdea1,
            loc.docsToolsPromoIdea2,
            loc.docsToolsPromoIdea3,
            loc.docsToolsPromoIdea4,
            loc.docsToolsPromoIdea5,
          ],
        ),
        ManualContent(
          id: 'promo_strategy',
          title: 'Promotion Strategy',
          content: loc.docsToolsPromoStrategy,
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 4: Export Reports
    ManualSection(
      id: 'export_reports',
      title: loc.docsToolsExportReportsTitle,
      subtitle: loc.docsToolsExportReportsSubtitle,
      icon: Icons.download,
      category: 'Individual Tools',
      order: 4,
      contents: [
        ManualContent(
          id: 'export_purpose',
          title: 'What It Does',
          content: loc.docsToolsExportPurpose,
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'export_types',
          title: loc.docsToolsExportTypesTitle,
          content: loc.docsToolsExportTypesContent,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsToolsExportType1,
            loc.docsToolsExportType2,
            loc.docsToolsExportType3,
            loc.docsToolsExportType4,
            loc.docsToolsExportType5,
          ],
        ),
        ManualContent(
          id: 'export_uses',
          title: loc.docsToolsExportWhyTitle,
          content: loc.docsToolsExportWhy,
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 5: Payment Settings
    ManualSection(
      id: 'payment_settings',
      title: loc.docsToolsPaymentSettingsTitle,
      subtitle: loc.docsToolsPaymentSettingsSubtitle,
      icon: Icons.payment,
      category: 'Individual Tools',
      order: 5,
      contents: [
        ManualContent(
          id: 'payment_purpose',
          title: 'What It Does',
          content: loc.docsToolsPaymentPurpose,
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'payment_setup',
          title: loc.docsToolsPaymentNeededTitle,
          content: loc.docsToolsPaymentNeeded,
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'payment_importance',
          title: '',
          content: loc.docsToolsPaymentImportance,
          type: ManualContentType.important,
        ),
      ],
    ),

    // Section 6: Business Hours
    ManualSection(
      id: 'business_hours',
      title: loc.docsToolsBusinessHoursTitle,
      subtitle: loc.docsToolsBusinessHoursSubtitle,
      icon: Icons.access_time,
      category: 'Individual Tools',
      order: 6,
      contents: [
        ManualContent(
          id: 'hours_purpose',
          title: 'What It Does',
          content: loc.docsToolsHoursPurpose,
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'hours_features',
          title: loc.docsToolsHoursFeaturesTitle,
          content: loc.docsToolsHoursFeatures,
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'hours_importance',
          title: '',
          content: loc.docsToolsHoursImportance,
          type: ManualContentType.important,
        ),
      ],
    ),

    // Section 7: Service Management
    ManualSection(
      id: 'service_management',
      title: loc.docsToolsServiceManagementTitle,
      subtitle: loc.docsToolsServiceManagementSubtitle,
      icon: Icons.cut,
      category: 'Individual Tools',
      order: 7,
      contents: [
        ManualContent(
          id: 'services_purpose',
          title: 'What It Does',
          content: loc.docsToolsServicesPurpose,
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'services_benefits',
          title: loc.docsToolsServicesWhyTitle,
          content: loc.docsToolsServicesWhy,
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'services_tips',
          title: loc.docsToolsServicesTipsTitle,
          content: loc.docsToolsServicesTips,
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 8: Loyalty Program
    ManualSection(
      id: 'loyalty_program',
      title: loc.docsToolsLoyaltyProgramTitle,
      subtitle: loc.docsToolsLoyaltyProgramSubtitle,
      icon: Icons.card_giftcard,
      category: 'Individual Tools',
      order: 8,
      contents: [
        ManualContent(
          id: 'loyalty_purpose',
          title: 'What It Does',
          content: loc.docsToolsLoyaltyPurpose,
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'loyalty_benefits',
          title: loc.docsToolsLoyaltyWhyTitle,
          content: loc.docsToolsLoyaltyWhy,
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'loyalty_examples',
          title: loc.docsToolsLoyaltyIdeasTitle,
          content: loc.docsToolsLoyaltyIdeas,
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 9: Broadcasts
    ManualSection(
      id: 'broadcasts',
      title: loc.docsToolsBroadcastsTitle,
      subtitle: loc.docsToolsBroadcastsSubtitle,
      icon: Icons.campaign_outlined,
      category: 'Individual Tools',
      order: 9,
      contents: [
        ManualContent(
          id: 'broadcast_purpose',
          title: 'What It Does',
          content: loc.docsToolsBroadcastPurpose,
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'broadcast_uses',
          title: loc.docsToolsBroadcastWhenTitle,
          content: loc.docsToolsBroadcastWhenContent,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsToolsBroadcastUse1,
            loc.docsToolsBroadcastUse2,
            loc.docsToolsBroadcastUse3,
            loc.docsToolsBroadcastUse4,
            loc.docsToolsBroadcastUse5,
          ],
        ),
        ManualContent(
          id: 'broadcast_tips',
          title: loc.docsToolsBroadcastTipsTitle,
          content: loc.docsToolsBroadcastTips,
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 10: FAQ
    ManualSection(
      id: 'tools_faq',
      title: loc.docsToolsFAQTitle,
      subtitle: loc.docsToolsFAQSubtitle,
      icon: Icons.help_outline,
      category: 'Help',
      order: 10,
      contents: [
        ManualContent(
          id: 'faq_which_tool',
          title: loc.docsToolsFAQQ1,
          content: loc.docsToolsFAQA1,
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_tools_cost',
          title: loc.docsToolsFAQQ2,
          content: loc.docsToolsFAQA2,
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_reminders_delivery',
          title: loc.docsToolsFAQQ3,
          content: loc.docsToolsFAQA3,
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_promo_conflicts',
          title: loc.docsToolsFAQQ4,
          content: loc.docsToolsFAQA4,
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_export_frequency',
          title: loc.docsToolsFAQQ5,
          content: loc.docsToolsFAQA5,
          numberPrefix: '5',
          type: ManualContentType.text,
        ),
      ],
    ),
    ];
  }

  @override
  List<FAQModel> getFAQs(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      FAQModel(
        id: 'faq_tools_1',
        question: loc.docsToolsFAQQ6,
        answer: loc.docsToolsFAQA6,
        category: 'Getting Started',
        order: 1,
      ),
      FAQModel(
        id: 'faq_tools_2',
        question: loc.docsToolsFAQQ7,
        answer: loc.docsToolsFAQA7,
        category: 'Usage',
        order: 2,
      ),
      FAQModel(
        id: 'faq_tools_3',
        question: loc.docsToolsFAQQ8,
        answer: loc.docsToolsFAQA8,
        category: 'Strategy',
        order: 3,
      ),
      FAQModel(
        id: 'faq_tools_4',
        question: loc.docsToolsFAQQ9,
        answer: loc.docsToolsFAQA9,
        category: 'Payments',
        order: 4,
      ),
      FAQModel(
        id: 'faq_tools_5',
        question: loc.docsToolsFAQQ10,
        answer: loc.docsToolsFAQA10,
        category: 'Broadcasts',
        order: 5,
      ),
      FAQModel(
        id: 'faq_tools_6',
        question: loc.docsToolsFAQQ11,
        answer: loc.docsToolsFAQA11,
        category: 'Business Hours',
        order: 6,
      ),
    ];
  }
}
