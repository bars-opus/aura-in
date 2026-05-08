## Phase 1: Shop Management

## 🎯 Overview

The Shop Management system enables shop owners to create, manage, and publish their service businesses. It supports multi-step progressive disclosure forms, auto-save draft functionality, worker management, service definitions, opening hours, media galleries, and full CRUD operations for published shops.

**Dependencies**: Phase 0 (Foundation)

## 🏗️ Core Decisions

### 1. Multi-Step Form Pattern

**Decision**: Progressive disclosure with step-by-step form sections

**Why**:

- Reduces cognitive load for shop owners
- Prevents form abandonment
- Allows auto-saving between steps
- Validates sections progressively

### 2. Auto-Save Draft System

**Decision**: Local Hive storage with automatic persistence

**Why**:

- Prevents data loss from app crashes
- Enables resume-later functionality
- Reduces server load during editing
- Improves user experience

### 3. Settings-Based Dashboard Pattern

**Decision**: `SettingsConfig` pattern for consistent UI

**Why**:

- Reusable section and item components
- Unified interaction handling (navigation, toggle, action, link)
- Consistent styling across all configuration screens
- Easy to add new settings sections

## 📊 Data Models

### Shop Model

**Location**: `lib/features/shops/data/models/shop.dart`

| Field           | Type     | Description                   |
| --------------- | -------- | ----------------------------- |
| `id`            | String   | Unique shop identifier        |
| `userId`        | String   | Owner's user ID               |
| `shopName`      | String   | Business name                 |
| `shopType`      | String   | salon, barbershop, spa, etc.  |
| `luxuryLevel`   | String   | Moderate, Luxury, UltraLuxury |
| `description`   | String   | Business description          |
| `currencyCode`  | String   | GHS, NGN, USD, etc.           |
| `averageRating` | double   | Calculated from reviews       |
| `totalReviews`  | int      | Number of reviews             |
| `verified`      | bool     | Verification status           |
| `published`     | bool     | Publication status            |
| `createdAt`     | DateTime | Creation timestamp            |
| `updatedAt`     | DateTime | Last update timestamp         |

### Worker Model

**Location**: `lib/features/shops/data/models/worker.dart`

| Field           | Type         | Description              |
| --------------- | ------------ | ------------------------ |
| `id`            | String       | Worker unique ID         |
| `userId`        | String       | Reference to auth user   |
| `displayName`   | String       | Worker's display name    |
| `avatarUrl`     | String?      | Profile image URL        |
| `bio`           | String?      | Worker biography         |
| `specialties`   | List<String> | Service specialties      |
| `averageRating` | double       | Worker's rating          |
| `totalBookings` | int          | Completed bookings count |

### Appointment Slot Model

**Location**: `lib/features/shops/data/models/appointment_slot_model.dart`

| Field                 | Type    | Description               |
| --------------------- | ------- | ------------------------- |
| `id`                  | String  | Slot unique ID            |
| `shopId`              | String  | Parent shop ID            |
| `name`                | String  | Service name              |
| `description`         | String? | Service description       |
| `durationMinutes`     | int     | Duration in minutes       |
| `price`               | double  | Service price             |
| `maxClients`          | int     | Max clients per booking   |
| `bufferBeforeMinutes` | int     | Buffer before appointment |
| `bufferAfterMinutes`  | int     | Buffer after appointment  |
| `isActive`            | bool    | Availability status       |

### Opening Hours Model

**Location**: `lib/features/shops/data/models/opening_hours_dto.dart`

| Field       | Type    | Description            |
| ----------- | ------- | ---------------------- |
| `dayOfWeek` | int     | 0=Sunday to 6=Saturday |
| `isClosed`  | bool    | Shop closed this day   |
| `openTime`  | String? | HH:MM format           |
| `closeTime` | String? | HH:MM format           |

## 🗄️ Database Schema

### Shops Table

```sql
CREATE TABLE shops (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  shop_name TEXT NOT NULL,
  shop_type TEXT NOT NULL,
  luxury_level TEXT NOT NULL,
  description TEXT,
  currency_code TEXT DEFAULT 'GHS',
  average_rating DECIMAL(3,2) DEFAULT 0,
  total_reviews INTEGER DEFAULT 0,
  verified BOOLEAN DEFAULT false,
  published BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_shops_user_id ON shops(user_id);
CREATE INDEX idx_shops_published ON shops(published);
CREATE INDEX idx_shops_shop_type ON shops(shop_type);
```

### Workers Table

```sql
CREATE TABLE workers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  avatar_url TEXT,
  bio TEXT,
  specialties TEXT[],
  average_rating DECIMAL(3,2) DEFAULT 0,
  total_bookings INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_workers_user_id ON workers(user_id);
```

### Shop Workers Junction Table

```sql
CREATE TABLE shop_workers (
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
  worker_id UUID REFERENCES workers(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'staff', -- staff, manager, admin
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true,
  PRIMARY KEY (shop_id, worker_id)
);

CREATE INDEX idx_shop_workers_shop_id ON shop_workers(shop_id);
CREATE INDEX idx_shop_workers_worker_id ON shop_workers(worker_id);
```

### Appointment Slots Table

```sql
CREATE TABLE appointment_slots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  duration_minutes INTEGER NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  max_clients INTEGER DEFAULT 1,
  buffer_before_minutes INTEGER DEFAULT 0,
  buffer_after_minutes INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_appointment_slots_shop_id ON appointment_slots(shop_id);
```

### Slot Worker Assignments Table

```sql
CREATE TABLE slot_worker_assignments (
  slot_id UUID REFERENCES appointment_slots(id) ON DELETE CASCADE,
  worker_id UUID REFERENCES workers(id) ON DELETE CASCADE,
  PRIMARY KEY (slot_id, worker_id)
);
```

### Shop Opening Hours Table

```sql
CREATE TABLE shop_opening_hours (
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
  day_of_week INTEGER CHECK (day_of_week BETWEEN 0 AND 6),
  is_closed BOOLEAN DEFAULT false,
  open_time TIME,
  close_time TIME,
  PRIMARY KEY (shop_id, day_of_week)
);
```

### Shop Media Table

```sql
CREATE TABLE shop_media (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  type TEXT NOT NULL, -- 'image' or 'document'
  media_category TEXT, -- 'profile', 'gallery', 'license', 'certificate'
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_shop_media_shop_id ON shop_media(shop_id);
```

### Shop Contacts Table

```sql
CREATE TABLE shop_contacts (
  shop_id UUID PRIMARY KEY REFERENCES shops(id) ON DELETE CASCADE,
  phone TEXT,
  email TEXT,
  website TEXT,
  address TEXT,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8)
);
```

### Shop Social Links Table

```sql
CREATE TABLE shop_social_links (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
  platform TEXT NOT NULL, -- 'instagram', 'facebook', 'twitter', 'tiktok'
  url TEXT NOT NULL,
  UNIQUE(shop_id, platform)
);
```

### Shop Amenities Table

```sql
CREATE TABLE shop_amenities (
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
  amenity TEXT NOT NULL,
  PRIMARY KEY (shop_id, amenity)
);
```

### Row Level Security (RLS) Policies

```sql
-- Public read access for published shops
CREATE POLICY "Public can view published shops" ON shops
  FOR SELECT USING (published = true);

-- Authenticated users can read their own shops
CREATE POLICY "Users can view their own shops" ON shops
  FOR SELECT USING (auth.uid() = user_id);

-- Authenticated users can insert their own shops
CREATE POLICY "Users can insert their own shops" ON shops
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Authenticated users can update their own shops
CREATE POLICY "Users can update their own shops" ON shops
  FOR UPDATE USING (auth.uid() = user_id);
```

## 📂 Repository Layer

### Shop Repository Interface

**Location**: `lib/features/shops/domain/repositories/shop_repository.dart`

```dart
abstract class ShopRepository {
  // Create
  Future<Shop> createShop(ShopDraft draft);

  // Read
  Future<Shop?> getShop(String shopId);
  Future<List<ShopListItemDTO>> getShops({
    ShopQueryParams? params,
    String? cursor,
    int limit,
  });

  // Update
  Future<Shop> updateShop(String shopId, ShopDraft draft);

  // Delete
  Future<void> deleteShop(String shopId);

  // Publish
  Future<void> publishShop(String shopId);

  // Workers
  Future<List<Worker>> getWorkers(String shopId);
  Future<void> inviteWorker(String shopId, String email, String role);
  Future<void> updateWorkerRole(String shopId, String workerId, String role);
  Future<void> removeWorker(String shopId, String workerId);

  // Services
  Future<List<AppointmentSlot>> getServices(String shopId);
  Future<AppointmentSlot> addService(String shopId, CreateServiceDto dto);
  Future<AppointmentSlot> updateService(String serviceId, UpdateServiceDto dto);
  Future<void> deleteService(String serviceId);

  // Opening Hours
  Future<List<OpeningHoursDto>> getOpeningHours(String shopId);
  Future<void> updateOpeningHours(String shopId, List<OpeningHoursDto> hours);

  // Media
  Future<List<ShopMediaDto>> getMedia(String shopId);
  Future<void> addMedia(String shopId, List<File> images);
  Future<void> deleteMedia(String mediaId);
  Future<void> reorderMedia(String shopId, List<String> mediaIds);
}
```

### Supabase Shop Repository Implementation

**Location**: `lib/features/shops/data/repositories/supabase_shop_repository.dart`

**Key Methods**:

| Method         | Implementation Details                                              |
| -------------- | ------------------------------------------------------------------- |
| `createShop`   | Inserts into `shops` table, handles related inserts transactionally |
| `updateShop`   | Updates main table plus related tables with upserts                 |
| `getShops`     | Uses cursor-based pagination, joins with location and rating data   |
| `inviteWorker` | Creates entry in `shop_workers`, sends email notification           |
| `addService`   | Inserts into `appointment_slots`, validates worker assignments      |

## 🧠 State Management

### Provider Hierarchy

**Location**: `lib/features/shops/presentation/providers/`

| Provider                 | Type           | Purpose                           |
| ------------------------ | -------------- | --------------------------------- |
| `shopRepositoryProvider` | Provider       | Singleton repository instance     |
| `shopDraftProvider`      | StateNotifier  | Manages in-progress shop creation |
| `shopDetailsProvider`    | FutureProvider | Fetches single shop by ID         |
| `shopListProvider`       | FutureProvider | Paginated shop list with filters  |
| `workersProvider`        | FutureProvider | List of workers for a shop        |
| `servicesProvider`       | FutureProvider | List of services for a shop       |
| `openingHoursProvider`   | FutureProvider | Opening hours for a shop          |
| `mediaProvider`          | FutureProvider | Media gallery for a shop          |

### Shop Draft State

**Location**: `lib/features/shops/presentation/providers/shop_draft_provider.dart`

```dart
class ShopDraftState {
  final String? shopId;
  final Map<String, dynamic> data;
  final bool isSaving;
  final DateTime? lastSaved;
  final List<String> validationErrors;

  ShopDraftState({
    this.shopId,
    required this.data,
    this.isSaving = false,
    this.lastSaved,
    this.validationErrors = const [],
  });

  // Helper methods
  bool get isValid => validationErrors.isEmpty;
  bool get isNewShop => shopId == null;
}
```

### Auto-Save Implementation

```dart
class ShopDraftNotifier extends StateNotifier<ShopDraftState> {
  final ShopRepository _repository;
  Timer? _debounceTimer;

  Future<void> updateField(String key, dynamic value) async {
    // Update state immediately
    state = ShopDraftState(
      data: {...state.data, key: value},
      isSaving: true,
    );

    // Debounce save (500ms)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      await _saveDraft();
    });
  }

  Future<void> _saveDraft() async {
    try {
      if (state.isNewShop) {
        final draftId = await _repository.saveDraft(state.data);
        state = ShopDraftState(shopId: draftId, data: state.data);
      } else {
        await _repository.updateDraft(state.shopId!, state.data);
      }
      state = ShopDraftState(
        shopId: state.shopId,
        data: state.data,
        lastSaved: DateTime.now(),
      );
    } catch (e) {
      // Handle error
    }
  }
}
```

## 🎨 UI Components

### Shop Creation Flow Screens

**Location**: `lib/features/shops/presentation/screens/creation/`

| Screen                   | Step | Content                          |
| ------------------------ | ---- | -------------------------------- |
| `BasicInfoScreen`        | 1    | Shop name, type, luxury level    |
| `LocationCurrencyScreen` | 2    | Address, country, currency       |
| `ServicesScreen`         | 3    | Service definitions with workers |
| `OpeningHoursScreen`     | 4    | Daily operating hours            |
| `MediaScreen`            | 5    | Images (3-5) with drag reorder   |
| `ContactsScreen`         | 6    | Phone, email, website            |
| `SocialLinksScreen`      | 7    | Instagram, Facebook, Twitter     |
| `AmenitiesScreen`        | 8    | Checklist from database          |
| `AwardsScreen`           | 9    | Awards and recognitions          |
| `DocumentsScreen`        | 10   | Licenses, certifications         |
| `ReviewPublishScreen`    | 11   | Summary and publish              |

### Settings-Based Dashboard Pattern

**Location**: `lib/presentation/shared/widgets/settings/`

**SettingsConfig**:

```dart
class SettingsSection {
  final String title;
  final List<SettingsItem> items;

  SettingsSection({required this.title, required this.items});
}

class SettingsItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final SettingsItemType type;
  final VoidCallback? onTap;
  final bool? value;
  final ValueChanged<bool>? onChanged;

  SettingsItem({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.type,
    this.onTap,
    this.value,
    this.onChanged,
  });
}

enum SettingsItemType {
  navigation,   // Navigates to another screen
  toggle,       // Switch widget
  action,       // Performs an action
  link,         // Opens external URL
}
```

**Usage Example**:

```dart
SettingsSection(
  title: 'Shop Settings',
  items: [
    SettingsItem(
      title: 'Edit Profile',
      icon: Icons.edit,
      type: SettingsItemType.navigation,
      onTap: () => context.push('/shop/edit'),
    ),
    SettingsItem(
      title: 'Published',
      icon: Icons.public,
      type: SettingsItemType.toggle,
      value: shop.published,
      onChanged: (value) => togglePublish(value),
    ),
  ],
)
```

### Key Widgets

| Widget             | Location                                                          | Purpose                             |
| ------------------ | ----------------------------------------------------------------- | ----------------------------------- |
| `ShopCard`         | `lib/features/shops/presentation/widgets/shop_card.dart`          | Displays shop in list views         |
| `WorkerCard`       | `lib/features/shops/presentation/widgets/worker_card.dart`        | Worker profile display              |
| `ServiceCard`      | `lib/features/shops/presentation/widgets/service_card.dart`       | Service display with price/duration |
| `OpeningHoursRow`  | `lib/features/shops/presentation/widgets/opening_hours_row.dart`  | Day/hour display with toggle        |
| `ImageReorderGrid` | `lib/features/shops/presentation/widgets/image_reorder_grid.dart` | Drag-to-reorder images              |
| `CurrencyPicker`   | `lib/features/shops/presentation/widgets/currency_picker.dart`    | Searchable currency selector        |

## 🔄 Key Flows

### Shop Creation Flow

```
User clicks "Create Shop"
        ↓
Load draft from Hive (if exists)
        ↓
Step 1: Basic Info → Auto-save to Hive
        ↓
Step 2: Location & Currency → Auto-save
        ↓
Step 3: Services → Add/remove services → Assign workers
        ↓
Step 4: Opening Hours → Time picker for each day
        ↓
Step 5: Media → Upload 3-5 images → Drag to reorder
        ↓
Step 6: Contacts → Phone, email, website
        ↓
Step 7: Social Links → Platform + URL pairs
        ↓
Step 8: Amenities → Toggle checklist items
        ↓
Step 9: Awards → Add/remove award entries
        ↓
Step 10: Documents → Upload licenses/certificates
        ↓
Step 11: Review & Publish → Submit to Supabase
        ↓
Clear draft from Hive → Navigate to Shop Dashboard
```

### Worker Invitation Flow

```
Shop owner clicks "Invite Worker"
        ↓
Search workers by email or display name
        ↓
Select worker → Choose role (staff/manager/admin)
        ↓
Send invitation → Create shop_workers entry
        ↓
Worker receives notification (email/in-app)
        ↓
Worker accepts → shop_workers.is_active = true
        ↓
Worker now assignable to services
```

### Edit Shop Flow

```
User navigates to Shop Dashboard
        ↓
Click "Edit Shop"
        ↓
Load shop data from Supabase
        ↓
Convert to ShopDraft format
        ↓
User edits sections (same steps as creation)
        ↓
Changes auto-save locally
        ↓
User clicks "Save & Publish"
        ↓
Update Supabase with full object
        ↓
Refresh UI with updated data
```

## 🔐 Currency System

### Auto-Detection

| Country        | Currency Code | Flag Emoji |
| -------------- | ------------- | ---------- |
| Ghana          | GHS           | 🇬🇭         |
| Nigeria        | NGN           | 🇳🇬         |
| Kenya          | KES           | 🇰🇪         |
| South Africa   | ZAR           | 🇿🇦         |
| United States  | USD           | 🇺🇸         |
| United Kingdom | GBP           | 🇬🇧         |
| European Union | EUR           | 🇪🇺         |

**Features**:

- Auto-detection from location service
- Flag emoji for visual identification
- Searchable currency picker for manual override
- SharedPreferences persistence across sessions

## 📦 Dependencies Added in Phase 1

```yaml
dependencies:
  # Local Storage for Drafts
  hive_flutter: ^1.1.0
  path_provider: ^2.1.0

  # Image Handling
  image_picker: ^1.0.4
  file_picker: ^5.3.0

  # Drag and Drop
  reorderables: ^0.6.0

  # Form Utilities
  flutter_form_builder: ^9.1.0

  # Time Pickers
  time_picker_sheet: ^0.0.3
```

## 📁 Phase 1 Folder Structure

```
lib/features/shops/
├── data/
│   ├── dtos/
│   │   ├── shop_list_item_dto.dart
│   │   ├── shop_details_dto.dart
│   │   ├── shop_media_dto.dart
│   │   ├── appointment_slot_dto.dart
│   │   └── opening_hours_dto.dart
│   ├── models/
│   │   ├── shop.dart
│   │   ├── worker.dart
│   │   ├── appointment_slot_model.dart
│   │   ├── luxury_level_info.dart
│   │   └── shop_type_count.dart
│   ├── repositories/
│   │   ├── shop_repository.dart
│   │   └── supabase_shop_repository.dart
│   └── local/
│       └── shop_draft_storage.dart
├── domain/
│   ├── entities/
│   │   └── shop.dart
│   └── repositories/
│       └── shop_repository.dart
└── presentation/
    ├── providers/
    │   ├── shop_repository_provider.dart
    │   ├── shop_draft_provider.dart
    │   ├── shop_details_provider.dart
    │   ├── shop_list_provider.dart
    │   ├── workers_provider.dart
    │   ├── services_provider.dart
    │   └── luxury_level_provider.dart
    ├── screens/
    │   ├── creation/
    │   │   ├── basic_info_screen.dart
    │   │   ├── location_currency_screen.dart
    │   │   ├── services_screen.dart
    │   │   ├── opening_hours_screen.dart
    │   │   ├── media_screen.dart
    │   │   ├── contacts_screen.dart
    │   │   ├── social_links_screen.dart
    │   │   ├── amenities_screen.dart
    │   │   ├── awards_screen.dart
    │   │   ├── documents_screen.dart
    │   │   └── review_publish_screen.dart
    │   ├── edit/
    │   │   └── edit_shop_screen.dart
    │   └── dashboard/
    │       └── shop_dashboard_screen.dart
    └── widgets/
        ├── shop_card.dart
        ├── worker_card.dart
        ├── service_card.dart
        ├── opening_hours_row.dart
        ├── image_reorder_grid.dart
        ├── currency_picker.dart
        ├── luxury_level_chips.dart
        ├── shop_rating_widget.dart
        └── shop_shimmer_skeleton.dart
```

## ⏭️ Next Phase

**Phase 2: Discovery & Search**, which implements map-based shop discovery, location services, and unified search functionality.
