// lib/features/documentation/data/docs/booking_docs/group_bookings.dart

import 'package:flutter/material.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';
import 'package:nano_embryo/app/documentations/user_manual/models/documentation_model.dart'
    show DocumentationModule;
import 'package:nano_embryo/app/documentations/user_manual/models/faq_model.dart';
import 'package:nano_embryo/app/documentations/user_manual/models/manual_content.dart';
import 'package:nano_embryo/app/documentations/user_manual/models/manual_section.dart';

class GroupBookingsDocs implements DocumentationModule {
  @override
  int get order => 3;

  @override
  String getTitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsGroupBookingsTitle;
  }

  @override
  String get id => 'groupBookings';

  @override
  String getSubtitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsGroupBookingsSubtitle;
  }

  @override
  IconData get icon => Icons.group;

  @override
  List<ManualSection> getSections(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
    ManualSection(
      id: 'group_intro',
      title: loc.docsGroupBookingsIntro_title,
      subtitle: loc.docsGroupBookingsIntro_subtitle,
      icon: Icons.group_add,
      category: 'Group Bookings',
      order: 1,
      contents: [
        ManualContent(
          id: 'group_explained',
          title: loc.docsGroupBookingsIntro_explained_title,
          content: loc.docsGroupBookingsIntro_explained_content,
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsGroupBookingsIntro_explained_bullet1,
            loc.docsGroupBookingsIntro_explained_bullet2,
            loc.docsGroupBookingsIntro_explained_bullet3,
            loc.docsGroupBookingsIntro_explained_bullet4,
          ],
        ),
        ManualContent(
          id: 'group_example',
          title: loc.docsGroupBookingsIntro_example_title,
          content: loc.docsGroupBookingsIntro_example_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'group_benefits',
          title: loc.docsGroupBookingsIntro_benefits_title,
          content: loc.docsGroupBookingsIntro_benefits_content,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsGroupBookingsIntro_benefits_bullet1,
            loc.docsGroupBookingsIntro_benefits_bullet2,
            loc.docsGroupBookingsIntro_benefits_bullet3,
            loc.docsGroupBookingsIntro_benefits_bullet4,
            loc.docsGroupBookingsIntro_benefits_bullet5,
          ],
        ),
        ManualContent(
          id: 'group_tip',
          title: '',
          content: loc.docsGroupBookingsIntro_tip_content,
          type: ManualContentType.tip,
        ),
      ],
    ),
    ManualSection(
      id: 'how_to_group',
      title: loc.docsGroupBookingsHowTo_title,
      subtitle: loc.docsGroupBookingsHowTo_subtitle,
      icon: Icons.layers,
      category: 'Group Bookings',
      order: 2,
      contents: [
        ManualContent(
          id: 'group_step1',
          title: loc.docsGroupBookingsHowTo_step1_title,
          content: loc.docsGroupBookingsHowTo_step1_content,
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'group_step2',
          title: loc.docsGroupBookingsHowTo_step2_title,
          content: loc.docsGroupBookingsHowTo_step2_content,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsGroupBookingsHowTo_step2_bullet1,
            loc.docsGroupBookingsHowTo_step2_bullet2,
            loc.docsGroupBookingsHowTo_step2_bullet3,
            loc.docsGroupBookingsHowTo_step2_bullet4,
          ],
        ),
        ManualContent(
          id: 'group_step2_example',
          title: loc.docsGroupBookingsHowTo_step2Example_title,
          content: loc.docsGroupBookingsHowTo_step2Example_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'group_step3',
          title: loc.docsGroupBookingsHowTo_step3_title,
          content: loc.docsGroupBookingsHowTo_step3_content,
          numberPrefix: '3',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsGroupBookingsHowTo_step3_bullet1,
            loc.docsGroupBookingsHowTo_step3_bullet2,
            loc.docsGroupBookingsHowTo_step3_bullet3,
          ],
        ),
        ManualContent(
          id: 'group_step3_example',
          title: loc.docsGroupBookingsHowTo_step3Example_title,
          content: loc.docsGroupBookingsHowTo_step3Example_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'group_step4',
          title: loc.docsGroupBookingsHowTo_step4_title,
          content: loc.docsGroupBookingsHowTo_step4_content,
          numberPrefix: '4',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsGroupBookingsHowTo_step4_bullet1,
            loc.docsGroupBookingsHowTo_step4_bullet2,
            loc.docsGroupBookingsHowTo_step4_bullet3,
            loc.docsGroupBookingsHowTo_step4_bullet4,
          ],
        ),
        ManualContent(
          id: 'group_step4_example',
          title: loc.docsGroupBookingsHowTo_step4Example_title,
          content: loc.docsGroupBookingsHowTo_step4Example_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'group_step5',
          title: loc.docsGroupBookingsHowTo_step5_title,
          content: loc.docsGroupBookingsHowTo_step5_content,
          numberPrefix: '5',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsGroupBookingsHowTo_step5_bullet1,
            loc.docsGroupBookingsHowTo_step5_bullet2,
            loc.docsGroupBookingsHowTo_step5_bullet3,
          ],
        ),
        ManualContent(
          id: 'group_step5_example',
          title: loc.docsGroupBookingsHowTo_step5Example_title,
          content: loc.docsGroupBookingsHowTo_step5Example_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'group_step6',
          title: loc.docsGroupBookingsHowTo_step6_title,
          content: loc.docsGroupBookingsHowTo_step6_content,
          numberPrefix: '6',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsGroupBookingsHowTo_step6_bullet1,
            loc.docsGroupBookingsHowTo_step6_bullet2,
            loc.docsGroupBookingsHowTo_step6_bullet3,
            loc.docsGroupBookingsHowTo_step6_bullet4,
          ],
        ),
        ManualContent(
          id: 'group_step6_example',
          title: loc.docsGroupBookingsHowTo_step6Example_title,
          content: loc.docsGroupBookingsHowTo_step6Example_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'group_important',
          title: '',
          content: loc.docsGroupBookingsHowTo_important_content,
          type: ManualContentType.important,
        ),
      ],
    ),
    ManualSection(
      id: 'group_worker',
      title: loc.docsGroupBookingsWorker_title,
      subtitle: loc.docsGroupBookingsWorker_subtitle,
      icon: Icons.people,
      category: 'Group Bookings',
      order: 3,
      contents: [
        ManualContent(
          id: 'group_worker_intro',
          title: loc.docsGroupBookingsWorker_intro_title,
          content: loc.docsGroupBookingsWorker_intro_content,
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsGroupBookingsWorker_intro_bullet1,
            loc.docsGroupBookingsWorker_intro_bullet2,
            loc.docsGroupBookingsWorker_intro_bullet3,
          ],
        ),
        ManualContent(
          id: 'group_worker_same',
          title: loc.docsGroupBookingsWorker_same_title,
          content: loc.docsGroupBookingsWorker_same_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'group_worker_different',
          title: loc.docsGroupBookingsWorker_different_title,
          content: loc.docsGroupBookingsWorker_different_content,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsGroupBookingsWorker_different_bullet1,
            loc.docsGroupBookingsWorker_different_bullet2,
            loc.docsGroupBookingsWorker_different_bullet3,
            loc.docsGroupBookingsWorker_different_bullet4,
          ],
        ),
        ManualContent(
          id: 'group_worker_interface',
          title: loc.docsGroupBookingsWorker_interface_title,
          content: loc.docsGroupBookingsWorker_interface_content,
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'group_worker_example',
          title: loc.docsGroupBookingsWorker_example_title,
          content: loc.docsGroupBookingsWorker_example_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'group_worker_tip',
          title: '',
          content: loc.docsGroupBookingsWorker_tip_content,
          type: ManualContentType.tip,
        ),
      ],
    ),
    ManualSection(
      id: 'group_time',
      title: loc.docsGroupBookingsTime_title,
      subtitle: loc.docsGroupBookingsTime_subtitle,
      icon: Icons.access_time,
      category: 'Group Bookings',
      order: 4,
      contents: [
        ManualContent(
          id: 'group_time_calculation',
          title: loc.docsGroupBookingsTime_calculation_title,
          content: loc.docsGroupBookingsTime_calculation_content,
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsGroupBookingsTime_calculation_bullet1,
            loc.docsGroupBookingsTime_calculation_bullet2,
            loc.docsGroupBookingsTime_calculation_bullet3,
          ],
        ),
        ManualContent(
          id: 'group_time_example_sequential',
          title: loc.docsGroupBookingsTime_sequential_title,
          content: loc.docsGroupBookingsTime_sequential_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'group_time_example_parallel',
          title: loc.docsGroupBookingsTime_parallel_title,
          content: loc.docsGroupBookingsTime_parallel_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'group_time_combined',
          title: loc.docsGroupBookingsTime_combined_title,
          content: loc.docsGroupBookingsTime_combined_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'group_time_tip',
          title: '',
          content: loc.docsGroupBookingsTime_tip_content,
          type: ManualContentType.tip,
        ),
      ],
    ),
    ManualSection(
      id: 'group_payment',
      title: loc.docsGroupBookingsPayment_title,
      subtitle: loc.docsGroupBookingsPayment_subtitle,
      icon: Icons.payment,
      category: 'Group Bookings',
      order: 5,
      contents: [
        ManualContent(
          id: 'group_payment_deposit',
          title: loc.docsGroupBookingsPayment_deposit_title,
          content: loc.docsGroupBookingsPayment_deposit_content,
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsGroupBookingsPayment_deposit_bullet1,
            loc.docsGroupBookingsPayment_deposit_bullet2,
            loc.docsGroupBookingsPayment_deposit_bullet3,
            loc.docsGroupBookingsPayment_deposit_bullet4,
          ],
        ),
        ManualContent(
          id: 'group_payment_example',
          title: loc.docsGroupBookingsPayment_example_title,
          content: loc.docsGroupBookingsPayment_example_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'group_payment_cancellation',
          title: loc.docsGroupBookingsPayment_cancellation_title,
          content: loc.docsGroupBookingsPayment_cancellation_content,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsGroupBookingsPayment_cancellation_bullet1,
            loc.docsGroupBookingsPayment_cancellation_bullet2,
            loc.docsGroupBookingsPayment_cancellation_bullet3,
          ],
        ),
        ManualContent(
          id: 'group_payment_important',
          title: '',
          content: loc.docsGroupBookingsPayment_important_content,
          type: ManualContentType.important,
        ),
        ManualContent(
          id: 'group_payment_flexibility',
          title: loc.docsGroupBookingsPayment_flexibility_title,
          content: loc.docsGroupBookingsPayment_flexibility_content,
          numberPrefix: '3',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsGroupBookingsPayment_flexibility_bullet1,
            loc.docsGroupBookingsPayment_flexibility_bullet2,
            loc.docsGroupBookingsPayment_flexibility_bullet3,
            loc.docsGroupBookingsPayment_flexibility_bullet4,
          ],
        ),
      ],
    ),
    ManualSection(
      id: 'group_scenarios',
      title: loc.docsGroupBookingsScenarios_title,
      subtitle: loc.docsGroupBookingsScenarios_subtitle,
      icon: Icons.format_list_bulleted,
      category: 'Group Bookings',
      order: 6,
      contents: [
        ManualContent(
          id: 'scenario_family',
          title: loc.docsGroupBookingsScenarios_family_title,
          content: loc.docsGroupBookingsScenarios_family_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'scenario_friends',
          title: loc.docsGroupBookingsScenarios_friends_title,
          content: loc.docsGroupBookingsScenarios_friends_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'scenario_bridal',
          title: loc.docsGroupBookingsScenarios_bridal_title,
          content: loc.docsGroupBookingsScenarios_bridal_content,
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
        id: 'faq_group_what',
        question: loc.docsGroupBookingsFaq1Q,
        answer: loc.docsGroupBookingsFaq1A,
        category: 'Group Bookings',
        order: 1,
      ),
      FAQModel(
        id: 'faq_group_quantity',
        question: loc.docsGroupBookingsFaq2Q,
        answer: loc.docsGroupBookingsFaq2A,
        category: 'Group Bookings',
        order: 2,
      ),
      FAQModel(
        id: 'faq_group_different_services',
        question: loc.docsGroupBookingsFaq3Q,
        answer: loc.docsGroupBookingsFaq3A,
        category: 'Group Bookings',
        order: 3,
      ),
      FAQModel(
        id: 'faq_group_workers',
        question: loc.docsGroupBookingsFaq4Q,
        answer: loc.docsGroupBookingsFaq4A,
        category: 'Group Bookings',
        order: 4,
      ),
      FAQModel(
        id: 'faq_group_payment',
        question: loc.docsGroupBookingsFaq5Q,
        answer: loc.docsGroupBookingsFaq5A,
        category: 'Group Bookings',
        order: 5,
      ),
      FAQModel(
        id: 'faq_group_cancel',
        question: loc.docsGroupBookingsFaq6Q,
        answer: loc.docsGroupBookingsFaq6A,
        category: 'Group Bookings',
        order: 6,
      ),
      FAQModel(
        id: 'faq_group_time',
        question: loc.docsGroupBookingsFaq7Q,
        answer: loc.docsGroupBookingsFaq7A,
        category: 'Group Bookings',
        order: 7,
      ),
      FAQModel(
        id: 'faq_group_max',
        question: loc.docsGroupBookingsFaq8Q,
        answer: loc.docsGroupBookingsFaq8A,
        category: 'Group Bookings',
        order: 8,
      ),
      FAQModel(
        id: 'faq_group_kids',
        question: loc.docsGroupBookingsFaq9Q,
        answer: loc.docsGroupBookingsFaq9A,
        category: 'Group Bookings',
        order: 9,
      ),
      FAQModel(
        id: 'faq_group_check_in',
        question: loc.docsGroupBookingsFaq10Q,
        answer: loc.docsGroupBookingsFaq10A,
        category: 'Group Bookings',
        order: 10,
      ),
      FAQModel(
        id: 'faq_group_split_payment',
        question: loc.docsGroupBookingsFaq11Q,
        answer: loc.docsGroupBookingsFaq11A,
        category: 'Group Bookings',
        order: 11,
      ),
      FAQModel(
        id: 'faq_group_reschedule',
        question: loc.docsGroupBookingsFaq12Q,
        answer: loc.docsGroupBookingsFaq12A,
        category: 'Group Bookings',
        order: 12,
      ),
      FAQModel(
        id: 'faq_group_guest_booking',
        question: loc.docsGroupBookingsFaq13Q,
        answer: loc.docsGroupBookingsFaq13A,
        category: 'Group Bookings',
        order: 13,
      ),
      FAQModel(
        id: 'faq_group_remaining_cash',
        question: loc.docsGroupBookingsFaq14Q,
        answer: loc.docsGroupBookingsFaq14A,
        category: 'Group Bookings',
        order: 14,
      ),
    ];
  }
}
