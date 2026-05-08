

# NanoEmbryo Architecture

## 🎯 Overview

The Review & Rating System enables customers to rate and review completed bookings. Shop owners can respond to reviews, and the system automatically updates shop average ratings and total review counts via database triggers. The feature includes a 5-star rating component, text reviews with character limits, shop response functionality, and detailed rating breakdown widgets.

**Dependencies**: Phase 0 (Foundation), Phase 1 (Shop Management), Phase 3 (Booking System)

## 🏗️ Core Decisions

### 1. Booking-Based Reviews

**Decision**: Reviews are linked to specific completed bookings

**Why**:

- Prevents fake/spam reviews from non-customers
- Ensures only verified customers can leave reviews
- Links review to specific service and worker
- Enables context-aware review display

### 2. Database Triggers for Rating Updates

**Decision**: PostgreSQL triggers automatically update shop ratings

**Why**:

- Maintains data consistency across tables
- Eliminates manual calculation errors
- Real-time rating updates on review changes
- Reduces application logic complexity

### 3. Shop Owner Response Capability

**Decision**: Shop owners can respond to customer reviews

**Why**:

- Enables conflict resolution and customer engagement
- Shows prospective customers shop values service recovery
- Keeps all communication on platform
- Timestamps show response time

### 4. Rating Breakdown Display

**Decision**: Show rating distribution bars alongside average

**Why**:

- Customers see rating distribution (5-star, 4-star, etc.)
- Provides more context than simple average
- Helps identify service quality patterns
- Builds trust through transparency

### 5. Review Edit Window

**Decision**: Customers can edit review until shop responds

**Why**:

- Allows customers to update experience after follow-up
- Incentivizes shop owners to respond promptly
- Reduces duplicate review submissions
- Maintains review authenticity

## 📊 Data Models

**Location**: `lib/features/reviews/data/models/`

| Model                 | Purpose                                                          |
| --------------------- | ---------------------------------------------------------------- |
| `booking_review.dart` | Review with rating (1-5), review text, shop response, timestamps |
| `review_rating.dart`  | Rating summary with distribution counts                          |
| `shop_rating.dart`    | Shop average rating and total review count                       |

## 🗄️ Database Schema

### Booking Reviews Table

```sql
CREATE TABLE booking_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE UNIQUE,
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
  client_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL,
  review TEXT,
  shop_response TEXT,
  responded_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT rating_range CHECK (rating >= 1 AND rating <= 5),
  CONSTRAINT review_length CHECK (review IS NULL OR LENGTH(review) <= 1000),
  CONSTRAINT shop_response_length CHECK (shop_response IS NULL OR LENGTH(shop_response) <= 2000)
);

CREATE INDEX idx_booking_reviews_booking_id ON booking_reviews(booking_id);
CREATE INDEX idx_booking_reviews_shop_id ON booking_reviews(shop_id);
CREATE INDEX idx_booking_reviews_client_id ON booking_reviews(client_id);
CREATE INDEX idx_booking_reviews_rating ON booking_reviews(rating);
CREATE INDEX idx_booking_reviews_created_at ON booking_reviews(created_at);
```

### Shop Rating Update Trigger Function

```sql
CREATE OR REPLACE FUNCTION update_shop_rating()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_shop_id UUID;
  v_avg_rating DECIMAL(3,2);
  v_total_reviews INTEGER;
BEGIN
  -- Determine shop_id from the review
  IF TG_OP = 'DELETE' THEN
    v_shop_id := OLD.shop_id;
  ELSE
    v_shop_id := NEW.shop_id;
  END IF;

  -- Calculate new average rating and total reviews
  SELECT
    ROUND(AVG(rating)::NUMERIC, 2),
    COUNT(*)
  INTO v_avg_rating, v_total_reviews
  FROM booking_reviews
  WHERE shop_id = v_shop_id;

  -- Update shops table
  UPDATE shops
  SET
    average_rating = COALESCE(v_avg_rating, 0),
    total_reviews = COALESCE(v_total_reviews, 0),
    updated_at = NOW()
  WHERE id = v_shop_id;

  RETURN NULL;
END;
$$;
```

### Trigger Installation

```sql
CREATE TRIGGER update_shop_rating_on_insert
  AFTER INSERT ON booking_reviews
  FOR EACH ROW EXECUTE FUNCTION update_shop_rating();

CREATE TRIGGER update_shop_rating_on_update
  AFTER UPDATE OF rating ON booking_reviews
  FOR EACH ROW EXECUTE FUNCTION update_shop_rating();

CREATE TRIGGER update_shop_rating_on_delete
  AFTER DELETE ON booking_reviews
  FOR EACH ROW EXECUTE FUNCTION update_shop_rating();
```

### Updated At Trigger for Reviews

```sql
CREATE OR REPLACE FUNCTION update_review_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER update_review_timestamp
  BEFORE UPDATE ON booking_reviews
  FOR EACH ROW EXECUTE FUNCTION update_review_updated_at();
```

### Rating Distribution View

```sql
CREATE VIEW rating_distribution AS
SELECT
  shop_id,
  rating,
  COUNT(*) as count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY shop_id), 1) as percentage
FROM booking_reviews
GROUP BY shop_id, rating
ORDER BY shop_id, rating DESC;
```

## 📂 Repository Layer

### Review Repository Interface

**Location**: `lib/features/reviews/domain/repositories/review_repository.dart`

| Method                    | Purpose                                            |
| ------------------------- | -------------------------------------------------- |
| `getReviewsForShop()`     | Paginated list of reviews for a shop               |
| `getReviewsForBooking()`  | Get review for a specific booking                  |
| `getRatingDistribution()` | Count of reviews per rating (5-star, 4-star, etc.) |
| `createReview()`          | Submit new review for completed booking            |
| `updateReview()`          | Edit existing review (before shop responds)        |
| `deleteReview()`          | Remove review (admin/shop owner only)              |
| `addShopResponse()`       | Shop owner responds to review                      |
| `updateShopResponse()`    | Edit existing response                             |
| `canReview()`             | Check if booking is completed and not reviewed     |
| `canEditReview()`         | Check if review exists and not responded to        |

## 🧠 State Management

### Review Providers

**Location**: `lib/features/reviews/providers/review_providers.dart`

| Provider                             | Type                  | Purpose                                |
| ------------------------------------ | --------------------- | -------------------------------------- |
| `reviewRepositoryProvider`           | Provider              | Singleton repository instance          |
| `shopReviewsProvider`                | FutureProvider        | Paginated reviews for shop detail page |
| `ratingDistributionProvider`         | FutureProvider        | Rating breakdown for shop              |
| `bookingReviewProvider`              | FutureProvider        | Review status for specific booking     |
| `reviewSubmissionControllerProvider` | StateNotifierProvider | Create/update review actions           |
| `shopResponseControllerProvider`     | StateNotifierProvider | Add/update shop response to review     |

### Review Submission Controller

**Location**: `lib/features/reviews/presentation/controllers/review_submission_controller.dart`

| State Property | Type    | Purpose                        |
| -------------- | ------- | ------------------------------ |
| `rating`       | int     | Selected rating (1-5)          |
| `reviewText`   | String  | Review text content            |
| `isSubmitting` | bool    | Submission in progress         |
| `error`        | String? | Validation or submission error |
| `canEdit`      | bool    | Whether review can be edited   |

| Method            | Purpose                            |
| ----------------- | ---------------------------------- |
| `setRating()`     | Update selected rating             |
| `setReviewText()` | Update review text with validation |
| `submitReview()`  | Create or update review            |
| `reset()`         | Clear form state                   |

## 🎨 UI Components (Paths Only)

### Review Screens

| Screen                   | Path                                                                      | Purpose                                        |
| ------------------------ | ------------------------------------------------------------------------- | ---------------------------------------------- |
| `ReviewSubmissionScreen` | `lib/features/reviews/presentation/screens/review_submission_screen.dart` | Full-page review form after booking completion |

### Review Widgets

| Widget                     | Path                                                                         | Purpose                                           |
| -------------------------- | ---------------------------------------------------------------------------- | ------------------------------------------------- |
| `StarRatingWidget`         | `lib/features/reviews/presentation/widgets/star_rating_widget.dart`          | Interactive 5-star rating input/display           |
| `ReviewBottomSheet`        | `lib/features/reviews/presentation/widgets/review_bottom_sheet.dart`         | Modal review form (appears after booking)         |
| `ReviewDisplayWidget`      | `lib/features/reviews/presentation/widgets/review_display_widget.dart`       | Single review with avatar, rating, text, response |
| `ShopRatingWidget`         | `lib/features/reviews/presentation/widgets/shop_rating_widget.dart`          | Simple average rating + star display              |
| `DetailedShopRatingWidget` | `lib/features/reviews/presentation/widgets/detailed_shop_rating_widget.dart` | Rating breakdown bars with percentages            |
| `HorizontalReviewsPreview` | `lib/features/reviews/presentation/widgets/horizontal_reviews_preview.dart`  | Horizontal scroll of recent reviews               |
| `RatingDistributionBars`   | `lib/features/reviews/presentation/widgets/rating_distribution_bars.dart`    | Visual bars for each rating level                 |
| `ShopResponseField`        | `lib/features/reviews/presentation/widgets/shop_response_field.dart`         | Text field for shop owner response                |

## 🔄 Key Flows

### Review Submission Flow

```
Booking status changes to 'completed'
        ↓
UI shows "Leave a Review" prompt / button
        ↓
canReview() checks: booking is completed AND no review exists
        ↓
Customer taps → ReviewBottomSheet opens
        ↓
Select rating (1-5 stars) → setRating()
        ↓
Optional: Write review text (max 1000 chars) → setReviewText()
        ↓
Submit → createReview() called
        ↓
Repository inserts into booking_reviews table
        ↓
Database trigger updates shops.average_rating and total_reviews
        ↓
Review appears on shop page
        ↓
UI updates to show "Review Submitted" instead of prompt
```

### Shop Owner Response Flow

```
Customer leaves review on shop
        ↓
Shop owner sees review in dashboard or shop page
        ↓
Clicks "Respond" → ShopResponseField appears
        ↓
Writes response (max 2000 chars)
        ↓
Submits → addShopResponse() called
        ↓
Repository updates booking_reviews.shop_response and responded_at
        ↓
ReviewDisplayWidget shows response below review
        ↓
Customer can no longer edit review (edit window closes)
```

### Review Edit Flow

```
Customer submitted review (shop hasn't responded yet)
        ↓
canEditReview() returns true (review exists AND responded_at IS NULL)
        ↓
UI shows "Edit Review" button
        ↓
ReviewBottomSheet opens with existing rating/text
        ↓
Customer updates rating and/or text
        ↓
Submit → updateReview() called
        ↓
Repository updates existing record
        ↓
updated_at timestamp updates (via trigger)
        ↓
Shop rating recalculated (if rating changed)
        ↓
Updated review appears on shop page
```

### Rating Distribution Flow

```
User opens shop detail page
        ↓
getRatingDistribution() queries rating_distribution view
        ↓
Returns data like: {5: 45, 4: 20, 3: 10, 2: 3, 1: 2}
        ↓
DetailedShopRatingWidget calculates percentages
        ↓
Renders: ★★★★★ (45 reviews, 56%)
        ↓
Renders: ★★★★☆ (20 reviews, 25%)
        ↓
Total reviews displayed: 80
```

## 📦 Dependencies Added in Phase 7

```yaml
dependencies:
  # No new dependencies - uses existing Flutter widgets
```

## 📁 Phase 7 Folder Structure

```
lib/features/reviews/
├── data/
│   ├── models/
│   │   ├── booking_review.dart
│   │   ├── review_rating.dart
│   │   └── shop_rating.dart
│   └── repositories/
│       └── supabase_review_repository.dart
├── domain/
│   ├── providers/
│   │   └── review_providers.dart
│   └── repositories/
│       └── review_repository.dart
└── presentation/
    ├── controllers/
    │   ├── review_submission_controller.dart
    │   └── shop_response_controller.dart
    ├── screens/
    │   └── review_submission_screen.dart
    └── widgets/
        ├── star_rating_widget.dart
        ├── review_bottom_sheet.dart
        ├── review_display_widget.dart
        ├── shop_rating_widget.dart
        ├── detailed_shop_rating_widget.dart
        ├── horizontal_reviews_preview.dart
        ├── rating_distribution_bars.dart
        └── shop_response_field.dart
```

## ⏭️ Next Phase

**Phase 8: Chat System**, which implements Sendbird SDK integration, real-time messaging, channel management, and typing indicators.