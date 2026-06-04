# Agent Instructions

Instructions for AI coding agents working on this codebase.

## Checks

Run before pushing or updating a PR:

```bash
bundle exec rubocop -A
bin/rails test
```

### CI

CI runs on GitHub Actions (`.github/workflows/ci.yml`). To check status and fetch failures:

```bash
gh run list --limit 1                    # check latest run status
gh run view <run_id> --log-failed        # fetch failure logs
gh pr checks                             # check status of current PR's checks
```

Common CI failures:
- **Stale branch** — rebase on main when tests pass locally but fail on CI due to missing changes from other merged PRs
- **Rubocop offenses** — always run `rubocop -A` before pushing
- **Missing keyword args** — view signatures may change after merging other PRs; rebase fixes this

When amending commits on an open PR, review whether the PR title and description still reflect the actual changes. Update them if the scope shifted.

### Git

- Prefer normal commits over amending — keep history navigable so we can easily go back
- Force-push only when explicitly asked
- When a PR is merged and new work is requested, always pull the target branch (usually main) and create a new branch from it before starting. If the target might be a feature branch, confirm before branching.

### Commit messages and PR titles

Follow [Karma commit message format](https://karma-runner.github.io/0.13/dev/git-commit-msg.html). PR titles use the same format (they become the merge commit in history).

```
<type>(<scope>): <subject>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Scope is optional — use when the change is clearly scoped to one area (e.g., `feat(diff): add copy buttons`). Omit when global or hard to assign.

Subject: imperative, present tense, lowercase, no period at end.

Examples:
- `feat(diff): add sticker list diff tool`
- `fix: resolve turbo frame rendering on diff page`
- `refactor(tests): move content assertions to view tests`
- `docs: add AGENTS.md and adr-workflow skill`

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

## Presentation layer

UI code lives in `app/ui/` (components, fragments, layouts) — not `app/views/`. See [ADR-0006](docs/adr/0006-presentation-layer-organization.md) for the decision guide on where to place new UI classes.

## Environment

- All environments use SQLite via `database.yml`
- Production database lives at `/var/data/production.sqlite3` (Render persistent disk)

## Domain language

[CONTEXT.md](CONTEXT.md) is the glossary for this project. When introducing a new domain concept, update CONTEXT.md inline — don't batch. When the user uses a term that conflicts with the glossary, call it out. Keep CONTEXT.md free of implementation details — it's a glossary, not a spec.

## Architecture Decision Records (ADRs)

ADRs live in `docs/adr/`, managed by [adr-tools](https://github.com/npryce/adr-tools).

- Before implementing, check existing ADRs: `adr list`
- Read relevant ADRs to understand rationale and constraints
- Suggest an ADR when a decision is hard to reverse, surprising without context, and the result of a real trade-off
- ADR format follows a structured template (Date, Status, Context, Decision, Consequences) — keep each section concise
- Load the `adr-workflow` skill for the full workflow
- If `adr` is not installed, create the file manually (next sequential number in `docs/adr/`) and suggest the user installs adr-tools

## Emerging skills

If you notice a multi-step workflow being repeated across sessions (complex enough to have decision trees, loops, or conditional behavior), suggest extracting it as a project skill in `.agents/skills/`. Don't force it — skills emerge from pain, not pre-planning. A one-liner doesn't need a skill.

## Documentation

- [CONTEXT.md](CONTEXT.md) — domain language glossary
- [README.md](README.md) — project overview for humans
- [docs/adr/](docs/adr/) — architecture decision records
- [.agents/skills/](.agents/skills/) — reusable workflow skills

## Contributing to AGENTS.md

- Let rules emerge from practice — add guidelines after encountering real problems, not preemptively
- Keep it concise — bullet points over verbose explanations
- Don't repeat general knowledge — only document what's specific to this project
- Prefer soft language — "prefer", "when possible" over strict mandates
- Review the full file when making changes to spot redundancies and maintain consistency
