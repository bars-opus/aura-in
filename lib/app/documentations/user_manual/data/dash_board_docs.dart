import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class DashboardDocs implements DocumentationModule {
  @override
  String getTitle(BuildContext context) => 'Manage Your Business Dashboard';

  @override
  String get id => 'dashboard';

  @override
  String getSubtitle(BuildContext context) =>
      'Track performance, manage clients, and grow your business';

  @override
  IconData get icon => Icons.dashboard;

  @override
  int get order => 4;

  @override
  List<ManualSection> getSections(BuildContext context) => [
    // Section 1: Overview
    ManualSection(
      id: 'dashboard_overview',
      title: 'Your Dashboard Overview',
      subtitle: 'Everything you need to run your business',
      icon: Icons.info_outline,
      category: 'Dashboard',
      order: 1,
      contents: [
        ManualContent(
          id: 'dashboard_welcome',
          title: 'Welcome to Your Dashboard',
          content:
              'Your dashboard is command center for your business. View your earnings, understand your clients, track performance, and manage your team all in one place.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'dashboard_tabs',
          title: 'Dashboard Tabs',
          content:
              'Navigate between tabs to access different areas of your business:',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Revenue - Your wallet, earnings, and payouts',
            'Analytics - Performance metrics and booking trends',
            'Insights - Smart recommendations and patterns',
            'Tools - Additional features (separate documentation)',
            'Clients - Your customer list and interactions',
            'Staff - Your team members (shops only, not freelancers)',
          ],
        ),
      ],
    ),

    // Section 2: Revenue Tab
    ManualSection(
      id: 'revenue_tab',
      title: 'Revenue Tab - Your Money',
      subtitle: 'Track earnings and manage payments',
      icon: Icons.account_balance_wallet,
      category: 'Dashboard Tabs',
      order: 2,
      contents: [
        ManualContent(
          id: 'revenue_overview',
          title: 'What\'s in Revenue?',
          content:
              'The Revenue tab shows your wallet - how much money you\'ve earned, how much is available, and how to withdraw it.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'wallet_balance',
          title: 'Wallet Balance',
          content:
              'See your current balance: how much money you\'ve earned total and how much is available to withdraw right now.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'transactions_history',
          title: 'Transaction History',
          content:
              'View all your transactions: payments received, fees, refunds, and withdrawals. Scroll to see older transactions.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'withdraw_funds',
          title: 'Withdraw Your Money',
          content:
              'Transfer earnings to your bank account. You can withdraw anytime (subject to minimum amount requirements and processing fees).',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'payment_setup',
          title: 'Payment Setup',
          content:
              'Before you can withdraw, you need to set up a payment method. This is a one-time setup - add your bank details securely.',
          numberPrefix: '5',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 3: Analytics Tab
    ManualSection(
      id: 'analytics_tab',
      title: 'Analytics Tab - Your Performance',
      subtitle: 'Understand your business metrics',
      icon: Icons.show_chart,
      category: 'Dashboard Tabs',
      order: 3,
      contents: [
        ManualContent(
          id: 'analytics_overview',
          title: 'What\'s in Analytics?',
          content:
              'Analytics shows how your business is performing: revenue trends, top services, top workers, and booking patterns over time.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'revenue_trends',
          title: 'Revenue Trends',
          content:
              'See your revenue broken down by quarter or month. Identify when you make the most money. Compare quarter-to-quarter growth.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'top_services',
          title: 'Top Services',
          content:
              'Which services make you the most money? Analytics shows your best-performing services ranked by revenue.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'top_workers',
          title: 'Top Performers',
          content:
              'See which team members generate the most revenue. Use this to understand who\'s your top performer.',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'analytics_use_case',
          title: '',
          content:
              'Use analytics to make business decisions: What services should you promote? Who should you give more bookings? When is your peak season?',
          type: ManualContentType.tip,
        ),
      ],
    ),

    // Section 4: Insights Tab
    ManualSection(
      id: 'insights_tab',
      title: 'Insights Tab - Smart Recommendations',
      subtitle: 'Get AI-powered suggestions',
      icon: Icons.lightbulb,
      category: 'Dashboard Tabs',
      order: 4,
      contents: [
        ManualContent(
          id: 'insights_overview',
          title: 'What\'s in Insights?',
          content:
              'Insights uses AI to give you smart recommendations about your business. It shows patterns and alerts about things that need attention.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'alerts',
          title: 'Alerts & Recommendations',
          content:
              'Get alerts about important things: slow periods, pricing opportunities, customer issues, or time slots you\'re missing bookings on.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'heatmap',
          title: 'Booking Heatmap',
          content:
              'Visual heat map showing when you get the most bookings. Darker areas = more bookings. Lighter areas = slower times. Helps you understand demand patterns.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'insights_action',
          title: 'Act on Insights',
          content:
              'Use insights to improve: increase prices during busy times, run promotions during slow times, or add more services customers want.',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'insights_benefit',
          title: '',
          content:
              'Insights help you make data-driven decisions. Don\'t ignore the recommendations - they\'re based on your real business patterns.',
          type: ManualContentType.important,
        ),
      ],
    ),

    // Section 5: Clients Tab
    ManualSection(
      id: 'clients_tab',
      title: 'Clients Tab - Manage Relationships',
      subtitle: 'View and understand your customers',
      icon: Icons.people,
      category: 'Dashboard Tabs',
      order: 5,
      contents: [
        ManualContent(
          id: 'clients_overview',
          title: 'Your Client List',
          content:
              'See all customers who have booked with you. View their contact info, booking history, and feedback.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'client_profile',
          title: 'Client Information',
          content:
              'For each client: their name, phone, email, total bookings, average rating, and when they last booked.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'search_clients',
          title: 'Search Clients',
          content:
              'Quickly find a client by typing their name or phone number. Useful for when a regular customer calls.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'client_insights',
          title: 'Learn About Clients',
          content:
              'Understand who your best clients are. Who books most frequently? Who spends the most? Use this to provide better service.',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 6: Staff Tab (Shops Only)
    ManualSection(
      id: 'staff_tab',
      title: 'Staff Tab - Manage Your Team',
      subtitle: 'For shops only (not freelancers)',
      icon: Icons.person_add,
      category: 'Dashboard Tabs',
      order: 6,
      contents: [
        ManualContent(
          id: 'staff_overview',
          title: 'About the Staff Tab',
          content:
              'The Staff tab is only for shop owners with team members. Freelancers work alone, so they don\'t have a Staff tab.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'staff_management',
          title: 'What Can You Do?',
          content:
              'In Staff tab: view all your workers, see their performance, check attendance records, and manage team assignments.',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'View all team members',
            'See who\'s working today',
            'Check attendance history',
            'View worker performance metrics',
            'Manage service assignments',
          ],
        ),
        ManualContent(
          id: 'worker_performance',
          title: 'Worker Performance',
          content:
              'See which workers are your top performers - how many bookings, revenue generated, and customer ratings.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'attendance_tracking',
          title: 'Attendance',
          content:
              'Track when workers are present. Mark daily attendance and track no-shows or late arrivals.',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 7: Tips
    ManualSection(
      id: 'dashboard_tips',
      title: 'Dashboard Tips & Best Practices',
      subtitle: 'Make the most of your dashboard',
      icon: Icons.tips_and_updates,
      category: 'Dashboard Tips',
      order: 7,
      contents: [
        ManualContent(
          id: 'tip_regular_check',
          title: 'Check Regularly',
          content:
              'Visit your dashboard daily to: check new bookings, monitor earnings, respond to clients, and review alerts.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'tip_use_analytics',
          title: 'Use Analytics Strategically',
          content:
              'Weekly: review analytics to spot trends. Identify slow periods and plan promotions. Recognize top services and boost them.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'tip_act_on_insights',
          title: 'Act on Insights',
          content:
              'Monthly: review insights and alerts. Make one improvement based on what you see - pricing change, new service, or promotion.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'tip_track_clients',
          title: 'Know Your Best Clients',
          content:
              'Note your best clients. Give them special attention, remember their preferences, offer them loyalty rewards.',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'dashboard_importance',
          title: '',
          content:
              'Your dashboard is your business intelligence tool. The more you use it, the better decisions you make. Data-driven businesses grow faster.',
          type: ManualContentType.important,
        ),
      ],
    ),

    // Section 8: FAQ
    ManualSection(
      id: 'dashboard_faq',
      title: 'Common Questions',
      subtitle: 'Get help with your dashboard',
      icon: Icons.help_outline,
      category: 'Help',
      order: 8,
      contents: [
        ManualContent(
          id: 'faq_why_dashboard',
          title: 'Why should I use the dashboard?',
          content:
              'The dashboard helps you understand your business: how much money you make, what\'s popular, and who your best clients are. This helps you make better decisions.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_revenue_delay',
          title: 'Why is my revenue not showing immediately?',
          content:
              'Revenue updates after a booking is completed and payment is confirmed. It takes a few moments to process and appear.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_analytics_data',
          title: 'How far back does analytics show?',
          content:
              'Analytics typically shows the last 12 months of data. This gives you a full year view of patterns and trends.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_insights_accuracy',
          title: 'Are the insights accurate?',
          content:
              'Insights are based on your real data and AI analysis. They get more accurate the more data you have (the longer your business has been running).',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_withdraw_time',
          title: 'How long does withdrawal take?',
          content:
              'Withdrawals typically process within 2-5 business days depending on your bank. Check the withdrawal screen for estimated timing.',
          numberPrefix: '5',
          type: ManualContentType.text,
        ),
      ],
    ),
  ];

  @override
  List<FAQModel> getFAQs(BuildContext context) {
    return [
      FAQModel(
        id: 'faq_dashboard_1',
        question: 'How often should I check my dashboard?',
        answer:
            'Daily to check new bookings and messages. Weekly to review analytics and identify trends. Monthly to act on insights.',
        category: 'Usage',
        order: 1,
      ),
      FAQModel(
        id: 'faq_dashboard_2',
        question: 'What\'s the difference between Analytics and Insights?',
        answer:
            'Analytics shows your historical performance data (revenue, bookings, top services). Insights provides AI recommendations based on that data.',
        category: 'Features',
        order: 2,
      ),
      FAQModel(
        id: 'faq_dashboard_3',
        question: 'Can I export my dashboard data?',
        answer:
            'Some dashboard views support exporting. Look for export buttons in Analytics and Reports sections to download data.',
        category: 'Features',
        order: 3,
      ),
      FAQModel(
        id: 'faq_dashboard_4',
        question: 'Do freelancers see the same dashboard as shops?',
        answer:
            'Mostly yes - both see Revenue, Analytics, Insights, Clients, and Tools. Only shops see the Staff tab.',
        category: 'Setup',
        order: 4,
      ),
      FAQModel(
        id: 'faq_dashboard_5',
        question: 'What if I don\'t understand the insights?',
        answer:
            'Insights come with explanations. Hover or tap on any insight to get more context about what it means and why it matters.',
        category: 'Help',
        order: 5,
      ),
      FAQModel(
        id: 'faq_dashboard_6',
        question: 'Can I share my dashboard with my team?',
        answer:
            'Workers can see their own performance in the Staff tab, but full dashboard access is owner-only for security reasons.',
        category: 'Setup',
        order: 6,
      ),
    ];
  }
}
