# Phase 16 PLAN-CHECK — Daily Close-Out Report

**Checked:** 2026-06-11
**PLAN reviewed:** 19 tasks across 7 waves (16-PLAN.md:1744)
**Verdict:** REVISIONS REQUIRED

## Dimension 1 — Goal achievement (SC-1..SC-18)

| SC | Covered? | Task | Test command / evidence | Note |
|----|----------|------|-------------------------|------|
| SC-1 | PASS | 1.6 + 2.2 + Wave 7 | Smoke §I + §L + UAT step 2 (16-PLAN.md:1605) | Concrete |
| SC-2 | PASS | 4.4 + 6.3(c,k) | Smoke §B + widget test cases (c,k) | Concrete |
| SC-3 | PASS | 2.1 + 6.4 §G | Smoke §G asserts `revenue_minor=15000` | Concrete |
| SC-4 | PASS | 2.1 + 6.4 §N + 6.3(e) | Smoke §N, widget (e) | Concrete |
| SC-5 | PASS | 6.4 §N (variant) | Mapped in matrix line 1609 | Variant explicit |
| SC-6 | PASS | 2.1 + 6.4 §G | Per-worker sum-equals-total assertion | Concrete |
| SC-7 | PASS | 2.1 + 6.4 §G | Per-service sum-equals-total assertion | Concrete |
| SC-8 | PASS | 2.1 + 6.4 §O + 6.3(c) | Smoke §O + widget | Concrete |
| SC-9 | PASS | 2.1 + 6.4 §F | Smoke §F (confirmed-past-end) | Concrete |
| SC-10 | PASS | 1.4 + 2.1 + 6.4 §F | AMEND-2 round-trip in §F | Concrete |
| SC-11 | PASS | 2.1 + 6.4 §B+§C + 6.3(g) | Smoke §C asserts `outcome='updated'` row | Concrete |
| SC-12 | PASS | 2.2 + 6.4 §K | Duplicate-tick test in §K | Concrete |
| SC-13 | PASS | 2.2 + 6.4 §J | Heartbeat row assertion in §J | Concrete |
| SC-14 | **BLOCK** | 2.1 + 6.4 §A+§D | Smoke §D expects HINT `OWNER_NOT_FOUND` | **See Blocker #1: Task 2.1 outer `WHEN OTHERS` catches `OWNER_NOT_FOUND` and re-raises as `REPORT_RPC_FAILED`. SC-14 will fail as written.** |
| SC-15 | **BLOCK** | 2.1 + 6.4 §E | Smoke §E expects HINT `REPORT_DATE_INVALID` | **Same root cause as SC-14: outer `WHEN OTHERS` swallows the specific HINT.** |
| SC-16 | **BLOCK** | 2.1 + 6.4 §E | Same | **Same root cause as SC-14/15.** |
| SC-17 | PASS | 2.3 + 6.2 + 6.4 §M | Clamp assertions in §M | Concrete |
| SC-18 | PASS | 2.2 + 6.4 §L + Wave 7 | IST 17:00 UTC selector test in §L | Concrete |

**Coverage finding:** all 18 SCs have a mapped task and concrete test path. **However SC-14, SC-15, SC-16 will not pass with the current Task 2.1 EXCEPTION block** — see Blocker #1.

## Dimension 2 — Locked-decision coverage (LD-1..LD-15 + AMEND-1..AMEND-7)

| Item | Covered? | Task | Note |
|------|----------|------|------|
| LD-1 timezone column | PASS | 1.1 | `NOT NULL DEFAULT 'Africa/Accra'` + CHECK + COMMENT verbatim (16-PLAN.md:213) |
| LD-2 cron + idempotency | PASS | 1.6, 2.2 | `*/15 * * * *`, unschedule-first, ON CONFLICT |
| LD-3 minor units | PASS | 2.1 | `(bs.price_at_booking * 100)::bigint` used in all 4 revenue aggregations (16-PLAN.md:580, 593, 601, 640, 655) |
| LD-4 snapshot persistence | PASS | 1.2, 2.1 | `payload` JSONB, `schema_version=1`, ON CONFLICT DO UPDATE |
| LD-5 audit + REVOKE | PASS | 1.3 | REVOKE UPDATE,DELETE explicit on PUBLIC, authenticated, service_role, anon (16-PLAN.md:340-343) |
| LD-5 audit `error_code` discipline | **BLOCK** | 2.1 | **Task 2.1 EXCEPTION block writes `error_code = COALESCE(NULLIF(SQLERRM, ''), 'REPORT_RPC_FAILED')` (16-PLAN.md:835). SPEC LD-5 line 200 + Task 1.3 COMMENT line 346: "error_code is a stable HINT code — never free-text." This stuffs `SQLERRM` (e.g. "not_found", "invalid_input", any error text) into `error_code`. See Blocker #2.** |
| LD-6 notification routing | PASS | 2.1, 4.4, 5.1 | `notification_type='daily_report'`, deep-link `/dashboard/:shopId/daily-report/:reportDate`, push channel, EN copy keys present |
| LD-7 zero-booking skip | PASS | 2.1, 2.2 | Selector `EXISTS` + manual-call skip + heartbeat row |
| LD-8 manual re-generation | PASS | 2.1, 3.2, 4.1 | RPC + repo method + FAB |
| LD-9 pagination | PASS | 2.3 | `GREATEST(10, LEAST(50, COALESCE(p_page_size, 30)))` |
| LD-10 authz FIRST | PASS | 2.1, 2.3 | Shop lookup + `user_id = auth.uid()` check at start of every RPC body (lines 551, 988) |
| LD-11 HINT vocabulary | PASS | 2.1, 2.3, 3.2 | All 4 HINTs declared + classifier maps each |
| LD-12 tomorrow peek | PASS | 2.1, 4.1 | `MIN(start_time)`, `COUNT(*)`, `BOOL_OR(is_group_booking)` only |
| LD-13 follow-up rules | PASS | 2.1 | 3 reasons, UNION ALL, redaction `LEFT(name,1)||'***'` |
| LD-14 comparison NULL | PASS | 2.1 | `CASE WHEN v_yesterday_rev = 0 THEN NULL ...` |
| LD-15 documented skips | PASS | "Out-of-band" section + PR checklist | Verbatim SPEC quote at 16-PLAN.md:1679 + re-eval reminder at line 1719 |
| AMEND-1 unpaid_balance enum | PASS | 2.1 | `payment_status IN ('unpaid', 'failed')` (16-PLAN.md:711) |
| AMEND-2 client_notes.booking_id | PASS | 1.4, 2.1 | ALTER + partial index in 1.4; join `cn.booking_id = b.id` in 2.1 (line 730) |
| AMEND-3 shops.user_id | PASS | 2.1, 2.3 | `shops.user_id`, not `owner_id`, used throughout |
| AMEND-4 cron direct SQL | PASS | 1.6 | `$cron$ SELECT public.dispatch_daily_reports(); $cron$` (line 465) |
| AMEND-5 PK shape | PASS | 1.2 | `id UUID PK DEFAULT gen_random_uuid()` + UNIQUE (shop_id, report_date) |
| AMEND-6 half-open range | PASS | 2.1, 2.2 | Every `booking_date` query uses `>= ((d::timestamp) AT TIME ZONE tz) AND < (((d+1)::timestamp) AT TIME ZONE tz)`. Verified at lines 589, 598, 606, 645, 662, 674, 692, 709, 725, 906 |
| AMEND-7 Wave 1 pre-flight | PASS | 1.0 | DO block reports pg_cron, pg_net, archived_at via RAISE NOTICE; non-blocking |

## Dimension 3 — Algorithm Quality Checklist

All P0-U items have concrete task hooks; all P1 items either a task or in documented skip section; LD-15 skips surfaced with PR re-eval reminder.

| Checklist | Priority | Covered? | Task | Note |
|-----------|----------|----------|------|------|
| 1.1 idempotency | P1 | PASS | 1.2 + 2.1 + 6.4 §C | UNIQUE + ON CONFLICT |
| 1.4 authz at every access | P0-U | PASS | 2.1, 2.2, 2.3 | Authz FIRST |
| 1.5 auth verified | P0-U | PASS | 2.1, 2.3 | `user_id = auth.uid()` |
| 1.7 stateless RPCs | P2 | PASS | 2.1–2.3 | No shared state |
| 1.8 Big-O documented | P2 | PASS | 2.1, 2.3 COMMENT | Comments include Big-O |
| 1.9 consistency model | P1 | PASS | 1.2 COMMENT | Snapshot semantics documented |
| 1.10 compensating cleanup | P1 | PASS | 2.1 EXCEPTION block | Writes 'failed' row |
| 1.11 PII assessment | P1 | PASS | 1.1 | Timezone = config metadata |
| 2.1 input sanitization | P0-U | PASS | 2.1, 2.3 | Date + clamp |
| 2.2 no string-concat SQL | P0-U | PASS | All RPCs | Parameterized |
| 2.4 sanitized errors | P0-U | PARTIAL | 2.1, 2.3, 3.2 | **Compromised by Blocker #2 — SQLERRM leak into audit table** |
| 2.5 page_size + range limits | P0-U | PASS | 2.1, 2.3 | Clamp + 365-day |
| 2.10 transactional cleanup | P0-U | PASS | 2.1 EXCEPTION | Audit row on failure |
| 2.13 cron timeout | P1 | PASS | 2.1 (10s), 2.2 (30s) | SET LOCAL statement_timeout |
| 2.16 concurrent re-gen | P1 | PASS | 2.1 ON CONFLICT | Idempotent |
| 2.18 idempotent RPCs | P1 | PASS | 2.1 + §C | Smoke §C asserts |
| 2.19 minor units | P0-U | PASS | 2.1 | bigint throughout, no float |
| 2.22 audit append-only | P1 | PASS | 1.3 + §H | REVOKE UPDATE/DELETE + smoke test |
| 3.1 pagination | P2 | PASS | 2.3, 4.2 | Keyset |
| 3.3 indexes (EXPLAIN) | P2 | PASS | §I EXPLAIN ANALYZE | In smoke §I |
| 3.10 don't retry auth fail | P1 | PASS | 3.2 classifier | Non-retryable subtype |
| 3.12 graceful shutdown | P1 | WARNING | 2.2 per-shop catch + §K | RESEARCH §8.2 asked for explicit chaos test simulating mid-fan-out kill; §K is duplicate-tick, not mid-fan-out kill. See Non-blocking #1. |
| 4.1 structured logs | P2 | PASS | 2.2 RAISE NOTICE | RED metrics |
| 4.4 PII redaction | P0-U | PASS | 2.1 + §F + 6.3(f) | "A***" regex assertion |
| 4.6 RED metrics | P2 | PASS | 2.2 NOTICE line | shop_count, error_count, duration_ms |
| 4.9 alerts → runbook | P2 | WARNING | (not mapped) | RESEARCH §8.2 flagged this gap; PLAN does not add an alert hook task or runbook entry. See Non-blocking #2. |
| 4.11 configurable thresholds | P2 | PASS | 1.1 timezone + LD scope note | |
| 5.1 actionable errors | P2 | PASS | 3.1 userMessage + 5.1 i18n | |
| 5.2 ≤200ms first paint | P2 | PASS | 4.1 (single DTO) + UAT | |
| 5.5 no internal IDs in UI | P0-U | PASS | 3.2 classifier | Typed exceptions only |
| 6.1 edge cases | P1 | PASS | §J, §K, §L | |
| 6.2 failure scenarios | P2 | PASS | 2.1 commit order | daily_reports committed before notification INSERT |
| 6.3 race tests | P1 | PASS | §K | |
| 6.7 ≥90% branch coverage | P2 | PASS | §B/§F/§G/§N/§O | Branches enumerated |
| 6.10 24h soak | skip | PASS | LD-15 + PR checklist | Re-eval at >1000 shops reminded |
| 6.11 2x load | skip | PASS | LD-15 + PR checklist | Same |
| 6.13 documentation | P2 | PASS | All COMMENTs + PR | |

LD-15 skips (6.10, 6.11) surfaced at 16-PLAN.md:1681-1682 with verbatim SPEC justification at 1679; PR rollout checklist line 1719 carries the >1000-shops re-eval reminder.

## Dimension 4 — Task quality

All 19 tasks pass the deep-work rules: every task has `Read first` (read_first), `File(s)` with NEW/EDIT classification, concrete description (concrete SQL bodies, concrete dart skeletons, no "align X with Y" placeholders), grep/test-verifiable acceptance with named `Smoke §X` / `flutter test test/.../...` / explicit assertions, `Rollback`, and `Estimate`.

Specific spot-checks:
- Task 1.0 (16-PLAN.md:194-204): read_first names SPEC AMEND-7 + RESEARCH §2.1; acceptance lists the exact RAISE NOTICE substring; rollback `discard file`; 15 min.
- Task 2.1 (16-PLAN.md:486-860): 9 acceptance lines naming Smoke §A–§G + regex; rollback `DROP FUNCTION`; 90 min.
- Task 4.4 (16-PLAN.md:1421-1444): names exact lines `main.dart:266-298` to edit; acceptance is a unit test with synthesized payload.
- Task 6.4 (16-PLAN.md:1550-1575): 15 §A–§O sections each map to specific SCs; acceptance is "exactly 15 `OK:` lines, zero `FAIL:`."

No subjective language ("looks correct", "properly configured") found in any task description.

## Dimension 5 — Wave structure + parallelism

- Wave boundaries are clean: Wave 1 (DDL) → Wave 2 (RPCs depend on Wave 1 tables) → Wave 3 (Dart depends on Wave 2 RPCs) → Wave 4 (UI depends on Wave 3) → Wave 5 (i18n disjoint, parallel with 3) → Wave 6 (tests, parallel within) → Wave 7 (UAT).
- Wave 3 ∥ Wave 5 parallelism call-out present at 16-PLAN.md:181 and again at 185-188. Correct (touches `lib/presentation/features/shops/dashboard/` vs `lib/i10n/app_en.arb`).
- Wave 2(c) `list_daily_reports` independence from 2(a)/2(b) noted at 16-PLAN.md:178 and 187. Correct (no shared SQL objects).
- Wave 6 test file independence noted at 16-PLAN.md:182, 188.
- Dependencies explicit in the wave table at 16-PLAN.md:175-184.
- **Inconsistency (non-blocking):** Task 1.6 cron registration is labeled Wave 1 but its migration timestamp (`20260611100900`) is intentionally AFTER Wave 2's RPC timestamps (`100600`–`100800`) so the cron body references the existing RPC. PLAN acknowledges this explicitly at 16-PLAN.md:445 ("placed in Wave 1 by file naming but executed last among Wave 1 migrations conceptually"). Mechanically correct because all migrations apply in timestamp order during `supabase db push`; semantically the cron task depends on Wave 2 RPCs being created first. Recommend re-labeling as "Wave 2 Task 2.4" or "Wave 1 Task 1.6 (executes after Wave 2)" for execution clarity. See Non-blocking #3.

## Dimension 6 — Source audit

All 21 SPEC items (LD-1..LD-15 + AMEND-1..AMEND-7) accounted for in Dimension 2 table. All 14 RESEARCH §8.1 LD→checklist hooks accounted for in Dimension 3 table.

**RESEARCH §8.2 callouts:**
- 4.9 alerts → runbook: **NOT addressed** by a concrete task. RESEARCH §8.2 specifically recommended a Wave 6 task adding a structured log line `daily_report.dispatch_completed` + a "0 dispatches at 22:30 UTC for 48h" alert hook. The PLAN ships the structured log line (Task 2.2) but no alert hook task. See Non-blocking #2.
- 6.7 ≥90% branch coverage: PLAN maps §B/§F/§G/§N/§O — acceptable (5 branches: happy, follow-up, revenue, null-comparison, tomorrow-empty).
- 3.12 graceful shutdown: PLAN points to Task 2.2 per-shop catch + §K. §K is a "duplicate-tick test", not the "mid-fan-out kill" chaos test RESEARCH explicitly asked for. See Non-blocking #1.

**RESEARCH §9 open questions:**
- Q1 payment_status enum: resolved via AMEND-1, reflected in Task 2.1.
- Q2 client_notes.booking_id: resolved via AMEND-2 + Task 1.4.
- Q3 PK shape: resolved via AMEND-5, reflected in Task 1.2 (UUID PK + UNIQUE).
- Q4 archived_at: **DEFERRED to executor runtime**. PLAN uses `WHERE TRUE` placeholder at 16-PLAN.md:898 with executor-edits-the-migration instruction at 948. RESEARCH treated this as a "planner picks" decision; the planner instead made it a runtime branch. Acceptable per AMEND-7 but fragile. See Non-blocking #4.
- Q5 cron Option A vs B: resolved via AMEND-4 (Option B), reflected in Task 1.6.

## Blocking gaps

1. **Task 2.1 outer `WHEN OTHERS` swallows specific HINTs and breaks SC-14/15/16.** The outer EXCEPTION block at 16-PLAN.md:828-839 catches every exception — including the early `OWNER_NOT_FOUND` (line 556, 559), `REPORT_DATE_INVALID` (lines 544, 566, 570), and the input-validation raise (line 543) — and re-raises every one as HINT `REPORT_RPC_FAILED`. Result: smoke §D (SC-14) expecting HINT `OWNER_NOT_FOUND` will see `REPORT_RPC_FAILED`; smoke §E (SC-15, SC-16) expecting HINT `REPORT_DATE_INVALID` will see `REPORT_RPC_FAILED`. Three success criteria silently fail. **Fix:** in the EXCEPTION block, re-raise the original HINT when it is one of the known stable codes (`OWNER_NOT_FOUND`, `REPORT_DATE_INVALID`) and only emit `REPORT_RPC_FAILED` for truly unexpected errors. Pattern:
   ```sql
   EXCEPTION
     WHEN OTHERS THEN
       DECLARE v_hint TEXT := COALESCE(NULLIF(current_setting('exception.hint', true), ''), '');
       BEGIN
         INSERT INTO public.daily_report_runs (..., outcome, error_code)
         VALUES (..., 'failed', CASE WHEN v_hint IN ('OWNER_NOT_FOUND','REPORT_DATE_INVALID') THEN v_hint ELSE 'REPORT_RPC_FAILED' END);
         IF v_hint IN ('OWNER_NOT_FOUND','REPORT_DATE_INVALID') THEN RAISE; END IF;
         RAISE EXCEPTION 'report_failed' USING ERRCODE = '50000', HINT = 'REPORT_RPC_FAILED';
       END;
   END;
   ```
   Or wrap the validation phase in a sub-block with its own `RAISE` that bypasses the outer catch.

2. **Task 2.1 EXCEPTION block leaks `SQLERRM` into `daily_report_runs.error_code`, violating LD-5.** Line 835 writes `error_code = COALESCE(NULLIF(SQLERRM, ''), 'REPORT_RPC_FAILED')`. `SQLERRM` is free-text English (e.g. `'not_found'`, `'invalid_input'`, or any plpgsql error message). SPEC LD-5 line 200 and Task 1.3 COMMENT at 16-PLAN.md:346 explicitly require: *"error_code is a stable HINT code (REPORT_RPC_FAILED, etc.) — never free-text."* **Fix:** write only a stable HINT to `error_code`. Use the recovered HINT from blocker #1's fix, or unconditionally `'REPORT_RPC_FAILED'` if the outer catch is reached.

## Non-blocking suggestions

1. **Add an explicit mid-fan-out kill test to Wave 6.** RESEARCH §8.2 (3.12 graceful shutdown) recommended a chaos test simulating "DB restart mid-fan-out → next tick is a no-op for already-committed shops". §K covers duplicate-tick but not partial-progress recovery. Add a §P that calls `dispatch_daily_reports()`, kills the connection mid-loop (or simulates by interrupting after one inner call), then re-runs and asserts no duplicate `daily_reports` rows.

2. **Add an alert-hook documentation task.** RESEARCH §8.2 (4.9) recommended documenting a "0 dispatches at 22:30 UTC for 48h" alert. PLAN ships the structured log line but no alert-hook entry. Either add a one-paragraph entry to the PR description or a `docs/runbooks/` note linking the NOTICE format to the monitoring layer.

3. **Re-label Task 1.6 for execution clarity.** Either move to Wave 2 as Task 2.4 (its dependency target) or rename to "Wave 1 Task 1.6 (post-Wave-2)". Mechanically correct as-is, but the wave label invites confusion when an executor sequences work.

4. **Tighten the `WHERE TRUE` placeholder in Task 2.2.** The current pattern (16-PLAN.md:898 with executor-edits-migration instructions at 948) is a runtime branch on the AMEND-7 pre-flight finding. Lower-risk alternative: emit two migration files (one with `archived_at IS NULL`, one without) and the executor selects, OR detect at runtime via `to_regclass` / `information_schema` inside the DO block. Current shape works but invites executor mistakes.

5. **i18n key count overshoots the brief (35 vs ~30).** PLAN flags this at line 1494. Not a real issue; consistent with Phase 14/15 overshoot pattern.

6. **Notification body is hardcoded EN at SQL layer (Task 2.1 lines 800-804).** RESEARCH §4.5 recommended path (b) — store components only and let the Edge Function format. PLAN ships a hybrid: stores components AND emits a server-side EN string. Fine for v1 (EN-only is consistent with Phases 13/14/15) but document the path-(b) migration if a non-EN locale ships later.

## PLAN VERIFICATION COMPLETE — REVISIONS REQUIRED
