import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class CreateShopDocs implements DocumentationModule {
  @override
  String getTitle(BuildContext context) => 'Create Your Shop';

  @override
  String get id => 'create_shop';

  @override
  String getSubtitle(BuildContext context) =>
      'Set up your business and start taking bookings in minutes';

  @override
  IconData get icon => Icons.store;

  @override
  int get order => 1;

  @override
  List<ManualSection> getSections(BuildContext context) => [
    // Section 1: Overview
    ManualSection(
      id: 'shop_overview',
      title: 'Getting Started with Your Shop',
      subtitle: 'Learn the basics of creating your business profile',
      icon: Icons.info_outline,
      category: 'Shop Setup',
      order: 1,
      contents: [
        ManualContent(
          id: 'welcome_intro',
          title: 'Welcome to Your Shop Dashboard',
          content:
              'Creating a shop on NanoEmbryo takes just a few minutes. You\'ll add your business information, set your services and working hours, and you\'re ready to accept bookings from customers.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'setup_steps_overview',
          title: 'What You\'ll Set Up',
          content: 'Here\'s what you\'ll do when creating your shop:',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Add your shop name and logo',
            'Write a brief description of your business',
            'Choose your shop type (salon, barber, spa, etc.)',
            'Set your location and service address',
            'Add your working hours',
            'Create services you offer with pricing',
            'Add contact information',
            'Upload photos and documents',
          ],
        ),
        ManualContent(
          id: 'save_progress_tip',
          title: '',
          content:
              'Your work is saved automatically as you fill in the form. You can come back anytime to continue editing or publish when ready.',
          type: ManualContentType.tip,
        ),
      ],
    ),

    // Section 2: Basic Information
    ManualSection(
      id: 'basic_info',
      title: 'Basic Shop Information',
      subtitle: 'Tell customers who you are',
      icon: Icons.business,
      category: 'Shop Setup',
      order: 2,
      contents: [
        ManualContent(
          id: 'logo_section',
          title: 'Add Your Shop Logo',
          content:
              'Your logo is the first thing customers see. It should clearly represent your business. Use a square image (e.g., 500x500 pixels) for best results.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'shop_name',
          title: 'Shop Name',
          content:
              'Enter your business name exactly as you want customers to see it. Be clear and professional. Example: "Marie\'s Hair Studio" or "City Barbershop"',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'shop_type',
          title: 'Choose Your Shop Type',
          content:
              'Select the type of business you run. This helps customers find you in search. Available types include:',
          numberPrefix: '3',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Hair Salon - for haircuts, coloring, styling',
            'Barber Shop - for men\'s haircuts and grooming',
            'Spa - for massages, facials, wellness services',
            'Beauty Services - makeup, nails, and other beauty treatments',
            'Other Services - for businesses not listed above',
          ],
        ),
        ManualContent(
          id: 'description',
          title: 'Shop Description',
          content:
              'Write a short description about your shop (100-200 words). Tell customers what makes you special. Example: "We specialize in natural hair care and modern styling for all hair types. Family-friendly environment with professional stylists."',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'terms_info',
          title: 'Terms & Conditions',
          content:
              'Add any important rules customers should know. Examples: cancellation policy, age restrictions, deposit requirements, dress code, or health restrictions.',
          numberPrefix: '5',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 3: Location
    ManualSection(
      id: 'location_setup',
      title: 'Location & Hours',
      subtitle: 'Where customers can find you and when you work',
      icon: Icons.location_on,
      category: 'Shop Setup',
      order: 3,
      contents: [
        ManualContent(
          id: 'location_intro',
          title: 'Set Your Location',
          content:
              'Customers need to know where to find you. You can either:',
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Pin your location on the map (drag the marker)',
            'Search for your address in the search box',
            'Enter your street address manually',
          ],
        ),
        ManualContent(
          id: 'location_accuracy',
          title: '',
          content:
              'Make sure your location is accurate. Customers use it to find you and calculate travel time.',
          type: ManualContentType.important,
        ),
        ManualContent(
          id: 'working_hours',
          title: 'Set Your Working Hours',
          content:
              'Customers can only book times when you\'re open. Set your hours for each day of the week.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'hours_example',
          title: 'Example Hours',
          content: 'Monday - Friday: 9:00 AM to 6:00 PM\nSaturday: 9:00 AM to 5:00 PM\nSunday: Closed',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'hours_tip',
          title: '',
          content:
              'You can set different hours for different days, or mark any day as closed when you\'re not working.',
          type: ManualContentType.tip,
        ),
      ],
    ),

    // Section 4: Services
    ManualSection(
      id: 'services_setup',
      title: 'Services & Pricing',
      subtitle: 'Tell customers what you offer and how much it costs',
      icon: Icons.inventory_2,
      category: 'Shop Setup',
      order: 4,
      contents: [
        ManualContent(
          id: 'services_intro',
          title: 'Add Your Services',
          content:
              'Each service is something customers can book and pay for. Examples: "Haircut", "Hair Color", "Massage", "Facial Treatment".',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'service_details',
          title: 'For Each Service, Add:',
          content: 'When you create a service, you need to provide:',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Service name - what you\'re offering (e.g., "Haircut")',
            'Description - brief details about what\'s included',
            'Price - how much the service costs',
            'Duration - how long it takes (e.g., 30 minutes, 1 hour)',
            'Category - what type of service it is',
          ],
        ),
        ManualContent(
          id: 'pricing_tip',
          title: 'Pricing Tip',
          content:
              'Be clear with your prices. You can offer different service tiers (e.g., "Basic Haircut" vs "Premium Haircut") at different prices.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'duration_important',
          title: '',
          content:
              'Set the duration accurately. Customers book based on this time, and staff need to know how long to reserve.',
          type: ManualContentType.important,
        ),
      ],
    ),

    // Section 5: Team & Workers
    ManualSection(
      id: 'team_setup',
      title: 'Manage Your Team',
      subtitle: 'Add staff members and assign them to services',
      icon: Icons.people,
      category: 'Shop Setup',
      order: 5,
      contents: [
        ManualContent(
          id: 'workers_intro',
          title: 'Add Your Staff',
          content:
              'If you have team members working at your shop, you can add them here. This helps you manage who is available for bookings.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'add_worker',
          title: 'How to Add a Staff Member',
          content:
              'When you add a worker, you need:',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Their name',
            'Their phone number or email to send them an invitation',
            'Which services they can provide',
          ],
        ),
        ManualContent(
          id: 'worker_assignment',
          title: 'Assign Services to Workers',
          content:
              'You can decide which workers can do which services. For example, "John can do Haircuts and Beards" or "Sarah can do Hair Color and Treatments".',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'worker_invitation',
          title: '',
          content:
              'When you add a worker, they\'ll receive an invitation to join your team. They need to accept it to start taking bookings.',
          type: ManualContentType.tip,
        ),
      ],
    ),

    // Section 6: Photos & Documents
    ManualSection(
      id: 'media_setup',
      title: 'Photos & Documents',
      subtitle: 'Show your work and share important info',
      icon: Icons.photo,
      category: 'Shop Setup',
      order: 6,
      contents: [
        ManualContent(
          id: 'photos_intro',
          title: 'Upload Shop Photos',
          content:
              'High-quality photos help customers get excited about your business. Include photos of:',
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Your shop interior',
            'Your staff at work',
            'Before and after examples of your work',
            'Your reception area or waiting area',
          ],
        ),
        ManualContent(
          id: 'photo_tips',
          title: 'Photo Tips',
          content:
              'Use clear, well-lit photos. Avoid blurry or dark images. Show real work, not just pictures from the internet.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'documents',
          title: 'Upload Documents',
          content:
              'You can upload important documents like certifications, licenses, or health permits. Customers can view these to build trust.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'media_impact',
          title: '',
          content:
              'Shops with photos get more bookings. Take time to upload quality images of your work and space.',
          type: ManualContentType.important,
        ),
      ],
    ),

    // Section 7: Contact & Social
    ManualSection(
      id: 'contact_setup',
      title: 'Contact & Social Media',
      subtitle: 'Help customers reach you',
      icon: Icons.contact_mail,
      category: 'Shop Setup',
      order: 7,
      contents: [
        ManualContent(
          id: 'contact_info',
          title: 'Add Contact Information',
          content:
              'Add ways customers can reach you:',
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Phone number - customers can call for questions',
            'Email - customers can send messages',
            'Website - if you have one',
          ],
        ),
        ManualContent(
          id: 'social_media',
          title: 'Link Social Media',
          content:
              'Connect your social media accounts (Facebook, Instagram, TikTok, etc.). This helps customers:',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'See more of your work and updates',
            'Follow you for promotions and news',
            'Trust your business more',
          ],
        ),
        ManualContent(
          id: 'social_benefits',
          title: 'Why Social Links Matter',
          content:
              'Customers check social media to see your latest work and customer reviews. It builds confidence in your business.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 8: Publishing
    ManualSection(
      id: 'publish_launch',
      title: 'Review & Publish',
      subtitle: 'Make your shop live and visible to customers',
      icon: Icons.publish,
      category: 'Shop Setup',
      order: 8,
      contents: [
        ManualContent(
          id: 'review_before_publish',
          title: 'Before You Publish',
          content:
              'Review everything one more time:',
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Shop name and description are accurate',
            'Location is correct on the map',
            'Hours are correct for all days',
            'At least one service is added',
            'Contact information is correct',
            'Photo of your shop is uploaded',
          ],
        ),
        ManualContent(
          id: 'publish_action',
          title: 'Publish Your Shop',
          content:
              'Once everything looks good, click "Publish" or "Go Live". Your shop will appear in customer searches immediately.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'after_publish',
          title: 'After Publishing',
          content:
              'You can still edit everything after publishing. Changes take effect immediately, so don\'t worry if you want to adjust something later.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'publish_important',
          title: '',
          content:
              'You need at least one service and accurate location to publish. Otherwise customers can\'t book with you.',
          type: ManualContentType.important,
        ),
      ],
    ),

    // Section 9: Troubleshooting
    ManualSection(
      id: 'troubleshooting',
      title: 'Common Questions',
      subtitle: 'Get help with setup',
      icon: Icons.help_outline,
      category: 'Help',
      order: 9,
      contents: [
        ManualContent(
          id: 'cant_find_location',
          title: 'Can\'t Find My Location?',
          content:
              'If your address doesn\'t appear in the search:',
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Try typing just the street name first',
            'Manually drag the map marker to your location',
            'Enter your full address: Street, City, Postal Code',
          ],
        ),
        ManualContent(
          id: 'edit_published_shop',
          title: 'Can I Edit After Publishing?',
          content:
              'Yes! You can edit anything after publishing. Go to "My Shops" and click "Edit" to make changes. Updates happen immediately.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'add_workers_later',
          title: 'Do I Need to Add Workers Now?',
          content:
              'No, you can add workers anytime. If you\'re a solo business, you don\'t need to add anyone. You can add team members later when they join.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'change_hours',
          title: 'What if My Hours Change?',
          content:
              'You can update your hours anytime. Go to your shop settings and update the schedule. Changes are immediate.',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
      ],
    ),
  ];

  @override
  List<FAQModel> getFAQs(BuildContext context) {
    return [
      FAQModel(
        id: 'faq_shop_1',
        question: 'How long does it take to create a shop?',
        answer:
            'Most businesses can set up a shop in 5-15 minutes. You just need your business name, location, at least one service, and working hours.',
        category: 'Getting Started',
        order: 1,
      ),
      FAQModel(
        id: 'faq_shop_2',
        question: 'What do I need to start?',
        answer:
            'You need: your business name, location address, shop type, at least one service with pricing, and your working hours. A logo and photos are optional but recommended.',
        category: 'Getting Started',
        order: 2,
      ),
      FAQModel(
        id: 'faq_shop_3',
        question: 'Can I change things after publishing?',
        answer:
            'Yes! You can edit everything after your shop is live. Go to "My Shops", click on your shop, and click "Edit". All changes take effect immediately.',
        category: 'Management',
        order: 3,
      ),
      FAQModel(
        id: 'faq_shop_4',
        question: 'Do I need team members to start?',
        answer:
            'No. If you\'re a solo business, you can start immediately. You can add team members anytime from your shop settings.',
        category: 'Team',
        order: 4,
      ),
      FAQModel(
        id: 'faq_shop_5',
        question: 'How do I add photos after publishing?',
        answer:
            'Go to your shop settings and click "Media" or "Photos". You can add, remove, or replace photos anytime. Quality photos help you get more bookings.',
        category: 'Media',
        order: 5,
      ),
      FAQModel(
        id: 'faq_shop_6',
        question: 'What if I need to close my shop temporarily?',
        answer:
            'Go to your shop settings and set your hours as "Closed" for the days you\'re not available. Customers won\'t be able to book on those days.',
        category: 'Management',
        order: 6,
      ),
    ];
  }
}
