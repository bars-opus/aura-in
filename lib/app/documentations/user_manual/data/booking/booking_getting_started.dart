// lib/features/documentation/data/docs/booking_docs/booking_getting_started.dart

import 'package:flutter/material.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';
import 'package:nano_embryo/app/documentations/user_manual/models/documentation_model.dart'
    show DocumentationModule;
import 'package:nano_embryo/app/documentations/user_manual/models/faq_model.dart';
import 'package:nano_embryo/app/documentations/user_manual/models/manual_content.dart';
import 'package:nano_embryo/app/documentations/user_manual/models/manual_section.dart';

class BookingGettingStartedDocs implements DocumentationModule {
  @override
  int get order => 1;

  @override
  String getTitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsBookingStartedTitle;
  }

  @override
  String get id => 'bookingGettingStarted';

  @override
  String getSubtitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsBookingStartedSubtitle;
  }

  @override
  IconData get icon => Icons.calendar_month;

  @override
  List<ManualSection> getSections(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
    ManualSection(
      id: 'booking_introduction',
      title: loc.docsBookingStartedBookingIntro_title,
      subtitle: loc.docsBookingStartedBookingIntro_subtitle,
      icon: Icons.auto_awesome,
      category: 'Booking Guide',
      order: 1,
      contents: [
        ManualContent(
          id: 'what_is_booking',
          title: loc.docsBookingStartedBookingIntro_whatIsBooking_title,
          content: loc.docsBookingStartedBookingIntro_whatIsBooking_content,
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'who_its_for',
          title: loc.docsBookingStartedBookingIntro_whoItsFor_title,
          content: loc.docsBookingStartedBookingIntro_whoItsFor_content,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsBookingStartedBookingIntro_whoItsFor_bullet1,
            loc.docsBookingStartedBookingIntro_whoItsFor_bullet2,
            loc.docsBookingStartedBookingIntro_whoItsFor_bullet3,
          ],
        ),
        ManualContent(
          id: 'guest_booking_intro',
          title: loc.docsBookingStartedBookingIntro_guestBookingIntro_title,
          content: loc.docsBookingStartedBookingIntro_guestBookingIntro_content,
          numberPrefix: '2b',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'welcome_note',
          title: '',
          content: loc.docsBookingStartedBookingIntro_welcomeNote_content,
          type: ManualContentType.tip,
        ),
      ],
    ),
    ManualSection(
      id: 'creating_account',
      title: loc.docsBookingStartedCreatingAccount_title,
      subtitle: loc.docsBookingStartedCreatingAccount_subtitle,
      icon: Icons.person_add,
      category: 'Getting Started',
      order: 2,
      contents: [
        ManualContent(
          id: 'two_ways_to_book',
          title: loc.docsBookingStartedCreatingAccount_twoWaysToBook_title,
          content: loc.docsBookingStartedCreatingAccount_twoWaysToBook_content,
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsBookingStartedCreatingAccount_twoWaysToBook_bullet1,
            loc.docsBookingStartedCreatingAccount_twoWaysToBook_bullet2,
          ],
        ),
        ManualContent(
          id: 'account_steps',
          title: loc.docsBookingStartedCreatingAccount_accountSteps_title,
          content: loc.docsBookingStartedCreatingAccount_accountSteps_content,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsBookingStartedCreatingAccount_accountSteps_bullet1,
            loc.docsBookingStartedCreatingAccount_accountSteps_bullet2,
            loc.docsBookingStartedCreatingAccount_accountSteps_bullet3,
            loc.docsBookingStartedCreatingAccount_accountSteps_bullet4,
            loc.docsBookingStartedCreatingAccount_accountSteps_bullet5,
            loc.docsBookingStartedCreatingAccount_accountSteps_bullet6,
          ],
        ),
        ManualContent(
          id: 'account_types',
          title: loc.docsBookingStartedCreatingAccount_accountTypes_title,
          content: loc.docsBookingStartedCreatingAccount_accountTypes_content,
          numberPrefix: '3',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsBookingStartedCreatingAccount_accountTypes_bullet1,
            loc.docsBookingStartedCreatingAccount_accountTypes_bullet2,
          ],
        ),
        ManualContent(
          id: 'guest_booking_option',
          title: loc.docsBookingStartedCreatingAccount_guestBookingOption_title,
          content: loc.docsBookingStartedCreatingAccount_guestBookingOption_content,
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'verification_note',
          title: '',
          content: loc.docsBookingStartedCreatingAccount_verificationNote_content,
          type: ManualContentType.important,
        ),
      ],
    ),
    ManualSection(
      id: 'first_booking',
      title: loc.docsBookingStartedFirstBooking_title,
      subtitle: loc.docsBookingStartedFirstBooking_subtitle,
      icon: Icons.event_available,
      category: 'Getting Started',
      order: 3,
      contents: [
        ManualContent(
          id: 'booking_steps',
          title: loc.docsBookingStartedFirstBooking_bookingSteps_title,
          content: loc.docsBookingStartedFirstBooking_bookingSteps_content,
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsBookingStartedFirstBooking_bookingSteps_bullet1,
            loc.docsBookingStartedFirstBooking_bookingSteps_bullet2,
            loc.docsBookingStartedFirstBooking_bookingSteps_bullet3,
            loc.docsBookingStartedFirstBooking_bookingSteps_bullet4,
            loc.docsBookingStartedFirstBooking_bookingSteps_bullet5,
            loc.docsBookingStartedFirstBooking_bookingSteps_bullet6,
          ],
        ),
        ManualContent(
          id: 'what_happens_next',
          title: loc.docsBookingStartedFirstBooking_whatHappensNext_title,
          content: loc.docsBookingStartedFirstBooking_whatHappensNext_content,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsBookingStartedFirstBooking_whatHappensNext_bullet1,
            loc.docsBookingStartedFirstBooking_whatHappensNext_bullet2,
            loc.docsBookingStartedFirstBooking_whatHappensNext_bullet3,
            loc.docsBookingStartedFirstBooking_whatHappensNext_bullet4,
            loc.docsBookingStartedFirstBooking_whatHappensNext_bullet5,
          ],
        ),
        ManualContent(
          id: 'payment_process',
          title: loc.docsBookingStartedFirstBooking_paymentProcess_title,
          content: loc.docsBookingStartedFirstBooking_paymentProcess_content,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsBookingStartedFirstBooking_paymentProcess_bullet1,
            loc.docsBookingStartedFirstBooking_paymentProcess_bullet2,
            loc.docsBookingStartedFirstBooking_paymentProcess_bullet3,
            loc.docsBookingStartedFirstBooking_paymentProcess_bullet4,
            loc.docsBookingStartedFirstBooking_paymentProcess_bullet5,
          ],
        ),

        ManualContent(
          id: 'remaining_payment_options',
          title: loc.docsBookingStartedFirstBooking_remainingPaymentOptions_title,
          content: loc.docsBookingStartedFirstBooking_remainingPaymentOptions_content,
          numberPrefix: '2b',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsBookingStartedFirstBooking_remainingPaymentOptions_bullet1,
            loc.docsBookingStartedFirstBooking_remainingPaymentOptions_bullet2,
            loc.docsBookingStartedFirstBooking_remainingPaymentOptions_bullet3,
          ],
        ),

        ManualContent(
          id: 'deposit_note',
          title: '',
          content: loc.docsBookingStartedFirstBooking_depositNote_content,
          type: ManualContentType.important,
        ),
        ManualContent(
          id: 'booking_tip',
          title: '',
          content: loc.docsBookingStartedFirstBooking_bookingTip_content,
          type: ManualContentType.tip,
        ),
      ],
    ),
    ManualSection(
      id: 'navigation',
      title: loc.docsBookingStartedNavigation_title,
      subtitle: loc.docsBookingStartedNavigation_subtitle,
      icon: Icons.map,
      category: 'Getting Started',
      order: 4,
      contents: [
        ManualContent(
          id: 'main_screens',
          title: loc.docsBookingStartedNavigation_mainScreens_title,
          content: loc.docsBookingStartedNavigation_mainScreens_content,
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsBookingStartedNavigation_mainScreens_bullet1,
            loc.docsBookingStartedNavigation_mainScreens_bullet2,
            loc.docsBookingStartedNavigation_mainScreens_bullet3,
            loc.docsBookingStartedNavigation_mainScreens_bullet4,
            loc.docsBookingStartedNavigation_mainScreens_bullet5,
          ],
        ),
        ManualContent(
          id: 'booking_flow',
          title: loc.docsBookingStartedNavigation_bookingFlow_title,
          content: loc.docsBookingStartedNavigation_bookingFlow_content,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsBookingStartedNavigation_bookingFlow_bullet1,
            loc.docsBookingStartedNavigation_bookingFlow_bullet2,
            loc.docsBookingStartedNavigation_bookingFlow_bullet3,
            loc.docsBookingStartedNavigation_bookingFlow_bullet4,
          ],
        ),
        ManualContent(
          id: 'navigation_tip',
          title: '',
          content: loc.docsBookingStartedNavigation_navigationTip_content,
          type: ManualContentType.tip,
        ),
      ],
    ),
    ManualSection(
      id: 'booking_basics',
      title: loc.docsBookingStartedBasics_title,
      subtitle: loc.docsBookingStartedBasics_subtitle,
      icon: Icons.school,
      category: 'Getting Started',
      order: 5,
      contents: [
        ManualContent(
          id: 'key_concepts',
          title: loc.docsBookingStartedBasics_keyTerms_title,
          content: loc.docsBookingStartedBasics_keyTerms_content,
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsBookingStartedBasics_keyTerms_bullet1,
            loc.docsBookingStartedBasics_keyTerms_bullet2,
            loc.docsBookingStartedBasics_keyTerms_bullet3,
            loc.docsBookingStartedBasics_keyTerms_bullet4,
            loc.docsBookingStartedBasics_keyTerms_bullet5,
          ],
        ),
        ManualContent(
          id: 'what_you_need',
          title: loc.docsBookingStartedBasics_whatYouNeed_title,
          content: loc.docsBookingStartedBasics_whatYouNeed_content,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsBookingStartedBasics_whatYouNeed_bullet1,
            loc.docsBookingStartedBasics_whatYouNeed_bullet2,
            loc.docsBookingStartedBasics_whatYouNeed_bullet3,
            loc.docsBookingStartedBasics_whatYouNeed_bullet4,
          ],
        ),
        ManualContent(
          id: 'deposit_explained',
          title: loc.docsBookingStartedBasics_depositExplained_title,
          content: loc.docsBookingStartedBasics_depositExplained_content,
          numberPrefix: '3',
          type: ManualContentType.text,
        ),

        ManualContent(
          id: 'deposit_example',
          title: loc.docsBookingStartedBasics_depositExample_title,
          content: loc.docsBookingStartedBasics_depositExample_content,
          type: ManualContentType.text,
        ),

        ManualContent(
          id: 'deposit_tip',
          title: '',
          content: loc.docsBookingStartedBasics_depositTip_content,
          type: ManualContentType.tip,
        ),

        ManualContent(
          id: 'basics_important',
          title: '',
          content: loc.docsBookingStartedBasics_basicsImportant_content,
          type: ManualContentType.important,
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
        id: 'faq_gs_no_account',
        question: loc.docsBookingStartedFaq1Q,
        answer: loc.docsBookingStartedFaq1A,
        category: 'Getting Started',
        order: 1,
      ),
      FAQModel(
        id: 'faq_gs_cost',
        question: loc.docsBookingStartedFaq2Q,
        answer: loc.docsBookingStartedFaq2A,
        category: 'Getting Started',
        order: 2,
      ),
      FAQModel(
        id: 'faq_gs_multiple_shops',
        question: loc.docsBookingStartedFaq3Q,
        answer: loc.docsBookingStartedFaq3A,
        category: 'Getting Started',
        order: 3,
      ),
      FAQModel(
        id: 'faq_gs_deposit_refund',
        question: loc.docsBookingStartedFaq4Q,
        answer: loc.docsBookingStartedFaq4A,
        category: 'Getting Started',
        order: 8,
      ),

      FAQModel(
        id: 'faq_gs_deposit_amount',
        question: loc.docsBookingStartedFaq5Q,
        answer: loc.docsBookingStartedFaq5A,
        category: 'Getting Started',
        order: 9,
      ),

      FAQModel(
        id: 'faq_gs_deposit_multiple',
        question: loc.docsBookingStartedFaq6Q,
        answer: loc.docsBookingStartedFaq6A,
        category: 'Getting Started',
        order: 10,
      ),

      FAQModel(
        id: 'faq_gs_deposit_emergency',
        question: loc.docsBookingStartedFaq7Q,
        answer: loc.docsBookingStartedFaq7A,
        category: 'Getting Started',
        order: 11,
      ),
      FAQModel(
        id: 'faq_gs_reminders',
        question: loc.docsBookingStartedFaq8Q,
        answer: loc.docsBookingStartedFaq8A,
        category: 'Getting Started',
        order: 5,
      ),
      FAQModel(
        id: 'faq_gs_payment',
        question: loc.docsBookingStartedFaq9Q,
        answer: loc.docsBookingStartedFaq9A,
        category: 'Getting Started',
        order: 6,
      ),
      FAQModel(
        id: 'faq_gs_shop_owner',
        question: loc.docsBookingStartedFaq10Q,
        answer: loc.docsBookingStartedFaq10A,
        category: 'Getting Started',
        order: 7,
      ),
      FAQModel(
        id: 'faq_gs_guest_booking',
        question: loc.docsBookingStartedFaq11Q,
        answer: loc.docsBookingStartedFaq11A,
        category: 'Getting Started',
        order: 12,
      ),
      FAQModel(
        id: 'faq_gs_platform_fee',
        question: loc.docsBookingStartedFaq12Q,
        answer: loc.docsBookingStartedFaq12A,
        category: 'Getting Started',
        order: 13,
      ),
      FAQModel(
        id: 'faq_gs_remaining_payment_options',
        question: loc.docsBookingStartedFaq13Q,
        answer: loc.docsBookingStartedFaq13A,
        category: 'Getting Started',
        order: 14,
      ),
      FAQModel(
        id: 'faq_gs_guest_receipt',
        question: loc.docsBookingStartedFaq14Q,
        answer: loc.docsBookingStartedFaq14A,
        category: 'Getting Started',
        order: 15,
      ),
    ];
  }
}
