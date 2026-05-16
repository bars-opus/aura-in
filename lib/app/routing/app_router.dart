// Route names for type-safe navigation
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:nano_embryo/app/routing/routing_notifier.dart';
import 'package:nano_embryo/app/splash_screen.dart';
import 'package:nano_embryo/core/utils/location/location_search_mode.dart';
import 'package:nano_embryo/core/utils/location/widgets/location_search_screen.dart';
import 'package:nano_embryo/presentation/features/auth/log_in/presentation/screens/forgot_password_screen.dart';
import 'package:nano_embryo/presentation/features/auth/log_in/presentation/screens/password_reset_email_sent_screen.dart';
import 'package:nano_embryo/presentation/features/auth/log_in/presentation/screens/username_creation_screen.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/domain/models/freelancer_draft.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/screens/freelancer_basics_screen.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/screens/freelancer_creation_dashboard.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/models/freelancer_edit_data.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/screens/freelancer_location_screen.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/screens/freelancer_tools_screen.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/screens/near_you_freelancers_screen.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/screens/top_rated_freelancers_screen.dart';
import 'package:nano_embryo/presentation/features/freelancer/presentation/screens/freelancer_details_screen.dart';
import 'package:nano_embryo/presentation/features/freelancer/presentation/screens/freelancer_preview_screen.dart';
import 'package:nano_embryo/presentation/features/shops/appointments/presentation/widgets/shop_schedule_hub.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/presentation/screens/calendar_screen.dart';
import 'package:nano_embryo/presentation/features/profile/models/profile_search_result.dart';
import 'package:nano_embryo/presentation/features/profile/widgets/profile_screen.dart';
import 'package:nano_embryo/presentation/features/settings/screens/language_screen.dart';
import 'package:nano_embryo/presentation/features/settings/screens/theme_screen.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/conversation.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/screens/chat_channel_loader.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/screens/chat_screen.dart';
import 'package:nano_embryo/presentation/features/search/presentation/screens/search_screen.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/screens/appointment_assign_workers_screen.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/screens/drafts_screen.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/screens/edit_basics_screen.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/screens/edit_location_screen.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/screens/edit_shop_screen.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/screens/manage_amenities_screen.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/screens/manage_awards_screen.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/screens/manage_contacts_screen.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/screens/manage_documents_screen.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/screens/manage_media_screen.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/screens/manage_services_screen.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/screens/manage_social_links_screen.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/screens/preview_shop_screen.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/screens/set_hours_screen.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/screens/shop_creation.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/screens/owner_dashboard_screen.dart';
import 'package:nano_embryo/presentation/features/shops/payment/presentation/screens/payment_settings_screen.dart';
import 'package:nano_embryo/presentation/features/shops/payment/presentation/widgets/paystack_connection_screen.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/screens/all_shop_workers_screen.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/screens/my_shops_screen.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/screens/premium_shops_screen.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/screens/shop_details_screen.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/screens/top_rated_shops_screen.dart';
import 'package:nano_embryo/presentation/features/auth/log_in/presentation/screens/update_password_screen.dart';
import 'package:nano_embryo/presentation/features/auth/verify_email/verify_email_screen.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/presentation/screens/shop_reviews_screen.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/marketplace_screen.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/product_detail_screen.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/cart_screen.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/checkout_screen.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/order_confirmation_screen.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/customer_orders_screen.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/customer_order_detail_screen.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/shop_orders_screen.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/order_detail_screen.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/shop_products_screen.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/product_form_screen.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';

/// Route names for type-safe navigation
class RouteNames {
  static const String intro = '/intro';
  static const String home = '/home';
  static const String allLegalDocumentation = '/allLegalDocumentation';
  static const String appInfoScreen = '/appInfoScreen';
  static const String settings = '/settings';
  static const String more = '/more';
  static const String login = '/login';
  static const String loginOptions = '/loginOptions';
  static const String language = '/language';
  static const String licenses = '/licenses';
  static const String theme = '/theme';
  static const String search = '/search';
  static const String chatScreen = '/chatScreen';
  static const String chatChannel = '/chat-channel';
  static const String editScreen = '/editScreen';
  static const String createUsername = '/createUsername';
  static const String verifyEmail = '/verifyEmail';
  static const String forgotPassword = '/forgot-password';
  static const String profileScreen = '/profileScreen';
  static const String locationSearchScreen = '/locationSearchScreen';
  static const String nearYouShopsScreen = '/nearYouShopsScreen';
  static const String topRatedShopsScreen = '/topRatedShopsScreen';
  static const String premiumShopsScreen = '/premiumShopsScreen';
  static const String shopDetailsScreen = '/shopDetailsScreen';
  static const String splash = '/splash';
  static const String calendar = '/calendar';
  static const String editBasics = '/editBasics';
  static const String editLocation = '/editLocation';
  static const String freelancerLocation = '/freelancerLocation';
  static const String setHours = '/setHours';
  static const String manageServices = '/manageServices';
  static const String manageMedia = '/manageMedia';
  static const String previewShop = '/previewShop';
  static const String editShop = '/editShop';
  static const String shopCreation = '/shopCreation';
  static const String manageSocialLinks = '/manageSocialLinks';
  static const String manageAmenities = '/manageAmenities';
  static const String manageDocuments = '/manageDocuments';
  static const String manageAwards = '/manageAwards';
  static const String manageContacts = '/manageContacts';
  static const String draftsScreen = '/draftsScreen';
  static const String appointmentAssignWorkersScreen =
      '/appointmentAssignWorkersScreen';
  static const String shopReviewsScreen = '/shopReviewsScreen';
  static const String shopScheduleHub = '/shopScheduleHub';
  static const String allShopWorkersScreen = '/allShopWorkersScreen';
  static const String ownerDashboardScreen = '/ownerDashboardScreen';
  static const String paystackConnectionScreen = '/paystackConnectionScreen';
  static const String paymentSettingsScreen = '/paymentSettingsScreen';
  static const String freelancerCreationDashboard =
      '/freelancerCreationDashboard';
  static const String freelancerBasicsScreen = '/freelancerBasicsScreen';
  static const String freelancerToolsScreen = '/freelancerToolsScreen';
  static const String myShopsScreen = '/myShopsScreen';
  static const String freelancerDetailsScreen = '/freelancerDetailsScreen';
  static const String freelancerPreviewScreen = '/freelancerPreviewScreen';
  static const String topRatedFreelancersScreen = '/topRatedFreelancersScreen';
  static const String nearYouFreelancersScreen = '/nearYouFreelancersScreen';
  static const String updatePasswordScreen = '/updatePasswordScreen';

  static const String passwordResetSentScreen = '/passwordResetSentScreen';

  // Marketplace / orders / cart
  static const String marketplace = '/marketplace';
  static const String productDetail = '/productDetail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/orderConfirmation';
  static const String customerOrders = '/customerOrders';
  static const String customerOrderDetail = '/customerOrderDetail';
  static const String shopOrders = '/shopOrders';
  static const String shopOrderDetail = '/shopOrderDetail';
  static const String shopProducts = '/shopProducts';
  static const String productForm = '/productForm';

  // static const String bookingDetailScreen = '/bookingDetailScreen';
}

GoRouter createAppRouter(RoutingNotifier routingNotifier) {
  return GoRouter(
    debugLogDiagnostics: kDebugMode,
    initialLocation: '/_invisible',
    refreshListenable: routingNotifier,
    onException: (_, state, router) {
      // Unrecognised locations (e.g. OAuth callback /?code=…) — let the
      // auth state stream settle and re-evaluate via the invisible trigger.
      router.go('/_invisible');
    },
    redirect: (context, state) {
      // OAuth callback deep links (/?code= or /?access_token=) are consumed
      // by AppLinks in main.dart. Bounce through /_invisible so the auth
      // state stream can settle and the redirect fires with the real user.
      final q = state.uri.queryParameters;
      if (q.containsKey('code') || q.containsKey('access_token')) {
        return '/_invisible';
      }

      // Password-recovery deep link — send the user to the update screen and
      // stay there until they complete the flow (isRecoveryMode cleared on success).
      if (routingNotifier.isRecoveryMode) {
        if (state.matchedLocation == RouteNames.updatePasswordScreen)
          return null;
        return RouteNames.updatePasswordScreen;
      }

      // Handle the invisible initial route first
      if (state.matchedLocation == '/_invisible') {
        final lastLocation = routingNotifier.currentLocation;
        if (lastLocation == RouteNames.editScreen) {
          return RouteNames.editScreen;
        }

        // Normal invisible route handling
        final user = routingNotifier.user;
        final profile = routingNotifier.profile;
        final isFirstLaunch = routingNotifier.isFirstLaunch;
        final hasUsername = profile?.hasUsername ?? false;

        if (isFirstLaunch) return RouteNames.intro;
        if (user == null) return RouteNames.home;
        if (!hasUsername) return RouteNames.createUsername;
        return RouteNames.home;
      }

      final user = routingNotifier.user;
      final profile = routingNotifier.profile;
      final isFirstLaunch = routingNotifier.isFirstLaunch;
      final hasUsername = profile?.hasUsername ?? false;

      // 🟢 NEW GUARD: If we're on edit screen and user becomes null temporarily,
      // don't redirect - this is likely a refresh
      // GUARD: If user becomes null on protected route (likely refresh), stay
      if (user == null) {
        final protectedRoutes = [
          RouteNames.home,
          RouteNames.editScreen,
          RouteNames.settings,
          RouteNames.more,
        ];
        if (protectedRoutes.contains(state.matchedLocation)) {
          return null;
        }
      }

      // 1. FIRST LAUNCH
      if (isFirstLaunch) {
        if (state.matchedLocation == RouteNames.intro) return null;
        return RouteNames.intro;
      }

      // 2. NOT FIRST LAUNCH - authenticated user on intro → transition to home.
      // Unauthenticated users (e.g. after logout) are allowed to stay on intro.
      if (state.matchedLocation == RouteNames.intro && user != null) {
        return '${RouteNames.splash}?transition=true';
      }

      // 3. NOT LOGGED IN
      if (user == null) {
        final protectedRoutes = [
          RouteNames.home,
          RouteNames.editScreen,
          RouteNames.settings,
          RouteNames.more,
        ];

        if (protectedRoutes.contains(state.matchedLocation)) return null;

        if (state.matchedLocation == RouteNames.createUsername) {
          return RouteNames.home;
        }
        // Allow the verify email screen when awaiting confirmation
        if (state.matchedLocation == RouteNames.verifyEmail) return null;
        return null;
      }

      // 4. LOGGED IN but NO USERNAME
      // Guard: profile is null when still loading — don't redirect yet.
      // setUser() fires immediately on sign-in before the profile fetch
      // completes; without this guard an authenticated user would be
      // incorrectly redirected to createUsername on every login.
      if (profile == null) return null;

      if (!hasUsername) {
        if (state.matchedLocation == RouteNames.createUsername) return null;
        // After email confirmation the user lands on createUsername, not verifyEmail
        if (state.matchedLocation == RouteNames.verifyEmail) {
          return RouteNames.createUsername;
        }
        return RouteNames.createUsername;
      }

      // 5. FULLY AUTHENTICATED - redirect from public routes
      final publicRoutes = [
        RouteNames.intro,
        RouteNames.login,
        RouteNames.loginOptions,
        RouteNames.createUsername,
      ];
      if (publicRoutes.contains(state.matchedLocation)) return RouteNames.home;

      return null;
    },
    routes: [
      // Add deep link route handler
      GoRoute(
        path: '/l/:slug',
        name: 'deepLink',
        builder: (context, state) => const SizedBox.shrink(),
      ),
      // Your routes here - exactly as you had them
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.intro,
        name: 'intro',
        builder: (context, state) => const IntroScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.loginOptions,
        name: 'loginOptions',
        builder: (context, state) {
          final from = state.extra as String? ?? '';
          return LoginScreenOptions(from: from);
        },
      ),
      GoRoute(
        path: RouteNames.profileScreen,
        name: 'profileScreen',
        builder: (context, state) {
          // Use dynamic with null safety
          final params = state.extra as Map<String, dynamic>?;

          return ProfileScreen(
            currentUserId: params?['currentUserId'] as String? ?? '',
            profileUserId: params?['profileUserId'] as String? ?? '',
            profileSearchResult:
                params?['profileSearchResult'] as ProfileSearchResult?,
          );
        },
      ),

      GoRoute(
        path: RouteNames.createUsername,
        name: 'createUsername',
        builder: (context, state) => const UsernameCreationScreen(),
      ),
      GoRoute(
        path: RouteNames.verifyEmail,
        name: 'verifyEmail',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return VerifyEmailScreen(email: email);
        },
      ),
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.more,
        name: 'more',
        builder:
            (context, state) => const MoreScreen(
              shopId: '',
              accountType: '',
              shopName: '',
              shopOwnerId: '',
              shopCurrencyCode: '',
              shopCountry: '',
              isFreelancer: false,
            ),
      ),

      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) {
          final currentUserId = state.extra as String? ?? '';
          return SettingsScreen(currentUserId: currentUserId);
        },
      ),
      // GoRoute(
      //   path: RouteNames.settings,
      //   name: 'settings',
      //   builder: (context, state) => const SettingsScreen(),
      // ),
      GoRoute(
        path: RouteNames.search,
        name: 'search',
        pageBuilder:
            (context, state) =>
                MaterialPage(key: state.pageKey, child: const SearchScreen()),
      ),
      GoRoute(
        path: RouteNames.chatScreen,
        name: 'chatScreen',
        builder: (context, state) {
          final conversation = state.extra as Conversation;
          return ChatScreen(conversation: conversation);
        },
      ),
      GoRoute(
        path: RouteNames.chatChannel,
        name: 'chatChannel',
        builder: (context, state) {
          final channelUrl = state.uri.queryParameters['url'] ?? '';
          return ChatChannelLoader(channelUrl: channelUrl);
        },
      ),
      GoRoute(
        path: RouteNames.editScreen,
        name: 'editScreen',
        builder: (context, state) {
          final currentUserId = state.extra as String? ?? '';
          return EditProfileScreen(currentUserId: currentUserId);
        },
      ),

      GoRoute(
        path: RouteNames.language,
        name: 'language',
        pageBuilder:
            (context, state) =>
                MaterialPage(key: state.pageKey, child: const LanguageScreen()),
      ),
      GoRoute(
        path: RouteNames.theme,
        name: 'theme',
        pageBuilder:
            (context, state) =>
                MaterialPage(key: state.pageKey, child: const ThemeScreen()),
      ),
      GoRoute(
        path: RouteNames.licenses,
        name: 'licenses',
        builder: (context, state) => const LicensesScreen(),
      ),
      GoRoute(
        path: RouteNames.allLegalDocumentation,
        name: 'allLegalDocumentation',
        builder: (context, state) => const AllLegalDocumentationsScreen(),
      ),
      GoRoute(
        path: RouteNames.appInfoScreen,
        name: 'appInfoScreen',
        builder: (context, state) => const AppInfoScreen(),
      ),
      GoRoute(
        path: RouteNames.locationSearchScreen,
        name: 'locationSearchScreen',
        builder: (context, state) {
          final mode =
              state.extra as LocationSearchMode? ?? LocationSearchMode.city;
          return LocationSearchScreen(mode: mode);
        },
      ),
      GoRoute(
        path: RouteNames.nearYouShopsScreen,
        name: 'nearYouShopsScreen',
        builder: (context, state) => const PremiumShopsScreen(),
      ),
      GoRoute(
        path: RouteNames.topRatedShopsScreen,
        name: 'topRatedShopsScreen',
        builder: (context, state) => const TopRatedShopsScreen(),
      ),
      GoRoute(
        path: RouteNames.premiumShopsScreen,
        name: 'premiumShopsScreen',
        builder: (context, state) => const PremiumShopsScreen(),
      ),

      GoRoute(
        path: RouteNames.shopDetailsScreen,
        name: 'shopDetailsScreen',
        builder: (context, state) {
          // Cast to Map with nullable values first
          final params = state.extra as Map<String, String?>;

          return ShopDetailsScreen(
            shopId: params['shopId'] ?? '', // Provide default for null
            coverImageUrl: params['coverImageUrl'] ?? '',
          );
        },
      ),

      GoRoute(
        path: RouteNames.calendar,
        name: 'calendar',
        builder: (context, state) {
          // Cast to Map with proper types
          final params = state.extra as Map<String, dynamic>?;
          return CalendarScreen(
            currentUserId: params?['currentUserId'] as String? ?? '',
            isShopOwner: params?['isShopOwner'] as bool? ?? false,
            isCurrentUser: params?['isCurrentUser'] as bool? ?? false,
          );
        },
      ),
      // In your router configuration
      GoRoute(
        path: RouteNames.editBasics,
        name: 'editBasics',
        builder: (context, state) => const EditBasicsScreen(),
      ),
      GoRoute(
        path: RouteNames.editLocation,
        name: 'editLocation',
        builder: (context, state) {
          final showBottonNextButton = state.extra as bool? ?? false;
          return EditLocationScreen(showBottonNextButton: showBottonNextButton);
        },
      ),
      GoRoute(
        path: RouteNames.freelancerLocation,
        name: 'freelancerLocation',
        builder: (context, state) => const FreelancerLocationScreen(),
      ),

      GoRoute(
        path: RouteNames.manageServices,
        name: 'manageServices',
        builder: (context, state) => const ManageServicesScreen(shopId: ''),
      ),
      GoRoute(
        path: RouteNames.setHours,
        name: 'setHours',
        builder: (context, state) => const SetHoursScreen(),
      ),

      GoRoute(
        path: RouteNames.manageMedia,
        name: 'manageMedia',
        builder: (context, state) => const ManageMediaScreen(),
      ),

      GoRoute(
        path: RouteNames.previewShop,
        name: 'previewShop',
        builder: (context, state) {
          final mode = state.extra as String? ?? '';
          return PreviewShopScreen(mode: mode);
        },
      ),

      GoRoute(
        path: RouteNames.editShop,
        name: 'editShop',
        builder: (context, state) {
          final shopId = state.extra as String? ?? '';
          return EditShopScreen(shopId: shopId);
        },
      ),

      GoRoute(
        path: RouteNames.shopCreation,
        name: 'shopCreation',
        builder: (context, state) {
          return ShopCreation();
        },
      ),

      GoRoute(
        path: RouteNames.manageSocialLinks,
        name: 'manageSocialLinks',
        builder: (context, state) => const ManageSocialLinksScreen(),
      ),

      GoRoute(
        path: RouteNames.manageAmenities,
        name: 'manageAmenities',
        builder: (context, state) => const ManageAmenitiesScreen(),
      ),

      GoRoute(
        path: RouteNames.manageDocuments,
        name: 'manageDocuments',
        builder: (context, state) => const ManageDocumentsScreen(),
      ),

      GoRoute(
        path: RouteNames.manageAwards,
        name: 'manageAwards',
        builder: (context, state) => const ManageAwardsScreen(),
      ),

      GoRoute(
        path: RouteNames.manageContacts,
        name: 'manageContacts',
        builder: (context, state) => const ManageContactsScreen(),
      ),
      GoRoute(
        path: RouteNames.draftsScreen,
        name: 'draftsScreen',
        builder: (context, state) => const DraftsScreen(),
      ),

      GoRoute(
        path: RouteNames.appointmentAssignWorkersScreen,
        name: 'appointmentAssignWorkersScreen',
        builder: (context, state) => AppointmentAssignWorkersScreen(shopId: ''),
      ),

      GoRoute(
        path: RouteNames.shopReviewsScreen,
        name: 'shopReviewsScreen',
        builder: (context, state) {
          // Cast to Map with nullable values first
          final params = state.extra as Map<String, String?>;

          return ShopReviewsScreen(
            shopId: params['shopId'] ?? '', // Provide default for null
            shopName: params['shopName'] ?? '',
          );
        },
      ),

      GoRoute(
        path: RouteNames.allShopWorkersScreen,
        name: 'allShopWorkersScreen',
        builder: (context, state) {
          // Cast to Map with nullable values first
          final params = state.extra as Map<String, String?>;

          return AllShopWorkersScreen(
            shopId: params['shopId'] ?? '', // Provide default for null
            shopName: params['shopName'] ?? '',
          );
        },
      ),

      GoRoute(
        path: RouteNames.ownerDashboardScreen,
        name: 'ownerDashboardScreen',
        builder: (context, state) {
          // Cast to Map with nullable values first
          final params = state.extra as Map<String, dynamic>;
          return OwnerDashboardScreen(
            shopId: params['shopId'] ?? '', // Provide default for null
            accountType: params['accountType'] ?? '',
            // subaccountId: params['subaccountId'] ?? '',
            shopName: params['shopName'] ?? '',
            shopOwnerId: params['shopOwnerId'] ?? '',
            shopCurrencyCode: params['shopCurrencyCode'] ?? '',
            shopCountry: params['shopCountry'] ?? '',
            isFreelancer: params['shopCountry'] ?? false,
          );
        },
      ),

      GoRoute(
        path: RouteNames.shopScheduleHub,
        name: 'shopScheduleHub',
        builder: (context, state) {
          // Cast to Map with nullable values first
          final params = state.extra as Map<String, String?>;

          return ShopScheduleHub(
            shopId: params['shopId'] ?? '', // Provide default for null
            accountType: params['accountType'] ?? '',
          );
        },
      ),

      GoRoute(
        path: RouteNames.paystackConnectionScreen,
        name: 'paystackConnectionScreen',
        builder: (context, state) {
          final params = state.extra as Map<String, String>;
          return PaystackConnectionScreen(
            shopName: params['shopName'] ?? '',
            shopId: params['shopId'] ?? '',
            shopOwnerId: params['shopOwnerId'] ?? '',
            shopCurrencyCode: params['shopCurrencyCode'] ?? '',
          );
        },
      ),

      GoRoute(
        path: RouteNames.paymentSettingsScreen,
        name: 'paymentSettingsScreen',
        builder: (context, state) {
          final params = state.extra as Map<String, String>;
          return PaymentSettingsScreen(
            shopName: params['shopName'] ?? '',
            shopId: params['shopId'] ?? '',
            shopOwnerId: params['shopOwnerId'] ?? '',
            shopCurrencyCode: params['shopCurrencyCode'] ?? '',
            shopCountry: params['shopCountry'] ?? '',
          );
        },
      ),

      GoRoute(
        path: RouteNames.freelancerCreationDashboard,
        name: 'freelancerCreationDashboard',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>? ?? {};
          return FreelancerCreationDashboard(
            freelancerId: params['shopId'] as String?,
            mode: params['mode'] as FreelancerMode? ?? FreelancerMode.create,
            existingFreelancer:
                params['existingFreelancer'] as FreelancerEditData?,
          );
        },
      ),

      GoRoute(
        path: RouteNames.freelancerBasicsScreen,
        name: 'freelancerBasicsScreen',
        builder: (context, state) => const FreelancerBasicsScreen(),
      ),

      GoRoute(
        path: RouteNames.freelancerToolsScreen,
        name: 'freelancerToolsScreen',
        builder: (context, state) => const FreelancerToolsScreen(),
      ),

      GoRoute(
        path: RouteNames.myShopsScreen,
        name: 'myShopsScreen',
        builder: (context, state) => const MyShopsScreen(),
      ),

      GoRoute(
        path: RouteNames.freelancerDetailsScreen,
        name: 'freelancerDetailsScreen',
        builder: (context, state) {
          // Cast to Map with nullable values first
          final params = state.extra as Map<String, String?>;
          return FreelancerDetailsScreen(
            freelancerId: params['freelancerId'] ?? '',
            freelancurrency: params['freelancurrency'] ?? '',
            coverImageUrl:
                params['coverImageUrl'] ?? '', // Provide default for null
          );
        },
      ),

      GoRoute(
        path: RouteNames.freelancerPreviewScreen,
        name: 'freelancerPreviewScreen',
        builder: (context, state) {
          // Get the extra data
          final extra = state.extra as Map<String, dynamic>?;

          // Extract mode and draft with proper types
          final mode =
              extra?['mode'] as FreelancerMode? ?? FreelancerMode.create;
          final draft = extra?['draft'] as FreelancerDraft?;

          return FreelancerPreviewScreen(mode: mode, draft: draft);
        },
      ),

      GoRoute(
        path: RouteNames.topRatedFreelancersScreen,
        name: 'topRatedFreelancersScreen',
        builder: (context, state) => TopRatedFreelancersScreen(),
      ),

      GoRoute(
        path: RouteNames.nearYouFreelancersScreen,
        name: 'nearYouFreelancersScreen',
        builder: (context, state) => NearYouFreelancersScreen(),
      ),

      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) {
          final email = state.extra as String?;
          return ForgotPasswordScreen(initialEmail: email);
        },
      ),

      GoRoute(
        path: RouteNames.passwordResetSentScreen,
        name: 'passwordResetSentScreen',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return PasswordResetEmailSentScreen(email: email);
        },
      ),

      GoRoute(
        path: RouteNames.updatePasswordScreen,
        name: 'updatePasswordScreen',
        builder: (context, state) => const UpdatePasswordScreen(),
      ),

      // ── Marketplace / orders / cart ──────────────────────────
      GoRoute(
        path: RouteNames.marketplace,
        name: 'marketplace',
        builder: (context, state) => const MarketplaceScreen(),
      ),
      GoRoute(
        path: RouteNames.productDetail,
        name: 'productDetail',
        builder:
            (context, state) =>
                ProductDetailScreen(productId: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: RouteNames.cart,
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: RouteNames.checkout,
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: RouteNames.orderConfirmation,
        name: 'orderConfirmation',
        builder:
            (context, state) =>
                OrderConfirmationScreen(orderId: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: RouteNames.customerOrders,
        name: 'customerOrders',
        builder: (context, state) => const CustomerOrdersScreen(),
      ),
      GoRoute(
        path: RouteNames.customerOrderDetail,
        name: 'customerOrderDetail',
        builder:
            (context, state) => CustomerOrderDetailScreen(
              orderId: state.extra as String? ?? '',
            ),
      ),
      GoRoute(
        path: RouteNames.shopOrders,
        name: 'shopOrders',
        builder:
            (context, state) =>
                ShopOrdersScreen(shopId: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: RouteNames.shopOrderDetail,
        name: 'shopOrderDetail',
        builder: (context, state) {
          final params = state.extra as Map<String, String>;
          return OrderDetailScreen(
            orderId: params['orderId'] ?? '',
            shopId: params['shopId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: RouteNames.shopProducts,
        name: 'shopProducts',
        builder:
            (context, state) =>
                ShopProductsScreen(shopId: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: RouteNames.productForm,
        name: 'productForm',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>;
          return ProductFormScreen(
            shopId: params['shopId'] as String? ?? '',
            mode: params['mode'] as FormMode? ?? FormMode.create,
            product: params['product'] as ProductModel?,
          );
        },
      ),
    ],
  );
}

class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('🗺️ Route pushed: ${route.settings.name}');
  }
}
