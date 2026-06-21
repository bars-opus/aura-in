# Freelancer Tags & Product Discovery Rails Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a curated+custom multi-select freelancer Tags system that filters/groups freelancers on discover, and add Top-Rated + Near-You product rails to the discover Buy tab.

**Architecture:** Feature A reuses the existing `workers.specialties text[]` column (no storage migration); a new selector widget replaces the free-text specialties input, a new multi-select chip row + selected-tags provider drive discovery, and `get_nearby_freelancers` overload B gains a `p_tags text[]` overlap filter. Feature B reuses the existing `discover_products` RPC via two new FutureProviders and two new horizontal rail widgets, wired into the discover screen's Buy branch — mirroring the freelancer rails exactly.

**Tech Stack:** Flutter, Riverpod, Supabase (Postgres + PostGIS RPCs), flutter_test.

## Global Constraints

- Money is never float; this work introduces no money math (checklist 2.19) — leave price formatting on the existing `ProductModel.formattedPrice` path.
- All filtering goes through RPC params, never string-built SQL (checklist 2.2).
- Custom tag input: trim + collapse whitespace, reject empty, max 40 chars, case-insensitive de-dup, max 15 tags per freelancer (checklist 2.1, 2.5).
- Available-tags RPC caps at 100 rows; product rails request limit 10; `discover_products` keeps its existing ≤50 clamp (checklist 2.5).
- DB column stays named `specialties`; the UI concept is "Tags" — add a code comment noting the mapping at each touch point.
- `get_top_rated_freelancers` (no-location fallback) is NOT modified — its source is not in any tracked migration. Tag filtering applies only to location-based paths.
- Empty rails / failed chip-count RPC render `SizedBox.shrink()` so discover never shows an empty rail or breaks.
- Match surrounding code style; reuse `AppFilterChip`, `ProductGridItem`, and the freelancer horizontal-section shell rather than re-implementing.
- Run `flutter analyze <touched files>` clean after every task; commit per task.

---

## File Structure

**Feature A (Freelancer Tags):**
- Create: `lib/core/constants/freelancer_tags.dart` — curated vocab + `normalize`.
- Create: `lib/presentation/features/freelancer/creation/presentation/widgets/freelancer_tags_selector.dart` — input UX.
- Create: `lib/presentation/features/freelancer/creation/presentation/providers/selected_freelancer_tags_provider.dart` — discover selection state.
- Create: `lib/presentation/features/freelancer/creation/presentation/widgets/freelancer_tag_chips.dart` — multi-select discover chip row.
- Create migration: `supabase/migrations/20260621030000_freelancer_tags.sql` — `freelancer_tags_with_counts` + `get_nearby_freelancers` overload B `p_tags`.
- Modify: `freelancer_basics_screen.dart` — swap specialties block for the selector.
- Modify: `supabase_freelancer_repository.dart` — `tags` param on `getNearbyFreelancers` + new `getFreelancerTags`.
- Modify: `freelancer_discovery_provider.dart` — pass tags from the 3 providers.
- Modify: `discover_screen.dart` — render `FreelancerTagChips` in the freelancers branch.

**Feature B (Product Rails):**
- Create: `lib/presentation/features/products/presentation/widgets/top_rated_products_horizontal.dart`.
- Create: `lib/presentation/features/products/presentation/widgets/near_you_products_horizontal.dart`.
- Modify: `marketplace_providers.dart` — `topRatedProductsProvider` + `nearYouProductsProvider`.
- Modify: `discover_screen.dart` — render the two rails in the Buy branch.

**Tests:**
- Create: `test/core/constants/freelancer_tags_test.dart`
- Create: `test/features/products/marketplace_rail_providers_test.dart`

---

## FEATURE A: FREELANCER TAGS

### Task A1: Curated tag vocabulary + normalize helper

**Files:**
- Create: `lib/core/constants/freelancer_tags.dart`
- Test: `test/core/constants/freelancer_tags_test.dart`

**Interfaces:**
- Produces: `FreelancerTags.curated` (`List<String>`), `FreelancerTags.normalize(String) → String`.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/constants/freelancer_tags_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/constants/freelancer_tags.dart';

void main() {
  group('FreelancerTags.normalize', () {
    test('trims surrounding whitespace', () {
      expect(FreelancerTags.normalize('  Haircut  '), 'Haircut');
    });
    test('collapses internal whitespace', () {
      expect(FreelancerTags.normalize('Bridal   Makeup'), 'Bridal Makeup');
    });
    test('empty after trim returns empty string', () {
      expect(FreelancerTags.normalize('   '), '');
    });
  });

  test('curated list is non-empty and has no duplicates', () {
    expect(FreelancerTags.curated, isNotEmpty);
    expect(FreelancerTags.curated.toSet().length, FreelancerTags.curated.length);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/constants/freelancer_tags_test.dart`
Expected: FAIL — `freelancer_tags.dart` does not exist / `FreelancerTags` undefined.

- [ ] **Step 3: Write the implementation**

```dart
// lib/core/constants/freelancer_tags.dart
/// Curated freelancer tag vocabulary. Tags are stored in the
/// `workers.specialties text[]` DB column (the column keeps its legacy name;
/// the product concept is "Tags"). Freelancers may also add custom tags
/// not in this list.
class FreelancerTags {
  FreelancerTags._();

  static const List<String> curated = [
    'Haircut',
    'Hair Coloring',
    'Balayage',
    'Braids',
    'Locs',
    'Wig Install',
    'Manicure',
    'Pedicure',
    'Nail Art',
    'Acrylics',
    'Makeup',
    'Bridal Makeup',
    'Lashes',
    'Brows',
    'Facial',
    'Waxing',
    'Massage',
    'Barbering',
  ];

  /// Max number of tags a freelancer may select (resource cap).
  static const int maxTags = 15;

  /// Max length of a single custom tag.
  static const int maxTagLength = 40;

  /// Normalize a tag for storage / comparison: trim + collapse internal
  /// whitespace. Returns '' if nothing remains after trimming.
  static String normalize(String raw) =>
      raw.trim().replaceAll(RegExp(r'\s+'), ' ');
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/constants/freelancer_tags_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/core/constants/freelancer_tags.dart test/core/constants/freelancer_tags_test.dart
git commit -m "feat(freelancer): curated tag vocabulary + normalize helper"
```

---

### Task A2: FreelancerTagsSelector input widget

**Files:**
- Create: `lib/presentation/features/freelancer/creation/presentation/widgets/freelancer_tags_selector.dart`

**Interfaces:**
- Consumes: `FreelancerTags.curated`, `FreelancerTags.normalize`, `FreelancerTags.maxTags`, `FreelancerTags.maxTagLength` (Task A1); `AppFilterChip` (`label`, `selected`, `onSelected`); `Spacing`, `BorderRadiusTokens`.
- Produces: `FreelancerTagsSelector({required List<String> selectedTags, required ValueChanged<List<String>> onTagsChanged})`.

> Note: this is a stateless widget over a parent-owned list (the screen owns the
> `List<String>`, seeded from `draft.specialties`). It emits a new list on every
> change; it does NOT keep its own copy of the selection.

- [ ] **Step 1: Write the implementation**

```dart
// lib/presentation/features/freelancer/creation/presentation/widgets/freelancer_tags_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/constants/freelancer_tags.dart';
import 'package:nano_embryo/core/widgets/app_filer_chip.dart';

/// Multi-select tag picker for freelancers. Curated chips + custom add.
/// Selection is owned by the parent (persisted into the `specialties` column).
class FreelancerTagsSelector extends StatefulWidget {
  final List<String> selectedTags;
  final ValueChanged<List<String>> onTagsChanged;

  const FreelancerTagsSelector({
    super.key,
    required this.selectedTags,
    required this.onTagsChanged,
  });

  @override
  State<FreelancerTagsSelector> createState() => _FreelancerTagsSelectorState();
}

class _FreelancerTagsSelectorState extends State<FreelancerTagsSelector> {
  final _customController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  bool _isSelected(String tag) => widget.selectedTags
      .any((t) => t.toLowerCase() == tag.toLowerCase());

  void _toggle(String tag, bool select) {
    final next = List<String>.from(widget.selectedTags);
    if (select) {
      if (next.length >= FreelancerTags.maxTags) {
        setState(() => _error = 'You can select at most ${FreelancerTags.maxTags} tags');
        return;
      }
      if (!next.any((t) => t.toLowerCase() == tag.toLowerCase())) {
        next.add(tag);
      }
    } else {
      next.removeWhere((t) => t.toLowerCase() == tag.toLowerCase());
    }
    setState(() => _error = null);
    widget.onTagsChanged(next);
  }

  void _addCustom() {
    final value = FreelancerTags.normalize(_customController.text);
    if (value.isEmpty) {
      setState(() => _error = 'Enter a tag');
      return;
    }
    if (value.length > FreelancerTags.maxTagLength) {
      setState(() => _error = 'Tag too long (max ${FreelancerTags.maxTagLength})');
      return;
    }
    if (_isSelected(value)) {
      setState(() => _error = 'Already added');
      return;
    }
    if (widget.selectedTags.length >= FreelancerTags.maxTags) {
      setState(() => _error = 'You can select at most ${FreelancerTags.maxTags} tags');
      return;
    }
    final next = List<String>.from(widget.selectedTags)..add(value);
    _customController.clear();
    setState(() => _error = null);
    widget.onTagsChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Custom tags = selected tags not present in the curated list.
    final customTags = widget.selectedTags
        .where((t) => !FreelancerTags.curated
            .any((c) => c.toLowerCase() == t.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Spacing.sm.w,
          runSpacing: Spacing.sm.h,
          children: FreelancerTags.curated.map((tag) {
            return AppFilterChip(
              label: tag,
              selected: _isSelected(tag),
              labelColor: colorScheme.onSurface.withOpacity(0.7),
              onSelected: (sel) => _toggle(tag, sel),
            );
          }).toList(),
        ),
        Gap(Spacing.md.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customController,
                decoration: InputDecoration(
                  hintText: 'Add a custom tag',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(BorderRadiusTokens.md.r),
                  ),
                ),
                onSubmitted: (_) => _addCustom(),
              ),
            ),
            Gap(Spacing.sm.w),
            IconButton(
              onPressed: _addCustom,
              icon: Icon(Icons.add_circle, color: colorScheme.primary),
            ),
          ],
        ),
        if (_error != null) ...[
          Gap(Spacing.xs.h),
          Text(
            _error!,
            style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.error),
          ),
        ],
        if (customTags.isNotEmpty) ...[
          Gap(Spacing.sm.h),
          Wrap(
            spacing: Spacing.sm.w,
            runSpacing: Spacing.sm.h,
            children: customTags.map((tag) {
              return Chip(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: colorScheme.outline.withOpacity(.3),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(BorderRadiusTokens.md.r),
                ),
                label: Text(
                  tag,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                onDeleted: () => _toggle(tag, false),
                deleteIcon: Icon(Icons.close, size: 14.h, color: colorScheme.error),
              );
            }).toList(),
          ),
        ],
        Gap(Spacing.sm.h),
        Text(
          'Select all that apply, or add your own. Up to ${FreelancerTags.maxTags}.',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze lib/presentation/features/freelancer/creation/presentation/widgets/freelancer_tags_selector.dart`
Expected: No errors. (Resolve any import-path mismatch for `app_filer_chip.dart` / `design_tokens.dart` by matching the paths used in `freelancer_type_selector.dart`.)

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/features/freelancer/creation/presentation/widgets/freelancer_tags_selector.dart
git commit -m "feat(freelancer): tags selector widget (curated chips + custom add)"
```

---

### Task A3: Replace specialties block in FreelancerBasicsScreen

**Files:**
- Modify: `lib/presentation/features/freelancer/creation/presentation/screens/freelancer_basics_screen.dart`

**Interfaces:**
- Consumes: `FreelancerTagsSelector` (Task A2); existing `freelancerCreationProvider.updateProfile(specialties: List<String>)` and `draft.specialties`.

- [ ] **Step 1: Remove the old specialties plumbing**

Delete the `_specialtiesController` field (line ~25), the `_specialtiesList` field (line ~26), the `_addSpecialty()` method (lines ~54-65), the `_removeSpecialty(int)` method (lines ~67-74), the `_specialtiesController.dispose()` line in `dispose()`, and the `_specialtiesList` seeding in `_loadExistingData()`. Replace the `_loadExistingData` specialties line with nothing (the selector reads from `draft.specialties` directly via `build`).

- [ ] **Step 2: Replace the specialties `CardInkWell` block**

Replace the entire `CardInkWell` containing the "Specialties" UI (the block at lines ~191-261, the text-field + add-button + custom `Chip` wrap) with:

```dart
            // Tags (stored in the `specialties` column; concept is "Tags").
            CardInkWell(
              margin: EdgeInsets.only(bottom: Spacing.md.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tags', style: titleStyle),
                  Text(
                    'Tag the services you offer so clients can find you',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Gap(Spacing.sm.h),
                  FreelancerTagsSelector(
                    selectedTags: draft.specialties,
                    onTagsChanged: (tags) {
                      ref
                          .read(freelancerCreationProvider.notifier)
                          .updateProfile(specialties: tags);
                    },
                  ),
                ],
              ),
            ),
```

- [ ] **Step 3: Add the import**

Add near the other widget imports:

```dart
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/widgets/freelancer_tags_selector.dart';
```

- [ ] **Step 4: Verify it compiles**

Run: `flutter analyze lib/presentation/features/freelancer/creation/presentation/screens/freelancer_basics_screen.dart`
Expected: No errors, no unused-field warnings for the removed controllers/lists.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/features/freelancer/creation/presentation/screens/freelancer_basics_screen.dart
git commit -m "feat(freelancer): use FreelancerTagsSelector for tags input"
```

---

### Task A4: Migration — tag-count RPC + p_tags filter on get_nearby_freelancers

**Files:**
- Create: `supabase/migrations/20260621030000_freelancer_tags.sql`

**Interfaces:**
- Produces RPC `freelancer_tags_with_counts(p_user_lat, p_user_lng, p_radius_km, p_limit) → table(tag text, count bigint)`.
- Produces updated RPC `get_nearby_freelancers(... , p_tags text[] default null)` (overload B signature) filtering `w.specialties && p_tags`.

> The new `get_nearby_freelancers` body MUST be copied verbatim from overload B
> in `supabase/migrations/20260620150000_nearby_rpcs_add_seed.sql` (the
> `p_freelancer_types text[]` + `p_page_limit`/`p_page_offset` + `p_seed`
> overload), adding only the `p_tags` param and one WHERE predicate. Read that
> file first and reproduce the SELECT/JOIN/ORDER BY exactly so nothing else
> changes. `specialties` lives on `workers w`; gate predicates (`w.is_freelancer`,
> `w.is_active`, `w.verification_status = 'approved'`) live on `workers w`;
> location lives on `freelancer_details fd`.

- [ ] **Step 1: Write the migration**

```sql
-- supabase/migrations/20260621030000_freelancer_tags.sql
-- Freelancer tags = workers.specialties text[]. Adds a tag-count RPC for the
-- discover chip row, and a p_tags overlap filter on get_nearby_freelancers
-- overload B (the text[] + paged overload the Dart repo calls).

-- 1) Distinct tags + counts among discoverable freelancers within radius.
create or replace function public.freelancer_tags_with_counts(
  p_user_lat double precision default null,
  p_user_lng double precision default null,
  p_radius_km double precision default null,
  p_limit int default 40
)
returns table(tag text, count bigint)
language sql stable
as $$
  select t.tag, count(*)::bigint as count
  from public.workers w
  inner join public.freelancer_details fd on w.id = fd.worker_id
  cross join lateral unnest(w.specialties) as t(tag)
  where w.is_freelancer = true
    and w.is_active = true
    and w.verification_status = 'approved'
    and (
      p_user_lat is null or p_user_lng is null or p_radius_km is null
      or (
        fd.base_latitude is not null and fd.base_longitude is not null
        and ST_DWithin(
          ST_SetSRID(ST_MakePoint(fd.base_longitude, fd.base_latitude), 4326)::geography,
          ST_SetSRID(ST_MakePoint(p_user_lng, p_user_lat), 4326)::geography,
          p_radius_km * 1000)
      )
    )
  group by t.tag
  order by count desc, t.tag asc
  limit least(greatest(coalesce(p_limit, 40), 1), 100);
$$;

-- 2) Drop the exact prior overload-B signature, then recreate with p_tags.
--    DROP-before-CREATE avoids PGRST203 ambiguity from a new overload.
drop function if exists public.get_nearby_freelancers(
  double precision, double precision, double precision, text[], numeric, text, integer, integer, int
);

create or replace function public.get_nearby_freelancers(
  p_user_lat double precision,
  p_user_lng double precision,
  p_radius_km double precision default 10,
  p_freelancer_types text[] default null::text[],
  p_min_rating numeric default null::numeric,
  p_sort_by text default 'distance'::text,
  p_page_limit integer default 20,
  p_page_offset integer default 0,
  p_seed int default 0,
  p_tags text[] default null::text[]
)
returns table(worker_id uuid, name text, profile_image text, bio text, specialties text[], freelancer_type text, freelancer_types text[], tools text[], can_travel boolean, travel_radius_km integer, average_rating numeric, total_reviews integer, total_bookings integer, total_revenue numeric, distance_km double precision, base_latitude double precision, base_longitude double precision, is_identity_verified boolean, is_background_checked boolean)
language plpgsql
as $function$
BEGIN
  RETURN QUERY
  SELECT
    w.id as worker_id,
    w.name,
    w.profile_image_url as profile_image,
    w.bio,
    w.specialties,
    fd.freelancer_type,
    fd.freelancer_types,
    fd.tools,
    fd.can_travel,
    fd.travel_radius_km,
    COALESCE(fd.rating, 0) as average_rating,
    COALESCE(fd.total_reviews, 0) as total_reviews,
    COALESCE(fd.total_bookings, 0) as total_bookings,
    COALESCE(fd.total_revenue, 0) as total_revenue,
    ROUND(
      (ST_Distance(
        ST_SetSRID(ST_MakePoint(p_user_lng, p_user_lat), 4326)::geography,
        ST_SetSRID(ST_MakePoint(fd.base_longitude, fd.base_latitude), 4326)::geography
      ) / 1000)::NUMERIC,
      2
    )::DOUBLE PRECISION as distance_km,
    fd.base_latitude,
    fd.base_longitude,
    COALESCE(fd.is_identity_verified, false) as is_identity_verified,
    COALESCE(fd.is_background_checked, false) as is_background_checked
  FROM workers w
  INNER JOIN freelancer_details fd ON w.id = fd.worker_id
  WHERE
    w.is_freelancer = true
    AND w.is_active = true
    AND w.verification_status = 'approved'
    AND fd.base_latitude IS NOT NULL
    AND fd.base_longitude IS NOT NULL
    AND ST_DWithin(
      ST_SetSRID(ST_MakePoint(fd.base_longitude, fd.base_latitude), 4326)::geography,
      ST_SetSRID(ST_MakePoint(p_user_lng, p_user_lat), 4326)::geography,
      p_radius_km * 1000
    )
    AND (p_freelancer_types IS NULL OR fd.freelancer_type = ANY(p_freelancer_types))
    AND (p_min_rating IS NULL OR COALESCE(fd.rating, 0) >= p_min_rating)
    AND (p_tags IS NULL OR array_length(p_tags, 1) IS NULL
         OR w.specialties && p_tags)
  ORDER BY
    CASE WHEN p_sort_by = 'rating'  THEN fd.rating        END DESC NULLS LAST,
    CASE WHEN p_sort_by = 'revenue' THEN fd.total_revenue END DESC NULLS LAST,
    CASE WHEN p_sort_by NOT IN ('rating', 'revenue') THEN floor(
      ROUND(
        (ST_Distance(
          ST_SetSRID(ST_MakePoint(p_user_lng, p_user_lat), 4326)::geography,
          ST_SetSRID(ST_MakePoint(fd.base_longitude, fd.base_latitude), 4326)::geography
        ) / 1000)::NUMERIC, 2
      ) / 2.0
    ) END ASC NULLS LAST,
    CASE WHEN p_sort_by NOT IN ('rating', 'revenue') THEN md5(w.id::text || p_seed::text) END ASC NULLS LAST
  LIMIT p_page_limit OFFSET p_page_offset;
END;
$function$;
```

> **Verification before finalizing:** open `20260620150000_nearby_rpcs_add_seed.sql`
> overload B and diff its SELECT list, JOINs, WHERE (minus the new `p_tags`
> predicate), and ORDER BY against the body above. They must match exactly. If
> the live ORDER BY differs from what is shown here, use the live version — the
> only intended change is the added `p_tags` param + predicate.

- [ ] **Step 2: Validate SQL syntax locally (no apply)**

Run: `ls supabase/migrations/20260621030000_freelancer_tags.sql`
Expected: file exists. (DB apply is a deferred ops step — `supabase db push` — recorded in the ops checklist; do not apply here.)

- [ ] **Step 3: Commit**

```bash
git add supabase/migrations/20260621030000_freelancer_tags.sql
git commit -m "feat(db): freelancer_tags_with_counts + p_tags filter on get_nearby_freelancers"
```

---

### Task A5: Repository — tags param + getFreelancerTags

**Files:**
- Modify: `lib/presentation/features/freelancer/data/repositories/supabase_freelancer_repository.dart`

**Interfaces:**
- Consumes: RPCs from Task A4.
- Produces:
  - `getNearbyFreelancers(... , List<String>? tags)` — sends `p_tags`.
  - `getFreelancerTags({double? latitude, double? longitude, double? radiusKm}) → Future<List<TagCount>>` where `TagCount` is `({String tag, int count})`.

> The repo interface (if `FreelancerRepository` is abstract) must gain the
> matching members. Check for an abstract base; if present, update it too.

- [ ] **Step 1: Add the `tags` param to `getNearbyFreelancers`**

In `getNearbyFreelancers` (signature at line ~925), add `List<String>? tags,` to the named params, and add `'p_tags': tags,` to the `params:` map of the `get_nearby_freelancers` rpc call.

- [ ] **Step 2: Add `TagCount` typedef + `getFreelancerTags`**

Add near the top of the file (after imports):

```dart
/// A freelancer tag and how many discoverable freelancers carry it.
typedef TagCount = ({String tag, int count});
```

Add this method to the repository class:

```dart
  /// Distinct freelancer tags (from the `specialties` column) with counts,
  /// scoped to discoverable freelancers within radius. Empty if no location.
  Future<List<TagCount>> getFreelancerTags({
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) {
    return runRepoQuery(
      opName: 'getFreelancerTags',
      userMessage: "Couldn't load tags. Please try again.",
      () async {
        final response = await _client.rpc(
          'freelancer_tags_with_counts',
          params: {
            'p_user_lat': latitude,
            'p_user_lng': longitude,
            'p_radius_km': radiusKm,
            'p_limit': 40,
          },
        );
        final List<dynamic> data = response as List<dynamic>;
        return data
            .map<TagCount>((row) => (
                  tag: (row as Map<String, dynamic>)['tag'] as String,
                  count: (row['count'] as num).toInt(),
                ))
            .toList();
      },
    );
  }
```

- [ ] **Step 3: Update the abstract interface if present**

If `freelancer_repository.dart` (or similar abstract) declares `getNearbyFreelancers`, add the `List<String>? tags` param and declare `getFreelancerTags`. Run:

Run: `grep -rn "getNearbyFreelancers\|abstract class.*Freelancer" lib/presentation/features/freelancer/data/repositories/`
Expected: locate any abstract declaration; mirror the new signature there.

- [ ] **Step 4: Verify it compiles**

Run: `flutter analyze lib/presentation/features/freelancer/data/repositories/`
Expected: No errors.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/features/freelancer/data/repositories/
git commit -m "feat(freelancer): repo tags param + getFreelancerTags"
```

---

### Task A6: Discover providers — selected tags + available tags + wiring

**Files:**
- Create: `lib/presentation/features/freelancer/creation/presentation/providers/selected_freelancer_tags_provider.dart`
- Modify: `lib/presentation/features/freelancer/creation/presentation/providers/freelancer_discovery_provider.dart`

**Interfaces:**
- Consumes: `getNearbyFreelancers(... tags:)`, `getFreelancerTags(...)`, `TagCount` (Task A5); existing `userLocationNotifierProvider`, `searchRadiusKmProvider`, `freelancerRepositoryProvider`.
- Produces:
  - `selectedFreelancerTagsProvider` → `StateProvider<Set<String>>`.
  - `freelancerTagsProvider` → `FutureProvider<List<TagCount>>`.

- [ ] **Step 1: Create the selected-tags provider**

```dart
// lib/presentation/features/freelancer/creation/presentation/providers/selected_freelancer_tags_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tags selected on the discover screen to filter freelancers. Empty = All.
/// Multi-select: a freelancer matches if ANY selected tag overlaps theirs
/// (w.specialties && p_tags in the RPC).
final selectedFreelancerTagsProvider =
    StateProvider<Set<String>>((ref) => <String>{});
```

- [ ] **Step 2: Add the available-tags provider to freelancer_discovery_provider.dart**

Append:

```dart
/// Available freelancer tags (with counts) within the current radius, for the
/// discover chip row. Empty when no location.
final freelancerTagsProvider = FutureProvider<List<TagCount>>((ref) async {
  final userLocation = ref.watch(userLocationNotifierProvider);
  final radiusKm = ref.watch(searchRadiusKmProvider);
  final repository = ref.watch(freelancerRepositoryProvider);
  if (userLocation == null) return const [];
  return repository.getFreelancerTags(
    latitude: userLocation.latitude,
    longitude: userLocation.longitude,
    radiusKm: radiusKm,
  );
});
```

Add the import at the top of the file:

```dart
import 'package:nano_embryo/presentation/features/freelancer/data/repositories/supabase_freelancer_repository.dart' show TagCount;
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/selected_freelancer_tags_provider.dart';
```

(If `TagCount` is exported from the repo file already imported, drop the duplicate import.)

- [ ] **Step 3: Wire tags into the 3 discovery providers**

In `freelancerDiscoveryProvider`, `topRatedFreelancersProvider`, and
`nearYouFreelancersProvider`, add at the top of each body:

```dart
  final selectedTags = ref.watch(selectedFreelancerTagsProvider);
```

and pass to each `repository.getNearbyFreelancers(...)` call:

```dart
    tags: selectedTags.isEmpty ? null : selectedTags.toList(),
```

(Do NOT touch the `getAllFreelancers` no-location branch — those providers all
use `getNearbyFreelancers` directly and require location, so this is complete.)

- [ ] **Step 4: Verify it compiles**

Run: `flutter analyze lib/presentation/features/freelancer/creation/presentation/providers/`
Expected: No errors.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/features/freelancer/creation/presentation/providers/
git commit -m "feat(freelancer): selected + available tag providers, wire into discovery"
```

---

### Task A7: FreelancerTagChips widget + discover wiring

**Files:**
- Create: `lib/presentation/features/freelancer/creation/presentation/widgets/freelancer_tag_chips.dart`
- Modify: `lib/presentation/features/discover/screens/discover_screen.dart`

**Interfaces:**
- Consumes: `freelancerTagsProvider`, `selectedFreelancerTagsProvider` (Task A6); `TagCount` (Task A5); `AppFilterChip`.

- [ ] **Step 1: Create the multi-select chip row**

```dart
// lib/presentation/features/freelancer/creation/presentation/widgets/freelancer_tag_chips.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/app_filer_chip.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_discovery_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/selected_freelancer_tags_provider.dart';

/// Multi-select tag filter row for freelancer discovery. "All" clears the
/// selection; each tag toggles membership. Hidden when no tags / on error.
class FreelancerTagChips extends ConsumerWidget {
  const FreelancerTagChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(freelancerTagsProvider);
    final selected = ref.watch(selectedFreelancerTagsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return tagsAsync.when(
      data: (tags) {
        if (tags.isEmpty) return const SizedBox.shrink();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: Spacing.sm.w),
                child: AppFilterChip(
                  label: 'All',
                  selected: selected.isEmpty,
                  backgroundColor: colorScheme.background,
                  labelColor: colorScheme.onBackground,
                  borderWidth: 0.3,
                  onSelected: (_) =>
                      ref.read(selectedFreelancerTagsProvider.notifier).state = {},
                ),
              ),
              ...tags.map((tc) {
                final isSel = selected.contains(tc.tag);
                return Padding(
                  padding: EdgeInsets.only(right: Spacing.sm.w),
                  child: AppFilterChip(
                    label: tc.tag,
                    selected: isSel,
                    selectedColor: colorScheme.primary,
                    backgroundColor: colorScheme.background,
                    labelColor: colorScheme.onBackground,
                    borderWidth: 0.3,
                    onSelected: (_) {
                      final next = Set<String>.from(selected);
                      if (isSel) {
                        next.remove(tc.tag);
                      } else {
                        next.add(tc.tag);
                      }
                      ref.read(selectedFreelancerTagsProvider.notifier).state = next;
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
```

- [ ] **Step 2: Wire into discover_screen.dart**

Add the import:

```dart
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/widgets/freelancer_tag_chips.dart';
```

In the `selectedType == ProviderType.freelancers` branch (currently lines ~177-181), insert the chip row above the rails:

```dart
          ] else if (selectedType == ProviderType.freelancers) ...[
            const SliverToBoxAdapter(child: FreelancerTagChips()),
            SliverGap(Spacing.sm.h),
            const SliverToBoxAdapter(child: TopRatedFreelancersHorizontal()),
            const SliverToBoxAdapter(child: NearYouFreelancersHorizontal()),
            SliverGap(Spacing.md.h),
          ]
```

- [ ] **Step 3: Verify it compiles**

Run: `flutter analyze lib/presentation/features/freelancer/creation/presentation/widgets/freelancer_tag_chips.dart lib/presentation/features/discover/screens/discover_screen.dart`
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/features/freelancer/creation/presentation/widgets/freelancer_tag_chips.dart lib/presentation/features/discover/screens/discover_screen.dart
git commit -m "feat(discover): multi-select freelancer tag filter chips"
```

---

## FEATURE B: PRODUCT DISCOVERY RAILS

### Task B1: Top-Rated + Near-You product providers

**Files:**
- Modify: `lib/presentation/features/products/presentation/providers/marketplace_providers.dart`
- Test: `test/features/products/marketplace_rail_providers_test.dart`

**Interfaces:**
- Consumes: existing `productRepositoryProvider`, `discoverySeedProvider`, `userLocationNotifierProvider`, `searchRadiusKmProvider`, `selectedServiceCategoryProvider`, `_shopTypesFilter`, `SortOption`, `ProductModel`, `getMarketplaceProducts(...)`.
- Produces: `topRatedProductsProvider`, `nearYouProductsProvider` (both `FutureProvider<List<ProductModel>>`).

- [ ] **Step 1: Write the failing test**

```dart
// test/features/products/marketplace_rail_providers_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/data/repositories/product_repository.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/marketplace_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/product_providers.dart';

class _FakeProductRepo implements ProductRepository {
  SortOption? lastSortBy;
  int? lastLimit;
  double? lastRadiusKm;
  double? lastUserLat;

  @override
  Future<List<ProductModel>> getMarketplaceProducts({
    String? category,
    SortOption? sortBy,
    double? minPrice,
    double? maxPrice,
    bool showVerifiedOnly = false,
    required int limit,
    required int page,
    int seed = 0,
    double? userLat,
    double? userLng,
    double? radiusKm,
    List<String>? shopTypes,
  }) async {
    lastSortBy = sortBy;
    lastLimit = limit;
    lastRadiusKm = radiusKm;
    lastUserLat = userLat;
    return const [];
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('topRatedProductsProvider requests popular sort, limit 10', () async {
    final fake = _FakeProductRepo();
    final container = ProviderContainer(overrides: [
      productRepositoryProvider.overrideWithValue(fake),
    ]);
    addTearDown(container.dispose);

    await container.read(topRatedProductsProvider.future);

    expect(fake.lastSortBy, SortOption.popular);
    expect(fake.lastLimit, 10);
  });
}
```

> Note: if `noSuchMethod` on `_FakeProductRepo` triggers analyzer errors for an
> abstract class, instead implement every `ProductRepository` member as
> `throw UnimplementedError()` except `getMarketplaceProducts`. The test only
> exercises `getMarketplaceProducts`.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/products/marketplace_rail_providers_test.dart`
Expected: FAIL — `topRatedProductsProvider` undefined.

- [ ] **Step 3: Add the providers**

Append to `marketplace_providers.dart` (after `marketplaceProductsPagedProvider`):

```dart
// ============================================
// Discover Buy-tab rails (reuse discover_products via getMarketplaceProducts)
// ============================================

/// Top-rated = most-ordered products for the discover Buy-tab rail.
/// No location filter (top sellers everywhere), mirroring topRatedFreelancers.
final topRatedProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final seed = ref.watch(discoverySeedProvider);
  final selectedCategory = ref.watch(selectedServiceCategoryProvider);
  return repo.getMarketplaceProducts(
    sortBy: SortOption.popular,
    limit: 10,
    page: 0,
    seed: seed,
    shopTypes: _shopTypesFilter(selectedCategory),
  );
});

/// Near-you products for the discover Buy-tab rail. Watches the radius slider.
final nearYouProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final seed = ref.watch(discoverySeedProvider);
  final userLocation = ref.watch(userLocationNotifierProvider);
  final radiusKm = ref.watch(searchRadiusKmProvider);
  final selectedCategory = ref.watch(selectedServiceCategoryProvider);
  if (userLocation == null) return const [];
  return repo.getMarketplaceProducts(
    sortBy: SortOption.discover,
    limit: 10,
    page: 0,
    seed: seed,
    userLat: userLocation.latitude,
    userLng: userLocation.longitude,
    radiusKm: radiusKm,
    shopTypes: _shopTypesFilter(selectedCategory),
  );
});
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/products/marketplace_rail_providers_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/features/products/presentation/providers/marketplace_providers.dart test/features/products/marketplace_rail_providers_test.dart
git commit -m "feat(marketplace): top-rated + near-you product rail providers"
```

---

### Task B2: Product rail widgets

**Files:**
- Create: `lib/presentation/features/products/presentation/widgets/top_rated_products_horizontal.dart`
- Create: `lib/presentation/features/products/presentation/widgets/near_you_products_horizontal.dart`

**Interfaces:**
- Consumes: `topRatedProductsProvider`, `nearYouProductsProvider` (Task B1); `ProductGridItem` (`product`, `onTap`); `userLocationNotifierProvider`, `hasLocationProvider`.

- [ ] **Step 1: Create the Top-Rated rail**

```dart
// lib/presentation/features/products/presentation/widgets/top_rated_products_horizontal.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/marketplace_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/product_grid_item.dart';

/// Most-ordered products rail on the discover Buy tab. Hidden when empty/error.
class TopRatedProductsHorizontal extends ConsumerWidget {
  const TopRatedProductsHorizontal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(topRatedProductsProvider);
    final theme = Theme.of(context);

    return async.when(
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
              child: Row(
                children: [
                  Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 20.sp),
                  Gap(Spacing.xs.w),
                  Text(
                    'Top Sellers',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Gap(Spacing.sm.h),
            SizedBox(
              height: 230.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
                itemCount: products.length,
                separatorBuilder: (_, __) => Gap(Spacing.md.w),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return SizedBox(
                    width: 160.w,
                    child: ProductGridItem(
                      product: product,
                      onTap: () => context.pushNamed('productDetail', extra: product.id),
                    ),
                  );
                },
              ),
            ),
            Gap(Spacing.md.h),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
```

- [ ] **Step 2: Create the Near-You rail**

```dart
// lib/presentation/features/products/presentation/widgets/near_you_products_horizontal.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/marketplace_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/product_grid_item.dart';

/// Products near the user on the discover Buy tab. Hidden without location or
/// when empty/error.
class NearYouProductsHorizontal extends ConsumerWidget {
  const NearYouProductsHorizontal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasLocation = ref.watch(hasLocationProvider);
    if (!hasLocation) return const SizedBox.shrink();

    final async = ref.watch(nearYouProductsProvider);
    final theme = Theme.of(context);

    return async.when(
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
              child: Row(
                children: [
                  Icon(Icons.near_me, color: Colors.purple, size: 20.sp),
                  Gap(Spacing.xs.w),
                  Text(
                    'Products Near You',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Gap(Spacing.sm.h),
            SizedBox(
              height: 230.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
                itemCount: products.length,
                separatorBuilder: (_, __) => Gap(Spacing.md.w),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return SizedBox(
                    width: 160.w,
                    child: ProductGridItem(
                      product: product,
                      onTap: () => context.pushNamed('productDetail', extra: product.id),
                    ),
                  );
                },
              ),
            ),
            Gap(Spacing.md.h),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
```

- [ ] **Step 3: Verify they compile**

Run: `flutter analyze lib/presentation/features/products/presentation/widgets/top_rated_products_horizontal.dart lib/presentation/features/products/presentation/widgets/near_you_products_horizontal.dart`
Expected: No errors. (If `hasLocationProvider` is not exported via `export_screens.dart`, add its explicit import — find it with `grep -rn "hasLocationProvider" lib/core lib/presentation | grep -i provider`.)

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/features/products/presentation/widgets/top_rated_products_horizontal.dart lib/presentation/features/products/presentation/widgets/near_you_products_horizontal.dart
git commit -m "feat(marketplace): top-rated + near-you product rail widgets"
```

---

### Task B3: Wire product rails into discover Buy branch

**Files:**
- Modify: `lib/presentation/features/discover/screens/discover_screen.dart`

**Interfaces:**
- Consumes: `TopRatedProductsHorizontal`, `NearYouProductsHorizontal` (Task B2); existing `ProviderType.buy`.

- [ ] **Step 1: Add imports**

```dart
import 'package:nano_embryo/presentation/features/products/presentation/widgets/top_rated_products_horizontal.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/near_you_products_horizontal.dart';
```

- [ ] **Step 2: Add the Buy-tab rails branch**

Extend the rails `if/else if` chain (currently shops + freelancers, lines ~172-181) with a Buy branch:

```dart
          ] else if (selectedType == ProviderType.buy) ...[
            const SliverToBoxAdapter(child: TopRatedProductsHorizontal()),
            const SliverToBoxAdapter(child: NearYouProductsHorizontal()),
            SliverGap(Spacing.md.h),
          ],
```

Leave the existing "All Products" title + `SliverFillRemaining(child: MarketplaceScreen())` block below unchanged.

- [ ] **Step 3: Verify it compiles**

Run: `flutter analyze lib/presentation/features/discover/screens/discover_screen.dart`
Expected: No errors.

- [ ] **Step 4: Run the rail provider test (regression)**

Run: `flutter test test/features/products/marketplace_rail_providers_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/features/discover/screens/discover_screen.dart
git commit -m "feat(discover): top-rated + near-you product rails on Buy tab"
```

---

## Final verification (whole-branch)

- [ ] **Full analyze**

Run: `flutter analyze`
Expected: No new errors in touched files.

- [ ] **Full test suite (touched areas)**

Run: `flutter test test/core/constants/freelancer_tags_test.dart test/features/products/marketplace_rail_providers_test.dart`
Expected: All PASS.

## Deferred ops (run after merge — not code tasks)

- [ ] `supabase db push` to apply `20260621030000_freelancer_tags.sql` (and any earlier pending migrations: `20260620170000_product_shop_types.sql`, `20260621000000_orders_currency.sql`, `20260621010000_drop_old_nearby_shops_overload.sql`, `20260621020000_discover_products_no_approval_gate.sql`).
- [ ] Device smoke test: freelancer onboarding tag selection persists; discover freelancer tag chips filter (multi-select); Buy tab shows Top Sellers + Products Near You rails above the grid.
```
