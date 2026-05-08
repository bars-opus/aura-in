


# NanoEmbryo Architecture

## Phase 3: Booking System

## 🎯 Overview

The Booking System enables customers to book appointments at shops, supporting single-service bookings, multi-service bookings, and group bookings (multiple people for the same service). It handles worker assignment (parallel workers for group bookings), time slot generation with conflict detection, buffer times between appointments, deposit collection, and idempotent transaction processing.

**Dependencies**: Phase 0 (Foundation), Phase 1 (Shop Management), Phase 2 (Discovery & Search)

## 🏗️ Core Decisions

### 1. Atomic Database Transactions

**Decision**: PostgreSQL RPC functions with transaction blocks

**Why**:

- Prevents partial booking creation
- Ensures consistent state across multiple tables
- Handles wallet deductions and booking creation atomically
- Uses `FOR UPDATE` locks to prevent race conditions

### 2. Idempotency Keys

**Decision**: Client-generated UUID v4 as idempotency key

**Why**:

- Prevents duplicate bookings from network retries
- Store used keys in database with expiration
- Returns existing booking on duplicate key
- Works across app restarts and network failures

### 3. Parallel Worker Assignment for Groups

**Decision**: Each person in group booking assigned to different worker

**Why**:

- Enables family/friend bookings at same time
- Maximizes shop capacity utilization
- Prevents worker overload on single booking
- Clients can request specific workers

### 4. Buffer Times Between Appointments

**Decision**: Configurable buffer before and after per service

**Why**:

- Allows cleaning/setup time between appointments
- Prevents back-to-back scheduling conflicts
- Improves customer experience (no waiting)
- Shop owners can customize per service

### 5. Deposit + Platform Fee Model

**Decision**: Configurable deposit percentage (default 30%) paid at booking

**Why**:

- Reduces no-shows for shop owners
- Platform collects fee from deposit
- Remaining balance paid after service
- Customer commitment without full payment

## 📊 Data Models

### Booking Model

**Location**: `lib/features/bookings/data/models/booking_model.dart`

```dart
class BookingModel {
  final String id;
  final String shopId;
  final String clientId;
  final String status;        // pending, confirmed, completed, cancelled, no_show
  final DateTime bookingDate;
  final double totalAmount;
  final double depositAmount;
  final double platformFee;
  final double shopEarnings;
  final String? idempotencyKey;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingModel({
    required this.id,
    required this.shopId,
    required this.clientId,
    required this.status,
    required this.bookingDate,
    required this.totalAmount,
    required this.depositAmount,
    required this.platformFee,
    required this.shopEarnings,
    this.idempotencyKey,
    this.cancellationReason,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });
}
```

### Booking Service Model (Multi-Service Support)

**Location**: `lib/features/bookings/data/models/booking_service_model.dart`

```dart
class BookingServiceModel {
  final String id;
  final String bookingId;
  final String serviceId;           // appointment_slot.id
  final String serviceName;
  final int quantity;               // For group bookings (e.g., 3 people)
  final double pricePerUnit;
  final double totalPrice;
  final int durationMinutes;
  final DateTime startTime;
  final DateTime endTime;
  final String? assignedWorkerId;
  final String? assignedWorkerName;

  const BookingServiceModel({
    required this.id,
    required this.bookingId,
    required this.serviceId,
    required this.serviceName,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalPrice,
    required this.durationMinutes,
    required this.startTime,
    required this.endTime,
    this.assignedWorkerId,
    this.assignedWorkerName,
  });
}
```

### Booking Parameters

**Location**: `lib/features/bookings/data/models/booking_params.dart`

```dart
class BookingParams {
  final String shopId;
  final List<BookingServiceInput> services;
  final DateTime bookingDate;
  final String? idempotencyKey;

  const BookingParams({
    required this.shopId,
    required this.services,
    required this.bookingDate,
    this.idempotencyKey,
  });
}

class BookingServiceInput {
  final String serviceId;
  final int quantity;              // 1 for single, >1 for group
  final String? preferredWorkerId;

  const BookingServiceInput({
    required this.serviceId,
    this.quantity = 1,
    this.preferredWorkerId,
  });
}
```

### Time Slot Model

**Location**: `lib/features/bookings/data/models/time_slot.dart`

```dart
class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final String? workerId;
  final String? workerName;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.workerId,
    this.workerName,
  });
}
```

## 🗄️ Database Schema

### Bookings Table

```sql
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id UUID REFERENCES shops(id) NOT NULL,
  client_id UUID REFERENCES auth.users(id) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  booking_date TIMESTAMPTZ NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  deposit_amount DECIMAL(10,2) NOT NULL,
  platform_fee DECIMAL(10,2) NOT NULL,
  shop_earnings DECIMAL(10,2) NOT NULL,
  idempotency_key TEXT UNIQUE,
  cancellation_reason TEXT,
  cancelled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT valid_status CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled', 'no_show')),
  CONSTRAINT deposit_positive CHECK (deposit_amount >= 0),
  CONSTRAINT total_positive CHECK (total_amount >= 0)
);

-- Indexes
CREATE INDEX idx_bookings_shop_id ON bookings(shop_id);
CREATE INDEX idx_bookings_client_id ON bookings(client_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_booking_date ON bookings(booking_date);
CREATE INDEX idx_bookings_idempotency_key ON bookings(idempotency_key);
CREATE INDEX idx_bookings_created_at ON bookings(created_at);
```

### Booking Services Table

```sql
CREATE TABLE booking_services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
  service_id UUID REFERENCES appointment_slots(id) NOT NULL,
  service_name TEXT NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  price_per_unit DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  duration_minutes INTEGER NOT NULL,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  assigned_worker_id UUID REFERENCES workers(id),
  assigned_worker_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT quantity_positive CHECK (quantity >= 1),
  CONSTRAINT duration_positive CHECK (duration_minutes > 0)
);

-- Indexes
CREATE INDEX idx_booking_services_booking_id ON booking_services(booking_id);
CREATE INDEX idx_booking_services_service_id ON booking_services(service_id);
CREATE INDEX idx_booking_services_assigned_worker ON booking_services(assigned_worker_id);
CREATE INDEX idx_booking_services_start_time ON booking_services(start_time);
```

### Idempotency Keys Table (Optional - Can use bookings.idempotency_key)

```sql
CREATE TABLE idempotency_keys (
  key TEXT PRIMARY KEY,
  response JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '24 hours'
);

CREATE INDEX idx_idempotency_keys_expires_at ON idempotency_keys(expires_at);
```

### Atomic Booking Creation RPC Function

```sql
CREATE OR REPLACE FUNCTION create_booking_transaction(
  p_shop_id UUID,
  p_client_id UUID,
  p_services JSONB,  -- Array of {service_id, quantity, preferred_worker_id, start_time}
  p_idempotency_key TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_booking_id UUID;
  v_total_amount DECIMAL(10,2);
  v_deposit_amount DECIMAL(10,2);
  v_platform_fee DECIMAL(10,2);
  v_shop_earnings DECIMAL(10,2);
  v_service_record RECORD;
  v_worker_available BOOLEAN;
BEGIN
  -- Check idempotency
  IF p_idempotency_key IS NOT NULL THEN
    SELECT id INTO v_booking_id FROM bookings
    WHERE idempotency_key = p_idempotency_key;

    IF FOUND THEN
      RETURN jsonb_build_object(
        'booking_id', v_booking_id,
        'is_existing', true
      );
    END IF;
  END IF;

  -- Calculate totals
  v_total_amount := 0;
  FOR v_service_record IN SELECT * FROM jsonb_to_recordset(p_services) AS x(
    service_id UUID,
    quantity INTEGER,
    preferred_worker_id UUID,
    start_time TIMESTAMPTZ
  ) LOOP
    -- Validate service exists and get price
    SELECT price INTO v_service_record.price
    FROM appointment_slots
    WHERE id = v_service_record.service_id;

    -- Validate worker availability
    SELECT EXISTS(
      SELECT 1 FROM worker_availability wa
      WHERE wa.worker_id = v_service_record.preferred_worker_id
        AND wa.is_available = true
        AND wa.date = v_service_record.start_time::DATE
    ) INTO v_worker_available;

    IF NOT v_worker_available THEN
      RAISE EXCEPTION 'Worker % not available at %',
        v_service_record.preferred_worker_id, v_service_record.start_time;
    END IF;

    v_total_amount := v_total_amount +
      (v_service_record.price * v_service_record.quantity);
  END LOOP;

  -- Calculate deposit (30% default) and fees
  v_deposit_amount := v_total_amount * 0.30;
  v_platform_fee := v_deposit_amount * 0.10;  -- 10% platform fee on deposit
  v_shop_earnings := v_deposit_amount - v_platform_fee;

  -- Create booking
  INSERT INTO bookings (
    shop_id, client_id, status, booking_date,
    total_amount, deposit_amount, platform_fee, shop_earnings,
    idempotency_key
  ) VALUES (
    p_shop_id, p_client_id, 'pending', NOW(),
    v_total_amount, v_deposit_amount, v_platform_fee, v_shop_earnings,
    p_idempotency_key
  ) RETURNING id INTO v_booking_id;

  -- Create booking services
  FOR v_service_record IN SELECT * FROM jsonb_to_recordset(p_services) AS x(
    service_id UUID,
    quantity INTEGER,
    preferred_worker_id UUID,
    start_time TIMESTAMPTZ
  ) LOOP
    INSERT INTO booking_services (
      booking_id, service_id, service_name, quantity,
      price_per_unit, total_price, duration_minutes,
      start_time, end_time, assigned_worker_id
    )
    SELECT
      v_booking_id,
      v_service_record.service_id,
      s.name,
      v_service_record.quantity,
      s.price,
      s.price * v_service_record.quantity,
      s.duration_minutes,
      v_service_record.start_time,
      v_service_record.start_time + (s.duration_minutes || ' minutes')::INTERVAL,
      v_service_record.preferred_worker_id
    FROM appointment_slots s
    WHERE s.id = v_service_record.service_id;
  END LOOP;

  -- Return success
  RETURN jsonb_build_object(
    'booking_id', v_booking_id,
    'total_amount', v_total_amount,
    'deposit_amount', v_deposit_amount,
    'platform_fee', v_platform_fee,
    'shop_earnings', v_shop_earnings,
    'is_existing', false
  );
END;
$$;
```

### Time Slot Generation Function

```sql
CREATE OR REPLACE FUNCTION get_available_slots(
  p_shop_id UUID,
  p_service_id UUID,
  p_date DATE,
  p_quantity INTEGER DEFAULT 1
)
RETURNS TABLE(
  start_time TIMESTAMPTZ,
  end_time TIMESTAMPTZ,
  worker_id UUID,
  worker_name TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_service_duration INTEGER;
  v_shop_open TIME;
  v_shop_close TIME;
  v_buffer_before INTEGER;
  v_buffer_after INTEGER;
  v_time_slot TIMESTAMPTZ;
  v_day_of_week INTEGER;
BEGIN
  -- Get service details
  SELECT duration_minutes, buffer_before_minutes, buffer_after_minutes
  INTO v_service_duration, v_buffer_before, v_buffer_after
  FROM appointment_slots WHERE id = p_service_id;

  -- Get shop opening hours for the day
  v_day_of_week := EXTRACT(DOW FROM p_date);

  SELECT open_time, close_time
  INTO v_shop_open, v_shop_close
  FROM shop_opening_hours
  WHERE shop_id = p_shop_id AND day_of_week = v_day_of_week AND is_closed = false;

  -- Generate time slots
  FOR v_time_slot IN
    SELECT generate_series(
      (p_date + v_shop_open)::TIMESTAMPTZ,
      (p_date + v_shop_close - (v_service_duration || ' minutes')::INTERVAL)::TIMESTAMPTZ,
      '15 minutes'::INTERVAL
    )
  LOOP
    -- Check if worker available for this slot
    RETURN QUERY
    SELECT DISTINCT
      v_time_slot,
      v_time_slot + (v_service_duration || ' minutes')::INTERVAL,
      w.id,
      w.display_name
    FROM workers w
    INNER JOIN slot_worker_assignments swa ON swa.worker_id = w.id
    WHERE swa.slot_id = p_service_id
      AND NOT EXISTS (
        SELECT 1 FROM booking_services bs
        WHERE bs.assigned_worker_id = w.id
          AND tsrange(bs.start_time, bs.end_time, '[)') && tsrange(
            v_time_slot - (v_buffer_before || ' minutes')::INTERVAL,
            v_time_slot + (v_service_duration + v_buffer_after || ' minutes')::INTERVAL,
            '[)'
          )
      )
      AND w.id IN (
        SELECT worker_id FROM shop_workers
        WHERE shop_id = p_shop_id AND is_active = true
      )
    LIMIT p_quantity;
  END LOOP;
END;
$$;
```

## 📂 Repository Layer

### Booking Repository Interface

**Location**: `lib/features/bookings/domain/repositories/booking_repository.dart`

```dart
abstract class BookingRepository {
  // Create booking
  Future<BookingResult> createBooking(BookingParams params);

  // Read bookings
  Future<BookingModel?> getBooking(String bookingId);
  Future<PaginatedBookings> getClientBookings({
    required String clientId,
    String? cursor,
    int limit = 20,
    BookingStatus? status,
  });
  Future<PaginatedBookings> getShopBookings({
    required String shopId,
    String? cursor,
    int limit = 20,
    BookingStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });

  // Update booking status
  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
    String? cancellationReason,
  });

  // Get available time slots
  Future<List<TimeSlot>> getAvailableSlots({
    required String shopId,
    required String serviceId,
    required DateTime date,
    int quantity = 1,
  });

  // Check worker availability for multiple services
  Future<Map<String, List<TimeSlot>>> getMultiServiceSlots({
    required String shopId,
    required List<String> serviceIds,
    required DateTime date,
    required Map<String, int> quantities,
  });
}
```

### Supabase Booking Repository Implementation

**Location**: `lib/features/bookings/data/repositories/supabase_booking_repository.dart`

```dart
class SupabaseBookingRepository implements BookingRepository {
  final SupabaseClient _client;

  @override
  Future<BookingResult> createBooking(BookingParams params) async {
    // Generate idempotency key if not provided
    final idempotencyKey = params.idempotencyKey ?? uuid.v4();

    // Prepare services JSON for RPC call
    final servicesJson = params.services.map((service) => {
      'service_id': service.serviceId,
      'quantity': service.quantity,
      'preferred_worker_id': service.preferredWorkerId,
      'start_time': service.startTime?.toIso8601String(),
    }).toList();

    // Call the atomic transaction function
    final result = await _client.rpc('create_booking_transaction', params: {
      'p_shop_id': params.shopId,
      'p_client_id': _client.auth.currentUser!.id,
      'p_services': servicesJson,
      'p_idempotency_key': idempotencyKey,
    });

    return BookingResult.fromJson(result);
  }

  @override
  Future<List<TimeSlot>> getAvailableSlots({
    required String shopId,
    required String serviceId,
    required DateTime date,
    int quantity = 1,
  }) async {
    final result = await _client.rpc('get_available_slots', params: {
      'p_shop_id': shopId,
      'p_service_id': serviceId,
      'p_date': date.toIso8601String().split('T')[0],
      'p_quantity': quantity,
    });

    return (result as List).map((slot) => TimeSlot(
      startTime: DateTime.parse(slot['start_time']),
      endTime: DateTime.parse(slot['end_time']),
      isAvailable: true,
      workerId: slot['worker_id'],
      workerName: slot['worker_name'],
    )).toList();
  }

  @override
  Future<PaginatedBookings> getClientBookings({
    required String clientId,
    String? cursor,
    int limit = 20,
    BookingStatus? status,
  }) async {
    var query = _client.from('bookings')
        .select('''
          *,
          shop:shops(shop_name, cover_image_url),
          booking_services(*)
        ''')
        .eq('client_id', clientId)
        .order('created_at', ascending: false);

    if (status != null) {
      query = query.eq('status', status.value);
    }

    if (cursor != null) {
      query = query.lt('created_at', cursor);
    }

    final response = await query.limit(limit + 1);
    final bookings = response.map((json) => BookingModel.fromJson(json)).toList();

    final hasMore = bookings.length > limit;
    if (hasMore) bookings.removeLast();

    return PaginatedBookings(
      items: bookings,
      nextCursor: hasMore ? bookings.last.createdAt.toIso8601String() : null,
      hasMore: hasMore,
    );
  }

  @override
  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
    String? cancellationReason,
  }) async {
    final updates = {
      'status': status.value,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (status == BookingStatus.cancelled) {
      updates['cancelled_at'] = DateTime.now().toIso8601String();
      updates['cancellation_reason'] = cancellationReason;
    }

    if (status == BookingStatus.completed) {
      // Transfer remaining balance from deposit to shop wallet
      await _client.rpc('complete_booking_payment', params: {
        'p_booking_id': bookingId,
      });
    }

    await _client.from('bookings').update(updates).eq('id', bookingId);
  }
}
```

## 🧠 State Management

### Booking Providers

**Location**: `lib/features/bookings/domain/providers/booking_providers.dart`

```dart
// Repository provider
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return SupabaseBookingRepository(Supabase.instance.client);
});

// Current booking draft (multi-step booking)
final bookingDraftProvider = StateNotifierProvider<BookingDraftNotifier, BookingDraftState>((ref) {
  return BookingDraftNotifier();
});

// Available time slots for selected service/date
final availableTimeSlotsProvider = FutureProvider.family<List<TimeSlot>, TimeSlotParams>((ref, params) async {
  final repository = ref.read(bookingRepositoryProvider);
  return repository.getAvailableSlots(
    shopId: params.shopId,
    serviceId: params.serviceId,
    date: params.date,
    quantity: params.quantity,
  );
});

// Client booking history
final clientBookingsProvider = FutureProvider.family<PaginatedBookings, String>((ref, clientId) async {
  final repository = ref.read(bookingRepositoryProvider);
  return repository.getClientBookings(clientId: clientId);
});

// Create booking controller
final createBookingControllerProvider = StateNotifierProvider<CreateBookingController, AsyncValue<void>>((ref) {
  return CreateBookingController(ref.read(bookingRepositoryProvider));
});
```

### Booking Draft Notifier

**Location**: `lib/features/bookings/domain/providers/booking_draft_notifier.dart`

```dart
class BookingDraftState {
  final String? shopId;
  final List<BookingServiceInput> services;
  final DateTime? selectedDate;
  final Map<String, DateTime?> selectedStartTimes;
  final Map<String, String?> selectedWorkers;
  final bool isSubmitting;

  const BookingDraftState({
    this.shopId,
    this.services = const [],
    this.selectedDate,
    this.selectedStartTimes = const {},
    this.selectedWorkers = const {},
    this.isSubmitting = false,
  });

  double get totalAmount {
    // Calculate from services
    return 0.0;
  }

  double get depositAmount => totalAmount * 0.30;

  bool get isValid => shopId != null &&
      services.isNotEmpty &&
      selectedDate != null &&
      services.every((service) => selectedStartTimes.containsKey(service.serviceId));
}

class BookingDraftNotifier extends StateNotifier<BookingDraftState> {
  BookingDraftNotifier() : super(const BookingDraftState());

  void addService(String serviceId, int quantity) {
    final newService = BookingServiceInput(
      serviceId: serviceId,
      quantity: quantity,
    );
    state = BookingDraftState(
      shopId: state.shopId,
      services: [...state.services, newService],
      selectedDate: state.selectedDate,
      selectedStartTimes: state.selectedStartTimes,
      selectedWorkers: state.selectedWorkers,
    );
  }

  void removeService(String serviceId) {
    state = BookingDraftState(
      shopId: state.shopId,
      services: state.services.where((s) => s.serviceId != serviceId).toList(),
      selectedDate: state.selectedDate,
      selectedStartTimes: {...state.selectedStartTimes}..remove(serviceId),
      selectedWorkers: {...state.selectedWorkers}..remove(serviceId),
    );
  }

  void updateSelectedDate(DateTime date) {
    state = BookingDraftState(
      shopId: state.shopId,
      services: state.services,
      selectedDate: date,
      selectedStartTimes: state.selectedStartTimes,
      selectedWorkers: state.selectedWorkers,
    );
  }

  void updateStartTime(String serviceId, DateTime startTime) {
    state = BookingDraftState(
      shopId: state.shopId,
      services: state.services,
      selectedDate: state.selectedDate,
      selectedStartTimes: {
        ...state.selectedStartTimes,
        serviceId: startTime,
      },
      selectedWorkers: state.selectedWorkers,
    );
  }

  void updateWorker(String serviceId, String workerId) {
    state = BookingDraftState(
      shopId: state.shopId,
      services: state.services,
      selectedDate: state.selectedDate,
      selectedStartTimes: state.selectedStartTimes,
      selectedWorkers: {
        ...state.selectedWorkers,
        serviceId: workerId,
      },
    );
  }

  Future<void> submit() async {
    if (!state.isValid) return;

    state = BookingDraftState(
      shopId: state.shopId,
      services: state.services,
      selectedDate: state.selectedDate,
      selectedStartTimes: state.selectedStartTimes,
      selectedWorkers: state.selectedWorkers,
      isSubmitting: true,
    );

    // Build booking params
    final params = BookingParams(
      shopId: state.shopId!,
      services: state.services.map((service) => BookingServiceInput(
        serviceId: service.serviceId,
        quantity: service.quantity,
        preferredWorkerId: state.selectedWorkers[service.serviceId],
        startTime: state.selectedStartTimes[service.serviceId],
      )).toList(),
      bookingDate: state.selectedDate!,
      idempotencyKey: uuid.v4(),
    );

    // Submit to repository
    // Result handled by controller
  }
}
```

## 🎨 UI Components

### Booking Screens

| Screen                      | Location                                                                      | Purpose                                     |
| --------------------------- | ----------------------------------------------------------------------------- | ------------------------------------------- |
| `ServiceSelectionScreen`    | `lib/features/bookings/presentation/screens/service_selection_screen.dart`    | Select services and quantities              |
| `DateTimeSelectionScreen`   | `lib/features/bookings/presentation/screens/date_time_selection_screen.dart`  | Pick date and time slots                    |
| `WorkerAssignmentScreen`    | `lib/features/bookings/presentation/screens/worker_assignment_screen.dart`    | Assign workers to each service (for groups) |
| `BookingSummaryScreen`      | `lib/features/bookings/presentation/screens/booking_summary_screen.dart`      | Review all details before payment           |
| `BookingConfirmationScreen` | `lib/features/bookings/presentation/screens/booking_confirmation_screen.dart` | Success/failure result                      |
| `BookingDetailScreen`       | `lib/features/bookings/presentation/screens/booking_detail_screen.dart`       | View single booking details                 |

### Key Widgets

| Widget                  | Location                                                                  | Purpose                                |
| ----------------------- | ------------------------------------------------------------------------- | -------------------------------------- |
| `ClientServiceCard`     | `lib/features/bookings/presentation/widgets/client_service_card.dart`     | Service selection with quantity picker |
| `TimeSlotSelector`      | `lib/features/bookings/presentation/widgets/time_slot_selector.dart`      | Grid of available time slots           |
| `BookingPriceBreakdown` | `lib/features/bookings/presentation/widgets/booking_price_breakdown.dart` | Shows total, deposit, fees             |
| `WorkerSelector`        | `lib/features/bookings/presentation/widgets/worker_selector.dart`         | Dropdown for worker selection          |
| `GroupBookingRow`       | `lib/features/bookings/presentation/widgets/group_booking_row.dart`       | Shows each person in group booking     |
| `BookingStatusBadge`    | `lib/features/bookings/presentation/widgets/booking_status_badge.dart`    | Status chip with color coding          |

## 🔄 Key Flows

### Single Service Booking Flow

```
User selects shop → Clicks "Book Now"
        ↓
Step 1: Service Selection
  - Choose service from list
  - Select quantity (1+ for groups)
        ↓
Step 2: Date & Time Selection
  - Pick date from calendar
  - See available time slots (generated by get_available_slots())
  - Select time slot → Shows worker assignment
        ↓
Step 3: Worker Assignment (optional)
  - See available workers for that time
  - Select preferred worker
        ↓
Step 4: Review & Payment
  - See total: $100
  - Deposit (30%): $30 + platform fee: $3
  - Remaining: $70 payable after service
  - Confirm booking
        ↓
Generate idempotency key (UUID)
        ↓
Call create_booking_transaction() RPC
        ↓
Success → Navigate to confirmation screen
        ↓
Redirect to payment (Phase 4)
```

### Multi-Service Group Booking Flow

```
User selects shop → Clicks "Book Multiple Services"
        ↓
Step 1: Service Selection
  - Add services one by one
  - For each: select service name, quantity (people)
  - Example: Haircut (3 people), Color (1 person)
        ↓
Step 2: Date & Time Selection
  - Pick single date for all services
  - System finds overlapping time slots for all services
  - Shows "Optimal Time" or "Split Booking" options
        ↓
Step 3: Parallel Worker Assignment
  - For Haircut (3 people): assign Worker A, B, C
  - For Color (1 person): assign Worker D
  - All workers confirmed available at selected time
        ↓
Step 4: Review & Payment
  - Total: Haircut ($30×3=90) + Color ($50×1=50) = $140
  - Deposit (30%): $42 + platform fee: $4.20
  - Remaining: $98
        ↓
Submit booking → Atomic transaction creates:
  - 1 booking record
  - 2 booking_service records (one per service type)
  - 4 worker assignments (3 haircut + 1 color)
```

### Booking Cancellation Flow (Shop Owner)

```
Shop owner opens booking details
        ↓
Clicks "Cancel Booking"
        ↓
Select reason from options:
  - Customer request
  - Worker unavailable
  - Shop closed
  - Other
        ↓
Confirm cancellation
        ↓
Update booking.status = 'cancelled'
        ↓
Refund deposit to customer wallet
        ↓
Send notification to customer
        ↓
Release worker time slots for re-booking
```

### Booking Completion Flow (Shop Owner)

```
Service completed
        ↓
Shop owner clicks "Mark Complete"
        ↓
Update booking.status = 'completed'
        ↓
Trigger complete_booking_payment() RPC:
  - Transfer remaining balance from escrow to shop wallet
  - Calculate final platform fee on full amount
  - Update shop earnings
        ↓
Prompt customer to leave review (Phase 7)
        ↓
Send receipt notification
```

## ⚠️ Error Handling & Edge Cases

| Scenario                                | Handling                                  |
| --------------------------------------- | ----------------------------------------- |
| Duplicate idempotency key               | Return existing booking, don't create new |
| Worker not available at selected time   | Show error, suggest alternative times     |
| Shop closed on selected date            | Disable date, show message                |
| Insufficient wallet balance for deposit | Show error, redirect to add funds         |
| Concurrent booking on same slot         | Transaction lock prevents double-booking  |
| Network failure during booking          | Retry with same idempotency key           |
| Partial booking creation                | RPC transaction rolls back all changes    |
| Group booking exceeds max_clients       | Validate before showing time slots        |

## 📦 Dependencies Added in Phase 3

```yaml
dependencies:
  # UUID Generation
  uuid: ^4.0.0

  # Date/Time Utilities
  intl: ^0.18.1
  time: ^2.1.2
  table_calendar: ^3.0.9

  # Payment (Partial - full in Phase 4)
  flutter_stripe: ^10.0.0
  paystack_sdk: ^1.0.0

  # UI Enhancement
  smooth_page_indicator: ^1.1.0
  timeline_tile: ^2.0.0
```

## 📁 Phase 3 Folder Structure

```
lib/features/bookings/
├── data/
│   ├── models/
│   │   ├── booking_model.dart
│   │   ├── booking_service_model.dart
│   │   ├── booking_params.dart
│   │   ├── time_slot.dart
│   │   └── paginated_bookings.dart
│   └── repositories/
│       ├── booking_repository.dart
│       └── supabase_booking_repository.dart
├── domain/
│   ├── entities/
│   │   ├── booking.dart
│   │   ├── booking_service.dart
│   │   └── booking_status.dart
│   ├── providers/
│   │   ├── booking_providers.dart
│   │   └── booking_draft_notifier.dart
│   └── repositories/
│       └── booking_repository.dart
└── presentation/
    ├── screens/
    │   ├── service_selection_screen.dart
    │   ├── date_time_selection_screen.dart
    │   ├── worker_assignment_screen.dart
    │   ├── booking_summary_screen.dart
    │   ├── booking_confirmation_screen.dart
    │   └── booking_detail_screen.dart
    └── widgets/
        ├── client_service_card.dart
        ├── time_slot_selector.dart
        ├── booking_price_breakdown.dart
        ├── worker_selector.dart
        ├── group_booking_row.dart
        ├── booking_status_badge.dart
        └── service_with_requirements.dart
```

## ⏭️ Next Phase

**Phase 4: Payment & Wallet**, which implements payment provider integration (Paystack, Stripe Connect), shop subaccount creation, wallet system, and withdrawal processing.