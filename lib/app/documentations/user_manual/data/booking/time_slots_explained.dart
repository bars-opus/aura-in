// lib/features/documentation/data/docs/booking_docs/time_slots_explained.dart
import 'package:flutter/material.dart';
import 'package:nano_embryo/app/documentations/user_manual/models/documentation_model.dart'
    show DocumentationModule;
import 'package:nano_embryo/app/documentations/user_manual/models/faq_model.dart';
import 'package:nano_embryo/app/documentations/user_manual/models/manual_content.dart';
import 'package:nano_embryo/app/documentations/user_manual/models/manual_section.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';


class TimeSlotsExplainedDocs implements DocumentationModule {
  @override
  int get order => 5;

  @override
  String getTitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsTimeSlotsTitle;
  }

  @override
  String get id => 'timeSlotsExplained';

  @override
  String getSubtitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsTimeSlotsSubtitle;
  }

  @override
  IconData get icon => Icons.access_time;

  @override
  List<ManualSection> getSections(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      ManualSection(
        id: 'time_intro',
        title: loc.docsTimeSlotsExplainedTimeIntro_title,
        subtitle: loc.docsTimeSlotsExplainedTimeIntro_subtitle,
        icon: Icons.visibility,
        category: 'Time Slots',
        order: 1,
        contents: [
          ManualContent(
            id: 'time_intro_text',
            title: loc.docsTimeSlotsExplainedTimeIntro_timeIntroText_title,
            content: loc.docsTimeSlotsExplainedTimeIntro_timeIntroText_content,
            numberPrefix: '1',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'time_switch',
            title: loc.docsTimeSlotsExplainedTimeIntro_timeSwitch_title,
            content: loc.docsTimeSlotsExplainedTimeIntro_timeSwitch_content,
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'time_important',
            title: '',
            content: loc.docsTimeSlotsExplainedTimeIntro_timeImportant_content,
            type: ManualContentType.important,
          ),
        ],
      ),
      ManualSection(
        id: 'regular_view',
        title: loc.docsTimeSlotsExplainedRegularView_title,
        subtitle: loc.docsTimeSlotsExplainedRegularView_subtitle,
        icon: Icons.view_list,
        category: 'Time Slots',
        order: 2,
        contents: [
          ManualContent(
            id: 'regular_explained',
            title: loc.docsTimeSlotsExplainedRegularView_regularExplained_title,
            content: loc.docsTimeSlotsExplainedRegularView_regularExplained_content,
            numberPrefix: '1',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'regular_example',
            title: loc.docsTimeSlotsExplainedRegularView_regularExample_title,
            content: loc.docsTimeSlotsExplainedRegularView_regularExample_content,
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'regular_when',
            title: loc.docsTimeSlotsExplainedRegularView_regularWhen_title,
            content: loc.docsTimeSlotsExplainedRegularView_regularWhen_content,
            numberPrefix: '2',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsTimeSlotsExplainedRegularView_regularWhen_bullet1,
              loc.docsTimeSlotsExplainedRegularView_regularWhen_bullet2,
              loc.docsTimeSlotsExplainedRegularView_regularWhen_bullet3,
              loc.docsTimeSlotsExplainedRegularView_regularWhen_bullet4,
            ],
          ),
          ManualContent(
            id: 'regular_challenge',
            title: loc.docsTimeSlotsExplainedRegularView_regularChallenge_title,
            content: loc.docsTimeSlotsExplainedRegularView_regularChallenge_content,
            type: ManualContentType.warning,
          ),
          ManualContent(
            id: 'regular_tip',
            title: '',
            content: loc.docsTimeSlotsExplainedRegularView_regularTip_content,
            type: ManualContentType.tip,
          ),
        ],
      ),
      ManualSection(
        id: 'combined_view',
        title: loc.docsTimeSlotsExplainedCombinedView_title,
        subtitle: loc.docsTimeSlotsExplainedCombinedView_subtitle,
        icon: Icons.merge_type,
        category: 'Time Slots',
        order: 3,
        contents: [
          ManualContent(
            id: 'combined_explained',
            title: loc.docsTimeSlotsExplainedCombinedView_combinedExplained_title,
            content: loc.docsTimeSlotsExplainedCombinedView_combinedExplained_content,
            numberPrefix: '1',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'combined_example',
            title: loc.docsTimeSlotsExplainedCombinedView_combinedExample_title,
            content: loc.docsTimeSlotsExplainedCombinedView_combinedExample_content,
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'combined_calculation',
            title: loc.docsTimeSlotsExplainedCombinedView_combinedCalculation_title,
            content: loc.docsTimeSlotsExplainedCombinedView_combinedCalculation_content,
            numberPrefix: '2',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsTimeSlotsExplainedCombinedView_combinedCalculation_bullet1,
              loc.docsTimeSlotsExplainedCombinedView_combinedCalculation_bullet2,
              loc.docsTimeSlotsExplainedCombinedView_combinedCalculation_bullet3,
              loc.docsTimeSlotsExplainedCombinedView_combinedCalculation_bullet4,
            ],
          ),
          ManualContent(
            id: 'combined_example_calc',
            title: loc.docsTimeSlotsExplainedCombinedView_combinedExampleCalc_title,
            content: loc.docsTimeSlotsExplainedCombinedView_combinedExampleCalc_content,
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'combined_when',
            title: loc.docsTimeSlotsExplainedCombinedView_combinedWhen_title,
            content: loc.docsTimeSlotsExplainedCombinedView_combinedWhen_content,
            numberPrefix: '3',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsTimeSlotsExplainedCombinedView_combinedWhen_bullet1,
              loc.docsTimeSlotsExplainedCombinedView_combinedWhen_bullet2,
              loc.docsTimeSlotsExplainedCombinedView_combinedWhen_bullet3,
              loc.docsTimeSlotsExplainedCombinedView_combinedWhen_bullet4,
            ],
          ),
          ManualContent(
            id: 'combined_benefit',
            title: '',
            content: loc.docsTimeSlotsExplainedCombinedView_combinedBenefit_content,
            type: ManualContentType.important,
          ),
        ],
      ),
      ManualSection(
        id: 'comparison',
        title: loc.docsTimeSlotsExplainedComparison_title,
        subtitle: loc.docsTimeSlotsExplainedComparison_subtitle,
        icon: Icons.compare_arrows,
        category: 'Time Slots',
        order: 4,
        contents: [
          ManualContent(
            id: 'comparison_table',
            title: loc.docsTimeSlotsExplainedComparison_comparisonTable_title,
            content: loc.docsTimeSlotsExplainedComparison_comparisonTable_content,
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'comparison_visual',
            title: loc.docsTimeSlotsExplainedComparison_comparisonVisual_title,
            content: loc.docsTimeSlotsExplainedComparison_comparisonVisual_content,
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'comparison_example',
            title: loc.docsTimeSlotsExplainedComparison_comparisonExample_title,
            content: loc.docsTimeSlotsExplainedComparison_comparisonExample_content,
            type: ManualContentType.text,
          ),
        ],
      ),
      ManualSection(
        id: 'group_time',
        title: loc.docsTimeSlotsExplainedGroupTime_title,
        subtitle: loc.docsTimeSlotsExplainedGroupTime_subtitle,
        icon: Icons.group,
        category: 'Time Slots',
        order: 5,
        contents: [
          ManualContent(
            id: 'group_time_intro',
            title: loc.docsTimeSlotsExplainedGroupTime_groupTimeIntro_title,
            content: loc.docsTimeSlotsExplainedGroupTime_groupTimeIntro_content,
            numberPrefix: '1',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsTimeSlotsExplainedGroupTime_groupTimeIntro_bullet1,
              loc.docsTimeSlotsExplainedGroupTime_groupTimeIntro_bullet2,
              loc.docsTimeSlotsExplainedGroupTime_groupTimeIntro_bullet3,
              loc.docsTimeSlotsExplainedGroupTime_groupTimeIntro_bullet4,
            ],
          ),
          ManualContent(
            id: 'group_time_same_worker',
            title: loc.docsTimeSlotsExplainedGroupTime_groupTimeSameWorker_title,
            content: loc.docsTimeSlotsExplainedGroupTime_groupTimeSameWorker_content,
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'group_time_diff_workers',
            title: loc.docsTimeSlotsExplainedGroupTime_groupTimeDiffWorkers_title,
            content: loc.docsTimeSlotsExplainedGroupTime_groupTimeDiffWorkers_content,
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'group_time_combined',
            title: loc.docsTimeSlotsExplainedGroupTime_groupTimeCombined_title,
            content: loc.docsTimeSlotsExplainedGroupTime_groupTimeCombined_content,
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'group_time_tip',
            title: '',
            content: loc.docsTimeSlotsExplainedGroupTime_groupTimeTip_content,
            type: ManualContentType.tip,
          ),
        ],
      ),
      ManualSection(
        id: 'buffer_time',
        title: loc.docsTimeSlotsExplainedBufferTime_title,
        subtitle: loc.docsTimeSlotsExplainedBufferTime_subtitle,
        icon: Icons.timer,
        category: 'Time Slots',
        order: 6,
        contents: [
          ManualContent(
            id: 'buffer_explained',
            title: loc.docsTimeSlotsExplainedBufferTime_bufferExplained_title,
            content: loc.docsTimeSlotsExplainedBufferTime_bufferExplained_content,
            numberPrefix: '1',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'buffer_purpose',
            title: loc.docsTimeSlotsExplainedBufferTime_bufferPurpose_title,
            content: loc.docsTimeSlotsExplainedBufferTime_bufferPurpose_content,
            numberPrefix: '2',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsTimeSlotsExplainedBufferTime_bufferPurpose_bullet1,
              loc.docsTimeSlotsExplainedBufferTime_bufferPurpose_bullet2,
              loc.docsTimeSlotsExplainedBufferTime_bufferPurpose_bullet3,
              loc.docsTimeSlotsExplainedBufferTime_bufferPurpose_bullet4,
            ],
          ),
          ManualContent(
            id: 'buffer_visibility',
            title: loc.docsTimeSlotsExplainedBufferTime_bufferVisibility_title,
            content: loc.docsTimeSlotsExplainedBufferTime_bufferVisibility_content,
            type: ManualContentType.important,
          ),
          ManualContent(
            id: 'buffer_example',
            title: loc.docsTimeSlotsExplainedBufferTime_bufferExample_title,
            content: loc.docsTimeSlotsExplainedBufferTime_bufferExample_content,
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'buffer_fairness',
            title: '',
            content: loc.docsTimeSlotsExplainedBufferTime_bufferFairness_content,
            type: ManualContentType.tip,
          ),
        ],
      ),
      ManualSection(
        id: 'time_faq',
        title: loc.docsTimeSlotsExplainedTimeFaq_title,
        subtitle: loc.docsTimeSlotsExplainedTimeFaq_subtitle,
        icon: Icons.help,
        category: 'Time Slots',
        order: 7,
        contents: [
          ManualContent(
            id: 'time_faq_1',
            title: loc.docsTimeSlotsExplainedTimeFaq_timeFaq1_title,
            content: loc.docsTimeSlotsExplainedTimeFaq_timeFaq1_content,
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'time_faq_2',
            title: loc.docsTimeSlotsExplainedTimeFaq_timeFaq2_title,
            content: loc.docsTimeSlotsExplainedTimeFaq_timeFaq2_content,
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'time_faq_3',
            title: loc.docsTimeSlotsExplainedTimeFaq_timeFaq3_title,
            content: loc.docsTimeSlotsExplainedTimeFaq_timeFaq3_content,
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'time_faq_4',
            title: loc.docsTimeSlotsExplainedTimeFaq_timeFaq4_title,
            content: loc.docsTimeSlotsExplainedTimeFaq_timeFaq4_content,
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
        id: 'faq_time_regular_vs_combined',
        question: loc.docsTimeSlotsExplainedFaq_regularVsCombined_Q,
        answer: loc.docsTimeSlotsExplainedFaq_regularVsCombined_A,
        category: 'Time Slots',
        order: 1,
      ),
      FAQModel(
        id: 'faq_time_combined_not_showing',
        question: loc.docsTimeSlotsExplainedFaq_combinedNotShowing_Q,
        answer: loc.docsTimeSlotsExplainedFaq_combinedNotShowing_A,
        category: 'Time Slots',
        order: 2,
      ),
      FAQModel(
        id: 'faq_time_buffer',
        question: loc.docsTimeSlotsExplainedFaq_buffer_Q,
        answer: loc.docsTimeSlotsExplainedFaq_buffer_A,
        category: 'Time Slots',
        order: 3,
      ),
      FAQModel(
        id: 'faq_time_duration',
        question: loc.docsTimeSlotsExplainedFaq_duration_Q,
        answer: loc.docsTimeSlotsExplainedFaq_duration_A,
        category: 'Time Slots',
        order: 4,
      ),
      FAQModel(
        id: 'faq_time_group',
        question: loc.docsTimeSlotsExplainedFaq_group_Q,
        answer: loc.docsTimeSlotsExplainedFaq_group_A,
        category: 'Time Slots',
        order: 5,
      ),
      FAQModel(
        id: 'faq_time_am_pm',
        question: loc.docsTimeSlotsExplainedFaq_amPm_Q,
        answer: loc.docsTimeSlotsExplainedFaq_amPm_A,
        category: 'Time Slots',
        order: 6,
      ),
      FAQModel(
        id: 'faq_time_last_slot',
        question: loc.docsTimeSlotsExplainedFaq_lastSlot_Q,
        answer: loc.docsTimeSlotsExplainedFaq_lastSlot_A,
        category: 'Time Slots',
        order: 7,
      ),
      FAQModel(
        id: 'faq_time_change',
        question: loc.docsTimeSlotsExplainedFaq_change_Q,
        answer: loc.docsTimeSlotsExplainedFaq_change_A,
        category: 'Time Slots',
        order: 8,
      ),
      FAQModel(
        id: 'faq_time_slot_not_appearing',
        question: loc.docsTimeSlotsExplainedFaq_slotDisappeared_Q,
        answer: loc.docsTimeSlotsExplainedFaq_slotDisappeared_A,
        category: 'Time Slots',
        order: 9,
      ),
      FAQModel(
        id: 'faq_time_workers',
        question: loc.docsTimeSlotsExplainedFaq_workers_Q,
        answer: loc.docsTimeSlotsExplainedFaq_workers_A,
        category: 'Time Slots',
        order: 10,
      ),
    ];
  }
}
