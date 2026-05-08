## Phase 5: Calendar & Schedule

## 🎯 Overview

The Calendar & Schedule system provides a unified calendar view that adapts to both client and shop owner roles. Clients see their personal booking history and upcoming appointments. Shop owners see their shop's schedule across multiple workers. The system includes month view with appointment indicators, day view with detailed appointments, a 15-day horizontal date selector for daily schedules, time-based filtering (Morning/Afternoon/Evening), and intelligent caching with pre-fetching for smooth scrolling.

**Dependencies**: Phase 0 (Foundation), Phase 1 (Shop Management), Phase 3 (Booking System)

## 🏗️ Core Decisions

### 1. Unified Calendar Component

**Decision**: Single calendar widget that adapts based on user role

**Why**:

- Reduces code duplication
- Consistent user experience across roles
- Automatic role detection from user's shops
- Seamless switching between personal and business views

### 2. Role-Based Data Sources

**Decision**: Different data providers for client vs shop owner

**Why**:

- Clients fetch from `bookings` table (client_id filter)
- Shop owners fetch from `booking_services` table (shop_id via worker assignment)
- Shop owners see all workers' appointments
- Clients see only their own appointments

### 3. On-Demand Fetching with Caching

**Decision**: Fetch appointments when date is selected, cache results

**Why**:

- Reduces unnecessary API calls
- Improves perceived performance
- Adjacent dates pre-fetched in background
- Cache invalidated on booking changes

### 4. Three-Tier Appointment Display

**Decision**: Month dots → Day bottom sheet → Month list

**Why**:

- Month view: Status-colored dots (1 per appointment, "5+" for >5)
- Tap date: Bottom sheet shows all appointments for that day
- Below calendar: Month list shows ALL appointments for current month, newest to oldest
- Provides multiple access points to appointment data

### 5. Time Group Filtering

**Decision**: Horizontal chips for Morning, Afternoon, Evening

**Why**:

- Shop owners quickly filter daily schedule
- Reduces cognitive load on busy days
- Configurable time ranges per group
- Persists selected filter during session

## 📊 Data Models

**Location**: `lib/features/calendar/data/models/`

| Model                          | Purpose                                                                   |
| ------------------------------ | ------------------------------------------------------------------------- |
| `client_calendar_booking.dart` | Client's booking with shop info, services list, status color helper       |
| `shop_calendar_booking.dart`   | Shop's booking with client info, worker assignment, time range formatting |
| `time_group.dart`              | Morning/Afternoon/Evening enum with time ranges and icons                 |
| `grouped_appointments.dart`    | Groups appointments by time group for daily schedule view                 |

## 🗄️ Database Schema

### Client Bookings View

```sql
CREATE VIEW client_calendar_bookings AS
SELECT
  b.id, b.shop_id, s.shop_name, s.cover_image_url as shop_cover_image,
  b.booking_date, b.status, b.total_amount, b.deposit_amount,
  jsonb_agg(
    jsonb_build_object(
      'service_id', bs.service_id, 'service_name', bs.service_name,
      'quantity', bs.quantity, 'start_time', bs.start_time,
      'end_time', bs.end_time, 'worker_name', bs.assigned_worker_name
    )
  ) as services
FROM bookings b
INNER JOIN shops s ON s.id = b.shop_id
INNER JOIN booking_services bs ON bs.booking_id = b.id
GROUP BY b.id, s.shop_name, s.cover_image_url;
```

### Shop Calendar View

```sql
CREATE VIEW shop_calendar_bookings AS
SELECT
  bs.id as booking_service_id, bs.booking_id, b.client_id,
  p.display_name as client_name, p.avatar_url as client_avatar,
  bs.service_id, bs.service_name, bs.quantity,
  bs.start_time, bs.end_time,
  bs.assigned_worker_id as worker_id, w.display_name as worker_name,
  b.status, bs.total_price as price
FROM booking_services bs
INNER JOIN bookings b ON b.id = bs.booking_id
INNER JOIN profiles p ON p.id = b.client_id
INNER JOIN workers w ON w.id = bs.assigned_worker_id
WHERE b.status NOT IN ('cancelled')
ORDER BY bs.start_time;
```

### User Shops View (for multi-shop owners)

```sql
CREATE VIEW user_shops_with_workers AS
SELECT sw.shop_id, s.shop_name, sw.worker_id, w.display_name as worker_name,
       w.avatar_url as worker_avatar, sw.role, u.id as user_id
FROM shop_workers sw
INNER JOIN shops s ON s.id = sw.shop_id
INNER JOIN workers w ON w.id = sw.worker_id
INNER JOIN users u ON u.id = w.user_id;
```

### Monthly Appointment Count Function

```sql
CREATE OR REPLACE FUNCTION get_monthly_appointment_counts(
  p_user_id UUID, p_year INTEGER, p_month INTEGER
)
RETURNS TABLE(day INTEGER, count INTEGER, status_colors JSONB)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
  SELECT EXTRACT(DAY FROM b.booking_date)::INTEGER as day,
         COUNT(*)::INTEGER as count,
         jsonb_object_agg(DISTINCT b.status, COUNT(*) FILTER (WHERE b.status = status)) as status_colors
  FROM bookings b
  WHERE b.client_id = p_user_id
    AND EXTRACT(YEAR FROM b.booking_date) = p_year
    AND EXTRACT(MONTH FROM b.booking_date) = p_month
  GROUP BY EXTRACT(DAY FROM b.booking_date)
  ORDER BY day;
END;
$$;
```

## 📂 Repository Layer

### Calendar Repository Interface

**Location**: `lib/features/calendar/domain/repositories/calendar_repository.dart`

| Method                        | Purpose                                                         |
| ----------------------------- | --------------------------------------------------------------- |
| `getClientBookingsForMonth()` | Fetch all client bookings for a specific month                  |
| `getClientBookingsForDate()`  | Fetch client bookings for a single day                          |
| `getShopBookingsForDate()`    | Fetch shop bookings for a date, with optional time group filter |
| `getShopBookingsForMonth()`   | Fetch all shop bookings for a month                             |
| `isShopOwner()`               | Check if user owns any shops                                    |
| `getUserShops()`              | Get list of shops user owns or works at                         |
| `saveSelectedShop()`          | Persist selected shop for multi-shop owners                     |
| `getSelectedShop()`           | Retrieve persisted selected shop                                |

### Daily Schedule Repository Interface

**Location**: `lib/features/shop_daily_schedule/data/repositories/daily_schedule_repository.dart`

| Method                      | Purpose                                              |
| --------------------------- | ---------------------------------------------------- |
| `getAppointmentsForDate()`  | Fetch appointments for a date with in-memory caching |
| `preFetchAdjacentDates()`   | Background pre-fetch of yesterday and tomorrow       |
| `getAppointment()`          | Fetch single appointment by ID                       |
| `updateAppointmentStatus()` | Update status (complete, cancel, no-show)            |
| `invalidateCache()`         | Clear cache for specific date                        |
| `clearAllCache()`           | Clear entire appointment cache                       |

## 🧠 State Management

### Calendar Providers

**Location**: `lib/features/calendar/domain/providers/calendar_provider.dart`

| Provider                     | Type                  | Purpose                                 |
| ---------------------------- | --------------------- | --------------------------------------- |
| `calendarRepositoryProvider` | Provider              | Singleton repository instance           |
| `isShopOwnerProvider`        | FutureProvider        | Role detection for current user         |
| `userShopsProvider`          | FutureProvider        | List of shops for multi-shop owners     |
| `selectedShopIdProvider`     | StateNotifierProvider | Persisted selected shop across sessions |
| `monthAppointmentsProvider`  | FutureProvider        | Appointments for calendar month view    |
| `dayAppointmentsProvider`    | FutureProvider        | Appointments for day bottom sheet       |

### Daily Schedule Providers

**Location**: `lib/features/shop_daily_schedule/domain/providers/daily_schedule_provider.dart`

| Provider                           | Type                  | Purpose                                          |
| ---------------------------------- | --------------------- | ------------------------------------------------ |
| `dailyScheduleRepositoryProvider`  | Provider              | Singleton repository instance                    |
| `selectedDateProvider`             | StateProvider         | Currently selected date in date selector         |
| `selectedTimeGroupProvider`        | StateProvider         | Morning/Afternoon/Evening filter                 |
| `selectedDateAppointmentsProvider` | FutureProvider        | Auto-refreshing appointments for selected date   |
| `dailyScheduleControllerProvider`  | StateNotifierProvider | Actions: mark complete, cancel, no-show, refresh |

## 🎨 UI Components (Paths Only)

### Calendar Screens

| Screen                | Path                                                                               | Purpose                                        |
| --------------------- | ---------------------------------------------------------------------------------- | ---------------------------------------------- |
| `CalendarScreen`      | `lib/features/calendar/presentation/screens/calendar_screen.dart`                  | Main calendar with role detection and tab bar  |
| `DailyScheduleScreen` | `lib/features/shop_daily_schedule/presentation/screens/daily_schedule_screen.dart` | Shop owner's daily schedule view               |
| `ShopScheduleHub`     | `lib/features/shop_daily_schedule/presentation/screens/shop_schedule_hub.dart`     | Container for date selector + appointment list |

### Calendar Widgets

| Widget                  | Path                                                                      | Purpose                                          |
| ----------------------- | ------------------------------------------------------------------------- | ------------------------------------------------ |
| `CalendarMonthView`     | `lib/features/calendar/presentation/widgets/calendar_month_view.dart`     | TableCalendar with custom dot markers            |
| `DayAppointmentsSheet`  | `lib/features/calendar/presentation/widgets/day_appointments_sheet.dart`  | Bottom sheet showing all appointments for a date |
| `MonthAppointmentsList` | `lib/features/calendar/presentation/widgets/month_appointments_list.dart` | Scrollable list of all month appointments        |
| `ShopSelectorDropdown`  | `lib/features/calendar/presentation/widgets/shop_selector_dropdown.dart`  | Dropdown for multi-shop owners                   |
| `AppointmentCard`       | `lib/features/calendar/presentation/widgets/appointment_card.dart`        | Individual appointment display card              |

### Daily Schedule Widgets

| Widget                   | Path                                                                                  | Purpose                                       |
| ------------------------ | ------------------------------------------------------------------------------------- | --------------------------------------------- |
| `HorizontalDateSelector` | `lib/features/shop_daily_schedule/presentation/widgets/horizontal_date_selector.dart` | 15-day horizontal scrollable date picker      |
| `TimeGroupFilterChips`   | `lib/features/shop_daily_schedule/presentation/widgets/time_group_filter_chips.dart`  | Morning/Afternoon/Evening filter chips        |
| `AppointmentCard`        | `lib/features/shop_daily_schedule/presentation/widgets/appointment_card.dart`         | Daily schedule appointment with actions       |
| `AppointmentBottomSheet` | `lib/features/shop_daily_schedule/presentation/widgets/appointment_bottom_sheet.dart` | Detailed appointment view with action buttons |
| `EmptyScheduleWidget`    | `lib/features/shop_daily_schedule/presentation/widgets/empty_schedule_widget.dart`    | Empty state for no appointments               |

## 🔄 Key Flows

### Client Calendar Flow

```
User opens Calendar Screen
        ↓
isShopOwnerProvider checks user role
        ↓
If false → build client calendar view
        ↓
CalendarMonthView shows month grid with dot indicators
        ↓
User taps date → DayAppointmentsSheet bottom sheet
        ↓
User taps appointment → Navigate to BookingDetailScreen
```

### Shop Owner Calendar Flow

```
User opens Calendar Screen
        ↓
isShopOwnerProvider returns true
        ↓
userShopsProvider loads shop list
        ↓
ShopSelectorDropdown appears in AppBar
        ↓
selectedShopIdProvider persists selection
        ↓
ShopScheduleHub loads with HorizontalDateSelector
        ↓
Selected date shows TimeGroupFilterChips + appointment list
        ↓
User taps appointment → AppointmentBottomSheet with actions
```

### Daily Schedule Data Flow

```
HorizontalDateSelector date selected
        ↓
selectedDateProvider updates
        ↓
selectedDateAppointmentsProvider auto-refreshes
        ↓
Check cache → if exists return cached
        ↓
If not cached → fetch from Supabase → store in cache
        ↓
Pre-fetch adjacent dates in background
        ↓
Apply time group filter (if selected)
        ↓
Render filtered appointment list
```

### Appointment Status Update Flow

```
Shop owner clicks action button (Complete/Cancel/No-Show)
        ↓
dailyScheduleControllerProvider calls appropriate method
        ↓
Repository updates booking_services status
        ↓
Invalidate cache for affected date
        ↓
Refresh selectedDateAppointmentsProvider
        ↓
UI updates with new status badge
```

## 📦 Dependencies Added in Phase 5

```yaml
dependencies:
  table_calendar: ^3.0.9
  intl: ^0.18.1
```

## 📁 Phase 5 Folder Structure

```
lib/features/calendar/
├── data/
│   ├── models/
│   │   ├── client_calendar_booking.dart
│   │   ├── shop_calendar_booking.dart
│   │   ├── time_group.dart
│   │   └── grouped_appointments.dart
│   └── repositories/
│       └── supabase_calendar_repository.dart
├── domain/
│   ├── providers/
│   │   └── calendar_provider.dart
│   └── repositories/
│       └── calendar_repository.dart
└── presentation/
    ├── screens/
    │   └── calendar_screen.dart
    └── widgets/
        ├── calendar_month_view.dart
        ├── day_appointments_sheet.dart
        ├── month_appointments_list.dart
        └── shop_selector_dropdown.dart

lib/features/shop_daily_schedule/
├── data/
│   ├── models/
│   │   ├── time_group.dart
│   │   └── grouped_appointments.dart
│   └── repositories/
│       └── supabase_daily_schedule_repository.dart
├── domain/
│   ├── providers/
│   │   └── daily_schedule_provider.dart
│   └── repositories/
│       └── daily_schedule_repository.dart
└── presentation/
    ├── screens/
    │   ├── daily_schedule_screen.dart
    │   └── shop_schedule_hub.dart
    └── widgets/
        ├── horizontal_date_selector.dart
        ├── time_group_filter_chips.dart
        ├── appointment_card.dart
        ├── appointment_bottom_sheet.dart
        └── empty_schedule_widget.dart
```

## ⏭️ Next Phase

**Phase 6: Shop Owner Dashboard**, which implements KPI metrics, revenue tracking, top services/workers analytics, booking heatmap, client management, and CSV export.
