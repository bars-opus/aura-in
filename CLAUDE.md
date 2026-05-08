# CLAUDE.md - NanoEmbryo

## Project Overview
NanoEmbryo is a production-ready Flutter marketplace for service-based businesses (salons, barbershops, spas).

## Tech Stack
- **State Management**: Riverpod
- **Backend**: Supabase (PostgreSQL + PostGIS + RLS)
- **Navigation**: GoRouter
- **Payments**: Paystack (Africa) + Stripe Connect (Global)
- **Chat**: Sendbird SDK
- **Maps**: Mapbox + PostGIS

## Architecture Documentation
All detailed phase documentation is in `/architecture/`:

| Phase | File | When to Load |
|-------|------|--------------|
| Phase 0 | `/architecture/FOUNDATION.md` | Setup, theming, responsive |
| Phase 1 | `/architecture/SHOPMANAGEMENT.md` | Shop CRUD, workers, services |
| Phase 2 | `/architecture/DISCOVERY_SEARCH.md` | Maps, search, location |
| Phase 3 | `/architecture/BOOKING_SYSTEM.md` | Booking, time slots, groups |
| Phase 4 | `/architecture/PAYMENR_WALLET.md` | Payments, wallets, withdrawals |
| Phase 5 | `/architecture/CALENDAR&SCHEDULE.md` | Calendar, daily schedule |
| Phase 6 | `/architecture/SHOP_OWNER_DASHBOARD.md` | Analytics, heatmap, exports |
| Phase 7 | `/architecture/REVIEW&RATING_SYSTEM.md` | Ratings, responses |
| Phase 8 | `/architecture/CHAT.md` | Sendbird integration |
| Reference | `/architecture/FOLDER_STRUCTURE.md` | Complete file tree |

## GSTACK Integration
I have GSTACK skills installed in `.claude/skills/gstack/`

### Available Commands
- `/gstack:office-hours` - 6 forcing questions before coding
- `/gstack:plan-ceo-review` - Reframe from first principles
- `/gstack:plan-eng-review` - Lock architecture, data flow
- `/gstack:plan-design-review` - Rate UI 0-10 across dimensions
- `/gstack:engineering` - Write production code
- `/gstack:review` - Find bugs that pass CI
- `/gstack:qa` - Open browser, find visual bugs
- `/gstack:ship` - Sync, test, open PR
- `/gstack:retro` - Weekly retrospective

### Task Routing Guide
| Task | Command | Then Read |
|------|---------|-----------|
| Plan new feature | `/gstack:office-hours` | Relevant phase doc |
| Design complex UI | `/gstack:plan-design-review` | Phase 6 doc for dashboard |
| Implement feature | `/gstack:engineering` | Phase doc for patterns |
| Before commit | `/gstack:review` + `/gstack:qa` | Phase doc for validation |
| Create PR | `/gstack:ship` | None - automated |

## Skill routing

When the user's request matches an available skill, invoke it via the Skill tool. The
skill has multi-step workflows, checklists, and quality gates that produce better
results than an ad-hoc answer. When in doubt, invoke the skill. A false positive is
cheaper than a false negative.

Key routing rules:
- Product ideas, "is this worth building", brainstorming → invoke /office-hours
- Strategy, scope, "think bigger", "what should we build" → invoke /plan-ceo-review
- Architecture, "does this design make sense" → invoke /plan-eng-review
- Design system, brand, "how should this look" → invoke /design-consultation
- Design review of a plan → invoke /plan-design-review
- Developer experience of a plan → invoke /plan-devex-review
- "Review everything", full review pipeline → invoke /autoplan
- Bugs, errors, "why is this broken", "wtf", "this doesn't work" → invoke /investigate
- Test the site, find bugs, "does this work" → invoke /qa (or /qa-only for report only)
- Code review, check the diff, "look at my changes" → invoke /review
- Visual polish, design audit, "this looks off" → invoke /design-review
- Developer experience audit, try onboarding → invoke /devex-review
- Ship, deploy, create a PR, "send it" → invoke /ship
- Merge + deploy + verify → invoke /land-and-deploy
- Configure deployment → invoke /setup-deploy
- Post-deploy monitoring → invoke /canary
- Update docs after shipping → invoke /document-release
- Weekly retro, "how'd we do" → invoke /retro
- Second opinion, codex review → invoke /codex
- Safety mode, careful mode, lock it down → invoke /careful or /guard
- Restrict edits to a directory → invoke /freeze or /unfreeze
- Upgrade gstack → invoke /gstack-upgrade
- Save progress, "save my work" → invoke /context-save
- Resume, restore, "where was I" → invoke /context-restore
- Security audit, OWASP, "is this secure" → invoke /cso
- Make a PDF, document, publication → invoke /make-pdf
- Launch real browser for QA → invoke /open-gstack-browser
- Import cookies for authenticated testing → invoke /setup-browser-cookies
- Performance regression, page speed, benchmarks → invoke /benchmark
- Review what gstack has learned → invoke /learn
- Tune question sensitivity → invoke /plan-tune
- Code quality dashboard → invoke /health

## Coding Standards
- Use Riverpod providers for all state
- Repository pattern for data layer
- DTOs for API responses, Models for domain
- Feature-first folder structure (not layer-first)
- Follow Material Design 3 with design tokens

## Build Commands
```bash
flutter pub get
flutter run --flavor development
flutter test