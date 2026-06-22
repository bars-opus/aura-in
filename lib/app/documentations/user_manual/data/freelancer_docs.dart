import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';

class FreelancerDocs implements DocumentationModule {
  @override
  int get order => 2;

  @override
  String getTitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsFreelancerTitle;
  }

  @override
  String get id => 'become_freelancer';

  @override
  String getSubtitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsFreelancerSubtitle;
  }

  @override
  IconData get icon => Icons.person_add;

  @override
  List<ManualSection> getSections(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      // Section 1: Freelancer Overview
      ManualSection(
        id: 'freelancer_overview',
        title: loc.docsFreelancerFreelancerOverview_title,
        subtitle: loc.docsFreelancerFreelancerOverview_subtitle,
        icon: Icons.info_outline,
        category: 'Freelancer Setup',
        order: 1,
        contents: [
          ManualContent(
            id: 'freelancer_welcome',
            title: loc.docsFreelancerFreelancerOverview_freelancerWelcomeTitle,
            content: loc.docsFreelancerFreelancerOverview_freelancerWelcomeContent,
            numberPrefix: '1',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'freelancer_vs_shop',
            title: loc.docsFreelancerFreelancerOverview_freelancerVsShopTitle,
            content: loc.docsFreelancerFreelancerOverview_freelancerVsShopContent,
            numberPrefix: '2',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsFreelancerFreelancerOverview_freelancerVsShopBullet1,
              loc.docsFreelancerFreelancerOverview_freelancerVsShopBullet2,
              loc.docsFreelancerFreelancerOverview_freelancerVsShopBullet3,
              loc.docsFreelancerFreelancerOverview_freelancerVsShopBullet4,
              loc.docsFreelancerFreelancerOverview_freelancerVsShopBullet5,
            ],
          ),
          ManualContent(
            id: 'freelancer_requirements',
            title: loc.docsFreelancerFreelancerOverview_freelancerRequirementsTitle,
            content: loc.docsFreelancerFreelancerOverview_freelancerRequirementsContent,
            numberPrefix: '3',
            type: ManualContentType.text,
          ),
        ],
      ),

      // Section 2: Profile Setup
      ManualSection(
        id: 'profile_setup',
        title: loc.docsFreelancerProfileSetup_title,
        subtitle: loc.docsFreelancerProfileSetup_subtitle,
        icon: Icons.person,
        category: 'Freelancer Setup',
        order: 2,
        contents: [
          ManualContent(
            id: 'profile_photo',
            title: loc.docsFreelancerProfileSetup_profilePhotoTitle,
            content: loc.docsFreelancerProfileSetup_profilePhotoContent,
            numberPrefix: '1',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'your_name',
            title: loc.docsFreelancerProfileSetup_yourNameTitle,
            content: loc.docsFreelancerProfileSetup_yourNameContent,
            numberPrefix: '2',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'profession_type',
            title: loc.docsFreelancerProfileSetup_professionTypeTitle,
            content: loc.docsFreelancerProfileSetup_professionTypeContent,
            numberPrefix: '3',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'bio_description',
            title: loc.docsFreelancerProfileSetup_bioDescriptionTitle,
            content: loc.docsFreelancerProfileSetup_bioDescriptionContent,
            numberPrefix: '4',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'terms_guidelines',
            title: loc.docsFreelancerProfileSetup_termsGuidelinesTitle,
            content: loc.docsFreelancerProfileSetup_termsGuidelinesContent,
            numberPrefix: '5',
            type: ManualContentType.text,
          ),
        ],
      ),

      // Section 3: Service Area
      ManualSection(
        id: 'service_area',
        title: loc.docsFreelancerServiceArea_title,
        subtitle: loc.docsFreelancerServiceArea_subtitle,
        icon: Icons.location_on,
        category: 'Freelancer Setup',
        order: 3,
        contents: [
          ManualContent(
            id: 'base_location',
            title: loc.docsFreelancerServiceArea_baseLocationTitle,
            content: loc.docsFreelancerServiceArea_baseLocationContent,
            numberPrefix: '1',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'travel_radius',
            title: loc.docsFreelancerServiceArea_travelRadiusTitle,
            content: loc.docsFreelancerServiceArea_travelRadiusContent,
            numberPrefix: '2',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'mobile_vs_fixed',
            title: loc.docsFreelancerServiceArea_mobileVsFixedTitle,
            content: loc.docsFreelancerServiceArea_mobileVsFixedContent,
            numberPrefix: '3',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'service_address_tip',
            title: '',
            content: loc.docsFreelancerServiceArea_serviceAddressTipContent,
            type: ManualContentType.tip,
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
        id: 'faq_freelancer_1',
        question: loc.docsFreelancerFaq1Q,
        answer: loc.docsFreelancerFaq1A,
        category: 'Getting Started',
        order: 1,
      ),
      FAQModel(
        id: 'faq_freelancer_2',
        question: loc.docsFreelancerFaq2Q,
        answer: loc.docsFreelancerFaq2A,
        category: 'Getting Started',
        order: 2,
      ),
      FAQModel(
        id: 'faq_freelancer_3',
        question: loc.docsFreelancerFaq3Q,
        answer: loc.docsFreelancerFaq3A,
        category: 'Management',
        order: 3,
      ),
      FAQModel(
        id: 'faq_freelancer_4',
        question: loc.docsFreelancerFaq4Q,
        answer: loc.docsFreelancerFaq4A,
        category: 'Payments',
        order: 4,
      ),
      FAQModel(
        id: 'faq_freelancer_5',
        question: loc.docsFreelancerFaq5Q,
        answer: loc.docsFreelancerFaq5A,
        category: 'Bookings',
        order: 5,
      ),
    ];
  }
}
