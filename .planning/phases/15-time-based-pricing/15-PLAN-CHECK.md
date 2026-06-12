# Phase 15 PLAN-CHECK

**Verdict: PASS-WITH-NOTES** — all 10 SPEC success criteria executable, all 20 hard constraints honored, smoke covers contract, dependency ordering correct. Three tightenings recommended below.

## Goal-backward — 10 SPEC criteria → tasks

| SC | SPEC | Plan coverage | OK |
|----|------|---------------|----|
| 1 | Owner → Pricing rules → empty state | Tasks 3.4, 3.2 (PLAN L1404–1407, 1390–1395) | yes |
| 2 | Create rule, row appears | Tasks 3.3, 1.1 (PLAN L1397–1402, 1330–1335) | yes |
| 3 | Live preview "$40 (saved $10 vs $50 base)" | Task 3.3 (PLAN L1037, 1399–1400) + Smoke §F | yes |
| 4 | Client sees $40 + chip in window | Tasks 1.4, 3.1, 4.1 + Smoke §F | yes |
| 5 | Pick 10am → $40 → SUMMER10 → $36 | Tasks 4.1, 4.2 + Smoke §F (PLAN L1413–1425) | yes |
| 6 | Edit value→30; historical bookings preserved at $36 | Task 1.2 + snapshot invariant (PLAN L39–40, 1339) | yes |
| 7 | Archive → $50 no chip | Task 1.3 + Smoke §D | yes |
| 8 | Two overlapping rules, Tue-only wins | Task 1.4 + Smoke §G | yes |
| 9 | `fixed_discount=100` clamps at $0 | Task 1.4 (GREATEST clamp PLAN L754) + Smoke §J | yes |
| 10 | promo applied against effective total | Tasks 4.1, 4.2 + PLAN L1239–1244 | yes |

## Hard constraints — 20-point lock check

| # | Constraint | Plan reference | OK |
|---|------------|----------------|----|
| 1 | day_of_week 1..7 CHECK | PLAN L233–234 | yes |
| 2 | EXTRACT(ISODOW) bug fix bundled | PLAN L678, 1351–1356 | yes |
| 3 | base_price NUMERIC RETURN column | PLAN L655 | yes |
| 4 | Client patch (booking_confirmation:302–359, controller:462,496) | Tasks 4.1, 4.2 | yes |
| 5 | 4 adjustment kinds + percent ≤100 CHECK | PLAN L237–239, 255–258 | yes |
| 6 | 3-tier ladder: specificity → window → created_at DESC | PLAN L758–759 | yes |
| 7 | 50-cap server-enforced, OVERRIDE_CAP_EXCEEDED HINT | PLAN L397–406 | yes |
| 8 | FK slot_id → appointment_slots ON DELETE CASCADE | PLAN L230–231 | yes |
| 9 | CHECK time_window_end > time_window_start | PLAN L250–251 | yes |
| 10 | Form soft warnings (>50% surcharge, >5× fixed) | PLAN L1038 | yes |
| 11 | Effective price clamped at 0 (GREATEST) | PLAN L752, 754 | yes |
| 12 | UI is AppBar IconButton in ServiceEditScreen (edit-only) | PLAN L1060, 1404–1407 | yes |
| 13 | Client chip = "Discount"/"Surcharge", name not exposed | PLAN L116, 1151, 1162 | yes |
| 14 | Phase 13 promo unchanged, runs against effective_total | PLAN L36–38, 1239–1244 | yes |
| 15 | REVOKE FROM authenticated + GRANT EXECUTE | PLAN L427–429, 541–543, 586–588 | yes |
| 16 | DashboardRepository extended (no separate repo file) | PLAN L78, 112–113 | yes |
| 17 | HINT-based typed exceptions | PLAN L888–897 (table) | yes |
| 18 | EN-only i18n | PLAN L119, 1262 | yes |
| 19 | price_at_booking snapshot invariant | PLAN L39–40 + Task 4.1 | yes |
| 20 | Override pre-materialization (jsonb_agg outside FOREACH) | PLAN L696–713 (before FOREACH at L716) | yes |

## Smoke coverage map

§A RLS · §B create + authz · §C update + authz · §D archive idempotency · §E base_price · §F percent_discount · §G single-day > all-week · §H narrower > wider · §I newest > older · §J fixed clamp · §K 50-cap · §L ISODOW Sunday — all sections present in `15_smoke_tests.sql` and each maps to a SPEC criterion or constraint.

## Dependency ordering

- Wave 0 (schema) → Wave 1 (RPCs) → Wave 2 (data layer) → Wave 3 (UI) → Wave 4 (booking patch) → Wave 5 (i18n) → Wave 6 (tests) → Wave 7 (UAT). Correct.
- **Wave 4 booking patch ordering**: lands AFTER Wave 1 RPC patch is deployed (PLAN L1411 "depends on Wave 3" which depends on Wave 2 which depends on Wave 1). The RPC adds `base_price` to RETURN TABLE; the client reads `json['base_price']` and falls back to null. `?? service.price` fallback on the effective-price read means the client tolerates the old RPC for the window before Wave 1 lands. **Order is safe.**

## Style + risk

- Matches Phase 14 voice (file-path-led, terse, RESEARCH cross-refs). Yes.
- Risk register populated (PLAN L1519–1529). Yes.
- Definition of done: per-task Acceptance lines + Verification matrix (L1496–1515) are grep-checkable. Yes.
- Plan-check criteria at end: phase boundary L1531–1552 lists ship/no-ship. Yes.

## Notes (tightenings — not blockers)

1. **PLAN L365 `IF char_length(p_name) NOT BETWEEN 1 AND 80 THEN`** — PostgreSQL does not parse `NOT BETWEEN x AND y` inside a scalar IF context this way. Should be `NOT (char_length(p_name) BETWEEN 1 AND 80)` or `char_length(p_name) NOT BETWEEN 1 AND 80` is actually accepted by Postgres, but the same expression appears in the schema CHECK at L232 (`CHECK (char_length(name) BETWEEN 1 AND 80)`) and at L492 in update. Executor: verify the negation parses; if not, wrap in parens. (Cosmetic but blocks migration if parser rejects.)

2. **Smoke §F expects `v_price <> v_expected` via NUMERIC equality** (line 355). NUMERIC math should be exact for `50 * 0.80 = 40.00`, but if `appointment_slots.price` carries trailing decimals, the equality may flake. Suggest changing to `abs(v_price - v_expected) > 0.01`. Same pattern in §G L405, §H L455, §I L506.

3. **PLAN L369 `IF p_day_of_week IS NOT NULL AND p_day_of_week NOT BETWEEN 1 AND 7`** — same parser concern as note 1; verify Postgres accepts `NOT BETWEEN` as a postfix in `IF`. Postgres grammar does allow it, but for clarity recommend `(p_day_of_week < 1 OR p_day_of_week > 7)`.

## Verdict

**PASS-WITH-NOTES** — execute Wave 0 after addressing notes 1 + 3 (5-minute parser sanity check) and note 2 (NUMERIC tolerance in smoke).
