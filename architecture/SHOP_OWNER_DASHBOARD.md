



## 🎯 Overview

The Shop Owner Dashboard provides comprehensive analytics and management tools for shop owners. It includes real-time KPI cards (today's revenue, bookings count, occupancy rate, cancellation rate), revenue tracking with percentage change comparisons, top services and workers analytics, booking heatmap visualization, client management with search and statistics, worker attendance tracking, and CSV export functionality for revenue, bookings, and client data.

**Dependencies**: Phase 0 (Foundation), Phase 1 (Shop Management), Phase 3 (Booking System), Phase 4 (Payment & Wallet)

## 🏗️ Core Decisions

### 1. Multi-Tab Dashboard Architecture

**Decision**: Tab-based dashboard with five main sections (Overview, Analytics, Clients, Staff, Tools)

**Why**:

- Organizes complex functionality into manageable sections
- Reduces cognitive load for shop owners
- Each tab can be independently refreshed
- Persistent state between tab switches

### 2. Real-Time KPI Updates

**Decision**: Stream-based providers for real-time metric updates

**Why**:

- Shop owners see immediate impact of completed bookings
- Uses Supabase real-time subscriptions
- Reduces manual refresh needs
- Improves perceived responsiveness

### 3. Parallel Data Fetching

**Decision**: Fetch all dashboard data concurrently using `Future.wait`

**Why**:

- Reduces total loading time
- Independent error handling per data source
- Progressive rendering as data arrives
- Better user experience on slow connections

### 4. Date Range Utilities Pattern

**Decision**: Centralized `DateRangeUtils` class for consistent date period calculations

**Why**:

- Ensures consistent date ranges across all analytics
- Supports daily, weekly, monthly, quarterly, and custom ranges
- Automatically sets end dates to 23:59:59 for proper inclusion
- Single source of truth for date calculations

### 5. Provider Families for Parameterized State

**Decision**: Provider families with type-safe parameter classes

**Why**:

- Supports multiple shops in same app instance
- Type-safe parameter passing with Equatable
- Automatic provider disposal when parameters change
- Consistent dependency injection pattern

## 📊 Data Models

**Location**: `lib/features/dashboard/data/models/`

| Model                           | Purpose                                                         |
| ------------------------------- | --------------------------------------------------------------- |
| `dashboard_metrics.dart`        | TodayMetrics, WeeklyMetrics, MonthlyMetrics, QuarterlyMetrics   |
| `top_services_data.dart`        | TopServiceItem with booking count, revenue, percentage of total |
| `top_workers_data.dart`         | TopWorkerItem with bookings, revenue, rating, occupancy rate    |
| `quarterly_revenue.dart`        | QuarterData with revenue, growth rate for Q1-Q4                 |
| `booking_heatmap_models.dart`   | HeatmapDay, HeatmapHour with booking intensity                  |
| `client_management_models.dart` | ClientOverview, ClientBookingHistory                            |
| `worker_performance.dart`       | WorkerPerformance, DailyAttendance, AttendanceStatus enum       |
| `revenue_comparison.dart`       | Week-over-week and month-over-month revenue changes             |

## 🗄️ Database Schema

### Daily Revenue View

```sql
CREATE VIEW daily_revenue AS
SELECT DATE(b.created_at) as date, SUM(b.total_amount) as revenue,
       COUNT(*) as bookings,
       AVG(CASE WHEN b.status = 'completed' THEN 1 ELSE 0 END) * 100 as completion_rate
FROM bookings b
WHERE b.status IN ('completed', 'confirmed', 'pending')
GROUP BY DATE(b.created_at)
ORDER BY date DESC;
```

### Top Services View

```sql
CREATE VIEW top_services AS
SELECT bs.service_id, bs.service_name,
       DATE_TRUNC('week', b.created_at) as week,
       DATE_TRUNC('month', b.created_at) as month,
       COUNT(*) as booking_count, SUM(bs.total_price) as total_revenue,
       COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY DATE_TRUNC('week', b.created_at)) as weekly_percentage,
       COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY DATE_TRUNC('month', b.created_at)) as monthly_percentage
FROM booking_services bs
INNER JOIN bookings b ON b.id = bs.booking_id
WHERE b.status = 'completed'
GROUP BY bs.service_id, bs.service_name, DATE_TRUNC('week', b.created_at), DATE_TRUNC('month', b.created_at);
```

### Top Workers View

```sql
CREATE VIEW top_workers AS
SELECT bs.assigned_worker_id as worker_id, w.display_name as worker_name, w.avatar_url,
       DATE_TRUNC('week', b.created_at) as week,
       DATE_TRUNC('month', b.created_at) as month,
       COUNT(*) as booking_count, SUM(bs.total_price) as revenue_generated,
       AVG(r.rating) as average_rating
FROM booking_services bs
INNER JOIN bookings b ON b.id = bs.booking_id
INNER JOIN workers w ON w.id = bs.assigned_worker_id
LEFT JOIN booking_reviews r ON r.booking_id = b.id
WHERE b.status = 'completed'
GROUP BY bs.assigned_worker_id, w.display_name, w.avatar_url, DATE_TRUNC('week', b.created_at), DATE_TRUNC('month', b.created_at);
```

### Booking Heatmap Function

```sql
CREATE OR REPLACE FUNCTION get_booking_heatmap(
  p_shop_id UUID, p_start_date DATE, p_end_date DATE
)
RETURNS TABLE(booking_date DATE, hour INTEGER, booking_count BIGINT)
LANGUAGE sql AS $$
  SELECT DATE(b.booking_date) as booking_date,
         EXTRACT(HOUR FROM bs.start_time)::INTEGER as hour,
         COUNT(*) as booking_count
  FROM bookings b
  INNER JOIN booking_services bs ON bs.booking_id = b.id
  WHERE b.shop_id = p_shop_id
    AND DATE(b.booking_date) BETWEEN p_start_date AND p_end_date
    AND b.status = 'completed'
  GROUP BY DATE(b.booking_date), EXTRACT(HOUR FROM bs.start_time)
  ORDER BY booking_date, hour;
$$;
```

### Worker Attendance Table

```sql
CREATE TABLE worker_attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  worker_id UUID REFERENCES workers(id) ON DELETE CASCADE,
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  status TEXT NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT valid_status CHECK (status IN ('present', 'absent', 'late', 'half_day', 'vacation', 'sick')),
  UNIQUE(worker_id, shop_id, date)
);

CREATE INDEX idx_worker_attendance_worker ON worker_attendance(worker_id);
CREATE INDEX idx_worker_attendance_shop_date ON worker_attendance(shop_id, date);
```

## 📂 Repository Layer

### Dashboard Repository Interface

**Location**: `lib/features/dashboard/data/repositories/dashboard_repository.dart`

| Method                      | Purpose                                         |
| --------------------------- | ----------------------------------------------- |
| `getMetrics()`              | Fetch all KPI metrics for dashboard overview    |
| `watchMetrics()`            | Stream real-time metric updates                 |
| `getQuarterlyRevenue()`     | Revenue aggregation by quarter for current year |
| `getRevenueComparisons()`   | Week/week and month/month revenue changes       |
| `getTopServices()`          | Most booked services (weekly and monthly)       |
| `getTopWorkers()`           | Top performing workers with metrics             |
| `getBookingHeatmap()`       | Heatmap data for date range                     |
| `getClients()`              | Paginated client list with search               |
| `getClientBookingHistory()` | All bookings for a specific client              |
| `getWorkers()`              | List of workers with performance data           |
| `getWorkerDetails()`        | Single worker details with attendance           |
| `updateAttendance()`        | Update worker attendance status                 |
| `getAttendanceHistory()`    | Attendance records for date range               |
| `exportRevenueData()`       | CSV/JSON export of revenue data                 |
| `exportBookingsData()`      | CSV/JSON export of bookings data                |
| `exportClientsData()`       | CSV/JSON export of client data                  |

## 🧠 State Management

### Dashboard Controller

**Location**: `lib/features/dashboard/presentation/controllers/owner_dashboard_controller.dart`

| State Property | Type             | Purpose                              |
| -------------- | ---------------- | ------------------------------------ |
| `metrics`      | DashboardMetrics | All KPI data for overview tab        |
| `isLoading`    | bool             | Loading state indicator              |
| `error`        | String?          | Error message if fetch fails         |
| `lastUpdated`  | DateTime         | Timestamp of last successful refresh |

| Method                 | Purpose                              |
| ---------------------- | ------------------------------------ |
| `loadMetrics()`        | Fetch all dashboard data in parallel |
| `refresh()`            | Manual refresh with cache bypass     |
| `subscribeToMetrics()` | Real-time stream subscription        |

### Analytics Controller

**Location**: `lib/features/dashboard/presentation/controllers/analytics_controller.dart`

| State Property      | Type              | Purpose                           |
| ------------------- | ----------------- | --------------------------------- |
| `quarterlyRevenue`  | QuarterlyRevenue  | Q1-Q4 revenue with growth rates   |
| `topServices`       | TopServicesData   | Weekly and monthly top services   |
| `topWorkers`        | TopWorkersData    | Weekly and monthly top workers    |
| `revenueComparison` | RevenueComparison | Week/week and month/month changes |
| `isLoading`         | bool              | Loading state indicator           |
| `error`             | String?           | Error message if fetch fails      |

| Method            | Purpose                              |
| ----------------- | ------------------------------------ |
| `loadAnalytics()` | Fetch all analytics data in parallel |
| `refresh()`       | Manual refresh                       |

### Heatmap Controller

**Location**: `lib/features/dashboard/presentation/controllers/heatmap_controller.dart`

| State Property | Type               | Purpose                            |
| -------------- | ------------------ | ---------------------------------- |
| `heatmapData`  | BookingHeatmapData | Grid of booking counts by day/hour |
| `startDate`    | DateTime           | Start of heatmap date range        |
| `endDate`      | DateTime           | End of heatmap date range          |
| `isLoading`    | bool               | Loading state indicator            |
| `error`        | String?            | Error message if fetch fails       |

| Method              | Purpose                              |
| ------------------- | ------------------------------------ |
| `loadHeatmap()`     | Fetch heatmap for current date range |
| `updateDateRange()` | Change date range and reload         |

### Client Management Controller

**Location**: `lib/features/dashboard/presentation/controllers/client_management_controller.dart`

| State Property  | Type                 | Purpose                      |
| --------------- | -------------------- | ---------------------------- |
| `clients`       | List<ClientOverview> | Paginated client list        |
| `isLoading`     | bool                 | Initial load state           |
| `isLoadingMore` | bool                 | Pagination load state        |
| `hasMore`       | bool                 | More pages available         |
| `cursor`        | String?              | Pagination cursor            |
| `searchQuery`   | String?              | Current search filter        |
| `error`         | String?              | Error message if fetch fails |

| Method            | Purpose                       |
| ----------------- | ----------------------------- |
| `loadClients()`   | Fetch clients with pagination |
| `searchClients()` | Filter clients by name        |
| `loadMore()`      | Load next page                |
| `refresh()`       | Reset and reload from start   |

### Worker Management Controller

**Location**: `lib/features/dashboard/presentation/controllers/worker_management_controller.dart`

| State Property      | Type                    | Purpose                                |
| ------------------- | ----------------------- | -------------------------------------- |
| `workers`           | List<WorkerPerformance> | All workers with performance           |
| `selectedWorker`    | WorkerPerformance?      | Currently selected worker              |
| `attendanceHistory` | List<DailyAttendance>   | Attendance records for selected worker |
| `isLoading`         | bool                    | Loading state indicator                |
| `error`             | String?                 | Error message if fetch fails           |

| Method                | Purpose                              |
| --------------------- | ------------------------------------ |
| `loadWorkers()`       | Fetch all workers for shop           |
| `loadWorkerDetails()` | Fetch single worker with attendance  |
| `updateAttendance()`  | Mark worker present/absent/late/etc. |
| `refresh()`           | Reload all worker data               |

### Export Controller

**Location**: `lib/features/dashboard/presentation/controllers/export_controller.dart`

| State Property | Type    | Purpose                       |
| -------------- | ------- | ----------------------------- |
| `isExporting`  | bool    | Export in progress            |
| `exportUrl`    | String? | Generated file URL            |
| `error`        | String? | Error message if export fails |

| Method             | Purpose                    |
| ------------------ | -------------------------- |
| `exportRevenue()`  | Generate revenue CSV/JSON  |
| `exportBookings()` | Generate bookings CSV/JSON |
| `exportClients()`  | Generate clients CSV/JSON  |

### Dashboard Providers

**Location**: `lib/features/dashboard/shared/providers/dashboard_providers.dart`

| Provider                                   | Type                  | Purpose                       |
| ------------------------------------------ | --------------------- | ----------------------------- |
| `dashboardRepositoryProvider`              | Provider              | Singleton repository instance |
| `ownerDashboardControllerProviderFamily`   | StateNotifierProvider | Dashboard state per shop      |
| `analyticsControllerProviderFamily`        | StateNotifierProvider | Analytics state per shop      |
| `heatmapControllerProviderFamily`          | StateNotifierProvider | Heatmap state per shop        |
| `clientManagementControllerProviderFamily` | StateNotifierProvider | Client list state per shop    |
| `workerManagementControllerProviderFamily` | StateNotifierProvider | Worker state per shop         |
| `exportControllerProvider`                 | StateNotifierProvider | Export state (shop-agnostic)  |

## 🎨 UI Components (Paths Only)

### Dashboard Screens

| Screen                 | Path                                                                      | Purpose                                   |
| ---------------------- | ------------------------------------------------------------------------- | ----------------------------------------- |
| `OwnerDashboardScreen` | `lib/features/dashboard/presentation/screens/owner_dashboard_screen.dart` | Main dashboard with 5 tabs                |
| `AnalyticsScreen`      | `lib/features/dashboard/presentation/screens/analytics_screen.dart`       | Revenue charts, top services, top workers |
| `InsightsScreen`       | `lib/features/dashboard/presentation/screens/insights_screen.dart`        | Heatmap with natural language insights    |
| `ToolsScreen`          | `lib/features/dashboard/presentation/screens/tools_screen.dart`           | Export functionality, promotions          |
| `ClientsScreen`        | `lib/features/dashboard/presentation/screens/clients_screen.dart`         | Paginated client list with search         |
| `ClientDetailScreen`   | `lib/features/dashboard/presentation/screens/client_detail_screen.dart`   | Client booking history and stats          |
| `WorkersScreen`        | `lib/features/dashboard/presentation/screens/workers_screen.dart`         | Worker list with performance              |
| `WorkerDetailScreen`   | `lib/features/dashboard/presentation/screens/worker_detail_screen.dart`   | Worker schedule and attendance            |
| `ServiceDetailScreen`  | `lib/features/dashboard/presentation/screens/service_detail_screen.dart`  | Service performance analytics             |

### Dashboard Widgets

| Widget                  | Path                                                                       | Purpose                                  |
| ----------------------- | -------------------------------------------------------------------------- | ---------------------------------------- |
| `KPICard`               | `lib/features/dashboard/presentation/widgets/kpi_card.dart`                | Metric card with trend indicator         |
| `TopServicesList`       | `lib/features/dashboard/presentation/widgets/top_services_list.dart`       | Ranked list of most booked services      |
| `TopWorkersList`        | `lib/features/dashboard/presentation/widgets/top_workers_list.dart`        | Ranked list of top performers            |
| `BookingHeatmap`        | `lib/features/dashboard/presentation/widgets/booking_heatmap.dart`         | Interactive day/hour intensity grid      |
| `HeatmapInsights`       | `lib/features/dashboard/presentation/widgets/heatmap_insights.dart`        | Natural language analysis of patterns    |
| `QuarterlyRevenueChart` | `lib/features/dashboard/presentation/widgets/quarterly_revenue_chart.dart` | Bar chart of Q1-Q4 revenue               |
| `ClientCard`            | `lib/features/dashboard/presentation/widgets/client_card.dart`             | Client summary with booking stats        |
| `WorkerCard`            | `lib/features/dashboard/presentation/widgets/worker_card.dart`             | Worker summary with performance          |
| `AttendanceRegistry`    | `lib/features/dashboard/presentation/widgets/attendance_registry.dart`     | Daily attendance grid with status picker |
| `ExportButton`          | `lib/features/dashboard/presentation/widgets/export_button.dart`           | Dropdown for CSV/JSON export             |

## 🔄 Key Flows

### Dashboard Load Flow

```
User opens OwnerDashboardScreen
        ↓
Provider family creates controller with shopId
        ↓
Controller.loadMetrics() called
        ↓
Future.wait parallel requests:
  - getMetrics() for KPI cards
  - getQuarterlyRevenue() for chart
  - getTopServices() for lists
  - getTopWorkers() for lists
        ↓
All data renders progressively
        ↓
Stream subscription watches for real-time updates
```

### Heatmap Interaction Flow

```
User navigates to Insights tab
        ↓
HeatmapController loads with default 30-day range
        ↓
getBookingHeatmap() RPC called
        ↓
Data returns as day/hour grid
        ↓
HeatmapInsights generates natural language:
  - "Your busiest hour is 2 PM with 45 bookings"
  - "Saturday is your busiest day"
        ↓
User taps date range selector
        ↓
UpdateDateRange() → reload heatmap
```

### Client Search Flow

```
User navigates to Clients tab
        ↓
ClientManagementController loads first 20 clients
        ↓
User types in search bar
        ↓
300ms debounce → searchClients(query)
        ↓
Refresh with search filter, reset pagination
        ↓
User scrolls to bottom → loadMore()
        ↓
Next page appended to list
```

### Attendance Update Flow

```
User navigates to Staff tab → selects worker
        ↓
WorkerDetailScreen shows attendance calendar
        ↓
User taps date → status picker dialog
        ↓
updateAttendance() called with new status
        ↓
Repository upserts to worker_attendance table
        ↓
Refresh attendance history view
```

### Export Flow

```
User navigates to Tools tab
        ↓
Select export type (Revenue/Bookings/Clients)
        ↓
Pick date range (for revenue/bookings)
        ↓
Select format (CSV/JSON)
        ↓
ExportController calls repository method
        ↓
Repository queries data → converts to format
        ↓
Returns file URL or raw data
        ↓
Share dialog opens for user to save/send
```

## 📦 Dependencies Added in Phase 6

```yaml
dependencies:
  fl_chart: ^0.66.0
  csv: ^5.1.1
  share_plus: ^7.2.1
```

## 📁 Phase 6 Folder Structure

```
lib/features/dashboard/
├── data/
│   ├── models/
│   │   ├── analytics/
│   │   │   ├── quarterly_revenue.dart
│   │   │   ├── top_services_data.dart
│   │   │   └── top_workers_data.dart
│   │   ├── dashboard_metrics.dart
│   │   ├── booking_heatmap_models.dart
│   │   ├── client_management_models.dart
│   │   ├── revenue_comparison.dart
│   │   └── worker_performance.dart
│   └── repositories/
│       └── supabase_dashboard_repository.dart
├── domain/
│   └── repositories/
│       └── dashboard_repository.dart
├── presentation/
│   ├── controllers/
│   │   ├── owner_dashboard_controller.dart
│   │   ├── analytics_controller.dart
│   │   ├── heatmap_controller.dart
│   │   ├── client_management_controller.dart
│   │   ├── worker_management_controller.dart
│   │   └── export_controller.dart
│   ├── screens/
│   │   ├── owner_dashboard_screen.dart
│   │   ├── analytics_screen.dart
│   │   ├── insights_screen.dart
│   │   ├── tools_screen.dart
│   │   ├── clients_screen.dart
│   │   ├── client_detail_screen.dart
│   │   ├── workers_screen.dart
│   │   ├── worker_detail_screen.dart
│   │   └── service_detail_screen.dart
│   └── widgets/
│       ├── kpi_card.dart
│       ├── top_services_list.dart
│       ├── top_workers_list.dart
│       ├── booking_heatmap.dart
│       ├── heatmap_insights.dart
│       ├── quarterly_revenue_chart.dart
│       ├── client_card.dart
│       ├── worker_card.dart
│       ├── attendance_registry.dart
│       └── export_button.dart
└── shared/
    └── providers/
        └── dashboard_providers.dart
```

## ⏭️ Next Phase

**Phase 7: Review & Rating System**, which implements 5-star ratings, text reviews, shop responses, and automatic rating updates.
