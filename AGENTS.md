# Agent Instructions

Instructions for AI coding agents working on this codebase.

## Baseline

Rails 8 application. Assume standard Rails conventions unless explicitly overridden in this file, a DOX file, or an ADR.

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
- **Never push directly to main or merge without explicit user consent. Always open a PR and wait for approval.**
- **Never alter production infrastructure without explicit consent.** This includes env vars, Render service settings, database operations, deploy triggers, and any other production-affecting action. Always ask first.

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

## DOX (Adapted)

This project uses [DOX](https://github.com/agent0ai/dox) — a hierarchical documentation framework for AI agents. DOX files are binding work contracts for their subtrees. See [ADR-0007](docs/adr/0007-adapted-dox-mirror-tree.md) for the adaptation rationale.

**Adaptation:** child DOX files live under `.agents/dox/` in a mirror-tree structure instead of co-located `AGENTS.md` files in source folders. The root `AGENTS.md` stays here (DOX rail).

### Core Contract

Work products, source materials, instructions, records, assets, and durable docs must stay understandable from the nearest applicable DOX file (`.agents/dox/{path}/_index.md`) plus every parent DOX file above it up to this root.

### Path Convention

- Folder contracts → `.agents/dox/{path}/_index.md`
- File contracts (rare) → `.agents/dox/{path}/{filename_without_ext}.md`

Examples:
- `app/services/` → `.agents/dox/app/services/_index.md`
- `app/services/trade_comparer.rb` → `.agents/dox/app/services/trade_comparer.md`

### Read Before Editing

1. Read this root `AGENTS.md`
2. Identify every file or folder you expect to touch
3. Walk from the repository root to each target path
4. For each path segment, check if `.agents/dox/{accumulated_path}/_index.md` exists — read it if so
5. Use the nearest DOX file as the local contract; parent docs for repo-wide rules
6. If docs conflict, the closer doc controls local work details, but no child doc may weaken DOX

Do not rely on memory. Re-read the applicable DOX chain in the current session before editing.

### Update After Editing

Every meaningful change requires a DOX pass before the task is done.

Update the closest owning DOX file when a change affects:
- purpose, scope, ownership, or responsibilities
- durable structure, contracts, workflows, or operating rules
- required inputs, outputs, permissions, constraints, side effects, or artifacts
- user preferences about behavior, communication, process, organization, or quality
- DOX file creation, deletion, move, rename, or index contents

Update parent docs when parent-level structure, ownership, workflow, or child index changes. Update child docs when parent changes alter local rules. Remove stale or contradictory text immediately.

Small edits that do not change behavior or contracts may leave docs unchanged, but the DOX pass still must happen.

### Hierarchy

- This root AGENTS.md is the DOX rail: project-wide instructions, global preferences, durable workflow rules, and the top-level Child DOX Index
- Child DOX files own domain-specific instructions and their own Child DOX Index
- Each parent explains what its direct children cover and what stays owned by the parent
- The closer a doc is to the work, the more specific and practical it must be

### Creating Child Docs

Create `.agents/dox/{path}/_index.md` when a folder becomes a durable boundary with its own purpose, rules, responsibilities, workflow, materials, or quality standards.

Work Guidance must reflect the current standards of the project or user instructions; if there are no specific standards or instructions yet, leave it empty. Verification must reflect an existing check; if no verification framework exists yet, leave it empty and update it when one exists.

Default section order:
- Purpose
- Ownership
- Local Contracts
- Work Guidance
- Verification
- Child DOX Index

Omit empty sections. File-level docs are rare — only when a file outgrows its folder's `_index.md`.

### Closeout

1. Re-check changed paths against the DOX chain
2. Update nearest owning docs and any affected parents or children
3. Refresh every affected Child DOX Index
4. Remove stale or contradictory text
5. Run existing verification when relevant

### Style

- Concise, current, operational
- Document stable interfaces, non-obvious technical decisions, and information that saves tokens in future agentic interactions
- Do not describe what the source code makes obvious — document what an agent would otherwise waste tokens discovering
- Document stable contracts, not diary entries
- Broad rules in parent docs, concrete details in child docs
- Direct bullets with explicit names
- No duplication across files unless each scope needs a local version
- Delete stale notes immediately

### User Preferences

When the user requests a durable behavior change (e.g., "always do X", "never do Y", "I prefer Z"), persist it immediately in this section or in the relevant child DOX file. Do not wait for the end of the task.

Load the `dox` skill for operational helpers (commands, templates, orphan checks).

## Child DOX Index

- [.agents/dox/app/_index.md](.agents/dox/app/_index.md) — application source code
- [.agents/dox/test/_index.md](.agents/dox/test/_index.md) — test suite
- [.agents/dox/config/_index.md](.agents/dox/config/_index.md) — Rails configuration
- [.agents/dox/db/_index.md](.agents/dox/db/_index.md) — database schema, migrations, seeds

## Contributing to AGENTS.md

- Let rules emerge from practice — add guidelines after encountering real problems, not preemptively
- Keep it concise — bullet points over verbose explanations
- Don't repeat general knowledge — only document what's specific to this project
- Prefer soft language — "prefer", "when possible" over strict mandates
- Review the full file when making changes to spot redundancies and maintain consistency
