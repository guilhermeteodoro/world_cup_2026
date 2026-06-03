# Agent Instructions

Instructions for AI coding agents working on this codebase.

## Checks

Run before pushing or updating a PR:

```bash
bundle exec rubocop -A
bin/rails test
```

When checks fail on CI, fetch the failure logs:

```bash
gh run list --limit 1          # find the run ID
gh run view <run_id> --log-failed
```

When amending commits on an open PR, review whether the PR title and description still reflect the actual changes. Update them if the scope shifted.

## Tests

### Guidelines

**Integration tests** are broad smoke tests — one or two happy-path flows per feature. They verify routes work, redirects happen, and the right status codes come back. Don't assert HTML content in integration tests.

**View tests** verify rendering: what text appears, what components are present, clipboard data attributes, Turbo frame structure. Render Phlex components directly via `ComponentTestHelper` and assert on the HTML output with Nokogiri.

**Service/model tests** verify business logic in isolation.

### Rules

1. **Minimal data** — create only the records needed for the assertion. Use small inline dumps (`"SA26|1|1-5|1:1"`) instead of `sample_dump`. A test for balanced trading needs 5 stickers per user, not 591.
2. **Seed is shared** — the sticker catalog (994 stickers, 49 countries) is loaded once at suite startup and shared via transactional rollback. Don't re-seed or depend on seed order.
3. **No content assertions in integration tests** — if you're asserting `response.body` includes specific text, it probably belongs in a view test.
4. **Edge cases in unit tests** — integration tests cover the happy path. Parser edge cases, empty states, error handling, and rendering variations go in service or view tests.

## Environment

- `DATABASE_URL` lives in `.env.production` (loaded only when `RAILS_ENV=production`)
- Dev and test use SQLite via `database.yml` — do NOT set `DATABASE_URL` in `.env`

## Domain language

[CONTEXT.md](CONTEXT.md) is the glossary for this project. When introducing a new domain concept, update CONTEXT.md inline — don't batch. When the user uses a term that conflicts with the glossary, call it out. Keep CONTEXT.md free of implementation details — it's a glossary, not a spec.

## Emerging skills

If you notice a multi-step workflow being repeated across sessions (complex enough to have decision trees, loops, or conditional behavior), suggest extracting it as a project skill in `.agents/skills/`. Don't force it — skills emerge from pain, not pre-planning. A one-liner doesn't need a skill.

## Documentation

- [CONTEXT.md](CONTEXT.md) — domain language glossary
- [README.md](README.md) — project overview for humans
- [docs/adr/](docs/adr/) — architecture decision records
