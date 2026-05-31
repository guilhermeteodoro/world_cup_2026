# Rails App — Task Plan

> **Note to agents/bots:** Update this file as you complete tasks (check them off) or
> change the plan (add/remove/reorder tasks). This is the living source of truth for
> implementation progress.

## Phase 1: Project setup
- [x] Generate Rails 8 app (SQLite dev, PostgreSQL prod)
- [x] Install and configure Phlex
- [x] Install and configure RubyUI + Tailwind CSS
- [x] Set up base layout (Phlex composition-based)
- [ ] Configure Render deployment (render.yaml, Dockerfile or buildpack)

## Phase 2: Sticker catalog
- [x] Create `countries` migration (code, emoji)
- [x] Create `stickers` migration (country_id, number, category enum, position)
- [x] Create `Sticker` + `Country` models with validations
- [x] Write seed file with all 994 stickers
- [x] Verify seed: `Sticker.count == 994`, category counts match (68/14/912)

## Phase 3: Users + collections
- [x] Create `users` migration (slug, name, email)
- [x] Create `User` model with slug generation
- [x] Create `user_stickers` migration (user_id, sticker_id, copies, unique index)
- [x] Create `UserSticker` model
- [x] Implement session-based auth (cookie login on account creation)
- [x] Build registration + login flows with smart redirects

## Phase 4: Import parsers
- [x] Build dump parser service (`DumpParser`)
- [x] Build manual parser service (`ManualParser`)
- [x] Build import service (`CollectionImporter`)
- [x] Wire parsers to registration and collection edit forms

## Phase 5: Collection pages
- [x] Build public collection page `/u/:slug` (stats + duplicates grouped by team)
- [x] Build logged-in view of own collection (stats + update/settings buttons)
- [x] Build update flow (re-import form, same parsers, wipe + replace)
- [x] Add copy-to-clipboard (server-built text with indentation)

## Phase 6: Trade comparison
- [x] Build `TradeComparer` service (a_gives_b, b_gives_a by category)
- [x] Build balanced trade suggestion + leftovers
- [x] Build trade comparison view (shown on `/u/:slug` when logged in as different user)
- [x] Group output by team with country emoji

## Phase 7: i18n + polish
- [x] Add i18n support (pt-BR default + English)
- [x] Browser-based locale detection + session override
- [x] Language switcher dropdown (RubyUI DropdownMenu)
- [x] Country names from i18n (remove name column from DB)
- [x] Refactor views to use RubyUI components (Button, Card, Badge, Alert, Input, Form)

## Phase 8: Tests
- [x] DumpParser unit tests
- [x] ManualParser unit tests
- [x] CollectionImporter unit tests
- [x] TradeComparer unit tests
- [x] View tests (clipboard text assertions via rendered Phlex + Nokogiri)
- [x] Integration smoke tests (routes, registration, login)
- [x] E2E test: navigate home → register with collection → assert sees own info and collection

## Phase 9: Trade consolidation
- [x] Create `trades` table (user_a, user_b, confirmed_at)
- [x] Create `trade_stickers` pivot (trade_id, sticker_id, giver_id, receiver_id)
- [x] "Consolidar troca" button saves balanced trade to DB
- [x] Trade history on owner's collection page
- [x] Schema annotations on all models

## Phase 10: Deploy
- [ ] Configure Render deployment (render.yaml, Dockerfile or buildpack)
- [ ] Deploy to Render (web service + Postgres + seed)
- [ ] Smoke test with real dumps in production
