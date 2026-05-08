




## Phase 2: Discovery & Search

## 🎯 Overview

The Discovery & Search system enables customers to find shops through map-based exploration, filtered listings, location-aware search, and unified search across multiple categories (shops, profiles, freelancers, products). It uses Mapbox for interactive maps, PostGIS for geospatial queries, and a repository pattern for search across different entity types.

**Dependencies**: Phase 0 (Foundation), Phase 1 (Shop Management)

## 🏗️ Core Decisions

### 1. Map Provider: Mapbox

**Decision**: Mapbox SDK for map rendering

**Why**:

- High-quality vector maps with custom styling
- Excellent Flutter SDK support
- Free tier for development
- Used by Uber, Airbnb, and Snapchat
- Smooth performance with custom markers

### 2. Geospatial Database: PostGIS on Supabase

**Decision**: Supabase with PostGIS extension for geospatial queries

**Why**:

- Native geospatial data types (GEOMETRY, GEOGRAPHY)
- Efficient bounding box queries for viewport markers
- Server-side filtering reduces client payload
- RLS policies protect location data
- Distance calculations at database level

### 3. Search Architecture: Unified Repository Pattern

**Decision**: Multiple parallel search queries with category aggregation

**Why**:

- Single search interface for all content types
- Parallel queries for better performance
- Category-specific result screens
- Consistent pagination across categories
- Easy to add new searchable categories

### 4. API Key Security: Platform-Native Configuration

**Decision**: Mapbox tokens stored natively per platform

**Why**:

- Mapbox SDK requires native access before Flutter initialization
- Keeps tokens out of Dart source code
- Platform-specific best practices
- Build-time token injection

## 🗺️ Map System

### Data Models

**ShopLocationDTO** - Minimal data for map markers:

**Location**: `lib/features/map/data/models/shop_location_dto.dart`

```dart
class ShopLocationDTO extends Equatable {
  final String id;
  final String? shopType;      // salon, barbershop, spa, etc.
  final String? luxuryLevel;   // Moderate, Luxury, UltraLuxury
  final double latitude;
  final double longitude;

  const ShopLocationDTO({
    required this.id,
    this.shopType,
    this.luxuryLevel,
    required this.latitude,
    required this.longitude,
  });
}
```

**ShopListItemDTO** - Full details for bottom sheet:

**Location**: `lib/features/shops/data/dtos/shop_list_item_dto.dart`

```dart
class ShopListItemDTO extends Equatable {
  final String id;
  final String shopName;
  final String? coverImageUrl;
  final double? averageRating;
  final int? numberClientsWorked;
  final String? luxuryLevel;
  final double? distanceKm;
  final bool verified;
  final String? shopType;
  final bool isOpen;
  final String? openStatus;

  const ShopListItemDTO({
    required this.id,
    required this.shopName,
    this.coverImageUrl,
    this.averageRating,
    this.numberClientsWorked,
    this.luxuryLevel,
    this.distanceKm,
    required this.verified,
    this.shopType,
    required this.isOpen,
    this.openStatus,
  });
}
```

### Database Schema (PostGIS)

**Shop Locations Table**:

```sql
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE shop_locations (
  shop_id UUID PRIMARY KEY REFERENCES shops(id) ON DELETE CASCADE,
  address TEXT NOT NULL,
  location GEOGRAPHY(POINT, 4326) NOT NULL,  -- Longitude, Latitude order
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create spatial index for fast bounding box and distance queries
CREATE INDEX idx_shop_locations_location ON shop_locations USING GIST (location);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_shop_locations_updated_at
  BEFORE UPDATE ON shop_locations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### PostGIS Database Functions

**Get Shops in Viewport**:

```sql
CREATE OR REPLACE FUNCTION get_shops_in_viewport(
  p_north DOUBLE PRECISION,
  p_south DOUBLE PRECISION,
  p_east DOUBLE PRECISION,
  p_west DOUBLE PRECISION,
  p_shop_type TEXT DEFAULT NULL,
  p_luxury_level TEXT DEFAULT NULL,
  p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
  id UUID,
  shop_type TEXT,
  luxury_level TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION
) LANGUAGE SQL STABLE AS $$
  SELECT
    s.id,
    s.shop_type,
    s.luxury_level,
    ST_Y(sl.location::GEOMETRY) as latitude,
    ST_X(sl.location::GEOMETRY) as longitude
  FROM shops s
  INNER JOIN shop_locations sl ON sl.shop_id = s.id
  WHERE s.published = true
    AND sl.location && ST_MakeEnvelope(p_west, p_south, p_east, p_north, 4326)
    AND (p_shop_type IS NULL OR s.shop_type = p_shop_type)
    AND (p_luxury_level IS NULL OR s.luxury_level = p_luxury_level)
  LIMIT p_limit;
$$;
```

**Get Shops Nearby**:

```sql
CREATE OR REPLACE FUNCTION get_shops_nearby(
  p_latitude DOUBLE PRECISION,
  p_longitude DOUBLE PRECISION,
  p_radius_km DOUBLE PRECISION,
  p_shop_type TEXT DEFAULT NULL,
  p_luxury_level TEXT DEFAULT NULL,
  p_limit INTEGER DEFAULT 50
)
RETURNS TABLE(
  id UUID,
  shop_name TEXT,
  shop_type TEXT,
  luxury_level TEXT,
  average_rating DECIMAL,
  distance_km DOUBLE PRECISION
) LANGUAGE SQL STABLE AS $$
  SELECT
    s.id,
    s.shop_name,
    s.shop_type,
    s.luxury_level,
    s.average_rating,
    ST_Distance(
      sl.location,
      ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::GEOGRAPHY
    ) / 1000.0 as distance_km
  FROM shops s
  INNER JOIN shop_locations sl ON sl.shop_id = s.id
  WHERE s.published = true
    AND ST_DWithin(
      sl.location,
      ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::GEOGRAPHY,
      p_radius_km * 1000
    )
    AND (p_shop_type IS NULL OR s.shop_type = p_shop_type)
    AND (p_luxury_level IS NULL OR s.luxury_level = p_luxury_level)
  ORDER BY distance_km
  LIMIT p_limit;
$$;
```

**Is Shop Open**:

```sql
CREATE OR REPLACE FUNCTION is_shop_open(
  p_shop_id UUID,
  p_check_time TIMESTAMPTZ DEFAULT NOW()
)
RETURNS BOOLEAN LANGUAGE SQL STABLE AS $$
  SELECT NOT EXISTS (
    SELECT 1 FROM shop_opening_hours oh
    WHERE oh.shop_id = p_shop_id
      AND oh.day_of_week = EXTRACT(DOW FROM p_check_time)
      AND (oh.is_closed = true OR p_check_time::TIME NOT BETWEEN oh.open_time AND oh.close_time)
  );
$$;
```

### Map Repository

**Location**: `lib/features/map/domain/repositories/map_repository.dart`

```dart
abstract class MapRepository {
  // Get shops within viewport bounds
  Future<List<ShopLocationDTO>> getShopsInViewport({
    required double north,
    required double south,
    required double east,
    required double west,
    String? shopType,
    String? luxuryLevel,
    int limit = 100,
  });

  // Get shops within radius
  Future<List<ShopListItemDTO>> getShopsNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? shopType,
    String? luxuryLevel,
    int limit = 50,
  });

  // Check if shop is currently open
  Future<bool> isShopOpen(String shopId, {DateTime? checkTime});

  // Get distance between user and shop
  Future<double> getDistanceToShop(
    String shopId,
    double userLatitude,
    double userLongitude,
  );
}
```

### Map Controller (Riverpod)

**Location**: `lib/features/map/presentation/controllers/map_controller.dart`

```dart
class MapState {
  final List<ShopLocationDTO> markers;
  final MapBounds? bounds;
  final MapFilters filters;
  final bool isLoading;
  final String? error;
  final LatLng? userLocation;

  const MapState({
    this.markers = const [],
    this.bounds,
    this.filters = const MapFilters(),
    this.isLoading = false,
    this.error,
    this.userLocation,
  });

  MapState copyWith({...});
}

class MapController extends StateNotifier<MapState> {
  final MapRepository _repository;
  Timer? _debounceTimer;

  MapController(this._repository) : super(const MapState());

  // Update viewport with debounce (300ms)
  void updateViewport(MapBounds bounds, MapFilters filters) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      await _loadMarkers(bounds, filters);
    });
  }

  // Load markers within bounds
  Future<void> _loadMarkers(MapBounds bounds, MapFilters filters) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.getShopsInViewport(
      north: bounds.north,
      south: bounds.south,
      east: bounds.east,
      west: bounds.west,
      shopType: filters.shopType,
      luxuryLevel: filters.luxuryLevel,
    );

    state = state.copyWith(
      markers: result,
      bounds: bounds,
      filters: filters,
      isLoading: false,
    );
  }

  // Manual refresh
  Future<void> refresh() async {
    if (state.bounds != null) {
      await _loadMarkers(state.bounds!, state.filters);
    }
  }
}
```

### Custom Marker System

**CanvasMarkerBuilder**:

**Location**: `lib/features/map/presentation/widgets/canvas_marker_builder.dart`

```dart
class CanvasMarkerBuilder {
  static Future<Uint8List> drawSimpleMarker({
    required String typeCode,      // e.g., "SALON", "BARB", "SPA"
    required Color luxuryColor,    // Green=Moderate, Purple=Luxury, Amber=UltraLuxury
    required BuildContext context,
    bool isSelected = false,
    double width = 120,
    double height = 50,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = luxuryColor;

    // Draw rounded rectangle background
    final rect = Rect.fromLTWH(0, 0, width, height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(25));
    canvas.drawRRect(rrect, paint);

    // Draw text
    final textSpan = TextSpan(
      text: typeCode,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((width - textPainter.width) / 2, (height - textPainter.height) / 2),
    );

    // Add arrow pointer if selected
    if (isSelected) {
      final path = Path();
      path.moveTo(width / 2 - 10, height);
      path.lineTo(width / 2, height + 15);
      path.lineTo(width / 2 + 10, height);
      canvas.drawPath(path, paint);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
```

**Luxury Level Colors**:

| Level       | Color Code | Visual |
| ----------- | ---------- | ------ |
| Moderate    | `#4CAF50`  | Green  |
| Luxury      | `#9C27B0`  | Purple |
| UltraLuxury | `#FF8C00`  | Amber  |

### Map UI Components

| Widget                  | Location                                                             | Purpose                     |
| ----------------------- | -------------------------------------------------------------------- | --------------------------- |
| `MapScreen`             | `lib/features/map/presentation/screens/map_screen.dart`              | Main map view with markers  |
| `MapFilterBar`          | `lib/features/map/presentation/widgets/map_filter_bar.dart`          | Category and luxury filters |
| `ShopInfoBottomSheet`   | `lib/features/map/presentation/widgets/shop_info_bottom_sheet.dart`  | Shop details on marker tap  |
| `AnimatedMarkerManager` | `lib/features/map/presentation/widgets/animated_marker_manager.dart` | Manages marker animations   |
| `UserLocationButton`    | `lib/features/map/presentation/widgets/user_location_button.dart`    | Centers map on user         |

## 🔍 Search System

### Search Models

**SearchCategory**:

**Location**: `lib/features/search/models/search_category.dart`

```dart
enum SearchCategory {
  all,        // Shows mixed results
  shops,      // Service shops only
  freelancers,// Individual service providers
  products,   // Products for sale
  profiles,   // User profiles
}

extension SearchCategoryExtension on SearchCategory {
  String get displayName {
    switch (this) {
      case SearchCategory.all:
        return 'All';
      case SearchCategory.shops:
        return 'Shops';
      case SearchCategory.freelancers:
        return 'Freelancers';
      case SearchCategory.products:
        return 'Products';
      case SearchCategory.profiles:
        return 'Profiles';
    }
  }

  IconData get icon {
    switch (this) {
      case SearchCategory.all:
        return Icons.search;
      case SearchCategory.shops:
        return Icons.store;
      case SearchCategory.freelancers:
        return Icons.work;
      case SearchCategory.products:
        return Icons.shopping_bag;
      case SearchCategory.profiles:
        return Icons.person;
    }
  }
}
```

**SearchFilters**:

**Location**: `lib/features/search/models/search_filters.dart`

```dart
class SearchFilters extends Equatable {
  final bool verifiedOnly;
  final double? minRating;
  final double? maxDistanceKm;
  final String? luxuryLevel;

  const SearchFilters({
    this.verifiedOnly = false,
    this.minRating,
    this.maxDistanceKm,
    this.luxuryLevel,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      if (verifiedOnly) 'verified': true,
      if (minRating != null) 'min_rating': minRating,
      if (maxDistanceKm != null) 'max_distance': maxDistanceKm,
      if (luxuryLevel != null) 'luxury_level': luxuryLevel,
    };
  }

  @override
  List<Object?> get props => [verifiedOnly, minRating, maxDistanceKm, luxuryLevel];
}
```

**Unified Search Result**:

**Location**: `lib/features/search/models/unified_search_result.dart`

```dart
sealed class UnifiedSearchResult {}

class ShopSearchResult extends UnifiedSearchResult {
  final String id;
  final String shopName;
  final String? coverImageUrl;
  final double? averageRating;
  final String? luxuryLevel;
  final bool verified;
  final double? distanceKm;

  const ShopSearchResult({...});
}

class ProfileSearchResult extends UnifiedSearchResult {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final double? rating;

  const ProfileSearchResult({...});
}

// FreelancerSearchResult, ProductSearchResult similarly defined
```

### Search Repositories

**ShopSearchRepository**:

**Location**: `lib/features/search/data/repositories/shop_search_repository.dart`

```dart
class ShopSearchRepository {
  final SupabaseClient _client;

  Future<PaginatedResult<ShopSearchResult>> search({
    required String query,
    SearchFilters? filters,
    String? cursor,
    int limit = 15,
  }) async {
    PostgrestFilterBuilder q = _client.from('shows').select('''
      id, shop_name, cover_image_url, average_rating,
      luxury_level, verified, shop_type
    ''');

    // Apply search query
    if (query.isNotEmpty) {
      q = q.ilike('shop_name', '%$query%');
    }

    // Apply filters
    if (filters?.verifiedOnly == true) {
      q = q.eq('verified', true);
    }
    if (filters?.minRating != null) {
      q = q.gte('average_rating', filters!.minRating!);
    }

    // Apply cursor-based pagination (MUST be before order)
    if (cursor != null) {
      q = q.gt('id', cursor);
    }

    // Apply order and limit
    final response = await q
        .order('shop_name')
        .limit(limit + 1);  // Request +1 to detect hasMore

    final results = response.map((json) => ShopSearchResult.fromJson(json)).toList();
    final hasMore = results.length > limit;
    if (hasMore) results.removeLast();

    return PaginatedResult(
      items: results,
      nextCursor: hasMore ? results.last.id : null,
      hasMore: hasMore,
    );
  }
}
```

**UnifiedSearchRepository**:

**Location**: `lib/features/search/data/repositories/unified_search_repository.dart`

```dart
class UnifiedSearchRepository {
  final ShopSearchRepository _shopRepo;
  final ProfileSearchRepository _profileRepo;

  // Search all categories in parallel
  Future<List<CategorySearchSection>> searchAllSections({
    required String query,
    SearchFilters? filters,
  }) async {
    final results = await Future.wait([
      _shopRepo.search(query: query, filters: filters, limit: 5),
      _profileRepo.search(query: query, filters: filters, limit: 5),
      // Add freelancer, product searches here
    ]);

    final sections = <CategorySearchSection>[];

    if (results[0].items.isNotEmpty) {
      sections.add(CategorySearchSection(
        category: SearchCategory.shops,
        items: results[0].items,
        totalCount: results[0].hasMore ? results[0].items.length + 1 : results[0].items.length,
      ));
    }

    if (results[1].items.isNotEmpty) {
      sections.add(CategorySearchSection(
        category: SearchCategory.profiles,
        items: results[1].items,
        totalCount: results[1].hasMore ? results[1].items.length + 1 : results[1].items.length,
      ));
    }

    return sections;
  }

  // Category-specific search with pagination
  Future<PaginatedResult<UnifiedSearchResult>> searchByCategory({
    required SearchCategory category,
    required String query,
    SearchFilters? filters,
    String? cursor,
    int limit = 15,
  }) async {
    switch (category) {
      case SearchCategory.shops:
        return _shopRepo.search(query: query, filters: filters, cursor: cursor, limit: limit);
      case SearchCategory.profiles:
        return _profileRepo.search(query: query, filters: filters, cursor: cursor, limit: limit);
      default:
        throw UnimplementedError('Category $category not implemented');
    }
  }
}
```

### Search History Storage

**Location**: `lib/features/search/data/local/search_history_storage.dart`

```dart
class SearchHistoryStorage {
  static const String _key = 'search_history';
  static const int _maxHistory = 20;

  static Future<List<String>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> saveHistory(List<String> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, history);
  }

  static Future<void> addToHistory(String query) async {
    final history = await loadHistory();
    final newHistory = [query, ...history.where((q) => q != query)].take(_maxHistory).toList();
    await saveHistory(newHistory);
  }

  static Future<void> clearHistory() async {
    await saveHistory([]);
  }
}
```

### Search State Management

**SearchNotifier** (Debounced Search):

**Location**: `lib/features/search/presentation/state/search_providers.dart`

```dart
class SearchState {
  final String query;
  final SearchCategory selectedCategory;
  final SearchFilters filters;
  final List<CategorySearchSection> sections;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const SearchState({
    this.query = '',
    this.selectedCategory = SearchCategory.all,
    this.filters = const SearchFilters(),
    this.sections = const [],
    this.isLoading = false,
    this.hasMore = false,
    this.error,
  });
}

class SearchNotifier extends StateNotifier<SearchState> {
  final UnifiedSearchRepository _searchRepo;
  Timer? _debounceTimer;

  SearchNotifier(this._searchRepo) : super(const SearchState());

  void updateQuery(String query) {
    state = state.copyWith(query: query);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  void updateCategory(SearchCategory category) {
    state = state.copyWith(selectedCategory: category);
    _performSearch(resetPagination: true);
  }

  Future<void> _performSearch({bool resetPagination = true}) async {
    if (state.query.isEmpty) {
      state = state.copyWith(sections: [], isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      if (state.selectedCategory == SearchCategory.all) {
        final sections = await _searchRepo.searchAllSections(
          query: state.query,
          filters: state.filters,
        );
        state = state.copyWith(sections: sections, isLoading: false);
      } else {
        final result = await _searchRepo.searchByCategory(
          category: state.selectedCategory,
          query: state.query,
          filters: state.filters,
        );
        // Convert to CategorySearchSection
        final section = CategorySearchSection(
          category: state.selectedCategory,
          items: result.items,
          totalCount: result.hasMore ? result.items.length + 1 : result.items.length,
        );
        state = state.copyWith(
          sections: [section],
          hasMore: result.hasMore,
          isLoading: false,
        );
      }

      // Add to search history
      if (state.query.isNotEmpty) {
        await SearchHistoryStorage.addToHistory(state.query);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
```

## 🎨 Search UI Components

### Screens

| Screen                  | Location                                                                | Purpose                                                      |
| ----------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------ |
| `SearchScreen`          | `lib/features/search/presentation/screens/search_screen.dart`           | Main search with animated bar, category chips, mixed results |
| `CategoryResultsScreen` | `lib/features/search/presentation/screens/category_results_screen.dart` | Category-specific paginated results                          |

### Widgets

| Widget                 | Location                                                               | Purpose                                   |
| ---------------------- | ---------------------------------------------------------------------- | ----------------------------------------- |
| `SearchAppBar`         | `lib/features/search/presentation/widgets/search_app_bar.dart`         | Animated search bar with slide/fade       |
| `CategoryFilterChips`  | `lib/features/search/presentation/widgets/category_filter_chips.dart`  | Horizontal category selection chips       |
| `SearchSuggestions`    | `lib/features/search/presentation/widgets/search_suggestions.dart`     | Recent search history display             |
| `CategoryResultCard`   | `lib/features/search/presentation/widgets/category_result_card.dart`   | Unified card for all result types         |
| `HorizontalShopList`   | `lib/features/search/presentation/widgets/horizontal_shop_list.dart`   | Horizontal scroll of shops (for All view) |
| `VerticalCategoryList` | `lib/features/search/presentation/widgets/vertical_category_list.dart` | Vertical list for non-shop categories     |

## 📍 Location Services

### Location Service

**Location**: `lib/core/services/location_service.dart`

```dart
class LocationService {
  final GeolocatorPlatform _geolocator = GeolocatorPlatform.instance;

  // Get current user location
  Future<LatLng> getCurrentLocation() async {
    final permission = await _geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await _geolocator.requestPermission();
      if (requested == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    final position = await _geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  // Calculate distance using Haversine formula
  double calculateDistance(LatLng from, LatLng to) {
    const double R = 6371; // Earth's radius in km

    final dLat = _toRadians(to.latitude - from.latitude);
    final dLon = _toRadians(to.longitude - from.longitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(from.latitude)) * cos(_toRadians(to.latitude)) *
        sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  // Get country code from coordinates using reverse geocoding
  Future<String> getCountryCode(LatLng position) async {
    final places = await GeocodingPlatform.instance.placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    return places.first.isoCountryCode ?? 'US';
  }

  // Get currency code from country code
  String getCurrencyCode(String countryCode) {
    const countryCurrency = {
      'GH': 'GHS',  // Ghana
      'NG': 'NGN',  // Nigeria
      'KE': 'KES',  // Kenya
      'ZA': 'ZAR',  // South Africa
      'US': 'USD',  // United States
      'GB': 'GBP',  // United Kingdom
    };
    return countryCurrency[countryCode] ?? 'GHS';
  }
}
```

## 🔄 Key Flows

### Map Discovery Flow

```
User opens Map Screen
        ↓
Request location permission
        ↓
Center map on user location
        ↓
Camera idle triggers viewport update (debounced 300ms)
        ↓
Call get_shops_in_viewport() Supabase function
        ↓
Render markers with custom canvas drawings
        ↓
User taps marker → Show ShopInfoBottomSheet
        ↓
Bottom sheet loads full shop details
        ↓
User taps "View Shop" → Navigate to Shop Details
```

### Search Flow (All Categories)

```
User taps search bar
        ↓
Animated expansion with slide/fade
        ↓
Show recent search suggestions
        ↓
User types query (debounced 300ms)
        ↓
Parallel queries: shops (5), profiles (5), freelancers (5)
        ↓
Render "All" view:
  - Horizontal shop section (max 5)
  - Vertical categories below (max 5 each)
        ↓
User taps "See All" on a category
        ↓
Navigate to CategoryResultsScreen with pagination
```

### Category Results Pagination

```
Initial load: 15 items
        ↓
User scrolls to bottom
        ↓
Load more: 5 items per page
        ↓
hasMore detection: Request limit + 1, compare lengths
        ↓
Show loading indicator at bottom
        ↓
Pull-to-refresh resets pagination
```

## 📊 Pagination Strategy

### "All" View

| Category    | Initial Load | "See All" Action            |
| ----------- | ------------ | --------------------------- |
| Shops       | 5 items      | Navigate to category screen |
| Profiles    | 5 items      | Navigate to category screen |
| Freelancers | 5 items      | Navigate to category screen |

### Category-Specific View

| Parameter           | Value                                |
| ------------------- | ------------------------------------ |
| Initial Load        | 15 items                             |
| Pagination          | 5 items per page                     |
| `hasMore` detection | Request `limit + 1`, compare lengths |
| Cursor              | Last item's ID                       |

## 🗺️ Map Filtering Logic

### Filter Types

| Filter       | Options                                  | Default |
| ------------ | ---------------------------------------- | ------- |
| Shop Type    | All, Salon, Barbershop, Spa, Nail Studio | All     |
| Luxury Level | All, Moderate, Luxury, UltraLuxury       | All     |

### Quick Filters (Search Level)

| Filter        | Purpose                  |
| ------------- | ------------------------ |
| Verified Only | Show only verified shops |
| Top Rated     | Minimum rating 4.5       |
| Near Me       | Within 5km radius        |

## 📦 Dependencies Added in Phase 2

```yaml
dependencies:
  # Maps
  mapbox_gl: ^0.16.0
  mapbox_gl_web: ^0.16.0

  # Location
  geolocator: ^10.1.0
  geocoding: ^2.1.1

  # Search & Utilities
  equatable: ^2.0.5
  flutter_animate: ^4.1.1

dev_dependencies:
  build_runner: ^2.4.6
```

## 📁 Phase 2 Folder Structure

```
lib/features/
├── map/
│   ├── data/
│   │   ├── models/
│   │   │   └── shop_location_dto.dart
│   │   ├── repositories/
│   │   │   └── map_repository_impl.dart
│   │   └── datasources/
│   │       └── supabase_map_datasource.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   └── map_bounds.dart
│   │   └── repositories/
│   │       └── map_repository.dart
│   └── presentation/
│       ├── controllers/
│       │   └── map_controller.dart
│       ├── providers/
│       │   ├── map_providers.dart
│       │   └── map_filter_providers.dart
│       ├── screens/
│       │   └── map_screen.dart
│       └── widgets/
│           ├── animated_marker_manager.dart
│           ├── canvas_marker_builder.dart
│           ├── marker_code_generator.dart
│           ├── shop_info_bottom_sheet_loader.dart
│           ├── shop_info_bottom_sheet.dart
│           ├── map_filter_bar.dart
│           └── user_location_button.dart
│
├── search/
│   ├── data/
│   │   ├── local/
│   │   │   └── search_history_storage.dart
│   │   └── repositories/
│   │       ├── shop_search_repository.dart
│   │       ├── profile_search_repository.dart
│   │       └── unified_search_repository.dart
│   ├── domain/
│   │   ├── mappers/
│   │   │   └── shop_to_search_mapper.dart
│   │   └── repositories/
│   │       └── search_repository.dart
│   ├── models/
│   │   ├── search_category.dart
│   │   ├── search_filters.dart
│   │   ├── search_params.dart
│   │   ├── search_paginated_result.dart
│   │   ├── unified_search_result.dart
│   │   ├── shop_search_result.dart
│   │   ├── profile_search_result.dart
│   │   └── category_search_section.dart
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── search_screen.dart
│   │   │   └── category_results_screen.dart
│   │   ├── state/
│   │   │   └── search_providers.dart
│   │   └── widgets/
│   │       ├── category_filter_chips.dart
│   │       ├── category_result_card.dart
│   │       ├── horizontal_shop_list.dart
│   │       ├── search_suggestions.dart
│   │       ├── vertical_category_list.dart
│   │       └── search_app_bar.dart
│   └── utils/
│       └── search_analytics.dart
│
└── location/
    ├── models/
    │   └── user_location.dart
    ├── providers/
    │   └── location_provider.dart
    ├── screens/
    │   └── location_search_screen.dart
    └── widgets/
        ├── location_display_widget.dart
        └── location_picker_bottom_sheet.dart
```

## ⏭️ Next Phase

**Phase 3: Booking System**, which implements single/multi-service booking, group bookings, parallel worker assignment, and time slot generation.
