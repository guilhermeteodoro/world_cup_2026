# Purpose

Application source code for the Sticker Trader Rails app. Follows standard Rails directory layout with one exception: UI components live in `app/ui/` instead of `app/views/` (see ADR-0006).

# Ownership

All runtime application code. Config, tests, and infrastructure live elsewhere.

# Local Contracts

- No business logic in controllers — delegate to services or models
- Models are thin: associations, validations, scopes, and simple query methods
- Services encapsulate multi-step operations and return structured results
- UI layer uses Phlex exclusively (no ERB for components)

# Work Guidance

- Run `bundle exec rubocop -A` after any Ruby change
- Follow domain language from CONTEXT.md — especially sticker/collection/trade terminology
- Check ADR-0006 before adding new UI classes

# Child DOX Index

- [models/_index.md](models/_index.md) — ActiveRecord models and domain entities
- [services/_index.md](services/_index.md) — service objects for business operations
- [controllers/_index.md](controllers/_index.md) — HTTP request handling
- [ui/_index.md](ui/_index.md) — Phlex-based presentation layer
- [views/_index.md](views/_index.md) — ERB templates (legacy, minimal use)
