// lib/core/documentation/documentation_registry.dart
import 'package:nano_embryo/app/documentations/user_manual/data/freelancer_docs.dart';
import 'package:nano_embryo/app/documentations/user_manual/data/booking/booking_getting_started.dart';
import 'package:nano_embryo/app/documentations/user_manual/data/booking/faqs.dart';
import 'package:nano_embryo/app/documentations/user_manual/data/booking/group_bookings.dart';
import 'package:nano_embryo/app/documentations/user_manual/data/booking/how_to_book_services.dart';
import 'package:nano_embryo/app/documentations/user_manual/data/booking/payment_fees_explained.dart';
import 'package:nano_embryo/app/documentations/user_manual/data/booking/time_slots_explained.dart';
import 'package:nano_embryo/app/documentations/user_manual/data/dash_board_docs.dart';
import 'package:nano_embryo/app/documentations/user_manual/data/getting_started_docs.dart';
import 'package:nano_embryo/app/documentations/user_manual/data/create_product_docs.dart';
import 'package:nano_embryo/app/documentations/user_manual/data/create_shop_docs.dart';
import 'package:nano_embryo/app/documentations/user_manual/models/documentation_model.dart';

// lib/core/documentation/documentation_registry.dart
// 4. Update DocumentationRegistry

class DocumentationRegistry {
  // Store all modules by ID
  static final Map<String, DocumentationModule> _idMap = {};

  // Initialize with default modules
  static void initialize() {
    // Register all your modules here
    registerModule(CreateShopDocs());
    registerModule(FreelancerDocs());
    registerModule(CreateProductDocs());
    // registerModule(BookingGettingStartedDocs());
    registerModule(HowToBookServicesDocs());
    registerModule(GroupBookingsDocs());
    registerModule(PaymentFeesExplainedDocs());
    registerModule(TimeSlotsExplainedDocs());
    registerModule(FAQsDocs());

    registerModule(DashboardDocs());
    // registerModule(GettingStartedDocs());

    // Add more as needed
  }

  // ✅ 1. Get all modules (sorted by order)
  static List<DocumentationModule> getAllModules() {
    return _idMap.values.toList()..sort((a, b) => a.order.compareTo(b.order));
  }

  // ✅ 2. Get module by ID
  static DocumentationModule? getById(String id) => _idMap[id];

  static CreateShopDocs get createShop =>
      getById('create_shop') as CreateShopDocs;
  static FreelancerDocs get freelancer =>
      getById('become_freelancer') as FreelancerDocs;
  static CreateProductDocs get createProduct =>
      getById('sell_products') as CreateProductDocs;
  static BookingGettingStartedDocs get bookingGettingStarted =>
      getById('bookingGettingStarted') as BookingGettingStartedDocs;
  static HowToBookServicesDocs get howToBookServices =>
      getById('howToBookServices') as HowToBookServicesDocs;
  static GroupBookingsDocs get groupBookings =>
      getById('groupBookings') as GroupBookingsDocs;
  static PaymentFeesExplainedDocs get paymentFeesExplained =>
      getById('paymentFeesExplained') as PaymentFeesExplainedDocs;
  static TimeSlotsExplainedDocs get timeSlotsExplained =>
      getById('timeSlotsExplained') as TimeSlotsExplainedDocs;
  static FAQsDocs get faqs => getById('faqs') as FAQsDocs;

  // ✅ 3. Get direct instances (for type-safe access)
  static DashboardDocs get dashboard => getById('dashboard') as DashboardDocs;
  static GettingStartedDocs get gettingStarted =>
      getById('gettingStarted') as GettingStartedDocs;
  // static AuthenticationDocs get authentication =>
  // getById('authentication') as AuthenticationDocs;

  // ✅ 4. Register new modules
  static void registerModule(DocumentationModule module) {
    _idMap[module.id] = module;
  }

  // ✅ 5. Get all topic IDs
  static List<String> getAllTopicIds() => _idMap.keys.toList();

  // ✅ 6. Get modules by category
  static Map<String, List<DocumentationModule>> getModulesByCategory() {
    final map = <String, List<DocumentationModule>>{};

    return map;
  }
}
