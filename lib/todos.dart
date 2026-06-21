//  flutter build web --release --no-tree-shake-icons 




// Give me a deatils transcript or note on this video so i can fully understand what was being said without missing any revelant detail.



// insert into app_admins (user_id) values ('<your-auth-user-id>');




// supabase secrets set WHATSAPP_VERIFY_TOKEN=3765b6803b1f283313ae9d7e6708b4fe1cd83103

// remove authIntroSubtitle from localixation


// Two manual follow-ups still on the user side

// Submit 3 Meta WhatsApp templates for guest delivery. Worker auto-retries via existing 6h fallback — non-blocking.
// Manual UAT once you create real test bookings on the dev DB. The trigger fires when a booking goes to confirmed, so the easiest test is: book through the app → wait → check scheduled_notifications for 2 pending rows (24h + 2h).





// What's left before launch
// You (user-action steps):

// Vercel deploy — npx vercel deploy --prod from aura-in-web/, with env vars set in Vercel dashboard (NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY, NEXT_PUBLIC_MAPBOX_TOKEN)
// Set a real booking_slug on a shop in the Supabase dashboard SQL editor so you can hit /book/<slug> with a 200
// Lighthouse Mobile Slow 4G check (target: Performance ≥ 90, FCP <2s, LCP <3s)
// End-to-end smoke: open the link, pick a service, pay GH₵ X via Paystack test mode, confirm success page shows ≤ 10s

// supabase functions deploy sendbird-auth




// Primary Bundle ID
// XC com bars-Opus florence (A8RJ357U9Y.com.bars-Opus.florence)
// Website URLs
// kbmjwicdffpuowymkobo.supabase.co
// https://kbmjwicdffpuowymkobo.supabase.co/auth/v1/callback






















// Read and understand these chats and all the implementations because we are going to build on that so read and get updated. I dont want you to write any codes you can just list some implementations and concepts from the chats i just want you to know the progress we you can keep up:
// https://chat.deepseek.com/share/dwres9elgr773lzvyg
// https://chat.deepseek.com/share/f9x0ike4q1wxo0b8eh
// https://chat.deepseek.com/share/cal0ngpvritgsr5bjf
// https://chat.deepseek.com/share/05bxw07nso6ddh7nm3
// https://chat.deepseek.com/share/rkjf4ql9a9ekazrc8r
// https://chat.deepseek.com/share/0e3583g0u8x1m1j9qn
// https://chat.deepseek.com/share/idr52imomfrjmudw2
// https://chat.deepseek.com/share/ccvf6s9kprkahyskpz
// https://chat.deepseek.com/share/7t56n0gml7yshm53vz
// https://chat.deepseek.com/share/mpffhpo6me0zmh80no
// https://chat.deepseek.com/share/ud18pjt0rpiyrjb8ll



// source 'https://github.com/CocoaPods/Specs.git'


// $MapboxAccessToken = ENV['MAPBOX_ACCESS_TOKEN']



//todos
//change Read user manual in intro screen
//implement chat language changes
//implement username creation  language changes
//implement username lgout prompt in settings  language changes
//implement chat and conversation  language changes
//We have to change the app logo on splash, intro screen and login screen options
//Implement login profile language translation
//Implement editable profile avatar profile language translation
//Implement  language translation for discover shops screen
//Implement  language translation for top rated, near you and premuim, list screens, and HorizontalShopSection
//Implement  language translation for LocationPickerBottomSheet, LocationDisplayWidget && location search screen
//Impelement language change for booking and BookingException
//Impelement language change for calendar and its associated files
//Impelement language change for create shop and its associated files










//todos add theses localization languages
// String get confirmPasswordLabel => 'Confirm Password';
// String get confirmPasswordHint => 'Re-enter your password';
// String get passwordsDoNotMatch => 'Passwords do not match';
// String get confirmPasswordLabel => 'Confirm Password';
// String get confirmPasswordHint => 'Re-enter your password';
// String get confirmPasswordRequired => 'Please confirm your password';
// String get validationValid => 'is valid';
// String get alreadyHaveAccount => 'Already have an account? Login';
// String get createAccount => 'Create an account';String get confirmPasswordRequired => 'Please confirm your password';
// String get loggingInIndicatorText => 'Logging in...';
// String get loginSuccessful => 'Login successful!';
// String get loginFailed => 'Login failed';
// String get creatingAccount => 'Creating account...';
// String get accountCreated => 'Account created successfully!';
// String get confirmEmailMessage => 'Please check your email to confirm your account';
// String get signupFailed => 'Sign up failed';
// String get authenticating => 'Authenticating...';
// String get googleSignInFailed => 'Google sign-in failed';
// String get appleSignInFailed => 'Apple sign-in failed';
// String get sendingResetEmail => 'Sending reset email...';
// String get resetEmailSent => 'Reset email sent. Check your inbox.';
// String get resetPasswordFailed => 'Password reset failed';
// String get tryAgain => 'Try again';
// String get confirmPasswordRequired => 'Please confirm your password';
// String get passwordsDoNotMatch => 'Passwords do not match';
// String get networkError => 'Network error. Please check your connection.';
// String get timeoutError => 'Request timed out. Please try again.';
// String get unknownError => 'An unexpected error occurred.';
// String get verifyEmailTitle => 'Verify Your Email';
// String get verifyEmailHeader => 'Check Your Email';
// String get verifyEmailSentTo => 'We sent a verification link to:';
// String get verificationLinkExpires => 'Link expires in:';
// String get emailVerified => 'Email Verified!';
// String get resendVerificationEmail => 'Resend Verification Email';
// String get backToIntro => 'Back to Intro';
// String get verifyEmailHelp => 'Click the link in your email to verify your account. Check spam folder if you don\'t see it.';
// String get verifyEmailSentMessage => 'Verification email sent! Please check your inbox.';


//todos work on the email verification flow again. 
//Admin cloud function Cleanup for unveirfied cancled email sign up. Used by: Notion, Supabase Studio itself we have to use a cloud function to perform this
// replace this:  emailRedirectTo: 'https://www.barsopus.com/aura-in', with branch.io dynamic link so when user verify their email, it opens the app









// -- =====================================================
// -- MIGRATION: Create tables for Aura shops (run once)
// -- =====================================================
// We'll start from scratch: create the tables with proper relationships, then insert one complete shop with all associated data. This ensures our schema is robust and scalable. We'll use UUIDs, foreign keys, and indexes.


// -- =====================================================
// -- MIGRATION: Create tables for Aura shops (run once)
// -- =====================================================

// -- Enable UUID extension
// CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

// -- 1. SHOPS table (core)
// CREATE TABLE shops (
//     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//     user_id TEXT NOT NULL, -- references auth.users.id from Supabase Auth
//     shop_name TEXT NOT NULL,
//     shop_logo_url TEXT,
//     verified BOOLEAN DEFAULT false,
//     shop_type TEXT, -- 'salon', 'barbershop', 'spa', 'nail_salon', 'specialty'
//     dynamic_link TEXT,
//     terms TEXT,
//     overview TEXT,
//     no_booking BOOLEAN DEFAULT false,
//     city TEXT,
//     country TEXT,
//     address TEXT,
//     currency TEXT DEFAULT 'USD',
//     transfer_recipient_id TEXT,
//     subaccount_id TEXT,
//     account_type TEXT, -- 'business' or 'individual'
//     average_rating DECIMAL(3,2) DEFAULT 0,
//     number_clients_worked INTEGER DEFAULT 0,
//     is_paid_for_week BOOLEAN DEFAULT false,
//     is_main_shop BOOLEAN DEFAULT false,
//     main_shop_id UUID REFERENCES shops(id) ON DELETE SET NULL,
//     luxury_level TEXT, -- 'Moderate', 'Luxury', 'UltraLuxury'
//     show_on_explore_page BOOLEAN DEFAULT true,
//     created_at TIMESTAMPTZ DEFAULT NOW(),
//     updated_at TIMESTAMPTZ DEFAULT NOW()
// );

// -- Indexes for common queries
// CREATE INDEX idx_shops_user_id ON shops(user_id);
// CREATE INDEX idx_shops_city ON shops(city);
// CREATE INDEX idx_shops_verified ON shops(verified);
// CREATE INDEX idx_shops_show_on_explore ON shops(show_on_explore_page);

// -- 2. SHOP LOCATIONS (one-to-many, but we'll start with one per shop)
// CREATE TABLE shop_locations (
//     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//     shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
//     address TEXT NOT NULL,
//     city TEXT NOT NULL,
//     country TEXT NOT NULL,
//     latitude DOUBLE PRECISION,
//     longitude DOUBLE PRECISION,
//     is_primary BOOLEAN DEFAULT true,
//     created_at TIMESTAMPTZ DEFAULT NOW()
// );

// CREATE INDEX idx_shop_locations_shop_id ON shop_locations(shop_id);

// -- 3. SHOP WORKERS
// CREATE TABLE shop_workers (
//     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//     shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
//     name TEXT NOT NULL,
//     bio TEXT,
//     profile_image_url TEXT,
//     is_active BOOLEAN DEFAULT true,
//     specialties TEXT[], -- array of service categories or specific skills
//     created_at TIMESTAMPTZ DEFAULT NOW()
// );

// CREATE INDEX idx_shop_workers_shop_id ON shop_workers(shop_id);

// -- 4. SHOP SERVICES
// CREATE TABLE shop_services (
//     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//     shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
//     name TEXT NOT NULL,
//     description TEXT,
//     duration INTERVAL NOT NULL, -- PostgreSQL interval type, e.g., '45 minutes'
//     base_price DECIMAL(10,2) NOT NULL,
//     category TEXT, -- 'Hair', 'Nails', 'Massage', etc.
//     is_active BOOLEAN DEFAULT true,
//     created_at TIMESTAMPTZ DEFAULT NOW()
// );

// CREATE INDEX idx_shop_services_shop_id ON shop_services(shop_id);
// CREATE INDEX idx_shop_services_category ON shop_services(category);

// -- 5. SHOP APPOINTMENT SLOTS (recurring slots definition)
// CREATE TABLE shop_appointment_slots (
//     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//     shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
//     service_id UUID REFERENCES shop_services(id) ON DELETE SET NULL,
//     type TEXT, -- 'in-person', 'online', etc.
//     duration INTERVAL NOT NULL,
//     price DECIMAL(10,2) NOT NULL,
//     max_clients INTEGER DEFAULT 1,
//     description TEXT,
//     select_preferred_worker BOOLEAN DEFAULT false,
//     days_of_week INTEGER[], -- array of integers 0-6 (Sunday=0 or Monday=1? We'll use Monday=1 for clarity)
//     is_recurring BOOLEAN DEFAULT true,
//     valid_from DATE,
//     valid_until DATE,
//     created_at TIMESTAMPTZ DEFAULT NOW()
// );

// CREATE INDEX idx_slots_shop_id ON shop_appointment_slots(shop_id);
// CREATE INDEX idx_slots_service_id ON shop_appointment_slots(service_id);

// -- 6. SLOT-WORKER ASSIGNMENTS (many-to-many)
// CREATE TABLE slot_worker_assignments (
//     slot_id UUID REFERENCES shop_appointment_slots(id) ON DELETE CASCADE,
//     worker_id UUID REFERENCES shop_workers(id) ON DELETE CASCADE,
//     is_preferred BOOLEAN DEFAULT false,
//     PRIMARY KEY (slot_id, worker_id)
// );

// -- 7. SHOP AWARDS (PortfolioModel)
// CREATE TABLE shop_awards (
//     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//     shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
//     name TEXT NOT NULL,
//     link TEXT,
//     date_received DATE,
//     description TEXT,
//     created_at TIMESTAMPTZ DEFAULT NOW()
// );

// CREATE INDEX idx_awards_shop_id ON shop_awards(shop_id);

// -- 8. SHOP SOCIAL LINKS
// CREATE TABLE shop_social_links (
//     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//     shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
//     name TEXT, -- e.g., 'Instagram', 'Facebook'
//     url TEXT NOT NULL,
//     platform TEXT GENERATED ALWAYS AS (
//         CASE
//             WHEN url ILIKE '%instagram.com%' THEN 'instagram'
//             WHEN url ILIKE '%facebook.com%' THEN 'facebook'
//             WHEN url ILIKE '%twitter.com%' OR url ILIKE '%x.com%' THEN 'twitter'
//             WHEN url ILIKE '%tiktok.com%' THEN 'tiktok'
//             ELSE 'other'
//         END
//     ) STORED,
//     created_at TIMESTAMPTZ DEFAULT NOW()
// );

// CREATE INDEX idx_social_links_shop_id ON shop_social_links(shop_id);

// -- 9. SHOP CONTACTS (PortfolioContactModel)
// CREATE TABLE shop_contacts (
//     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//     shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
//     contact_type TEXT NOT NULL, -- 'email', 'phone', 'whatsapp'
//     value TEXT NOT NULL,
//     is_primary BOOLEAN DEFAULT false,
//     created_at TIMESTAMPTZ DEFAULT NOW()
// );

// CREATE INDEX idx_contacts_shop_id ON shop_contacts(shop_id);

// -- 10. SHOP MEDIA (professional images, document images, etc.)
// CREATE TABLE shop_media (
//     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//     shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
//     media_type TEXT NOT NULL, -- 'logo', 'professional', 'document', 'award'
//     url TEXT NOT NULL,
//     sort_order INTEGER DEFAULT 0,
//     caption TEXT,
//     created_at TIMESTAMPTZ DEFAULT NOW()
// );

// CREATE INDEX idx_media_shop_id ON shop_media(shop_id);
// CREATE INDEX idx_media_type ON shop_media(media_type);

// -- 11. AMENITIES lookup table
// CREATE TABLE amenities (
//     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//     name TEXT NOT NULL UNIQUE,
//     icon_name TEXT,
//     category TEXT
// );

// -- 12. SHOP AMENITIES (junction)
// CREATE TABLE shop_amenities (
//     shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
//     amenity_id UUID REFERENCES amenities(id) ON DELETE CASCADE,
//     PRIMARY KEY (shop_id, amenity_id)
// );

// -- Optional: trigger to update updated_at timestamp
// CREATE OR REPLACE FUNCTION update_updated_at_column()
// RETURNS TRIGGER AS $$
// BEGIN
//     NEW.updated_at = NOW();
//     RETURN NEW;
// END;
// $$ LANGUAGE plpgsql;

// CREATE TRIGGER update_shops_updated_at
//     BEFORE UPDATE ON shops
//     FOR EACH ROW
//     EXECUTE FUNCTION update_updated_at_column();

// -- =====================================================
// -- SEED: Insert one complete shop with all relations
// -- =====================================================

// -- First, insert a shop
// INSERT INTO shops (
//     id, user_id, shop_name, shop_logo_url, verified, shop_type,
//     dynamic_link, terms, overview, no_booking, city, country, address, currency,
//     transfer_recipient_id, subaccount_id, account_type,
//     average_rating, number_clients_worked, is_paid_for_week,
//     is_main_shop, main_shop_id, luxury_level, show_on_explore_page
// ) VALUES (
//     '11111111-1111-1111-1111-111111111111', -- fixed UUID for easy reference
//     'auth_user_123',                          -- replace with actual auth user id later
//     'Luxe Beauty Salon',
//     'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=200',
//     true,
//     'salon',
//     'https://aura.app/luxe-beauty',
//     'Cancellation policy: 24h notice required. Deposits non-refundable.',
//     'Premium beauty salon in downtown offering haircuts, coloring, and spa services.',
//     false,
//     'New York',
//     'USA',
//     '123 5th Avenue, Suite 101',
//     'USD',
//     'recipient_123',
//     'subaccount_123',
//     'business',
//     4.8,
//     1250,
//     true,
//     true,
//     NULL,
//     'Premium',
//     true
// );

// -- Insert location
// INSERT INTO shop_locations (
//     id, shop_id, address, city, country, latitude, longitude, is_primary
// ) VALUES (
//     '11111111-1111-1111-1111-111111111112',
//     '11111111-1111-1111-1111-111111111111',
//     '123 5th Avenue, Suite 101',
//     'New York',
//     'USA',
//     40.7128,
//     -74.0060,
//     true
// );

// -- Insert workers (3 workers)
// INSERT INTO shop_workers (id, shop_id, name, bio, profile_image_url, is_active, specialties) VALUES
// (
//     '11111111-1111-1111-1111-111111111121',
//     '11111111-1111-1111-1111-111111111111',
//     'Sarah Johnson',
//     'Senior stylist with 8 years experience specializing in color and cuts.',
//     'https://images.unsplash.com/photo-1494790108777-28675f2b6f79?w=200',
//     true,
//     ARRAY['Haircut', 'Color', 'Styling']
// ),
// (
//     '11111111-1111-1111-1111-111111111122',
//     '11111111-1111-1111-1111-111111111111',
//     'Michael Chen',
//     'Master barber and beard specialist.',
//     'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
//     true,
//     ARRAY['Beard Trim', 'Fade', 'Hot Shave']
// ),
// (
//     '11111111-1111-1111-1111-111111111123',
//     '11111111-1111-1111-1111-111111111111',
//     'Jessica Williams',
//     'Color specialist and creative director.',
//     'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
//     true,
//     ARRAY['Balayage', 'Highlights', 'Color Correction']
// );

// -- Insert services (4 services)
// INSERT INTO shop_services (id, shop_id, name, description, duration, base_price, category, is_active) VALUES
// (
//     '11111111-1111-1111-1111-111111111131',
//     '11111111-1111-1111-1111-111111111111',
//     'Women''s Haircut',
//     'Wash, cut, and blow-dry style',
//     '45 minutes'::interval,
//     75.00,
//     'Hair',
//     true
// ),
// (
//     '11111111-1111-1111-1111-111111111132',
//     '11111111-1111-1111-1111-111111111111',
//     'Men''s Haircut',
//     'Wash and cut with clippers or scissors',
//     '30 minutes'::interval,
//     45.00,
//     'Hair',
//     true
// ),
// (
//     '11111111-1111-1111-1111-111111111133',
//     '11111111-1111-1111-1111-111111111111',
//     'Full Color',
//     'All-over color application',
//     '90 minutes'::interval,
//     120.00,
//     'Color',
//     true
// ),
// (
//     '11111111-1111-1111-1111-111111111134',
//     '11111111-1111-1111-1111-111111111111',
//     'Blowout',
//     'Wash and blow-dry styling',
//     '30 minutes'::interval,
//     35.00,
//     'Styling',
//     true
// );

// -- Insert appointment slots (2 slots)
// INSERT INTO shop_appointment_slots (
//     id, shop_id, service_id, type, duration, price, max_clients,
//     description, select_preferred_worker, days_of_week, is_recurring,
//     valid_from, valid_until
// ) VALUES
// (
//     '11111111-1111-1111-1111-111111111141',
//     '11111111-1111-1111-1111-111111111111',
//     '11111111-1111-1111-1111-111111111131', -- Women's Haircut
//     'in-person',
//     '45 minutes'::interval,
//     75.00,
//     1,
//     'Standard haircut appointment',
//     true,
//     ARRAY[1,2,3,4,5,6], -- Monday-Saturday
//     true,
//     '2024-01-01',
//     '2024-12-31'
// ),
// (
//     '11111111-1111-1111-1111-111111111142',
//     '11111111-1111-1111-1111-111111111111',
//     '11111111-1111-1111-1111-111111111132', -- Men's Haircut
//     'in-person',
//     '30 minutes'::interval,
//     45.00,
//     2,
//     'Men''s haircut - can book 2 at same time',
//     false,
//     ARRAY[1,2,3,4,5,6],
//     true,
//     '2024-01-01',
//     '2024-12-31'
// );

// -- Assign workers to slots
// INSERT INTO slot_worker_assignments (slot_id, worker_id, is_preferred) VALUES
// ('11111111-1111-1111-1111-111111111141', '11111111-1111-1111-1111-111111111121', true), -- Sarah for women's cut
// ('11111111-1111-1111-1111-111111111141', '11111111-1111-1111-1111-111111111123', false), -- Jessica also for women's cut
// ('11111111-1111-1111-1111-111111111142', '11111111-1111-1111-1111-111111111122', true); -- Michael for men's cut

// -- Insert social links
// INSERT INTO shop_social_links (id, shop_id, name, url) VALUES
// (
//     '11111111-1111-1111-1111-111111111151',
//     '11111111-1111-1111-1111-111111111111',
//     'Instagram',
//     'https://instagram.com/luxebeautynyc'
// ),
// (
//     '11111111-1111-1111-1111-111111111152',
//     '11111111-1111-1111-1111-111111111111',
//     'Facebook',
//     'https://facebook.com/luxebeautysalon'
// );

// -- Insert awards
// INSERT INTO shop_awards (id, shop_id, name, link, date_received, description) VALUES
// (
//     '11111111-1111-1111-1111-111111111161',
//     '11111111-1111-1111-1111-111111111111',
//     'Best Salon NYC 2023',
//     'https://bestofnyc.com/luxe-beauty',
//     '2023-11-15',
//     'Awarded Best Salon in Manhattan by City Guide'
// ),
// (
//     '11111111-1111-1111-1111-111111111162',
//     '11111111-1111-1111-1111-111111111111',
//     'Top Colorist Award',
//     'https://beautyawards.com/sarah-johnson',
//     '2023-09-20',
//     'Sarah Johnson won Top Colorist at the Beauty Excellence Awards'
// );

// -- Insert contacts
// INSERT INTO shop_contacts (id, shop_id, contact_type, value, is_primary) VALUES
// (
//     '11111111-1111-1111-1111-111111111171',
//     '11111111-1111-1111-1111-111111111111',
//     'phone',
//     '+12125551234',
//     true
// ),
// (
//     '11111111-1111-1111-1111-111111111172',
//     '11111111-1111-1111-1111-111111111111',
//     'email',
//     'hello@luxebeauty.com',
//     true
// ),
// (
//     '11111111-1111-1111-1111-111111111173',
//     '11111111-1111-1111-1111-111111111111',
//     'whatsapp',
//     '+12125551234',
//     false
// );

// -- Insert media (professional images and documents)
// INSERT INTO shop_media (id, shop_id, media_type, url, sort_order, caption) VALUES
// -- Professional images
// (
//     '11111111-1111-1111-1111-111111111181',
//     '11111111-1111-1111-1111-111111111111',
//     'professional',
//     'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=800',
//     1,
//     'Salon interior'
// ),
// (
//     '11111111-1111-1111-1111-111111111182',
//     '11111111-1111-1111-1111-111111111111',
//     'professional',
//     'https://images.unsplash.com/photo-1522338242992-e1a54906a8da?w=800',
//     2,
//     'Nail station'
// ),
// (
//     '11111111-1111-1111-1111-111111111183',
//     '11111111-1111-1111-1111-111111111111',
//     'professional',
//     'https://images.unsplash.com/photo-1487412948826-c4bacb7c887a?w=800',
//     3,
//     'Styling in progress'
// ),
// -- Document image
// (
//     '11111111-1111-1111-1111-111111111184',
//     '11111111-1111-1111-1111-111111111111',
//     'document',
//     'https://images.unsplash.com/photo-1586281380117-5a60ae2050cc?w=800',
//     1,
//     'Business license'
// );

// -- Insert amenities (if not already present)
// INSERT INTO amenities (id, name, icon_name, category) VALUES
// ('am111111-1111-1111-1111-111111111101', 'Free WiFi', 'wifi', 'general'),
// ('am111111-1111-1111-1111-111111111102', 'Parking', 'local_parking', 'general'),
// ('am111111-1111-1111-1111-111111111103', 'Wheelchair Access', 'accessible', 'accessibility'),
// ('am111111-1111-1111-1111-111111111104', 'Coffee/Tea', 'free_breakfast', 'refreshments'),
// ('am111111-1111-1111-1111-111111111105', 'Credit Cards Accepted', 'credit_card', 'payment')
// ON CONFLICT (name) DO NOTHING;

// -- Assign amenities to shop
// INSERT INTO shop_amenities (shop_id, amenity_id) VALUES
// ('11111111-1111-1111-1111-111111111111', 'am111111-1111-1111-1111-111111111101'),
// ('11111111-1111-1111-1111-111111111111', 'am111111-1111-1111-1111-111111111104'),
// ('11111111-1111-1111-1111-111111111111', 'am111111-1111-1111-1111-111111111105');

// -- =====================================================
// -- Verify the data with a query that joins everything
// -- =====================================================
// /*
// SELECT
//     s.shop_name,
//     l.address,
//     w.name as worker_name,
//     sv.name as service_name,
//     sl.days_of_week,
//     m.url as professional_image
// FROM shops s
// LEFT JOIN shop_locations l ON s.id = l.shop_id
// LEFT JOIN shop_workers w ON s.id = w.shop_id
// LEFT JOIN shop_services sv ON s.id = sv.shop_id
// LEFT JOIN shop_appointment_slots sl ON s.id = sl.shop_id
// LEFT JOIN shop_media m ON s.id = m.shop_id AND m.media_type = 'professional'
// WHERE s.id = '11111111-1111-1111-1111-111111111111';
// */























//   @override
 
 
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final freelancerAsync = ref.watch(
//       freelancerDetailsProvider(widget.freelancerId),
//     );



//     return Scaffold(
//       backgroundColor: colorScheme.surface,
//       body: freelancerAsync.when(
//         data: (freelancer) {
//           if (freelancer == null) {
//             return Center(
//               child: ErrorStateWidget(
//                 title: 'Freelancer Not Found',
//                 subtitle:
//                     'The requested freelancer profile could not be found.',
//                 onPrimaryAction: () => Navigator.pop(context),
//               ),
//             );
//           }
//           return CustomScrollView(
//             slivers: [
//               // App Bar with image
//               SliverAppBar(
//                 expandedHeight: 300.h,
//                 pinned: true,
//                 backgroundColor: colorScheme.surface,
//                 flexibleSpace: FlexibleSpaceBar(
//                   background: _buildHeaderImage(freelancer),
//                   collapseMode: CollapseMode.parallax,
//                 ),
//                 actions: [
//                   IconButton(
//                     icon: Icon(Icons.share, color: colorScheme.onSurface),
//                     onPressed: () => _shareProfile(freelancer),
//                   ),
//                 ],
//               ),

//               // Content
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: EdgeInsets.all(Spacing.lg.w),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Name and verification badges
//                       GestureDetector(
//                         onTap: () async {
//                           final editData = await ref.read(
//                             freelancerEditDataProvider(
//                               widget.freelancerId,
//                             ).future,
//                           );
//                           context.push(
//                             '/freelancerCreationDashboard',
//                             extra: {
//                               'shopId': freelancer.id,
//                               'mode': FreelancerMode.edit,
//                               'existingFreelancer': editData,
//                             },
//                           );
//                         },
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 freelancer.name,
//                                 style: theme.textTheme.headlineSmall?.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             if (freelancer.isIdentityVerified)
//                               _buildVerificationBadge(
//                                 icon: Icons.verified,
//                                 label: 'Identity Verified',
//                                 color: Colors.blue,
//                               ),
//                             if (freelancer.isBackgroundChecked)
//                               _buildVerificationBadge(
//                                 icon: Icons.shield,
//                                 label: 'Background Checked',
//                                 color: Colors.green,
//                               ),
//                           ],
//                         ),
//                       ),
//                       Gap(Spacing.sm.h),

//                       // Freelancer type
//                       if (freelancer.freelancerType != null)
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: Spacing.sm.w,
//                             vertical: Spacing.xs.h,
//                           ),
//                           decoration: BoxDecoration(
//                             color: colorScheme.primary.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8.r),
//                           ),
//                           child: Text(
//                             freelancer.freelancerType!.displayName,
//                             style: theme.textTheme.labelMedium?.copyWith(
//                               color: colorScheme.primary,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       Gap(Spacing.md.h),

//                       // Rating row
//                       Row(
//                         children: [
//                           // RatingStars(
//                           //   rating: freelancer.rating,
//                           //   size: 18,
//                           //   showNumber: true,
//                           // ),
//                           Gap(Spacing.sm.w),
//                           Text(
//                             '(${freelancer.totalReviews} reviews)',
//                             style: theme.textTheme.bodyMedium?.copyWith(
//                               color: colorScheme.onSurface.withOpacity(0.6),
//                             ),
//                           ),
//                         ],
//                       ),
//                       Gap(Spacing.md.h),

//                       // Bio
//                       if (freelancer.bio != null &&
//                           freelancer.bio!.isNotEmpty) ...[
//                         Text(
//                           'About',
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         Gap(Spacing.sm.h),
//                         Text(
//                           freelancer.bio!,
//                           style: theme.textTheme.bodyMedium,
//                         ),
//                         Gap(Spacing.lg.h),
//                       ],

//                       // Specialties
//                       if (freelancer.specialties.isNotEmpty) ...[
//                         Text(
//                           'Specialties',
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         Gap(Spacing.sm.h),
//                         Wrap(
//                           spacing: Spacing.sm.w,
//                           runSpacing: Spacing.sm.h,
//                           children:
//                               freelancer.specialties.map((specialty) {
//                                 return Container(
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: Spacing.md.w,
//                                     vertical: Spacing.sm.h,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: colorScheme.surfaceVariant,
//                                     borderRadius: BorderRadius.circular(20.r),
//                                   ),
//                                   child: Text(
//                                     specialty,
//                                     style: theme.textTheme.bodySmall,
//                                   ),
//                                 );
//                               }).toList(),
//                         ),
//                         Gap(Spacing.lg.h),
//                       ],

//                       // Tools & Equipment
//                       if (freelancer.tools.isNotEmpty) ...[
//                         Text(
//                           'Tools & Equipment',
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         Gap(Spacing.sm.h),
//                         Wrap(
//                           spacing: Spacing.sm.w,
//                           runSpacing: Spacing.sm.h,
//                           children:
//                               freelancer.tools.map((tool) {
//                                 return Chip(
//                                   label: Text(tool),
//                                   avatar: Icon(Icons.build, size: 16.h),
//                                 );
//                               }).toList(),
//                         ),
//                         Gap(Spacing.lg.h),
//                       ],

//                       // Service area info
//                       Container(
//                         padding: EdgeInsets.all(Spacing.md.h),
//                         decoration: BoxDecoration(
//                           color: colorScheme.surfaceVariant,
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.location_on, color: colorScheme.primary),
//                             Gap(Spacing.md.w),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Service Area',
//                                     style: theme.textTheme.titleSmall?.copyWith(
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   Text(
//                                     freelancer.canTravel
//                                         ? 'Travels up to ${freelancer.travelRadiusKm}km'
//                                         : 'Serves clients at fixed location',
//                                     style: theme.textTheme.bodySmall,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Gap(Spacing.lg.h),

//                       // Services
//                       FreelancerServiceList(freelancerId: widget.freelancerId),
//                       Gap(Spacing.lg.h),

//                       // Portfolio Gallery
//                       FreelancerPortfolioGallery(
//                         freelancerId: widget.freelancerId,
//                       ),
//                       Gap(Spacing.lg.h),

//                       // Reviews Section
//                       FreelancerReviewsSection(
//                         freelancerId: widget.freelancerId,
//                       ),
//                       Gap(Spacing.xl.h),

//                       // Book Button
//                       AppButton(
//                         label: 'Book Appointment',
//                         onPressed: () => _bookFreelancer(freelancer),
//                         width: double.infinity,
//                         height: 56.h,
//                         iconData: Icons.calendar_month,
//                       ),
//                       Gap(Spacing.xl.h),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//         loading:
//             () => const Center(
//               child: LoadingStateWidget(type: LoadingStateType.inline),
//             ),
//         error:
//             (error, stack) => Center(
//               child: ErrorStateWidget(
//                 title: 'Error Loading Profile',
//                 subtitle: error.toString(),
//                 onPrimaryAction: () {
//                   ref.invalidate(
//                     freelancerDetailsProvider(widget.freelancerId),
//                   );
//                 },
//               ),
//             ),
//       ),
//     );
//   }

//   Widget _buildHeaderImage(FreelancerDetailsDTO freelancer) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         if (freelancer.profileImageUrl != null)
//           Image.network(
//             freelancer.profileImageUrl!,
//             fit: BoxFit.cover,
//             errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
//           )
//         else
//           _buildPlaceholderImage(),
//         Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPlaceholderImage() {
//     return Container(
//       color: Colors.grey.shade300,
//       child: Center(
//         child: Icon(Icons.person, size: 80.sp, color: Colors.grey.shade500),
//       ),
//     );
//   }



//   void _shareProfile(FreelancerDetailsDTO freelancer) {
//     // TODO: Implement share functionality
//   }

//   void _bookFreelancer(FreelancerDetailsDTO freelancer) {
//     // Navigate to booking flow with freelancer ID
//     context.push('/booking/freelancer/${freelancer.id}');
//   }
// }
