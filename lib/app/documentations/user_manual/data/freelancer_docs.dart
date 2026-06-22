import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class FreelancerDocs implements DocumentationModule {
  @override
  int get order => 2;

  @override
  String getTitle(BuildContext context) => 'Become a Freelancer';

  @override
  String get id => 'become_freelancer';

  @override
  String getSubtitle(BuildContext context) =>
      'Offer your services on demand and grow your client base';

  @override
  IconData get icon => Icons.person_add;

  @override
  List<ManualSection> getSections(BuildContext context) => [
    // Section 1: Overview
    ManualSection(
      id: 'freelancer_overview',
      title: 'Getting Started as a Freelancer',
      subtitle: 'Learn how to set up your profile and start taking clients',
      icon: Icons.info_outline,
      category: 'Freelancer Setup',
      order: 1,
      contents: [
        ManualContent(
          id: 'freelancer_welcome',
          title: 'Welcome to Freelancing',
          content:
              'As a freelancer on NanoEmbryo, you offer services directly to customers in your area. Unlike a traditional shop, you work from your own location and can travel to meet clients. Set up your profile in just a few minutes and start accepting bookings.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'freelancer_vs_shop',
          title: 'Freelancer vs Shop: What\'s the Difference?',
          content: 'Here\'s how freelancing works:',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'You work independently - no fixed storefront required',
            'You can travel to clients within your chosen radius',
            'You set your own hours and availability',
            'You manage your own schedule and clients',
            'Customers book you directly for services',
          ],
        ),
        ManualContent(
          id: 'freelancer_requirements',
          title: 'What You\'ll Need',
          content:
              'To start as a freelancer, you need: your name, a profession type (hairdresser, massage therapist, etc.), location, travel radius, services, and your working hours. A professional photo helps customers trust you.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 2: Profile
    ManualSection(
      id: 'profile_setup',
      title: 'Create Your Profile',
      subtitle: 'Tell customers who you are',
      icon: Icons.person,
      category: 'Freelancer Setup',
      order: 2,
      contents: [
        ManualContent(
          id: 'profile_photo',
          title: 'Add Your Profile Photo',
          content:
              'A professional headshot or portrait builds trust with customers. Use a clear, well-lit photo of yourself. Customers want to know who they\'re booking with.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'your_name',
          title: 'Your Name',
          content:
              'Enter your full name exactly as you want customers to see it. Be professional and clear.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'profession_type',
          title: 'Choose Your Profession',
          content:
              'Select what you do. Examples: Hairdresser, Massage Therapist, Makeup Artist, Barber, Esthetician, or other specialized services.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'bio_description',
          title: 'Write Your Bio',
          content:
              'Write a short description about yourself and your experience (50-150 words). Tell customers what makes you unique. Example: "I specialize in natural hair care with 5 years of experience. Certified in color and styling."',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'terms_guidelines',
          title: 'Add Your Guidelines',
          content:
              'Share any important rules or policies. Examples: age restrictions, cancellation policy, health requirements, or preparation instructions.',
          numberPrefix: '5',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 3: Service Area
    ManualSection(
      id: 'service_area',
      title: 'Set Your Service Area',
      subtitle: 'Define where you work',
      icon: Icons.location_on,
      category: 'Freelancer Setup',
      order: 3,
      contents: [
        ManualContent(
          id: 'base_location',
          title: 'Set Your Base Location',
          content:
              'This is where you normally work from. Customers within your travel radius can book you. You can either pin on the map or search for your address.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'travel_radius',
          title: 'Travel Radius',
          content:
              'How far are you willing to travel to meet clients? Set this in kilometers. Example: "5 km radius" means clients up to 5 km from your location can book you.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'mobile_vs_fixed',
          title: 'Mobile or Fixed Location?',
          content:
              'Choose whether you travel to clients or meet them at one location. If you\'re mobile, customers can request you at their home or office.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'service_address_tip',
          title: '',
          content:
              'Customers will see your travel radius when searching. Be accurate so they know if you can serve their area.',
          type: ManualContentType.tip,
        ),
      ],
    ),

    // Section 4: Tools & Skills
    ManualSection(
      id: 'tools_setup',
      title: 'List Your Tools & Equipment',
      subtitle: 'Show customers what you bring',
      icon: Icons.build,
      category: 'Freelancer Setup',
      order: 4,
      contents: [
        ManualContent(
          id: 'tools_intro',
          title: 'What Are Tools?',
          content:
              'Tools are the equipment or skills you have. They help customers understand what you can do and what to expect.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'tool_examples',
          title: 'Example Tools',
          content: 'For different professions:',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Hairdresser: Blow dryer, flat iron, curling iron, scissors',
            'Massage Therapist: Massage table, hot stones, aromatherapy oils',
            'Makeup Artist: Makeup brushes, airbrush, LED light',
            'Barber: Electric clippers, straight razor, styling cream',
          ],
        ),
        ManualContent(
          id: 'tool_selection',
          title: 'Selecting Tools',
          content:
              'Choose all the tools and equipment you use professionally. Customers want to know you have the right equipment for their service.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 5: Services & Pricing
    ManualSection(
      id: 'services_setup',
      title: 'Services & Pricing',
      subtitle: 'Tell customers what you offer',
      icon: Icons.inventory_2,
      category: 'Freelancer Setup',
      order: 5,
      contents: [
        ManualContent(
          id: 'service_basics',
          title: 'Add Your Services',
          content:
              'Each service is something customers can book. Examples: "Haircut", "Full Body Massage", "Makeup Application".',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'service_info',
          title: 'For Each Service, Add:',
          content: 'You need:',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Service name - what you\'re offering',
            'Description - what it includes',
            'Price - how much it costs',
            'Duration - how long it takes (30 min, 1 hour, etc.)',
          ],
        ),
        ManualContent(
          id: 'pricing_strategy',
          title: 'Pricing Tips',
          content:
              'Research what others charge for similar services in your area. Price competitively but fairly for your experience level.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'duration_importance',
          title: '',
          content:
              'Set duration accurately. This is how long you block out for each booking. Customers rely on this time.',
          type: ManualContentType.important,
        ),
      ],
    ),

    // Section 6: Working Hours
    ManualSection(
      id: 'hours_setup',
      title: 'Set Your Availability',
      subtitle: 'When you\'re available to work',
      icon: Icons.schedule,
      category: 'Freelancer Setup',
      order: 6,
      contents: [
        ManualContent(
          id: 'hours_intro',
          title: 'Working Hours',
          content:
              'Customers can only book during times you mark as available. Set your hours for each day of the week.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'hours_example',
          title: 'Example Schedule',
          content:
              'Monday - Friday: 9:00 AM to 6:00 PM\nSaturday: 10:00 AM to 4:00 PM\nSunday: Closed',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'flexible_hours',
          title: 'Be Flexible or Strict?',
          content:
              'You decide. If you want consistent hours, set them. If you prefer flexibility, you can adjust daily as needed.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'block_time',
          title: '',
          content:
              'When a customer books you, that time is blocked on your calendar. Set hours wisely to avoid conflicts.',
          type: ManualContentType.tip,
        ),
      ],
    ),

    // Section 7: Contact & Credentials
    ManualSection(
      id: 'contact_credentials',
      title: 'Contact Info & Credentials',
      subtitle: 'Help customers reach you and build trust',
      icon: Icons.verified,
      category: 'Freelancer Setup',
      order: 7,
      contents: [
        ManualContent(
          id: 'contact_methods',
          title: 'Add Contact Information',
          content: 'Provide ways customers can reach you:',
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Phone number - for direct calls',
            'Email - for messages',
            'WhatsApp - for quick chat',
            'Website - if you have one',
          ],
        ),
        ManualContent(
          id: 'social_profiles',
          title: 'Link Social Media',
          content:
              'Connect your social accounts (Instagram, Facebook, TikTok). Customers can view your work and portfolio.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'certifications',
          title: 'Upload Certifications',
          content:
              'Upload documents that build trust: licenses, certifications, insurance, training certificates. Customers love to see proof of your qualifications.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'credentials_impact',
          title: '',
          content:
              'Freelancers with certifications and social proof get more bookings. Take time to showcase your expertise.',
          type: ManualContentType.important,
        ),
      ],
    ),

    // Section 8: Portfolio
    ManualSection(
      id: 'portfolio_setup',
      title: 'Show Your Work',
      subtitle: 'Upload photos of your best work',
      icon: Icons.photo,
      category: 'Freelancer Setup',
      order: 8,
      contents: [
        ManualContent(
          id: 'portfolio_importance',
          title: 'Why Photos Matter',
          content:
              'High-quality photos of your work help customers see your style and skill level. It\'s the best way to attract clients who want your specific style.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'what_to_upload',
          title: 'What to Upload',
          content: 'Show your best work:',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Before and after photos of services',
            'Different styles you can do',
            'Close-up photos of quality work',
            'Real client photos (with permission)',
          ],
        ),
        ManualContent(
          id: 'photo_quality',
          title: 'Photo Quality Tips',
          content:
              'Use clear, well-lit photos. Show real work, not pictures from the internet. Customers want to see what they\'re actually getting.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'portfolio_impact',
          title: '',
          content:
              'Freelancers with a strong portfolio get 3-5x more bookings. Invest time in quality photos.',
          type: ManualContentType.important,
        ),
      ],
    ),

    // Section 9: Launch
    ManualSection(
      id: 'launch',
      title: 'Review & Go Live',
      subtitle: 'Publish your profile and start taking bookings',
      icon: Icons.publish,
      category: 'Freelancer Setup',
      order: 9,
      contents: [
        ManualContent(
          id: 'review_checklist',
          title: 'Before You Launch',
          content: 'Review everything one final time:',
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Profile photo is clear and professional',
            'Name and profession are correct',
            'Bio clearly describes what you do',
            'Location and travel radius are set',
            'At least one service is added with pricing',
            'Working hours are correct',
            'Contact information is up to date',
            'At least 3-5 portfolio photos uploaded',
          ],
        ),
        ManualContent(
          id: 'publish_action',
          title: 'Publish Your Profile',
          content:
              'Once everything looks good, click "Go Live" or "Publish". Your profile will appear in customer searches immediately.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'after_launch',
          title: 'After Going Live',
          content:
              'You can edit everything anytime. Changes take effect immediately. Keep updating your portfolio as you complete more work.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'launch_requirements',
          title: '',
          content:
              'You need at least one service, correct location, and working hours to go live. Otherwise customers can\'t book you.',
          type: ManualContentType.important,
        ),
      ],
    ),

    // Section 10: FAQ
    ManualSection(
      id: 'freelancer_faq',
      title: 'Common Questions',
      subtitle: 'Get help with setup',
      icon: Icons.help_outline,
      category: 'Help',
      order: 10,
      contents: [
        ManualContent(
          id: 'faq_time',
          title: 'How long does setup take?',
          content:
              'Most freelancers set up in 5-10 minutes. The minimum is: name, profession, location, one service, and hours.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_solo',
          title: 'Do I need a team?',
          content:
              'No. As a freelancer, you work alone. You don\'t manage workers like a shop does. Everything is just you.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_edit_after',
          title: 'Can I change things after publishing?',
          content:
              'Yes! You can edit your profile, services, hours, or anything else anytime. Changes take effect immediately.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_travel',
          title: 'What if I don\'t travel?',
          content:
              'You can set travel radius to 0 and say you\'re not mobile. Customers will come to your fixed location.',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_change_services',
          title: 'Can I add more services later?',
          content:
              'Yes. You can add or remove services anytime. Add new services as you develop new skills.',
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
        id: 'faq_freelancer_1',
        question: 'What\'s the difference between a freelancer and a shop owner?',
        answer:
            'A freelancer works independently, often traveling to clients. A shop owner has a fixed location. Freelancers are more flexible, shops are more established.',
        category: 'Getting Started',
        order: 1,
      ),
      FAQModel(
        id: 'faq_freelancer_2',
        question: 'How do customers find me?',
        answer:
            'Your profile appears in customer searches based on your location, profession, and services. A good photo and portfolio help you get found more.',
        category: 'Getting Started',
        order: 2,
      ),
      FAQModel(
        id: 'faq_freelancer_3',
        question: 'Can I work for multiple platforms?',
        answer:
            'Yes! You can set up profiles on multiple platforms. Just make sure your availability matches across all platforms.',
        category: 'Management',
        order: 3,
      ),
      FAQModel(
        id: 'faq_freelancer_4',
        question: 'How do payments work?',
        answer:
            'Customers pay through the app. You receive payment to your account after the service is completed.',
        category: 'Payments',
        order: 4,
      ),
      FAQModel(
        id: 'faq_freelancer_5',
        question: 'What if I need to cancel a booking?',
        answer:
            'You can cancel before the booking time. Contact support if you need to reschedule. Be fair to customers - frequent cancellations hurt your rating.',
        category: 'Bookings',
        order: 5,
      ),
      FAQModel(
        id: 'faq_freelancer_6',
        question: 'How do ratings work?',
        answer:
            'After each booking, customers rate you (1-5 stars) and leave reviews. A high rating helps you get more bookings.',
        category: 'Management',
        order: 6,
      ),
    ];
  }
}
